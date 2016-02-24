import os
import hashlib
import logging
import zipfile
import datetime
import tempfile

from sqlalchemy.dialects import postgresql

from webargs import flaskparser
from flask_apispec.utils import resolve_annotations
from celery_once import QueueOnce

from webservices import utils
from webservices.common import counts
from webservices.common.models import db
from webservices.resources import candidates, committees, filings, costs, sched_e

from webservices.tasks import app
from webservices.tasks import utils as task_utils

logger = logging.getLogger(__name__)

IGNORE_FIELDS = {'page', 'per_page', 'sort', 'sort_hide_null'}
RESOURCE_WHITELIST = {
    candidates.CandidateList,
    committees.CommitteeList,
    filings.FilingsList,
    costs.CommunicationCostView,
    costs.ElectioneeringView,
    sched_e.ScheduleEView,
}

COUNT_NOTE = (
    '*Note: The record count displayed on the website is an estimate. The record '
    'count in this manifest is accurate and will equal the rows in the accompanying '
    'CSV file.'
)

def call_resource(path, qs):
    app = task_utils.get_app()
    endpoint, arguments = app.url_map.bind('').match(path)
    resource_type = app.view_functions[endpoint].view_class
    if resource_type not in RESOURCE_WHITELIST:
        raise ValueError('Downloads on resource {} not supported'.format(resource_type.__name__))
    resource = resource_type()
    fields, kwargs = parse_kwargs(resource, qs)
    kwargs = utils.extend(arguments, kwargs)
    for field in IGNORE_FIELDS:
        kwargs.pop(field, None)
    query, model, schema = unpack(resource.build_query(**kwargs), 3)
    count = counts.count_estimate(query, db.session, threshold=5000)
    return {
        'path': path,
        'qs': qs,
        'name': get_s3_name(path, qs),
        'query': query,
        'schema': schema or resource.schema,
        'resource': resource,
        'count': count,
        'timestamp': datetime.datetime.utcnow(),
        'fields': fields,
        'kwargs': kwargs,
    }

def parse_kwargs(resource, qs):
    annotation = resolve_annotations(resource.get, 'args', parent=resource)
    fields = utils.extend(*[option['args'] for option in annotation.options])
    with task_utils.get_app().test_request_context(b'?' + qs):
        kwargs = flaskparser.parser.parse(fields)
    return fields, kwargs

def query_to_csv(query, fp):
    dialect = postgresql.dialect()
    compiled = query.statement.compile(dialect=dialect)
    conn = db.engine.raw_connection()
    cursor = conn.cursor()
    select = cursor.mogrify(compiled.string, compiled.params).decode()
    copy = 'copy ({}) to stdout with csv header'.format(select)
    cursor.copy_expert(copy, fp)
    conn.close()

def query_with_labels(query, schema):
    """Create a new query that labels columns according to the SQLAlchemy model.
    Properties that are excluded by `schema` will be ignored.

    :param query: Original SQLAlchemy query
    :param schema: Optional schema specifying properties to exclude
    :returns: Query with labeled entities
    """
    description = query.column_descriptions[0]
    mapper = description['expr']
    model = description['type']
    exclude = getattr(schema.Meta, 'exclude', ())
    properties = [
        mapper.get_property_by_column(column)
        for column in mapper.columns
    ]
    entities = [
        getattr(model, prop.key).label(prop.key)
        for prop in properties if prop.key not in exclude
    ]
    return query.with_entities(*entities)

def unpack(values, size):
    values = values if isinstance(values, tuple) else (values, )
    return values + (None, ) * (size - len(values))

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

def make_manifest(resource, row_count, path):
    with open(os.path.join(path, 'manifest.txt'), 'w') as fp:
        fp.write('Time: {}\n'.format(resource['timestamp']))
        fp.write('Resource: {}\n'.format(resource['path']))
        fp.write('*Count: {}\n'.format(row_count))
        fp.write('Filters:\n\n')
        fp.write('{}\n\n'.format(COUNT_NOTE))
        fp.write(make_filters(resource))

def make_filters(resource):
    lines = []
    for key, value in resource['kwargs'].items():
        if key in resource['fields']:
            value = ', '.join(map(format, value)) if isinstance(value, list) else value
            description = resource['fields'][key].metadata.get('description')
            lines.append(make_filter(key, value, description))
    return '\n\n'.join(lines)

def make_filter(key, value, description):
    lines = []
    lines.append('{}: {}'.format(key, value))
    if description:
        lines.append(description.strip())
    return '\n'.join(lines)

def wc(path):
    with open(path) as fp:
        return sum(1 for _ in fp.readlines())

def make_bundle(resource):
    with tempfile.TemporaryDirectory(dir=os.getenv('TMPDIR')) as tmpdir:
        csv_path = os.path.join(tmpdir, 'data.csv')
        with open(csv_path, 'w') as fp:
            query = query_with_labels(resource['query'], resource['schema'])
            query_to_csv(query, fp)
        row_count = wc(csv_path)
        make_manifest(resource, row_count, tmpdir)
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
    make_bundle(resource)

@app.task
def clear_bucket():
    for key in task_utils.get_bucket().objects.all():
        key.delete()
