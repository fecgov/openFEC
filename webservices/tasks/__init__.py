from datetime import timedelta

import celery
from celery import signals
from celery.schedules import crontab


from webservices.env import env
from webservices.tasks import utils


# Feature and dev are sharing the same RDS box so we only want dev to update
schedule = {}
if env.app.get('space_name', 'unknown-space').lower() != 'feature':
    schedule = {
        'refresh': {
            'task': 'webservices.tasks.refresh.refresh',
            'schedule': crontab(minute=0, hour=9),
        },
        'calendar': {
            'task': 'webservices.tasks.refresh.refresh_calendar',
            'schedule': timedelta(minutes=15),
        },
        'refresh_legal_docs': {
            'task': 'webservices.tasks.legal_docs.refresh',
            'schedule': timedelta(minutes=15),
        },
    }

def redis_url():
    redis = env.get_service(label='redis28')
    if redis:
        url = redis.get_url(host='hostname', password='password', port='port')
        return 'redis://{}'.format(url)
    return env.get_credential('FEC_REDIS_URL', 'redis://localhost:6379/0')

app = celery.Celery('openfec')
app.conf.update(
    BROKER_URL=redis_url(),
    ONCE_REDIS_URL=redis_url(),
    ONCE_DEFAULT_TIMEOUT=60 * 60,
    CELERY_IMPORTS=(
        'webservices.tasks.refresh',
        'webservices.tasks.download',
        'webservices.tasks.legal_docs',
    ),
    CELERYBEAT_SCHEDULE=schedule,
)

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
