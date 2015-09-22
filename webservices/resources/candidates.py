import sqlalchemy as sa
from flask_smore import doc, use_kwargs, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.util import filter_query


filter_fields = {
    'candidate_id',
    'candidate_status',
    'district',
    'incumbent_challenge',
    'office',
    'party',
    'state',
}


@doc(
    tags=['candidate'],
    description=docs.CANDIDATE_LIST,
)
class CandidateList(utils.Resource):

    @property
    def query(self):
        return models.Candidate.query

    @use_kwargs(args.paging)
    @use_kwargs(args.candidate_list)
    @use_kwargs(args.candidate_detail)
    @use_kwargs(
        args.make_sort_args(
            default=['name'],
            validator=args.IndexValidator(models.Candidate),
        )
    )
    @marshal_with(schemas.CandidatePageSchema())
    def get(self, **kwargs):
        query = self.get_candidates(kwargs)
        return utils.fetch_page(query, kwargs, model=models.Candidate)

    def get_candidates(self, kwargs):

        candidates = self.query

        if kwargs.get('q'):
            candidates = utils.search_text(
                candidates.join(
                    models.CandidateSearch,
                    models.Candidate.candidate_id == models.CandidateSearch.id,
                ),
                models.CandidateSearch.fulltxt,
                kwargs['q'],
            ).distinct()

        candidates = filter_query(models.Candidate, candidates, filter_fields, kwargs)

        if kwargs.get('name'):
            candidates = candidates.filter(models.Candidate.name.ilike('%{}%'.format(kwargs['name'])))

        # TODO(jmcarp) Reintroduce year filter pending accurate `load_date` and `expire_date` values
        if kwargs['cycle']:
            candidates = candidates.filter(models.Candidate.cycles.overlap(kwargs['cycle']))

        return candidates


@doc(
    tags=['candidate'],
    description=docs.CANDIDATE_SEARCH,
)
class CandidateSearch(CandidateList):

    @property
    def query(self):
        # Eagerly load principal committees to avoid extra queries
        return models.Candidate.query.options(
            sa.orm.subqueryload(models.Candidate.principal_committees)
        )

    @use_kwargs(args.paging)
    @use_kwargs(args.candidate_list)
    @use_kwargs(args.candidate_detail)
    @use_kwargs(args.make_sort_args(validator=args.IndexValidator(models.Candidate)))
    @marshal_with(schemas.CandidateSearchPageSchema())
    def get(self, **kwargs):
        query = self.get_candidates(kwargs)
        return utils.fetch_page(query, kwargs, model=models.Candidate)


@doc(
    tags=['candidate'],
    description=docs.CANDIDATE_DETAIL,
    params={
        'candidate_id': {'description': docs.CANDIDATE_ID},
        'committee_id': {'description': docs.COMMITTEE_ID},
    },
)
class CandidateView(utils.Resource):

    @use_kwargs(args.paging)
    @use_kwargs(args.candidate_detail)
    @use_kwargs(
        args.make_sort_args(
            default=['-expire_date'],
            validator=args.IndexValidator(models.CandidateDetail),
        )
    )
    @marshal_with(schemas.CandidateDetailPageSchema())
    def get(self, candidate_id=None, committee_id=None, **kwargs):
        query = self.get_candidate(kwargs, candidate_id, committee_id)
        return utils.fetch_page(query, kwargs, model=models.CandidateDetail)

    def get_candidate(self, kwargs, candidate_id=None, committee_id=None):
        if candidate_id is not None:
            candidates = models.CandidateDetail.query
            candidates = candidates.filter_by(candidate_id=candidate_id)

        if committee_id is not None:
            candidates = models.CandidateDetail.query.join(
                models.CandidateCommitteeLink
            ).filter(
                models.CandidateCommitteeLink.committee_id == committee_id
            ).distinct()

        candidates = filter_query(models.CandidateDetail, candidates, filter_fields, kwargs)

        # TODO(jmcarp) Reintroduce year filter pending accurate `load_date` and `expire_date` values
        if kwargs['cycle']:
            candidates = candidates.filter(models.CandidateDetail.cycles.overlap(kwargs['cycle']))

        return candidates


@doc(
    tags=['candidate'],
    description=docs.CANDIDATE_HISTORY,
    params={
        'candidate_id': {'description': docs.CANDIDATE_ID},
        'committee_id': {'description': docs.COMMITTEE_ID},
        'cycle': {'description': docs.CANDIDATE_CYCLE},
    },
)
class CandidateHistoryView(utils.Resource):

    @use_kwargs(args.paging)
    @use_kwargs(
        args.make_sort_args(
            default=['-two_year_period'],
            validator=args.IndexValidator(models.CandidateHistory),
        )
    )
    @marshal_with(schemas.CandidateHistoryPageSchema())
    def get(self, candidate_id=None, committee_id=None, cycle=None, **kwargs):
        query = self.get_candidate(candidate_id, committee_id, cycle, kwargs)
        return utils.fetch_page(query, kwargs, model=models.CandidateHistory)

    def get_candidate(self, candidate_id, committee_id, cycle, kwargs):
        query = models.CandidateHistory.query

        if candidate_id:
            query = query.filter(models.CandidateHistory.candidate_id == candidate_id)

        if committee_id:
            query = query.join(
                models.CandidateCommitteeLink,
                models.CandidateCommitteeLink.candidate_key == models.CandidateHistory.candidate_key,
            ).filter(
                models.CandidateCommitteeLink.committee_id == committee_id
            ).distinct()

        if cycle:
            query = query.filter(models.CandidateHistory.two_year_period == cycle)

        return query
