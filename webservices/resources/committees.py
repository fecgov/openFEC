import sqlalchemy as sa
from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.util import filter_query


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


@spec.doc(
    tags=['committee'],
    description=docs.COMMITTEE_LIST,
)
class CommitteeList(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.committee)
    @args.register_kwargs(args.committee_list)
    @args.register_kwargs(args.make_sort_args(default=['name']))
    @schemas.marshal_with(schemas.CommitteePageSchema())
    def get(self, **kwargs):
        query = self.get_committees(kwargs)
        return utils.fetch_page(query, kwargs)

    def get_committees(self, kwargs):

        committees = models.Committee.query

        if kwargs['candidate_id']:
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
            )

        if kwargs.get('name'):
            committees = committees.filter(models.Committee.name.ilike('%{}%'.format(kwargs['name'])))

        committees = filter_query(models.Committee, committees, list_filter_fields, kwargs)

        if kwargs['year']:
            committees = filter_year(models.Committee, committees, kwargs['year'])

        if kwargs['cycle']:
            committees = committees.filter(models.Committee.cycles.overlap(kwargs['cycle']))

        if kwargs['min_first_file_date']:
            committees = committees.filter(models.Committee.first_file_date >= kwargs['min_first_file_date'])
        if kwargs['max_first_file_date']:
            committees = committees.filter(models.Committee.first_file_date <= kwargs['max_first_file_date'])

        return committees


@spec.doc(
    tags=['committee'],
    description=docs.COMMITTEE_DETAIL,
    path_params=[
        {
            'name': 'candidate_id',
            'type': 'string',
            'in': 'path',
            'description': docs.CANDIDATE_ID,
        },
        {
            'name': 'committee_id',
            'type': 'string',
            'in': 'path',
            'description': docs.COMMITTEE_ID,
        },
    ],
)
class CommitteeView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.committee)
    @args.register_kwargs(args.make_sort_args(default=['name']))
    @schemas.marshal_with(schemas.CommitteeDetailPageSchema())
    def get(self, committee_id=None, candidate_id=None, **kwargs):
        query = self.get_committee(kwargs, committee_id, candidate_id)
        return utils.fetch_page(query, kwargs)

    def get_committee(self, kwargs, committee_id, candidate_id):

        committees = models.CommitteeDetail.query

        if committee_id is not None:
            committees = committees.filter_by(committee_id=committee_id)

        if candidate_id is not None:
            committees = models.CommitteeDetail.query.join(
                models.CandidateCommitteeLink
            ).filter(
                models.CandidateCommitteeLink.candidate_id == candidate_id
            )

        committees = filter_query(models.CommitteeDetail, committees, detail_filter_fields, kwargs)

        if kwargs['year']:
            committees = filter_year(models.CommitteeDetail, committees, kwargs['year'])

        if kwargs['cycle']:
            committees = committees.filter(models.CommitteeDetail.cycles.overlap(kwargs['cycle']))

        return committees


@spec.doc(
    tags=['committee'],
    description=docs.COMMITTEE_HISTORY,
    path_params=[
        {'name': 'committee_id', 'description': docs.COMMITTEE_ID, 'in': 'path', 'type': 'string'},
        {'name': 'candidate_id', 'description': docs.CANDIDATE_ID, 'in': 'path', 'type': 'string'},
        {'name': 'cycle', 'in': 'path', 'type': 'integer'},
    ],
)
class CommitteeHistoryView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.make_sort_args(default=['-cycle']))
    @schemas.marshal_with(schemas.CommitteeHistoryPageSchema())
    def get(self, committee_id=None, candidate_id=None, cycle=None, **kwargs):
        query = self.get_committee(committee_id, candidate_id, cycle, kwargs)
        return utils.fetch_page(query, kwargs)

    def get_committee(self, committee_id, candidate_id, cycle, kwargs):
        query = models.CommitteeHistory.query

        if committee_id:
            query = query.filter(models.CommitteeHistory.committee_id == committee_id)

        if candidate_id:
            query = query.join(
                models.CandidateCommitteeLink,
                models.CandidateCommitteeLink.committee_key == models.CommitteeHistory.committee_key,
            ).filter(
                models.CandidateCommitteeLink.candidate_id == candidate_id
            )

        if cycle:
            query = query.filter(models.CommitteeHistory.cycle == cycle)

        return query
