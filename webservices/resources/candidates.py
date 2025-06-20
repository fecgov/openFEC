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


# used for endpoint:`/candidates/`
# under tag: candidate
# Ex: http://127.0.0.1:5000/v1/candidates/?candidate_id=S2TX00106&sort=name
@doc(
    tags=['candidate'], description=docs.CANDIDATE_LIST,
)
class CandidateList(ApiResource):

    model = models.Candidate
    schema = schemas.CandidateSchema
    page_schema = schemas.CandidatePageSchema
    filter_multi_fields = filter_multi_fields(models.Candidate)
    filter_range_fields = filter_range_fields(models.Candidate)
    filter_fulltext_fields = [('q', models.CandidateSearch.fulltxt)]
    aliases = {'receipts': models.CandidateSearch.receipts}
    contains_joined_load = True

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
                    models.Candidate, extra=list(self.aliases.keys()),
                ),
            ),
        )

    def build_query(self, **kwargs):
        if kwargs.get("sort"):
            if "q" not in kwargs and kwargs["sort"] in {"receipts", "-receipts"}:
                raise exceptions.ApiError(
                    "Cannot sort on receipts when parameter 'q' is not set",
                    status_code=422,
                )

        if kwargs.get('name'):
            kwargs['q'] = kwargs['name']

        query = super().build_query(**kwargs)
        query._array_cast_keys = set()

        candidate_detail = models.Candidate

        if 'has_raised_funds' in kwargs:
            query = query.filter(
                candidate_detail.flags.has(
                    models.CandidateFlags.has_raised_funds == kwargs['has_raised_funds']
                )
            )
        if 'federal_funds_flag' in kwargs:
            query = query.filter(
                candidate_detail.flags.has(
                    models.CandidateFlags.federal_funds_flag
                    == kwargs['federal_funds_flag']
                )
            )

        if kwargs.get('q'):
            query = query.join(
                models.CandidateSearch,
                candidate_detail.candidate_id == models.CandidateSearch.id,
            ).distinct()

            if kwargs.get("sort") in {"receipts", "-receipts"}:
                query = query.add_columns(models.CandidateSearch.receipts)

        if kwargs.get('cycle'):
            query = query.filter(candidate_detail.cycles.overlap(kwargs['cycle']))
            query._array_cast_keys.add('cycles_')
        if kwargs.get('election_year'):
            query = query.filter(
                candidate_detail.election_years.overlap(kwargs['election_year'])
            )
            query._array_cast_keys.add('election_years_')
        if 'is_active_candidate' in kwargs and kwargs.get('is_active_candidate'):
            # load active candidates only if True
            if kwargs.get('election_year'):
                query = query.filter(
                    sa.or_(
                        ~(
                            candidate_detail.inactive_election_years.contains(
                                kwargs['election_year']
                            )
                        ),
                        candidate_detail.inactive_election_years.is_(None),
                    )
                )
                query._array_cast_keys.add('inactive_election_years_')

            else:
                query = query.filter(
                    candidate_detail.candidate_inactive.is_(False)
                )  # noqa
        elif 'is_active_candidate' in kwargs and not kwargs.get('is_active_candidate'):
            # load inactive candidates only if False
            if kwargs.get('election_year'):
                query = query.filter(
                    candidate_detail.inactive_election_years.overlap(
                        kwargs['election_year']
                    )
                )
                query._array_cast_keys.add('inactive_election_years_')
            else:
                query = query.filter(
                    candidate_detail.candidate_inactive == True  # noqa
                )
        else:
            # load all candidates
            pass
        return query


# used for endpoint:`/candidates/search/`
# under tag: candidate
# Ex: http://127.0.0.1:5000/v1/candidates/search/
@doc(
    tags=['candidate'], description=docs.CANDIDATE_SEARCH,
)
class CandidateSearch(CandidateList):

    schema = schemas.CandidateSearchSchema
    page_schema = schemas.CandidateSearchPageSchema
    contains_joined_load = True

    query_options = [
        sa.orm.joinedload(models.Candidate.flags),
        sa.orm.selectinload(models.Candidate.principal_committees),
    ]


