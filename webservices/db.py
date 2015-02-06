import os
from datetime import datetime
from psycopg2._range import DateTimeRange

from flask import g
import htsql
import sqlalchemy as sa


def sqla_conn_string():
    sqla_conn_string = os.getenv('SQLA_CONN')
    if not sqla_conn_string:
        print("Environment variable SQLA_CONN is empty; running against "
              + "local `cfdm_test`")
        sqla_conn_string = 'postgresql://:@/cfdm_test'
    return sqla_conn_string


def db_conn():
    if not hasattr(g, '_db_conn'):
        engine = sa.create_engine(sqla_conn_string())
        g._db_conn = engine.connect()
    return g._db_conn


def htsql_conn():
    if not hasattr(g, '_htsql_conn'):
        htsql_conn_string = sqla_conn_string().replace('postgresql', 'pgsql')
        g._htsql_conn = htsql.HTSQL(htsql_conn_string)
    return g._htsql_conn

def as_dicts(data):
    """
    Because HTSQL results render as though they were lists (field info lost)
    without intervention.
    """
    if isinstance(data, htsql.core.domain.Record):
        return dict(zip(data.__fields__, [as_dicts(d) for d in data]))
    elif isinstance(data, DateTimeRange):
        return {'begin': data.upper, 'end': data.lower}
    elif (isinstance(data, htsql.core.domain.Product)
            or isinstance(data, list)):
        return [as_dicts(d) for d in data]
    else:
        return data
