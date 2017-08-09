import os.path

import pytest
import sqlalchemy as sa
from sqlalchemy.sql import select

from manage import execute_sql_file
from webservices.rest import db


@pytest.fixture(scope="module", autouse=True)
def install_utils(app_ctx):
    execute_sql_file(os.path.join('data', 'functions', 'utils.sql'))


@pytest.mark.parametrize('year, expected_cycle', [
    (0, 0), (1, 2), (2, 2),
    (1998, 1998), (1999, 2000), (2000, 2000),
])
def test_get_cycle(year, expected_cycle):
    query = select([sa.func.get_cycle(year)])
    actual_cycle = db.engine.execute(query).scalar()
    assert actual_cycle == expected_cycle
