"""
A RESTful web service supporting fulltext and field-specific searches on FEC data. For
full documentation visit: https://api.open.fec.gov/developers.
"""

import http
import logging
import os

from marshmallow import EXCLUDE
import ujson
import sqlalchemy as sa
import flask_cors as cors
from nplusone.ext.flask_sqlalchemy import NPlusOne

from datetime import datetime, time
from flask import abort
from flask import request
from flask import jsonify
from flask import url_for
from flask import redirect
from flask import render_template
from flask import send_from_directory
from flask import Flask
from flask import Blueprint
from werkzeug.middleware.proxy_fix import ProxyFix
from webargs.flaskparser import FlaskParser
from flask_apispec import FlaskApiSpec
from webservices import spec
from webservices import exceptions
from webservices import utils
from webservices.common import util
from webservices.common import models
from webservices.common.models import db
from webservices.resources import national_party
from webservices.resources import totals
from webservices.resources import reports
from webservices.resources import sched_a
from webservices.resources import sched_b
from webservices.resources import sched_c
from webservices.resources import sched_d
from webservices.resources import sched_e
from webservices.resources import sched_f
from webservices.resources import sched_h4
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
from webservices.resources import presidential
from webservices.resources import spending_by_others
from webservices.env import env
from webservices.tasks.celery import celery_init_app
from webservices.tasks.response_exception import ResponseException
from webservices.tasks.error_code import ErrorCode
from webservices.api_setup import api, v1
from celery import signals


# Variables NTC
TRUSTED_PROXY_IPS = utils.split_env_var(env.get_credential('FEC_API_TRUSTED_PROXY_IPS', ''))
# Save blocked IPs as a long string, ex. "1.1.1.1, 2.2.2.2, 3.3.3.3"
BLOCKED_IPS = env.get_credential('FEC_API_BLOCKED_IPS', '')
USE_PROXY = env.get_credential('FEC_API_USE_PROXY', False)
# Search these key_id's in the API umbrella admin interface to look up the API KEY
DOWNLOAD_KEY_ID = env.get_credential('FEC_API_DOWNLOAD_KEY_ID')
BYPASS_RESTRICTION_API_KEY_IDS = env.get_credential('FEC_API_BYPASS_RESTRICTION_API_KEY_IDS')
# Settings to restrict traffic to certain API keys - only work with API umbrella
RESTRICT_DOWNLOADS = env.get_credential('FEC_API_RESTRICT_DOWNLOADS', False)
RESTRICT_TRAFFIC = env.get_credential('FEC_API_RESTRICT_TRAFFIC', False)
RESTRICT_MESSAGE = "We apologize for the inconvenience, but we are temporarily " \
    "blocking API traffic. Please contact apiinfo@fec.gov if this is an urgent issue."
SHOW_TEST_F1 = env.get_credential('FEC_SHOW_TEST_F1', False)


def sqla_conn_string():
    sqla_conn_string = env.get_credential('SQLA_CONN')
    if not sqla_conn_string:
        print("Environment variable SQLA_CONN is empty; running against " + "local `cfdm_test`")
        sqla_conn_string = 'postgresql://:@/cfdm_test'
    return sqla_conn_string


class FlaskRestParser(FlaskParser):
    DEFAULT_UNKNOWN_BY_LOCATION = {"query": EXCLUDE}

    def handle_error(self, error, req, schema, *, error_status_code, error_headers):
        message = error.messages
        status_code = getattr(error, 'status_code', 422)
        raise exceptions.ApiError(message, status_code)


parser = FlaskRestParser()


