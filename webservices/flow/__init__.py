import os

here, _ = os.path.split(__file__)
home = os.path.join(here, os.pardir, os.pardir)
script_path = os.path.join(home, 'data', 'sql_updates')

import datetime

from webservices.config import SQL_CONFIG

os.environ['AIRFLOW_CONN_POSTGRES_DEFAULT'] = os.getenv('SQLA_CONN', 'postgresql:///cfdm_test')

default_args = {
    'owner': 'fec',
    'start_date': datetime.datetime(2016, 1, 1),
    'postgres_conn_id': 'POSTGRES_DEFAULT',
    'parameters': SQL_CONFIG,
}
