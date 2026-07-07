"""Approximate query count based on ANALYZE output for PostgreSQL and SQLAlchemy.

Count logic borrowed from https://wiki.postgresql.org/wiki/Count_estimate
ANALYZE borrowed from https://bitbucket.org/zzzeek/sqlalchemy/wiki/UsageRecipes/Explain
"""

import re

from sqlalchemy.ext.compiler import compiles
from sqlalchemy.sql.expression import Executable, ClauseElement
from webservices.common import models
from sqlalchemy import select, func

count_pattern = re.compile(r'rows=(\d+)')


def check_result_exist(resource, query):
    """
    use_pk_for_count = true for schedule_a, schedule_b and schedule_e.
    """
    is_result_exist = False
    if resource.use_pk_for_count and resource.model:
        primary_key = resource.model.__mapper__.primary_key[0]
        query = query.with_only_columns(primary_key)

    is_result_exist = models.db.session.execute(select(query.exists())).scalar()
    return is_result_exist


def is_estimated_count(resource, query):
    """
    1)Determine prior to counting if count will be an estimate (avoids calling
    get_counts and using the `is_estimate` return value which may cause
    exact counting (when False)

    2)use_estimated_counts is always false for ScheduleEEfileView

    3)is_count_exact is always true for
    ElectionsListView(endpoint:'/elections/search/')
    ReportsView('/reports/<string:entity_type>/')
    CommitteeReportsView('/committee/<string:committee_id>/reports/')
    TotalsByEntityTypeView('/totals/<string:entity_type>/')
    TotalsCommitteeView('/committee/<string:committee_id>/totals/')
    CandidateTotalsDetailView('/candidate/<string:candidate_id>/totals/')
    """

    if resource.use_pk_for_count and resource.model:
        primary_key = resource.model.__mapper__.primary_key[0]
        query = query.with_only_columns(primary_key)
    if resource.use_estimated_counts:
        estimated_count, _ = get_estimated_count(resource, query)
        if estimated_count > resource.estimated_count_threshold:
            resource.is_count_exact = False
            return True
    resource.is_count_exact = True
    return False


def get_exact_count(resource, query):
    exact_count = models.db.session.scalar(select(func.count()).select_from(query.subquery()))
    resource.is_count_exact = True
    return exact_count, resource.is_count_exact


def get_count(resource, query):
    """
    Calculate either the estimated count or exact count.
    Indicate whether the count is an estimate.
    Optionally only select the primary key column in the query
    used by download.py
    """
    is_estimate = is_estimated_count(resource, query)

    if is_estimate:
        estimated_count, _ = get_estimated_count(resource, query)
        return estimated_count, is_estimate
        # # Use exact counts for `use_estimated_counts == False` and small result sets
    exact_count = models.db.session.scalar(select(func.count()).select_from(query.subquery()))
    return exact_count, is_estimate


def get_estimated_count(resource, query):
    rows = get_query_plan(query)
    estimated_count = extract_analyze_count(rows)
    resource.is_estimate = True
    return estimated_count, resource.is_estimate


def get_query_plan(query):
    return models.db.session.execute(explain(query)).fetchall()


def extract_analyze_count(rows):
    for row in rows:
        match = count_pattern.search(row[0])
        if match:
            return int(match.groups()[0])


class explain(Executable, ClauseElement):
    inherit_cache = False

    def __init__(self, stmt, analyze=False):
        self.statement = stmt
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
