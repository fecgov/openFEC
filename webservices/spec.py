from apispec import APISpec
from apispec.ext.marshmallow import MarshmallowPlugin

from webservices import docs
from webservices import __API_VERSION__
from webservices.env import env


def format_docstring(docstring):
    if not docstring or not docstring.strip():
        return ''

    formatted = []
    lines = docstring.expandtabs().splitlines()

    for line in lines:
        if line == '':
            formatted.append('\n\n')
        else:
            formatted.append(line.strip())

    return ' '.join(formatted).strip()


TAGS = [
    {
        'name': 'candidate',
        'description': format_docstring(docs.CANDIDATE_TAG),
    },
    {
        'name': 'committee',
        'description': format_docstring(docs.COMMITTEE_TAG),
    },
    {
        'name': 'dates',
        'description': format_docstring(docs.DATES_TAG),
    },
    {
        'name': 'financial',
        'description': format_docstring(docs.FINANCIAL_TAG),
    },
    {
        'name': 'search',
        'description': format_docstring(docs.SEARCH_TAG),
    },
    {
        'name': 'filings',
        'description': format_docstring(docs.FILINGS),
    },
    {
        'name': 'receipts',
        'description': format_docstring(docs.SCHEDULE_A_TAG),
    },
    {
        'name': 'disbursements',
        'description': format_docstring(docs.SCHEDULE_B_TAG),
    },
    {
        'name': 'loans',
        'description': format_docstring(docs.SCHEDULE_C_TAG),
    },
    {
        'name': 'debts',
        'description': format_docstring(docs.SCHEDULE_D_TAG),
    },
    {
        'name': 'independent expenditures',
        'description': format_docstring(docs.SCHEDULE_E_TAG),
    },
    {
        'name': 'party-coordinated expenditures',
        'description': format_docstring(docs.SCHEDULE_F_TAG),
    },
    {
        'name': 'communication cost',
        'description': format_docstring(docs.COMMUNICATION_TAG),
    },
    {
        'name': 'electioneering',
        'description': format_docstring(docs.ELECTIONEERING),
    },
    {
        'name': 'filer resources',
        'description': format_docstring(docs.FILER_RESOURCES),
    },
    {
        'name': 'efiling',
        'description': format_docstring(docs.EFILING_TAG),
    },
    {
        'name': 'audit',
        'description': format_docstring(docs.AUDIT),
    },
    {
        'name': 'legal',
        'description': format_docstring(docs.LEGAL),
    }
]

if bool(env.get_credential('FEC_FEATURE_PRESIDENTIAL', '')):
    # Insert after 'electioneering'
    TAGS.insert(14, {
        'name': 'presidential',
        'description': format_docstring(docs.PRESIDENTIAL),
    })

spec = APISpec(
    title='OpenFEC',
    version=__API_VERSION__,
    openapi_version='2.0',
    info={'description': format_docstring(docs.API_DESCRIPTION)},
    produces=['application/json'],
    plugins=[MarshmallowPlugin()],
    securityDefinitions={
        'apiKey': {
            'type': 'apiKey',
            'name': 'api_key',
            'in': 'query',
        },
        'ApiKeyQueryAuth': {
            'type': 'apiKey',
            'name': 'api_key',
            'in': 'query',
        },
        'ApiKeyHeaderAuth': {
            'type': 'apiKey',
            'name': 'X-Api-Key',
            'in': 'header',
        }
    },
    security=[
        {
            'apiKey': [],
            'ApiKeyQueryAuth': [],
            'ApiKeyHeaderAuth': []
        }
    ],
    tags=TAGS,
)
