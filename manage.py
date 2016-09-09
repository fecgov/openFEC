#!/usr/bin/env python

import os
import glob
import logging
import subprocess
import multiprocessing

import networkx as nx
import sqlalchemy as sa
from flask_script import Server
from flask_script import Manager

from webservices import efile_parser, flow, partition, utils
from webservices.env import env
from webservices.rest import app, db
from webservices.config import SQL_CONFIG, check_config
from webservices.common.util import get_full_path
from webservices.tasks.utils import get_bucket, get_object
from webservices.load_legal_docs import (remove_legal_docs, index_statutes,
    index_regulations, index_advisory_opinions, load_advisory_opinions_into_s3,
    delete_advisory_opinions_from_s3, load_archived_murs, delete_murs_from_s3,
    delete_murs_from_es)

manager = Manager(app)
logger = logging.getLogger('manager')
logging.basicConfig(level=logging.INFO)

# The Flask app server should only be used for local testing, so we default to
# using debug mode and auto-reload. To disable debug mode locally, pass the
# --no-debug flag to `runserver`.
manager.add_command('runserver', Server(use_debugger=True, use_reloader=True))

manager.command(remove_legal_docs)
manager.command(index_statutes)
manager.command(index_regulations)
manager.command(index_advisory_opinions)
manager.command(load_advisory_opinions_into_s3)
manager.command(delete_advisory_opinions_from_s3)
manager.command(load_archived_murs)
manager.command(delete_murs_from_s3)
manager.command(delete_murs_from_es)

def check_itemized_queues(schedule):
    """Checks to see if the queues associated with an itemized schedule have
    been successfully cleared out and sends the information to the logs.
    """

    remaining_new_queue = db.engine.execute(
        'select count(*) from ofec_sched_{schedule}_queue_new'.format(
            schedule=schedule
        )
    ).scalar()
    remaining_old_queue = db.engine.execute(
        'select count(*) from ofec_sched_{schedule}_queue_old'.format(
            schedule=schedule
        )
    ).scalar()

    if remaining_new_queue == remaining_old_queue == 0:
        logger.info(
            'Successfully emptied Schedule {schedule} queues.'.format(
                schedule=schedule.upper()
            )
        )
    else:
        logger.warn(
            'Schedule {schedule} queues not empty ({new} new / {old} old left).'.format(
                schedule=schedule.upper(),
                new=remaining_new_queue,
                old=remaining_old_queue
            )
        )

def get_projected_weekly_itemized_totals(schedules):
    """Calculates the weekly total of itemized records that should have been
    processed at the point when the weekly aggregate rebuild takes place.
    """

    projected_weekly_totals = {}

    for schedule in schedules:
        cmd = 'select get_projected_weekly_itemized_total(\'{0}\');'.format(schedule)
        result = db.engine.execute(cmd)
        projected_weekly_totals[schedule] = result.scalar()

    return projected_weekly_totals

def get_actual_weekly_itemized_totals(schedules):
    """Retrieves the actual weekly total of itemized records that have been
    processed at the time of the weekly aggregate rebuild.
    """

    actual_weekly_totals = {}

    for schedule in schedules:
        cmd = 'select count(*) from ofec_sched_{0}_master where pg_date > current_date - interval \'7 days\';'.format(schedule)
        result = db.engine.execute(cmd)
        actual_weekly_totals[schedule] = result.scalar()

    return actual_weekly_totals

def execute_sql_file(path):
    """This helper is typically used within a multiprocessing pool; create a new database
    engine for each job.
    """
    db.engine.dispose()
    logger.info(('Running {}'.format(path)))
    with open(path) as fp:
        cmd = '\n'.join([
            line for line in fp.readlines()
            if not line.strip().startswith('--')
        ])
        db.engine.execute(sa.text(cmd), **SQL_CONFIG)

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
    """For improved search when candidates have a name that doesn't appear on their form"""
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
    """For improved search of organizations that go by acronyms"""
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
    """This updates the smaller tables and views. It is run on deploy.
    """
    logger.info("Starting DB refresh...")
    processes = int(processes)
    graph = flow.get_graph()
    for task in nx.topological_sort(graph):
        path = os.path.join('data', 'sql_updates', '{}.sql'.format(task))
        execute_sql_file(path)
    execute_sql_file('data/rename_temporary_views.sql')
    logger.info("Finished DB refresh.")

@manager.command
def update_functions(processes=1):
    """This command updates the helper functions. It is run on deploy.
    """
    execute_sql_folder('data/functions/', processes=processes)

@manager.command
def update_itemized(schedule):
    """These are the scripts that create the main schedule tables.
    Run this when you make a change to code in:
        data/sql_setup/
    """
    logger.info('Updating Schedule {0} tables...'.format(schedule))
    execute_sql_file('data/sql_setup/prepare_schedule_{0}.sql'.format(schedule))
    logger.info('Finished Schedule {0} update.'.format(schedule))

@manager.command
def rebuild_aggregates(processes=1):
    """These are the functions used to update the aggregates and schedules.
    Run this when you make a change to code in:
        data/sql_incremental_aggregates
    """
    logger.info('Rebuilding incremental aggregates...')
    execute_sql_folder('data/sql_incremental_aggregates/', processes=processes)
    logger.info('Finished rebuilding incremental aggregates.')

@manager.command
def update_aggregates():
    """These are run nightly to recalculate the totals
    """
    logger.info('Updating incremental aggregates...')

    with db.engine.begin() as connection:
        connection.execute(
            sa.text('select update_aggregates()').execution_options(
                autocommit=True
            )
        )
        logger.info('Finished updating Schedule E and support aggregates.')

    logger.info('Updating Schedule A...')
    partition.SchedAGroup.refresh_children()
    logger.info('Finished updating Schedule A.')

    logger.info('Updating Schedule B...')
    partition.SchedBGroup.refresh_children()
    logger.info('Finished updating Schedule B.')

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
    logger.info('Partitioning Schedule A...')
    partition.SchedAGroup.run()
    logger.info('Finished partitioning Schedule A.')
    logger.info('Partitioning Schedule B...')
    partition.SchedBGroup.run()
    logger.info('Finished partitioning Schedule B.')
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
    check_config()
    if env.index == '0':
        subprocess.Popen(['python', 'manage.py', 'update_schemas'])

@manager.command
def test_util():
    df = efile_parser.get_dataframe(6)
    efile_parser.parse_f3psummary_column_b(df)

if __name__ == '__main__':
    manager.run()
