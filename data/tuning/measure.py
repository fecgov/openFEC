import os
import time
import requests
import sqlalchemy as sa
from sqlalchemy.sql import text

username = os.getenv('NGINX_USERNAME')
password = os.getenv('NGINX_PASSWORD')
inserter = text("""INSERT INTO tuning_test (requirement_id, initial, seconds, error_msg)
                   VALUES (:req_id, :initial, :seconds, :error_msg)""")

def run_tuning_tests(conn_str, id=None):
    engine = sa.create_engine(conn_str)
    connection = engine.connect()
    if id is None:
        tuning_reqs = connection.execute('SELECT * FROM tuning_requirement')
    else:
        tuning_reqs = connection.execute(text('''SELECT * FROM tuning_requirement
                                                 WHERE id = :req_id'''), req_id=id)        
    for tuning_req in tuning_reqs:
        begin_time = time.monotonic()
        if tuning_req.type == 'sql':
            try:
                connection.execute(tuning_req.txt)
                error = 'NULL'
            except Exception as err:
                result = 'NULL'
                error = str(err)
        elif tuning_req.type == 'url':
            try:
                result = requests.get(tuning_req.txt, auth=(username, password))
                error = 'NULL'
            except Exception as err:
                result = 'NULL'
                error = str(err)
        else:
            print('%s tests not supported' % tuning_req.type)
            continue
        print(result)
        elapsed = time.monotonic() - begin_time
        is_initial = (tuning_req.status == 'untested')
        connection.execute(inserter, req_id=tuning_req.id, initial=is_initial, 
                                     seconds=elapsed, error_msg=error)
        connection.execute(text('''UPDATE tuning_requirement SET status = 'tested' 
                                   WHERE id = :req_id'''), req_id=tuning_req.id)
    return result
