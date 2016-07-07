import io
import logging

import manage
from webservices import mail
from webservices.tasks import app, download

logger = logging.getLogger(__name__)

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
            download.clear_bucket()
        except Exception as error:
            manage.logger.exception(error)
    try:
        mail.send_mail(buffer)
    except Exception as error:
        logger.exception(error)


@app.task
def refresh_and_rebuild():
    """Comprehensive schedule updates to ensure that data is up to date.
    As with regular updates, email logs are also sent.
    """
    buffer = io.StringIO()
    with mail.CaptureLogs(manage.logger, buffer):
        try:
            manage.rebuild_aggregates()
            manage.refresh_materialized()
            download.clear_bucket()
        except Exception as error:
            manage.logger.exception(error)
    try:
        mail.send_mail(buffer)
    except Exception as error:
        logger.exception(error)
