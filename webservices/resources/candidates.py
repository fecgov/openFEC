import sqlalchemy as sa
from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.util import filter_query
from webservices.common.views import ApiResource


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
class CandidateList(ApiResource):

    model = models.Candidate
    schema = schemas.CandidateSchema
    page_schema = schemas.CandidatePageSchema

    @property
    def query(self):
        return models.Candidate.query

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.candidate_list,
            args.candidate_detail,
            args.make_sort_args(
                default=['name'],
                validator=args.IndexValidator(self.model)
            )
        )

    def build_query(self, **kwargs):

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
        if kwargs.get('cycle'):
            candidates = candidates.filter(models.Candidate.cycles.overlap(kwargs['cycle']))

        return candidates


@doc(
    tags=['candidate'],
    description=docs.CANDIDATE_SEARCH,
)
class CandidateSearch(CandidateList):

    schema = schemas.CandidateSearchSchema
    page_schema = schemas.CandidateSearchPageSchema

    @property
    def query(self):
        # Eagerly load principal committees to avoid extra queries
        return models.Candidate.query.options(
            sa.orm.subqueryload(models.Candidate.principal_committees)
        )


@doc(
    tags=['candidate'],
    description=docs.CANDIDATE_DETAIL,
    params={
        'candidate_id': {'description': docs.CANDIDATE_ID},
        'committee_id': {'description': docs.COMMITTEE_ID},
    },
)
class CandidateView(ApiResource):

    model = models.CandidateDetail
    schema = schemas.CandidateDetailSchema
    page_schema = schemas.CandidateDetailPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.candidate_detail,
            args.make_sort_args(
                default=['-expire_date'],
                validator=args.IndexValidator(self.model),
            ),
        )

    def build_query(self, candidate_id=None, committee_id=None, **kwargs):
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
        if kwargs.get('cycle'):
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
class CandidateHistoryView(ApiResource):

    model = models.CandidateHistory
    schema = schemas.CandidateHistorySchema
    page_schema = schemas.CandidateHistoryPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.make_sort_args(
                default=['-two_year_period'],
                validator=args.IndexValidator(self.model),
            ),
        )

    def build_query(self, candidate_id=None, committee_id=None, cycle=None, **kwargs):
        query = models.CandidateHistory.query

        if candidate_id:
            query = query.filter(models.CandidateHistory.candidate_id == candidate_id)

        if committee_id:
            query = query.join(
                models.CandidateCommitteeLink,
                models.CandidateCommitteeLink.candidate_id == models.CandidateHistory.candidate_id,
            ).filter(
                models.CandidateCommitteeLink.committee_id == committee_id
            ).distinct()

        if cycle:
            query = query.filter(models.CandidateHistory.two_year_period == cycle)

        return query
