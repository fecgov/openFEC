from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import counts
from webservices.common import models


filter_multi_fields = [
    ('committee_id', models.ScheduleA.committee_id),
    ('contributor_id', models.ScheduleA.contributor_id),
]
fulltext_fields = [
    ('contributor_name', models.ScheduleASearch.contributor_name_text),
    ('contributor_employer', models.ScheduleASearch.contributor_employer_text),
]


@spec.doc(
    tags=['filings'],
    description=docs.SCHEDULE_A,
)
class ScheduleAView(Resource):

    @args.register_kwargs(args.schedule_a)
    @args.register_kwargs(args.make_seek_args())
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.OptionValidator(['report_year', 'contributor_receipt_amount']),
            multiple=False,
        )
    )
    @schemas.marshal_with(schemas.ScheduleAPageSchema())
    def get(self, **kwargs):
        query = self.build_query(kwargs)
        count = counts.count_estimate(query, models.db.session)
        return utils.fetch_seek_page(query, kwargs, models.ScheduleA.sched_a_sk, count=count)

    def build_query(self, kwargs):
        query = models.ScheduleA.query

        query = utils.filter_multi(query, filter_multi_fields, kwargs)

        if any(kwargs[key] for key, column in fulltext_fields):
            query = query.join(
                models.ScheduleA,
                models.ScheduleA.sched_a_sk == models.ScheduleASearch.sched_a_sk,
            )
        for key, column in fulltext_fields:
            if kwargs[key]:
                query = utils.search_text(query, column, kwargs[key])

        return query
