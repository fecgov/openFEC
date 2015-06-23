from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import counts
from webservices.common import models
from webservices.config import SQL_CONFIG


filter_multi_fields = [
    ('committee_id', models.ScheduleB.committee_id),
    ('recipient_city', models.ScheduleB.recipient_city),
    ('recipient_state', models.ScheduleB.recipient_state),
    ('recipient_committee_id', models.ScheduleB.recipient_committee_id),
]
fulltext_fields = [
    ('recipient_name', models.ScheduleASearch.contributor_name_text),
]


@spec.doc(
    tags=['filings'],
    description=docs.SCHEDULE_B,
)
class ScheduleBView(Resource):

    @args.register_kwargs(args.schedule_b)
    @args.register_kwargs(args.make_seek_args())
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.OptionValidator(['report_year', 'disbursement_amount']),
            multiple=False,
        )
    )
    @schemas.marshal_with(schemas.ScheduleBPageSchema())
    def get(self, **kwargs):
        query = self.build_query(kwargs)
        count = counts.count_estimate(query, models.db.session)
        return utils.fetch_seek_page(query, kwargs, models.ScheduleB.sched_a_sk, count=count)

    def build_query(self, kwargs):
        query = models.ScheduleB.query.filter(
            models.ScheduleB.report_year >= SQL_CONFIG['START_YEAR_ITEMIZED'],
        )

        query = utils.filter_multi(query, filter_multi_fields, kwargs)

        if any(kwargs[key] for key, column in fulltext_fields):
            query = query.join(
                models.ScheduleASearch,
                models.ScheduleA.sched_a_sk == models.ScheduleASearch.sched_a_sk,
            )
        for key, column in fulltext_fields:
            if kwargs[key]:
                query = utils.search_text(query, column, kwargs[key])

        return query
