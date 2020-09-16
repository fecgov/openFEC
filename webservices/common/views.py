import sqlalchemy as sa

from flask_apispec import Ref, marshal_with
from webservices import utils
from webservices import filters
from webservices import sorting
from webservices import exceptions
from webservices.common import counts
from webservices.common import models
from webservices.utils import use_kwargs


class ApiResource(utils.Resource):

    args = {}
    model = None
    schema = None
    page_schema = None
    index_column = None
    unique_column = None
    filter_match_fields = []
    filter_multi_fields = []
    filter_range_fields = []
    filter_fulltext_fields = []
    query_options = []
    join_columns = {}
    aliases = {}
    cap = 100
    use_estimated_counts = True
    estimated_count_threshold = 500000
    use_pk_for_count = False

    @use_kwargs(Ref('args'))
    @marshal_with(Ref('page_schema'))
    def get(self, *args, **kwargs):
        query = self.build_query(*args, **kwargs)
        count, _ = counts.get_count(self, query)
        multi = False
        if isinstance(kwargs['sort'], (list, tuple)):
            multi = True

        return utils.fetch_page(
            query, kwargs,
            count=count, model=self.model, join_columns=self.join_columns, aliases=self.aliases,
            index_column=self.index_column, cap=self.cap, multi=multi,
        )

    def build_query(self, *args, _apply_options=True, **kwargs):
        query = self.model.query
        query = filters.filter_match(query, kwargs, self.filter_match_fields)
        query = filters.filter_multi(query, kwargs, self.filter_multi_fields)
        query = filters.filter_range(query, kwargs, self.filter_range_fields)
        query = filters.filter_fulltext(query, kwargs, self.filter_fulltext_fields)
        if _apply_options:
            query = query.options(*self.query_options)
        return query


class ItemizedResource(ApiResource):

    year_column = None
    index_column = None
    filters_with_max_count = []
    max_count = 10

    def get(self, **kwargs):
        """Get itemized resources. If multiple values are passed for `committee_id`,
        create a subquery for each and combine with `UNION ALL`. This is necessary
        to avoid slow queries when one or more relevant committees has many
        records.
        """
        if kwargs.get("last_index"):
            if all(
                kwargs.get("last_{}".format(option)) is None
                for option in self.sort_options
            ) and not kwargs.get("sort_null_only"):
                raise exceptions.ApiError(
                    "When paginating through results, both values from the \
                    previous page's `last_indexes` object are needed. For more information, \
                    see https://api.open.fec.gov/developers/. Please add one of the following \
                    filters to your query: `sort_null_only`=True, {}".format(
                        ", ".join("`last_" + option + "`" for option in self.sort_options)
                    ),
                    status_code=422,
                )
        over_limit_fields = [
            field
            for field in self.filters_with_max_count
            if len(kwargs.get(field, [])) > self.max_count
        ]
        if over_limit_fields:
            raise exceptions.ApiError(
                "Can only specify up to {0} values for `{1}`".format(
                    self.max_count, "`, `".join(over_limit_fields)
                ),
                status_code=422,
            )
        if len(kwargs.get("committee_id", [])) > 1:
            query, count = self.join_committee_queries(kwargs)
            return utils.fetch_seek_page(query, kwargs, self.index_column, count=count)
        query = self.build_query(**kwargs)
        count, _ = counts.get_count(self, query)
        return utils.fetch_seek_page(query, kwargs, self.index_column, count=count, cap=self.cap)

    def join_committee_queries(self, kwargs):
        """Build and compose per-committee subqueries using `UNION ALL`.
        """
        queries = []
        total = 0
        temp_kwargs = {}
        print("\nkwargs\n")
        print(kwargs)
        for committee_id in kwargs.get('committee_id', []):
            temp_kwargs['committee_id'] = [committee_id]
            for two_year_transaction_period in kwargs.get('two_year_transaction_period', []):
                temp_kwargs['two_year_transaction_period'] = [two_year_transaction_period]
                query, count = self.build_union_subquery(kwargs, temp_kwargs)
                queries.append(query.subquery().select())
                total += count
        query = models.db.session.query(
            self.model
        ).select_entity_from(
            sa.union_all(*queries)
        )
        query = query.options(*self.query_options)
        return query, total

    def build_union_subquery(self, kwargs, temp_kwargs):
        """Build a subquery by committee.
        """
        query = self.build_query(_apply_options=False, **utils.extend(kwargs, temp_kwargs))
        sort, hide_null = kwargs['sort'], kwargs['sort_hide_null']
        query, _ = sorting.sort(query, sort, model=self.model, hide_null=hide_null)
        page_query = utils.fetch_seek_page(query, kwargs, self.index_column, count=-1, eager=False).results
        count, _ = counts.get_count(self, query)
        return page_query, count
