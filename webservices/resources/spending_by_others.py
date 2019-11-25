import sqlalchemy as sa
from flask_apispec import doc
from webservices import args
from webservices import utils
from webservices import docs
from webservices import schemas
from webservices.common.views import ApiResource
from webservices.common.models import (
    CandidateHistory,
    ElectioneeringByCandidate,
    ScheduleEByCandidate,
    db,
)

def get_candidate_list(kwargs):
    """
    This function is to get all candidates from candidate_history

    """
    candidate = db.session.query(
        CandidateHistory.candidate_id.label('candidate_id'),
        CandidateHistory.two_year_period.label('two_year_period'),
        CandidateHistory.candidate_election_year.label('candidate_election_year'),
    ).filter(
        (
            CandidateHistory.candidate_id.in_(kwargs.get('candidate_id'))
            if kwargs.get('candidate_id')
            else True
        )
    ).distinct().subquery()

    cycle_column = (
        candidate.c.candidate_election_year + candidate.c.candidate_election_year % 2
        if kwargs.get('election_full')
        else candidate.c.two_year_period
    ).label('cycle')

    return cycle_column, candidate

@doc(
    tags=['electioneering'],
    description=docs.ELECTIONEERING_TOTAL_BY_CANDIDATE,
)
class ECTotalsByCandidateView(ApiResource):

    schema = schemas.ECTotalsByCandidateSchema
    page_schema = schemas.ECTotalsByCandidatePageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_e_totals_by_candidate_other_costs_EC,
            args.make_sort_args(),
        )

    def build_query(self, **kwargs):

        cycle_column, candidate = get_candidate_list(kwargs)

        query = db.session.query(
            ElectioneeringByCandidate.candidate_id,
            cycle_column,
            sa.func.sum(ElectioneeringByCandidate.total).label('total')
        ).join(
            ElectioneeringByCandidate,
            sa.and_(
                ElectioneeringByCandidate.candidate_id == candidate.c.candidate_id,
                ElectioneeringByCandidate.cycle == candidate.c.two_year_period
            )
        ).filter(
            (
                cycle_column.in_(kwargs['cycle'])
                if kwargs.get('cycle')
                else True
            )
        ).group_by(ElectioneeringByCandidate.candidate_id, cycle_column,)

        return query



    
@doc(
    tags=['independent expenditures'],
    description=docs.SCHEDULE_E_INDEPENDENT_EXPENDITURES_TOTALS_BY_CANDIDATE,
)
class IETotalsByCandidateView(ApiResource):

    schema = schemas.IETotalsByCandidateSchema
    page_schema = schemas.IETotalsByCandidatePageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_e_totals_by_candidate_other_costs_IE_and_CC,
            args.make_sort_args(),
        )

    def build_query(self, **kwargs):
        cycle_column, candidate = get_candidate_list(kwargs)

        query = db.session.query(
            ScheduleEByCandidate.candidate_id,
            ScheduleEByCandidate.support_oppose_indicator,
            cycle_column,
            sa.func.sum(ScheduleEByCandidate.total).label('total'),
        ).join(
            ScheduleEByCandidate,
            sa.and_(
                ScheduleEByCandidate.candidate_id == candidate.c.candidate_id,
                ScheduleEByCandidate.cycle == candidate.c.two_year_period
            )
        ).filter(
            (
                cycle_column.in_(kwargs['cycle'])
                if kwargs.get('cycle')
                else True
            )
        ).group_by(
            ScheduleEByCandidate.candidate_id, cycle_column, ScheduleEByCandidate.support_oppose_indicator,
        ).order_by(ScheduleEByCandidate.candidate_id, cycle_column, ScheduleEByCandidate.support_oppose_indicator,)

        return query


@doc(
    tags=['communication cost'],
    description=docs.SCHEDULE_E_COMMUNICATIONS_COSTS_TOTALS_BY_CANDIDATE,
)
class CCTotalsByCandidateView(ApiResource):

    schema = schemas.CCTotalsByCandidateSchema
    page_schema = schemas.CCTotalsByCandidatePageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_e_totals_by_candidate_other_costs_IE_and_CC,
            args.make_sort_args(),
        )

    def build_query(self, **kwargs):
        cycle_column, candidate = get_candidate_list(kwargs)

        query = db.session.query(
            ScheduleEByCandidate.candidate_id,
            ScheduleEByCandidate.support_oppose_indicator,
            cycle_column,
            sa.func.sum(ScheduleEByCandidate.total).label('total'),
        ).join(
            ScheduleEByCandidate,
            sa.and_(
                ScheduleEByCandidate.candidate_id == candidate.c.candidate_id,
                ScheduleEByCandidate.cycle == candidate.c.two_year_period
            )
        ).filter(
            (
                cycle_column.in_(kwargs['cycle'])
                if kwargs.get('cycle')
                else True
            )
        ).group_by(
            ScheduleEByCandidate.candidate_id, cycle_column, ScheduleEByCandidate.support_oppose_indicator,
        ).order_by(ScheduleEByCandidate.candidate_id, cycle_column, ScheduleEByCandidate.support_oppose_indicator,)

        return query
