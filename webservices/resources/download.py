import base64
import http

from marshmallow import fields

import boto3
from botocore.exceptions import ClientError

from flask import request

from webservices import utils
from webservices import exceptions
from webservices.tasks import download
from webservices.tasks.utils import delete_redis_value
from webservices.tasks import utils as task_utils
from webservices.utils import use_kwargs_original
from flask import current_app
import logging

logger = logging.getLogger(__name__)

client = boto3.client('s3')

MAX_RECORDS = 500000
URL_EXPIRY = 7 * 24 * 60 * 60


class DownloadView(utils.Resource):

    @use_kwargs_original({'filename': fields.Str(load_default=None),
                          'task_id': fields.Str(load_default=None)}, location='json')
    def post(self, path, filename=None, task_id=None, **kwargs):
        parts = request.path.split('/')
        parts.remove('download')
        path = '/'.join(parts)

        cached_file = get_cached_file(path, request.query_string, filename=filename)
        if cached_file:
            if task_id and task_utils.get_redis_value('download-queued:{}'.format(task_id)):
                delete_redis_value('download-queued:{}'.format(task_id))

            return {
                'status': 'complete',
                'url': cached_file,
            }

        if task_id:
            if task_utils.get_redis_value('download-failed:{}'.format(task_id)):
                delete_redis_value('download-failed:{}'.format(task_id))
                logging.exception(f"Download {task_id} failed")
                raise exceptions.ApiError('Download failed', status_code=http.client.INTERNAL_SERVER_ERROR)
            if task_utils.get_redis_value('download-queued:{}'.format(task_id)):
                return {'status': 'queued', 'task_id': task_id}

        resource = download.call_resource(current_app, path, request.query_string.decode('UTF-8'))

        if resource['count'] > MAX_RECORDS:
            raise exceptions.ApiError(
                'Cannot request downloads with more than {} records'.format(MAX_RECORDS),
                status_code=http.client.FORBIDDEN,
            )

        task_id = download.export_query.delay(
            path,
            base64.b64encode(request.query_string).decode('UTF-8')
        ).id
        task_utils.set_redis_value('download-queued:{}'.format(task_id), True, age=7200)

        return {'status': 'queued', 'task_id': task_id}


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
