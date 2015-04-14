from smore.apispec import APISpec

spec = APISpec(
    title='OpenFEC',
    version='0.2',
    description='OpenFEC API',
    plugins=['smore.ext.marshmallow'],
)
