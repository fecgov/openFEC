import sqlalchemy as sa

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ItemizedResource


@spec.doc(
    tags=['schedules'],
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
        ('image_number', models.ScheduleA.image_number),
        ('committee_id', models.ScheduleA.committee_id),
        ('contributor_id', models.ScheduleA.contributor_id),
        ('contributor_city', models.ScheduleA.contributor_city),
        ('contributor_state', models.ScheduleA.contributor_state),
    ]
    filter_fulltext_fields = [
        ('contributor_name', models.ScheduleASearch.contributor_name_text),
        ('contributor_employer', models.ScheduleASearch.contributor_employer_text),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleA.contributor_receipt_date),
        (('min_amount', 'max_amount'), models.ScheduleA.contributor_receipt_amount),
        (('min_image_number', 'max_image_number'), models.ScheduleA.image_number),
    ]

    @args.register_kwargs(args.itemized)
    @args.register_kwargs(args.schedule_a)
    @args.register_kwargs(args.make_seek_args())
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.OptionValidator([
                'contributor_receipt_date',
                'contributor_receipt_amount',
                'contributor_aggregate_ytd',
            ]),
            multiple=False,
        )
    )
    @schemas.marshal_with(schemas.ScheduleAPageSchema())
    def get(self, **kwargs):
        return super(ScheduleAView, self).get(**kwargs)

    def build_query(self, kwargs):
        query = super(ScheduleAView, self).build_query(kwargs)
        query = query.options(sa.orm.joinedload(models.ScheduleA.committee))
        query = query.options(sa.orm.joinedload(models.ScheduleA.contributor))
        query = utils.filter_contributor_type(query, self.model.entity_type, kwargs)
        return query

    def join_fulltext(self, query):
        return query.join(
            models.ScheduleASearch,
            models.ScheduleA.sched_a_sk == models.ScheduleASearch.sched_a_sk,
        )
