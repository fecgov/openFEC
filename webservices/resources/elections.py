import sqlalchemy as sa
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices.utils import use_kwargs
from webservices.common.models import (
    db, CandidateHistory, CommitteeHistory, CandidateCommitteeLink,
    CommitteeTotalsPresidential, CommitteeTotalsHouseSenate,
    ElectionResult, ScheduleEByCandidate,
)


office_totals_map = {
    'president': CommitteeTotalsPresidential,
    'senate': CommitteeTotalsHouseSenate,
    'house': CommitteeTotalsHouseSenate,
}
office_args_map = {
    'house': ['state', 'district'],
    'senate': ['state'],
}

def cycle_length(elections):
    return sa.case(
        [
            (elections.c.office == 'P', 4),
            (elections.c.office == 'S', 6),
            (elections.c.office == 'H', 2),
        ]
    )

@doc(
    description=docs.ELECTION_SEARCH,
    tags=['financial']
)
class ElectionList(utils.Resource):

    filter_multi_fields = [
        ('cycle', CandidateHistory.two_year_period),
    ]

    @use_kwargs(args.paging)
    @use_kwargs(args.election_search)
    @use_kwargs(args.make_sort_args(default=['-_office_status']))
    @marshal_with(schemas.ElectionSearchPageSchema())
    def get(self, **kwargs):
        query = self._get_records(kwargs)
        return utils.fetch_page(query, kwargs)

    def _get_records(self, kwargs):
        """Get election records, sorted by status of office (P > S > H).
        """
        elections = self._get_elections(kwargs).subquery()
        return db.session.query(
            elections,
            ElectionResult.cand_id,
            ElectionResult.cand_name,
            sa.case(
                [
                    (elections.c.office == 'P', 1),
                    (elections.c.office == 'S', 2),
                    (elections.c.office == 'H', 3),
                ],
                else_=4,
            ).label('_office_status'),
        ).outerjoin(
            ElectionResult,
            sa.and_(
                elections.c.state == ElectionResult.cand_office_st,
                elections.c.office == ElectionResult.cand_office,
                sa.func.coalesce(elections.c.district, '00') == ElectionResult.cand_office_district,
                elections.c.two_year_period == ElectionResult.election_yr + cycle_length(elections),
            ),
        ).order_by(
            '_office_status',
            ElectionResult.cand_office_district,
        )

    def _get_elections(self, kwargs):
        """Get elections from candidate history records."""
        query = CandidateHistory.query.distinct(
            CandidateHistory.state,
            CandidateHistory.office,
            CandidateHistory.district,
            CandidateHistory.two_year_period,
        ).filter(
            CandidateHistory.candidate_inactive == None,  # noqa
            # TODO(jmcarp) Revert after #1271 is resolved
            sa.or_(
                CandidateHistory.district == None,  # noqa
                CandidateHistory.district != '99',
            )
        )
        if kwargs.get('cycle'):
            query = query.filter(CandidateHistory.election_years.contains(kwargs['cycle']))
        if kwargs.get('office'):
            values = [each[0].upper() for each in kwargs['office']]
            query = query.filter(CandidateHistory.office.in_(values))
        if kwargs.get('state'):
            query = query.filter(CandidateHistory.state.in_(kwargs['state'] + ['US']))
        if kwargs.get('district'):
            query = query.filter(
                sa.or_(
                    CandidateHistory.district.in_(kwargs['district']),
                    CandidateHistory.district == None  # noqa
                ),
            )
        if kwargs.get('zip'):
            query = self._filter_zip(query, kwargs)
        return filters.filter_multi(query, kwargs, self.filter_multi_fields)

    def _filter_zip(self, query, kwargs):
        """Filter query by zip codes."""
        fips_states = sa.Table('ofec_fips_states', db.metadata, autoload_with=db.engine)
        zips_districts = sa.Table('ofec_zips_districts', db.metadata, autoload_with=db.engine)
        districts = db.session.query(
            zips_districts,
            fips_states,
        ).join(
            fips_states,
            zips_districts.c['State'] == fips_states.c['FIPS State Numeric Code'],
        ).filter(
            zips_districts.c['ZCTA'].in_(kwargs['zip'])
        ).subquery()
        return query.join(
            districts,
            sa.or_(
                # House races from matching states and districts
                sa.and_(
                    CandidateHistory.district_number == districts.c['Congressional District'],
                    CandidateHistory.state == districts.c['Official USPS Code'],
                ),
                # Senate and presidential races from matching states
                sa.and_(
                    CandidateHistory.district_number == None,  # noqa
                    CandidateHistory.state.in_([districts.c['Official USPS Code'], 'US'])
                ),
            )
        )


