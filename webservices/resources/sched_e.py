import sqlalchemy as sa
from flask_smore import doc, use_kwargs, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ItemizedResource


@doc(
    tags=['schedules/schedule_e'],
    description=docs.SCHEDULE_E,
)
class ScheduleEView(ItemizedResource):

    model = models.ScheduleE

    @property
    def year_column(self):
        return self.model.report_year
    @property
    def index_column(self):
        return self.model.sched_e_sk
    @property
    def amount_column(self):
        return self.model.expenditure_amount

    filter_multi_fields = [
        ('cycle', sa.func.get_cycle(models.ScheduleE.report_year)),
        ('image_number', models.ScheduleE.image_number),
        ('committee_id', models.ScheduleE.committee_id),
        ('candidate_id', models.ScheduleE.candidate_id),
    ]
    filter_fulltext_fields = [
        ('payee_name', models.ScheduleE.payee_name_text),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleE.expenditure_date),
        (('min_amount', 'max_amount'), models.ScheduleE.expenditure_amount),
        (('min_image_number', 'max_image_number'), models.ScheduleE.image_number),
    ]
    query_options = [
        sa.orm.joinedload(models.ScheduleE.candidate),
        sa.orm.joinedload(models.ScheduleE.committee),
    ]

    @use_kwargs(args.itemized)
    @use_kwargs(args.schedule_e)
    @use_kwargs(args.make_seek_args())
    @use_kwargs(
        args.make_sort_args(
            validator=args.OptionValidator([
                'expenditure_date',
                'expenditure_amount',
                'office_total_ytd',
            ]),
            multiple=False,
        )
    )
    @marshal_with(schemas.ScheduleEPageSchema())
    def get(self, **kwargs):
        return super(ScheduleEView, self).get(**kwargs)

    def filter_election(self, query, kwargs):
        if not kwargs['office']:
            return query
        utils.check_election_arguments(kwargs)
        query = query.join(
            models.CandidateHistory,
            models.ScheduleE.candidate_id == models.CandidateHistory.candidate_id,
        ).filter(
            models.CandidateHistory.two_year_period == kwargs['cycle'],
            models.CandidateHistory.office == kwargs['office'][0].upper(),
            models.ScheduleE.report_year.in_([kwargs['cycle'], kwargs['cycle'] - 1]),
        )
        if kwargs['state']:
            query = query.filter(models.CandidateHistory.state == kwargs['state'])
        if kwargs['district']:
            query = query.filter(models.CandidateHistory.district == kwargs['district'])
        return query
