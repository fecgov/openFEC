"""
The connection with FEC's Oracle machine tends to break 
before very large INSERT INTO ... SELECT ... commands can
run against it.  So, for the largest tables, I hacked
together a script to 

Before running it, set the values in ``ranges`` to enclose 
the lowest and largest primary key values (in FEC) of the
tables in question.

This table should exist in Postgresql *on the bridge machine*
(rather than on RDS):

	DROP TABLE IF EXISTS synch_successes;
	CREATE TABLE synch_successes (table_name text not null, 
				      begin_sk bigint not null, 
				      end_sk bigint not null,
				      success bool,
				      err_msg text);

TODO: Make this script idempotent - so we can simply re-run it
      to examine synch_successes and retry chunks that failed

      Or maybe just come up with a better approach altogether
"""

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
