#!/usr/bin/env python

import glob
import logging
import subprocess
import multiprocessing

from flask.ext.script import Server
from flask.ext.script import Manager
from sqlalchemy import text as sqla_text

from webservices.env import env
from webservices.rest import app, db
from webservices.config import SQL_CONFIG
from webservices.common.util import get_full_path


manager = Manager(app)
logger = logging.getLogger('manager')
logging.basicConfig(level=logging.INFO)

# The Flask app server should only be used for local testing, so we default to
# using debug mode and auto-reload. To disable debug mode locally, pass the
# --no-debug flag to `runserver`.
manager.add_command('runserver', Server(use_debugger=True, use_reloader=True))


def execute_sql_file(path):
    # This helper is typically used within a multiprocessing pool; create a new database
    # engine for each job.
    db.engine.dispose()
    logger.info(('Running {}'.format(path)))
    with open(path) as fp:
        cmd = '\n'.join([
            line for line in fp.readlines()
            if not line.startswith('--')
        ])
        db.engine.execute(sqla_text(cmd), **SQL_CONFIG)

def execute_sql_folder(path, processes):
    sql_dir = get_full_path(path)
    if not sql_dir.endswith('/'):
        sql_dir += '/'
    paths = sorted(glob.glob(sql_dir + '*.sql'))
    if processes > 1:
        pool = multiprocessing.Pool(processes=processes)
        pool.map(execute_sql_file, sorted(paths))
    else:
        for path in paths:
            execute_sql_file(path)

@manager.command
def load_nicknames():
    import pandas as pd
    import sqlalchemy as sa
    try:
        table = sa.Table('ofec_nicknames', db.metadata, autoload_with=db.engine)
        db.engine.execute(table.delete())
    except sa.exc.NoSuchTableError:
        pass
    load_table(pd.read_csv('data/nicknames.csv'), 'ofec_nicknames', if_exists='append')

@manager.command
def load_pacronyms():
    import pandas as pd
    import sqlalchemy as sa
    try:
        table = sa.Table('ofec_pacronyms', db.metadata, autoload_with=db.engine)
        db.engine.execute(table.delete())
    except sa.exc.NoSuchTableError:
        pass
    load_table(pd.read_excel('data/pacronyms.xlsx'), 'ofec_pacronyms', if_exists='append')

def load_table(frame, tablename, if_exists='replace', indexes=()):
    import sqlalchemy as sa
    frame.to_sql(tablename, db.engine, if_exists=if_exists)
    table = sa.Table(tablename, db.metadata, autoload_with=db.engine)
    for index in indexes:
        sa.Index('{}_{}_idx'.format(tablename, index), table.c[index]).create(db.engine)

@manager.command
def build_districts():
    import pandas as pd
    load_table(pd.read_csv('data/fips_states.csv'), 'ofec_fips_states')
    load_table(pd.read_csv('data/natl_zccd_delim.csv'), 'ofec_zips_districts', indexes=('ZCTA', ))

@manager.command
def load_election_dates():
    import pandas as pd
    frame = pd.read_excel('data/election_dates.xlsx')
    frame.columns = [column.lower() for column in frame.columns]
    load_table(
        frame, 'ofec_election_dates',
        indexes=('office', 'state', 'district', 'election_yr', 'senate_class'),
    )

@manager.command
def dump_districts(dest=None):
    source = db.engine.url
    dest = dest or './data/districts.dump'
    cmd = (
        'pg_dump {source} --format c --no-acl --no-owner -f {dest} '
        '-t ofec_fips_states -t ofec_zips_districts'
    ).format(**locals())
    subprocess.call(cmd, shell=True)

@manager.command
def load_districts(source=None):
    source = source or './data/districts.dump'
    dest = db.engine.url
    cmd = (
        'pg_restore --dbname {dest} --no-acl --no-owner --clean {source}'
    ).format(**locals())
    subprocess.call(cmd, shell=True)

@manager.command
def build_district_counts(outname='districts.json'):
    import utils
    utils.write_district_counts(outname)

@manager.command
def update_schemas(processes=1):
    logger.info("Starting DB refresh...")
    processes = int(processes)
    execute_sql_folder('data/sql_updates/', processes=processes)
    execute_sql_file('data/rename_temporary_views.sql')
    logger.info("Finished DB refresh.")

@manager.command
def update_functions(processes=1):
    execute_sql_folder('data/functions/', processes=processes)

@manager.command
def update_itemized(schedule):
    logger.info('Updating Schedule {0} tables...'.format(schedule))
    execute_sql_file('data/sql_setup/prepare_schedule_{0}.sql'.format(schedule))
    logger.info('Finished Schedule {0} update.'.format(schedule))

@manager.command
def rebuild_aggregates(processes=1):
    logger.info('Rebuilding incremental aggregates...')
    execute_sql_folder('data/sql_incremental_aggregates/', processes=processes)
    logger.info('Finished rebuilding incremental aggregates.')

@manager.command
def update_aggregates():
    logger.info('Updating incremental aggregates...')
    db.engine.execute('select update_aggregates()')
    logger.info('Finished updating incremental aggregates.')

@manager.command
def update_all(processes=1):
    """Update all derived data. Warning: Extremely slow on production data.
    """
    processes = int(processes)
    update_functions(processes=processes)
    load_districts()
    load_pacronyms()
    load_nicknames()
    load_election_dates()
    update_itemized('a')
    update_itemized('b')
    update_itemized('e')
    rebuild_aggregates(processes=processes)
    update_schemas(processes=processes)

@manager.command
def refresh_materialized():
    """Refresh materialized views."""
    logger.info('Refreshing materialized views...')
    execute_sql_file('data/refresh_materialized_views.sql')
    logger.info('Finished refreshing materialized views.')

@manager.command
def cf_startup():
    """Migrate schemas on `cf push`."""
    if env.index == '0':
        subprocess.Popen(['python', 'manage.py', 'update_schemas'])

if __name__ == '__main__':
    manager.run()
