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
import logging
import sys
import os

from flask import Flask
from flask.ext import restful
from flask.ext.restful import reqparse
import flask.ext.restful.representations.json
from json_encoding import TolerantJSONEncoder
import sqlalchemy as sa

from db import db_conn, as_dicts
from candidates.resources import CandidateResource
# from committees.resources import CommitteeResource
from resources import Searchable
from totals.resources import TotalResource, TotalSearch
from webservices.common.models import db
from webservices.resources.candidates import CandidateList, CandidateView
from webservices.resources.totals import TotalsView
from webservices.resources.reports import ReportsView
from webservices.resources.committees import CommitteeList, CommitteeView

speedlogger = logging.getLogger('speed')
speedlogger.setLevel(logging.CRITICAL)
speedlogger.addHandler(logging.FileHandler(('rest_speed.log')))

flask.ext.restful.representations.json.settings["cls"] = TolerantJSONEncoder


def sqla_conn_string():
    sqla_conn_string = os.getenv('SQLA_CONN')
    if not sqla_conn_string:
        print("Environment variable SQLA_CONN is empty; running against "
              + "local `cfdm_test`")
        sqla_conn_string = 'postgresql://:@/cfdm_test'
    print sqla_conn_string
    return sqla_conn_string

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = sqla_conn_string()
api = restful.Api(app)
db.init_app(app)


class NameSearch(restful.Resource):
    """
    A quick name search (candidate or committee) optimized for response time
    for typeahead
    """

    fulltext_qry = """
        SELECT cand_id AS candidate_id,
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
        data = db_conn().execute(qry, findme=findme).fetchall()

        return {"api_version": "0.2",
                "pagination": {'per_page': 20, 'page': 1, 'pages': 1,
                               'count': len(data)},
                "results": [dict(d) for d in data]}


class Help(restful.Resource):
    def get(self):
        result = {'doc': sys.modules[__name__].__doc__,
                  'endpoints': {}}
        for cls in (CandidateList, CommitteeSearch):
            name = cls.__name__[:-6].lower()
            result['endpoints'][name] = {
                'arguments supported': {a.name: a.help
                                        for a in sorted(cls.parser.args)}
            }
        return result

api.add_resource(Help, '/')
api.add_resource(CandidateView, '/candidate/<string:candidate_id>', '/committee/<string:committee_id>/candidates')
api.add_resource(CandidateList, '/candidate')
api.add_resource(CommitteeView, '/committee/<string:committee_id>', '/candidate/<string:candidate_id>/committees')
api.add_resource(CommitteeList, '/committee')
api.add_resource(TotalsView, '/committee/<string:id>/totals')
api.add_resource(TotalResource, '/total/<string:id>')
api.add_resource(TotalSearch, '/total')
api.add_resource(ReportsView, '/committee/<string:id>/reports')
api.add_resource(NameSearch, '/name')
# for debugging
api.add_resource(CandidateResource, '/oldcandidate/<string:id>')
