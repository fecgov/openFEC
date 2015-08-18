"""
A RESTful web service supporting fulltext and field-specific searches on FEC data. For
full documentation visit: https://api.open.fec.gov/developers.
"""
import os
import re
import http
import logging

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

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices import exceptions
from webservices.common import util
from webservices.common import models
from webservices.common.models import db
from webservices.resources import totals
from webservices.resources import reports
from webservices.resources import sched_a
from webservices.resources import sched_b
from webservices.resources import sched_e
from webservices.resources import aggregates
from webservices.resources import candidate_aggregates
from webservices.resources import candidates
from webservices.resources import committees
from webservices.resources import elections
from webservices.resources import filings
from webservices.resources import dates
from webservices.resources import communication_cost

speedlogger = logging.getLogger('speed')
speedlogger.setLevel(logging.CRITICAL)
speedlogger.addHandler(logging.FileHandler(('rest_speed.log')))


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
# app.config['SQLALCHEMY_ECHO'] = True
db.init_app(app)
cors.CORS(app)


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


def search_typeahead_text(model, text):
    query = utils.search_text(model.query, model.fulltxt, text)
    query = query.limit(20)
    return {'results': query.all()}


@spec.doc(
    tags=['search'],
    description=docs.NAME_SEARCH,
)
class CandidateNameSearch(restful.Resource):
    """
    A quick name search (candidate or committee) optimized for response time
    for typeahead
    """

    @args.register_kwargs(args.names)
    @schemas.marshal_with(schemas.CandidateSearchListSchema())
    def get(self, **kwargs):
        return search_typeahead_text(models.CandidateSearch, kwargs['q'])


@spec.doc(
    tags=['search'],
    description=docs.NAME_SEARCH,
)
class CommitteeNameSearch(restful.Resource):
    """
    A quick name search (candidate or committee) optimized for response time
    for typeahead
    """

    @args.register_kwargs(args.names)
    @schemas.marshal_with(schemas.CommitteeSearchListSchema())
    def get(self, **kwargs):
        return search_typeahead_text(models.CommitteeSearch, kwargs['q'])


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
api.add_resource(totals.TotalsView, '/committee/<string:committee_id>/totals/')
api.add_resource(reports.ReportsView, '/committee/<string:committee_id>/reports', '/reports/<string:committee_type>/')
api.add_resource(CandidateNameSearch, '/names/candidates/')
api.add_resource(CommitteeNameSearch, '/names/committees/')
api.add_resource(sched_a.ScheduleAView, '/schedules/schedule_a/')
api.add_resource(sched_b.ScheduleBView, '/schedules/schedule_b/')
api.add_resource(sched_e.ScheduleEView, '/schedules/schedule_e/')
api.add_resource(elections.ElectionView, '/elections/')
api.add_resource(elections.ElectionList, '/elections/search/')
api.add_resource(dates.ElectionDatesView, '/election-dates/')
api.add_resource(dates.ReportingDatesView, '/reporting-dates/')

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
add_aggregate_resource(api, aggregates.ScheduleAByContributorTypeView, 'a', 'contributor_type')

add_aggregate_resource(api, aggregates.ScheduleBByRecipientView, 'b', 'recipient')
add_aggregate_resource(api, aggregates.ScheduleBByRecipientIDView, 'b', 'recipient_id')
add_aggregate_resource(api, aggregates.ScheduleBByPurposeView, 'b', 'purpose')

add_aggregate_resource(api, aggregates.ScheduleEByCandidateView, 'e', 'candidate')

api.add_resource(candidate_aggregates.ScheduleABySizeCandidateView, '/schedules/schedule_a/by_size/by_candidate/')
api.add_resource(candidate_aggregates.ScheduleAByStateCandidateView, '/schedules/schedule_a/by_state/by_candidate/')
api.add_resource(
    candidate_aggregates.ScheduleAByContributorTypeCandidateView,
    '/schedules/schedule_a/by_contributor_type/by_candidate/',
)

api.add_resource(
    communication_cost.CommunicationCostByCandidateView,
    '/candidate/<string:candidate_id>/communication_costs',
    '/committee/<string:committee_id>/communicaiton_costs',
)

api.add_resource(
    filings.FilingsView,
    '/committee/<committee_id>/filings/',
    '/candidate/<candidate_id>/filings/',
)
api.add_resource(filings.FilingsList, '/filings/')


RE_URL = re.compile(r'<(?:[^:<>]+:)?([^<>]+)>')
def extract_path(path):
    '''
    Transform a Flask/Werkzeug URL pattern in a Swagger one.
    '''
    return RE_URL.sub(r'{\1}', path)


