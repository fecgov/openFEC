from flask.ext.restful import Resource, reqparse, fields, marshal_with, inputs
from webservices.common.models import db
from webservices.common.util import default_year
from sqlalchemy.sql import text


# output format for flask-restful marshaling
candidate_fields = {
    'candidate_id': fields.String,
    'candidate_status_short': fields.String,
    'candidate_status': fields.String,
    'district': fields.String,
    'election_year': fields.Integer,
    'incumbent_challenge_short': fields.String,
    'incumbent_challenge': fields.String,
    'office_short': fields.String,
    'office': fields.String,
    'party_short': fields.String,
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
    parser.add_argument('party', type=str, help="Party under which a candidate ran for office")
    parser.add_argument('party_short', type=str, help="Three letter code of the party under which a candidate ran for office")
    parser.add_argument('year', type=str, default=default_year(), dest='election_year', help="Year in which a candidate runs for office")
    parser.add_argument('fields', type=str, help='Choose the fields that are displayed')
    parser.add_argument('district', type=str, help='Two digit district number')
    parser.add_argument('candidate_status', type=str, help='Test explaining if the candidate is a present, future or past candidate')
    parser.add_argument('candidate_status_short', type=str, help='Code explaining if the candidate is a present, future or past candidate')
    parser.add_argument('incumbent_challenge', type=str, help='Text explaining if the candidate is an incumbent, a challenger, or if the seat is open.')
    parser.add_argument('incumbent_challenge_short', type=str, help='Code explaining if the candidate is an incumbent, a challenger, or if the seat is open.')

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

        for argname in ['office', 'district', 'state', 'party', 'candidate_id']:
            if args.get(argname):
                if ',' in args[argname]:
                    candidates = candidates.filter(getattr(Candidate, argname).in_(args[argname].split(',')))
                elif argname in ['office', 'party', 'incumbent_challenge', 'candidate_status']:
                    candidates = candidates.filter_by(**{argname + '_short': args[argname]})
                else:
                    candidates = candidates.filter_by(**{argname: args[argname]})


        if args.get('name'):
            candidates = candidates.filter(Candidate.name.ilike('%{}%'.format(args['name'])))

        if args.get('election_year') and args['election_year'] != '*':
            candidates = candidates.filter(Candidate.election_year.in_(args['election_year'].split(',')))

        count = candidates.count()

        return count, candidates.order_by(Candidate.name).paginate(page_num, per_page, False).items


class Candidate(db.Model):
    candidate_key = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String(10))
    candidate_status_short = db.Column(db.String(1))
    candidate_status = db.Column(db.String(11))
    district = db.Column(db.String(2))
    election_year = db.Column(db.Integer)
    incumbent_challenge_short = db.Column(db.String(1))
    incumbent_challenge = db.Column(db.String(10))
    office_short = db.Column(db.String(1))
    office = db.Column(db.String(9))
    party_short = db.Column(db.String(3))
    party = db.Column(db.String(255))
    state = db.Column(db.String(2))
    name = db.Column(db.String(100))

    __tablename__ = 'ofec_candidates_vw'

class CandidateFulltext(db.Model):
    cand_sk = db.Column(db.Integer, primary_key=True)
    fulltxt = db.Column(db.Text)

    __tablename__ = 'dimcand_fulltext'
