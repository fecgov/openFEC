import sqlalchemy as sa
from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import paging
from webservices import schemas
from webservices.common.util import filter_query
from webservices.common.models import db, Candidate, CandidateDetail, CandidateHistory, CandidateCommitteeLink


filter_fields = {
    'candidate_id',
    'candidate_status',
    'district',
    'incumbent_challenge',
    'office',
    'party',
    'state',
}


@spec.doc(
    tags=['candidate'],
    description=docs.CANDIDATE_LIST,
)
class CandidateList(Resource):

    fulltext_query = '''
        SELECT cand_sk
        FROM   dimcand_fulltext_mv
        WHERE  fulltxt @@ to_tsquery(:findme)
        ORDER BY ts_rank_cd(fulltxt, to_tsquery(:findme)) desc
   '''

    @property
    def query(self):
        return Candidate.query

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.candidate_list)
    @args.register_kwargs(args.candidate_detail)
    @schemas.marshal_with(schemas.CandidateListPageSchema())
    def get(self, **kwargs):
        candidates = self.get_candidates(kwargs)
        paginator = paging.SqlalchemyPaginator(candidates, kwargs['per_page'])
        return paginator.get_page(kwargs['page'])

    def get_candidates(self, kwargs):

        candidates = self.query

        if kwargs.get('q'):
            findme = ' & '.join(kwargs['q'].split())
            candidates = candidates.filter(
                Candidate.candidate_key.in_(
                    db.session.query('cand_sk').from_statement(sa.text(self.fulltext_query)).params(findme=findme)
                )
            )

        candidates = filter_query(Candidate, candidates, filter_fields, kwargs)

        if kwargs.get('name'):
            candidates = candidates.filter(Candidate.name.ilike('%{}%'.format(kwargs['name'])))

        # TODO(jmcarp) Reintroduce year filter pending accurate `load_date` and `expire_date` values
        if kwargs['cycle']:
            candidates = candidates.filter(Candidate.cycles.overlap(kwargs['cycle']))

        return candidates.order_by(Candidate.name)


@spec.doc(
    tags=['candidate'],
    description=docs.CANDIDATE_SEARCH,
)
class CandidateSearch(CandidateList):

    @property
    def query(self):
        # Eagerly load principal committees to avoid extra queries
        return Candidate.query.options(
            sa.orm.subqueryload(Candidate.principal_committees)
        )

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.candidate_list)
    @args.register_kwargs(args.candidate_detail)
    @schemas.marshal_with(schemas.CandidateSearchPageSchema())
    def get(self, **kwargs):
        candidates = self.get_candidates(kwargs)
        paginator = paging.SqlalchemyPaginator(candidates, kwargs['per_page'])
        return paginator.get_page(kwargs['page'])


@spec.doc(
    tags=['candidate'],
    description=docs.CANDIDATE_DETAIL,
    path_params=[
        {'name': 'candidate_id', 'in': 'path', 'type': 'string'},
        {'name': 'committee_id', 'in': 'path', 'type': 'string'},
    ],
)
class CandidateView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.candidate_detail)
    @schemas.marshal_with(schemas.CandidateDetailPageSchema())
    def get(self, candidate_id=None, committee_id=None, **kwargs):
        candidates = self.get_candidate(kwargs, candidate_id, committee_id)
        paginator = paging.SqlalchemyPaginator(candidates, kwargs['per_page'])
        return paginator.get_page(kwargs['page'])

    def get_candidate(self, kwargs, candidate_id=None, committee_id=None):
        if candidate_id is not None:
            candidates = CandidateDetail.query
            candidates = candidates.filter_by(candidate_id=candidate_id)

        if committee_id is not None:
            candidates = CandidateDetail.query.join(
                CandidateCommitteeLink
            ).filter(
                CandidateCommitteeLink.committee_id == committee_id
            )

        candidates = filter_query(CandidateDetail, candidates, filter_fields, kwargs)

        # TODO(jmcarp) Reintroduce year filter pending accurate `load_date` and `expire_date` values
        if kwargs['cycle']:
            candidates = candidates.filter(CandidateDetail.cycles.overlap(kwargs['cycle']))

        return candidates.order_by(CandidateDetail.expire_date.desc())


class CandidateHistoryView(Resource):

    @args.register_kwargs(args.paging)
    @schemas.marshal_with(schemas.CandidateHistoryPageSchema())
    def get(self, candidate_id, year=None, **kwargs):
        candidates = self.get_candidate(candidate_id, year, kwargs)
        paginator = paging.SqlalchemyPaginator(candidates, kwargs['per_page'])
        return paginator.get_page(kwargs['page'])

    def get_candidate(self, candidate_id, year, kwargs):

        candidates = CandidateHistory.query
        candidates = candidates.filter_by(candidate_id=candidate_id)

        if year:
            if year == 'recent':
                return candidates.order_by(CandidateHistory.two_year_period.desc()).limit(1)
            year = int(year) + int(year) % 2
            candidates = candidates.filter_by(two_year_period=year)

        return candidates.order_by(CandidateHistory.two_year_period.desc())
