import logging

from celery_once import QueueOnce
from smart_open import smart_open
from flask import request
from webservices.tasks import app
from webservices.tasks import utils

# logger = logging.getLogger('cache_request.py')
logger = logging.getLogger(__name__)

@app.task(base=QueueOnce, once={'graceful': True})
def cache_all_requests(json_data, formatted_url):

    try:
        # get s3 bucket env variables
        s3_bucket = utils.get_bucket()
        cached_url = "s3://{0}/cached-calls/{1}.json".format(s3_bucket.name, formatted_url)
        logger.info('Before uploading to s3....')
        # upload the json_data to s3 bucket
        with smart_open(cached_url, "wb") as cached_file:
            cached_file.write(json_data)
        logger.info('After uploading to s3....')
        logger.info(
            'The following request has been uploaded to S3 successfully: {}'.format(
                cached_url
            )
        )
    except Exception as e:
        logger.error('Exception occured while uploading the cache request to S3.%s', e)
