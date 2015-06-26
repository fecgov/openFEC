from flask.ext.restful import Resource

from webservices import utils
from webservices.common import counts
from webservices.common import models
from webservices.config import SQL_CONFIG


class ItemizedResource(Resource):

    model = None
    year_column = None
    index_column = None
    amount_column = None
    filter_multi_fields = []
    filter_fulltext_fields = []

    def get(self, **kwargs):
        query = self.build_query(kwargs)
        count = counts.count_estimate(query, models.db.session)
        return utils.fetch_seek_page(query, kwargs, self.index_column, count=count)

    def build_query(self, kwargs):
        query = self.model.query.filter(
            self.year_column >= SQL_CONFIG['START_YEAR_ITEMIZED'],
        )

        query = self.filter_multi(query, kwargs)
        query = self.filter_cycle(query, kwargs)
        query = self.filter_fulltext(query, kwargs)
        query = self.filter_amount(query, kwargs)

        return query

    def filter_multi(self, query, kwargs):
        for key, column in self.filter_multi_fields:
            if kwargs[key]:
                query = query.filter(column.in_(kwargs[key]))
        return query

    def filter_cycle(self, query, kwargs):
        if kwargs['cycle']:
            cycles = sum(
                [[cycle - 1, cycle] for cycle in kwargs['cycle']],
                []
            )
            query = query.filter(self.year_column.in_(cycles))
        return query

    def filter_fulltext(self, query, kwargs):
        if any(kwargs[key] for key, column in self.filter_fulltext_fields):
            query = self.join_fulltext(query)
        for key, column in self.filter_fulltext_fields:
            if kwargs[key]:
                query = utils.search_text(query, column, kwargs[key], order=False)
        return query

    def filter_amount(self, query, kwargs):
        if kwargs['min_amount'] is not None:
            query = query.filter(self.amount_column >= kwargs['min_amount'])
        if kwargs['max_amount'] is not None:
            query = query.filter(self.amount_column <= kwargs['max_amount'])
        return query
