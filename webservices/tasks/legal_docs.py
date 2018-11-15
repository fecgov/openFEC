import datetime

import logging

from celery_once import QueueOnce

from webservices import utils
from webservices.legal_docs.advisory_opinions import load_advisory_opinions
from webservices.legal_docs.current_cases import load_cases
from webservices.legal_docs.index_management import create_elasticsearch_backup
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

RECENTLY_MODIFIED_CASES = """
    SELECT case_no, case_type, pg_date
    FROM fecmur.cases_with_parsed_case_serial_numbers_vw
    WHERE pg_date >= NOW() - '8 hour'::INTERVAL
    ORDER BY case_serial
"""

@app.task(once={'graceful': True}, base=QueueOnce)
def refresh():
    with db.engine.connect() as conn:
        refresh_aos(conn)
        refresh_cases(conn)

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

@app.task(once={'graceful': True}, base=QueueOnce)
def create_es_backup():
    logger.info("Weekly (%s) elasticsearch backup starting", datetime.date.today().strftime("%A"))
    create_elasticsearch_backup()
    logger.info("Weekly (%s) elasticsearch backup completed", datetime.date.today().strftime("%A"))
    slack_message = 'Weekly elasticsearch backup completed in {0} space'.format(get_app_name())
    utils.post_to_slack(slack_message, '#bots')

def refresh_aos(conn):
    row = conn.execute(RECENTLY_MODIFIED_STARTING_AO).first()
    if row:
        logger.info("AO %s found modified at %s", row["ao_no"], row["pg_date"])
        load_advisory_opinions(row["ao_no"])
    else:
        logger.info("No modified AOs found")

def refresh_cases(conn):
    logger.info('Checking for modified cases')
    rs = conn.execute(RECENTLY_MODIFIED_CASES)
    if rs.returns_rows:
        load_count = 0
        for row in rs:
            logger.info("%s %s found modified at %s", row["case_type"], row["case_no"], row["pg_date"])
            load_cases(row["case_type"], row["case_no"])
            load_count += 1
        logger.info("Total of %d case(s) loaded", load_count)
    else:
        logger.info("No modified cases found")
