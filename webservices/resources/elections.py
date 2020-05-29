import sqlalchemy as sa
from sqlalchemy import cast, Integer
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices.common import counts
from webservices.utils import use_kwargs
from webservices.common import models
from webservices.common.views import ApiResource
from webservices.common.models import (
    db,
    CandidateHistory,
    CandidateCommitteeLink,
    CommitteeTotalsHouseSenate,
    ElectionsList,
    ZipsDistricts,
    ScheduleEByCandidate,
    BaseConcreteCommittee,
    CommitteeTotalsCombined,
)


office_totals_map = {
    'president': CommitteeTotalsCombined,
    'senate': CommitteeTotalsHouseSenate,
    'house': CommitteeTotalsHouseSenate,
}
office_args_map = {
    'house': ['state', 'district'],
    'senate': ['state'],
}
election_durations = {
    'senate': 6,
    'president': 4,
    'house': 2,
}


def get_cycle_duration(kwargs):
    if kwargs.get('election_full'):
        if kwargs.get('state', '').upper() == 'PR':
            # PR house commissioners have 4-year cycles
            return 4
        return election_durations.get(kwargs['office'], 2)
    return 2


@doc(description=docs.ELECTION_SEARCH, tags=['financial'])
class ElectionsListView(utils.Resource):

    model = ElectionsList
    schema = schemas.ElectionsListSchema
    page_schema = schemas.ElectionsListPageSchema

    filter_multi_fields = [
        ('cycle', ElectionsList.cycle),
    ]

    @use_kwargs(args.paging)
    @use_kwargs(args.elections_list)
    @use_kwargs(args.make_multi_sort_args(default=['sort_order', 'district', ]))
    @marshal_with(schemas.ElectionsListPageSchema())
    def get(self, **kwargs):
        query = self._get_elections(kwargs)
        return utils.fetch_page(query, kwargs, model=ElectionsList, multi=True)

    def _get_elections(self, kwargs):
        """Get elections from ElectionsList model."""
        query = db.session.query(ElectionsList)
        if kwargs.get('office'):
            values = [each[0].upper() for each in kwargs['office']]
            query = query.filter(ElectionsList.office.in_(values))
        if kwargs.get('state'):
            query = query.filter(
                sa.or_(
                    ElectionsList.state.in_(kwargs['state']),
                    ElectionsList.office == 'P',
                )
            )
        if kwargs.get('district'):
            query = query.filter(
                sa.or_(
                    ElectionsList.district.in_(kwargs['district']),
                    ElectionsList.office.in_(['P', 'S']),
                ),
            )
        if kwargs.get('zip'):
            query = self._filter_zip(query, kwargs)

        return filters.filter_multi(query, kwargs, self.filter_multi_fields)

    def _filter_zip(self, query, kwargs):
        """Filter query by zip codes."""
        districts = (
            db.session.query(ZipsDistricts)
            .filter(
                cast(ZipsDistricts.zip_code, Integer).in_(kwargs['zip']),
                ZipsDistricts.active == 'Y',
            )
            .subquery()
        )
        return query.join(
            districts,
            sa.or_(
                # House races from matching states and districts
                sa.and_(
                    ElectionsList.district == districts.c['district'],
                    ElectionsList.state == districts.c['state_abbrevation'],
                ),
                # Senate and presidential races from matching states
                sa.and_(
                    sa.or_(ElectionsList.district == '00'),
                    ElectionsList.state.in_([districts.c['state_abbrevation'], 'US']),
                ),
            ),
        )


