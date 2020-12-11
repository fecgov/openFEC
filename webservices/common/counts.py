"""Approximate query count based on ANALYZE output for PostgreSQL and SQLAlchemy.

Count logic borrowed from https://wiki.postgresql.org/wiki/Count_estimate
ANALYZE borrowed from https://bitbucket.org/zzzeek/sqlalchemy/wiki/UsageRecipes/Explain
"""

import re

from sqlalchemy.ext.compiler import compiles
from sqlalchemy.sql.expression import Executable, ClauseElement, _literal_as_text
from webservices.common import models


count_pattern = re.compile(r'rows=(\d+)')


def is_estimated_count(resource, query):
    """
    determine prior to counting if count will be an estimate (avoids calling
    get_counts and using the `is_estimate` return value which may cause
    exact counting (when False)
    """
    if resource.use_pk_for_count and resource.model:
        primary_key = resource.model.__mapper__.primary_key[0]
        query = query.with_entities(primary_key)
    if resource.use_estimated_counts:
        estimated_count = get_estimated_count(query)
        if estimated_count > resource.estimated_count_threshold:
            return True
    return False


def get_count(resource, query):
    """
    Calculate either the estimated count or exact count.
    Indicate whether the count is an estimate.
    Optionally only select the primary key column in the query
    """
    is_estimate = is_estimated_count(resource, query)
    if is_estimate:
        estimated_count = get_estimated_count(query)
        return estimated_count, is_estimate
    # Use exact counts for `use_estimated_counts == False` and small result sets
    exact_count = query.count()
    return exact_count, is_estimate


def get_estimated_count(query):
    rows = get_query_plan(query)
    estimated_count = extract_analyze_count(rows)
    return estimated_count


def get_query_plan(query):
    return models.db.session.execute(explain(query)).fetchall()


def extract_analyze_count(rows):
    for row in rows:
        match = count_pattern.search(row[0])
        if match:
            return int(match.groups()[0])


class explain(Executable, ClauseElement):
    def __init__(self, stmt, analyze=False):
        self.statement = _literal_as_text(stmt)
        self.analyze = analyze
        # helps with INSERT statements
        self.inline = getattr(stmt, 'inline', None)


@compiles(explain, 'postgresql')
def pg_explain(element, compiler, **kw):
    text = 'EXPLAIN '
    if element.analyze:
        text += 'ANALYZE '
    text += compiler.process(element.statement, **kw)
    return text
