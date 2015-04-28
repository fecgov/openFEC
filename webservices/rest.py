"""
A RESTful web service supporting fulltext and field-specific searches on FEC
candidate data.

SEE DOCUMENTATION FOLDER
"""
import logging
import sys
import os

from flask import Flask, abort, request
from flask.ext import restful
from flask.ext.restful import reqparse
import flask.ext.restful.representations.json
from .json_encoding import TolerantJSONEncoder
import sqlalchemy as sa

from webservices.common.models import db
from webservices.resources.candidates import CandidateList, CandidateView, CandidateHistoryView
from webservices.resources.totals import TotalsView
from webservices.resources.reports import ReportsView
from webservices.resources.committees import CommitteeList, CommitteeView
from webservices.common.util import Pagination

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
app.config['SQLALCHEMY_DATABASE_URI'] = sqla_conn_string()
api = restful.Api(app)
db.init_app(app)

# api.data.gov
trusted_proxies = ('54.208.160.112', '54.208.160.151')
FEC_API_WHITELIST_IPS = os.getenv('FEC_API_WHITELIST_IPS', False)


@app.before_request
def limit_remote_addr():
    falses = (False, 'False', 'false', 'f')
    if FEC_API_WHITELIST_IPS not in falses:
        try:
            *_, api_data_route, cf_route = request.access_route
        except ValueError:  # Not enough routes
            abort(403)
        else:
            if api_data_route not in trusted_proxies:
                abort(403)


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
      FROM   name_search_fulltext_mv
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
        data = db.engine.execute(qry, findme=findme).fetchall()
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
api.add_resource(CandidateHistoryView, '/candidate/<string:candidate_id>/history/<string:year>', '/candidate/<string:candidate_id>/history')
api.add_resource(CandidateList, '/candidates')
api.add_resource(CommitteeView, '/committee/<string:committee_id>', '/candidate/<string:candidate_id>/committees')
api.add_resource(CommitteeList, '/committees')
api.add_resource(TotalsView, '/committee/<string:id>/totals')
api.add_resource(ReportsView, '/committee/<string:id>/reports')
api.add_resource(NameSearch, '/names')