@doc(
    description=docs.ELECTIONS,
    tags=['financial']
)
class ElectionView(utils.Resource):

    @use_kwargs(args.paging)
    @use_kwargs(args.elections)
    @use_kwargs(args.make_sort_args(default=['-total_receipts'], default_nulls_large=False))
    @marshal_with(schemas.ElectionPageSchema())
    def get(self, **kwargs):
        query = self._get_records(kwargs)
        return utils.fetch_page(query, kwargs, cap=0)

    def _get_records(self, kwargs):
        utils.check_election_arguments(kwargs)
        totals_model = office_totals_map[kwargs['office']]
        pairs = self._get_pairs(totals_model, kwargs).subquery()
        aggregates = self._get_aggregates(pairs).subquery()
        filings = self._get_filings(pairs).subquery()
        outcomes = self._get_outcomes(kwargs).subquery()
        return db.session.query(
            aggregates,
            filings,
            sa.case(
                [(outcomes.c.cand_id != None, True)],  # noqa
                else_=False,
            ).label('won'),
        ).join(
            filings,
            aggregates.c.candidate_id == filings.c.candidate_id,
        ).outerjoin(
            outcomes,
            aggregates.c.candidate_id == outcomes.c.cand_id,
        )

    def _get_pairs(self, totals_model, kwargs):
        pairs = CandidateHistory.query.with_entities(
            CandidateHistory.candidate_id,
            CandidateHistory.name,
            CandidateHistory.party_full,
            CandidateHistory.incumbent_challenge_full,
            CandidateHistory.office,
            totals_model.committee_id,
            totals_model.receipts,
            totals_model.disbursements,
            totals_model.last_report_year.label('report_year'),
            totals_model.last_report_type_full.label('report_type_full'),
            totals_model.last_beginning_image_number.label('beginning_image_number'),
            totals_model.last_cash_on_hand_end_period.label('cash_on_hand_end_period'),
        ).distinct(
            CandidateHistory.candidate_key,
            CommitteeHistory.committee_key,
        )
        pairs = join_candidate_totals(pairs, kwargs, totals_model)
        pairs = filter_candidate_totals(pairs, kwargs, totals_model)
        return pairs.order_by(
            CandidateHistory.candidate_key,
            CommitteeHistory.committee_key,
            sa.desc(totals_model.coverage_end_date),
        )

    def _get_aggregates(self, pairs):
        return db.session.query(
            pairs.c.candidate_id,
            sa.func.max(pairs.c.name).label('candidate_name'),
            sa.func.max(pairs.c.party_full).label('party_full'),
            sa.func.max(pairs.c.incumbent_challenge_full).label('incumbent_challenge_full'),
            sa.func.max(pairs.c.office).label('office'),
            sa.func.sum(pairs.c.receipts).label('total_receipts'),
            sa.func.sum(pairs.c.disbursements).label('total_disbursements'),
            sa.func.sum(pairs.c.cash_on_hand_end_period).label('cash_on_hand_end_period'),
            sa.func.array_agg(pairs.c.committee_id).label('committee_ids'),
        ).group_by(
            pairs.c.candidate_id,
        )

    def _get_filings(self, pairs):
        return db.session.query(
            pairs.c.candidate_id,
            pairs.c.report_year,
            pairs.c.report_type_full,
            pairs.c.beginning_image_number,
        ).distinct(
            pairs.c.candidate_id,
        ).order_by(
            pairs.c.candidate_id,
            sa.desc(pairs.c.coverage_end_date),
        )

    def _get_outcomes(self, kwargs):
        return db.session.query(
            ElectionResult.cand_id
        ).filter(
            ElectionResult.election_yr == kwargs['cycle'],
            ElectionResult.cand_office == kwargs['office'][0].upper(),
            ElectionResult.cand_office_st == (kwargs.get('state', 'US')),
            ElectionResult.cand_office_district == (kwargs.get('district', '00')),
        )

