"""
A RESTful web service supporting fulltext and field-specific searches on FEC data. For
full documentation visit: https://api.open.fec.gov/developers.
"""
from webservices.env import env

def initialize_newrelic():
    license_key = env.get_credential('NEW_RELIC_LICENSE_KEY')
    if license_key:
        import newrelic.agent
        settings = newrelic.agent.global_settings()
        settings.license_key = license_key
        newrelic.agent.initialize()

initialize_newrelic()

import os
import http
import logging
import json
import boto

from flask import abort
from flask import request
from flask import jsonify
from flask import url_for
from flask import redirect
from flask import render_template
from flask import Flask
from flask import Blueprint

import flask_cors as cors
import flask_restful as restful

from werkzeug.contrib.fixers import ProxyFix
import sqlalchemy as sa

from webargs.flaskparser import FlaskParser
from flask_apispec import FlaskApiSpec

from webservices import spec
from webservices import exceptions
from webservices.common import util
from webservices.common.models import db
from webservices.resources import totals
from webservices.resources import reports
from webservices.resources import sched_a
from webservices.resources import sched_b
from webservices.resources import sched_c
from webservices.resources import sched_d
from webservices.resources import sched_e
from webservices.resources import sched_f
from webservices.resources import download
from webservices.resources import aggregates
from webservices.resources import candidate_aggregates
from webservices.resources import candidates
from webservices.resources import committees
from webservices.resources import elections
from webservices.resources import filings
from webservices.resources import rad_analyst
from webservices.resources import search
from webservices.resources import dates
from webservices.resources import costs
from webservices.resources import legal
from webservices.resources import large_aggregates
from webservices.resources import audit
from webservices.env import env
from webservices.tasks import utils

from webservices.tasks.response_exception import ResponseException
from webservices.tasks.json_response import JsonResponse
from webservices.tasks.error_code import ErrorCode

from smart_open import smart_open

app = Flask(__name__)
logger = logging.getLogger('rest.py')

def sqla_conn_string():
    sqla_conn_string = env.get_credential('SQLA_CONN')
    if not sqla_conn_string:
        print("Environment variable SQLA_CONN is empty; running against " + "local `cfdm_test`")
        sqla_conn_string = 'postgresql://:@/cfdm_test'
    return sqla_conn_string

# app.debug = True
app.config['SQLALCHEMY_DATABASE_URI'] = sqla_conn_string()
app.config['APISPEC_FORMAT_RESPONSE'] = None
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_POOL_SIZE'] = 50
app.config['SQLALCHEMY_MAX_OVERFLOW'] = 50
app.config['SQLALCHEMY_POOL_TIMEOUT'] = 120
app.config['SQLALCHEMY_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS'] = bool(
    env.get_credential('SQLA_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS', '')
)
app.config['SQLALCHEMY_FOLLOWER_TASKS'] = [
    'webservices.tasks.download.export_query',
]
app.config['SQLALCHEMY_FOLLOWERS'] = [
    sa.create_engine(follower.strip())
    for follower in env.get_credential('SQLA_FOLLOWERS', '').split(',')
    if follower.strip()
]
# app.config['SQLALCHEMY_ECHO'] = True

# Modify app configuration and logging level for production
if not app.debug:
    app.logger.addHandler(logging.StreamHandler())
    app.logger.setLevel(logging.INFO)

db.init_app(app)
cors.CORS(app)

class FlaskRestParser(FlaskParser):

    def handle_error(self, error):
        message = error.messages
        status_code = getattr(error, 'status_code', 422)
        raise exceptions.ApiError(message, status_code)

parser = FlaskRestParser()
app.config['APISPEC_WEBARGS_PARSER'] = parser

v1 = Blueprint('v1', __name__, url_prefix='/v1')
api = restful.Api(v1)

# Encode using ujson for speed and decimal encoding
api.representations['application/json'] = util.output_json

app.register_blueprint(v1)


