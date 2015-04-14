from smore.apispec import APISpec

spec = APISpec(
    title='OpenFEC',
    version='0.2',
    description='OpenFEC API',
    plugins=['smore.ext.marshmallow'],
)

def doc(**kwargs):
    def wrapper(func):
        func.__apidoc__ = getattr(func, '__apidoc__', {})
        func.__apidoc__.update(kwargs)
        return func
    return wrapper
