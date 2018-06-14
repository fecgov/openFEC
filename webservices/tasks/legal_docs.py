import logging

from celery_once import QueueOnce

from webservices.tasks import app
from webservices.rest import db
from webservices.legal_docs.advisory_opinions import load_advisory_opinions
from webservices.legal_docs.current_murs import load_current_murs

logger = logging.getLogger(__name__)

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
def reload_all_aos():
    logger.info("Daily reload of all AOs starting")
    load_advisory_opinions()
    logger.info("Daily reload of all AOs completed")


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
