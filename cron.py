#!/usr/bin/env python
"""Run background tasks in a crontab-like system using celery beat. Celery does
not daemonize itself, so this script should be run in a subprocess or managed
using supervisor or a similar tool.

Simple invocation: ::

    $ ./cron.py

Customizable invocation: ::

    celery worker -app cron --beat

"""

import io
import logging

import celery
from celery import signals
from celery.schedules import crontab

import manage
from webservices import mail
from webservices.rest import app as flask_app

logger = logging.getLogger(__name__)

app = celery.Celery('cron')
app.conf.update(
    BROKER_URL='sqla+sqlite:///beat.sqlite',
    CELERY_IMPORTS=('cron', 'webservices.downloads'),
    CELERYBEAT_SCHEDULE={
        'refresh': {
            'task': 'cron.refresh',
            'schedule': crontab(minute=0, hour=0),
        },
    }
)

@app.task
def refresh():
    """Update incremental aggregates and materialized views, then email logs
    to the development team.
    """
    buffer = io.StringIO()
    with mail.CaptureLogs(manage.logger, buffer):
        try:
            manage.update_aggregates()
            manage.refresh_materialized()
        except Exception as error:
            manage.logger.exception(error)
    try:
        mail.send_mail(buffer)
    except Exception as error:
        logger.exception(error)

context = {}

@signals.task_prerun.connect
def push_context(task_id, task, *args, **kwargs):
    print('pushing context')
    context[task_id] = flask_app.app_context()
    context[task_id].push()

@signals.task_postrun.connect
def pop_context(task_id, task, *args, **kwargs):
    if task_id in context:
        print('popping context')
        context[task_id].pop()
        context.pop(task_id)

if __name__ == '__main__':
    app.worker_main(['worker', '--beat'])
