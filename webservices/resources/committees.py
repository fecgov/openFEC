from flask.ext.restful import Resource, reqparse, fields, marshal_with, inputs
from webservices.common.models import db
from webservices.common.util import default_year
from webservices.resources.candidates import Candidate
from sqlalchemy.sql import text, or_
from sqlalchemy import extract
from datetime import date


# output format for flask-restful marshaling
candidate_commitee_fields = {
    'candidate_id': fields.String,
    'election_year': fields.Integer,
    'link_date': fields.String,
    'expire_date': fields.String,
}
committee_fields = {
    'committee_id': fields.String,
    'name': fields.String,
    'designation_full': fields.String,
    'designation': fields.String,
    'treasurer_name': fields.String,
    'organization_type_full': fields.String,
    'organization_type': fields.String,
    'state': fields.String,
    'party_full': fields.String,
    'party': fields.String,
    'committee_type_full': fields.String,
    'committee_type': fields.String,
    'expire_date': fields.String,
    'original_registration_date': fields.String,
    'candidates': fields.Nested(candidate_commitee_fields),
}
pagination_fields = {
    'per_page': fields.Integer,
    'page': fields.Integer,
    'count': fields.Integer,
    'pages': fields.Integer,
}
committee_list_fields = {
    'api_version': fields.Fixed(1),
    'pagination': fields.Nested(pagination_fields),
    'results': fields.Nested(committee_fields),
}


class CommitteeList(Resource):
    parser = reqparse.RequestParser()
    parser.add_argument('q', type=str, help='Text to search all fields for')
    parser.add_argument('committee_id', type=str, help="Committee's FEC ID")
    parser.add_argument('state', type=str, help='Two digit U.S. State committee is registered in')
    parser.add_argument('name', type=str, help="Committee's name (full or partial)")
    parser.add_argument('page', type=int, default=1, help='For paginating through results, starting at page 1')
    parser.add_argument('per_page', type=int, default=20, help='The number of results returned per page. Defaults to 20.')
    parser.add_argument('committee_type', type=str, help='The one-letter type code of the organization')
    parser.add_argument('designation', type=str, help='The one-letter designation code of the organization')
    parser.add_argument('organization_type', type=str, help='The one-letter code for the kind for organization')
    parser.add_argument('party', type=str, help='Three letter code for party')
    parser.add_argument('year', type=str, default=None, help='A year that the committee was active- (after original registration date but before expiration date.)')
    # not implemented yet
    # parser.add_argument('expire_date', type=str, help='Date the committee registration expires')
    # parser.add_argument('original_registration_date', type=str, help='Date of the committees first registered')

    @marshal_with(committee_list_fields)
    def get(self, **kwargs):

        args = self.parser.parse_args(strict=True)

        # pagination
        page_num = args.get('page', 1)
        per_page = args.get('per_page', 20)

        count, committees = self.get_committees(args, page_num, per_page)

        data = {
            'api_version': '0.2',
            'pagination': {
                'page': page_num,
                'per_page': per_page,
                'count': count,
                'pages': int(count / per_page),
            },
            'results': committees
        }

        return data

# maybe filtering out U designation committees would be faster, less records?
    def get_committees(self, args, page_num, per_page):
        committees = Committee.query

        fulltext_qry = """SELECT cmte_sk
                          FROM   dimcmte_fulltext
                          WHERE  fulltxt @@ to_tsquery(:findme)
                          ORDER BY ts_rank_cd(fulltxt, to_tsquery(:findme)) desc"""

        if args.get('q'):
            findme = ' & '.join(args['q'].split())
            committees = committees.filter(Committee.committee_key.in_(
                db.session.query("cmte_sk").from_statement(text(fulltext_qry)).params(findme=findme)))

        for argname in ['committee_id', 'designation', 'organization_type', 'state', 'party', 'committee_type']:
            if args.get(argname):
                if ',' in args[argname]:
                    committees = committees.filter(getattr(Committee, argname).in_(args[argname].split(',')))
                else:
                    committees = committees.filter_by(**{argname: args[argname]})

        if args.get('name'):
            committees = committees.filter(Committee.name.ilike('%{}%'.format(args['name'])))

        # default year filtering
        if args.get('year') is None:
            earliest_year = int(sorted(default_year().split(','))[0])
            # still going or expired after the earliest year we are looking for
            committees = committees.filter(or_(extract('year', Committee.expire_date) >= earliest_year, Committee.expire_date == None))

        # Should this handle a list of years to make it consistent with /candidate ?
        elif args.get('year') and args['year'] != '*':
            # before expiration
            committees = committees.filter(or_(extract('year', Committee.expire_date) >= int(args['year']), Committee.expire_date == None))
            # after origination
            committees = committees.filter(extract('year', Committee.original_registration_date) <= int(args['year']))

        count = committees.count()

        print str(committees)

        return count, committees.order_by(Committee.name).paginate(page_num, per_page, False).items










