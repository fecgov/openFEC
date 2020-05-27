"""Approximate query count based on ANALYZE output for PostgreSQL and SQLAlchemy.

Count logic borrowed from https://wiki.postgresql.org/wiki/Count_estimate
ANALYZE borrowed from https://bitbucket.org/zzzeek/sqlalchemy/wiki/UsageRecipes/Explain
"""

import re

from sqlalchemy.ext.compiler import compiles
from sqlalchemy.sql.expression import Executable, ClauseElement, _literal_as_text


count_pattern = re.compile(r'rows=(\d+)')


def get_count(query, session, model, estimate=True, threshold=500000):
    """
    Calculate either the estimated count or exact count.
    Indicate whether the count is an estimate.
    """
    # TODO: Move this to model.table_args? resource? I think table args can't be custom keys
    if estimate:
        # with_entities
        rows = get_query_plan(query.with_entities(model.committee_id), session)
        count = extract_analyze_count(rows)
        if count < threshold:
            estimate = False
            count = query.count()
    else:
        count = query.count()
    return count, estimate


def get_query_plan(query, session):
    print(query)
    return session.execute(explain(query)).fetchall()


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
