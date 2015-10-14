import sqlalchemy as sa

from webservices import utils
from webservices import filters
from webservices import sorting
from webservices import exceptions
from webservices.common import counts
from webservices.common import models


class ApiResource(utils.Resource):

    model = None
    filter_match_fields = []
    filter_multi_fields = []
    filter_range_fields = []
    query_options = []
    join_columns = {}

    def get(self, **kwargs):
        query = self.build_query(**kwargs)
        return utils.fetch_page(query, kwargs, model=self.model, join_columns=self.join_columns)

    def build_query(self, _apply_options=True, **kwargs):
        query = self.model.query
        query = filters.filter_match(query, kwargs, self.filter_match_fields)
        query = filters.filter_multi(query, kwargs, self.filter_multi_fields)
        query = filters.filter_range(query, kwargs, self.filter_range_fields)
        if _apply_options:
            query = query.options(*self.query_options)
        return query


class ItemizedResource(ApiResource):

    year_column = None
    index_column = None
    filter_fulltext_fields = []

    def get(self, **kwargs):
        """Get itemized resources. If multiple values are passed for `committee_id`,
        create a subquery for each and combine with `UNION ALL`. This is necessary
        to avoid slow queries when one or more relevant committees has many
        records.
        """
        committee_ids = kwargs.get('committee_id', [])
        if len(committee_ids) > 5:
            raise exceptions.ApiError(
                'Can only specify up to five values for "committee_id".',
                status_code=422,
            )
        if len(committee_ids) > 1:
            query, count = self.join_committee_queries(kwargs)
            return utils.fetch_seek_page(query, kwargs, self.index_column, count=count)
        query = self.build_query(**kwargs)
        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return utils.fetch_seek_page(query, kwargs, self.index_column, count=count)

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        query = self.filter_fulltext(query, kwargs)
        return query

    def join_committee_queries(self, kwargs):
        """Build and compose per-committee subqueries using `UNION ALL`.
        """
        queries = []
        total = 0
        for committee_id in kwargs.get('committee_id', []):
            query, count = self.build_committee_query(kwargs, committee_id)
            queries.append(query.subquery().select())
            total += count
        query = models.db.session.query(
            self.model
        ).select_entity_from(
            sa.union_all(*queries)
        )
        query = query.options(*self.query_options)
        return query, total

    def build_committee_query(self, kwargs, committee_id):
        """Build a subquery by committee.
        """
        query = self.build_query(_apply_options=False, **utils.extend(kwargs, {'committee_id': [committee_id]}))
        sort, hide_null, nulls_large = kwargs['sort'], kwargs['sort_hide_null'], kwargs['sort_nulls_large']
        query, _ = sorting.sort(query, sort, model=self.model, hide_null=hide_null, nulls_large=nulls_large)
        page_query = utils.fetch_seek_page(query, kwargs, self.index_column, count=-1, eager=False).results
        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return page_query, count

    def filter_fulltext(self, query, kwargs):
        for key, column in self.filter_fulltext_fields:
            if kwargs.get(key):
                query = utils.search_text(query, column, kwargs[key], order=False)
        return query
