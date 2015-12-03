import os
import csv
import hashlib
import logging
import zipfile
import datetime
import tempfile
import collections

import marshmallow
from webargs import flaskparser
from flask_apispec.utils import resolve_annotations
from celery_once import QueueOnce

from webservices import utils
from webservices.common import counts
from webservices.common.models import db

from webservices.tasks import app
from webservices.tasks import utils as task_utils

logger = logging.getLogger(__name__)

def call_resource(path, qs, per_page=5000):
    app = task_utils.get_app()
    endpoint, arguments = app.url_map.bind('').match(path)
    resource = app.view_functions[endpoint].view_class()
    kwargs = parse_kwargs(resource, qs)
    kwargs = utils.extend(arguments, kwargs)
    kwargs['per_page'] = per_page
    query, model, schema = unpack(resource.build_query(**kwargs), 3)
    count = counts.count_estimate(query, db.session, threshold=5000)
    index_column = utils.get_index_column(model or resource.model)
    paginator = utils.fetch_seek_paginator(query, kwargs, index_column, count=count)
    return {
        'path': path,
        'qs': qs,
        'name': get_s3_name(path, qs),
        'paginator': paginator,
        'schema': schema or resource.schema,
        'resource': resource,
        'count': count,
        'timestamp': datetime.datetime.utcnow(),
    }

def parse_kwargs(resource, qs):
    annotation = resolve_annotations(resource.get, 'args', parent=resource)
    with task_utils.get_app().test_request_context(b'?' + qs):
        kwargs = {}
        for option in annotation.options:
            kwargs.update(flaskparser.parser.parse(option['args']))
    return kwargs

def iter_paginator(paginator):
    last_index, sort_index = (None, None)
    while True:
        logger.info(
            'Fetching page with last_index={last_index}, sort_index={sort_index}'.format(
                **locals()
            )
        )
        page = paginator.get_page(last_index=last_index, sort_index=sort_index)
        if not page.results:
            return
        for result in page.results:
            yield result
        last_indexes = paginator._get_index_values(result)
        last_index = last_indexes['last_index']
        if paginator.sort_column:
            sort_index = last_indexes['last_{}'.format(paginator.sort_column[0].key)]

def unpack(values, size):
    values = values if isinstance(values, tuple) else (values, )
    return values + (None, ) * (size - len(values))

def un_nest(d, parent_key='', sep='_'):
    items = []
    for key, value in d.items():
        new_key = sep.join([parent_key, key]) if parent_key else key
        if value is None:
            continue
        if isinstance(value, collections.Mapping):
            items.extend(un_nest(value, new_key, sep=sep).items())
        else:
            items.append((new_key, value))
    return dict(items)

def create_headers(schema, parent_key='', sep='_'):
    items = []
    for name, field in schema._declared_fields.items():
        new_key = sep.join([parent_key, name]) if parent_key else name
        if isinstance(field, marshmallow.fields.Nested):
            items.extend(create_headers(field.nested, new_key, sep=sep))
        else:
            items.append(new_key)
    return items

def write_query_to_csv(query, schema, writer):
    """Write each query result subset to a csv."""
    instance = schema()
    updated = False
    for result in query:
        if not updated:
            updated = True
        result_dict = instance.dump(result, update_fields=not updated).data
        row = un_nest(result_dict)
        writer.writerow(row)

def rows_to_csv(query, schema, csvfile):
    headers = create_headers(schema)
    writer = csv.DictWriter(csvfile, fieldnames=headers)
    writer.writeheader()
    write_query_to_csv(query, schema, writer)

def get_s3_name(path, qs):
    """

    Example .. code-block:: python

        get_s3_name('schedules/schedule_a', '?office=H&sort=amount')
    """
    # TODO: consider including path in name
    # TODO: consider base64 vs hash
    raw = '{}{}'.format(path, qs)
    hashed = hashlib.sha224(raw.encode('utf-8')).hexdigest()
    return '{}.zip'.format(hashed)

def upload_s3(key, body):
    task_utils.get_bucket().put_object(Key=key, Body=body)

def make_csv(resource, query, path):
    with open(os.path.join(path, 'data.csv'), 'w') as fp:
        rows_to_csv(query, resource['schema'], fp)

def make_manifest(resource, path):
    with open(os.path.join(path, 'manifest.txt'), 'w') as fp:
        fp.write('Time: {}\n'.format(resource['timestamp']))
        fp.write('Resource: {}\n'.format(resource['path']))
        fp.write('Filters: {}\n'.format(resource['qs']))
        fp.write('Count: {}\n'.format(resource['count']))

def make_bundle(resource, query):
    with tempfile.TemporaryDirectory(dir=os.getenv('TMPDIR')) as tmpdir:
        make_csv(resource, query, tmpdir)
        make_manifest(resource, tmpdir)
        with tempfile.TemporaryFile(mode='w+b', dir=os.getenv('TMPDIR')) as tmpfile:
            archive = zipfile.ZipFile(tmpfile, 'w')
            for path in os.listdir(tmpdir):
                _, arcname = os.path.split(path)
                archive.write(os.path.join(tmpdir, path), arcname=arcname)
            archive.close()
            tmpfile.seek(0)
            upload_s3(resource['name'], tmpfile)

@app.task(base=QueueOnce, once={'graceful': True})
def export_query(path, qs):
    resource = call_resource(path, qs)
    query = iter_paginator(resource['paginator'])
    make_bundle(resource, query)

@app.task
def clear_bucket():
    for key in task_utils.get_bucket().objects.all():
        key.delete()
