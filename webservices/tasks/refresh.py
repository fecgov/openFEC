import io
import logging

import manage
from webservices import mail
from webservices.tasks import app, download

logger = logging.getLogger(__name__)


@app.task
def refresh():
    """Update incremental aggregates, itemized schedules, materialized views,
    then email logs to the development team.
    """
    buffer = io.StringIO()
    with mail.CaptureLogs(manage.logger, buffer):
        try:
            manage.update_functions()
            manage.update_aggregates()
            manage.refresh_itemized()
            manage.update_itemized('e')
            manage.update_schemas()
            download.clear_bucket()
        except Exception as error:
            manage.logger.exception(error)
    try:
        mail.send_mail(buffer)
    except Exception as error:
        logger.exception(error)


@app.task
def refresh_calendar():
    """ Updates calendar, is called every 15 minutes"""
    manage.refresh_calendar()
