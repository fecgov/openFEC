import datetime

import sqlalchemy as sa

from webservices.env import env
from webservices.common.models import db


def get_cycle_start(year):
    """Round year down to the first year of the two-year election cycle. Used
    when filtering original data for election cycle.
    """
    return year if year % 2 == 1 else year - 1

def get_cycle_end(year):
    """Round year up to the last year of the two-year election cycle. Used
    when querying partitioned itemized data for election cycle.
    """
    return year if year % 2 == 0 else year + 1

CURRENT_YEAR = datetime.datetime.now().year

SQL_CONFIG = {
    'START_YEAR': get_cycle_start(1980),
    'START_YEAR_AGGREGATE': get_cycle_start(2008),
    'END_YEAR_ITEMIZED': get_cycle_start(CURRENT_YEAR),
    # CYCLE_END_YEAR_ITEMIZED will need to be updated every cycle
    # once we have meaningful data
    'CYCLE_END_YEAR_ITEMIZED': 2018,
    'PARTITION_START_YEAR': 1978,
    'PARTITION_END_YEAR': 2018,
}

REQUIRED_CREDS = (
    'SQLA_CONN',
    'FEC_SLACK_TOKEN',
)

REQUIRED_SERVICES = ('redis32', 's3', 'elasticsearch24')

REQUIRED_TABLES = (
    tuple(db.Model.metadata.tables.keys()) +
    (
        'ofec_pacronyms',
        'ofec_nicknames',
        'ofec_zips_districts',
    )
)

def load_table(name):
    try:
        return sa.Table(name, db.metadata, autoload_with=db.engine)
    except sa.exc.NoSuchTableError:
        return None

def check_keys(keys, getter, formatter):
    missing = [key for key in keys if getter(key) is None]
    if missing:
        print(formatter.format(', '.join(keys)))
    return missing

CHECKS = [
    (REQUIRED_CREDS, env.get_credential, 'Missing creds {}'),
    (REQUIRED_SERVICES, lambda service: env.get_service(label=service), 'Missing services {}'),
    (REQUIRED_TABLES, load_table, 'Missing tables {}'),
]

def check_config():
    results = [check_keys(*check) for check in CHECKS]
    if any(results):
        raise RuntimeError('Invalid configuration: {0}'.format(results))
