#!/usr/bin/env python

import os
import glob
import logging
import shlex
import subprocess
import multiprocessing

import networkx as nx
import sqlalchemy as sa
from flask_script import Server
from flask_script import Manager

from webservices import flow
from webservices.env import env
from webservices.rest import app, db
from webservices.config import SQL_CONFIG, check_config
from webservices.common.util import get_full_path
import webservices.legal_docs as legal_docs

manager = Manager(app)
logger = logging.getLogger('manager')

# The Flask app server should only be used for local testing, so we default to
# using debug mode and auto-reload. To disable debug mode locally, pass the
# --no-debug flag to `runserver`.
manager.add_command('runserver', Server(use_debugger=True, use_reloader=True))

manager.command(legal_docs.delete_advisory_opinions_from_es)
manager.command(legal_docs.delete_murs_from_es)
manager.command(legal_docs.delete_murs_from_s3)
manager.command(legal_docs.index_regulations)
manager.command(legal_docs.index_statutes)
manager.command(legal_docs.load_archived_murs)
manager.command(legal_docs.load_advisory_opinions)
manager.command(legal_docs.load_current_murs)
manager.command(legal_docs.initialize_legal_docs)
manager.command(legal_docs.create_staging_index)
manager.command(legal_docs.restore_from_staging_index)
manager.command(legal_docs.delete_index)
manager.command(legal_docs.reinitialize_all_legal_docs)
manager.command(legal_docs.refresh_legal_docs_zero_downtime)

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
        cmd = 'select count(*) from ofec_sched_{0}_master where pg_date > current_date - interval \'7 days\';'.format(
            schedule)
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
    """For improved search when candidates have a name that doesn't appear on their form.
    Additional nicknames can be added to the csv for improved search.
    """

    logger.info('Loading nicknames...')

    import pandas as pd
    import sqlalchemy as sa

    try:
        table = sa.Table(
            'ofec_nicknames',
            db.metadata,
            autoload_with=db.engine
        )
        db.engine.execute(table.delete())
    except sa.exc.NoSuchTableError:
        pass

    load_table(
        pd.read_csv('data/nicknames.csv'),
        'ofec_nicknames',
        if_exists='append'
    )

    logger.info('Finished loading nicknames.')

@manager.command
def load_pacronyms():
    """For improved search of organizations that go by acronyms
    """

    logger.info('Loading pacronyms...')

    import pandas as pd
    import sqlalchemy as sa

    try:
        table = sa.Table(
            'ofec_pacronyms',
            db.metadata,
            autoload_with=db.engine
        )
        db.engine.execute(table.delete())
    except sa.exc.NoSuchTableError:
        pass

    load_table(
        pd.read_excel('data/pacronyms.xlsx'),
        'ofec_pacronyms',
        if_exists='append'
    )

    logger.info('Finished loading pacronyms.')

def load_table(frame, tablename, if_exists='replace', indexes=()):
    import sqlalchemy as sa
    frame.to_sql(tablename, db.engine, if_exists=if_exists)
    table = sa.Table(tablename, db.metadata, autoload_with=db.engine)
    for index in indexes:
        sa.Index('{}_{}_idx'.format(tablename, index), table.c[index]).create(db.engine)

@manager.command
def build_districts():
    """This creats the zipcode mapping for Congress based on data that is save as csvs.
    """
    import pandas as pd
    load_table(pd.read_csv('data/fips_states.csv'), 'ofec_fips_states')
    load_table(pd.read_csv('data/natl_zccd_delim.csv'), 'ofec_zips_districts', indexes=('ZCTA', ))

@manager.command
def load_election_dates():
    """ This is from before we had direct access to election data and needed it, we are still using the
    data from a csv, to populate the ElectionClassDate model.
    """

    logger.info('Loading election dates...')

    import pandas as pd
    frame = pd.read_excel('data/election_dates.xlsx')
    frame.columns = [column.lower() for column in frame.columns]
    load_table(
        frame, 'ofec_election_dates',
        indexes=('office', 'state', 'district', 'election_yr', 'senate_class'),
    )

    logger.info('Finished loading election dates.')

