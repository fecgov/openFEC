"""
A RESTful web service supporting fulltext and field-specific searches on FEC
candidate data.

SEE DOCUMENTATION FOLDER
(We can leave this here for now but this is all covered in the documentation
and changes should be reflected there)

Supported parameters across all objects::

    q=         (fulltext search)

Supported for /candidate ::

    /<cand_id>   Single candidate's record
    cand_id=     Synonym for /<cand_id>
    fec_id=      Synonym for /<cand_id>
    office=      (governmental office run for)
    state=       (two-letter code)
    district=    two-digit number
    name=        (candidate's name)
    page=        Page number
    party=       (3-letter abbreviation)
    per_page=    Number of records per page
    year=        (any year in which candidate ran)
    fields=      specify the fields returned

Supported for /committee ::

    /<cmte_id>   Single candidate's record
    cmte_id=     Synonym for /<cmte_id>
    fec_id=      Synonym for /<cmte_id>
    name=        (committee's name)
    state=       (two-letter code)
    candidate=   (associated candidate's name)
    type=   one-letter code see decoders.cmte
    designation=  one-letter code see decoders.designation
    year=        The four-digit election year

"""
import string
import sys
import sqlalchemy as sa
from flask import Flask
from flask.ext.restful import reqparse
from flask.ext import restful
import flask.ext.restful.representations.json
from json_encoding import TolerantJSONEncoder
import logging

from candidates.resources import CandidateResource, CandidateSearch
from committees.format import format_committees
from committees.models import Committee
from db import db_conn
from resources import Searchable, SingleResource
from totals.resources import TotalResource, TotalSearch

speedlogger = logging.getLogger('speed')
speedlogger.setLevel(logging.CRITICAL)
speedlogger.addHandler(logging.FileHandler(('rest_speed.log')))

flask.ext.restful.representations.json.settings["cls"] = TolerantJSONEncoder

app = Flask(__name__)
api = restful.Api(app)


class NameSearch(Searchable):
    """
    A quick name search (candidate or committee) optimized for response time for typeahead
    """

    fulltext_qry = """SELECT cand_id AS candidate_id,
                             cmte_id AS committee_id,
                             name,
                             office_sought
                      FROM   name_search_fulltext
                      WHERE  name_vec @@ to_tsquery(:findme || ':*')
                      ORDER BY ts_rank_cd(name_vec, to_tsquery(:findme || ':*')) desc
                      LIMIT  20"""

    parser = reqparse.RequestParser()
    parser.add_argument(
        'q',
        type=str,
        help='Name (candidate or committee) to search for',
    )

    def get(self):
        args = self.parser.parse_args(strict=True)

        qry = sa.sql.text(self.fulltext_qry)
        findme = ' & '.join(args['q'].split())
        data = db_conn().execute(qry, findme = findme).fetchall()

        return {"api_version": "0.2",
                "pagination": {'per_page': 20, 'page': 1, 'pages': 1, 'count': len(data)},
                "results": [dict(d) for d in data]}

    def format(self, data_dict, page_data, year):
        args = self.parser.parse_args()
        fields = self.find_fields(args)
        return format_committees(self, data_dict, page_data, fields, year)


class CommitteeResource(SingleResource, Committee):

    parser = reqparse.RequestParser()
    parser.add_argument(
        'fields',
        type=str,
        help='Choose the fields that are displayed'
    )

    def format(self, data_dict, page_data, year):
        args = self.parser.parse_args()
        fields = self.find_fields(args)
        return format_committees(self, data_dict, page_data, fields, year)


class CommitteeSearch(Searchable, Committee):

    field_name_map = {"committee_id": string.Template("cmte_id={'$arg'}"),
                        "fec_id": string.Template("cmte_id='$arg'"),
                        "candidate_id":string.Template(
                            "exists(dimlinkages?cand_id={'$arg'})"
                        ),
                        "state": string.Template(
                            "top(dimcmteproperties.sort(expire_date-)).cmte_st={'$arg'}"
                        ),
                        "name": string.Template(
                            "top(dimcmteproperties.sort(expire_date-)).cmte_nm~'$arg'"
                        ),
                        "type": string.Template(
                            "top(dimcmtetpdsgn.sort(expire_date-)).cmte_tp={'$arg'}"
                        ),
                        "designation": string.Template(
                            "top(dimcmtetpdsgn.sort(expire_date-)).cmte_dsgn={'$arg'}"
                        ),
                        "organization_type": string.Template(
                            "top(dimcmteproperties.sort(expire_date-)).org_tp={'$arg'}"
                        ),
                        "party": string.Template(
                            "top(dimcmteproperties.sort(expire_date-)).cand_pty_affiliation={'$arg'}"
                        ),
    }

    parser = reqparse.RequestParser()
    parser.add_argument(
        'q',
        type=str,
        help='Text to search all fields for'
    )
    parser.add_argument(
        'committee_id',
        type=str,
        help="Committee's FEC ID"
    )
    parser.add_argument(
        'fec_id',
        type=str,
        help="Committee's FEC ID"
    )
    parser.add_argument(
        'state',
        type=str,
        help='U. S. State committee is registered in'
    )
    parser.add_argument(
        'name',
        type=str,
        help="Committee's name (full or partial)"
    )
    parser.add_argument(
        'candidate_id',
        type=str,
        help="Associated candidate's name (full or partial)"
    )
    parser.add_argument(
        'page',
        type=int,
        default=1,
        help='For paginating through results, starting at page 1'
    )
    parser.add_argument(
        'per_page',
        type=int,
        default=20,
        help='The number of results returned per page. Defaults to 20.'
    )
    parser.add_argument(
        'fields',
        type=str,
        help='Choose the fields that are displayed'
    )
    parser.add_argument(
        'type',
        type=str,
        help='The one-letter type code of the organization'
    )
    parser.add_argument(
        'designation',
        type=str,
        help='The one-letter designation code of the organization'
    )
    parser.add_argument(
        'organization_type',
        type=str,
        help='The one-letter code for the kind for organization'
    )
    parser.add_argument(
        'party',
        type=str,
        help='Three letter code for party'
    )

    def format(self, data_dict, page_data, year):
        args = self.parser.parse_args()
        fields = self.find_fields(args)
        return format_committees(self, data_dict, page_data, fields, year)


class Help(restful.Resource):
    def get(self):
        result = {'doc': sys.modules[__name__].__doc__,
                  'endpoints': {}}
        for cls in (CandidateSearch, CommitteeSearch):
            name = cls.__name__[:-6].lower()
            result['endpoints'][name] = {'arguments supported':
                                         {a.name: a.help for a in sorted(cls.parser.args)}}
        return result


api.add_resource(Help, '/')
api.add_resource(CandidateResource, '/candidate/<string:id>')
api.add_resource(CandidateSearch, '/candidate')
api.add_resource(CommitteeResource, '/committee/<string:id>')
api.add_resource(CommitteeSearch, '/committee')
api.add_resource(TotalResource, '/total/<string:id>')
api.add_resource(TotalSearch, '/total')
api.add_resource(NameSearch, '/name')
