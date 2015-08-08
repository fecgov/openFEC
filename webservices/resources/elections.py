import sqlalchemy as sa
from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices import exceptions
from webservices.common.models import (
    db, CandidateHistory, CommitteeHistory, CandidateCommitteeLink, Filings,
)


office_args_map = {
    'house': ['state', 'district'],
    'senate': ['state'],
}


@spec.doc(
    description=docs.ELECTION_SEARCH,
    tags=['financial']
)
class ElectionList(Resource):

    filter_multi_fields = [
        ('office', CandidateHistory.office),
        ('cycle', CandidateHistory.two_year_period),
    ]

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.election_search)
    @args.register_kwargs(args.make_sort_args(default=['-office']))
    @schemas.marshal_with(schemas.ElectionSearchPageSchema())
    def get(self, **kwargs):
        query = self._get_records(kwargs)
        return utils.fetch_page(query, kwargs)

    def _get_records(self, kwargs):
        """Get election records, sorted by status of office (P > S > H).
        """
        elections = self._get_elections(kwargs).subquery()
        return db.session.query(
            elections,
            sa.case(
                [
                    (elections.c.office == 'P', 1),
                    (elections.c.office == 'S', 2),
                    (elections.c.office == 'H', 3),
                ],
                else_=4,
            ).label('_office_status'),
        ).order_by(
            '_office_status',
        )

    def _get_elections(self, kwargs):
        """Get elections from candidate history records."""
        query = CandidateHistory.query.distinct(
            CandidateHistory.state,
            CandidateHistory.office,
            CandidateHistory.district,
            CandidateHistory.two_year_period,
        )
        if kwargs['state']:
            query = query.filter(CandidateHistory.state.in_(kwargs['state'] + ['US']))
        if kwargs['district']:
            query = query.filter(
                sa.or_(
                    CandidateHistory.district.in_(kwargs['district']),
                    CandidateHistory.district == None  # noqa
                ),
            )
        if kwargs['zip']:
            query = self._filter_zip(query, kwargs)
        return utils.filter_multi(query, kwargs, self.filter_multi_fields)

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


@spec.doc(
    description=docs.ELECTIONS,
    tags=['financial']
)
class ElectionView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.elections)
    @args.register_kwargs(args.make_sort_args(default=['-total_receipts']))
    @schemas.marshal_with(schemas.ElectionPageSchema())
    def get(self, **kwargs):
        query = self._get_records(kwargs)
        return utils.fetch_page(query, kwargs, cap=0)

    def _get_records(self, kwargs):
        required_args = office_args_map.get(kwargs['office'], [])
        for arg in required_args:
            if kwargs[arg] is None:
                raise exceptions.ApiError(
                    'Must include argument "{0}" with office type "{1}"'.format(
                        arg,
                        kwargs['office'],
                    ),
                    status_code=422,
                )
        pairs = self._get_pairs(kwargs).subquery()
        aggregates = self._get_aggregates(pairs).subquery()
        filings = self._get_filings(pairs).subquery()
        query = db.session.query(
            aggregates,
            filings,
        ).join(
            filings,
            aggregates.c.candidate_id == filings.c.candidate_id,
        )
        return query

    def _get_pairs(self, kwargs):
        pairs = CandidateHistory.query.with_entities(
            CandidateHistory.candidate_id,
            CandidateHistory.name,
            CandidateHistory.candidate_status_full,
            Filings.report_year,
            Filings.report_type_full,
            Filings.total_receipts,
            Filings.total_disbursements,
            Filings.cash_on_hand_end_period,
            Filings.beginning_image_number,
        ).distinct(
            CandidateHistory.candidate_key,
            CommitteeHistory.committee_key,
        ).join(
            CandidateCommitteeLink,
            CandidateHistory.candidate_key == CandidateCommitteeLink.candidate_key,
        ).join(
            CommitteeHistory,
            CandidateCommitteeLink.committee_key == CommitteeHistory.committee_key,
        ).join(
            Filings,
            CommitteeHistory.committee_id == Filings.committee_id,
        ).filter(
            CandidateHistory.two_year_period == kwargs['cycle'],
            CandidateHistory.office == kwargs['office'][0].upper(),
            CommitteeHistory.cycle == kwargs['cycle'],
            CommitteeHistory.designation.in_(['P', 'A']),
            Filings.form_type.in_(['F3', 'F3P']),
            Filings.report_type != 'TER',
            Filings.report_year.in_([kwargs['cycle'] - 1, kwargs['cycle']]),
        )
        if kwargs['state']:
            pairs = pairs.filter(CandidateHistory.state == kwargs['state'])
        if kwargs['district']:
            pairs = pairs.filter(CandidateHistory.district == kwargs['district'])
        pairs = pairs.order_by(
            CandidateHistory.candidate_key,
            CommitteeHistory.committee_key,
            sa.desc(Filings.coverage_end_date),
        )
        return pairs

    def _get_aggregates(self, pairs):
        return db.session.query(
            pairs.c.candidate_id,
            sa.func.max(pairs.c.name).label('candidate_name'),
            sa.func.max(pairs.c.candidate_status_full).label('candidate_status_full'),
            sa.func.sum(pairs.c.total_receipts).label('total_receipts'),
            sa.func.sum(pairs.c.total_disbursements).label('total_disbursements'),
            sa.func.sum(pairs.c.cash_on_hand_end_period).label('cash_on_hand_end_period'),
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
