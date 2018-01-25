import sqlalchemy as sa

from flask_apispec import doc, marshal_with

from webservices import args
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices.utils import use_kwargs
from webservices.common.views import ApiResource
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
    tags=['receipts'],
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
    tags=['receipts'],
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

@doc(
    tags=['candidate'],
    description='Aggregated candidate receipts and disbursements grouped by cycle.',
)
class TotalsCandidateView(ApiResource):

    page_schema = schemas.CandidateHistoryTotalPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.candidate_totals,
            args.make_sort_args(),
        )

    def filter_multi_fields(self, history, total):
        return [
            ('candidate_id', history.candidate_id),
            ('election_year', total.election_year),
            ('cycle', total.cycle),
            ('office', history.office),
            ('party', history.party),
            ('state', history.state),
            ('district', history.district),
        ]

    def filter_range_fields(self, model):
        return [
            (('min_receipts', 'max_receipts'), model.receipts),
            (('min_disbursements', 'max_disbursements'), model.disbursements),
            (('min_cash_on_hand_end_period', 'max_cash_on_hand_end_period'), model.cash_on_hand_end_period),
            (('min_debts_owed_by_committee', 'max_debts_owed_by_committee'), model.debts_owed_by_committee),
        ]

    filter_fulltext_fields = [('q', models.CandidateSearch.fulltxt)]

    def build_query(self, **kwargs):
        if kwargs['election_full']:
            history = models.CandidateHistoryLatest
            year_column = history.candidate_election_year
        else:
            history = models.CandidateHistory
            year_column = history.two_year_period
        query = db.session.query(
            history.__table__,
            models.CandidateTotal.__table__,
            models.CandidateFlags.__table__
        ).join(
            models.CandidateTotal,
            sa.and_(
                history.candidate_id == models.CandidateTotal.candidate_id,
                year_column == models.CandidateTotal.cycle,
                history.candidate_election_year == models.CandidateTotal.cycle,
            )
        ).join(
            models.Candidate,
            history.candidate_id == models.Candidate.candidate_id,
        ).join(
            models.CandidateFlags,
            history.candidate_id == models.CandidateFlags.candidate_id,
        ).filter(
            models.CandidateTotal.is_election == kwargs['election_full'],
        )
        if kwargs.get('q'):
            query = query.join(
                models.CandidateSearch,
                history.candidate_id == models.CandidateSearch.id,
            )
        #The .filter methods may be able to moved to the filters methods, will investigate
        if kwargs.get('has_raised_funds'):
            query = query.filter(
                models.Candidate.flags.has(models.CandidateFlags.has_raised_funds == kwargs['has_raised_funds'])
            )
        if kwargs.get('federal_funds_flag'):
            query = query.filter(
                models.Candidate.flags.has(models.CandidateFlags.federal_funds_flag == kwargs['federal_funds_flag'])
            )
        query = filters.filter_multi(query, kwargs, self.filter_multi_fields(history, models.CandidateTotal))
        query = filters.filter_range(query, kwargs, self.filter_range_fields(models.CandidateTotal))
        query = filters.filter_fulltext(query, kwargs, self.filter_fulltext_fields)
        return query

