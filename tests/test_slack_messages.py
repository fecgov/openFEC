from unittest.mock import patch
from webservices.tasks.legal_docs import (
    daily_reload_all_aos_when_change,
    send_alert_daily_modified_legal_case,
    send_alert_daily_modified_rulemakings,
    SLACK_BOTS,
)
from tests.common import BaseTestCase


class TestSlackMessages(BaseTestCase):

    def setUp(self):
        super().setUp()
        self.slack_patcher = patch("webservices.utils.post_to_slack")
        self.mock_slack = self.slack_patcher.start()
        self.execute_patcher = patch("sqlalchemy.engine.Connection.execute")
        self.mock_execute = self.execute_patcher.start()

    def tearDown(self):
        self.execute_patcher.stop()
        self.slack_patcher.stop()
        super().tearDown()

    def _mock_rows(self, rows):
        self.mock_execute.return_value.mappings.return_value = rows

    @patch("webservices.tasks.legal_docs.get_app_name", return_value="test-app")
    @patch("webservices.tasks.legal_docs.load_advisory_opinions")
    def test_aos_slack_message_with_modified_aos(self, mock_load, mock_app_name):
        self._mock_rows([
            {"ao_no": "2024-01", "pg_date": "2024-01-15 10:00:00"},
            {"ao_no": "2024-02", "pg_date": "2024-01-15 11:00:00"},
        ])
        daily_reload_all_aos_when_change()
        self.mock_slack.assert_called_with(
            "AO_2024-01 found modified at 2024-01-15 10:00:00\n"
            "AO_2024-02 found modified at 2024-01-15 11:00:00\n"
            " in test-app",
            SLACK_BOTS
        )

    @patch("webservices.tasks.legal_docs.get_app_name", return_value="test-app")
    @patch("webservices.tasks.legal_docs.load_advisory_opinions")
    def test_aos_slack_message_no_modified_aos(self, mock_load, mock_app_name):
        self._mock_rows([])
        daily_reload_all_aos_when_change()
        self.mock_slack.assert_called_with("No daily modified AO found. in test-app", SLACK_BOTS)

    @patch("webservices.tasks.legal_docs.get_app_name", return_value="test-app")
    def test_cases_slack_message_with_published_case(self, mock_app_name):
        self._mock_rows([
            {"case_type": "MUR", "case_no": "1234", "pg_date": "2024-01-15 10:00:00", "published_flg": True},
        ])
        send_alert_daily_modified_legal_case()
        self.mock_slack.assert_called_with("MUR 1234 found published at 2024-01-15 10:00:00\n in test-app", SLACK_BOTS)

    @patch("webservices.tasks.legal_docs.get_app_name", return_value="test-app")
    def test_cases_slack_message_with_unpublished_case(self, mock_app_name):
        self._mock_rows([
            {"case_type": "AF", "case_no": "5678", "pg_date": "2024-01-15 11:00:00", "published_flg": False},
        ])
        send_alert_daily_modified_legal_case()
        self.mock_slack.assert_called_with("AF 5678 found unpublished at 2024-01-15 11:00:00\n in test-app", SLACK_BOTS)

    @patch("webservices.tasks.legal_docs.get_app_name", return_value="test-app")
    def test_cases_slack_message_mixed(self, mock_app_name):
        self._mock_rows([
            {"case_type": "MUR", "case_no": "1234", "pg_date": "2024-01-15 10:00:00", "published_flg": True},
            {"case_type": "AF",  "case_no": "5678", "pg_date": "2024-01-15 11:00:00", "published_flg": False},
            {"case_type": "ADR", "case_no": "9999", "pg_date": "2024-01-15 12:00:00", "published_flg": True},
        ])
        send_alert_daily_modified_legal_case()
        self.mock_slack.assert_called_with(
            "MUR 1234 found published at 2024-01-15 10:00:00\n"
            "AF 5678 found unpublished at 2024-01-15 11:00:00\n"
            "ADR 9999 found published at 2024-01-15 12:00:00\n"
            " in test-app",
            SLACK_BOTS
        )

    @patch("webservices.tasks.legal_docs.get_app_name", return_value="test-app")
    def test_cases_slack_message_no_modified_cases(self, mock_app_name):
        self._mock_rows([])
        send_alert_daily_modified_legal_case()
        self.mock_slack.assert_called_with(
            "No daily modified case (MUR/AF/ADR) found in test-app", SLACK_BOTS)

    @patch("webservices.tasks.legal_docs.get_app_name", return_value="test-app")
    def test_rulemakings_slack_message_with_published(self, mock_app_name):
        self._mock_rows([
            {"rm_no": "2024-01", "pg_date": "2024-01-15 10:00:00", "published_flg": True},
        ])
        send_alert_daily_modified_rulemakings()
        self.mock_slack.assert_called_with(
            "Rulemaking 2024-01 found published at 2024-01-15 10:00:00\n in test-app", SLACK_BOTS)

    @patch("webservices.tasks.legal_docs.get_app_name", return_value="test-app")
    def test_rulemakings_slack_message_with_unpublished(self, mock_app_name):
        self._mock_rows([
            {"rm_no": "2024-02", "pg_date": "2024-01-15 11:00:00", "published_flg": False},
        ])
        send_alert_daily_modified_rulemakings()
        self.mock_slack.assert_called_with(
            "Rulemaking 2024-02 found unpublished at 2024-01-15 11:00:00\n in test-app", SLACK_BOTS)

    @patch("webservices.tasks.legal_docs.get_app_name", return_value="test-app")
    def test_rulemakings_slack_message_mixed(self, mock_app_name):
        self._mock_rows([
            {"rm_no": "2024-01", "pg_date": "2024-01-15 10:00:00", "published_flg": True},
            {"rm_no": "2024-02", "pg_date": "2024-01-15 11:00:00", "published_flg": False},
            {"rm_no": "2024-03", "pg_date": "2024-01-15 12:00:00", "published_flg": True},
        ])
        send_alert_daily_modified_rulemakings()
        self.mock_slack.assert_called_with(
            "Rulemaking 2024-01 found published at 2024-01-15 10:00:00\n"
            "Rulemaking 2024-02 found unpublished at 2024-01-15 11:00:00\n"
            "Rulemaking 2024-03 found published at 2024-01-15 12:00:00\n"
            " in test-app",
            SLACK_BOTS
        )

    @patch("webservices.tasks.legal_docs.get_app_name", return_value="test-app")
    def test_rulemakings_slack_message_no_results(self, mock_app_name):
        self._mock_rows([])
        send_alert_daily_modified_rulemakings()
        self.mock_slack.assert_called_with("No daily modified rulemakings found in test-app", SLACK_BOTS)
