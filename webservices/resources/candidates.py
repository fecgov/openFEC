import sqlalchemy as sa
from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices import exceptions
from webservices.common import models
from webservices.common.views import ApiResource


def filter_multi_fields(model):
    return [
        ('candidate_id', model.candidate_id),
        ('candidate_status', model.candidate_status),
        ('district', model.district),
        ('incumbent_challenge', model.incumbent_challenge),
        ('office', model.office),
        ('party', model.party),
        ('state', model.state),
    ]


def filter_range_fields(model):
    return [
        (('min_first_file_date', 'max_first_file_date'), model.first_file_date),
    ]


@doc(
    tags=['candidate'],
    description=docs.CANDIDATE_LIST,
)
class CandidateList(ApiResource):

    model = models.Candidate
    schema = schemas.CandidateSchema
    page_schema = schemas.CandidatePageSchema
    filter_multi_fields = filter_multi_fields(models.Candidate)
    filter_range_fields = filter_range_fields(models.Candidate)
    filter_fulltext_fields = [('q', models.CandidateSearch.fulltxt)]
    aliases = {'receipts': models.CandidateSearch.receipts}

    query_options = [
        sa.orm.joinedload(models.Candidate.flags),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.candidate_list,
            args.candidate_detail,
            args.make_sort_args(
                default='name',
                validator=args.IndexValidator(
                    models.Candidate,
                    extra=list(self.aliases.keys()),
                ),
            )
        )

    def build_query(self, **kwargs):
        if kwargs.get('name'):
            kwargs['q'] = kwargs['name']

        query = super().build_query(**kwargs)
        candidate_detail = models.Candidate

        if {'receipts', '-receipts'}.intersection(kwargs.get('sort', [])) and 'q' not in kwargs:
            raise exceptions.ApiError(
                'Cannot sort on receipts when parameter "q" is not set',
                status_code=422,
            )

        if 'has_raised_funds' in kwargs:
            query = query.filter(
                candidate_detail.flags.has(models.CandidateFlags.has_raised_funds == kwargs['has_raised_funds'])
            )
        if 'federal_funds_flag' in kwargs:
            query = query.filter(
                candidate_detail.flags.has(models.CandidateFlags.federal_funds_flag == kwargs['federal_funds_flag'])
            )

        if kwargs.get('q'):
            query = query.join(
                models.CandidateSearch,
                candidate_detail.candidate_id == models.CandidateSearch.id,
            ).distinct()

        if kwargs.get('cycle'):
            query = query.filter(candidate_detail.cycles.overlap(kwargs['cycle']))
        if kwargs.get('election_year'):
            query = query.filter(candidate_detail.election_years.overlap(kwargs['election_year']))
        if 'is_active_candidate' in kwargs and kwargs.get('is_active_candidate'):
            # load active candidates only if True
            if kwargs.get('election_year'):
                query = query.filter(
                    sa.or_(~(candidate_detail.inactive_election_years.contains(kwargs['election_year'])),
                        candidate_detail.inactive_election_years.is_(None))
                )
            else:
                query = query.filter(candidate_detail.candidate_inactive == False)# noqa
        elif 'is_active_candidate' in kwargs and not kwargs.get('is_active_candidate'):
            # load inactive candidates only if False
            if kwargs.get('election_year'):
                query = query.filter(candidate_detail.inactive_election_years.overlap(kwargs['election_year']))
            else:
                query = query.filter(
                    candidate_detail.candidate_inactive == True # noqa
                )
        else:
            # load all candidates
            pass
        return query


@doc(
    tags=['candidate'],
    description=docs.CANDIDATE_SEARCH,
)
class CandidateSearch(CandidateList):

    schema = schemas.CandidateSearchSchema
    page_schema = schemas.CandidateSearchPageSchema
    query_options = [
        sa.orm.joinedload(models.Candidate.flags),
        sa.orm.subqueryload(models.Candidate.principal_committees),
    ]


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
    filter_multi_fields = filter_multi_fields(models.CandidateDetail)

    query_options = [
        sa.orm.joinedload(models.CandidateDetail.flags),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.candidate_detail,
            args.make_sort_args(
                default='name',
                validator=args.IndexValidator(self.model),
            ),
        )

    def build_query(self, candidate_id=None, committee_id=None, **kwargs):
        query = super().build_query(**kwargs)

        if candidate_id is not None:
            query = query.filter_by(candidate_id=candidate_id)

        if committee_id is not None:
            query = query.join(
                models.CandidateCommitteeLink
            ).filter(
                models.CandidateCommitteeLink.committee_id == committee_id
            ).distinct()

        if kwargs.get('cycle'):
            query = query.filter(models.CandidateDetail.cycles.overlap(kwargs['cycle']))
        if kwargs.get('election_year'):
            query = query.filter(models.Candidate.election_years.overlap(kwargs['election_year']))
        if 'has_raised_funds' in kwargs:
            query = query.filter(
                models.Candidate.flags.has(models.CandidateFlags.has_raised_funds == kwargs['has_raised_funds'])
            )
        if 'federal_funds_flag' in kwargs:
            query = query.filter(
                models.Candidate.flags.has(models.CandidateFlags.federal_funds_flag == kwargs['federal_funds_flag'])
            )

        return query


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

    query_options = [
        sa.orm.joinedload(models.CandidateHistory.flags),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.candidate_history,
            args.make_sort_args(
                default='-two_year_period',
                validator=args.IndexValidator(self.model),
            ),
        )

    def build_query(self, candidate_id=None, committee_id=None, cycle=None, **kwargs):
        query = super().build_query(**kwargs)

        if candidate_id:
            # use for
            # '/candidate/<string:candidate_id>/history/',
            # '/candidate/<string:candidate_id>/history/<int:cycle>/',
            query = query.filter(models.CandidateHistory.candidate_id == candidate_id)

        if committee_id:
            # use for
            # '/committee/<string:committee_id>/candidates/history/',
            # '/committee/<string:committee_id>/candidates/history/<int:cycle>/',
            query = query.join(
                models.CandidateCommitteeLink,
                models.CandidateCommitteeLink.candidate_id == models.CandidateHistory.candidate_id,
            ).filter(
                models.CandidateCommitteeLink.committee_id == committee_id
            ).distinct()
        if cycle:
            # use for
            # '/candidate/<string:candidate_id>/history/<int:cycle>/',
            # '/committee/<string:committee_id>/candidates/history/<int:cycle>/',
            if kwargs.get('election_full'):
                query = query.filter(
                    (models.CandidateHistory.candidate_election_year % 2 +
                        models.CandidateHistory.candidate_election_year) == cycle
                )
            else:
                query = query.filter(models.CandidateHistory.two_year_period == cycle)

        return query
