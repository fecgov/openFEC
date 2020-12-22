import os

import cfenv


env = cfenv.AppEnv()

S3_PUBLIC_SERVICE_INSTANCE_NAME = "fec-s3-api"

public_bucket = env.get_service(name=S3_PUBLIC_SERVICE_INSTANCE_NAME)

if public_bucket:
    os.environ['AWS_PUBLIC_BUCKET'] = public_bucket.credentials.get('bucket')
    os.environ['AWS_ACCESS_KEY_ID'] = public_bucket.credentials.get('access_key_id')
    os.environ['AWS_SECRET_ACCESS_KEY'] = public_bucket.credentials.get('secret_access_key')
    os.environ['AWS_DEFAULT_REGION'] = public_bucket.credentials.get('region')

__all__ = ['env']
