import csv
import hashlib
import tempfile
import collections

import boto3
import marshmallow
from webargs import flaskparser
from flask_apispec.utils import resolve_annotations

from webservices import utils
from webservices import schemas
from webservices.rest import app as flask_app
from webservices.common import counts
from webservices.common import models
from webservices.common.models import db
from webservices.resources import sched_a

from cron import app

adapter = flask_app.url_map.bind('')

# TODO: Get bucket name from environ
# TODO: Set up bucket / IAM credentials
BUCKETNAME = ''

def call_resource(path, qs, per_page=5000):
    endpoint, arguments = adapter.match(path)
    resource = flask_app.view_functions[endpoint].view_class()
    kwargs = parse_kwargs(resource, qs)
    kwargs['per_page'] = per_page
    query = resource.build_query(**utils.extend(arguments, kwargs))
    count = counts.count_estimate(query, db.session, threshold=5000)
    paginator = utils.fetch_seek_paginator(query, kwargs, resource.index_column, count=count)
    return paginator, resource.schema

def parse_kwargs(resource, qs):
    annotation = resolve_annotations(resource.get, 'args', parent=resource)
    with flask_app.test_request_context(qs):
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
    # CALL QUERY ITERATIOR
    write_query_to_csv(query, schema, writer)

def get_s3_name(path, qs):
    """

    Example .. code-block:: python

        get_s3_name('schedules/schedule_a', '?office=H&sort=amount')
    """
    # TODO: consider including path in name
    # TODO: consider base64 vs hash
    call = '{}{}.csv'.format(path, qs)
    return hashlib.sha224(call.encode('utf-8')).hexdigest()


s3 = boto3.resource('s3')

def upload_s3(name, file):
    s3.Bucket(BUCKETNAME).put_object(Key=name, Body=file)

@app.task
def export_query(path, qs):
    # TODO: consider moving app context to celery worker init
    with flask_app.app_context():
        paginator, schema = call_resource(path, qs)
        query = iter_paginator(paginator)
        name = get_s3_name(path, qs)
        # TODO: Can we pass the file mode to csv instead?
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv') as fp:
            rows_to_csv(query, schema, fp)
            upload_s3(name, fp)