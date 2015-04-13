from sqlalchemy import extract
from sqlalchemy.sql import text, or_
from webargs.flaskparser import use_kwargs
from flask.ext.restful import Resource

from webservices import args
from webservices import paging
from webservices import schemas
from webservices.common.models import db, Candidate, CandidateDetail, CandidateCommitteeLink


fulltext_query = """
    SELECT cand_sk
    FROM   dimcand_fulltext
    WHERE  fulltxt @@ to_tsquery(:findme)
    ORDER BY ts_rank_cd(fulltxt, to_tsquery(:findme)) desc
"""

filter_fields = {
    'candidate_id',
    'candidate_status',
    'district',
    'incumbent_challenge',
    'office',
    'party',
    'state',
}

def filter_query(model, query, fields, **kwargs):
    for field, value in kwargs.items():
        if field not in fields or not value:
            continue
        column = getattr(model, field)
        predicate = (
            column.in_(value.split(','))
            if ',' in value
            else column == value
        )
        query = query.filter(predicate)
    return query


class CandidateList(Resource):

    @use_kwargs(args.paging)
    @use_kwargs(args.candidate_list)
    @use_kwargs(args.candidate_detail)
    def get(self, **kwargs):
        candidates = self.get_candidates(kwargs)
        paginator = paging.SqlalchemyPaginator(candidates, kwargs['per_page'])
        page = paginator.get_page(kwargs['page'])
        return schemas.CandidatePageSchema().dump(page).data

    def get_candidates(self, kwargs):

        candidates = Candidate.query

        if kwargs.get('q'):
            findme = ' & '.join(kwargs['q'].split())
            candidates = candidates.filter(
                Candidate.candidate_key.in_(
                    db.session.query('cand_sk').from_statement(text(fulltext_query)).params(findme=findme)
                )
            )

        candidates = filter_query(Candidate, candidates, filter_fields, **kwargs)

        if kwargs.get('name'):
            candidates = candidates.filter(Candidate.name.ilike('%{}%'.format(kwargs['name'])))

        if kwargs.get('election_year') and kwargs['election_year'] != '*':
            candidates = candidates.filter(
                Candidate.election_years.overlap(
                    [int(x) for x in kwargs['election_year'].split(',')]
                )
            )

        return candidates.order_by(Candidate.name)


class CandidateView(Resource):

    @use_kwargs(args.paging)
    @use_kwargs(args.candidate_detail)
    def get(self, candidate_id=None, committee_id=None, **kwargs):
        candidates = self.get_candidate(kwargs, candidate_id, committee_id)
        paginator = paging.SqlalchemyPaginator(candidates, kwargs['per_page'])
        page = paginator.get_page(kwargs['page'])
        return schemas.CandidateDetailPageSchema().dump(page).data

    def get_candidate(self, kwargs, candidate_id, committee_id):
        if candidate_id is not None:
            candidates = CandidateDetail.query
            candidates = candidates.filter_by(**{'candidate_id': candidate_id})

        if committee_id is not None:
            candidates = CandidateDetail.query.join(CandidateCommitteeLink).filter(CandidateCommitteeLink.committee_id==committee_id)

        candidates = filter_query(CandidateDetail, candidates, filter_fields, **kwargs)

        if kwargs.get('year') and kwargs['year'] != '*':
            # before expiration
            candidates = candidates.filter(
                or_(
                    extract('year', CandidateDetail.expire_date) >= int(args['year']),
                    CandidateDetail.expire_date == None,  # noqa
                )
            )
            # after origination
            candidates = candidates.filter(extract('year', CandidateDetail.load_date) <= int(args['year']))

        return candidates.order_by(CandidateDetail.expire_date.desc())
