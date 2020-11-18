import celery
from celery import signals
from celery.schedules import crontab

from webservices.env import env
from webservices.tasks import utils


# Feature and dev are sharing the same RDS box so we only want dev to update
schedule = {}
if env.app.get('space_name', 'unknown-space').lower() != 'feature':
    schedule = {
        'refresh_materialized_views': {
            'task': 'webservices.tasks.refresh.refresh_materialized_views',
            'schedule': crontab(minute=0, hour=9),
        },

        'reload_all_aos_daily_except_sunday': {
            'task': 'webservices.tasks.legal_docs.reload_all_aos_when_change',
            'schedule': crontab(minute=0, hour=1, day_of_week='mon,tue,wed,thu,fri,sat'),
        },

        'reload_all_aos_every_sunday': {
            'task': 'webservices.tasks.legal_docs.reload_all_aos',
            'schedule': crontab(minute=0, hour=1, day_of_week='sun'),
        },

        'refresh_legal_docs': {
            'task': 'webservices.tasks.legal_docs.refresh',
            'schedule': crontab(minute='*/5', hour='10-23'),
        },

        'backup_elasticsearch_every_sunday': {
            'task': 'webservices.tasks.legal_docs.create_es_backup',
            'schedule': crontab(minute=0, hour=4, day_of_week='sun'),
        },
    }


def redis_url():
    """
    Retrieve the URL needed to connect to a Redis instance, depending on environment.

    When running in a cloud.gov environment, retrieve the uri credential for the 'redis32' service.
    """

    # Is the app running in a cloud.gov environment
    if env.space is not None:
        redis_env = env.get_service(label='redis32')
        redis_url = redis_env.credentials.get('uri')

        return redis_url

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
    broker_connection_timeout=30,  # in seconds
    broker_connection_max_retries=0,  # for unlimited retries
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
