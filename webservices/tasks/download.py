import base64
import hashlib
import logging
import datetime
import re

import psycopg2
from psycopg2 import errorcodes
from webargs import flaskparser
from flask_apispec.utils import resolve_annotations
from postgres_copy import query_entities, format_flags
from smart_open import open
from celery import shared_task
from celery.exceptions import SoftTimeLimitExceeded
from sqlalchemy import exc as sa_exc
from webservices.tasks.celery import FlaskQueueOnce
from sqlalchemy.dialects import postgresql
from webservices.env import env

from webservices import utils
from webservices.common import counts
from webservices.common.models import db
from webservices.common.models.itemized import ScheduleA

from webservices.legal.constants import S3_BACKUP_DIRECTORY

from webservices.tasks import utils as task_utils
from flask import Flask, current_app

logger = logging.getLogger(__name__)

IGNORE_FIELDS = {"page", "per_page", "sort", "sort_hide_null"}

DOWNLOAD_SOFT_LIMIT = int(env.get_credential("DOWNLOAD_SOFT_LIMIT", 240))
DOWNLOAD_HARD_LIMIT = int(env.get_credential("DOWNLOAD_HARD_LIMIT", 300))

# Failure categories emitted in the "download_failed" log line. Keep these stable: they are searched in logs.
FAILURE_SOFT_TIME_LIMIT = "soft_time_limit"
FAILURE_DB_STATEMENT_TIMEOUT = "db_statement_timeout"
FAILURE_DB_QUERY_CANCELED = "db_query_canceled"
FAILURE_DB_ERROR = "db_error"
FAILURE_UNEXPECTED = "unexpected_error"


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
    client = task_utils.get_s3_client()
    bucket_name = env.get_credential("AWS_PUBLIC_BUCKET")
    s3_uri = f"s3://{bucket_name}/{resource['name']}"

    with open(s3_uri, "wb", transport_params={"client": client}) as fp:
        query = query_with_labels(
            resource["query"],
            resource["schema"]
        )
        copy_to(
            query,
            fp,
            db.session.connection().engine,
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
    conn = engine.raw_connection()

    overlap_prefixes = source.get_execution_options().get("overlap_columns", set())

    if "POSTCOMPILE" in sql:
        sql = rebind_postcompile(sql)
        params = convert_lists_to_tuples(params, overlap_prefixes)

    try:
        with conn.cursor() as cursor:
            query = cursor.mogrify(sql, params).decode()
            formatted_flags = f"({format_flags(flags)})" if flags else ""
            copy_sql = f"COPY ({query}) TO STDOUT {formatted_flags}"
            cursor.copy_expert(copy_sql, dest)
    finally:
        conn.close()


def rebind_postcompile(sql):
    pattern = r"\(__\[POSTCOMPILE_([a-zA-Z0-9_]+)\]\)"
    return re.sub(pattern, r"%(\1)s", sql)


def convert_lists_to_tuples(params, overlap_prefixes):
    for key, val in params.items():
        if isinstance(val, list):
            if any(key.startswith(prefix) for prefix in overlap_prefixes):
                params[key] = val
            else:
                params[key] = tuple(val)
    return params


def _exception_chain(exc):
    """Yield exc and the exceptions it wraps: SQLAlchemy ``.orig``, ``__cause__`` and ``__context__``."""
    seen = set()
    pending = [exc]
    while pending:
        current = pending.pop(0)
        if current is None or id(current) in seen:
            continue
        seen.add(id(current))
        yield current
        pending.extend([getattr(current, "orig", None), current.__cause__, current.__context__])


def classify_download_failure(exc):
    """Return (category, pgcode) for a download failure.

    Statement timeouts and other cancellations share SQLSTATE 57014 (query_canceled), so the
    server message is used to tell them apart. Handles both SQLAlchemy-wrapped errors (the
    count query) and raw psycopg2 errors (the COPY, which runs on a raw DBAPI connection).
    """
    if isinstance(exc, SoftTimeLimitExceeded):
        return FAILURE_SOFT_TIME_LIMIT, None
    for error in _exception_chain(exc):
        if isinstance(error, psycopg2.Error):
            pgcode = error.pgcode
            if pgcode == errorcodes.QUERY_CANCELED:
                diag = getattr(error, "diag", None)
                message = (getattr(diag, "message_primary", None) or str(error)).lower()
                if "statement timeout" in message:
                    return FAILURE_DB_STATEMENT_TIMEOUT, pgcode
                return FAILURE_DB_QUERY_CANCELED, pgcode
            return FAILURE_DB_ERROR, pgcode
    if any(isinstance(error, sa_exc.SQLAlchemyError) for error in _exception_chain(exc)):
        return FAILURE_DB_ERROR, None
    return FAILURE_UNEXPECTED, None


def _log_download_failure(task_id, path, exc):
    """Emit one searchable line per failure. Deliberately excludes the query string and the
    exception message, which can contain SQL and bound parameter values."""
    category, pgcode = classify_download_failure(exc)
    logger.error(
        "download_failed task_id=%s category=%s exception_class=%s.%s pgcode=%s path=%s",
        task_id, category, type(exc).__module__, type(exc).__qualname__, pgcode, path,
    )


def _record_download_failure(task_id):
    """Write the failure state the API polls for. Redis errors are logged and swallowed so they
    never mask the original download exception.

    The failed key is written first, and the queued key is only removed once that succeeds:
    if neither key were present, the next API poll would queue the failed query again.
    """
    for event, operation in (
        ("download_failure_state_not_recorded",
         lambda: task_utils.set_redis_value('download-failed:{}'.format(task_id), True, age=7200)),
        ("download_queued_state_not_cleared",
         lambda: task_utils.delete_redis_value('download-queued:{}'.format(task_id))),
    ):
        try:
            operation()
        except Exception as redis_exc:
            logger.error(
                "%s task_id=%s exception_class=%s.%s",
                event, task_id, type(redis_exc).__module__, type(redis_exc).__qualname__,
            )
            return


@shared_task(
    bind=True,
    base=FlaskQueueOnce,
    once={"graceful": True},
    soft_time_limit=DOWNLOAD_SOFT_LIMIT,
    time_limit=DOWNLOAD_HARD_LIMIT,
)
def export_query(self, path, qs):
    task_id = self.request.id
    qs = base64.b64decode(qs)

    try:
        logger.info("Download query: {0}".format(qs))
        resource = call_resource(current_app, path, qs.decode('utf-8'))
        logger.info("Download resource: {0}".format(qs))
        make_bundle(resource)
        logger.info("Bundled: {0}".format(qs))
    except SoftTimeLimitExceeded as exc:
        logger.exception(f"Download soft time limit exceeded ({DOWNLOAD_SOFT_LIMIT} seconds): {qs}")
        _record_download_failure(task_id)
        _log_download_failure(task_id, path, exc)
        raise
    except Exception as exc:
        # No exc_info: the exception is re-raised and Celery logs its traceback, which can include
        # SQL and bound parameters; logging it here as well would duplicate them.
        logger.error("Download failed: {0}".format(qs))
        _record_download_failure(task_id)
        _log_download_failure(task_id, path, exc)
        # Re-raise so the worker reports the task as failed (#6704). No retry is configured, so
        # the task is not requeued; the API reports the failure via download-failed:<task_id>.
        raise


@shared_task
def clear_bucket():
    permanent_dir = ("legal", "bulk-downloads", S3_BACKUP_DIRECTORY)
    for obj in task_utils.get_bucket().objects.all():
        if not obj.key.startswith(permanent_dir):
            obj.delete()
