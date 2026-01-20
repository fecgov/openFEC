from flask import current_app
from tests.common import BaseTestCase
from sqlalchemy import text


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
