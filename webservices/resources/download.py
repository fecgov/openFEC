import furl

import boto3
from botocore.exceptions import ClientError

from flask import request, redirect

from webservices import utils
from webservices.tasks import download
from webservices.tasks import utils as task_utils

client = boto3.client('s3')

class DownloadView(utils.Resource):

    def get(self, path):
        parts = request.path.split('/')
        parts.remove('download')
        path = '/'.join(parts)
        cached_file = get_cached_file(path, request.query_string)
        if cached_file:
            return redirect(cached_file)
        download.export_query.delay(path, request.query_string)
        return {'status': 'queued'}

def get_cached_file(path, qs):
    key = download.get_s3_name(path, qs)
    obj = task_utils.get_bucket().Object(key=key)
    try:
        obj.metadata
        client = obj.meta.client
        url = furl.furl(client.meta.endpoint_url)
        url.path.segments = [obj.bucket_name, obj.key]
        return url.url
    except ClientError:
        return None