@doc(
    description=docs.ELECTION_SEARCH,
    tags=['financial']
)
class ElectionSummary(utils.Resource):

    @use_kwargs(args.elections)
    @marshal_with(schemas.ElectionSummarySchema())
    def get(self, **kwargs):
        utils.check_election_arguments(kwargs)
        aggregates = self.get_aggregates(kwargs).subquery()
        expenditures = self.get_expenditures(kwargs).subquery()
        return db.session.query(
            aggregates.c.count,
            aggregates.c.receipts,
            aggregates.c.disbursements,
            expenditures.c.independent_expenditures,
        ).first()._asdict()

    def get_aggregates(self, kwargs):
        """Aggregate candidate count, receipts, and disbursements.

        Note: first create subquery on candidate total per period using
        DISTINCT ON candidate and committee IDs to avoid duplicate linkage
        records.
        """
        totals_model = office_totals_map[kwargs['office']]
        totals = db.session.query(CandidateHistory, totals_model)
        totals = join_candidate_totals(totals, kwargs, totals_model)
        totals = filter_candidate_totals(totals, kwargs, totals_model)
        totals = totals.distinct(CandidateHistory.candidate_id, CommitteeHistory.committee_id)
        totals = totals.subquery()
        return db.session.query(
            sa.func.count(sa.distinct(totals.c.candidate_id)).label('count'),
            sa.func.sum(totals.c.receipts).label('receipts'),
            sa.func.sum(totals.c.disbursements).label('disbursements'),
        )

    def get_expenditures(self, kwargs):
        expenditures = db.session.query(
            sa.func.sum(ScheduleEByCandidate.total).label('independent_expenditures'),
        ).select_from(
            CandidateHistory
        ).join(
            ScheduleEByCandidate,
            sa.and_(
                CandidateHistory.candidate_id == ScheduleEByCandidate.candidate_id,
                ScheduleEByCandidate.cycle == kwargs['cycle'],
            ),
        )
        expenditures = filter_candidates(expenditures, kwargs)
        return expenditures


def join_candidate_totals(query, kwargs, totals_model):
    return query.join(
        CandidateCommitteeLink,
        CandidateHistory.candidate_key == CandidateCommitteeLink.candidate_key,
    ).join(
        CommitteeHistory,
        CandidateCommitteeLink.committee_key == CommitteeHistory.committee_key,
    ).join(
        totals_model,
        CommitteeHistory.committee_id == totals_model.committee_id,
    )


def filter_candidates(query, kwargs):
    query = query.filter(
        CandidateHistory.two_year_period == kwargs['cycle'],
        CandidateHistory.election_years.any(kwargs['cycle']),
        CandidateHistory.office == kwargs['office'][0].upper(),
    )
    if kwargs.get('state'):
        query = query.filter(CandidateHistory.state == kwargs['state'])
    if kwargs.get('district'):
        query = query.filter(CandidateHistory.district == kwargs['district'])
    return query


def filter_candidate_totals(query, kwargs, totals_model):
    query = filter_candidates(query, kwargs)
    query = query.filter(
        CandidateHistory.candidate_inactive == None,  # noqa
        CandidateCommitteeLink.election_year.in_([kwargs['cycle'], kwargs['cycle'] - 1]),
        CommitteeHistory.cycle == kwargs['cycle'],
        CommitteeHistory.designation.in_(['P', 'A']),
        totals_model.cycle == kwargs['cycle'],
    )
    return query
