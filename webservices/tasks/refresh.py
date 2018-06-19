"""Processes that keep the data up to date. Called from the __init__.py file."""
import logging

import manage
from webservices import utils
from webservices.env import env
from webservices.tasks import app, download


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
        slack_message = '*Success* nightly updates for {0} completed'.format(env.get_credential('NEW_RELIC_APP_NAME'))
        utils.post_to_slack(slack_message, '#bots')
        manage.logger.info(slack_message)
    except Exception as error:
        manage.logger.exception(error)
        slack_message = '*ERROR* nightly update failed for {0}. Check logs.'.format(env.get_credential('NEW_RELIC_APP_NAME'))
        utils.post_to_slack(slack_message, '#bots')
        manage.logger.exception(error)
