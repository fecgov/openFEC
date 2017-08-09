import os

import pytest

from webservices.rest import app


@pytest.fixture(scope="session")
def app_ctx():
    app.config['TESTING'] = True
    conn_str = os.getenv('SQLA_TEST_CONN', 'postgresql:///cfdm_unit_test')
    app.config['SQLALCHEMY_DATABASE_URI'] = conn_str
    with app.app_context():
        yield
