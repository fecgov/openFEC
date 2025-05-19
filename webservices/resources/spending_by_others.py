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
    CommunicationCostByCandidate,
    db,
)


def get_candidate_list(kwargs):
    """
    This function is to get all candidates from candidate_history

    """
    candidate = (
        db.session.query(
            CandidateHistory.candidate_id.label('candidate_id'),
            CandidateHistory.two_year_period.label('two_year_period'),
            CandidateHistory.candidate_election_year.label('candidate_election_year'),
        )
        .filter(
            (
                CandidateHistory.candidate_id.in_(kwargs.get('candidate_id'))
                if kwargs.get('candidate_id')
                else True
            )
        )
        .distinct()
        .subquery()
    )

    cycle_column = (
        candidate.c.candidate_election_year + candidate.c.candidate_election_year % 2
        if kwargs.get('election_full')
        else candidate.c.two_year_period
    ).label('cycle')

    return cycle_column, candidate


# used for '/electioneering/totals/by_candidate/'
# under tag: electioneering
# Ex:http://127.0.0.1:5000/v1/electioneering/totals/by_candidate/?sort=-cycle&election_full=true
@doc(
    tags=['electioneering'], description=docs.ELECTIONEERING_TOTAL_BY_CANDIDATE,
)
class ECTotalsByCandidateView(ApiResource):

    schema = schemas.ECTotalsByCandidateSchema
    page_schema = schemas.ECTotalsByCandidatePageSchema
    sort_option = [
            'cycle',
            'candidate_id',
            'total',
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.totals_by_candidate_other_costs_EC,
            args.make_multi_sort_args(default=["-cycle", "candidate_id"], validator=args.SortMultiOptionValidator(
                self.sort_option),
            ),
        )

    def build_query(self, **kwargs):

        cycle_column, candidate = get_candidate_list(kwargs)

        query = (
            db.session.query(
                ElectioneeringByCandidate.candidate_id,
                cycle_column,
                sa.func.sum(ElectioneeringByCandidate.total).label('total'),
            )
            .join(
                ElectioneeringByCandidate,
                sa.and_(
                    ElectioneeringByCandidate.candidate_id == candidate.c.candidate_id,
                    ElectioneeringByCandidate.cycle == candidate.c.two_year_period,
                ),
            )
            .filter(
                (cycle_column.in_(kwargs['cycle']) if kwargs.get('cycle') else True)
            )
            .group_by(ElectioneeringByCandidate.candidate_id, cycle_column,)
        )

        return query


# used for '/schedules/schedule_e/totals/by_candidate/'
# under tag: independent expenditures
# Ex: http://127.0.0.1:5000/v1/schedules/schedule_e/totals/by_candidate/?sort=-cycle&sort=candidate_id
# &election_full=true
@doc(
    tags=['independent expenditures'],
    description=docs.SCHEDULE_E_INDEPENDENT_EXPENDITURES_TOTALS_BY_CANDIDATE,
)
class IETotalsByCandidateView(ApiResource):

    schema = schemas.IETotalsByCandidateSchema
    page_schema = schemas.IETotalsByCandidatePageSchema

    sort_option = [
            'cycle',
            'candidate_id',
            'total',
            'support_oppose_indicator',
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_e_totals_by_candidate_other_costs_IE,
            args.make_multi_sort_args(default=["-cycle", "candidate_id"], validator=args.SortMultiOptionValidator(
                self.sort_option),
            ),
        )

    def build_query(self, **kwargs):
        cycle_column, candidate = get_candidate_list(kwargs)

        query = (
            db.session.query(
                ScheduleEByCandidate.candidate_id,
                ScheduleEByCandidate.support_oppose_indicator,
                cycle_column,
                sa.func.sum(ScheduleEByCandidate.total).label('total'),
            )
            .join(
                ScheduleEByCandidate,
                sa.and_(
                    ScheduleEByCandidate.candidate_id == candidate.c.candidate_id,
                    ScheduleEByCandidate.cycle == candidate.c.two_year_period,
                ),
            )
            .filter(
                (cycle_column.in_(kwargs['cycle']) if kwargs.get('cycle') else True)
            )
            .group_by(
                ScheduleEByCandidate.candidate_id,
                cycle_column,
                ScheduleEByCandidate.support_oppose_indicator,
            )

        )

        return query


# used for '/communication_costs/totals/by_candidate/'
# under tag: communication cost
# Ex: http://127.0.0.1:5000/v1/communication_costs/totals/by_candidate/?sort=-cycle&sort=candidate_id
# &election_full=true
@doc(
    tags=['communication cost'],
    description=docs.COMMUNICATIONS_COSTS_TOTALS_BY_CANDIDATE,
)
class CCTotalsByCandidateView(ApiResource):

    schema = schemas.CCTotalsByCandidateSchema
    page_schema = schemas.CCTotalsByCandidatePageSchema

    sort_option = [
            'cycle',
            'candidate_id',
            'total',
            'support_oppose_indicator',
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.totals_by_candidate_other_costs_CC,
            args.make_multi_sort_args(default=["-cycle", "candidate_id"], validator=args.SortMultiOptionValidator(
                self.sort_option),
            ),
        )

    def build_query(self, **kwargs):
        cycle_column, candidate = get_candidate_list(kwargs)

        query = (
            db.session.query(
                CommunicationCostByCandidate.candidate_id,
                CommunicationCostByCandidate.support_oppose_indicator,
                cycle_column,
                sa.func.sum(CommunicationCostByCandidate.total).label('total'),
            )
            .join(
                CommunicationCostByCandidate,
                sa.and_(
                    CommunicationCostByCandidate.candidate_id
                    == candidate.c.candidate_id,
                    CommunicationCostByCandidate.cycle == candidate.c.two_year_period,
                ),
            )
            .filter(
                (cycle_column.in_(kwargs['cycle']) if kwargs.get('cycle') else True)
            )
            .group_by(
                CommunicationCostByCandidate.candidate_id,
                cycle_column,
                CommunicationCostByCandidate.support_oppose_indicator,
            )

        )

        return query
