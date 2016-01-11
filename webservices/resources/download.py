import http

from marshmallow import fields

import boto3
from botocore.exceptions import ClientError

from flask import request

from webservices import utils
from webservices import exceptions
from webservices.tasks import download
from webservices.tasks import utils as task_utils
from webservices.utils import use_kwargs

client = boto3.client('s3')

MAX_RECORDS = 100000
URL_EXPIRY = 7 * 24 * 60 * 60

class DownloadView(utils.Resource):

    @use_kwargs({'filename': fields.Str(missing=None)})
    def post(self, path, filename=None, **kwargs):
        parts = request.path.split('/')
        parts.remove('download')
        path = '/'.join(parts)
        cached_file = get_cached_file(path, request.query_string, filename=filename)
        if cached_file:
            return {
                'status': 'complete',
                'url': cached_file,
            }
        resource = download.call_resource(path, request.query_string)
        if resource['count'] > MAX_RECORDS:
            raise exceptions.ApiError(
                'Cannot request downloads with more than {} records'.format(MAX_RECORDS),
                status_code=http.client.FORBIDDEN,
            )
        download.export_query.delay(path, request.query_string)
        return {'status': 'queued'}

def get_cached_file(path, qs, filename=None):
    key = download.get_s3_name(path, qs)
    obj = task_utils.get_object(key)
    try:
        obj.metadata
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
