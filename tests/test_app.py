from flask import current_app
from tests.common import BaseTestCase


class TestBaseTestCase(BaseTestCase):
    def test_db_connection(self):
        result = self.connection.execute("SELECT 1").scalar()
        self.assertEqual(result, 1, "Database is not connected")

    def test_app_context_exists(self):
        self.assertIsNotNone(current_app, "BROKEN")

    def test_client_is_available(self):
        response = self.client.get("/")
        self.assertEqual(response.status_int, 301, "Test client request failed")

    def test_home_page(self):
        response = self.client.get('/developers/')
        assert response.status_code == 200

    def test_redirect_page(self):
        response = self.client.get('/')
        assert response.status_code == 301