def create_app(test_config=None):
    app = Flask(__name__)
    app.url_map.strict_slashes = False
    # app.debug = True
    app.config['APISPEC_FORMAT_RESPONSE'] = None
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['SQLALCHEMY_POOL_SIZE'] = 50
    app.config['SQLALCHEMY_MAX_OVERFLOW'] = 50
    app.config['SQLALCHEMY_POOL_TIMEOUT'] = 120
    app.config['SQLALCHEMY_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS'] = bool(
        env.get_credential('SQLA_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS', ''))
    app.config['SQLALCHEMY_FOLLOWER_TASKS'] = [
        'webservices.tasks.download.export_query',]
    app.config['PROPAGATE_EXCEPTIONS'] = True
    # app.config['SQLALCHEMY_ECHO'] = True

    # Modify app configuration and logging level for production
    if not app.debug:
        app.logger.addHandler(logging.StreamHandler())
        app.logger.setLevel(logging.INFO)

    if test_config is None:
        app.config['SQLALCHEMY_DATABASE_URI'] = sqla_conn_string()
        app.config['SQLALCHEMY_FOLLOWERS'] = [sa.create_engine(follower.strip())
                                              for follower in utils.split_env_var(
                                              env.get_credential('SQLA_FOLLOWERS', ''))
                                              if follower.strip()]
        app.config['PRESERVE_CONTEXT_ON_EXCEPTION'] = False

    else:
        TEST_CONN = os.getenv('SQLA_TEST_CONN', 'postgresql:///cfdm_unit_test')
        """ app.config['SQLALCHEMY_FOLLOWERS'] = [sa.create_engine(follower.strip())
                                              for follower in utils.split_env_var(
                                              env.get_credential('SQLA_FOLLOWERS', ''))
                                              if follower.strip()] """
        app.config['NPLUSONE_RAISE'] = True
        app.config['SQLALCHEMY_DATABASE_URI'] = TEST_CONN
        app.config['PRESERVE_CONTEXT_ON_EXCEPTION'] = False
        app.config['TESTING'] = True

    # Initialize Extensions
    db.init_app(app)
    cors.CORS(app)
    api.init_app(app)
    NPlusOne(app)

    def redis_url():
        """
        Retrieve the URL needed to connect to a Redis instance, depending on environment.
        When running in a cloud.gov environment, retrieve the uri credential for the 'aws-elasticache-redis' service.
        """
        # Is the app running in a cloud.gov environment
        if env.space is not None:
            redis_env = env.get_service(label="aws-elasticache-redis")
            redis_url = redis_env.credentials.get("uri")

            return redis_url

        return env.get_credential("FEC_REDIS_URL", "redis://localhost:6379/0")

    app.config.from_mapping(
        CELERY=dict(
            broker_url=redis_url(),
            result_backend=None,  # may need to set
            task_ignore_result=True,  # may need to unset
        ),
    )
    context = {}

    @signals.task_prerun.connect
    def push_context(task_id, task, *args, **kwargs):
        context[task_id] = app.app_context()
        context[task_id].push()

    @signals.task_postrun.connect
    def pop_context(task_id, task, *args, **kwargs):
        if task_id in context:
            context[task_id].pop()
            context.pop(task_id)

    app.config.from_prefixed_env()
    celery_init_app(app)

    # Register Blueprints
    app.register_blueprint(v1)
    app.config.update({
        'APISPEC_SWAGGER_URL': None,
        'APISPEC_SWAGGER_UI_URL': None,
        'APISPEC_SPEC': spec.spec,
        })
    apidoc = FlaskApiSpec(app)

    apidoc.register(national_party.NationalParty_ScheduleAView, blueprint='v1')
    apidoc.register(national_party.NationalParty_ScheduleBView, blueprint='v1')
    apidoc.register(national_party.NationalPartyTotalsView, blueprint='v1')
    apidoc.register(search.CandidateNameSearch, blueprint='v1')
    apidoc.register(search.CommitteeNameSearch, blueprint='v1')
    apidoc.register(candidates.CandidateView, blueprint='v1')
    apidoc.register(candidates.CandidateList, blueprint='v1')
    apidoc.register(candidates.CandidateSearch, blueprint='v1')
    apidoc.register(candidates.CandidateHistoryView, blueprint='v1')
    apidoc.register(committees.CommitteeView, blueprint='v1')
    apidoc.register(committees.CommitteeList, blueprint='v1')
    apidoc.register(committees.CommitteeHistoryProfileView, blueprint='v1')
    apidoc.register(reports.ReportsView, blueprint='v1')
    apidoc.register(reports.CommitteeReportsView, blueprint='v1')
    apidoc.register(reports.EFilingHouseSenateSummaryView, blueprint='v1')
    apidoc.register(reports.EFilingPresidentialSummaryView, blueprint='v1')
    apidoc.register(reports.EFilingPacPartySummaryView, blueprint='v1')
    apidoc.register(totals.TotalsByEntityTypeView, blueprint='v1')
    apidoc.register(totals.CandidateTotalsDetailView, blueprint='v1')
    apidoc.register(totals.TotalsCommitteeView, blueprint='v1')
    apidoc.register(totals.InauguralDonationsView, blueprint='v1')
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
    apidoc.register(sched_h4.ScheduleH4View, blueprint='v1')
    apidoc.register(sched_h4.ScheduleH4EfileView, blueprint='v1')
    apidoc.register(costs.CommunicationCostView, blueprint='v1')
    apidoc.register(aggregates.CCAggregatesView, blueprint='v1')
    apidoc.register(costs.ElectioneeringView, blueprint='v1')
    apidoc.register(aggregates.ECAggregatesView, blueprint='v1')
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
    apidoc.register(filings.F2EFilingsView, blueprint='v1')
    apidoc.register(filings.F1EFilingsView, blueprint='v1')
    apidoc.register(large_aggregates.EntityReceiptDisbursementTotalsView, blueprint='v1')
    apidoc.register(totals.ScheduleAByStateRecipientTotalsView, blueprint='v1')
    apidoc.register(audit.AuditPrimaryCategoryView, blueprint='v1')
    apidoc.register(audit.AuditCategoryView, blueprint='v1')
    apidoc.register(audit.AuditCaseView, blueprint='v1')
    apidoc.register(audit.AuditCandidateNameSearch, blueprint='v1')
    apidoc.register(audit.AuditCommitteeNameSearch, blueprint='v1')
    apidoc.register(operations_log.OperationsLogView, blueprint='v1')
    apidoc.register(legal.UniversalSearch, blueprint='v1')
    apidoc.register(legal.GetLegalDocument, blueprint='v1')
    apidoc.register(candidate_aggregates.CandidateTotalAggregateView, blueprint='v1')
    apidoc.register(spending_by_others.ECTotalsByCandidateView, blueprint='v1')
    apidoc.register(spending_by_others.IETotalsByCandidateView, blueprint='v1')
    apidoc.register(spending_by_others.CCTotalsByCandidateView, blueprint='v1')
    # feature flag to publish endpoint
    # when turning this on, uncomment from spec.py
    if bool(env.get_credential('FEC_FEATURE_PRESIDENTIAL', '')):
        apidoc.register(presidential.PresidentialByCandidateView, blueprint='v1')
        apidoc.register(presidential.PresidentialSummaryView, blueprint='v1')
        apidoc.register(presidential.PresidentialBySizeView, blueprint='v1')
        apidoc.register(presidential.PresidentialByStateView, blueprint='v1')
        apidoc.register(presidential.PresidentialCoverageView, blueprint='v1')
    if SHOW_TEST_F1:
        apidoc.register(filings.TestF1EFilingsView, blueprint='v1')

    # Adapted from https://github.com/noirbizarre/flask-restplus
    here, _ = os.path.split(__file__)
    docs = Blueprint(
        'docs',
        __name__,
        static_folder=os.path.join(here, os.pardir, 'static', 'swagger-ui'),
        static_url_path='/docs/static',
    )

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
            api_key_signup_key=env.get_credential('API_UMBRELLA_SIGNUP_KEY'),
        )

    @docs.route('/swagger/')
    def api_spec():
        return jsonify(spec.spec.to_dict())

    app.register_blueprint(docs)
    app.app_context().push()

    parser = FlaskRestParser()
    app.config['APISPEC_WEBARGS_PARSER'] = parser
    app.config['MAX_CACHE_AGE'] = env.get_credential('FEC_CACHE_AGE')

    @app.errorhandler(exceptions.ApiError)
    def handle_error(error):
        response = jsonify(error.to_dict())
        response.status_code = error.status_code
        return response

    @app.before_request
    def limit_remote_addr():
        """
        If `FEC_API_USE_PROXY` is set:
        - Reject all requests that are not routed through the API Umbrella
        - Block any flagged IPs
        - If we're restricting downloads, only allow requests from specified key
        """
        true_values = (True, 'True', 'true', 't')
        if USE_PROXY in true_values:
            try:
                *_, source_ip, api_data_route, cf_route = request.access_route
            except ValueError:  # Not enough routes
                abort(403)
            else:
                if api_data_route not in TRUSTED_PROXY_IPS:
                    abort(403)
                if source_ip in BLOCKED_IPS:
                    abort(503, RESTRICT_MESSAGE)
                if RESTRICT_DOWNLOADS in true_values and '/download/' in request.url:
                    # 'X-Api-User-Id' header is passed through by the API umbrella
                    request_api_key_id = request.headers.get('X-Api-User-Id')
                    if request_api_key_id != DOWNLOAD_KEY_ID:
                        abort(403)
                # We don't want to accidentally block downloads here, handled above
                elif RESTRICT_TRAFFIC in true_values and '/v1/' in request.url:
                    request_api_key_id = request.headers.get('X-Api-User-Id')
                    if request_api_key_id not in BYPASS_RESTRICTION_API_KEY_IDS:
                        # Service unavailable
                        abort(503, RESTRICT_MESSAGE)

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

        LONG_CACHE_ENDPOINTS = ['/totals', '/schedules/']

        if '/efile/' in url:
            return DEFAULT_HEADER_TYPE, '{}{}'.format(DEFAULT_HEADER_PREFIX, EFILING_CACHE)
        if '/calendar-dates/' in url:
            return DEFAULT_HEADER_TYPE, '{}{}'.format(DEFAULT_HEADER_PREFIX, CALENDAR_CACHE)
        if '/legal/' in url:
            return DEFAULT_HEADER_TYPE, '{}{}'.format(DEFAULT_HEADER_PREFIX, LEGAL_CACHE)

        # This will work differently in local environment - will use local timezone
        for endpoint in LONG_CACHE_ENDPOINTS:
            if endpoint in url and PEAK_HOURS_START <= datetime.now().time() <= PEAK_HOURS_END:
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
        """
        Add secure headers to each response.
        The 'unsafe-inline' Content Security Policy (CSP) setting is
        needed for Swagger docs (see https://github.com/swagger-api/swagger-ui/issues/3370)
        """

        headers = {
            "X-Content-Type-Options": "nosniff",
            "X-Frame-Options": "Deny",
            "X-XSS-Protection": "1; mode=block",
        }
        content_security_policy = {
            "default-src": "'self' *.fec.gov *.app.cloud.gov",
            "connect-src": "*.fec.gov *.cloud.gov https://api.data.gov https://www.google-analytics.com",
            "font-src": "'self' https://fonts.gstatic.com data: https://api.data.gov",
            "frame-src": "'self' *.fec.gov *.app.cloud.gov https://www.google.com/recaptcha/ \
                https://recaptcha.google.com/recaptcha/",
            "img-src": "'self' data:",
            "object-src": "'none'",
            "script-src": "'self' https://api.data.gov https://dap.digitalgov.gov https://www.google-analytics.com \
                https://www.googletagmanager.com https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/ \
                    'unsafe-inline'",
            "style-src": "'self' https://fonts.googleapis.com https://api.data.gov 'unsafe-inline'",
            "report-uri": "/report-csp-violation/",
        }
        if env.app.get('space_name', 'local').lower() == 'local':
            content_security_policy["default-src"] += " localhost:* http://127.0.0.1:*"
            content_security_policy["connect-src"] += " localhost:* http://127.0.0.1:*"

        headers["Content-Security-Policy"] = "".join(
            "{0} {1}; ".format(directive, value)
            for directive, value in content_security_policy.items()
        )

        # Expect-CT header
        expect_ct_max_age = 60 * 60 * 24  # 1 day
        expect_ct_enforce = False
        expect_ct_report_uri = False
        expect_ct_string = 'max-age=%s' % expect_ct_max_age
        if expect_ct_enforce:
            expect_ct_string += ', enforce'
        if expect_ct_report_uri:
            expect_ct_string += ', report-uri="%s"' % expect_ct_report_uri
        headers["Expect-CT"] = expect_ct_string

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

    @app.route('/robots.txt/')
    def robots():
        return send_from_directory(app.static_folder, 'robots.txt')

    @app.route('/report-csp-violation/', methods=['POST'])
    def report():
        """
        Log Content Security Policy (CSP) violations from the browser
        for both API and CMS.
        Reports come in with tag 'csp-report'
        """
        app.logger.info(ujson.loads(str(request.data, 'utf-8')))
        return util.output_json("CSP violation reported", 200)

    @app.shell_context_processor
    def make_shell_context():
        return {'app': app, 'db': db, 'models': models}

    app.wsgi_app = ProxyFix(app.wsgi_app)

    return app
