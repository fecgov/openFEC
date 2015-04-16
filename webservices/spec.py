from smore.apispec import APISpec

from webservices import __API_VERSION__


spec = APISpec(
    title='OpenFEC',
    version=__API_VERSION__,
    description='OpenFEC API',
    plugins=['smore.ext.marshmallow'],
)


def doc(**kwargs):
    def wrapper(func):
        func.__apidoc__ = getattr(func, '__apidoc__', {})
        func.__apidoc__.update(kwargs)
        return func
    return wrapper
