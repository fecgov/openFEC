import logging

from celery_once import QueueOnce
from smart_open import smart_open
from webservices.tasks import app
from webservices.tasks import utils

logger = logging.getLogger(__name__)

@app.task(base=QueueOnce, once={'graceful': True})
def cache_all_requests(json_data, formatted_url):

    try:
        cached_url = 'cached-calls/{}'.format(formatted_url)
        s3_key = utils.get_s3_key(cached_url)

        # upload the json_data to s3 bucket
        with smart_open(s3_key, 'wb') as cached_file:
            cached_file.write(json_data)
        logger.info(
            'The following request has been uploaded to S3 successfully: {}'.format(
                cached_url
            )
        )
    except Exception as e:
        logger.error(
            'An exception occured while uploading the cached request to S3: {}'.format(e)
        )
