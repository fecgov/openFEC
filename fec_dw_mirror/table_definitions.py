"""
Uses Blaze to create empty tables in PostgreSQL corresponding (roughly!)
to those in FEC's Oracle data warehouse
"""
import blaze
import sqlalchemy as sa
engine = sa.create_engine("oracle://READONLY:password-not-in-version-control@172.16.129.22/PROCUAT")
pg_engine = sa.create_engine("postgresql://:@/cfdm")

table_names = [
    'sched_h1',
    'sched_h2',
    'sched_h3',
    'sched_h4',
    'sched_h5',
    'dimcand',
    'dimcandoffice',
    'dimcandproperties',
    'dimcandstatusici',
    'dimcmte',
    'dimcmteproperties',
    'dimcmtetpdsgn',
    'dimdates',
    'dimlinkages',
    'dimoffice',
    'dimparty',
    'dimreporttype',
    'dimyears',
    'dimelectiontp',
    'facthousesenate_f3',
    'factpresidential_f3p',
    'factpacsandparties_f3x',
    'log_audit_dml',
    'log_audit_module',
    'log_audit_process',
    'log_dml_errors',
    'form_56',
    'form_57',
    'form_65',
    'form_76',
    'form_82',
    'form_83',
    'form_91',
    'form_94',
    'form_105',
    'sched_a',
    'sched_b',
    'sched_c',
    'sched_c1',
    'sched_c2',
    'sched_d',
    'sched_e',
    'sched_f',
    'sched_h6',
    'sched_l',
    'sched_i',
]
# queried by SELECT '''' || LOWER(TABLE_NAME) || ''',' FROM ALL_TABLES WHERE OWNER = 'CFDM';
# can't query in blaze from ALL_TABLES because it's a view...

for table_name in table_names:
    ora = blaze.SQL (engine, 'CFDM.%s' % table_name)
    pg = blaze.SQL (pg_engine, table_name, schema=ora.schema)
