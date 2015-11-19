import furl

import boto3
from botocore.exceptions import ClientError

from flask import redirect
from flask_restful import Resource

# from webservices import tasks

client = boto3.client('s3')

BUCKET = 'openfec-download-bucket'

class DownloadView(Resource):

    def get(self, path, **query):
        cached_file = get_cached_file(path, query)
        if cached_file:
            return redirect(cached_file)
        # TODO(jmcarp): De-duplicate tasks
        tasks.download.delay(path, query)
        return {'status': 'queued'}

def get_cached_file(path, query):
    key = get_s3_key(path, query)
    try:
        client.head_object(Bucket=BUCKET, Key=key)
        url = furl.furl(client.meta.endpoint_url)
        url.path.segments = [BUCKET, key]
        return url.url
    except ClientError:
        return None

# TODO(LindsayYoung): Implement me
def get_s3_key(path, query):
    pass
