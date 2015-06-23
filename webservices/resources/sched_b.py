from webservices import args
from webservices import docs
from webservices import spec
from webservices import schemas
from webservices.common import models
from webservices.common.views import ItemizedResource


@spec.doc(
    tags=['filings'],
    description=docs.SCHEDULE_B,
)
class ScheduleBView(ItemizedResource):

    model = models.ScheduleB

    @property
    def year_column(self):
        return self.model.report_year
    @property
    def index_column(self):
        return self.model.sched_b_sk
    @property
    def amount_column(self):
        return self.model.disbursement_amount

    filter_multi_fields = [
        ('committee_id', models.ScheduleB.committee_id),
        ('recipient_city', models.ScheduleB.recipient_city),
        ('recipient_state', models.ScheduleB.recipient_state),
        ('recipient_committee_id', models.ScheduleB.recipient_committee_id),
    ]
    filter_fulltext_fields = [
        ('recipient_name', models.ScheduleASearch.contributor_name_text),
    ]

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
        return super(ScheduleBView, self).get(**kwargs)

    def join_fulltext(self, query):
        return query.join(
            models.ScheduleBSearch,
            models.ScheduleB.sched_b_sk == models.ScheduleBSearch.sched_b_sk,
        )
