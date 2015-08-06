import sqlalchemy as sa
from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices import exceptions
from webservices.common.models import (
    db, CandidateHistory, CommitteeHistory, CandidateCommitteeLink,
    CommitteeTotalsPresidential, CommitteeTotalsHouseSenate,
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


@spec.doc(
    description=docs.ELECTIONS,
    tags=['financial']
)
class ElectionView(Resource):

    @args.register_kwargs(args.elections)
    @args.register_kwargs(args.paging)
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
        totals_model = office_totals_map[kwargs['office']]
        pairs = self._get_pairs(totals_model, kwargs).subquery()
        aggregates = self._get_aggregates(pairs).subquery()
        filings = self._get_filings(pairs).subquery()
        return db.session.query(
            aggregates,
            filings,
        ).join(
            filings,
            aggregates.c.candidate_id == filings.c.candidate_id,
        )

    def _get_pairs(self, totals_model, kwargs):
        pairs = CandidateHistory.query.with_entities(
            CandidateHistory.candidate_id,
            CandidateHistory.name,
            CandidateHistory.party_full,
            CandidateHistory.incumbent_challenge_full,
            CandidateHistory.office,
            totals_model.receipts,
            totals_model.disbursements,
            totals_model.last_report_year.label('report_year'),
            totals_model.last_report_type_full.label('report_type_full'),
            totals_model.last_beginning_image_number.label('beginning_image_number'),
            totals_model.last_cash_on_hand_end_period.label('cash_on_hand_end_period'),
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
            totals_model,
            CommitteeHistory.committee_id == totals_model.committee_id,
        ).filter(
            CandidateHistory.two_year_period == kwargs['cycle'],
            CandidateHistory.office == kwargs['office'][0].upper(),
            CandidateCommitteeLink.election_year.in_([kwargs['cycle'], kwargs['cycle'] - 1]),
            CommitteeHistory.cycle == kwargs['cycle'],
            CommitteeHistory.designation.in_(['P', 'A']),
            totals_model.cycle == kwargs['cycle'],
        )
        if kwargs['state']:
            pairs = pairs.filter(CandidateHistory.state == kwargs['state'])
        if kwargs['district']:
            pairs = pairs.filter(CandidateHistory.district == kwargs['district'])
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
