import os
import datetime

from webservices.env import env
from webservices.config import SQL_CONFIG

here, _ = os.path.split(__file__)
home = os.path.join(here, os.pardir, os.pardir)
script_path = os.path.join(home, 'data', 'sql_updates')

os.environ['AIRFLOW_CONN_POSTGRES_DEFAULT'] = os.getenv(
    'AIRFLOW_CONN_POSTGRES_DEFAULT',
    os.getenv('SQLA_CONN', 'postgresql:///cfdm_test'),
)

default_args = {
    'owner': 'fec',
    'parameters': SQL_CONFIG,
    'postgres_conn_id': 'POSTGRES_DEFAULT',
    'start_date': datetime.datetime(2016, 1, 1),
    'email': env.get_credential('FEC_EMAIL_RECIPIENTS', '').split(','),
}