@app.errorhandler(exceptions.ApiError)
def handle_error(error):
    response = jsonify(error.to_dict())
    response.status_code = error.status_code
    return response


# api.data.gov
trusted_proxies = ('54.208.160.112', '54.208.160.151')
FEC_API_WHITELIST_IPS = env.get_credential('FEC_API_WHITELIST_IPS', False)


@app.before_request
def limit_remote_addr():
    """If `FEC_API_WHITELIST_IPS` is set, reject all requests that are not
    routed through the API Umbrella.
    """
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
def add_caching_headers(response):
    max_age = env.get_credential('FEC_CACHE_AGE')
    cache_all_requests = env.get_credential('CACHE_ALL_REQUESTS', False)
    status_code = response.status_code

    if max_age is not None:
        response.headers.add('Cache-Control', 'public, max-age={}'.format(max_age))

    if (cache_all_requests and status_code == 200):
        try:
            # convert the results to JSON
            json_data = utils.get_json_data(response)
            # format the URL by removing the api_key and special characters
            formatted_url = utils.format_url(request.url)
            # get s3 bucket env variables
            s3_bucket = utils.get_bucket()
            cached_url = "s3://{0}/cached-calls/{1}.json".format(s3_bucket.name, formatted_url)
            s3_key = utils.get_s3_key(cached_url)

            # upload the request_content.json file to s3 bucket
            # TODO:  Figure out why the s3_key object is not working with the
            #        smart_open call, when it does for downloads (and verify
            #        that downloads are indeed still working too).
            with smart_open(cached_url, 'w') as cached_file:
                cached_file.write(json_data)

            logger.info(
                'The following request has been cached and uploaded successfully: {}'.format(
                    cached_url
                )
            )
        except:
            logger.error('Cache Upload failed.')

    return response


@app.errorhandler(Exception)
def handle_exception(exception):
    wrapped = ResponseException(str(exception), ErrorCode.INTERNAL_ERROR, type(exception))
    # TODO : add a log statement using JsonResponse.error(wrapped, wrapped.status)
    logger.info("In handle_exception(), received error_code : %s , ", wrapped.status)
    if wrapped.status in [500, 502, 503, 504]:
        formatted_url = utils.format_url(request.url)
        # get s3 bucket env variables
        s3_bucket = utils.get_bucket()
        # TODO : create a variable and assing the region to it
        # create the URL to check if it already cached and saved on s3(call the format_utils)
        # return cache response if exists
        cached_url = "http://s3-us-gov-west-1.amazonaws.com/{0}/cached-calls/{1}.json".format(s3_bucket.name, formatted_url)
        cached_data = utils.get_cached_request(s3_bucket, cached_url)
        if cached_data is not None:
            return cached_data
        return ErrorCode.INTERNAL_ERROR
    return ErrorCode.INTERNAL_ERROR

