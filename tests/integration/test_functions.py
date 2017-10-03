import datetime

from webservices.rest import db
from tests import common


class TestViews(common.IntegrationTestCase):
    def test_last_day_of_month(self):
        connection = db.engine.connect()
        fixtures = [
            (datetime.datetime(1999, 3, 21, 10, 20, 30), datetime.datetime(1999, 3, 31, 0, 0, 0)),
            (datetime.datetime(2007, 4, 21, 10, 20, 30), datetime.datetime(2007, 4, 30, 0, 0, 0)),
            (datetime.datetime(2017, 2, 21, 10, 20, 30), datetime.datetime(2017, 2, 28, 0, 0, 0)),
        ]
        for fixture in fixtures:
            test_value, expected = fixture
            returned_date = connection.execute("SELECT last_day_of_month(%s)", test_value).scalar()

            assert returned_date == expected
