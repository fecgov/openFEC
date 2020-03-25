import base64
import hashlib
import logging
import datetime

from webargs import flaskparser
from flask_apispec.utils import resolve_annotations
from postgres_copy import query_entities, copy_to
from celery_once import QueueOnce
from smart_open import smart_open

from webservices import utils
from webservices.common import counts
from webservices.common.models import db
from webservices.legal_docs.index_management import BACKUP_DIRECTORY

from webservices.tasks import app
from webservices.tasks import utils as task_utils

logger = logging.getLogger(__name__)

IGNORE_FIELDS = {'page', 'per_page', 'sort', 'sort_hide_null'}


def call_resource(path, qs):
    app = task_utils.get_app()
    endpoint, arguments = app.url_map.bind('').match(path)
    resource_type = app.view_functions[endpoint].view_class
    resource = resource_type()
    fields, kwargs = parse_kwargs(resource, qs)
    kwargs = utils.extend(arguments, kwargs)

    for field in IGNORE_FIELDS:
        kwargs.pop(field, None)

    query, model, schema = unpack(resource.build_query(**kwargs), 3)
    count, _ = counts.get_count(query, db.session, resource.use_estimated_counts)
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


def query_with_labels(query, schema, sort_columns=False):
    """Create a new query that labels columns according to the SQLAlchemy
    model.  Properties that are excluded by `schema` will be ignored.

    Furthermore, if a "relationships" attribute is set on the schema (via the
    Meta options object), those relationships will be followed to include the
    specified nested fields in the output.  By default, only the fields
    defined on the model mapped directly to columns in the corresponding table
    will be included.

    :param query: Original SQLAlchemy query
    :param schema: Optional schema specifying properties to exclude
    :param sort_columns: Optional flag to sort the column labels by name
    :returns: Query with labeled entities
    """
    exclude = getattr(schema.Meta, 'exclude', ())
    relationships = getattr(schema.Meta, 'relationships', [])
    joins = []
    entities = [
        entity for entity in query_entities(query)
        if entity.key not in exclude
    ]

    for relationship in relationships:
        if relationship.position == -1:
            entities.append(relationship.column.label(relationship.label))
        else:
            entities.insert(
                relationship.position,
                relationship.column.label(relationship.label)
            )

        if relationship.field not in joins:
            joins.append(relationship.field)

    if sort_columns:
        entities.sort(key=lambda x: x.name)

    if joins:
        query = query.join(*joins).with_entities(*entities)
    else:
        query = query.with_entities(*entities)

    return query

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
    return '{}.csv'.format(hashed)


def make_bundle(resource):
    s3_key = task_utils.get_s3_key(resource['name'])
    with smart_open(s3_key, "wb") as fp:
        query = query_with_labels(
            resource['query'],
            resource['schema']
        )
        copy_to(
            query,
            fp,
            db.session.connection().engine,
            format='csv',
            header=True
        )

@app.task(base=QueueOnce, once={'graceful': True})
def export_query(path, qs):
    qs = base64.b64decode(qs.encode('UTF-8'))

    try:
        logger.info('Download query: {0}'.format(qs))
        resource = call_resource(path, qs)
        logger.info('Download resource: {0}'.format(qs))
        make_bundle(resource)
        logger.info('Bundled: {0}'.format(qs))
    except Exception:
        logger.exception('Download failed: {0}'.format(qs))


@app.task
def clear_bucket():
    permanent_dir = ('legal', 'bulk-downloads', BACKUP_DIRECTORY)
    for obj in task_utils.get_bucket().objects.all():
        if not obj.key.startswith(permanent_dir):
            obj.delete()
