
from flask_apispec import Ref, marshal_with
from webservices import utils
from webservices import filters
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
    filter_overlap_fields = []
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
        is_estimate = counts.is_estimated_count(self, query)
        if not is_estimate:
            count = None
        else:
            count, _ = counts.get_count(self, query)
        multi = False
        if isinstance(kwargs['sort'], (list, tuple)):
            multi = True
        return utils.fetch_page(
            query, kwargs, models.db.session,
            count=count, model=self.model, join_columns=self.join_columns, aliases=self.aliases,
            index_column=self.index_column, cap=self.cap, multi=multi,
        )

    def build_query(self, *args, _apply_options=True, **kwargs):
        query = models.db.select(self.model)
        query = filters.filter_match(query, kwargs, self.filter_match_fields)
        query = filters.filter_multi(query, kwargs, self.filter_multi_fields)
        query = filters.filter_range(query, kwargs, self.filter_range_fields)
        query = filters.filter_fulltext(query, kwargs, self.filter_fulltext_fields)
        query = filters.filter_overlap(query, kwargs, self.filter_overlap_fields)
        if _apply_options:
            query = query.options(*self.query_options)
        return query


class ItemizedResource(ApiResource):

    year_column = None
    index_column = None
    filters_with_max_count = []
    max_count = 10
    secondary_index_options = []

    def get(self, **kwargs):
        """Get itemized resources.
        """
        self.validate_kwargs(kwargs)

        query = self.build_query(**kwargs)
        is_estimate = counts.is_estimated_count(self, query)
        if not is_estimate:
            count = None
        else:
            count, _ = counts.get_count(self, query)
        return utils.fetch_seek_page(query, kwargs, models.db.session, self.index_column, count=count, cap=self.cap)

    def validate_kwargs(self, kwargs):
        """Custom keyword argument validation

        - Secondary index
        - Pagination
        - Filters with max count

        """
        if self.secondary_index_options:
            two_year_transaction_periods = set(
                kwargs.get('two_year_transaction_period', [])
            )
            if len(two_year_transaction_periods) != 1:
                if not any(kwargs.get(field) for field in self.secondary_index_options):
                    raise exceptions.ApiError(
                        "Please choose a single `two_year_transaction_period` or "
                        "add one of the following filters to your query: `{}`".format(
                            "`, `".join(self.secondary_index_options)
                        ),
                        status_code=400,
                    )
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


class IndividualColumnResource(ApiResource):

    def get(self, *args, **kwargs):
        query = self.build_query(*args, **kwargs)
        is_estimate = counts.is_estimated_count(self, query)
        if not is_estimate:
            count = None
        else:
            count, _ = counts.get_count(self, query)
        multi = False
        if isinstance(kwargs['sort'], (list, tuple)):
            multi = True
        return utils.fetch_page(
            query,
            kwargs,
            models.db.session,
            count=count,
            model=self.model,
            join_columns=self.join_columns,
            aliases=self.aliases,
            index_column=self.index_column,
            cap=self.cap,
            multi=multi,
            contains_individual_columns=True
        )
