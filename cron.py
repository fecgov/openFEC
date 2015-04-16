#!/usr/bin/env python

import celery
from celery.schedules import crontab

import manage


app = celery.Celery('cron')
app.conf.update(
    BROKER_URL='sqla+sqlite:///beat.sqlite',
    CELERY_IMPORTS=('cron', ),
    CELERYBEAT_SCHEDULE={
        'refresh': {
            'task': 'cron.refresh',
            'schedule': crontab(minute=0, hour=0),
        }
    }
)


@app.task
def refresh():
    with manage.app.test_request_context():
        manage.refresh_materialized()


if __name__ == '__main__':
    app.worker_main(['worker', '--beat'])
