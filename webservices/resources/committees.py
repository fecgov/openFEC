from flask.ext.restful import Resource, reqparse, fields, marshal_with, inputs
from webservices.common.models import db, Candidate, Committee, CandidateCommittee
from webservices.common.util import default_year
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
    parser.add_argument('candidate_id', type=str, help="Candidate's FEC ID")
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
        candidate_id = kwargs.get('id', args.get('candidate_id', None))

        # pagination
        page_num = args.get('page', 1)
        per_page = args.get('per_page', 20)

        count, committees = self.get_committees(args, page_num, per_page, candidate_id=candidate_id)

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


    def get_committees(self, args, page_num, per_page, candidate_id=None):

        committees = Committee.query

        if candidate_id:
            committees = Committee.query.join(CandidateCommittee).filter(CandidateCommittee.candidate_id==candidate_id)

        elif args.get('q'):
            fulltext_qry = """SELECT cmte_sk
                              FROM   dimcmte_fulltext
                              WHERE  fulltxt @@ to_tsquery(:findme)
                              ORDER BY ts_rank_cd(fulltxt, to_tsquery(:findme)) desc"""

            findme = ' & '.join(args['q'].split())
            committees = committees.filter(Committee.committee_key.in_(
                db.session.query("cmte_sk").from_statement(text(fulltext_qry)).params(findme=findme)))


        for argname in ['committee_id', 'designation', 'organization_type', 'state', 'party', 'committee_type']:
            if args.get(argname):
                if ',' in args[argname]:
                    committees = committees.filter(getattr(Committee, argname).in_(args[argname].split(',')))
                else:
                    committees = committees.filter(getattr(Committee, argname)==args[argname])

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

        return count, committees.order_by(Committee.name).paginate(page_num, per_page, False).items

