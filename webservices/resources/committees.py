from sqlalchemy import extract
from sqlalchemy.sql import text, or_
from flask.ext.restful import Resource

from webservices import args
from webservices import spec
from webservices import paging
from webservices import schemas
from webservices.common.util import default_year
from webservices.common.util import filter_query
from webservices.common.models import db, Committee, CandidateCommitteeLink, CommitteeDetail


list_filter_fields = {'committee_id', 'designation', 'organization_type', 'state', 'party', 'committee_type'}
detail_filter_fields = {'designation', 'organization_type', 'committee_type'}


def filter_year(model, query, kwargs):
    # default year filtering
    if kwargs.get('year') is None:
        earliest_year = int(sorted(default_year().split(','))[0])
        # still going or expired after the earliest year we are looking for
        query = query.filter(
            or_(
                extract('year', model.expire_date) >= earliest_year,
                model.expire_date == None  # noqa
            )
        )

    # Should this handle a list of years to make it consistent with /candidate ?
    if kwargs.get('year') and kwargs['year'] != '*':
        # before expiration
        query = query.filter(
            or_(
                extract('year', model.expire_date) >= int(kwargs['year']),
                model.expire_date == None  # noqa
            )
        )
        # after origination
        query = query.filter(
            extract('year', model.original_registration_date) <= int(kwargs['year'])
        )

    return query


class CommitteeList(Resource):

    fulltext_query = """
        SELECT cmte_sk
        FROM   dimcmte_fulltext
        WHERE  fulltxt @@ to_tsquery(:findme)
        ORDER BY ts_rank_cd(fulltxt, to_tsquery(:findme)) desc
    """

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.committee)
    @args.register_kwargs(args.committee_list)
    @schemas.marshal_with(schemas.CommitteePageSchema())
    def get(self, **kwargs):
        committees = self.get_committees(kwargs)
        paginator = paging.SqlalchemyPaginator(committees, kwargs['per_page'])
        return paginator.get_page(kwargs['page'])

    def get_committees(self, kwargs):

        committees = Committee.query

        if kwargs['candidate_id']:
            committees = committees.filter(
                Committee.candidate_ids.overlap(kwargs['candidate_id'].split(','))
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
        committees = filter_year(Committee, committees, kwargs)

        return committees.order_by(Committee.name)


@spec.doc(path_params=[
    {'name': 'candidate_id', 'in': 'path', 'type': 'string'},
    {'name': 'committee_id', 'in': 'path', 'type': 'string'},
])
class CommitteeView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.committee)
    @schemas.marshal_with(schemas.CommitteeDetailPageSchema())
    def get(self, committee_id=None, candidate_id=None, **kwargs):
        committees = self.get_committee(kwargs, committee_id, candidate_id)
        paginator = paging.SqlalchemyPaginator(committees, kwargs['per_page'])
        return paginator.get_page(kwargs['page'])

    def get_committee(self, kwargs, committee_id, candidate_id):

        committees = CommitteeDetail.query

        if committee_id is not None:
            committees = committees.filter_by(**{'committee_id': committee_id})

        if candidate_id is not None:
            committees = committees.join(
                CandidateCommitteeLink
            ).filter(
                CandidateCommitteeLink.candidate_id == candidate_id
            )

        committees = filter_query(CommitteeDetail, committees, detail_filter_fields, kwargs)
        committees = filter_year(CommitteeDetail, committees, kwargs)

        return committees.order_by(CommitteeDetail.name)
