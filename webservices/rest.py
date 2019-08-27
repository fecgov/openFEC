"""
A RESTful web service supporting fulltext and field-specific searches on FEC data. For
full documentation visit: https://api.open.fec.gov/developers.
"""

import http
import logging
import os
import sqlalchemy as sa
import flask_cors as cors
import flask_restful as restful
from datetime import datetime, time

from flask import abort
from flask import request
from flask import jsonify
from flask import url_for
from flask import redirect
from flask import render_template
from flask import Flask
from flask import Blueprint
from werkzeug.contrib.fixers import ProxyFix
from webargs.flaskparser import FlaskParser
from flask_apispec import FlaskApiSpec
from webservices import spec
from webservices import exceptions
from webservices import utils
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
from webservices.resources import operations_log
from webservices.env import env
from webservices.tasks.response_exception import ResponseException
from webservices.tasks.error_code import ErrorCode

app = Flask(__name__)
app.url_map.strict_slashes = False


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
    for follower in utils.split_env_var(env.get_credential('SQLA_FOLLOWERS', ''))
    if follower.strip()
]
app.config['PROPAGATE_EXCEPTIONS'] = True

# app.config['SQLALCHEMY_ECHO'] = True

# Modify app configuration and logging level for production
if not app.debug:
    app.logger.addHandler(logging.StreamHandler())
    app.logger.setLevel(logging.INFO)

db.init_app(app)
cors.CORS(app)


class FlaskRestParser(FlaskParser):

    def handle_error(self, error, req, schema, status_code, error_headers):
        message = error.messages
        status_code = getattr(error, 'status_code', 422)
        raise exceptions.ApiError(message, status_code)


parser = FlaskRestParser()
app.config['APISPEC_WEBARGS_PARSER'] = parser
app.config['MAX_CACHE_AGE'] = env.get_credential('FEC_CACHE_AGE')

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
TRUSTED_PROXY_IPS = utils.split_env_var(env.get_credential('TRUSTED_PROXY_IPS', ''))
# Save blocked IPs as a long string, ex. "1.1.1.1, 2.2.2.2, 3.3.3.3"
BLOCKED_IPS = env.get_credential('BLOCKED_IPS', '')
FEC_API_WHITELIST_IPS = env.get_credential('FEC_API_WHITELIST_IPS', False)
# Search this key_id in the API umbrella admin interface to look up the API KEY
DOWNLOAD_WHITELIST_API_KEY_ID = env.get_credential('DOWNLOAD_WHITELIST_API_KEY_ID')
RESTRICT_DOWNLOADS = env.get_credential('RESTRICT_DOWNLOADS')

@app.before_request
def limit_remote_addr():
    """
    If `FEC_API_WHITELIST_IPS` is set:
    - Reject all requests that are not routed through the API Umbrella
    - Block any flagged IPs
    - If we're restricting downloads, only allow requests from whitelisted key
    """
    falses = (False, 'False', 'false', 'f')
    if FEC_API_WHITELIST_IPS not in falses:
        try:
            *_, source_ip, api_data_route, cf_route = request.access_route
        except ValueError:  # Not enough routes
            abort(403)
        else:
            if api_data_route not in TRUSTED_PROXY_IPS:
                abort(403)
            if source_ip in BLOCKED_IPS:
                abort(403)
            if RESTRICT_DOWNLOADS not in falses and '/download/' in request.url:
                # 'X-Api-User-Id' header is passed through by the API umbrella
                request_api_key_id = request.headers.get('X-Api-User-Id')
                if request_api_key_id != DOWNLOAD_WHITELIST_API_KEY_ID:
                    abort(403)


