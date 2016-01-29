import sqlalchemy as sa
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices.utils import use_kwargs
from webservices.common import models
from webservices.common.models import (
    CandidateElection, CandidateCommitteeLink,
    ScheduleABySize, ScheduleAByState,
    db
)


election_duration = utils.get_election_duration(CandidateCommitteeLink.committee_type)

def candidate_aggregate(aggregate_model, label_columns, group_columns, kwargs):
    """Aggregate committee totals by candidate.

    :param aggregate_model: SQLAlchemy aggregate model
    :param list label_columns: List of label columns; must include group-by columns
    :param list group_columns: List of group-by columns
    :param dict kwargs: Parsed arguments from request
    """
    cycle_column = (
        CandidateElection.cand_election_year
        if kwargs.get('election_full')
        else CandidateCommitteeLink.fec_election_year
    ).label('cycle')

    rows = db.session.query(
        CandidateCommitteeLink.candidate_id,
        cycle_column,
    ).join(
        aggregate_model,
        sa.and_(
            CandidateCommitteeLink.committee_id == aggregate_model.committee_id,
            CandidateCommitteeLink.fec_election_year == aggregate_model.cycle,
        ),
    ).filter(
        (
            cycle_column.in_(kwargs['cycle'])
            if kwargs.get('cycle')
            else True
        ),
        CandidateCommitteeLink.candidate_id.in_(kwargs['candidate_id']),
        CandidateCommitteeLink.committee_designation.in_(['P', 'A']),
    )
    rows = join_elections(rows, kwargs)
    aggregates = rows.with_entities(
        CandidateCommitteeLink.candidate_id,
        cycle_column,
        *label_columns
    ).group_by(
        CandidateCommitteeLink.candidate_id,
        cycle_column,
        *group_columns
    )
    return rows, aggregates

def join_elections(query, kwargs):
    if not kwargs.get('election_full'):
        return query
    return query.join(
        CandidateElection,
        sa.and_(
            CandidateCommitteeLink.candidate_id == CandidateElection.candidate_id,
            CandidateCommitteeLink.fec_election_year <= CandidateElection.cand_election_year,
            CandidateCommitteeLink.fec_election_year > (CandidateElection.cand_election_year - election_duration),
        ),
    )

@doc(
    tags=['schedules/schedule_a'],
    description='Schedule A receipts aggregated by contribution size.',
)
class ScheduleABySizeCandidateView(utils.Resource):

    @use_kwargs(args.paging)
    @use_kwargs(args.make_sort_args())
    @use_kwargs(args.schedule_a_candidate_aggregate)
    @marshal_with(schemas.ScheduleABySizeCandidatePageSchema())
    def get(self, **kwargs):
        label_columns = [
            ScheduleABySize.size,
            sa.func.sum(ScheduleABySize.total).label('total'),
        ]
        group_columns = [ScheduleABySize.size]
        _, query = candidate_aggregate(ScheduleABySize, label_columns, group_columns, kwargs)
        return utils.fetch_page(query, kwargs, cap=None)


@doc(
    tags=['schedules/schedule_a'],
    description='Schedule A receipts aggregated by contributor state.',
)
class ScheduleAByStateCandidateView(utils.Resource):

    @use_kwargs(args.paging)
    @use_kwargs(args.make_sort_args())
    @use_kwargs(args.schedule_a_candidate_aggregate)
    @marshal_with(schemas.ScheduleAByStateCandidatePageSchema())
    def get(self, **kwargs):
        _, query = candidate_aggregate(
            ScheduleAByState,
            [
                ScheduleAByState.state,
                sa.func.sum(ScheduleAByState.total).label('total'),
                sa.func.max(ScheduleAByState.state_full).label('state_full'),
            ],
            [ScheduleAByState.state],
            kwargs,
        )
        return utils.fetch_page(query, kwargs, cap=0)


