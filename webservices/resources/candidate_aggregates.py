import sqlalchemy as sa

from flask_apispec import doc, marshal_with

from webservices import args
from webservices import utils
from webservices import docs
from webservices import filters
from webservices import schemas
from webservices.utils import use_kwargs
from webservices.common.views import ApiResource
from webservices.common import models
from webservices.common.models import (
    CandidateCommitteeLink,
    ScheduleABySize,
    ScheduleAByState,
    db,
)


def candidate_aggregate(aggregate_model, label_columns, group_columns, kwargs):
    """
    This fix is for doubled totals caused by linkage_mv #3816

    Use linkage.election_yr_to_be_included instead of ofec_candidate_election_mv for election_full=true

    When election_full=true, aggregate is calculated on election_yr_to_be_included
    When election_full=false, aggregate is calculated on fec_election_yr

    As long as the linkage.election_yr_to_be_included is correct for PR, the aggregate data will be correct too
    election year covers more than one fec_election_year
    Aggregated data are calculated per fec_cycle only, no odd year

    """
    rows = (
        db.session.query(
            CandidateCommitteeLink.candidate_id.label('candidate_id'),
            CandidateCommitteeLink.committee_id.label('committee_id'),
            CandidateCommitteeLink.fec_election_year.label('fec_election_year'),
            CandidateCommitteeLink.election_yr_to_be_included.label(
                'election_yr_to_be_included'
            ),
        )
        .filter(
            (
                CandidateCommitteeLink.fec_election_year.in_(kwargs['cycle'])
                if not kwargs.get('election_full')
                else CandidateCommitteeLink.election_yr_to_be_included.in_(
                    kwargs['cycle']
                )
            ),
            CandidateCommitteeLink.candidate_id.in_(kwargs['candidate_id']),
            CandidateCommitteeLink.committee_designation.in_(['P', 'A']),
        )
        .distinct()
        .subquery()
    )

    cycle_column = (
        rows.c.election_yr_to_be_included
        if kwargs.get('election_full')
        else rows.c.fec_election_year
    ).label('cycle')

    aggregates = (
        db.session.query(rows.c.candidate_id, cycle_column, *label_columns)
        .join(
            aggregate_model,
            sa.and_(
                rows.c.committee_id == aggregate_model.committee_id,
                rows.c.fec_election_year == aggregate_model.cycle,
            ),
        )
        .group_by(rows.c.candidate_id, cycle_column, *group_columns)
    )
    return rows, aggregates


@doc(
    tags=['receipts'], description=docs.SCHEDULE_A_SIZE_CANDIDATE_TAG,
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
            sa.func.sum(ScheduleABySize.count).label('count'),
        ]
        group_columns = [ScheduleABySize.size]

        _, query = candidate_aggregate(
            ScheduleABySize, label_columns, group_columns, kwargs
        )
        return utils.fetch_page(query, kwargs, cap=None)


@doc(
    tags=['receipts'], description=docs.SCHEDULE_A_STATE_CANDIDATE_TOTAL_TAG,
)
class ScheduleAByStateCandidateTotalsView(utils.Resource):
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
                ScheduleAByState.count,
            ],
            [ScheduleAByState.state, ScheduleAByState.count],
            kwargs,
        )
        q = query.subquery()
        query = db.session.query(
            sa.func.sum(q.c.total).label('total'),
            sa.func.sum(q.c.count).label('count'),
            q.c.candidate_id.label('candidate_id'),
            q.c.cycle,
        ).group_by(q.c.candidate_id, q.c.cycle)

        return utils.fetch_page(query, kwargs, cap=0)


@doc(
    tags=['receipts'], description=docs.SCHEDULE_A_STATE_CANDIDATE_TAG,
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
                sa.func.sum(ScheduleAByState.count).label('count'),
            ],
            [ScheduleAByState.state],
            kwargs,
        )
        return utils.fetch_page(query, kwargs, cap=0)


