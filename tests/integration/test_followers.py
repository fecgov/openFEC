import unittest
from webservices.rest import create_app
from webservices.common.models import db
from unittest.mock import patch


class FollowerRoutingTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app = create_app(test_config='follower')
        cls.app_context = cls.app.app_context()
        cls.app_context.push()

    @classmethod
    def tearDownClass(cls):
        cls.app_context.pop()

    def test_read_routes_to_follower(self):
        follower_engine = self.app.config['SQLALCHEMY_FOLLOWERS'][0]

        with patch.object(follower_engine, 'connect', wraps=follower_engine.connect) as mock_connect:
            # Run a read query
            db.session.execute("SELECT 1")
            db.session.commit()

            # Check that the follower engine was used
            self.assertGreater(mock_connect.call_count, 0, "Follower engine was not used for read query.")
