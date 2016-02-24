import boto3

from webservices.env import env

def get_app():
    from webservices.rest import app
    return app

def get_bucket():
    session = boto3.Session(
        aws_access_key_id=env.get_credential('access_key_id'),
        aws_secret_access_key=env.get_credential('secret_access_key'),
    )
    s3 = session.resource('s3')
    return s3.Bucket(env.get_credential('bucket'))

def get_object(key):
    return get_bucket().Object(key=key)