api.add_resource(candidates.CandidateList, '/candidates/')
api.add_resource(candidates.CandidateSearch, '/candidates/search/')
api.add_resource(
    candidates.CandidateView,
    '/candidate/<string:candidate_id>/',
    '/committee/<string:committee_id>/candidates/',
)
api.add_resource(
    candidates.CandidateHistoryView,
    '/candidate/<string:candidate_id>/history/',
    '/candidate/<string:candidate_id>/history/<int:cycle>/',
    '/committee/<string:committee_id>/candidates/history/',
    '/committee/<string:committee_id>/candidates/history/<int:cycle>/',
)
api.add_resource(committees.CommitteeList, '/committees/')
api.add_resource(
    committees.CommitteeView,
    '/committee/<string:committee_id>/',
    '/candidate/<string:candidate_id>/committees/',
)
api.add_resource(
    committees.CommitteeHistoryView,
    '/committee/<string:committee_id>/history/',
    '/committee/<string:committee_id>/history/<int:cycle>/',
    '/candidate/<candidate_id>/committees/history/',
    '/candidate/<candidate_id>/committees/history/<int:cycle>/',
)
api.add_resource(totals.TotalsView, '/totals/<string:committee_type>/')
api.add_resource(totals.TotalsCommitteeView, '/committee/<string:committee_id>/totals/')
api.add_resource(totals.CandidateTotalsView, '/candidate/<string:candidate_id>/totals/')
api.add_resource(reports.ReportsView, '/reports/<string:committee_type>/')
api.add_resource(reports.CommitteeReportsView, '/committee/<string:committee_id>/reports/')
api.add_resource(search.CandidateNameSearch, '/names/candidates/')
api.add_resource(search.CommitteeNameSearch, '/names/committees/')
api.add_resource(sched_a.ScheduleAView, '/schedules/schedule_a/', '/schedules/schedule_a/<string:sub_id>/')
api.add_resource(sched_a.ScheduleAEfileView, '/schedules/schedule_a/efile/')
api.add_resource(sched_b.ScheduleBView, '/schedules/schedule_b/', '/schedules/schedule_b/<string:sub_id>/')
api.add_resource(sched_b.ScheduleBEfileView, '/schedules/schedule_b/efile/')
api.add_resource(sched_c.ScheduleCView, '/schedules/schedule_c/')
api.add_resource(sched_c.ScheduleCViewBySubId, '/schedules/schedule_c/<string:sub_id>/')
api.add_resource(sched_d.ScheduleDView, '/schedules/schedule_d/')
api.add_resource(sched_d.ScheduleDViewBySubId, '/schedules/schedule_d/<string:sub_id>/')
api.add_resource(sched_e.ScheduleEView, '/schedules/schedule_e/')
api.add_resource(sched_e.ScheduleEEfileView, '/schedules/schedule_e/efile/')
api.add_resource(sched_f.ScheduleFView, '/schedules/schedule_f/', '/schedules/schedule_f/<string:sub_id>/')
api.add_resource(sched_f.ScheduleFViewBySubId, '/schedules/schedule_f/<string:sub_id>/')
api.add_resource(costs.CommunicationCostView, '/communication-costs/')
api.add_resource(costs.ElectioneeringView, '/electioneering/')
api.add_resource(elections.ElectionView, '/elections/')
api.add_resource(elections.ElectionList, '/elections/search/')
api.add_resource(elections.ElectionSummary, '/elections/summary/')
api.add_resource(dates.ElectionDatesView, '/election-dates/')
api.add_resource(dates.ReportingDatesView, '/reporting-dates/')
api.add_resource(dates.CalendarDatesView, '/calendar-dates/')
api.add_resource(dates.CalendarDatesExport, '/calendar-dates/export/')
api.add_resource(rad_analyst.RadAnalystView, '/rad-analyst/')
api.add_resource(filings.EFilingsView, '/efile/filings/')
api.add_resource(large_aggregates.EntityReceiptDisbursementTotalsView, '/totals/by_entity/')
api.add_resource(audit.PrimaryCategory, '/audit-primary-category/')
api.add_resource(audit.Category, '/audit-category/')
api.add_resource(audit.AuditCaseView, '/audit-case/')
api.add_resource(audit.AuditCandidateNameSearch, '/names/audit_candidates/')
api.add_resource(audit.AuditCommitteeNameSearch, '/names/audit_committees/')

def add_aggregate_resource(api, view, schedule, label):
    api.add_resource(
        view,
        '/schedules/schedule_{schedule}/by_{label}/'.format(**locals()),
        '/committee/<committee_id>/schedules/schedule_{schedule}/by_{label}/'.format(**locals()),
    )

add_aggregate_resource(api, aggregates.ScheduleABySizeView, 'a', 'size')
add_aggregate_resource(api, aggregates.ScheduleAByStateView, 'a', 'state')
add_aggregate_resource(api, aggregates.ScheduleAByZipView, 'a', 'zip')
add_aggregate_resource(api, aggregates.ScheduleAByEmployerView, 'a', 'employer')
add_aggregate_resource(api, aggregates.ScheduleAByOccupationView, 'a', 'occupation')

