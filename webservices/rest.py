"""
A RESTful web service supporting fulltext and field-specific searches on FEC
candidate data.

SEE DOCUMENTATION FOLDER
"""
import os
import sys
import logging

from flask import Flask
from flask.ext import restful
from flask.ext.restful import reqparse
import flask.ext.restful.representations.json
import sqlalchemy as sa
from smore import swagger

from .db import db_conn
from .json_encoding import TolerantJSONEncoder
from webservices.common.models import db
from webservices.resources.candidates import CandidateList, CandidateView
from webservices.resources.totals import TotalsView
from webservices.resources.reports import ReportsView
from webservices.resources.committees import CommitteeList, CommitteeView
from webservices.common.util import Pagination
from webservices.spec import spec
from webservices import args

speedlogger = logging.getLogger('speed')
speedlogger.setLevel(logging.CRITICAL)
speedlogger.addHandler(logging.FileHandler(('rest_speed.log')))

flask.ext.restful.representations.json.settings["cls"] = TolerantJSONEncoder


def sqla_conn_string():
    sqla_conn_string = os.getenv('SQLA_CONN')
    if not sqla_conn_string:
        print("Environment variable SQLA_CONN is empty; running against " + "local `cfdm_test`")
        sqla_conn_string = 'postgresql://:@/cfdm_test'
    print(sqla_conn_string)
    return sqla_conn_string

app = Flask(__name__)
app.debug = True
app.config['SQLALCHEMY_DATABASE_URI'] = sqla_conn_string()
api = restful.Api(app)
db.init_app(app)

@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Methods', 'GET')
    response.headers.add('Access-Control-Max-Age', '3000')
    return response


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
        page_data = Pagination(1, 1, len(data))

        return {"api_version": "0.2",
                "pagination": page_data.as_json(),
                "results": [dict(d) for d in data]}


class Help(restful.Resource):
    def get(self):
        result = {'doc': sys.modules[__name__].__doc__,
                  'endpoints': {}}
        return result

api.add_resource(Help, '/')
api.add_resource(CandidateView, '/candidate/<string:candidate_id>', '/committee/<string:committee_id>/candidates')
api.add_resource(CandidateList, '/candidates')
api.add_resource(CommitteeView, '/committee/<string:committee_id>', '/candidate/<string:candidate_id>/committees')
api.add_resource(CommitteeList, '/committees')
api.add_resource(TotalsView, '/committee/<string:id>/totals')
api.add_resource(ReportsView, '/committee/<string:id>/reports')
api.add_resource(NameSearch, '/names')

def extend(*dicts):
    ret = {}
    for each in dicts:
        ret.update(each)
    return ret

with app.app_context():
    spec.add_path(
        view=app.view_functions['candidateview'],
        operations={
            'get': {
                'responses': {
                    200: {'schema': {'$ref': '#/definitions/CandidateDetail'}},
                },
                'parameters': swagger.args2parameters(extend(args.paging, args.candidate_list, args.candidate_detail)),
            },
        },
    )
    spec.add_path(
        view=app.view_functions['candidatelist'],
        operations={
            'get': {
                'responses': {
                    200: {'schema': {'$ref': '#/definitions/Candidate'}},
                },
                'parameters': swagger.args2parameters(extend(args.paging, args.candidate_list)),
            },
        },
    )
