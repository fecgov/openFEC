import json
import redis

from tests.common import ApiBaseTest
from unittest.mock import patch, MagicMock
from webservices.api_setup import api
from webservices.resources.monitoring import celery_check
from webservices.tasks.service_status_checks import heartbeat
from webservices.tasks.utils import set_redis_value, get_redis_value


class TestMonitoring(ApiBaseTest):

    def test_celery_status_up(self):
        mock_value = {"celery-is-running": True}

        with patch("webservices.resources.monitoring.get_redis_value", return_value=mock_value):

            response = self.app.get(api.url_for(celery_check))
            assert response.status_code == 200
            data = json.loads(response.data)
            assert data["status"] == "ok"

    def test_celery_status_down(self):
        with patch("webservices.resources.monitoring.get_redis_value", return_value={}):
            response = self.app.get(api.url_for(celery_check))
            assert response.status_code == 503
            data = json.loads(response.data)
            assert data["status"] == "down"
            assert "No Celery workers responding" in data["message"]

    def test_celery_check_redis_down(self):
        with patch("webservices.resources.monitoring.get_redis_value", side_effect=redis.ConnectionError):
            response = self.app.get(api.url_for(celery_check))
            assert response.status_code == 503
            assert response.json["status"] == "down"
            assert "Redis connection error" in response.json["message"]

    @patch("webservices.tasks.service_status_checks.set_redis_value")
    def test_heartbeat_sets_redis_value(self, mock_set):
        heartbeat()
        mock_set.assert_called_once_with(
            "CELERY_STATUS",
            {"celery-is-running": True},
            age=40
        )

    @patch("webservices.tasks.utils.get_redis_instance")
    def test_set_redis_value(self, mock_get_redis_instance):
        mock_redis = MagicMock()
        mock_get_redis_instance.return_value = mock_redis

        set_redis_value("FOO", {"bar": "baz"}, age=600)

        mock_redis.set.assert_called_once_with("FOO", json.dumps({"bar": "baz"}), ex=600)

    @patch("webservices.tasks.utils.get_redis_instance")
    def test_get_redis_value_found(self, mock_get_redis_instance):
        mock_redis = MagicMock()
        mock_redis.get.return_value = json.dumps({"bar": "baz"})
        mock_get_redis_instance.return_value = mock_redis

        result = get_redis_value("FOO")

        mock_redis.get.assert_called_once_with("FOO")
        assert result == {"bar": "baz"}

    @patch("webservices.tasks.utils.get_redis_instance")
    def test_get_redis_value_not_found(self, mock_get_redis_instance):
        mock_redis = MagicMock()
        mock_redis.get.return_value = None
        mock_get_redis_instance.return_value = mock_redis

        result = get_redis_value("FOO", fallback={"bar": "default"})

        mock_redis.get.assert_called_once_with("FOO")
        assert result == {"bar": "default"}

    @patch("webservices.tasks.utils.get_redis_instance")
    def test_get_redis_value_empty(self, mock_get_redis_instance):
        mock_redis = MagicMock()
        mock_redis.get.return_value = ""
        mock_get_redis_instance.return_value = mock_redis

        result = get_redis_value("FOO", fallback={"bar": "default"})

        mock_redis.get.assert_called_once_with("FOO")
        assert result == {"bar": "default"}
