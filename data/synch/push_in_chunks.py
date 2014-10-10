#DROP TABLE IF EXISTS synch_successes;
#CREATE TABLE synch_successes (table_name text not null, 
#begin_sk bigint not null, 
#end_sk bigint not null,
#success bool,
#err_msg text);

import subprocess

feedback = ''
off_set = 0
increment = 100000
ranges = { 'sched_a': (784000000, 999000000),
           'sched_b': (739000000, 999000000), }

for table_name in ranges:
    key_min, key_max = ranges[table_name]
    for chunk_min in range(key_min, key_max, increment):
        chunk_max = chunk_min + increment - 1
        insert = """psql -c "
        INSERT INTO newdownload.%s SELECT * FROM frn.%s 
        WHERE %s_sk BETWEEN %d AND %d
        " cfdm""" % (table_name, table_name, table_name, 
                     chunk_min, chunk_max)
        print(insert)
        (exit_code, feedback) = subprocess.getstatusoutput(insert)
        log_insert = """psql -c "
        INSERT INTO synch_successes (table_name, begin_sk, end_sk, success, err_msg)
        VALUES ('%s', %d, %d, %s, '%s') " cfdm """ % (
                                             table_name, chunk_min, chunk_max,
                                             (not exit_code), feedback.replace("'", "''"))
        print(log_insert)
        (exit_code, feedback) = subprocess.getstatusoutput(log_insert)
