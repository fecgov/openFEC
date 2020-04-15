import manage
from tests.common import get_test_jdbc_url
from webservices import rest

import pytest
import subprocess


@pytest.fixture(scope="session")
def migrate_db(request):
    reset_schema()
    run_migrations()
    manage.refresh_materialized(concurrent=False)

def run_migrations():
    subprocess.check_call(
        ['flyway', 'migrate', '-n', '-url={0}'.format(get_test_jdbc_url()), '-locations=filesystem:data/migrations'],)

def reset_schema():
    for schema in [
        "aouser",
        "auditsearch",
        "disclosure",
        "fecapp",
        "fecmur",
        "public",
        "rad_pri_user",
        "real_efile",
        "real_pfile",
        "rohan",
        "staging",
    ]:
        rest.db.engine.execute('drop schema if exists %s cascade;' % schema)
    rest.db.engine.execute('create schema public;')
