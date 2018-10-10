"""Processes that keep the data up to date. Called from the __init__.py file."""
import logging

import manage
from webservices import utils
from webservices.tasks import app, download
from webservices.tasks.utils import get_app_name


logger = logging.getLogger(__name__)


@app.task
def refresh_materialized_views():
    """Update incremental aggregates, itemized schedules, materialized views,
    then slack a notification to the development team.
    """
    manage.logger.info('Starting nightly refresh...')
    try:
        manage.refresh_itemized()
        manage.refresh_materialized()
        download.clear_bucket()
        slack_message = '*Success* nightly updates for {0} completed'.format(
            get_app_name()
        )
        utils.post_to_slack(slack_message, '#bots')
        manage.logger.info(slack_message)
    except Exception as error:
        manage.logger.exception(error)
        slack_message = '*ERROR* nightly update failed for {0}. Check logs.'.format(
            get_app_name()
        )
        utils.post_to_slack(slack_message, '#bots')
        manage.logger.exception(error)
