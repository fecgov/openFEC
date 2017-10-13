"""Processes that keep the data up to date. Called from the __init__.py file."""
import logging

import manage
from webservices import utils
from webservices.env import env
from webservices.tasks import app, download


logger = logging.getLogger(__name__)


@app.task
def refresh():
    """Update incremental aggregates, itemized schedules, materialized views,
    then slack a notification to the development team.
    """
    try:
        manage.update_functions()
        manage.update_itemized('e')
        manage.update_schemas()
        download.clear_bucket()
        message = '*Success* nightly updates for {0} completed'.format(env.get_credential(NEW_RELIC_APP_NAME))
        utils.post_to_slack(message, '#bots')
    except Exception as error:
        message = '*ERROR* nightly update failed for {0}. Check logs.'.format(env.get_credential(NEW_RELIC_APP_NAME))
        utils.post_to_slack(message, '#bots')
        manage.logger.exception(error)


@app.task
def refresh_calendar():
    """Update calendar, called every 15 minutes."""
    manage.refresh_calendar()
