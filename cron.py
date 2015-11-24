#!/usr/bin/env python
"""Run background tasks in a crontab-like system using celery beat. Celery does
not daemonize itself, so this script should be run in a subprocess or managed
using supervisor or a similar tool.

Usage: ::

    celery worker --app cron --beat

"""

import io
import os
import json
import logging

import furl
import celery
from celery.schedules import crontab

import manage
from webservices import mail
from webservices.env import env

logger = logging.getLogger(__name__)

def redis_url():
    redis = env.get_service('redis28-swarm')
    if redis:
        url = redis.get_url(host='hostname', password='password', port='port')
        return 'redis://{}'.format(url)
    return os.getenv('FEC_REDIS_URL', 'redis://')

app = celery.Celery('cron')
app.conf.update(
    BROKER_URL=redis_url(),
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
