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
from celery.schedules import crontab

import manage
from webservices import mail

logger = logging.getLogger(__name__)

app = celery.Celery('cron')
app.conf.update(
    BROKER_URL='sqla+sqlite:///beat.sqlite',
    CELERY_IMPORTS=('cron', ),
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
            with manage.app.test_request_context():
                manage.update_aggregates()
                manage.refresh_materialized()
        except Exception as error:
            manage.logger.exception(error)
    try:
        mail.send_mail(buffer)
    except Exception as error:
        logger.exception(error)

if __name__ == '__main__':
    app.worker_main(['worker', '--beat'])
