import sqlalchemy as sa
import copy

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
    union_all_fields = ["committee_id"]
    ALL_YEARS = range(1976, utils.get_current_cycle() + 2, 2)

    def get(self, **kwargs):
        """Get itemized resources. If multiple values are passed for `committee_id`
        or `two_year_transaction_period` create a subquery for each and combine
        with `UNION ALL`. This is necessary to avoid slow queries when
        one or more relevant committees has many records.
        """
        self.validate_kwargs(kwargs)

        # Add all 2-year transaction periods where not specified
        if ("two_year_transaction_period" in self.union_all_fields
            and not kwargs.get("two_year_transaction_period")
        ):
            kwargs["two_year_transaction_period"] = self.ALL_YEARS

        # Only use UNION ALL for 2-15 or all two_year_periods
        use_two_year_union = (
            2 <= len(kwargs.get("two_year_transaction_period", [])) <= 15
            or kwargs.get("two_year_transaction_period") == self.ALL_YEARS
        )

        # Generate traditional "IN" query and counts for all
        query = self.build_query(**kwargs)
        count, _ = counts.get_count(self, query)

        # Generate "UNION ALL" subqueries for multiple committee ID's and 2-year periods
        if len(kwargs.get("committee_id", [])) > 1:
            query = self.join_committee_queries(kwargs, use_two_year_union)
        # Generate subqueries for only multiple 2-year periods
        elif use_two_year_union:
            query = self.join_year_queries(kwargs)

        return utils.fetch_seek_page(
            query, kwargs, self.index_column, count=count, cap=self.cap
        )

    def validate_kwargs(self, kwargs):
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

    def join_committee_queries(self, kwargs, use_two_year_union=False):
        """Build and compose per-field subqueries using `UNION ALL`.
        """
        queries = []
        temp_kwargs = {}
        for argument in kwargs.get("committee_id", []):
            temp_kwargs["committee_id"] = [argument]
            if use_two_year_union:
                query = self.join_year_queries(utils.extend(kwargs, temp_kwargs))
            else:
                query = self.build_union_subquery(kwargs, temp_kwargs)
            queries.append(query.subquery().select())
        query = models.db.session.query(
            self.model
        ).select_entity_from(
            sa.union_all(*queries)
        )
        query = query.options(*self.query_options)
        return query

    def join_year_queries(self, kwargs):
        """Build and compose per-field subqueries using `UNION ALL`.
        If all years, break up two_year_transaction period into 10-year ranges
        starting in 2020
        """
        queries = []
        temp_kwargs = {}
        # Use decade range for all years
        if kwargs["two_year_transaction_period"] == self.ALL_YEARS:
            range_column = self.model.two_year_transaction_period
            temp_kwargs = copy.deepcopy(kwargs)
            # Don't filter with IN because we're constructing with UNION
            del temp_kwargs["two_year_transaction_period"]
            # Break into 10-year ranges starting in 2000
            for min_year, max_year in utils.get_decade_range(2000, utils.get_current_cycle()):
                query = self.build_union_range_subquery(temp_kwargs, range_column, min_year, max_year)
                queries.append(query.subquery().select())
        else:
            for argument in kwargs.get("two_year_transaction_period", []):
                temp_kwargs["two_year_transaction_period"] = [argument]
                query = self.build_union_subquery(kwargs, temp_kwargs)
                queries.append(query.subquery().select())
        query = models.db.session.query(
            self.model
        ).select_entity_from(
            sa.union_all(*queries)
        )
        query = query.options(*self.query_options)
        return query

    def build_union_subquery(self, kwargs, temp_kwargs):
        """Build a subquery by specified arguments.
        """
        query = self.build_query(_apply_options=False, **utils.extend(kwargs, temp_kwargs))
        page_query = utils.fetch_seek_page(query, kwargs, self.index_column, count=-1, eager=False).results
        return page_query

    def build_union_range_subquery(self, kwargs, column, min_value=None, max_value=None):
        """Build a subquery by ranges
        """
        query = self.build_query(_apply_options=False, **kwargs)
        if min_value:
            query = query.filter(column > min_value)
        if max_value:
            query = query.filter(column <= max_value)

        page_query = utils.fetch_seek_page(query, kwargs, self.index_column, count=-1, eager=False).results
        return page_query