# used for endpoints: `/candidate/<string:candidate_id>/`
# `/committee/<string:committee_id>/candidates/`
# under tag: candidate
# Ex: http://127.0.0.1:5000/v1/candidate/P40014052/
# http://127.0.0.1:5000/v1/committee/C00684373/candidates/
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
    contains_joined_load = True

    query_options = [
        sa.orm.joinedload(models.CandidateDetail.flags),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.candidate_detail,
            args.make_sort_args(
                default='name', validator=args.IndexValidator(self.model),
            ),
        )

    def build_query(self, candidate_id=None, committee_id=None, **kwargs):
        query = super().build_query(**kwargs)
        query._array_cast_keys = set()

        if candidate_id is not None:
            candidate_id = candidate_id.upper()
            utils.check_candidate_id(candidate_id)
            query = query.filter_by(candidate_id=candidate_id)

        if committee_id is not None:
            committee_id = committee_id.upper()
            utils.check_committee_id(committee_id)

            query = (
                query.join(models.CandidateCommitteeLink)
                .filter(models.CandidateCommitteeLink.committee_id == committee_id)
                .distinct()
            )

        if kwargs.get('cycle'):
            query = query.filter(models.CandidateDetail.cycles.overlap(kwargs['cycle']))
            query._array_cast_keys.add('cycles_')
        if kwargs.get('election_year'):
            query = query.filter(
                models.Candidate.election_years.overlap(kwargs['election_year'])
            )
            query._array_cast_keys.add('election_years_')
        if 'has_raised_funds' in kwargs:
            query = query.filter(
                models.Candidate.flags.has(
                    models.CandidateFlags.has_raised_funds == kwargs['has_raised_funds']
                )
            )
        if 'federal_funds_flag' in kwargs:
            query = query.filter(
                models.Candidate.flags.has(
                    models.CandidateFlags.federal_funds_flag
                    == kwargs['federal_funds_flag']
                )
            )
        return query


# used for endpoints: `/candidate/<string:candidate_id>/history/`
# `/candidate/<string:candidate_id>/history/<int:cycle>/`
# `/committee/<string:committee_id>/candidates/history/`
# `/committee/<string:committee_id>/candidates/history/<int:cycle>/`
# under tag: candidate
# Ex: http://127.0.0.1:5000/v1/candidate/P40014052/history/
# http://127.0.0.1:5000/v1/candidate/P40014052/history/2024/
# http://127.0.0.1:5000/v1/committee/C00684373/candidates/history/
# http://127.0.0.1:5000/v1/committee/C00684373/candidates/history/2020/
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
    contains_joined_load = True

    query_options = [
        sa.orm.joinedload(models.CandidateHistory.flags),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.candidate_history,
            args.make_sort_args(
                default='-two_year_period', validator=args.IndexValidator(self.model),
            ),
        )

    def build_query(self, candidate_id=None, committee_id=None, cycle=None, **kwargs):
        query = super().build_query(**kwargs)

        if candidate_id:
            # use for
            # '/candidate/<string:candidate_id>/history/',
            # '/candidate/<string:candidate_id>/history/<int:cycle>/',
            candidate_id = candidate_id.upper()
            utils.check_candidate_id(candidate_id)
            query = query.filter(models.CandidateHistory.candidate_id == candidate_id)

        if committee_id:
            committee_id = committee_id.upper()
            utils.check_committee_id(committee_id)

            # use for
            # '/committee/<string:committee_id>/candidates/history/',
            # '/committee/<string:committee_id>/candidates/history/<int:cycle>/',
            query = (
                query.join(
                    models.CandidateCommitteeLink,
                    models.CandidateCommitteeLink.candidate_id
                    == models.CandidateHistory.candidate_id,
                )
                .filter(models.CandidateCommitteeLink.committee_id == committee_id)
                .distinct()
            )
        if cycle:
            # use for
            # '/candidate/<string:candidate_id>/history/<int:cycle>/',
            # '/committee/<string:committee_id>/candidates/history/<int:cycle>/',
            if kwargs.get('election_full'):
                query = query.filter(
                    (
                        models.CandidateHistory.candidate_election_year % 2
                        + models.CandidateHistory.candidate_election_year
                    )
                    == cycle
                )
            else:
                query = query.filter(models.CandidateHistory.two_year_period == cycle)
        return query