add_aggregate_resource(api, aggregates.ScheduleBByRecipientView, 'b', 'recipient')
add_aggregate_resource(api, aggregates.ScheduleBByRecipientIDView, 'b', 'recipient_id')
add_aggregate_resource(api, aggregates.ScheduleBByPurposeView, 'b', 'purpose')

add_aggregate_resource(api, aggregates.ScheduleEByCandidateView, 'e', 'candidate')

api.add_resource(candidate_aggregates.ScheduleABySizeCandidateView, '/schedules/schedule_a/by_size/by_candidate/')
api.add_resource(candidate_aggregates.ScheduleAByStateCandidateView, '/schedules/schedule_a/by_state/by_candidate/')

api.add_resource(candidate_aggregates.TotalsCandidateView, '/candidates/totals/')
api.add_resource(committees.TotalsCommitteeHistoryView, '/committees/totals/')
api.add_resource(totals.ScheduleAByStateRecipientTotalsView, '/schedules/schedule_a/by_state/totals/')

api.add_resource(
    aggregates.CommunicationCostByCandidateView,
    '/communication_costs/by_candidate/',
    '/committee/<string:committee_id>/communication_costs/by_candidate/',
)
api.add_resource(
    aggregates.ElectioneeringByCandidateView,
    '/electioneering/by_candidate/',
    '/committee/<string:committee_id>/electioneering/by_candidate/',
)

api.add_resource(
    filings.FilingsView,
    '/committee/<committee_id>/filings/',
    '/candidate/<candidate_id>/filings/',
)

api.add_resource(
    reports.EFilingSummaryView,
    '/efile/reports/<string:committee_type>/',
)

api.add_resource(filings.FilingsList, '/filings/')

api.add_resource(download.DownloadView, '/download/<path:path>/')

api.add_resource(legal.UniversalSearch, '/legal/search/')
api.add_resource(legal.GetLegalCitation, '/legal/citation/<citation_type>/<citation>')
api.add_resource(legal.GetLegalDocument, '/legal/docs/<doc_type>/<no>')

app.config.update({
    'APISPEC_SWAGGER_URL': None,
    'APISPEC_SWAGGER_UI_URL': None,
    'APISPEC_SPEC': spec.spec,
})
apidoc = FlaskApiSpec(app)

