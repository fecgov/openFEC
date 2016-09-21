from apispec import APISpec

from webservices import docs
from webservices import __API_VERSION__


spec = APISpec(
    title='OpenFEC',
    version=__API_VERSION__,
    info={'description': docs.API_DESCRIPTION},
    basePath='/v1',
    produces=['application/json'],
    plugins=['apispec.ext.marshmallow'],
    securityDefinitions={
        'apiKey': {
            'type': 'apiKey',
            'name': 'api_key',
            'in': 'query',
        },
    },
    security=[{'apiKey': []}],
    tags=[
        {
            'name': 'candidate',
            'description': docs.CANDIDATE_TAG,
        },
        {
            'name': 'committee',
            'description': docs.COMMITTEE_TAG,
        },
        {
            'name': 'dates',
            'description': docs.DATES_TAG,
        },
        {
            'name': 'financial',
            'description': docs.FINANCIAL_TAG,
        },
        {
            'name': 'search',
            'description': docs.SEARCH_TAG,
        },
        {
            'name': 'filings',
            'description': docs.FILINGS,
        },
        {
            'name': 'receipts',
            'description': docs.SCHEDULE_A_TAG,
        },
        {
            'name': 'disbursements',
            'description': docs.SCHEDULE_B_TAG,
        },
        {
            'name': 'loans',
            'description': docs.SCHEDULE_C_TAG,

        },
        {
            'name': 'debts',
            'description': docs.SCHEDULE_D_TAG,

        },
        {
            'name': 'independent expenditures',
            'description': docs.SCHEDULE_E_TAG,
        },
        {
            'name': 'party-coordinated expenditures',
            'description': docs.SCHEDULE_F_TAG,
        },
        {
            'name': 'communication cost',
            'description': docs.COMMUNICATION_TAG,
        },
        {
            'name': 'electioneering',
            'description': docs.ELECTIONEERING,
        },
        {
            'name': 'filer resources',
            'description': docs.FILER_RESOURCES,
        },
        {
            'name': 'efiling',
            'description': docs.EFILING_TAG,
        }
    ]
)