def get_cache_header(url):

    # Time in seconds
    EFILING_CACHE = 0
    LEGAL_CACHE = 60 * 5
    CALENDAR_CACHE = 60 * 5
    DEFAULT_CACHE = 60 * 60

    # cloud.gov time is in UTC (UTC = ET + 4 or 5 hours, depending on DST)
    PEAK_HOURS_START = time(13)  # 9:00 ET + 4 = 13:00 UTC
    PEAK_HOURS_END = time(23, 30)  # 19:30 ET + 4 = 23:30 UTC

    DEFAULT_HEADER_TYPE = 'Cache-Control'
    DEFAULT_HEADER_PREFIX = 'public, max-age='

    if '/efile/' in url:
        return DEFAULT_HEADER_TYPE, '{}{}'.format(DEFAULT_HEADER_PREFIX, EFILING_CACHE)
    elif '/calendar-dates/' in url:
        return DEFAULT_HEADER_TYPE, '{}{}'.format(DEFAULT_HEADER_PREFIX, CALENDAR_CACHE)
    elif '/legal/' in url:
        return DEFAULT_HEADER_TYPE, '{}{}'.format(DEFAULT_HEADER_PREFIX, LEGAL_CACHE)
    # This will work differently in local environment - will use local timezone
    elif (
        '/schedules/' in url and PEAK_HOURS_START <= datetime.now().time() <= PEAK_HOURS_END
    ):
        peak_hours_expiration_time = datetime.combine(
            datetime.now().date(), PEAK_HOURS_END
        ).strftime('%a, %d %b %Y %H:%M:%S GMT')
        return 'Expires', peak_hours_expiration_time

    return DEFAULT_HEADER_TYPE, '{}{}'.format(DEFAULT_HEADER_PREFIX, DEFAULT_CACHE)


@app.after_request
def add_caching_headers(response):

    cache_header_type, cache_header = get_cache_header(request.path)
    response.headers.add(cache_header_type, cache_header)
    return response


@app.after_request
def add_secure_headers(response):
    """Add secure headers to each response"""

    headers = {
        "X-Content-Type-Options": "nosniff",
        "X-Frame-Options": "Deny",
        "X-XSS-Protection": "1; mode=block",
    }
    content_security_policy = {
        "default-src": "'self' data: *.fec.gov *.app.cloud.gov",
        "img-src": "'self' data:",
        "script-src": "'self' 'unsafe-inline'",
        "style-src": "'self' https://fonts.googleapis.com 'unsafe-inline'",
        "font-src": "'self' https://fonts.gstatic.com data:",
        "connect-src": "*.fec.gov *.cloud.gov",
    }
    if env.app.get('space_name', 'local').lower() == 'local':
        content_security_policy["default-src"] += " localhost:* http://127.0.0.1:*"
        content_security_policy["connect-src"] += " localhost:* http://127.0.0.1:*"

    headers["Content-Security-Policy"] = "".join(
        "{0} {1}; ".format(directive, value)
        for directive, value in content_security_policy.items()
    )

    for header, value in headers.items():
        response.headers.add(header, value)
    return response


@app.errorhandler(Exception)
def handle_exception(exception):
    wrapped = ResponseException(str(exception), ErrorCode.INTERNAL_ERROR, type(exception))
    app.logger.error(
        'An API error occurred with the status code of {status} ({exception}).'
        .format(
            status=wrapped.status,
            exception=wrapped.wrappedException
        )
    )
    raise exceptions.ApiError('Could not process the request',
        status_code=http.client.NOT_FOUND)

@app.errorhandler(404)
def page_not_found(exception):
    wrapped = ResponseException(str(exception), exception.code, type(exception))
    return wrapped.wrappedException, wrapped.status

@app.errorhandler(403)
def forbidden(exception):
    wrapped = ResponseException(str(exception), exception.code, type(exception))
    return wrapped.wrappedException, wrapped.status


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
api.add_resource(elections.ElectionsListView, '/elections/search/')
api.add_resource(elections.ElectionSummary, '/elections/summary/')
api.add_resource(elections.StateElectionOfficeInfoView, '/state-election-office/')
api.add_resource(dates.ElectionDatesView, '/election-dates/')
api.add_resource(dates.ReportingDatesView, '/reporting-dates/')
api.add_resource(dates.CalendarDatesView, '/calendar-dates/')
api.add_resource(dates.CalendarDatesExport, '/calendar-dates/export/')
api.add_resource(rad_analyst.RadAnalystView, '/rad-analyst/')
api.add_resource(filings.EFilingsView, '/efile/filings/')
api.add_resource(large_aggregates.EntityReceiptDisbursementTotalsView, '/totals/by_entity/')
api.add_resource(audit.AuditPrimaryCategoryView, '/audit-primary-category/')
api.add_resource(audit.AuditCategoryView, '/audit-category/')
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
api.add_resource(candidate_aggregates.ScheduleAByStateCandidateTotalsView,
                 '/schedules/schedule_a/by_state/by_candidate/totals/')

