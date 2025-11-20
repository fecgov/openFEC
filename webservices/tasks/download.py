import base64
import hashlib
import logging
import datetime
import re
import subprocess
import sys
import json

from webargs import flaskparser
from flask_apispec.utils import resolve_annotations
from postgres_copy import query_entities
from celery_once import QueueOnce
from smart_open import smart_open
from celery import shared_task
from sqlalchemy.dialects import postgresql

from webservices import utils
from webservices.common import counts
from webservices.common.models import db
from webservices.common.models.itemized import ScheduleA

from webservices.legal.constants import S3_BACKUP_DIRECTORY

from webservices.tasks import utils as task_utils
from flask import Flask, current_app

logger = logging.getLogger(__name__)

IGNORE_FIELDS = {"page", "per_page", "sort", "sort_hide_null"}


def call_resource(app: Flask, path, qs):
    with app.app_context():
        endpoint, arguments = app.url_map.bind("").match(path)
        resource_type = app.view_functions[endpoint].view_class
        resource = resource_type()
        fields, kwargs = parse_kwargs(app, resource, qs)
        kwargs = utils.extend(arguments, kwargs)

        for field in IGNORE_FIELDS:
            kwargs.pop(field, None)

        query, model, schema = unpack(resource.build_query(**kwargs), 3)
        count, _ = counts.get_count(resource, query)
        return {
            "path": path,
            "qs": qs,
            "name": get_s3_name(path, qs.encode('utf-8')),
            "query": query,
            "schema": schema or resource.schema,
            "resource": resource,
            "count": count,
            "timestamp": datetime.datetime.utcnow(),
            "fields": fields,
            "kwargs": kwargs,
        }


def parse_kwargs(app: Flask, resource, qs):
    annotation = resolve_annotations(resource.get, "args", parent=resource)
    fields = utils.extend(*[option["args"] for option in annotation.options])
    with app.test_request_context("?" + qs):
        kwargs = flaskparser.parser.parse(fields, location='query')
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
    exclude = list(getattr(schema.Meta, "exclude", ()))

    # remove empty committee_name from schedule A downloads
    if query.column_descriptions[0]["entity"] == ScheduleA:
        exclude.append("committee_name")

    relationships = getattr(schema.Meta, "relationships", [])
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
        query = query.join(*joins).with_only_columns(*entities)
    else:
        query = query.with_only_columns(*entities)

    return query


def unpack(values, size):
    values = values if isinstance(values, tuple) else (values, )
    return values + (None, ) * (size - len(values))


def get_s3_name(path, qs):
    """

    Example .. code-block:: python

        get_s3_name("schedules/schedule_a", "?office=H&sort=amount")
    """
    # TODO: consider including path in name
    # TODO: consider base64 vs hash
    raw = "{}{}".format(path, qs)
    hashed = hashlib.sha224(raw.encode("utf-8")).hexdigest()
    prefix = "user-downloads/"
    return "{}{}.csv".format(prefix, hashed)


def make_bundle(resource):
    s3_key = task_utils.get_s3_key(resource["name"])
    with smart_open(s3_key, "wb") as fp:
        query = query_with_labels(
            resource["query"],
            resource["schema"]
        )
        copy_to(
            query,
            fp,
            db.engine,
            format="csv",
            header=True
        )


# modified for sqlalchemy 2.0 style taken from sqlalchemy-postgres-copy package by Joshua Carp
# https://github.com/jmcarp/sqlalchemy-postgres-copy
def copy_to(source, dest, engine, **flags):
    dialect = postgresql.dialect()
    compiled = source.compile(dialect=dialect)

    sql = compiled.string
    params = compiled.params
    array_keys = getattr(source, '_array_cast_keys', set())

    if "POSTCOMPILE" in sql:
        sql = rebind_postcompile(sql)
        params = convert_lists_to_tuples(params, array_keys)

    with engine.connect() as conn:
        raw_conn = conn.connection.dbapi_connection
        with raw_conn.cursor() as cursor:
            bound_query = cursor.mogrify(sql, params).decode()

    # copy_expert separate process wo psycogreen
    url = engine.url
    config = {
        'host': url.host,
        'port': url.port,
        'database': url.database,
        'user': url.username,
        'password': url.password,
        'query': bound_query,
        'flags': flags
    }

    result = subprocess.run([
        sys.executable, 'webservices/tasks/copy_worker.py'
    ], input=json.dumps(config), text=True, stdout=subprocess.PIPE, check=True)

    dest.write(result.stdout.encode('utf-8'))


def rebind_postcompile(sql):
    pattern = r"\(__\[POSTCOMPILE_([a-zA-Z0-9_]+)\]\)"
    return re.sub(pattern, r"%(\1)s", sql)


def convert_lists_to_tuples(params, array_keys):
    for key, val in params.items():
        if isinstance(val, list):
            if any(key.startswith(prefix) for prefix in array_keys):
                params[key] = val
            else:
                params[key] = tuple(val)
    return params


@shared_task(base=QueueOnce, once={"graceful": True})
def export_query(path, qs):
    qs = base64.b64decode(qs)

    try:
        logger.info("Download query: {0}".format(qs))
        resource = call_resource(current_app, path, qs.decode('utf-8'))
        logger.info("Download resource: {0}".format(qs))
        make_bundle(resource)
        logger.info("Bundled: {0}".format(qs))
    except Exception:
        logger.exception("Download failed: {0}".format(qs))


@shared_task
def clear_bucket():
    permanent_dir = ("legal", "bulk-downloads", S3_BACKUP_DIRECTORY)
    for obj in task_utils.get_bucket().objects.all():
        if not obj.key.startswith(permanent_dir):
            obj.delete()