@doc(description=docs.ELECTIONS, tags=['financial'])
class ElectionView(ApiResource):
    schema = schemas.ElectionSchema
    page_schema = schemas.ElectionPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.elections,
            args.make_sort_args(default='-total_receipts',),
        )

    def get(self, *args, **kwargs):
        query = self.build_query(*args, **kwargs)
        count, _ = counts.get_count(query, models.db.session, self.model)
        multi = False
        if isinstance(kwargs['sort'], (list, tuple)):
            multi = True

        return utils.fetch_page(
            query,
            kwargs,
            count=count,
            model=self.model,
            join_columns=self.join_columns,
            aliases=self.aliases,
            index_column=self.index_column,
            cap=0,
            multi=multi,
        )

    def build_query(self, **kwargs):
        utils.check_election_arguments(kwargs)
        totals_model = office_totals_map[kwargs['office']]
        basicPairs = self._get_basicPairs(totals_model, kwargs).subquery()
        pairs = self._get_pairs(basicPairs).subquery()
        aggregates = self._get_aggregates(pairs).subquery()
        candAggregates = self._get_candAggregates(aggregates).subquery()

        final_query = (
            db.session.query(
                candAggregates, BaseConcreteCommittee.name.label('candidate_pcc_name')
            )
            .outerjoin(
                BaseConcreteCommittee,
                candAggregates.c.candidate_pcc_id == BaseConcreteCommittee.committee_id,
            )
            .distinct()
        )
        return final_query

    def _get_basicPairs(self, totals_model, kwargs):
        # get basic data for election totals
        basicPairs = CandidateHistory.query.with_entities(
            CandidateHistory.candidate_id,
            CandidateHistory.name,
            CandidateHistory.party_full,
            CandidateHistory.incumbent_challenge_full,
            CandidateHistory.office,
            CandidateHistory.two_year_period,
            # CandidateHistory.candidate_election_year,
            CandidateCommitteeLink.election_yr_to_be_included.label(
                'candidate_election_year'
            ),
            CandidateCommitteeLink.committee_id.label('committee_id'),
            totals_model.receipts.label('receipts'),
            totals_model.disbursements.label('disbursements'),
            totals_model.last_cash_on_hand_end_period.label(
                'last_cash_on_hand_end_period'
            ),
            totals_model.coverage_end_date,
            sa.case(
                [
                    (
                        CandidateCommitteeLink.committee_designation == 'P',
                        CandidateCommitteeLink.committee_id,
                    )
                ]  # noqa
            ).label('candidate_pcc_id'),
        ).filter(CandidateCommitteeLink.committee_designation.in_(['P', 'A']))
        basicPairs = join_candidate_totals(basicPairs, kwargs, totals_model)
        basicPairs = filter_candidate_totals(basicPairs, kwargs)

        return basicPairs

    def _get_pairs(self, basicPairs):
        """
        get cash_on_hand_end_period info from the latest financial report
        per candidate_id/candidate_election_year/cmte_id

        When newlest financial report not filed yet, the financial data columns will be
        null, take the data from the previous filing for calculation.

        However, when the latest fincial report filed, but COH is null (the null will be
        converted to 0 in final calculation) should be used.
        """

        # Window params
        window_p = {
            'partition_by': [
                basicPairs.c.candidate_id,
                basicPairs.c.candidate_election_year,
                basicPairs.c.committee_id,
            ],
            'order_by': [
                sa.case(
                    [
                        (
                            basicPairs.c.coverage_end_date.isnot(None),
                            basicPairs.c.two_year_period,
                        )
                    ]
                )
                .desc()
                .nullslast()
            ],
        }

        pairs = db.session.query(
            basicPairs.c.candidate_id,
            basicPairs.c.name,
            basicPairs.c.party_full,
            basicPairs.c.incumbent_challenge_full,
            basicPairs.c.office,
            basicPairs.c.two_year_period,
            basicPairs.c.candidate_election_year,
            basicPairs.c.committee_id,
            basicPairs.c.receipts.label('receipts'),
            basicPairs.c.disbursements.label('disbursements'),
            sa.func.first_value(basicPairs.c.last_cash_on_hand_end_period)
            .over(**window_p)
            .label('last_cash_on_hand_end_period'),
            sa.func.first_value(basicPairs.c.coverage_end_date)
            .over(**window_p)
            .label('coverage_end_date'),
            basicPairs.c.candidate_pcc_id,
        )
        return pairs

    def _get_aggregates(self, pairs):
        # sum up values per candidate_id/candidate_election_year/cmte_id
        aggregates = db.session.query(
            pairs.c.candidate_id,
            pairs.c.candidate_election_year,
            pairs.c.committee_id,
            sa.func.max(pairs.c.name).label('candidate_name'),
            sa.func.max(pairs.c.party_full).label('party_full'),
            sa.func.max(pairs.c.incumbent_challenge_full).label(
                'incumbent_challenge_full'
            ),
            sa.func.max(pairs.c.office).label('office'),
            sa.func.sum(sa.func.coalesce(pairs.c.receipts, 0.0)).label('receipts'),
            sa.func.sum(sa.func.coalesce(pairs.c.disbursements, 0.0)).label(
                'disbursements'
            ),
            sa.func.max(
                sa.func.coalesce(pairs.c.last_cash_on_hand_end_period, 0.0)
            ).label('last_cash_on_hand_end_period'),
            sa.func.max(pairs.c.coverage_end_date).label('coverage_end_date'),
            sa.func.max(pairs.c.candidate_pcc_id).label('candidate_pcc_id'),
        ).group_by(
            pairs.c.candidate_id, pairs.c.candidate_election_year, pairs.c.committee_id
        )
        return aggregates

    def _get_candAggregates(self, aggregates):
        # sum up values per candidate_id/candidate_election_year
        candAggregates = db.session.query(
            aggregates.c.candidate_id,
            aggregates.c.candidate_election_year,
            sa.func.max(aggregates.c.candidate_name).label('candidate_name'),
            sa.func.max(aggregates.c.party_full).label('party_full'),
            sa.func.max(aggregates.c.incumbent_challenge_full).label(
                'incumbent_challenge_full'
            ),
            sa.func.max(aggregates.c.office).label('office'),
            sa.func.sum(sa.func.coalesce(aggregates.c.receipts, 0.0)).label(
                'total_receipts'
            ),
            sa.func.sum(sa.func.coalesce(aggregates.c.disbursements, 0.0)).label(
                'total_disbursements'
            ),
            sa.func.sum(
                sa.func.coalesce(aggregates.c.last_cash_on_hand_end_period, 0.0)
            ).label('cash_on_hand_end_period'),
            sa.func.array_agg(sa.distinct(aggregates.c.committee_id)).label(
                'committee_ids'
            ),
            sa.func.max(aggregates.c.coverage_end_date).label('coverage_end_date'),
            sa.func.max(aggregates.c.candidate_pcc_id).label('candidate_pcc_id'),
        ).group_by(aggregates.c.candidate_id, aggregates.c.candidate_election_year)
        return candAggregates


