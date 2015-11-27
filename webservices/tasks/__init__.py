import os

import celery
from celery import signals
from celery.schedules import crontab

from webservices.env import env
from webservices.rest import app as flask_app

def redis_url():
    redis = env.get_service(label='redis28-swarm')
    if redis:
        url = redis.get_url(host='hostname', password='password', port='port')
        return 'redis://{}'.format(url)
    return os.getenv('FEC_REDIS_URL', 'redis://localhost:6379/0')

app = celery.Celery('openfec')
app.conf.update(
    BROKER_URL=redis_url(),
    ONCE_REDIS_URL=redis_url(),
    ONCE_DEFAULT_TIMEOUT=60 * 60,
    CELERY_IMPORTS=(
        'webservices.tasks.refresh',
        'webservices.tasks.download',
    ),
    CELERYBEAT_SCHEDULE={
        'refresh': {
            'task': 'webservices.tasks',
            'schedule': crontab(minute=0, hour=0),
        },
    }
)

context = {}

@signals.task_prerun.connect
def push_context(task_id, task, *args, **kwargs):
    context[task_id] = flask_app.app_context()
    context[task_id].push()

@signals.task_postrun.connect
def pop_context(task_id, task, *args, **kwargs):
    if task_id in context:
        context[task_id].pop()
        context.pop(task_id)
