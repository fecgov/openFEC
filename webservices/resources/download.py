import furl
from marshmallow import fields
from flask_apispec import use_kwargs

import boto3
from botocore.exceptions import ClientError

from flask import request

from webservices import utils
from webservices.tasks import download
from webservices.tasks import utils as task_utils

client = boto3.client('s3')

URL_EXPIRY = 7 * 24 * 60 * 60

class DownloadView(utils.Resource):

    @use_kwargs({'filename': fields.Str(missing=None)})
    def post(self, path, filename=None):
        parts = request.path.split('/')
        parts.remove('download')
        path = '/'.join(parts)
        cached_file = get_cached_file(path, request.query_string, filename=filename)
        if cached_file:
            return {
                'status': 'complete',
                'url': cached_file,
            }
        download.export_query.delay(path, request.query_string)
        return {'status': 'queued'}

def get_cached_file(path, qs, filename=None):
    key = download.get_s3_name(path, qs)
    obj = task_utils.get_bucket().Object(key=key)
    try:
        obj.metadata
        client = obj.meta.client
        url = furl.furl(client.meta.endpoint_url)
        url.path.segments = [obj.bucket_name, obj.key]
        return get_download_url(obj, filename=filename)
    except ClientError:
        return None

def get_download_url(obj, filename=None):
    params = {
        'Key': obj.key,
        'Bucket': obj.bucket_name,
    }
    if filename:
        params['ResponseContentDisposition'] = 'filename={}'.format(filename)
    return obj.meta.client.generate_presigned_url(
        'get_object',
        Params=params,
        ExpiresIn=URL_EXPIRY,
    )
