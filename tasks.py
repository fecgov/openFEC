from invoke import run
from invoke import task


DEFAULT_FRACTION = 0.015
FULL_TABLES = [
    'dimdates',
    'dimparty',
    'dimyears',
    'dimoffice',
    'dimreporttype',
]
EXCLUDE_TABLES = [
    '*_mv',
    '*_tmp',
    '*_old',
    'sched_a',
    'sched_b',
    'ofec_two_year_periods',
]
# Include Nancy Pelosi and John Boehner for debugging purposes
FORCE_INCLUDE = [
    ('dimcand', 10024584),
    ('dimcand', 10034937),
]


@task
def fetch_schemas(source, dest):
    cmd = 'pg_dump {0} --format c --schema-only --no-acl --no-owner'.format(source)
    for table in (FULL_TABLES + EXCLUDE_TABLES):
        cmd += ' --exclude-table {0}'.format(table)
    cmd += ' | pg_restore --dbname {0} --no-acl --no-owner'.format(dest)
    run(cmd, echo=True)


@task
def fetch_full(source, dest):
    cmd = 'pg_dump {0} --format c --no-acl --no-owner'.format(source)
    for table in FULL_TABLES:
        cmd += ' --table {0}'.format(table)
    cmd += ' | pg_restore --dbname {0} --no-acl --no-owner'.format(dest)
    run(cmd, echo=True)


@task
def fetch_subset(source, dest, fraction=DEFAULT_FRACTION):
    cmd = 'rdbms-subsetter {source} {dest} {fraction}'.format(**locals())
    for table in (FULL_TABLES + EXCLUDE_TABLES):
        cmd += ' --exclude-table {0}'.format(table)
    for table, key in FORCE_INCLUDE:
        cmd += ' --force {0}:{1}'.format(table, key)
    cmd += ' --config data/subset-config.json'
    cmd += ' --yes'
    run(cmd, echo=True)


@task
def build_test(source, dest, fraction=DEFAULT_FRACTION):
    fetch_full(source, dest)
    fetch_schemas(source, dest)
    fetch_subset(source, dest, fraction=fraction)


@task
def dump(source, dest):
    cmd = 'pg_dump {source} --no-acl --no-owner -f {dest}'.format(**locals())
    for table in EXCLUDE_TABLES:
        cmd += ' --exclude-table {0}'.format(table)
    run(cmd, echo=True)
