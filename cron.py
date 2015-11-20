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

logger = logging.getLogger(__name__)

def redis_url():
    return os.getenv('FEC_REDIS_URL') or vcap_redis_url()

def vcap_redis_url():
    services = json.loads(os.getenv('VCAP_SERVICES', '{}'))
    credentials = services['redis28-swarm'][0]['credentials']
    url = furl.furl('redis://')
    url.host = credentials['hostname']
    url.password = credentials['password']
    url.port = credentials['port']
    return url.url

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
