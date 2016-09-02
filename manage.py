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

from webservices import flow, partition
from webservices.env import env
from webservices.rest import app, db
from webservices.config import SQL_CONFIG, check_config
from webservices.common.util import get_full_path
from webservices.tasks.utils import get_bucket, get_object
from webservices import partition, utils, efile_parser
from webservices.load_legal_docs import (remove_legal_docs, index_statutes,
    index_regulations, index_advisory_opinions, load_advisory_opinions_into_s3,
    delete_advisory_opinions_from_s3)

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

def get_sections(reg):
    sections = {}
    for node in reg['children'][0]['children']:
        sections[tuple(node['label'])] = {'text': get_text(node),
                                          'title': node['title']}
    return sections


def get_text(node):
    text = ''
    if "text" in node:
        text = node["text"]
    for child in node["children"]:
        text += ' ' + get_text(child)
    return text

@manager.command
def remove_legal_docs():
    es = utils.get_elasticsearch_connection()
    es.indices.delete('docs')
    es.indices.create('docs', {"mappings": {
                             "_default_": {
                                "properties": {
                                        "no": {
                                            "type": "string",
                                            "index": "not_analyzed"
                                        }
                                    }
                                }}})

@manager.command
def index_regulations():
    eregs_api = env.get_credential('FEC_EREGS_API', '')

    if(eregs_api):
        reg_versions = requests.get(eregs_api + 'regulation').json()['versions']
        es = utils.get_elasticsearch_connection()
        reg_count = 0
        for reg in reg_versions:
            url = '%sregulation/%s/%s' % (eregs_api, reg['regulation'],
                                          reg['version'])
            regulation = requests.get(url).json()
            sections = get_sections(regulation)

            print("Loading part %s" % reg['regulation'])
            for section_label in sections:
                doc_id = '%s_%s' % (section_label[0], section_label[1])
                section_formatted = '%s-%s' % (section_label[0], section_label[1])
                reg_url = '/regulations/{0}/{1}#{0}'.format(section_formatted,
                                                            reg['version'])
                no = '%s.%s' % (section_label[0], section_label[1])
                name = sections[section_label]['title'].split(no)[1].strip()
                doc = {"doc_id": doc_id, "name": name,
                       "text": sections[section_label]['text'], 'url': reg_url,
                       "no": no}

                es.create('docs', 'regulations', doc, id=doc['doc_id'])
            reg_count += 1
        print("%d regulation parts indexed." % reg_count)
    else:
        print("Regs could not be indexed, environment variable not set.")

def legal_loaded():
    legal_loaded = db.engine.execute("""SELECT EXISTS (
                               SELECT 1
                               FROM   information_schema.tables
                               WHERE  table_name = 'ao'
                            );""").fetchone()[0]
    if not legal_loaded:
        print('Advisory opinion tables not found.')

    return legal_loaded

@manager.command
def index_advisory_opinions():
    print('Indexing advisory opinions...')

    if legal_loaded():
        count = db.engine.execute('select count(*) from AO').fetchone()[0]
        print('AO count: %d' % count)
        count = db.engine.execute('select count(*) from DOCUMENT').fetchone()[0]
        print('DOC count: %d' % count)

        es = utils.get_elasticsearch_connection()

        result = db.engine.execute("""select DOCUMENT_ID, OCRTEXT, DESCRIPTION,
                                CATEGORY, DOCUMENT.AO_ID, NAME, SUMMARY,
                                TAGS, AO_NO, DOCUMENT_DATE FROM DOCUMENT INNER JOIN
                                AO on AO.AO_ID = DOCUMENT.AO_ID""")

        docs_loaded = 0
        bucket_name = env.get_credential('bucket')
        for row in result:
            key = "legal/aos/%s.pdf" % row[0]
            pdf_url = "https://%s.s3.amazonaws.com/%s" % (bucket_name, key)
            doc = {"doc_id": row[0],
                   "text": row[1],
                   "description": row[2],
                   "category": row[3],
                   "id": row[4],
                   "name": row[5],
                   "summary": row[6],
                   "tags": row[7],
                   "no": row[8],
                   "date": row[9],
                   "url": pdf_url}

            es.create('docs', 'advisory_opinions', doc, id=doc['doc_id'])
            docs_loaded += 1

            if docs_loaded % 500 == 0:
                print("%d docs loaded" % docs_loaded)
        print("%d docs loaded" % docs_loaded)

@manager.command
def delete_advisory_opinions_from_s3():
    for obj in get_bucket().objects.filter(Prefix="legal/aos"):
        obj.delete()

@manager.command
def load_advisory_opinions_into_s3():
    if legal_loaded():
        docs_in_db = set([str(r[0]) for r in db.engine.execute(
                         "select document_id from document").fetchall()])

        bucket = get_bucket()
        docs_in_s3 = set([re.match("legal/aos/([0-9]+)\.pdf", obj.key).group(1)
                          for obj in bucket.objects.filter(Prefix="legal/aos")])

        new_docs = docs_in_db.difference(docs_in_s3)

        if new_docs:
            query = "select document_id, fileimage from document \
                    where document_id in (%s)" % ','.join(new_docs)

            result = db.engine.connect().execution_options(stream_results=True)\
                    .execute(query)

            bucket_name = env.get_credential('bucket')
            for i, (document_id, fileimage) in enumerate(result):
                key = "legal/aos/%s.pdf" % document_id
                bucket.put_object(Key=key, Body=bytes(fileimage),
                                  ContentType='application/pdf', ACL='public-read')
                url = "https://%s.s3.amazonaws.com/%s" % (bucket_name, key)
                print("pdf written to %s" % url)
                print("%d of %d advisory opinions written to s3" % (i + 1, len(new_docs)))
        else:
            print("No new advisory opinions found.")
@manager.command
def test_util():
    df = efile_parser.get_dataframe(6)
    efile_parser.parse_f3psummary_column_b(df)

if __name__ == '__main__':
    manager.run()