@manager.command
def dump_districts(dest=None):
    """ Makes districts locally that you can then add as a table to the databases
    """
    source = db.engine.url

    if dest is None:
        dest = './data/districts.dump'
    else:
        dest = shlex.quote(dest)

    cmd = (
        'pg_dump "{source}" --format c --no-acl --no-owner -f {dest} '
        '-t ofec_fips_states -t ofec_zips_districts'
    ).format(**locals())
    subprocess.run(cmd, shell=True)

@manager.command
def load_districts(source=None):
    """ Loads that districts that you made locally so that you can then add them as a
    table to the databases
    """

    logger.info('Loading districts...')

    if source is None:
        source = './data/districts.dump'
    else:
        source = shlex.quote(source)

    dest = db.engine.url
    cmd = (
        'pg_restore --dbname "{dest}" --no-acl --no-owner --clean {source}'
    ).format(**locals())
    subprocess.run(cmd, shell=True)
    logger.info('Finished loading districts.')

@manager.command
def build_district_counts(outname='districts.json'):
    """ Compiles the districts for a state
    """
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
    execute_sql_file('data/converted_mvs/sched_a_by_size_merged.sql')
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
def partition_itemized(schedule):
    """This command runs the partitioning against the specified itemized
    schedule table.
    """
    logger.info('Partitioning Schedule %s...', schedule)
    execute_sql_file('data/sql_partition/partition_schedule_{0}.sql'.format(schedule))
    logger.info('Finished partitioning Schedule %s.', schedule)

@manager.command
def index_itemized(schedule):
    """This command (re-)creates the indexes for the itemized schedule table
    partition and removes any old ones.
    Run this when you make changes to the index definitions on the itemized
    schedule A and B data but do not need to do a full repartition.
    """
    logger.info('(Re-)indexing Schedule %s...', schedule)
    execute_sql_file('data/sql_partition/index_schedule_{0}.sql'.format(schedule))
    logger.info('Finished (re-)indexing Schedule %s.', schedule)

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

@manager.command
def add_itemized_partition_cycle(cycle=None, amount=1):
    """Adds a new itemized cycle child table.
    By default this will try to add just the current cycle to all partitioned
    itemized schedule tables if it doesn't already exist.
    If the child table already exists, skip over it.
    """

    amount = int(amount)

    if not cycle:
        cycle = SQL_CONFIG['CYCLE_END_YEAR_ITEMIZED']
    else:
        cycle = int(cycle)

    logger.info('Adding Schedule A and B cycles...')
    try:
        with db.engine.begin() as connection:
            connection.execute(
                sa.text('SELECT add_partition_cycles(:start_year, :count)').execution_options(
                    autocommit=True
                ),
                start_year=cycle,
                count=amount
            )
        logger.info('Finished adding Schedule A and B cycles.')
    except Exception:
        logger.exception("Failed to add partition cycles")

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
    partition_itemized('a')
    partition_itemized('b')
    rebuild_aggregates(processes=processes)
    update_schemas(processes=processes)

@manager.command
def refresh_materialized():
    """Refresh materialized views nightly
    """
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
def load_efile_sheets():
    """Run this management command if there are changes to incoming efiling data structures.
    It will make the json mapping from the spreadsheets you provide it
    """
    import pandas as pd
    sheet_map = {4: 'efile_guide_f3', 5: 'efile_guide_f3p', 6: 'efile_guide_f3x'}
    for i in range(4, 7):
        table = sheet_map.get(i)
        df = pd.read_excel(
            # /Users/jonathancarmack/Documents/repos/openFEC
            io="data/real_efile_to_form_line_numbers.xlsx",
            #index_col="summary line number",
            sheetname=i,
            skiprows=7,

        )
        df = df.fillna(value="N/A")
        df = df.rename(columns={'fecp column name (column a value)': 'fecp_col_a',
                                'fecp column name (column b value)': 'fecp_col_b',
                                })
        form_column = table.split('_')[2] + " line number"
        columns_to_drop = ['summary line number', form_column, 'Unnamed: 5']
        df.drop(columns_to_drop, axis=1, inplace=True)
        df.to_json(path_or_buf="data/" + table + ".json", orient='values')

@manager.command
def refresh_calendar():
    """ Refreshes calendar data
    """
    with db.engine.begin() as connection:
        connection.execute('REFRESH MATERIALIZED VIEW CONCURRENTLY ofec_omnibus_dates_mv')


if __name__ == '__main__':
    manager.run()
