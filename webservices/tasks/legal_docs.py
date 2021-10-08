import datetime

import logging

from celery_once import QueueOnce

from webservices import utils
from webservices.legal_docs.advisory_opinions import load_advisory_opinions
from webservices.legal_docs.current_cases import load_cases
from webservices.legal_docs.es_management import create_es_snapshot
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
    SELECT case_no, case_type, pg_date, published_flg
    FROM fecmur.cases_with_parsed_case_serial_numbers_vw
    WHERE pg_date >= NOW() - '8 hour'::INTERVAL
    ORDER BY case_serial
"""

RECENTLY_MODIFIED_CASES_SEND_ALERT = """
    SELECT case_no, case_type, pg_date, published_flg
    FROM fecmur.cases_with_parsed_case_serial_numbers_vw
    WHERE pg_date >= NOW() - '13 hour'::INTERVAL
    ORDER BY case_serial
"""

SLACK_BOTS = "#bots"


@app.task(once={"graceful": True}, base=QueueOnce)
def refresh_most_recent_legal_doc():
    # refresh most recently(within 8 hours) modified legal_doc.
    with db.engine.connect() as conn:
        refresh_most_recent_aos(conn)
        refresh_most_recent_cases(conn)


@app.task(once={"graceful": True}, base=QueueOnce)
def daily_reload_all_aos_when_change():
    """
    Daily reload all AOs starting from earliest to current that were new or modified in the past 24 hours.
    """
    slack_message = ""
    with db.engine.connect() as conn:
        row = conn.execute(DAILY_MODIFIED_STARTING_AO).first()
        if row:
            logger.info(" Daily earliest AO found %s modified at %s", row["ao_no"], row["pg_date"])
            logger.info(" Daily (%s) reload of all AOs starting", datetime.date.today().strftime("%A"))
            load_advisory_opinions(row["ao_no"])
            logger.info(" Daily (%s) reload of all AOs completed", datetime.date.today().strftime("%A"))

            slack_message = "Daily reload of AO(s) starting from "
            slack_message = slack_message + "AO-" + str(row["ao_no"]) + " found modified at " + str(row["pg_date"])
            slack_message = slack_message + " completed "
        else:
            logger.info(" No daily (%s) modified AOs found", datetime.date.today().strftime("%A"))
            slack_message = \
                "No daily modified AO(s). Skip reload "

    if slack_message:
        slack_message = slack_message + "in " + get_app_name()
        utils.post_to_slack(slack_message, SLACK_BOTS)


@app.task(once={"graceful": True}, base=QueueOnce)
def reload_all_aos():
    logger.info(" Weekly (%s) reload of all AOs starting", datetime.date.today().strftime("%A"))
    load_advisory_opinions()
    logger.info(" Weekly (%s) reload of all AOs completed", datetime.date.today().strftime("%A"))
    slack_message = "Weekly reload of all AOs completed in {0} space".format(get_app_name())
    utils.post_to_slack(slack_message, SLACK_BOTS)


@app.task(once={"graceful": True}, base=QueueOnce)
def create_es_backup():
    try:
        logger.info(" Weekly (%s) elasticsearch backup starting", datetime.date.today().strftime("%A"))
        create_es_snapshot()
        logger.info(" Weekly (%s) elasticsearch backup completed", datetime.date.today().strftime("%A"))
        slack_message = "Weekly elasticsearch backup completed in {0} space".format(get_app_name())
        utils.post_to_slack(slack_message, SLACK_BOTS)
    except Exception as error:
        logger.exception(error)
        slack_message = "*ERROR* elasticsearch backup failed for {0}. Check logs.".format(get_app_name())
        utils.post_to_slack(slack_message, SLACK_BOTS)


def refresh_most_recent_aos(conn):
    # Reload RECENTLY_MODIFIED_STARTING_AO every 5 minutes during 6am-7pm(EST).
    row = conn.execute(RECENTLY_MODIFIED_STARTING_AO).first()
    if row:
        logger.info(" Recently modified AO %s found at %s", row["ao_no"], row["pg_date"])
        load_advisory_opinions(row["ao_no"])
    else:
        logger.info(" No recently modified AOs found.")


def refresh_most_recent_cases(conn):
    # Reload RECENTLY_MODIFIED_CASES (MUR/AF/ADR) every 5 minutes during 6am-7pm(EST).
    rs = conn.execute(RECENTLY_MODIFIED_CASES)
    load_count = 0
    deleted_case_count = 0
    for row in rs:
        logger.info(" Recently modified %s %s found at %s", row["case_type"], row["case_no"], row["pg_date"])
        load_cases(row["case_type"], row["case_no"])
        if row["published_flg"]:
            load_count += 1
            logger.info(" Total of %d case(s) loaded to elasticsearch.", load_count)
        else:
            deleted_case_count += 1
            logger.info(" Total of %d case(s) unpublished.", deleted_case_count)


@app.task(once={"graceful": True}, base=QueueOnce)
def send_alert_most_recent_legal_case():
    # Send modified case(s) (MUR/AF/ADR)(during 6am-7pm EST) alerts to Slack every day at 7pm(EST).
    slack_message = ""
    with db.engine.connect() as conn:
        rs = conn.execute(RECENTLY_MODIFIED_CASES_SEND_ALERT)
        row_count = 0
        for row in rs:
            row_count += 1
            if row["published_flg"]:
                slack_message = slack_message + str(row["case_type"]) + " " + str(row["case_no"]) + " found published at " + str(row["pg_date"])
                slack_message = slack_message + "\n"
            else:
                slack_message = slack_message + str(row["case_type"]) + " " + str(row["case_no"]) + " found unpublished at " + str(row["pg_date"])
                slack_message = slack_message + "\n"
    if row_count <= 0:
        slack_message = "No daily modified case (MUR/AF/ADR) found"

    if slack_message:
        slack_message = slack_message + " in " + get_app_name()
        utils.post_to_slack(slack_message, SLACK_BOTS)
