import logging
import datetime

from celery_once import QueueOnce
from smart_open import smart_open
from webservices.tasks import app
from webservices.tasks import utils
from webservices import utils as web_utils
from webservices.env import env


logger = logging.getLogger(__name__)

def get_cache_expiration():
    return datetime.datetime.now() + datetime.timedelta(minutes=60)

@app.task(base=QueueOnce, once={'graceful': True})
def cache_all_requests(json_str, formatted_url):

    try:
        cached_url = 'cached-calls/{}'.format(formatted_url)

        bucket = utils.get_bucket()
        # upload the json_data to s3 bucket
        bucket.put_object(Key=cached_url, Body=json_str,
                        ContentType="application/json", Expires=get_cache_expiration())
        logger.info(
            'The following request has been uploaded to S3 successfully: {}'.format(
                cached_url
            )
        )
    except Exception as e:
        logger.error('Exception occured while uploading the cache request to S3.%s', e)

@app.task
def delete_cached_calls_from_s3():
    """
    Deletes all files and folders under cached-calls from S3
    """
    bucket = utils.get_bucket()
    bucketListResultSet = bucket.list(prefix="cached-calls/")
    bucket.delete_keys([key.name for key in bucketListResultSet])
    slack_message = 'Successfully deleted the cached-calls folder in {0} from S3'.format(env.get_credential('NEW_RELIC_APP_NAME'))
    web_utils.post_to_slack(slack_message, '#bots')
    logger.info(slack_message)