api.add_resource(candidate_aggregates.TotalsCandidateView, '/candidates/totals/')
api.add_resource(totals.ScheduleAByStateRecipientTotalsView, '/schedules/schedule_a/by_state/totals/')
api.add_resource(candidate_aggregates.AggregateByOfficeView, '/candidates/totals/by_office/')
api.add_resource(candidate_aggregates.AggregateByOfficeByPartyView, '/candidates/totals/by_office/by_party/')

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
    reports.EFilingHouseSenateSummaryView,
    '/efile/reports/house-senate/',
)

api.add_resource(
    reports.EFilingPresidentialSummaryView,
    '/efile/reports/presidential/',
)

api.add_resource(
    reports.EFilingPacPartySummaryView,
    '/efile/reports/pac-party/',
)

api.add_resource(filings.FilingsList, '/filings/')

api.add_resource(download.DownloadView, '/download/<path:path>/')

api.add_resource(legal.UniversalSearch, '/legal/search/')
api.add_resource(legal.GetLegalCitation, '/legal/citation/<citation_type>/<citation>')
api.add_resource(legal.GetLegalDocument, '/legal/docs/<doc_type>/<no>')
api.add_resource(operations_log.OperationsLogView, '/operations-log/')

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
apidoc.register(reports.EFilingHouseSenateSummaryView, blueprint='v1')
apidoc.register(reports.EFilingPresidentialSummaryView, blueprint='v1')
apidoc.register(reports.EFilingPacPartySummaryView, blueprint='v1')
apidoc.register(totals.TotalsView, blueprint='v1')
apidoc.register(totals.CandidateTotalsView, blueprint='v1')
apidoc.register(totals.TotalsCommitteeView, blueprint='v1')
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
apidoc.register(candidate_aggregates.ScheduleAByStateCandidateTotalsView, blueprint='v1')
apidoc.register(candidate_aggregates.TotalsCandidateView, blueprint='v1')
apidoc.register(filings.FilingsView, blueprint='v1')
apidoc.register(filings.FilingsList, blueprint='v1')
apidoc.register(elections.ElectionsListView, blueprint='v1')
apidoc.register(elections.ElectionView, blueprint='v1')
apidoc.register(elections.ElectionSummary, blueprint='v1')
apidoc.register(elections.StateElectionOfficeInfoView, blueprint='v1')
apidoc.register(dates.ReportingDatesView, blueprint='v1')
apidoc.register(dates.ElectionDatesView, blueprint='v1')
apidoc.register(dates.CalendarDatesView, blueprint='v1')
apidoc.register(dates.CalendarDatesExport, blueprint='v1')
apidoc.register(rad_analyst.RadAnalystView, blueprint='v1')
apidoc.register(filings.EFilingsView, blueprint='v1')
apidoc.register(large_aggregates.EntityReceiptDisbursementTotalsView, blueprint='v1')
apidoc.register(totals.ScheduleAByStateRecipientTotalsView, blueprint='v1')
apidoc.register(audit.AuditPrimaryCategoryView, blueprint='v1')
apidoc.register(audit.AuditCategoryView, blueprint='v1')
apidoc.register(audit.AuditCaseView, blueprint='v1')
apidoc.register(audit.AuditCandidateNameSearch, blueprint='v1')
apidoc.register(audit.AuditCommitteeNameSearch, blueprint='v1')
apidoc.register(operations_log.OperationsLogView, blueprint='v1')
apidoc.register(legal.UniversalSearch, blueprint='v1')
apidoc.register(candidate_aggregates.AggregateByOfficeView, blueprint='v1')
apidoc.register(candidate_aggregates.AggregateByOfficeByPartyView, blueprint='v1')

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