class CommitteeByCandidate(Resource):
    parser = reqparse.RequestParser()
    parser.add_argument('state', type=str, help='Two digit U.S. State committee is registered in')
    parser.add_argument('name', type=str, help="Committee's name (full or partial)")
    parser.add_argument('page', type=int, default=1, help='For paginating through results, starting at page 1')
    parser.add_argument('per_page', type=int, default=20, help='The number of results returned per page. Defaults to 20.')
    parser.add_argument('committee_type', type=str, help='The one-letter type code of the organization')
    parser.add_argument('designation', type=str, help='The one-letter designation code of the organization')
    parser.add_argument('organization_type', type=str, help='The one-letter code for the kind for organization')
    parser.add_argument('party', type=str, help='Three letter code for party')
    parser.add_argument('year', type=str, default=None, help='A year that the committee was active- (fter original registration but before expiration.)')

    @marshal_with(committee_list_fields)
    def get(self, **kwargs):

        args = self.parser.parse_args(strict=True)

        # pagination
        page_num = args.get('page', 1)
        per_page = args.get('per_page', 20)

        count, committees = self.get_committees(args, page_num, per_page, **kwargs)

        data = {
            'api_version': '0.2',
            'pagination': {
                'page': page_num,
                'per_page': per_page,
                'count': count,
                'pages': int(count / per_page),
            },
            'results': committees
        }


        return data

    def get_committees(self, args, page_num, per_page, **kwargs):
        # look up candidate in dimlinkages to find committees
        candidate_id = kwargs['id']
        cand_committees = db.session.query(CandidateCommitteeLink).from_statement(
                text("SELECT cmte_sk, linkages_sk FROM dimlinkages WHERE cand_id=:candidate_id")).\
                params(candidate_id=candidate_id).all()
        committee_keys = []
        for c in cand_committees:
            committee_keys.append(int(c.committee_key))
        print committee_keys
        # look up committees
        committees = Committee.query
        # this is only working if there is one committee returned
        committees = committees.filter(getattr(Committee, 'committee_key').in_(committee_keys))

        for argname in ['designation', 'organization_type', 'state', 'party', 'committee_type']:
            if args.get(argname):
                if ',' in args[argname]:
                    committees = committees.filter(getattr(Committee, argname).in_(args[argname].split(',')))
                else:
                    committees = committees.filter_by(**{argname: args[argname]})

        # default year filtering
        if args.get('year') is None:
            earliest_year = int(sorted(default_year().split(','))[0])
            # still going or expired after the earliest year we are looking for
            committees = committees.filter(or_(extract('year', Committee.expire_date) >= earliest_year, Committee.expire_date == None))

        # Should this handle a list of years to make it consistent with /candidate ?
        elif args.get('year') and args['year'] != '*':
            # before expiration
            committees = committees.filter(or_(extract('year', Committee.expire_date) >= int(args['year']), Committee.expire_date == None))
            # after origination
            committees = committees.filter(extract('year', Committee.original_registration_date) <= int(args['year']))

        count = committees.count()

        print str(committees)

        return count, committees.order_by(Committee.name).paginate(page_num, per_page, False).items


class Committee(db.Model):
    committee_key = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column(db.String(9))
    designation = db.Column(db.String(1))
    designation_full = db.Column(db.String(25))
    treasurer_name = db.Column(db.String(100))
    organization_type = db.Column(db.String(1))
    organization_type_full = db.Column(db.String(100))
    state = db.Column(db.String(2))
    committee_type = db.Column(db.String(1))
    committee_type_full = db.Column(db.String(50))
    expire_date = db.Column(db.DateTime())
    party = db.Column(db.String(3))
    party_full = db.Column(db.String(50))
    original_registration_date = db.Column(db.DateTime())
    name = db.Column(db.String(100))
    candidates = db.relationship('CandidateCommitteeLink', backref='committees')

    __tablename__ = 'ofec_committees_vw'


class CommitteeFulltext(db.Model):
    cmte_sk = db.Column(db.Integer, primary_key=True)
    fulltxt = db.Column(db.Text)

    __tablename__ = 'dimcmte_fulltext'


class CandidateCommitteeLink(db.Model):
    linkages_sk = db.Column(db.Integer, primary_key=True)
    committee_key = db.Column('cmte_sk', db.Integer, db.ForeignKey(Committee.committee_key))
    candidate_key = db.Column('cand_sk', db.Integer, db.ForeignKey(Candidate.candidate_key))
    committee_id = db.Column('cmte_id', db.String(10))
    candidate_id = db.Column('cand_id', db.String(10))
    election_year = db.Column('cand_election_yr', db.Integer)
    link_date = db.Column('link_date', db.DateTime())
    expire_date = db.Column('expire_date', db.DateTime())

    __tablename__ = 'dimlinkages'
