from smore.apispec import APISpec

spec = APISpec(
    title='openfec',
    version='0.1.0',
    description='openfec api',
    plugins=[
        'smore.ext.flask',
        'smore.ext.marshmallow',
    ]
)
