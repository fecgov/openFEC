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
    itemized_schedules = ['a', 'b']

    with mail.CaptureLogs(manage.logger, buffer):
        try:
            projected_weekly_totals = manage.get_projected_weekly_itemized_totals(
                itemized_schedules
            )
            manage.update_all()
            actual_weekly_totals = manage.get_actual_weekly_itemized_totals(
                itemized_schedules
            )

            for schedule in itemized_schedules:
                manage.logger.info(
                    'Schedule {0} weekly totals: Projected = {1} / Actual = {2}'.format(
                        schedule,
                        projected_weekly_totals[schedule],
                        actual_weekly_totals[schedule]
                    )
                )

            download.clear_bucket()
        except Exception as error:
            manage.logger.exception(error)

    try:
        mail.send_mail(buffer)
    except Exception as error:
        logger.exception(error)
