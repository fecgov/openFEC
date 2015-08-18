import sqlalchemy as sa

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ItemizedResource


@spec.doc(
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
        ('image_number', models.ScheduleE.image_number),
        ('committee_id', models.ScheduleE.committee_id),
        ('candidate_id', models.ScheduleE.candidate_id),
    ]
    filter_fulltext_fields = [
        ('payee_name', models.ScheduleESearch.payee_name_text),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleE.expenditure_date),
        (('min_amount', 'max_amount'), models.ScheduleE.expenditure_amount),
        (('min_image_number', 'max_image_number'), models.ScheduleE.image_number),
    ]

    @args.register_kwargs(args.itemized)
    @args.register_kwargs(args.schedule_e)
    @args.register_kwargs(args.make_seek_args())
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.OptionValidator([
                'expenditure_date',
                'expenditure_amount',
                'office_total_ytd',
            ]),
            multiple=False,
        )
    )
    @schemas.marshal_with(schemas.ScheduleEPageSchema())
    def get(self, **kwargs):
        return super(ScheduleEView, self).get(**kwargs)

    def build_query(self, kwargs):
        query = super(ScheduleEView, self).build_query(kwargs)
        query = query.options(sa.orm.joinedload(models.ScheduleE.committee))
        query = query.options(sa.orm.joinedload(models.ScheduleE.candidate))
        return query

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

    def join_fulltext(self, query):
        return query.join(
            models.ScheduleESearch,
            models.ScheduleE.sched_e_sk == models.ScheduleESearch.sched_e_sk,
        )