apidoc.register(search.CandidateNameSearch, blueprint='v1')
apidoc.register(search.CommitteeNameSearch, blueprint='v1')
apidoc.register(candidates.CandidateView, blueprint='v1')
apidoc.register(candidates.CandidateList, blueprint='v1')
apidoc.register(candidates.CandidateSearch, blueprint='v1')
apidoc.register(candidates.CandidateHistoryView, blueprint='v1')
apidoc.register(committees.CommitteeView, blueprint='v1')
apidoc.register(committees.CommitteeList, blueprint='v1')
apidoc.register(committees.CommitteeHistoryView, blueprint='v1')
apidoc.register(reports.ReportsView, blueprint='v1')
apidoc.register(reports.CommitteeReportsView, blueprint='v1')
apidoc.register(reports.EFilingSummaryView, blueprint='v1')
apidoc.register(totals.TotalsView, blueprint='v1')
apidoc.register(totals.CandidateTotalsView, blueprint='v1')
apidoc.register(sched_a.ScheduleAView, blueprint='v1')
apidoc.register(sched_a.ScheduleAEfileView, blueprint='v1')
apidoc.register(sched_b.ScheduleBView, blueprint='v1')
apidoc.register(sched_b.ScheduleBEfileView, blueprint='v1')
apidoc.register(sched_c.ScheduleCView, blueprint='v1')
apidoc.register(sched_c.ScheduleCViewBySubId, blueprint='v1')
apidoc.register(sched_e.ScheduleEView, blueprint='v1')
apidoc.register(sched_e.ScheduleEEfileView, blueprint='v1')
apidoc.register(sched_f.ScheduleFView, blueprint='v1')
apidoc.register(sched_f.ScheduleFViewBySubId, blueprint='v1')
apidoc.register(sched_d.ScheduleDView, blueprint='v1')
apidoc.register(sched_d.ScheduleDViewBySubId, blueprint='v1')
apidoc.register(costs.CommunicationCostView, blueprint='v1')
apidoc.register(costs.ElectioneeringView, blueprint='v1')
apidoc.register(aggregates.ScheduleABySizeView, blueprint='v1')
apidoc.register(aggregates.ScheduleAByStateView, blueprint='v1')
apidoc.register(aggregates.ScheduleAByZipView, blueprint='v1')
apidoc.register(aggregates.ScheduleAByEmployerView, blueprint='v1')
apidoc.register(aggregates.ScheduleAByOccupationView, blueprint='v1')
apidoc.register(aggregates.ScheduleBByRecipientView, blueprint='v1')
apidoc.register(aggregates.ScheduleBByRecipientIDView, blueprint='v1')
apidoc.register(aggregates.ScheduleBByPurposeView, blueprint='v1')
apidoc.register(aggregates.ScheduleEByCandidateView, blueprint='v1')
apidoc.register(aggregates.CommunicationCostByCandidateView, blueprint='v1')
apidoc.register(aggregates.ElectioneeringByCandidateView, blueprint='v1')
apidoc.register(candidate_aggregates.ScheduleABySizeCandidateView, blueprint='v1')
apidoc.register(candidate_aggregates.ScheduleAByStateCandidateView, blueprint='v1')
apidoc.register(candidate_aggregates.TotalsCandidateView, blueprint='v1')
apidoc.register(filings.FilingsView, blueprint='v1')
apidoc.register(filings.FilingsList, blueprint='v1')
apidoc.register(elections.ElectionList, blueprint='v1')
apidoc.register(elections.ElectionView, blueprint='v1')
apidoc.register(elections.ElectionSummary, blueprint='v1')
apidoc.register(dates.ReportingDatesView, blueprint='v1')
apidoc.register(dates.ElectionDatesView, blueprint='v1')
apidoc.register(dates.CalendarDatesView, blueprint='v1')
apidoc.register(dates.CalendarDatesExport, blueprint='v1')
apidoc.register(rad_analyst.RadAnalystView, blueprint='v1')
apidoc.register(filings.EFilingsView, blueprint='v1')
apidoc.register(large_aggregates.EntityReceiptDisbursementTotalsView, blueprint='v1')
apidoc.register(totals.ScheduleAByStateRecipientTotalsView, blueprint='v1')
apidoc.register(audit.PrimaryCategory, blueprint='v1')
apidoc.register(audit.Category, blueprint='v1')
apidoc.register(audit.AuditCaseView, blueprint='v1')
apidoc.register(audit.AuditCandidateNameSearch, blueprint='v1')
apidoc.register(audit.AuditCommitteeNameSearch, blueprint='v1')

# Adapted from https://github.com/noirbizarre/flask-restplus
here, _ = os.path.split(__file__)
docs = Blueprint(
    'docs',
    __name__,
    static_folder=os.path.join(here, os.pardir, 'static', 'swagger-ui'),
    static_url_path='/docs/static',
)


@docs.route('/swagger/')
def api_spec():
    return jsonify(spec.spec.to_dict())


@docs.add_app_template_global
def swagger_static(filename):
    return url_for('docs.static', filename=filename)


@app.route('/')
@app.route('/v1/')
@app.route('/docs/')
@docs.route('/developer/')
def api_ui_redirect():
    return redirect(url_for('docs.api_ui'), code=http.client.MOVED_PERMANENTLY)


@docs.route('/developers/')
def api_ui():
    return render_template(
        'swagger-ui.html',
        specs_url=url_for('docs.api_spec'),
        PRODUCTION=env.get_credential('PRODUCTION'),
    )


app.register_blueprint(docs)

app.wsgi_app = ProxyFix(app.wsgi_app)
