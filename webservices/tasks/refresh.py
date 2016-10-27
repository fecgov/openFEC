import io
import logging

import manage
from webservices import mail
from webservices.tasks import app, download
from webservices import legal_docs

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
            legal_docs.index_advisory_opinions()
            legal_docs.load_advisory_opinions_into_s3()
            # TODO: needs to work with celery
            # legal_docs.load_current_murs()
        except Exception as error:
            manage.logger.exception(error)
    try:
        mail.send_mail(buffer)
    except Exception as error:
        logger.exception(error)
