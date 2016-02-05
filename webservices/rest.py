"""
A RESTful web service supporting fulltext and field-specific searches on FEC data. For
full documentation visit: https://api.open.fec.gov/developers.
"""
import os
import http

from flask import abort
from flask import request
from flask import jsonify
from flask import url_for
from flask import redirect
from flask import render_template
from flask import Flask
from flask import Blueprint

from flask.ext import cors
from flask.ext import restful
from raven.contrib.flask import Sentry
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
from webservices.resources import sched_e
from webservices.resources import download
from webservices.resources import aggregates
from webservices.resources import candidate_aggregates
from webservices.resources import candidates
from webservices.resources import committees
from webservices.resources import elections
from webservices.resources import filings
from webservices.resources import search
from webservices.resources import dates
from webservices.resources import costs
from webservices.env import env


def sqla_conn_string():
    sqla_conn_string = env.get_credential('SQLA_CONN')
    if not sqla_conn_string:
        print("Environment variable SQLA_CONN is empty; running against " + "local `cfdm_test`")
        sqla_conn_string = 'postgresql://:@/cfdm_test'
    print(sqla_conn_string)
    return sqla_conn_string


app = Flask(__name__)
app.debug = True
app.config['SQLALCHEMY_DATABASE_URI'] = sqla_conn_string()
app.config['APISPEC_FORMAT_RESPONSE'] = None

app.config['SQLALCHEMY_REPLICA_TASKS'] = [
    'webservices.tasks.download.export_query',
]
app.config['SQLALCHEMY_FOLLOWERS'] = [
    sa.create_engine(follower.strip())
    for follower in env.get_credential('SQLA_FOLLOWERS', '').split(',')
    if follower.strip()
]
# app.config['SQLALCHEMY_ECHO'] = True
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
FEC_API_WHITELIST_IPS = os.getenv('FEC_API_WHITELIST_IPS', False)


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
    max_age = os.getenv('FEC_CACHE_AGE')
    if max_age is not None:
        response.headers.add('Cache-Control', 'public, max-age={}'.format(max_age))
    return response


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
api.add_resource(totals.TotalsView, '/committee/<string:committee_id>/totals/', '/totals/<string:committee_type>/')
api.add_resource(reports.ReportsView, '/committee/<string:committee_id>/reports/', '/reports/<string:committee_type>/')
api.add_resource(search.CandidateNameSearch, '/names/candidates/')
api.add_resource(search.CommitteeNameSearch, '/names/committees/')
api.add_resource(sched_a.ScheduleAView, '/schedules/schedule_a/')
api.add_resource(sched_b.ScheduleBView, '/schedules/schedule_b/')
api.add_resource(sched_e.ScheduleEView, '/schedules/schedule_e/')
api.add_resource(costs.CommunicationCostView, '/communication-costs/')
api.add_resource(costs.ElectioneeringView, '/electioneering/')
api.add_resource(elections.ElectionView, '/elections/')
api.add_resource(elections.ElectionList, '/elections/search/')
api.add_resource(elections.ElectionSummary, '/elections/summary/')
api.add_resource(dates.ElectionDatesView, '/election-dates/')
api.add_resource(dates.ReportingDatesView, '/reporting-dates/')
api.add_resource(dates.CalendarDatesView, '/calendar-dates/')
api.add_resource(dates.CalendarDatesExport, '/calendar-dates/export/')

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
add_aggregate_resource(api, aggregates.ScheduleAByContributorView, 'a', 'contributor')

add_aggregate_resource(api, aggregates.ScheduleBByRecipientView, 'b', 'recipient')
add_aggregate_resource(api, aggregates.ScheduleBByRecipientIDView, 'b', 'recipient_id')
add_aggregate_resource(api, aggregates.ScheduleBByPurposeView, 'b', 'purpose')

add_aggregate_resource(api, aggregates.ScheduleEByCandidateView, 'e', 'candidate')

api.add_resource(candidate_aggregates.ScheduleABySizeCandidateView, '/schedules/schedule_a/by_size/by_candidate/')
api.add_resource(candidate_aggregates.ScheduleAByStateCandidateView, '/schedules/schedule_a/by_state/by_candidate/')

api.add_resource(candidate_aggregates.TotalsCandidateView, '/candidates/totals/')
api.add_resource(committees.TotalsCommitteeHistoryView, '/committees/totals/')

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
api.add_resource(filings.FilingsList, '/filings/')

api.add_resource(download.DownloadView, '/download/<path:path>/')

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
apidoc.register(totals.TotalsView, blueprint='v1')
apidoc.register(sched_a.ScheduleAView, blueprint='v1')
apidoc.register(sched_b.ScheduleBView, blueprint='v1')
apidoc.register(sched_e.ScheduleEView, blueprint='v1')
apidoc.register(costs.CommunicationCostView, blueprint='v1')
apidoc.register(costs.ElectioneeringView, blueprint='v1')
apidoc.register(aggregates.ScheduleABySizeView, blueprint='v1')
apidoc.register(aggregates.ScheduleAByStateView, blueprint='v1')
apidoc.register(aggregates.ScheduleAByZipView, blueprint='v1')
apidoc.register(aggregates.ScheduleAByEmployerView, blueprint='v1')
apidoc.register(aggregates.ScheduleAByOccupationView, blueprint='v1')
apidoc.register(aggregates.ScheduleAByContributorView, blueprint='v1')
apidoc.register(aggregates.ScheduleBByRecipientView, blueprint='v1')
apidoc.register(aggregates.ScheduleBByRecipientIDView, blueprint='v1')
apidoc.register(aggregates.ScheduleBByPurposeView, blueprint='v1')
apidoc.register(aggregates.ScheduleEByCandidateView, blueprint='v1')
apidoc.register(aggregates.CommunicationCostByCandidateView, blueprint='v1')
apidoc.register(aggregates.ElectioneeringByCandidateView, blueprint='v1')
apidoc.register(candidate_aggregates.ScheduleABySizeCandidateView, blueprint='v1')
apidoc.register(candidate_aggregates.ScheduleAByStateCandidateView, blueprint='v1')
apidoc.register(filings.FilingsView, blueprint='v1')
apidoc.register(filings.FilingsList, blueprint='v1')
apidoc.register(elections.ElectionList, blueprint='v1')
apidoc.register(elections.ElectionView, blueprint='v1')
apidoc.register(elections.ElectionSummary, blueprint='v1')
apidoc.register(dates.ReportingDatesView, blueprint='v1')
apidoc.register(dates.ElectionDatesView, blueprint='v1')
apidoc.register(dates.CalendarDatesView, blueprint='v1')

# Adapted from https://github.com/noirbizarre/flask-restplus
here, _ = os.path.split(__file__)
docs = Blueprint(
    'docs',
    __name__,
    static_folder=os.path.join(here, os.pardir, 'node_modules', 'swagger-ui', 'dist'),
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
        PRODUCTION=os.getenv('PRODUCTION'),
    )


app.register_blueprint(docs)

def initialize_newrelic():
    license_key = env.get_credential('NEW_RELIC_LICENSE_KEY')
    if license_key:
        import newrelic.agent
        settings = newrelic.agent.global_settings()
        settings.license_key = license_key
        newrelic.agent.initialize()

initialize_newrelic()

if env.get_credential('SENTRY_DSN'):
    Sentry(app, dsn=env.get_credential('SENTRY_DSN'))

app.wsgi_app = ProxyFix(app.wsgi_app)
