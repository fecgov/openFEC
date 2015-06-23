from webservices import args
from webservices import docs
from webservices import spec
from webservices import schemas
from webservices.common import models
from webservices.common.views import ItemizedResource


@spec.doc(
    tags=['filings'],
    description=docs.SCHEDULE_A,
)
class ScheduleAView(ItemizedResource):

    model = models.ScheduleA

    @property
    def year_column(self):
        return self.model.report_year
    @property
    def index_column(self):
        return self.model.sched_a_sk
    @property
    def amount_column(self):
        return self.model.contributor_receipt_amount

    filter_multi_fields = [
        ('committee_id', models.ScheduleA.committee_id),
        ('contributor_id', models.ScheduleA.contributor_id),
        ('contributor_city', models.ScheduleA.contributor_city),
        ('contributor_state', models.ScheduleA.contributor_state),
    ]
    filter_fulltext_fields = [
        ('contributor_name', models.ScheduleASearch.contributor_name_text),
        ('contributor_employer', models.ScheduleASearch.contributor_employer_text),
    ]

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
        return super(ScheduleAView, self).get(**kwargs)

    def join_fulltext(self, query):
        return query.join(
            models.ScheduleASearch,
            models.ScheduleA.sched_a_sk == models.ScheduleASearch.sched_a_sk,
        )
