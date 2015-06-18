"""Approximate query count based on ANALYZE output for PostgreSQL and SQLAlchemy.

Count logic borrowed from https://wiki.postgresql.org/wiki/Count_estimate
ANALYZE borrowed from https://bitbucket.org/zzzeek/sqlalchemy/wiki/UsageRecipes/Explain
"""

import re

from sqlalchemy.ext.compiler import compiles
from sqlalchemy.sql.expression import Executable, ClauseElement, _literal_as_text


count_pattern = re.compile(r'rows=(\d+)')


def count_estimate(query, session, threshold=None):
    rows = session.execute(explain(query)).fetchall()
    count = extract_analyze_count(rows)
    if threshold is not None and count < threshold:
        return query.count()
    return count


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
