import logging

from celery_once import QueueOnce

from webservices.tasks import app
from webservices.rest import db
from webservices.legal_docs.advisory_opinions import load_advisory_opinions

logger = logging.getLogger(__name__)

RECENTLY_MODIFIED_STARTING_AO = """
    SELECT ao_no, pg_date
    FROM aouser.aos_with_parsed_numbers
    WHERE pg_date >= NOW() - '1 day'::INTERVAL
    ORDER BY ao_year, ao_serial
    LIMIT 1;
"""

@app.task(once={'graceful': True}, base=QueueOnce)
def refresh():
    with db.engine.connect() as conn:
        refresh_aos(conn)

def refresh_aos(conn):
    row = conn.execute(RECENTLY_MODIFIED_STARTING_AO).first()
    if row:
        logger.info("AO found %s modified at %s", row["ao_no"], row["pg_date"])
        load_advisory_opinions(row["ao_no"])
    else:
        logger.info("No modified AOs found")
