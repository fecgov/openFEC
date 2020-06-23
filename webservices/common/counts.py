"""Approximate query count based on ANALYZE output for PostgreSQL and SQLAlchemy.

Count logic borrowed from https://wiki.postgresql.org/wiki/Count_estimate
ANALYZE borrowed from https://bitbucket.org/zzzeek/sqlalchemy/wiki/UsageRecipes/Explain
"""

import re

from sqlalchemy.ext.compiler import compiles
from sqlalchemy.sql.expression import Executable, ClauseElement, _literal_as_text
from webservices.common import models


count_pattern = re.compile(r'rows=(\d+)')


def get_count(query, model, estimate=True, use_pk_for_count=False, threshold=500000):
    """
    Calculate either the estimated count or exact count.
    Indicate whether the count is an estimate.
    """
    if use_pk_for_count and model:
        primary_key = model.__mapper__.primary_key[0]
        query = query.with_entities(primary_key)
    if estimate:
        rows = get_query_plan(query)
        count = extract_analyze_count(rows)
        if count < threshold:
            estimate = False
            count = query.count()
    else:
        count = query.count()
    return count, estimate


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
