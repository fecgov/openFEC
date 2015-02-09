from flask.ext.restful import Resource, reqparse, fields, marshal_with
from webservices.common.models import db
from webservices.common.util import default_year, natural_number


# output format for flask-restful marshaling
candidate_fields = {
    'candidate_id': fields.String,
    'candidate_status': fields.String,
    'district': fields.String,
    'election_year': fields.Integer,
    'incumbent_challenge': fields.String,
    'office': fields.String,
    'party': fields.String,
    'party_affiliation': fields.String,
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
    'pagination': fields.Nested(pagination_fields),
    'results': fields.Nested(candidate_fields),
}


class CandidateList(Resource):
    parser = reqparse.RequestParser()
    parser.add_argument('q', type=str, help='Text to search all fields for')
    parser.add_argument('candidate_id', type=str, help="Candidate's FEC ID")
    parser.add_argument('fec_id', type=str, help="Candidate's FEC ID")
    parser.add_argument('page', type=natural_number, default=1, help='For paginating through results, starting at page 1')
    parser.add_argument('per_page', type=natural_number, default=20, help='The number of results returned per page. Defaults to 20.')
    parser.add_argument('name', type=str, help="Candidate's name (full or partial)")
    parser.add_argument('office', type=str, help='Governmental office candidate runs for')
    parser.add_argument('state', type=str, help='U. S. State candidate is registered in')
    parser.add_argument('party', type=str, help="Party under which a candidate ran for office")
    parser.add_argument('year', type=str, default=default_year(), dest='election_year', help="Year in which a candidate runs for office")
    parser.add_argument('fields', type=str, help='Choose the fields that are displayed')
    parser.add_argument('district', type=str, help='Two digit district number')

    @marshal_with(candidate_list_fields)
    def get(self, **kwargs):

        args = self.parser.parse_args(strict=True)

        # pagination
        page_num = args.get('page', 1)
        per_page = args.get('per_page', 20)

        count, candidates = self.get_candidates(args, page_num, per_page)

        data = {
            'pagination': {
                'page': page_num,
                'per_page': per_page,
                'count': count,
                'pages': int(count / per_page),
            },
            'results': candidates
        }

        # TODO: add fulltext search back in ('q')

        return data

    def get_candidates(self, args, page_num, per_page):
        candidates = Candidate.query

        for argname in ['office', 'district', 'state', 'party', 'candidate_id']:
            if args.get(argname):
                candidates = candidates.filter_by(**{argname: args[argname]})

        if args.get('name'):
            candidates = candidates.filter(Candidate.name.ilike('%{}%'.format(args['name'])))

        candidates = candidates.filter(Candidate.election_year.in_(args.get('election_year').split(',')))
        count = candidates.count()

        return count, candidates.paginate(page_num, per_page, False).items


class Candidate(db.Model):
    candidate_key = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String(10))
    candidate_status = db.Column(db.String(1))
    district = db.Column(db.String(2))
    election_year = db.Column(db.Integer)
    incumbent_challenge = db.Column(db.String(1))
    office = db.Column(db.String(1))
    party = db.Column(db.String(3))
    party_affiliation = db.Column(db.String(64))
    state = db.Column(db.String(2))
    name = db.Column(db.String(100))

    __tablename__ = 'ofec_candidates_vw'

# class DimcandFulltext(db.Model):
#     cand_sk = db.Column(db.Integer)
#     fulltxt = db.Column(db.Text)
