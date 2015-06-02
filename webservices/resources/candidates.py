import sqlalchemy as sa
from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
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
        FROM   ofec_candidate_fulltext_mv
        WHERE  fulltxt @@ to_tsquery(:findme || ':*')
        ORDER BY ts_rank_cd(fulltxt, to_tsquery(:findme || ':*')) desc
   '''

    @property
    def query(self):
        return Candidate.query

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.candidate_list)
    @args.register_kwargs(args.candidate_detail)
    @args.register_kwargs(args.make_sort_args(default=['name']))
    @schemas.marshal_with(schemas.CandidatePageSchema())
    def get(self, **kwargs):
        query = self.get_candidates(kwargs)
        return utils.fetch_page(query, kwargs, model=Candidate)

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

        return candidates


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
    @args.register_kwargs(args.make_sort_args())
    @schemas.marshal_with(schemas.CandidateSearchPageSchema())
    def get(self, **kwargs):
        query = self.get_candidates(kwargs)
        return utils.fetch_page(query, kwargs, model=Candidate)


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
    @args.register_kwargs(args.make_sort_args(default=['-expire_date']))
    @schemas.marshal_with(schemas.CandidateDetailPageSchema())
    def get(self, candidate_id=None, committee_id=None, **kwargs):
        query = self.get_candidate(kwargs, candidate_id, committee_id)
        return utils.fetch_page(query, kwargs, model=CandidateDetail)

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

        return candidates


@spec.doc(
    tags=['candidate'],
    path_params=[
        {'name': 'candidate_id', 'in': 'path', 'type': 'string'},
        {'name': 'cycle', 'in': 'path', 'type': 'integer'},
    ],
)
class CandidateHistoryView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.make_sort_args(default=['-two_year_period']))
    @schemas.marshal_with(schemas.CandidateHistoryPageSchema())
    def get(self, candidate_id, cycle=None, **kwargs):
        query = self.get_candidate(candidate_id, cycle, kwargs)
        return utils.fetch_page(query, kwargs)

    def get_candidate(self, candidate_id, cycle, kwargs):
        query = CandidateHistory.query.filter(CandidateHistory.candidate_id == candidate_id)
        if cycle:
            query = query.filter(CandidateHistory.two_year_period == cycle)
        return query