@doc(
    tags=['candidate'], description=docs.TOTAL_CANDIDATE_TAG,
)
class TotalsCandidateView(ApiResource):

    schema = schemas.CandidateHistoryTotalSchema
    page_schema = schemas.CandidateHistoryTotalPageSchema

    @property
    def args(self):
        return utils.extend(args.paging, args.candidate_totals, args.make_sort_args(),)

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
            (
                ('min_cash_on_hand_end_period', 'max_cash_on_hand_end_period'),
                model.cash_on_hand_end_period,
            ),
            (
                ('min_debts_owed_by_committee', 'max_debts_owed_by_committee'),
                model.debts_owed_by_committee,
            ),
        ]

    filter_fulltext_fields = [('q', models.CandidateSearch.fulltxt)]

    filter_match_fields = [
        ('has_raised_funds', models.CandidateTotal.has_raised_funds),
        ('federal_funds_flag', models.CandidateTotal.federal_funds_flag),
        ('election_full', models.CandidateTotal.is_election),
    ]

    def build_query(self, **kwargs):
        history = models.CandidateHistoryWithFuture
        query = (
            db.session.query(history.__table__, models.CandidateTotal.__table__)
            .join(
                models.CandidateTotal,
                sa.and_(
                    history.candidate_id == models.CandidateTotal.candidate_id,
                    history.two_year_period == models.CandidateTotal.cycle,
                ),
            )
            .join(
                models.Candidate, history.candidate_id == models.Candidate.candidate_id,
            )
        )
        if kwargs.get('q'):
            query = query.join(
                models.CandidateSearch,
                history.candidate_id == models.CandidateSearch.id,
            )

        if 'is_active_candidate' in kwargs and kwargs.get(
            'is_active_candidate'
        ):  # load active candidates only if True
            query = query.filter(history.candidate_inactive == False)  # noqa
        elif 'is_active_candidate' in kwargs and not kwargs.get(
            'is_active_candidate'
        ):  # load inactive candidates only if False
            query = query.filter(history.candidate_inactive == True)  # noqa
        else:  # load all candidates
            pass

        query = filters.filter_multi(
            query, kwargs, self.filter_multi_fields(history, models.CandidateTotal)
        )
        query = filters.filter_range(
            query, kwargs, self.filter_range_fields(models.CandidateTotal)
        )
        query = filters.filter_fulltext(query, kwargs, self.filter_fulltext_fields)
        query = filters.filter_match(query, kwargs, self.filter_match_fields)
        return query


@doc(
    tags=['candidate'], description=docs.TOTAL_BY_OFFICE_TAG,
)
class AggregateByOfficeView(ApiResource):

    schema = schemas.TotalByOfficeSchema
    page_schema = schemas.TotalByOfficePageSchema

    @property
    def args(self):
        return utils.extend(args.paging, args.totals_by_office, args.make_sort_args(),)

    def build_query(self, **kwargs):
        history = models.CandidateHistoryWithFuture
        total = models.CandidateTotal
        # check to see if candidate is marked as inactive in history
        check_cand_status = (
            db.session.query(history)
            .filter(
                history.candidate_id == total.candidate_id,
                history.candidate_election_year == total.election_year,
                history.candidate_inactive.is_(True),
            )
            .exists()
        )

        query = db.session.query(
            sa.func.substr(total.candidate_id, 1, 1).label('office'),
            total.election_year.label('election_year'),
            sa.func.sum(total.receipts).label('total_receipts'),
            sa.func.sum(total.disbursements).label('total_disbursements'),
        ).filter(
            total.is_election == True  # noqa
        )

        if kwargs.get('office') and kwargs['office'] is not None:
            query = query.filter(
                sa.func.substr(total.candidate_id, 1, 1) == kwargs['office']
            )
        if kwargs.get('election_year'):
            query = query.filter(total.election_year.in_(kwargs['election_year']))

        if 'is_active_candidate' in kwargs and kwargs.get('is_active_candidate'):
            query = query.filter(~check_cand_status)
        elif 'is_active_candidate' in kwargs and not kwargs.get('is_active_candidate'):
            query = query.filter(check_cand_status)
        else:  # load all candidates
            pass

        query = query.group_by(
            sa.func.substr(total.candidate_id, 1, 1), total.election_year
        )
        return query


@doc(
    tags=['candidate'], description=docs.TOTAL_BY_OFFICE_BY_PARTY_TAG,
)
class AggregateByOfficeByPartyView(ApiResource):

    schema = schemas.TotalByOfficeByPartySchema
    page_schema = schemas.TotalByOfficeByPartyPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging, args.totals_by_office_by_party, args.make_sort_args(),
        )

    def build_query(self, **kwargs):
        total = models.CandidateTotal

        query = db.session.query(
            total.office.label('office'),
            # total.party.label('party'),
            sa.case(
                [
                    (total.party == 'DFL', 'DEM'),
                    (total.party == 'DEM', 'DEM'),
                    (total.party == 'REP', 'REP'),
                ],
                else_='Other',
            ).label('party'),
            total.election_year.label('election_year'),
            sa.func.sum(total.receipts).label('total_receipts'),
            sa.func.sum(total.disbursements).label('total_disbursements'),
        ).filter(
            total.is_election == True  # noqa
        )

        if kwargs.get('office') and kwargs['office'] is not None:
            query = query.filter(total.office == kwargs['office'])
        if kwargs.get('election_year'):
            query = query.filter(total.election_year.in_(kwargs['election_year']))

        if 'is_active_candidate' in kwargs and kwargs.get('is_active_candidate'):
            query = query.filter(total.candidate_inactive == 'False')
        elif 'is_active_candidate' in kwargs and not kwargs.get('is_active_candidate'):
            query = query.filter(total.candidate_inactive == 'True')
        else:  # load all candidates
            pass

        query = query.group_by(
            total.office,
            sa.case(
                [
                    (total.party == 'DFL', 'DEM'),
                    (total.party == 'DEM', 'DEM'),
                    (total.party == 'REP', 'REP'),
                ],
                else_='Other',
            ),
            total.election_year,
        )

        return query
