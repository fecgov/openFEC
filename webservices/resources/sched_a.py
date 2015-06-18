import sqlalchemy as sa
from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models


filter_multi_fields = [
    ('committee_id', models.ScheduleA.committee_id),
    ('contributor_id', models.ScheduleA.contributor_id),
]
fulltext_fields = [
    ('contributor_name', models.ScheduleASearch.contributor_name_text),
    ('contributor_employer', models.ScheduleASearch.contributor_employer_text),
    ('contributor_occupation', models.ScheduleASearch.contributor_occupation_text),
]


class ScheduleAView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.schedule_a)
    @schemas.marshal_with(schemas.ScheduleASchema())
    def get(self, **kwargs):
        query = self.buid_query(kwargs)
        return utils.fetch_page(query, kwargs, model=models.ScheduleA)

    def build_query(self, kwargs):
        query = models.ScheduleA.query

        query = utils.filter_multi(query, filter_multi_fields, kwargs)

        if any(kwargs[key] for key in fulltext_fields):
            query = query.join(
                models.ScheduleA,
                models.ScheduleA.sched_a_sk == models.ScheduleASearch.sched_a_sk,
            )
        for key, column in fulltext_fields:
            if kwargs[key]:
                query = utils.search_text(query, column, kwargs[key])

        return query
