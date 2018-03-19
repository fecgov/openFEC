from datetime import timedelta

import celery
from celery import signals
from celery.schedules import crontab
import logging

from webservices.env import env
from webservices.tasks import utils

logger = logging.getLogger(__name__)

# Feature and dev are sharing the same RDS box so we only want dev to update
schedule = {}
if env.app.get('space_name', 'unknown-space').lower() != 'feature':
    schedule = {
        'refresh': {
            'task': 'webservices.tasks.refresh.refresh',
            'schedule': crontab(minute=0, hour=9),
        },
        'refresh_legal_docs': {
            'task': 'webservices.tasks.legal_docs.refresh',
            'schedule': crontab(minute='*/5'),
        },
    }


def redis_url():
    """
    Retrieves the URL needed to connect to a Redis instance.
    """

    # Attempt to retrieve the space name the application is running in; this
    # will return the space if the app is running in a cloud.gov environment or
    # None if it is running locally.
    if env.space is not None:
        logger.info(
            'Running in the {0} space in cloud.gov.'.format(env.space)
        )

        # While we are not able to connect to Redis, retry as many times as
        # necessary.  This is usually due to a brief 1 - 3 second downtime as
        # a service instance is rebooted in the cloud.gov environment.
        # TODO:  Make this more robust in the case of extended outages.
        while True:
            logger.info('Attempting to connect to Redis...')
            redis = env.get_service(label='redis32')

            if redis is not None:
                logger.info('Successfully connected to Redis.')
                break
            else:
                logger.error('Could not connect to Redis, retrying...')

        # Construct the Redis instance URL based on the service information
        # returned.
        url = redis.get_url(host='hostname', password='password', port='port')
        return 'redis://{}'.format(url)
    else:
        logger.debug(
            'Not running in a cloud.gov space, attempting to connect locally.'
        )

    # Fall back to attempting to read whatever is set in the FEC_REDIS_URL
    # environment variable, otherwise a localhost connection.
    return env.get_credential('FEC_REDIS_URL', 'redis://localhost:6379/0')

app = celery.Celery('openfec')
app.conf.update(
    broker_url=redis_url(),
    imports=(
        'webservices.tasks.refresh',
        'webservices.tasks.download',
        'webservices.tasks.legal_docs',
    ),
    beat_schedule=schedule,
    task_acks_late=False
)

app.conf.ONCE = {
    'backend': 'celery_once.backends.Redis',
    'settings': {
        'url': redis_url(),
        'default_timeout': 60 * 60
    }
}

context = {}

@signals.task_prerun.connect
def push_context(task_id, task, *args, **kwargs):
    context[task_id] = utils.get_app().app_context()
    context[task_id].push()

@signals.task_postrun.connect
def pop_context(task_id, task, *args, **kwargs):
    if task_id in context:
        context[task_id].pop()
        context.pop(task_id)
