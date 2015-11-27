import sqlalchemy as sa
from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.util import filter_query
from webservices.common.views import ApiResource


list_filter_fields = {'committee_id', 'designation', 'organization_type', 'state', 'party', 'committee_type'}
detail_filter_fields = {'designation', 'organization_type', 'committee_type'}


def filter_year(model, query, years):
    return query.filter(
        sa.or_(*[
            sa.and_(
                sa.or_(
                    sa.extract('year', model.last_file_date) >= year,
                    model.last_file_date == None,
                ),
                sa.extract('year', model.first_file_date) <= year,
            )
            for year in years
        ])
    )  # noqa


@doc(
    tags=['committee'],
    description=docs.COMMITTEE_LIST,
)
class CommitteeList(ApiResource):

    model = models.Committee
    schema = schemas.CommitteeSchema
    page_schema = schemas.CommitteePageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.committee,
            args.committee_list,
            args.make_sort_args(
                default=['name'],
                validator=args.IndexValidator(self.model),
            ),
        )

    def build_query(self, **kwargs):

        committees = models.Committee.query

        if kwargs.get('candidate_id'):
            committees = committees.filter(
                models.Committee.candidate_ids.overlap(kwargs['candidate_id'])
            )

        if kwargs.get('q'):
            committees = utils.search_text(
                committees.join(
                    models.CommitteeSearch,
                    models.Committee.committee_id == models.CommitteeSearch.id,
                ),
                models.CommitteeSearch.fulltxt,
                kwargs['q'],
            ).distinct()

        if kwargs.get('name'):
            committees = committees.filter(models.Committee.name.ilike('%{}%'.format(kwargs['name'])))

        committees = filter_query(models.Committee, committees, list_filter_fields, kwargs)

        if kwargs.get('year'):
            committees = filter_year(models.Committee, committees, kwargs['year'])

        if kwargs.get('cycle'):
            committees = committees.filter(models.Committee.cycles.overlap(kwargs['cycle']))

        if kwargs.get('min_first_file_date'):
            committees = committees.filter(models.Committee.first_file_date >= kwargs['min_first_file_date'])
        if kwargs.get('max_first_file_date'):
            committees = committees.filter(models.Committee.first_file_date <= kwargs['max_first_file_date'])

        return committees


@doc(
    tags=['committee'],
    description=docs.COMMITTEE_DETAIL,
    params={
        'candidate_id': {'description': docs.CANDIDATE_ID},
        'committee_id': {'description': docs.COMMITTEE_ID},
    },
)
class CommitteeView(ApiResource):

    model = models.CommitteeDetail
    schema = schemas.CommitteeDetailSchema
    page_schema = schemas.CommitteeDetailPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.committee,
            args.make_sort_args(
                default=['name'],
                validator=args.IndexValidator(self.model),
            ),
        )

    def build_query(self, committee_id=None, candidate_id=None, **kwargs):

        committees = models.CommitteeDetail.query

        if committee_id is not None:
            committees = committees.filter_by(committee_id=committee_id)

        if candidate_id is not None:
            committees = models.CommitteeDetail.query.join(
                models.CandidateCommitteeLink
            ).filter(
                models.CandidateCommitteeLink.candidate_id == candidate_id
            ).distinct()

        committees = filter_query(models.CommitteeDetail, committees, detail_filter_fields, kwargs)

        if kwargs.get('year'):
            committees = filter_year(models.CommitteeDetail, committees, kwargs['year'])

        if kwargs.get('cycle'):
            committees = committees.filter(models.CommitteeDetail.cycles.overlap(kwargs['cycle']))

        return committees


@doc(
    tags=['committee'],
    description=docs.COMMITTEE_HISTORY,
    params={
        'candidate_id': {'description': docs.CANDIDATE_ID},
        'committee_id': {'description': docs.COMMITTEE_ID},
        'cycle': {'description': docs.COMMITTEE_CYCLE},
    },
)
class CommitteeHistoryView(ApiResource):

    model = models.CommitteeHistory
    schema = schemas.CommitteeHistorySchema
    page_schema = schemas.CommitteeHistoryPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.make_sort_args(
                default=['-cycle'],
                validator=args.IndexValidator(self.model),
            ),
        )

    def build_query(self, committee_id=None, candidate_id=None, cycle=None, **kwargs):
        query = models.CommitteeHistory.query

        if committee_id:
            query = query.filter(models.CommitteeHistory.committee_id == committee_id)

        if candidate_id:
            query = query.join(
                models.CandidateCommitteeLink,
                models.CandidateCommitteeLink.committee_id == models.CommitteeHistory.committee_id,
            ).filter(
                models.CandidateCommitteeLink.candidate_id == candidate_id
            ).distinct()

        if cycle:
            query = query.filter(models.CommitteeHistory.cycle == cycle)

        return query
