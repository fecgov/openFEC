from flask.ext.restful import Resource, reqparse, fields, marshal_with, inputs
from webservices.common.models import db, Candidate
from webservices.common.util import default_year
from sqlalchemy.sql import text


# output format for flask-restful marshaling
candidate_fields = {
    'candidate_id': fields.String,
    'candidate_status_full': fields.String,
    'candidate_status': fields.String,
    'district': fields.String,
    'active_through': fields.Integer,
    'election_years': fields.List(fields.Integer),
    'incumbent_challenge_full': fields.String,
    'incumbent_challenge': fields.String,
    'office_full': fields.String,
    'office': fields.String,
    'party_full': fields.String,
    'party': fields.String,
    'state': fields.String,
    'name': fields.String,
}
pagination_fields = {
    'per_page': fields.Integer,
    'page': fields.Integer,
    'count': fields.Integer,
    'pages': fields.Integer,
}
candidate_list_fields = {
    'api_version': fields.Fixed(1),
    'pagination': fields.Nested(pagination_fields),
    'results': fields.Nested(candidate_fields),
}


class CandidateList(Resource):
    parser = reqparse.RequestParser()
    parser.add_argument('q', type=str, help='Text to search all fields for')
    parser.add_argument('candidate_id', type=str, help="Candidate's FEC ID")
    parser.add_argument('fec_id', type=str, help="Candidate's FEC ID")
    parser.add_argument('page', type=inputs.natural, default=1, help='For paginating through results, starting at page 1')
    parser.add_argument('per_page', type=inputs.natural, default=20, help='The number of results returned per page. Defaults to 20.')
    parser.add_argument('name', type=str, help="Candidate's name (full or partial)")
    parser.add_argument('office', type=str, help='Governmental office candidate runs for')
    parser.add_argument('state', type=str, help='U. S. State candidate is registered in')
    parser.add_argument('party', type=str, help="Three letter code for the party under which a candidate ran for office")
    parser.add_argument('year', type=str, default=default_year(), dest='election_year', help="Year in which a candidate runs for office")
    parser.add_argument('district', type=str, help='Two digit district number')
    parser.add_argument('candidate_status', type=str, help='One letter code explaining if the candidate is a present, future or past candidate')
    parser.add_argument('incumbent_challenge', type=str, help='One letter code explaining if the candidate is an incumbent, a challenger, or if the seat is open.')


    @marshal_with(candidate_list_fields)
    def get(self, **kwargs):

        args = self.parser.parse_args(strict=True)

        # pagination
        page_num = args.get('page', 1)
        per_page = args.get('per_page', 20)

        count, candidates = self.get_candidates(args, page_num, per_page)

        data = {
            'api_version': '0.2',
            'pagination': {
                'page': page_num,
                'per_page': per_page,
                'count': count,
                'pages': int(count / per_page),
            },
            'results': candidates
        }

        return data

    def get_candidates(self, args, page_num, per_page):
        candidates = Candidate.query

        fulltext_qry = """SELECT cand_sk
                          FROM   dimcand_fulltext
                          WHERE  fulltxt @@ to_tsquery(:findme)
                          ORDER BY ts_rank_cd(fulltxt, to_tsquery(:findme)) desc"""

        if args.get('q'):
            findme = ' & '.join(args['q'].split())
            candidates = candidates.filter(Candidate.candidate_key.in_(
                db.session.query("cand_sk").from_statement(text(fulltext_qry)).params(findme=findme)))

        for argname in ['candidate_id', 'candidate_status', 'district', 'incumbent_challenge', 'office', 'party', 'state']:
            if args.get(argname):
                # this is not working and doesn't look like it would work for _short
                if ',' in args[argname]:
                    candidates = candidates.filter(getattr(Candidate, argname).in_(args[argname].split(',')))
                else:
                    candidates = candidates.filter_by(**{argname: args[argname]})


        if args.get('name'):
            candidates = candidates.filter(Candidate.name.ilike('%{}%'.format(args['name'])))

        if args.get('election_year') and args['election_year'] != '*':
            candidates = candidates.filter(Candidate.election_years.overlap([int(x) for x in args['election_year'].split(',')]))

        count = candidates.count()

        return count, candidates.order_by(Candidate.name).paginate(page_num, per_page, False).items


