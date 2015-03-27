import os
from flask import g
import sqlalchemy as sa


def sqla_conn_string():
    sqla_conn_string = os.getenv('SQLA_CONN')
    if not sqla_conn_string:
        print("Environment variable SQLA_CONN is empty; running against local `cfdm_test`")
        sqla_conn_string = 'postgresql://:@/cfdm_test'
    return sqla_conn_string


def db_conn():
    if not hasattr(g, '_db_conn'):
        engine = sa.create_engine(sqla_conn_string())
        g._db_conn = engine.connect()
    return g._db_conn
