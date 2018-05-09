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

from webservices import flow, partition
from webservices.env import env
from webservices.rest import app, db
from webservices.config import SQL_CONFIG, check_config
from webservices.common.util import get_full_path
import webservices.legal_docs as legal_docs
from webservices.utils import post_to_slack
from webservices.tasks import cache_request

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
manager.command(legal_docs.create_docs_index)
manager.command(legal_docs.create_archived_murs_index)
manager.command(legal_docs.create_staging_index)
manager.command(legal_docs.restore_from_staging_index)
manager.command(legal_docs.delete_docs_index)
manager.command(legal_docs.move_archived_murs)
manager.command(legal_docs.initialize_current_legal_docs)
manager.command(legal_docs.refresh_current_legal_docs_zero_downtime)
manager.command(cache_request.delete_cached_calls_from_s3)

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
def refresh_itemized():
    """These are run nightly to refresh the itemized schedule A and B data."""

    refresh_itemized_a()
    refresh_itemized_b()
    rebuild_itemized_e()

    logger.info('Finished updating incremental aggregates.')

@manager.command
def refresh_itemized_a():
    """Used to refresh the itemized Schedule A data."""

    logger.info('Updating Schedule A...')
    message = partition.SchedAGroup.process_queues()

    if message[0] == 0:
        logger.info(message[1])
    else:
        logger.error(message[1])

    logger.info('Finished updating Schedule A.')

@manager.command
def refresh_itemized_b():
    """Used to refresh the itemized Schedule B data."""
    logger.info('Updating Schedule B...')
    message = partition.SchedBGroup.process_queues()

    if message[0] == 0:
        logger.info(message[1])
    else:
        logger.error(message[1])

    logger.info('Finished updating Schedule B.')

@manager.command
def rebuild_itemized_e():
    """Used to rebuild the itemized Schedule E data."""
    logger.info('Rebuilding Schedule E...')
    execute_sql_file('data/refresh/rebuild_schedule_e.sql')
    logger.info('Finished rebuilding Schedule E.')

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
def refresh_materialized(concurrent=True):
    """Refresh materialized views in dependency order
       We usually want to refresh them concurrently so that we don't block other
       connections that use the DB. In the case of tests, we cannot refresh concurrently as the
       tables are not initially populated.
    """
    logger.info('Refreshing materialized views...')

    materialized_view_names = {
        'audit_case': ['ofec_audit_case_mv', 'ofec_audit_case_category_rel_mv', 'ofec_audit_case_sub_category_rel_mv', 'ofec_committee_fulltext_audit_mv', 'ofec_candidate_fulltext_audit_mv'],
        'cand_cmte_linkage': ['ofec_cand_cmte_linkage_mv'],
        'candidate_aggregates': ['ofec_candidate_totals_mv', 'ofec_candidate_totals_with_0s_mv'],
        'candidate_detail': ['ofec_candidate_detail_mv'],
        'candidate_election': ['ofec_candidate_election_mv'],
        'candidate_flags': ['ofec_candidate_flag_mv'],
        'candidate_fulltext': ['ofec_candidate_fulltext_mv'],
        'candidate_history': ['ofec_candidate_history_mv'],
        'candidate_history_latest': ['ofec_candidate_history_latest_mv'],
        'committee_detail': ['ofec_committee_detail_mv'],
        'committee_fulltext': ['ofec_committee_fulltext_mv'],
        'committee_history': ['ofec_committee_history_mv'],
        'communication_cost': ['ofec_communication_cost_mv'],
        'communication_cost_by_candidate': ['ofec_communication_cost_aggregate_candidate_mv'],
        'election_outcome': ['ofec_election_result_mv'],
        'electioneering': ['ofec_electioneering_mv'],
        'electioneering_by_candidate': ['ofec_electioneering_aggregate_candidate_mv'],
        'elections_list': ['ofec_elections_list_mv'],
        'filing_amendments_all': ['ofec_amendments_mv'],
        'filing_amendments_house_senate': ['ofec_house_senate_paper_amendments_mv'],
        'filing_amendments_pac_party': ['ofec_pac_party_paper_amendments_mv'],
        'filing_amendments_presidential': ['ofec_presidential_paper_amendments_mv'],
        'filings': ['ofec_filings_amendments_all_mv', 'ofec_filings_mv', 'ofec_filings_all_mv'],
        'large_aggregates': ['ofec_entity_chart_mv'],
        'rad_analyst': ['ofec_rad_mv'],
        'reports_house_senate': ['ofec_reports_house_senate_mv'],
        'reports_ie': ['ofec_reports_ie_only_mv'],  # Anomale
        'reports_pac_party': ['ofec_reports_pacs_parties_mv'],
        'reports_presidential': ['ofec_reports_presidential_mv'],
        'sched_a_by_size_merged': ['ofec_sched_a_aggregate_size_merged_mv'],
        'sched_a_by_state_recipient_totals': ['ofec_sched_a_aggregate_state_recipient_totals_mv'],
        'sched_c': ['ofec_sched_c_mv'],
        'sched_e_by_candidate': ['ofec_sched_e_aggregate_candidate_mv'],
        'sched_f': ['ofec_sched_f_mv'],
        'totals_candidate_committee': ['ofec_totals_candidate_committees_mv'],
        'totals_combined': ['ofec_totals_combined_mv'],
        'totals_house_senate': ['ofec_totals_house_senate_mv'],
        'totals_ie': ['ofec_totals_ie_only_mv'],
        'totals_pac_party': ['ofec_totals_pacs_parties_mv', 'ofec_totals_pacs_mv',
                             'ofec_totals_parties_mv'],
        'totals_presidential': ['ofec_totals_presidential_mv'],
    }

    graph = flow.get_graph()

    with db.engine.begin() as connection:
        for node in nx.topological_sort(graph):
            materialized_views = materialized_view_names.get(node, None)

            if materialized_views:
                for mv in materialized_views:
                    logger.info('Refreshing %s', mv)

                    if concurrent:
                        refresh_command = 'REFRESH MATERIALIZED VIEW CONCURRENTLY {}'.format(mv)
                    else:
                        refresh_command = 'REFRESH MATERIALIZED VIEW {}'.format(mv)

                    connection.execute(
                        sa.text(refresh_command).execution_options(
                            autocommit=True
                        )
                    )
            else:
                logger.error('Error refreshing node %s: not found.'.format(node))

    logger.info('Finished refreshing materialized views.')

@manager.command
def cf_startup():
    """Migrate schemas on `cf push`."""
    check_config()
    if env.index == '0':
        subprocess.Popen(['python', 'manage.py', 'refresh_materialized'])

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
def slack_message(message):
    """ Sends a message to the bots channel. you can add this command to ping you when a task is done, etc.
    run ./manage.py slack_message 'The message you want to post'
    """
    post_to_slack(message, '#bots')


if __name__ == '__main__':
    manager.run()
