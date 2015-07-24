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
    description=docs.ELECTIONS,
    tags=['financial']
)
class ElectionView(Resource):

    @args.register_kwargs(args.elections)
    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.make_sort_args(default=['candidate_name']))
    @schemas.marshal_with(schemas.ElectionPageSchema())
    def get(self, **kwargs):
        query = self._get_records(kwargs)
        return utils.fetch_page(query, kwargs)

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
            Filings.form_type == 'F3',
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
