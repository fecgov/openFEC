import sqlalchemy as sa
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import filters
from webservices import schemas
from webservices.common import models
from webservices.utils import use_kwargs
from webservices.common.views import ItemizedResource


is_individual = sa.func.is_individual(
    models.ScheduleA.contribution_receipt_amount,
    models.ScheduleA.receipt_type,
    models.ScheduleA.line_number,
    models.ScheduleA.memo_code,
    models.ScheduleA.memo_text,
)


@doc(
    tags=['schedules/schedule_a'],
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
        return self.model.contribution_receipt_amount

    filter_multi_fields = [
        ('image_number', models.ScheduleA.image_number),
        ('committee_id', models.ScheduleA.committee_id),
        ('contributor_id', models.ScheduleA.contributor_id),
        ('contributor_city', models.ScheduleA.contributor_city),
        ('contributor_state', models.ScheduleA.contributor_state),
    ]
    filter_match_fields = [
        ('is_individual', is_individual),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleA.contribution_receipt_date),
        (('min_amount', 'max_amount'), models.ScheduleA.contribution_receipt_amount),
        (('min_image_number', 'max_image_number'), models.ScheduleA.image_number),
    ]
    filter_fulltext_fields = [
        ('contributor_name', models.ScheduleA.contributor_name_text),
        ('contributor_employer', models.ScheduleA.contributor_employer_text),
        ('contributor_occupation', models.ScheduleA.contributor_occupation_text),
    ]
    query_options = [
        sa.orm.joinedload(models.ScheduleA.committee),
        sa.orm.joinedload(models.ScheduleA.contributor),
    ]

    @use_kwargs(args.itemized)
    @use_kwargs(args.schedule_a)
    @use_kwargs(args.make_seek_args())
    @use_kwargs(
        args.make_sort_args(
            validator=args.OptionValidator([
                'contribution_receipt_date',
                'contribution_receipt_amount',
                'contributor_aggregate_ytd',
            ]),
            multiple=False,
        )
    )
    @marshal_with(schemas.ScheduleAPageSchema())
    def get(self, **kwargs):
        return super().get(**kwargs)

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        query = filters.filter_contributor_type(query, self.model.entity_type, kwargs)
        return query
