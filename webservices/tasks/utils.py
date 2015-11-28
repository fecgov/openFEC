import boto3

from webservices.env import env

def get_app():
    from webservices.rest import app
    return app

def get_bucket():
    session = boto3.Session(
        aws_access_key_id=env.get_credential('FEC_DOWNLOAD_ACCESS_KEY'),
        aws_secret_access_key=env.get_credential('FEC_DOWNLOAD_SECRET_KEY'),
    )
    s3 = session.resource('s3')
    return s3.Bucket(env.get_credential('FEC_DOWNLOAD_BUCKET'))
