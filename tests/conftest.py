import manage
from tests import common
from webservices.common.models import db
from flask import current_app


import pytest
import subprocess
import logging
from webservices.rest import create_app


@pytest.fixture(scope="session")
def migrate_db():
    app = create_app(test_config="testing")
    with app.app_context():
        reset_schema()
        run_migrations()
        manage.refresh_materialized(concurrent=False)


def run_migrations():
    subprocess.check_call(
        [
            'flyway',
            'migrate',
            '-url={0}'.format(common.get_test_jdbc_url()),
            '-locations=filesystem:data/migrations',
        ],
    )


def reset_schema():
    if current_app.config['TESTING']:
        with db.engine.connect() as conn:
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
                "test_efile",
            ]:
                conn.execute('drop schema if exists %s cascade;' % schema)
            conn.execute('create schema public;')


def pytest_addoption(parser):
    parser.addoption(
        "--no-linting",
        action="store_true",
        default=False,
        help="Skip linting checks",
    )
    parser.addoption(
        "--linting",
        action="store_true",
        default=False,
        help="Only run linting checks",
    )


def pytest_collection_modifyitems(session, config, items):
    if config.getoption("--no-linting"):
        items[:] = [item for item in items if not item.get_closest_marker('flake8')]
    if config.getoption("--linting"):
        items[:] = [item for item in items if item.get_closest_marker('flake8')]


def pytest_configure(config):
    """Flake8 is very verbose by default. Silence it."""
    logging.getLogger("flake8").setLevel(logging.WARNING)
