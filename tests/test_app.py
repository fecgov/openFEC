from flask import current_app
from tests.common import BaseTestCase
from sqlalchemy import text
import unittest
from unittest.mock import patch
from webservices.rest import create_app
from webservices.common.models import db


class TestBaseTestCase(BaseTestCase):
    def test_db_connection(self):
        result = self.connection.execute(text("SELECT 1")).scalar()
        self.assertEqual(result, 1, "Database is not connected")

    def test_app_context_exists(self):
        self.assertIsNotNone(current_app, "BROKEN")

    def test_client_is_available(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 301)

    def test_home_page(self):
        response = self.client.get('/developers/')
        assert response.status_code == 200

    def test_redirect_page(self):
        response = self.client.get('/')
        assert response.status_code == 301

    def test_cors_headers(self):
        response = self.client.get('/swagger')
        assert "Access-Control-Allow-Origin" in response.headers
        assert response.headers["Access-Control-Allow-Origin"] == "*"


class StatementTimeoutTest(unittest.TestCase):
    """Test statement_timeout configuration - should only apply to follower (read-only) databases."""
    def test_follower_engines_have_statement_timeout(self):
        """Test that follower (read-only) database engines ARE configured with statement_timeout."""
        with patch.dict('os.environ', {'SQLA_STATEMENT_TIMEOUT': '30000'}):
            app = create_app(test_config='follower')
            app_context = app.app_context()
            app_context.push()

            try:
                # Get the follower engines
                follower_engines = app.config.get('SQLALCHEMY_FOLLOWERS', [])

                # Skip test if no followers configured
                if not follower_engines:
                    self.skipTest("No follower engines configured")

                for follower_engine in follower_engines:
                    self.assertIsNotNone(follower_engine)

                    # Execute a query to verify the timeout is set
                    with follower_engine.connect() as conn:
                        result = conn.execute(text("SHOW statement_timeout")).scalar()
                        self.assertIsNotNone(result, "Follower should have statement_timeout configured")
                        # Verify it's not the default (should be 30s or 30000ms)
                        self.assertNotEqual(result, '0', "Follower statement_timeout should not be 0")

            finally:
                app_context.pop()

    def test_statement_timeout_only_on_followers(self):
        """Test that statement_timeout is only applied to followers, not primary."""
        with patch.dict('os.environ', {'SQLA_STATEMENT_TIMEOUT': '60000'}):
            app = create_app(test_config='follower')
            app_context = app.app_context()
            app_context.push()

            try:
                primary_engine = db.engine
                follower_engines = app.config.get('SQLALCHEMY_FOLLOWERS', [])

                if not follower_engines:
                    self.skipTest("No follower engines configured")

                # Primary should NOT have timeout
                with primary_engine.connect() as conn:
                    primary_timeout = conn.execute(text("SHOW statement_timeout")).scalar()
                    self.assertEqual(primary_timeout, '0', "Primary should not have statement_timeout")

                # Followers SHOULD have timeout
                with follower_engines[0].connect() as conn:
                    follower_timeout = conn.execute(text("SHOW statement_timeout")).scalar()
                    self.assertNotEqual(follower_timeout, '0', "Follower should have statement_timeout")

            finally:
                app_context.pop()