@doc(description=docs.ELECTION_SEARCH, tags=['financial'])
class ElectionSummary(utils.Resource):
    @use_kwargs(args.elections)
    @marshal_with(schemas.ElectionSummarySchema())
    def get(self, **kwargs):
        utils.check_election_arguments(kwargs)
        aggregates = self._get_aggregates(kwargs).subquery()
        expenditures = self._get_expenditures(kwargs).subquery()
        return (
            db.session.query(
                aggregates.c.count,
                aggregates.c.receipts,
                aggregates.c.disbursements,
                expenditures.c.independent_expenditures,
            )
            .first()
            ._asdict()
        )

    def _get_aggregates(self, kwargs):
        totals_model = office_totals_map[kwargs['office']]
        aggregates = CandidateHistory.query.with_entities(
            sa.func.count(sa.distinct(CandidateHistory.candidate_id)).label('count'),
            sa.func.sum(totals_model.receipts).label('receipts'),
            sa.func.sum(totals_model.disbursements).label('disbursements'),
        )
        aggregates = join_candidate_totals(aggregates, kwargs, totals_model)
        aggregates = filter_candidate_totals(aggregates, kwargs)
        return aggregates

    def _get_expenditures(self, kwargs):
        expenditures = (
            db.session.query(
                sa.func.sum(ScheduleEByCandidate.total).label(
                    'independent_expenditures'
                ),
            )
            .select_from(CandidateHistory)
            .join(
                ScheduleEByCandidate,
                sa.and_(
                    CandidateHistory.candidate_id == ScheduleEByCandidate.candidate_id,
                    ScheduleEByCandidate.cycle == kwargs['cycle'],
                ),
            )
        )
        expenditures = filter_candidate_totals(expenditures, kwargs)
        return expenditures


def join_candidate_totals(query, kwargs, totals_model):
    """
    Joint Fundraising Committees raise money for multiple
    candidate committees and transfer that money to those committees.
    By limiting the committee designations to A and P
    you eliminate J (joint) and thus do not inflate
    the candidate's money by including it twice and
    by including money that was raised and transferred
    to the other committees in the joint fundraiser.
    """
    return query.outerjoin(
        CandidateCommitteeLink,
        sa.and_(
            CandidateHistory.candidate_id == CandidateCommitteeLink.candidate_id,
            CandidateHistory.two_year_period
            == CandidateCommitteeLink.fec_election_year,
        ),
    ).outerjoin(
        totals_model,
        sa.and_(
            CandidateCommitteeLink.committee_id == totals_model.committee_id,
            CandidateCommitteeLink.fec_election_year == totals_model.cycle,
            CandidateCommitteeLink.committee_designation.in_(['P', 'A']),
        ),
    )


def filter_candidate_totals(query, kwargs):
    duration = get_cycle_duration(kwargs)
    query = query.filter(
        CandidateHistory.two_year_period <= kwargs['cycle'],
        CandidateHistory.two_year_period > (kwargs['cycle'] - duration),
        CandidateCommitteeLink.election_yr_to_be_included == kwargs['cycle'],
        CandidateHistory.office == kwargs['office'][0].upper(),
    )
    if kwargs.get('state'):
        query = query.filter(CandidateHistory.state == kwargs['state'])
    if kwargs.get('district'):
        query = query.filter(CandidateHistory.district == kwargs['district'])

    query = query.filter(
        CandidateHistory.candidate_inactive == False,  # noqa
        # CandidateCommitteeLink.committee_designation.in_(['P', 'A']),
    ).distinct()
    return query


@doc(
    tags=['filer resources'], description=docs.STATE_ELECTION_OFFICES,
)
class StateElectionOfficeInfoView(ApiResource):
    model = models.StateElectionOfficeInfo
    schema = schemas.StateElectionOfficeInfoSchema
    page_schema = schemas.StateElectionOfficeInfoPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging, args.state_election_office_info, args.make_sort_args(),
        )

    @property
    def index_column(self):
        return self.model.state

    filter_match_fields = [
        ('state', models.StateElectionOfficeInfo.state),
    ]
