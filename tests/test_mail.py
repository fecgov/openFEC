import io

import mock
import pytest
import mandrill

from webservices import mail

@pytest.fixture
def environ(monkeypatch):
    monkeypatch.setenv('MANDRILL_API_KEY', '12345')
    monkeypatch.setenv('FEC_EMAIL_SENDER', 'cj@whitehouse.gov')
    monkeypatch.setenv('FEC_EMAIL_RECIPIENTS', 'toby@whitehouse.gov')
    monkeypatch.setenv('VCAP_APPLICATION', '{"name": "api", "space-name": "dev"}')

@pytest.fixture
def client():
    return mock.Mock()

@pytest.fixture
def login(monkeypatch, client):
    login = mock.Mock()
    login.return_value = client
    monkeypatch.setattr(mandrill, 'Mandrill', login)
    return login

class TestHelpers:

    def test_get_subject(self):
        settings = {
            'space-name': 'dev',
            'name': 'api',
        }
        assert mail.get_subject(settings) == 'FEC Update: dev | api'

    def test_get_subject_missing(self):
        assert mail.get_subject({}) == 'FEC Update: unknown-space | unknown-app'

    def test_get_recipients(self):
        res = mail.get_recipients('cj@whitehouse.gov,toby@whitehouse.gov')
        assert res == [
            {'email': 'cj@whitehouse.gov'},
            {'email': 'toby@whitehouse.gov'},
        ]

class TestSendMail:

    def test_send(self, environ, login, client):
        buffer = io.StringIO('message')
        mail.send_mail(buffer)
        login.assert_called_once_with('12345')
        message = {
            'text': 'message',
            'subject': 'FEC Update: dev | api',
            'from_email': 'cj@whitehouse.gov',
            'to': [{'email': 'toby@whitehouse.gov'}],
        }
        client.messages.send.assert_called_once_with(message=message, async=False)
