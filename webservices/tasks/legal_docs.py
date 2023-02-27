import datetime

import logging

from celery_once import QueueOnce

from webservices import utils
from webservices.legal_docs.advisory_opinions import load_advisory_opinions
from webservices.legal_docs.current_cases import load_cases
from webservices.legal_docs.es_management import create_es_snapshot
from webservices.legal_docs.es_management import (  # noqa
    CASE_INDEX,
    AO_INDEX,
)

from webservices.rest import db
from webservices.tasks import app
from webservices.tasks.utils import get_app_name


logger = logging.getLogger(__name__)

RECENTLY_MODIFIED_AOS = """
    SELECT /* celery_legal_ao_5 */ ao_no, pg_date
    FROM aouser.aos_with_parsed_numbers
    WHERE pg_date >= NOW() - '10 hours + 5 minutes'::INTERVAL
    ORDER BY ao_year, ao_serial;
"""

RECENTLY_MODIFIED_CASES = """
    SELECT /* celery_legal_case_5 */ case_no, case_type, pg_date, published_flg
    FROM fecmur.cases_with_parsed_case_serial_numbers_vw
    WHERE pg_date >= NOW() - '10 hours + 5 minutes'::INTERVAL
    ORDER BY case_serial;
"""

# For daily_reload_all_aos_when_change(): in past 24 hours(9pm-9pm EST)
DAILY_MODIFIED_AOS = """
    SELECT ao_no, pg_date
    FROM aouser.aos_with_parsed_numbers
    WHERE pg_date >= NOW() - '24 hour'::INTERVAL
    ORDER BY ao_year, ao_serial;
"""

# for send_alert_daily_modified_legal_case():  during 19:55pm-19:55pm(EST) (24 hours)
DAILY_MODIFIED_CASES_SEND_ALERT = """
    SELECT case_no, case_type, pg_date, published_flg
    FROM fecmur.cases_with_parsed_case_serial_numbers_vw
    WHERE pg_date >= NOW() - '24 hour'::INTERVAL
    ORDER BY case_serial;
"""

SLACK_BOTS = "#bots"


@app.task(once={"graceful": True}, base=QueueOnce)
def refresh_most_recent_legal_doc():
    """
        # Task 1: This task is launched every 5 minutes during 6am-7pmEST(13 hours).
        # Task 1A: refresh_most_recent_aos(conn):
        # 1) Identify the most recently modified AO(s) within 8 hours
        # 2) For each modified AO, find the earliest AO referenced by the modified AO
        # 3) Reload all AO(s) starting from the referenced AO to the latest AO.

        # Task 1B: refresh_most_recent_cases(conn):
        # When found modified case(s)(MUR/AF/ADR) within 8 hours,
        #   if published_flg = true, reload the case(s) on elasticsearch service.
        #   if published_flg = false, delete the case(s) on elasticsearch service.
    """
    with db.engine.connect() as conn:
        refresh_most_recent_aos(conn)
        refresh_most_recent_cases(conn)


def refresh_most_recent_aos(conn):
    """
        # 1) Identify the most recently modified AO(s) within 8 hours
        # 2) For each modified AO, find the earliest AO referenced by the modified AO
        # 3) Reload all AO(s) starting from the referenced AO to the latest AO.
    """
    logger.info(" Checking for recently modified AOs...")
    rs = conn.execute(RECENTLY_MODIFIED_AOS)
    row_count = 0
    for row in rs:
        if row:
            row_count += 1
            logger.info(" Recently modified AO %s found at %s", row["ao_no"], row["pg_date"])
            load_advisory_opinions(row["ao_no"])
    if row_count <= 0:
        logger.info(" No recently modified AO(s) found.")
    else:
        logger.info(" Total of %d ao(s) loaded to elasticsearch successfully.", row_count)


def refresh_most_recent_cases(conn):
    """
        # When found modified case(s)(MUR/AF/ADR) within 8 hours,
        #   if published_flg = true, reload the case(s) on elasticsearch service.
        #   if published_flg = false, delete the case(s) on elasticsearch service.
    """
    logger.info(" Checking for recently modified cases(MUR/AF/ADR)...")
    rs = conn.execute(RECENTLY_MODIFIED_CASES)
    row_count = 0
    load_count = 0
    deleted_case_count = 0
    for row in rs:
        row_count += 1
        logger.info(" Recently modified %s %s found at %s", row["case_type"], row["case_no"], row["pg_date"])
        load_cases(row["case_type"], row["case_no"])
        if row["published_flg"]:
            load_count += 1
            logger.info(" Total of %d case(s) loaded to elasticsearch successfully.", load_count)
        else:
            deleted_case_count += 1
            logger.info(" Total of %d case(s) unpublished.", deleted_case_count)

    if row_count <= 0:
        logger.info(" No recently modified cases(MUR/AF/ADR) found.")


