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
    WHERE pg_date >= NOW() - '1 day'::INTERVAL
    ORDER BY ao_year, ao_serial
    LIMIT 1;
"""

RECENTLY_MODIFIED_MURS = """
    SELECT case_no, pg_date
    FROM fecmur.cases_with_parsed_case_serial_numbers
    WHERE pg_date >= NOW() - '1 day'::INTERVAL
    ORDER BY case_serial
"""

@app.task(once={'graceful': True}, base=QueueOnce)
def refresh():
    with db.engine.connect() as conn:
        refresh_aos(conn)
        refresh_murs(conn)


def refresh_aos(conn):
    row = conn.execute(RECENTLY_MODIFIED_STARTING_AO).first()
    if row:
        logger.info("AO found %s modified at %s", row["ao_no"], row["pg_date"])
        load_advisory_opinions(row["ao_no"])
    else:
        logger.info("No modified AOs found")


def refresh_murs(conn):
    rs = conn.execute(RECENTLY_MODIFIED_MURS)
    if rs:
        for row in rs:
            logger.info("Current MUR found %s modified at %s", row["case_no"], row["pg_date"])
            load_current_murs(row["case_no"])
    else:
        logger.info("No modified current MURs found")
