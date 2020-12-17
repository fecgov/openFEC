import os

import cfenv


env = cfenv.AppEnv()

default_bucket = env.get_service(name="fec-s3-api")

if default_bucket:
    os.environ['AWS_DEFAULT_BUCKET'] = default_bucket.credentials.get('bucket')
    os.environ['AWS_ACCESS_KEY_ID'] = default_bucket.credentials.get('access_key_id')
    os.environ['AWS_SECRET_ACCESS_KEY'] = default_bucket.credentials.get('secret_access_key')
    os.environ['AWS_DEFAULT_REGION'] = default_bucket.credentials.get('region')

__all__ = ['env']