def resolve(key, docs, default=None):
    for doc in docs:
        value = doc.get(key)
        if value:
            return value
    return default


API_KEY_PARAM = {
    'in': 'query',
    'type': 'string',
    'required': True,
    'name': 'api_key',
    'description': docs.API_KEY_DESCRIPTION,
    'default': 'DEMO_KEY',
}


def register_resource(resource, blueprint=None):
    key = resource.__name__.lower()
    if blueprint:
        key = '{0}.{1}'.format(blueprint, key)
    rules = app.url_map._rules_by_endpoint[key]
    resource_doc = getattr(resource, '__apidoc__', {})
    operations = {}
    for rule in rules:
        path = extract_path(rule.rule)
        path_params = [
            utils.extend({'required': True}, each)
            for each in resource_doc.get('path_params', [])
            if each['name'] in rule.arguments
        ]
        for method in [method.lower() for method in resource.methods or []]:
            view = getattr(resource, method)
            method_doc = getattr(view, '__apidoc__', {})
            docs = [method_doc, resource_doc]
            operations[method] = {
                'tags': resolve('tags', docs, []),
                'responses': resolve('responses', docs, {}),
                'description': resolve('description', docs, None),
                'parameters': resolve('parameters', docs, []) + path_params,
            }
            if os.getenv('PRODUCTION'):
                operations[method]['parameters'].insert(0, API_KEY_PARAM)
        spec.spec.add_path(path=path, operations=operations, view=view)


register_resource(CandidateNameSearch, blueprint='v1')
register_resource(CommitteeNameSearch, blueprint='v1')
register_resource(candidates.CandidateView, blueprint='v1')
register_resource(candidates.CandidateList, blueprint='v1')
register_resource(candidates.CandidateSearch, blueprint='v1')
register_resource(candidates.CandidateHistoryView, blueprint='v1')
register_resource(committees.CommitteeView, blueprint='v1')
register_resource(committees.CommitteeList, blueprint='v1')
register_resource(committees.CommitteeHistoryView, blueprint='v1')
register_resource(reports.ReportsView, blueprint='v1')
register_resource(totals.TotalsView, blueprint='v1')
register_resource(sched_a.ScheduleAView, blueprint='v1')
register_resource(sched_b.ScheduleBView, blueprint='v1')
register_resource(sched_e.ScheduleEView, blueprint='v1')
register_resource(aggregates.ScheduleABySizeView, blueprint='v1')
register_resource(aggregates.ScheduleAByStateView, blueprint='v1')
register_resource(aggregates.ScheduleAByZipView, blueprint='v1')
register_resource(aggregates.ScheduleAByEmployerView, blueprint='v1')
register_resource(aggregates.ScheduleAByOccupationView, blueprint='v1')
register_resource(aggregates.ScheduleAByContributorView, blueprint='v1')
register_resource(aggregates.ScheduleAByContributorTypeView, blueprint='v1')
register_resource(aggregates.ScheduleBByRecipientView, blueprint='v1')
register_resource(aggregates.ScheduleBByRecipientIDView, blueprint='v1')
register_resource(aggregates.ScheduleBByPurposeView, blueprint='v1')
register_resource(communication_cost.CommunicationCostByCandidateView, blueprint='v1')
register_resource(candidate_aggregates.ScheduleABySizeCandidateView, blueprint='v1')
register_resource(candidate_aggregates.ScheduleAByStateCandidateView, blueprint='v1')
register_resource(candidate_aggregates.ScheduleAByContributorTypeCandidateView, blueprint='v1')
register_resource(filings.FilingsView, blueprint='v1')
register_resource(filings.FilingsList, blueprint='v1')
register_resource(elections.ElectionList, blueprint='v1')
register_resource(elections.ElectionView, blueprint='v1')
register_resource(dates.ReportingDatesView, blueprint='v1')


# Adapted from https://github.com/noirbizarre/flask-restplus
here, _ = os.path.split(__file__)
docs = Blueprint(
    'docs',
    __name__,
    static_folder=os.path.join(here, os.pardir, 'node_modules', 'swagger-ui', 'dist'),
    static_url_path='/docs/static',
)


@docs.route('/swagger')
def api_spec():
    return jsonify(spec.spec.to_dict())


@docs.add_app_template_global
def swagger_static(filename):
    return url_for('docs.static', filename=filename)


@app.route('/')
@app.route('/v1/')
@docs.route('/developer')
def api_ui_redirect():
    return redirect(url_for('docs.api_ui'), code=http.client.MOVED_PERMANENTLY)


@docs.route('/developers')
def api_ui():
    return render_template('swagger-ui.html', specs_url=url_for('docs.api_spec'))


app.register_blueprint(docs)
