from sqlalchemy import extract
from sqlalchemy.sql import text, or_, and_
from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common.util import filter_query
from webservices.common.models import db, Committee, CandidateCommitteeLink, CommitteeDetail, CommitteeHistory


list_filter_fields = {'committee_id', 'designation', 'organization_type', 'state', 'party', 'committee_type'}
detail_filter_fields = {'designation', 'organization_type', 'committee_type'}


def filter_year(model, query, years):
    return query.filter(
        or_(*[
            and_(
                or_(
                    extract('year', model.last_file_date) >= year,
                    model.last_file_date == None,
                ),
                extract('year', model.first_file_date) <= year,
            )
            for year in years
        ])
    )  # noqa


@spec.doc(
    tags=['committee'],
    description=docs.COMMITTEE_LIST,
)
class CommitteeList(Resource):

    fulltext_query = '''
        SELECT cmte_sk
        FROM   ofec_committee_fulltext_mv
        WHERE  fulltxt @@ to_tsquery(:findme)
        ORDER BY ts_rank_cd(fulltxt, to_tsquery(:findme)) desc
    '''

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.committee)
    @args.register_kwargs(args.committee_list)
    @args.register_kwargs(args.make_sort_args(default=['name']))
    @schemas.marshal_with(schemas.CommitteePageSchema())
    def get(self, **kwargs):
        query = self.get_committees(kwargs)
        return utils.fetch_page(query, kwargs)

    def get_committees(self, kwargs):

        committees = Committee.query

        if kwargs['candidate_id']:
            committees = committees.filter(
                Committee.candidate_ids.overlap(kwargs['candidate_id'])
            )

        if kwargs.get('q'):
            findme = ' & '.join(kwargs['q'].split())
            committees = committees.filter(
                Committee.committee_key.in_(
                    db.session.query('cmte_sk').from_statement(text(self.fulltext_query)).params(findme=findme)
                )
            )

        if kwargs.get('name'):
            committees = committees.filter(Committee.name.ilike('%{}%'.format(kwargs['name'])))

        committees = filter_query(Committee, committees, list_filter_fields, kwargs)

        if kwargs['year']:
            committees = filter_year(Committee, committees, kwargs['year'])

        if kwargs['cycle']:
            committees = committees.filter(Committee.cycles.overlap(kwargs['cycle']))

        return committees


@spec.doc(
    tags=['committee'],
    path_params=[
        {'name': 'candidate_id', 'in': 'path', 'type': 'string'},
        {'name': 'committee_id', 'in': 'path', 'type': 'string'},
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

        committees = CommitteeDetail.query

        if committee_id is not None:
            committees = committees.filter_by(committee_id=committee_id)

        if candidate_id is not None:
            committees = CommitteeDetail.query.join(
                CandidateCommitteeLink
            ).filter(
                CandidateCommitteeLink.candidate_id == candidate_id
            )

        committees = filter_query(CommitteeDetail, committees, detail_filter_fields, kwargs)

        if kwargs['year']:
            committees = filter_year(CommitteeDetail, committees, kwargs['year'])

        if kwargs['cycle']:
            committees = committees.filter(CommitteeDetail.cycles.overlap(kwargs['cycle']))

        return committees


@spec.doc(
    tags=['committee'],
    path_params=[
        {'name': 'committee_id', 'in': 'path', 'type': 'string'},
        {'name': 'candidate_id', 'in': 'path', 'type': 'string'},
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
        query = CommitteeHistory.query

        if committee_id:
            query = query.filter(CommitteeHistory.committee_id == committee_id)

        if candidate_id:
            query = CommitteeHistory.query.join(
                CandidateCommitteeLink,
                CandidateCommitteeLink.committee_key == CommitteeHistory.committee_key,
            ).filter(
                CandidateCommitteeLink.candidate_id == candidate_id
            )

        if cycle:
            query = query.filter(CommitteeHistory.cycle == cycle)

        return query
