import os
import sys

here, _ = os.path.split(__file__)
sys.path.insert(0, os.path.join(here, os.pardir))

import datetime

from airflow import DAG
from airflow.operators import PostgresOperator

from webservices.config import SQL_CONFIG

os.environ['AIRFLOW_CONN_POSTGRES_DEFAULT'] = os.getenv('SQLA_CONN', 'postgresql:///cfdm_test')
script_path = os.path.join(here, os.pardir, 'data', 'sql_updates')

default_args = {
    'owner': 'fec',
    'start_date': datetime.datetime(2016, 1, 1),
    'postgres_conn_id': 'POSTGRES_DEFAULT',
    'parameters': SQL_CONFIG,
}

dag = DAG(
    'refresh',
    default_args=default_args,
    template_searchpath=script_path,
    schedule_interval='0 9 * * *',
)

def script_task(path, dag):
    _, name, _ = split(path)
    return PostgresOperator(
        task_id=name,
        sql=path,
        start_date=datetime.datetime(2016, 1, 1),
        dag=dag,
    )

def split(path):
    head, tail = os.path.split(path)
    root, ext = os.path.splitext(tail)
    return head, root, ext

tasks = {
    split(path)[1]: script_task(path, dag)
    for path in os.listdir(script_path) if path.endswith('.sql')
}

tasks['candidate_detail'].set_upstream(tasks['candidate_history'])
tasks['candidate_election'].set_upstream(tasks['candidate_detail'])

tasks['committee_detail'].set_upstream(tasks['committee_history'])

tasks['filings'].set_upstream([tasks['candidate_history'], tasks['committee_history']])

tasks['totals_combined'].set_upstream([
    tasks['totals_house_senate'],
    tasks['totals_presidential'],
    tasks['totals_pac_party'],
])

tasks['committee_fulltext'].set_upstream([tasks['committee_detail'], tasks['totals_combined']])
tasks['candidate_fulltext'].set_upstream([tasks['candidate_detail'], tasks['totals_combined']])

tasks['sched_a_by_size_merged'].set_upstream(tasks['totals_combined'])
