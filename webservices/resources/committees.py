from flask.ext.restful import Resource, reqparse, fields, marshal_with, inputs
from webservices.common.models import db
from webservices.common.util import default_year
from sqlalchemy.sql import text


# output format for flask-restful marshaling
committee_fields = {
    'committee_id': fields.String,
    'name': fields.String,
    'designation_short': fields.String,
    'designation': fields.String,
    'treasurer_name': fields.String,
    'organization_type_short': fields.String,
    'organization_type': fields.String,
    'state': fields.String,
    'party_short': fields.String,
    'party': fields.String,
    'committee_type_short': fields.String,
    'committee_type': fields.String,
    'expire_date': fields.String,
    'original_registration_date': fields.String,
    # want to add ids
    'candidates': db.relationship('Linkages', backref='committees'),
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
    parser.add_argument(
        'q', type=str, help='Text to search all fields for'
    )
    parser.add_argument(
        'committee_id', type=str, help="Committee's FEC ID"
    )
    parser.add_argument(
        'state', type=str, help='Two digit U.S. State committee is registered in'
    )
    parser.add_argument(
        'name', type=str, help="Committee's name (full or partial)"
    )
    parser.add_argument(
        'page', type=int, default=1, help='For paginating through results, starting at page 1'
    )
    parser.add_argument(
        'per_page', type=int, default=20, help='The number of results returned per page. Defaults to 20.'
    )
    parser.add_argument(
        'committee_type', type=str, help='The one-letter type code of the organization'
    )
    parser.add_argument(
        'designation', type=str, help='The one-letter designation code of the organization'
    )
    parser.add_argument(
        'designation_short', type=str, help='The one-letter designation code of the organization'
    )
    parser.add_argument(
        'organization_type', type=str, help='The one-letter code for the kind for organization'
    )
    parser.add_argument(
        'organization_type_short', type=str, help='The one-letter code for the kind for organization'
    )
    parser.add_argument(
        'party', type=str, help='Three letter code for party'
    )
    parser.add_argument(
        'expire_date', type=str, help='Date the committee registration expires'
    )
    parser.add_argument(
        'original_registration_date', type=str, help='Date of the committees first registered'
    )
    parser.add_argument(
        'candidate_ids', type=str,help='FEC IDs of candidates that committees have mentioned in filings. (See designation for the nature of the relationship.)'
    )

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

        for argname in ['committee_id', 'name', 'designation', 'organization_type', 'state', 'party', 'committee_type', 'expire_date', 'original_registration_date']:
            if args.get(argname):
                if ',' in args[argname]:
                    committees.filter(getattr(Committee, argname).in_(args[argname].split(',')))
                elif argname in ['designation', 'organization_type', 'committee_type', 'party']:
                    committees = committees.filter_by(**{argname + '_short': args[argname]})
                else:
                    committees = committees.filter_by(**{argname: args[argname]})

        if args.get('name'):
            committees = committees.filter(Committee.name.ilike('%{}%'.format(args['name'])))

        # I want to add a proper year filter here

        count = committees.count()

        # trying to access the candidate_ids
        #cand_id

        print str(committees)

        return count, committees.order_by(Committee.name).paginate(page_num, per_page, False).items


class Committee(db.Model):
    committee_key = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column(db.String(9))
    designation_short = db.Column(db.String(1))
    designation = db.Column(db.String(25))
    treasurer_name = db.Column(db.String(100))
    organization_type_short = db.Column(db.String(1))
    organization_type = db.Column(db.String(100))
    state = db.Column(db.String(2))
    committee_type_short = db.Column(db.String(1))
    committee_type = db.Column(db.String(50))
    expire_date = db.Column(db.DateTime())
    party_short = db.Column(db.String(3))
    party = db.Column(db.String(50))
    original_registration_date = db.Column(db.DateTime())
    name = db.Column(db.String(100))

    __tablename__ = 'ofec_committees_vw'


class CommitteeFulltext(db.Model):
    cmte_sk = db.Column(db.Integer, primary_key=True)
    fulltxt = db.Column(db.Text)

    __tablename__ = 'dimcmte_fulltext'


class Linkages(db.Model):
    cmte_sk = db.Column(db.Integer, primary_key=True)
    cand_id = db.Column(db.String(9))

    __tablename__ = 'linkages'


# trying to link candidate ids so that committees will be search-able by candidate ids
class Association(Committee):
    __tablename__ = 'association'
    dimcmte_id = db.Column(db.Integer, db.ForeignKey('ofec_committees_vw.committee_key'), primary_key=True, )
    linkages_id = db.Column(db.Integer, db.ForeignKey('linkages.cmte_sk'), primary_key=True)
    child = db.relationship("Linkages", backref="parent_assocs")

