import sqlalchemy as sa
from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices import exceptions
from webservices.common.models import (
    CandidateHistory, CommitteeHistory, CandidateCommitteeLink, Filings,
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
    @args.register_kwargs(args.make_sort_args(default=['name']))
    @schemas.marshal_with(schemas.ElectionPageSchema())
    def get(self, **kwargs):
        query = self._get_records(kwargs)
        return utils.fetch_page(query, kwargs, model=CandidateHistory)

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
        query = CandidateHistory.query.with_entities(
            CandidateHistory,
            Filings,
        ).distinct(
            CandidateHistory.candidate_key,
        ).join(
            CandidateCommitteeLink,
            CandidateHistory.candidate_id == CandidateCommitteeLink.candidate_id,
        ).join(
            CommitteeHistory,
            CandidateCommitteeLink.committee_id == CommitteeHistory.committee_id,
        ).join(
            Filings,
            CommitteeHistory.committee_id == Filings.committee_id,
        ).filter(
            CandidateHistory.two_year_period == kwargs['cycle'],
            CommitteeHistory.cycle == kwargs['cycle'],
            CommitteeHistory.designation == 'P',
            Filings.form_type == 'F3',
            Filings.report_type != 'TER',
            Filings.report_year.in_([kwargs['cycle'] - 1, kwargs['cycle']]),
        )
        if kwargs['state']:
            query = query.filter(CandidateHistory.state == kwargs['state'])
        if kwargs['district']:
            query = query.filter(CandidateHistory.district == kwargs['district'])
        query = query.order_by(
            CandidateHistory.candidate_key,
            sa.desc(Filings.coverage_end_date),
        )
        return query