@app.task(once={"graceful": True}, base=QueueOnce)
def daily_reload_all_aos_when_change():
    """
        # 1) Identify the daily modified AO(s) in past 24 hours(9pm-9pm EST)
        # 2) For each modified AO, find the earliest AO referenced by the modified AO
        # 3) Reload all AO(s) starting from the referenced AO to the latest AO
        # 4) Send AO detail information to Slack.
    """
    slack_message = ""
    logger.info(" Checking for daily modified AOs...")
    with db.engine.connect() as conn:
        rs = conn.execute(DAILY_MODIFIED_AOS)
        row_count = 0
        for row in rs:
            if row:
                row_count += 1
                logger.info(" Daily modified AO %s found at %s", row["ao_no"], row["pg_date"])
                logger.info(" Daily (%s) reload of all AOs ", datetime.date.today().strftime("%A"))
                load_advisory_opinions(row["ao_no"])
                slack_message = slack_message + "AO_" + str(row["ao_no"]) + " found modified at " + str(row["pg_date"])
                slack_message = slack_message + "\n"
        if row_count <= 0:
            logger.info(" No daily (%s) modified AOs found. Skip reload", datetime.date.today().strftime("%A"))
            slack_message = "No daily modified AO found."
        else:
            logger.info(
                " Daily (%s) total of %d ao(s) reload to elasticsearch successfully.",
                datetime.date.today().strftime("%A"), row_count
            )

    if slack_message:
        slack_message = slack_message + " in " + get_app_name()
        utils.post_to_slack(slack_message, SLACK_BOTS)


@app.task(once={"graceful": True}, base=QueueOnce)
def weekly_reload_all_aos():
    """
    Reload all AOs only on Sunday.
    """
    logger.info(" Weekly (%s) reload of all AOs ", datetime.date.today().strftime("%A"))
    load_advisory_opinions()
    logger.info(" Weekly (%s) reload of all AOs completed successfully", datetime.date.today().strftime("%A"))
    slack_message = "Weekly reload of all AOs completed successfully in {0} space".format(get_app_name())
    utils.post_to_slack(slack_message, SLACK_BOTS)


@app.task(once={"graceful": True}, base=QueueOnce)
def send_alert_daily_modified_legal_case():
    # When found modified case(s)(MUR/AF/ADR) during 6am-7pm EST, Send case detail information to Slack.
    slack_message = ""
    with db.engine.connect() as conn:
        rs = conn.execute(DAILY_MODIFIED_CASES_SEND_ALERT)
        row_count = 0
        for row in rs:
            row_count += 1
            if row["published_flg"]:
                slack_message = slack_message + str(row["case_type"]) + " "
                + str(row["case_no"]) + " found published at " + str(row["pg_date"])
                slack_message = slack_message + "\n"
            else:
                slack_message = slack_message + str(row["case_type"]) + " "
                + str(row["case_no"]) + " found unpublished at " + str(row["pg_date"])
                slack_message = slack_message + "\n"
    if row_count <= 0:
        slack_message = "No daily modified case (MUR/AF/ADR) found"

    if slack_message:
        slack_message = slack_message + " in " + get_app_name()
        utils.post_to_slack(slack_message, SLACK_BOTS)


@app.task(once={"graceful": True}, base=QueueOnce)
def create_es_backup():
    """
        Take Elasticsearch `CASE_INDEX` and `AO_INDEX` snapshot weekly.
    """
    index_name_list = [CASE_INDEX, AO_INDEX]
    logger.info(" Weekly (%s) elasticsearch snapshot backup starting", datetime.date.today().strftime("%A"))
    for index_name in enumerate(index_name_list):
        try:
            create_es_snapshot(index_name)
        except Exception as error:
            logger.exception(error)
            slack_message = "*ERROR* elasticsearch backup failed for {0}. Check logs.".format(get_app_name())
            utils.post_to_slack(slack_message, SLACK_BOTS)

    logger.info(" Weekly (%s) elasticsearch snapshot backup completed", datetime.date.today().strftime("%A"))
    slack_message = "Weekly elasticsearch backup completed in {0} space".format(get_app_name())
    utils.post_to_slack(slack_message, SLACK_BOTS)
