"""Processes that keep the data up to date. Called from the __init__.py file."""
import logging

import manage
from webservices import utils
from webservices.tasks import app, download
from webservices.tasks.utils import get_app_name


logger = logging.getLogger(__name__)

SLACK_BOTS = "#bots"
SLACK_ALERTS = "#alerts"


@app.task
def refresh_materialized_views():
    """
    Refresh public materialized views.
    """
    manage.logger.info(" Starting daily update materialized views...")
    try:
        manage.refresh_materialized()
        download.clear_bucket()
        slack_message = "*Success* daily update materialized views for {0} completed.".format(get_app_name())
        utils.post_to_slack(slack_message, SLACK_BOTS)
        manage.logger.info(slack_message)
    except Exception as error:
        manage.logger.exception(error)
        slack_message = "*ERROR* daily update materialized views failed for {0}.".format(get_app_name())
        slack_message = slack_message + "\n Error message: " + str(error)
        utils.post_to_slack(slack_message, SLACK_BOTS)
        utils.post_to_slack(slack_message, SLACK_ALERTS)
