

import datetime

import logging

from celery_once import QueueOnce

from webservices import utils
from webservices.legal_docs.advisory_opinions import load_advisory_opinions
from webservices.legal_docs.current_murs import load_current_murs
from webservices.rest import db
from webservices.tasks import app
from webservices.tasks.utils import get_app_name


logger = logging.getLogger(__name__)

DAILY_MODIFIED_STARTING_AO = """
    SELECT ao_no, pg_date
    FROM aouser.aos_with_parsed_numbers
    WHERE pg_date >= NOW() - '24 hour'::INTERVAL
    ORDER BY ao_year, ao_serial
    LIMIT 1;
"""

RECENTLY_MODIFIED_STARTING_AO = """
    SELECT ao_no, pg_date
    FROM aouser.aos_with_parsed_numbers
    WHERE pg_date >= NOW() - '8 hour'::INTERVAL
    ORDER BY ao_year, ao_serial
    LIMIT 1;
"""

RECENTLY_MODIFIED_MURS = """
    SELECT case_no, pg_date
    FROM fecmur.cases_with_parsed_case_serial_numbers
    WHERE pg_date >= NOW() - '8 hour'::INTERVAL
    ORDER BY case_serial
"""

@app.task(once={'graceful': True}, base=QueueOnce)
def refresh():
    with db.engine.connect() as conn:
        refresh_aos(conn)
        refresh_murs(conn)

@app.task(once={'graceful': True}, base=QueueOnce)
def reload_all_aos_when_change():
    """
    Reload all AOs if there were any new or modified AOs found for the past 24 hour period
    """
    with db.engine.connect() as conn:
        row = conn.execute(DAILY_MODIFIED_STARTING_AO).first()
        if row:
            logger.info("AO found %s modified at %s", row["ao_no"], row["pg_date"])
            logger.info("Daily (%s) reload of all AOs starting", datetime.date.today().strftime("%A"))
            load_advisory_opinions()
            logger.info("Daily (%s) reload of all AOs completed", datetime.date.today().strftime("%A"))
            slack_message = 'Daily reload of all AOs completed in {0} space'.format(get_app_name())
            utils.post_to_slack(slack_message, '#bots')
        else:
            logger.info("No daily (%s) modified AOs found", datetime.date.today().strftime("%A"))
            slack_message = \
                'No modified AOs found for the day - Reload of all AOs skipped in {0} space'.format(get_app_name())
            utils.post_to_slack(slack_message, '#bots')

@app.task(once={'graceful': True}, base=QueueOnce)
def reload_all_aos():
    logger.info("Weekly (%s) reload of all AOs starting", datetime.date.today().strftime("%A"))
    load_advisory_opinions()
    logger.info("Weekly (%s) reload of all AOs completed", datetime.date.today().strftime("%A"))
    slack_message = 'Weekly reload of all AOs completed in {0} space'.format(get_app_name())
    utils.post_to_slack(slack_message, '#bots')

def refresh_aos(conn):
    row = conn.execute(RECENTLY_MODIFIED_STARTING_AO).first()
    if row:
        logger.info("AO found %s modified at %s", row["ao_no"], row["pg_date"])
        load_advisory_opinions(row["ao_no"])
    else:
        logger.info("No modified AOs found")

def refresh_murs(conn):
    logger.info('Checking for modified MURs')
    rs = conn.execute(RECENTLY_MODIFIED_MURS)
    if rs.returns_rows:
        load_count = 0
        for row in rs:
            logger.info("Current MUR %s found modified at %s", row["case_no"], row["pg_date"])
            load_current_murs(row["case_no"])
            load_count += 1
        logger.info("Total of %d current MUR(s) loaded", load_count)
    else:
        logger.info("No modified current MURs found")
