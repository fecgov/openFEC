import sqlalchemy as sa

from webservices.env import env
from webservices.common.models import db


def get_cycle_start(year):
    """Round year down to the first year of the two-year election cycle. Used
    when filtering original data for election cycle.
    """
    return year if year % 2 == 1 else year - 1

SQL_CONFIG = {
    'START_YEAR': get_cycle_start(1980),
    'START_YEAR_AGGREGATE': get_cycle_start(2008),
    'START_YEAR_ITEMIZED': get_cycle_start(2012),
    'END_YEAR_ITEMIZED': get_cycle_start(2016),
}

REQUIRED_CREDS = (
    'SQLA_CONN',

    'FEC_SLACK_TOKEN',

    'MANDRILL_API_KEY',
    'FEC_EMAIL_SENDER',
    'FEC_EMAIL_RECIPIENTS',
)

REQUIRED_SERVICES = ('redis28-swarm', 's3', 'elasticsearch-swarm-1.7.1')

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
        raise RuntimeError('Invalid configuration')
