import sqlalchemy as sa
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import utils
from webservices import schemas
from webservices.utils import use_kwargs
from webservices.common.models import (
    CandidateHistory, CommitteeHistory, CandidateCommitteeLink,
    ScheduleABySize, ScheduleAByState,
)


def candidate_aggregate(aggregate_model, label_columns, group_columns, kwargs):
    """Aggregate committee totals by candidate.

    :param aggregate_model: SQLAlchemy aggregate model
    :param list label_columns: List of label columns; must include group-by columns
    :param list group_columns: List of group-by columns
    :param dict kwargs: Parsed arguments from request
    """
    return CandidateHistory.query.with_entities(
        CandidateHistory.candidate_id,
        aggregate_model.cycle,
        sa.func.sum(aggregate_model.total).label('total'),
        *label_columns
    ).join(
        CandidateCommitteeLink,
        sa.and_(
            CandidateHistory.candidate_key == CandidateCommitteeLink.candidate_key,
            CandidateCommitteeLink.election_year.in_([
                CandidateHistory.two_year_period,
                CandidateHistory.two_year_period - 1,
            ]),
        )
    ).join(
        CommitteeHistory,
        sa.and_(
            CandidateCommitteeLink.committee_key == CommitteeHistory.committee_key,
            CandidateCommitteeLink.election_year.in_([
                CommitteeHistory.cycle,
                CommitteeHistory.cycle - 1,
            ]),
        )
    ).join(
        aggregate_model,
        sa.and_(
            CommitteeHistory.committee_id == aggregate_model.committee_id,
            CommitteeHistory.cycle == aggregate_model.cycle,
        )
    ).filter(
        CandidateHistory.candidate_id.in_(kwargs['candidate_id']),
        CommitteeHistory.designation.in_(['P', 'A']),
    ).group_by(
        CandidateHistory.candidate_id,
        aggregate_model.cycle,
        *group_columns
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
        group_columns = [ScheduleABySize.size]
        query = candidate_aggregate(ScheduleABySize, group_columns, group_columns, kwargs)
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
        query = candidate_aggregate(
            ScheduleAByState,
            [
                ScheduleAByState.state,
                sa.func.max(ScheduleAByState.state_full).label('state_full'),
            ],
            [ScheduleAByState.state],
            kwargs,
        )
        return utils.fetch_page(query, kwargs, cap=0)
