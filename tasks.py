from invoke import run
from invoke import task

DEFAULT_FRACTION = 0.015
FULL_TABLES = [
    'dimparty',
    'dimoffice',
    'dimyears',
]
EXCLUDE_TABLES = [
    'sched_a',
    'sched_b',
]


@task
def fetch_schemas(source, dest):
    cmd = 'pg_dump {0} --schema-only --no-owner'.format(source)
    for table in EXCLUDE_TABLES:
        cmd += ' --exclude-table {0}'.format(table)
    cmd += ' | psql {0}'.format(dest)
    run(cmd)


@task
def fetch_full(source, dest):
    cmd = 'pg_dump {0} --no-owner'.format(source)
    for table in FULL_TABLES:
        cmd += ' --table {0}'.format(table)
    cmd += ' | psql {0}'.format(dest)
    run(cmd, echo=True)


@task
def fetch_subset(source, dest, fraction=DEFAULT_FRACTION):
    cmd = 'rdbms-subsetter {source} {dest} {fraction}'.format(**locals())
    for table in (FULL_TABLES + EXCLUDE_TABLES):
        cmd += ' --exclude-table {0}'.format(table)
    cmd += ' --config data/subset-config.json'
    cmd += ' --yes'
    run(cmd, echo=True)


@task
def build_test(source, dest, fraction=DEFAULT_FRACTION):
    fetch_schemas(source, dest)
    fetch_full(source, dest)
    fetch_subset(source, dest, fraction=fraction)


@task
def dump(source, dest):
    cmd = 'pg_dump {source} --no-owner -f {dest}'.format(**locals())
    run(cmd, echo=True)