totals_model_map = {
    'P': models.CommitteeTotalsPresidential,
    'S': models.CommitteeTotalsHouseSenate,
    'H': models.CommitteeTotalsHouseSenate,
}

@doc(
    tags=['schedules/schedule_a'],
    description='Schedule A receipts aggregated by contributor state.',
)
class TotalsCandidateView(utils.Resource):

    @use_kwargs(args.paging)
    @use_kwargs(args.make_sort_args())
    @use_kwargs(args.totals_candidate_aggregate)
    @marshal_with(schemas.TotalsCandidatePageSchema())
    def get(self, candidate_id, **kwargs):
        totals_model = totals_model_map[candidate_id[0]]
        kwargs['candidate_id'] = [candidate_id]
        rows, aggregates = self._get_aggregates(kwargs, totals_model)
        latest = self._get_latest(rows, totals_model).subquery()
        aggregates = aggregates.subquery()
        query = db.session.query(
            aggregates,
            latest,
        ).join(
            latest,
            aggregates.c.cand_id == latest.c.cand_id,
        )
        return utils.fetch_page(query, kwargs)

    def _get_aggregates(self, kwargs, totals_model):
        return candidate_aggregate(
            totals_model,
            [
                sa.func.sum(totals_model.receipts).label('receipts'),
                sa.func.sum(totals_model.disbursements).label('disbursements'),
            ],
            [],
            kwargs,
        )

    def _get_latest(self, rows, totals_model):
        latest = rows.with_entities(
            CandidateCommitteeLink.candidate_id,
            CandidateCommitteeLink.committee_id,
            totals_model.last_cash_on_hand_end_period,
            totals_model.last_debts_owed_by_committee,
        ).distinct(
            CandidateCommitteeLink.candidate_id,
            CandidateCommitteeLink.committee_id,
        ).order_by(
            CandidateCommitteeLink.candidate_id,
            CandidateCommitteeLink.committee_id,
            sa.desc(CandidateCommitteeLink.fec_election_year)
        ).subquery()
        return db.session.query(
            latest.c.cand_id,
            sa.func.sum(latest.c.last_cash_on_hand_end_period).label('cash_on_hand_end_period'),
            sa.func.sum(latest.c.last_debts_owed_by_committee).label('debts_owed_by_committee'),
        ).group_by(
            latest.c.cand_id,
        )

class TotalsCandidateHistoryView(utils.Resource):

    def filter_multi_fields(self, model):
        return [
            ('party', model.party),
            ('state', model.state),
        ]

    def filter_range_fields(self, model):
        return [
            (('min_receipts', 'max_receipts'), model.receipts),
            (('min_disbursements', 'max_disbursements'), model.disbursements),
        ]

    @use_kwargs(args.paging)
    @use_kwargs(args.make_sort_args())
    @use_kwargs(args.totals_candidate_aggregate)
    @marshal_with(schemas.TotalsCandidatePageSchema())
    def get(self, office, cycle, **kwargs):
        query = self.build_query(office, cycle, **kwargs)
        return utils.fetch_page(query, kwargs)

    def build_query(self, office, cycle, **kwargs):
        if kwargs.get('election_full'):
            history = models.CandidateHistoryLatest
            totals = sa.Table('ofec_candidate_election_aggregate_mv', db.metadata, autoload_with=db.engine)
        else:
            history = models.CandidateHistory
            totals = sa.Table('ofec_candidate_aggregate_mv', db.metadata, autoload_with=db.engine)
        query = db.session.query(
            history.__table__,
            totals,
        ).join(
            totals,
            sa.and_(
                history.candidate_id == totals.c.cand_id,
                history.two_year_period == totals.c.cycle,
            )
        ).filter(
            history.office == office,
            history.two_year_period == cycle,
        )
        query = filters.filter_multi(query, kwargs, self.filter_multi_fields(history))
        query = filters.filter_range(query, kwargs, self.filter_range_fields(totals.c))
        return query
