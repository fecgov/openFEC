import csv
import hashlib
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
    return paginator, schema or resource.schema

def parse_kwargs(resource, qs):
    annotation = resolve_annotations(resource.get, 'args', parent=resource)
    with task_utils.get_app().test_request_context(qs):
        kwargs = {}
        for option in annotation.options:
            kwargs.update(flaskparser.parser.parse(option['args']))
    return kwargs

def iter_paginator(paginator):
    last_index, sort_index = (None, None)
    while True:
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

# don't know if we will need this one
def un_nest(d, parent_key='', sep='_'):
    items = []
    for k, v in d.items():
        new_key = parent_key + sep + k if parent_key else k
        if v is None:
            continue
        if isinstance(v, collections.MutableMapping):
            items.extend(un_nest(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)

# TODO: consider abstracting recursion
def create_headers(schema, parent_key='', sep='_'):
    items = []
    for name, field in schema._declared_fields.items():
        # TODO: use string formatting or string.join
        new_key = parent_key + sep + name if parent_key else name
        if isinstance(field, marshmallow.fields.Nested):
            items.extend(create_headers(field.nested, new_key, sep=sep))
        else:
            items.append(new_key)
    return items

def write_query_to_csv(query, schema, writer):
    """Write each query result subset to a csv."""

    for result in query:
        result_dict = schema().dump(result).data
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
    return '{}.csv'.format(hashed)


def upload_s3(key, body):
    task_utils.get_bucket().put_object(Key=key, Body=body)

@app.task(base=QueueOnce, once={'graceful': True})
def export_query(path, qs):
    paginator, schema = call_resource(path, qs)
    query = iter_paginator(paginator)
    name = get_s3_name(path, qs)
    # Note: Write CSV as unicode; read for upload as bytes
    with tempfile.NamedTemporaryFile(mode='w') as fp:
        rows_to_csv(query, schema, fp)
        fp.flush()
        upload_s3(name, open(fp.name, mode='rb'))
