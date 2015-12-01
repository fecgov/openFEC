import logging

import mandrill

from webservices.env import env

logger = logging.getLogger(__name__)

class CaptureLogs:

    def __init__(self, logger, buffer):
        self.logger = logger
        self.buffer = buffer

    def __enter__(self):
        self.formatter = logging.Formatter(
            fmt='%(asctime)s %(levelname)s:%(name)s:%(message)s',
            datefmt='%Y-%m-%d %H:%M:%S',
        )

        self.handler = logging.StreamHandler(self.buffer)
        self.handler.setFormatter(self.formatter)
        self.handler.setLevel(logging.INFO)

        self.logger.addHandler(self.handler)

    def __exit__(self, exc_type, exc_value, exc_tb):
        self.logger.removeHandler(self.handler)

def send_mail(buffer):
    client = mandrill.Mandrill(env.get_credential('MANDRILL_API_KEY'))
    message = {
        'text': buffer.getvalue(),
        'subject': get_subject(env.app),
        'from_email': env.get_credential('FEC_EMAIL_SENDER'),
        'to': get_recipients(env.get_credential('FEC_EMAIL_RECIPIENTS')),
    }
    client.messages.send(message=message, async=False)

def get_subject(settings):
    return 'FEC Update: {space} | {app}'.format(
        space=settings.get('space_name', 'unknown-space'),
        app=settings.get('name', 'unknown-app'),
    )

def get_recipients(recipients):
    return [
        {'email': each}
        for each in recipients.split(',')
    ]
