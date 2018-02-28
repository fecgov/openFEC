import logging

from celery_once import QueueOnce
from smart_open import smart_open
from flask import request
from webservices.tasks import app
from webservices.tasks import utils

# logger = logging.getLogger('cache_request.py')
logger = logging.getLogger(__name__)

@app.task(base=QueueOnce, once={'graceful': True})
def cache_all_requests(response):
    # import pdb
    # pdb.set_trace()
    logger.info('This task is executed :)')
    # try:
    #     # convert the request content into JSON object
    #     json_data = utils.get_json_data(response)
    #     logger.info('Format the response to a JSON....')
    #     # format the URL by removing the api_key and special characters
    #     formatted_url = utils.format_url(request.url)

    #     # get s3 bucket env variables
    #     s3_bucket = utils.get_bucket()
    #     logger.info('Got s3_bucket()....')
    #     cached_url = "s3://{0}/cached-calls/{1}.json".format(s3_bucket.name, formatted_url)
    #     logger.info('Before uploading to s3....')
    #     with smart_open(cached_url, "wb") as cached_file:
    #         cached_file.write(json_data)
    #     logger.info('After uploading to s3....')
    #     logger.info(
    #         'The following request has been uploaded to S3 successfully: {}'.format(
    #             cached_url
    #         )
    #     )
    # except Exception as e:
    #     logger.error('Exception occured while uploading the cache request to S3.%s', e)
