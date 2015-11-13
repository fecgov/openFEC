import sqlalchemy as sa
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import utils
from webservices import schemas
from webservices.utils import use_kwargs
from webservices.common.models import (CandidateCommitteeLink, ScheduleABySize, ScheduleAByState, db)


election_duration = sa.case(
    [
        (CandidateCommitteeLink.committee_designation == 'S', 6),
        (CandidateCommitteeLink.committee_designation == 'P', 4),
    ],
    else_=2,
)

def candidate_aggregate(aggregate_model, label_columns, group_columns, kwargs):
    """Aggregate committee totals by candidate.

    :param aggregate_model: SQLAlchemy aggregate model
    :param list label_columns: List of label columns; must include group-by columns
    :param list group_columns: List of group-by columns
    :param dict kwargs: Parsed arguments from request
    """
    cand_valid = sa.Table('cand_valid_fec_yr', db.metadata, autoload_with=db.engine)

    elections = get_elections(cand_valid, kwargs).subquery()

    cycle_column = (
        elections.c.cand_election_yr
        if kwargs.get('period')
        else CandidateCommitteeLink.fec_election_year
    ).label('cycle')

    query = db.session.query(
        CandidateCommitteeLink.candidate_id,
        cycle_column,
        ScheduleABySize.size,
        sa.func.sum(aggregate_model.total).label('total'),
        *label_columns
    ).join(
        aggregate_model,
        sa.and_(
            CandidateCommitteeLink.committee_id == aggregate_model.committee_id,
            CandidateCommitteeLink.fec_election_year == aggregate_model.cycle,
        ),
    ).filter(
        cycle_column.in_(kwargs['cycle']),
        CandidateCommitteeLink.candidate_id.in_(kwargs['candidate_id']),
        CandidateCommitteeLink.committee_designation.in_(['P', 'A']),
    ).group_by(
        CandidateCommitteeLink.candidate_id,
        cycle_column,
        *group_columns
    )

    return join_elections(query, elections, kwargs)

def get_elections(cand_valid, kwargs):
    return db.session.query(
        cand_valid.c.cand_id,
        cand_valid.c.cand_election_yr,
    ).filter(
        cand_valid.c.cand_id.in_(kwargs['candidate_id']),
        cand_valid.c.cand_election_yr.in_(kwargs['cycle']),
    ).distinct()

def join_elections(query, elections, kwargs):
    if not kwargs.get('period'):
        return query
    return query.join(
        elections,
        sa.and_(
            CandidateCommitteeLink.candidate_id == elections.c.cand_id,
            CandidateCommitteeLink.fec_election_year <= elections.c.cand_election_yr,
            CandidateCommitteeLink.fec_election_year > (elections.c.cand_election_yr - election_duration),
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
