from apispec import APISpec
from apispec.ext.marshmallow import MarshmallowPlugin


from webservices import docs
from webservices import __API_VERSION__

def format_docstring(docstring):
    if not docstring or not docstring.strip():
        return ''

    formatted = []
    lines = docstring.expandtabs().splitlines()
    indent = min(len(line) - len(line.strip()) for line in lines if line.strip())
    trimmed = [lines[0].lstrip()] + [line[indent:].rstrip() for line in lines[1:]]

    for line in lines:
        if line == '':
            formatted.append('\n\n')
        else:
            formatted.append(line.strip())

    return ' '.join(formatted).strip()


spec = APISpec(
    title='OpenFEC',
    version=__API_VERSION__,
    info={'description': format_docstring(docs.API_DESCRIPTION)},
    basePath='/v1',
    produces=['application/json'],
    plugins=[MarshmallowPlugin()],
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
        }
    ]
)
