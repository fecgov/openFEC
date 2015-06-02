from smore.apispec import APISpec

from webservices import docs
from webservices import __API_VERSION__


spec = APISpec(
    title='OpenFEC',
    version=__API_VERSION__,
    info={'description': docs.DESCRIPTION},
    basePath='/v1',
    produces=['application/json'],
    plugins=['smore.ext.marshmallow'],
    securityDefinitions={
        'apiKey': {
            'type': 'apiKey',
            'name': 'api_key',
            'in': 'query',
        },
    },
    security=[
        {'apiKey': []},
    ],
)


def doc(**kwargs):
    def wrapper(func):
        func.__apidoc__ = func.__dict__.get('__apidoc__', {})
        func.__apidoc__.update(kwargs)
        return func
    return wrapper
