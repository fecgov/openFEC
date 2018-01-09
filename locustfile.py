# -*- coding: utf-8 -*-
"""Load testing for the API and web app. Run from the root directory using the
`locust --host=https://api-stage.open.fec.gov/v1/` command, then open localhost:8089 to run tests.
Note: Locust must be run with Python 2.
"""

import os
import random
import resource

import locust


# Avoid "Too many open files" error
resource.setrlimit(resource.RLIMIT_NOFILE, (9999, 999999))


API_KEY = os.environ['FEC_API_KEY']

try:
    AUTH = (os.environ['FEC_USERNAME'], os.environ['FEC_PASSWORD'])
except KeyError:
    AUTH = None

CYCLES = range(1980, 2018, 2)
CANDIDATES = [
    'bush'
    'cheney',
    'gore',
    'lieberman',
    'kerry',
    'edwards',
    'obama',
    'biden',
    'mccain',
    'palin',
    'clinton',
    'sanders'
    'omalley',
    'rubio',
    'graham',
    'kasich',
]
TERMS = [
    'embezzle',
    'email',
    'department',
    'contribution',
    'commission'
]

class Tasks(locust.TaskSet):

    def on_start(self):
        self.candidates = self.fetch_ids('candidates', 'candidate_id')
        self.committees = self.fetch_ids('committees', 'committee_id')

    def fetch_ids(self, endpoint, key):
        params = {
            'api_key': API_KEY,
        }
        resp = self.client.get(endpoint, name='preload_ids', params=params)
        return [result[key] for result in resp.json()['results']]

    @locust.task
    def load_home(self):
        params = {
            'api_key': API_KEY,
        }
        self.client.get('', name='home', params=params)

    @locust.task
    def load_candidates_search(self, term=None):
        term = term or random.choice(CANDIDATES)
        params = {
            'api_key': API_KEY,
            'sort': '-receipts',
            'q': term,
        }
        self.client.get('candidates/search', name='candidate_search', params=params)

    @locust.task
    def load_committees_search(self, term=None):
        term = term or random.choice(CANDIDATES)
        params = {
            'api_key': API_KEY,
            'sort': '-receipts',
            'q': term,
        }
        self.client.get('committees', name='committee_search', params=params)

    @locust.task
    def load_candidates_table(self):
        params = {
            'cycle': [random.choice(CYCLES) for _ in range(3)],
            'api_key': API_KEY,
        }
        self.client.get('candidates', name='candidates_table', params=params)

    @locust.task
    def load_committees_table(self):
        params = {
            'cycle': [random.choice(CYCLES) for _ in range(3)],
            'api_key': API_KEY,
        }
        self.client.get('committees', name='committees_table', params=params)

    @locust.task
    def load_candidate_detail(self, candidate_id=None):
        params = {
            'api_key': API_KEY,
        }
        candidate_id = candidate_id or random.choice(self.candidates)
        self.client.get(os.path.join('candidate', candidate_id), name='candidate_detail', params=params)

    @locust.task
    def load_committee_detail(self, committee_id=None):
        params = {
            'api_key': API_KEY,
        }
        committee_id = committee_id or random.choice(self.committees)
        self.client.get(os.path.join('committee', committee_id), name='committee_detail', params=params)

    @locust.task
    def load_candidate_totals(self, candidate_id=None):
        params = {
            'api_key': API_KEY,
        }
        candidate_id = candidate_id or random.choice(self.candidates)
        self.client.get(os.path.join('candidate', candidate_id, 'totals'), name='candidate_totals', params=params)

    @locust.task
    def load_committee_totals(self, committee_id=None):
        params = {
            'api_key': API_KEY,
        }
        committee_id = committee_id or random.choice(self.committees)
        self.client.get(os.path.join('committee', committee_id, 'totals'), name='committee_totals', params=params)

    @locust.task
    def load_legal_documents_search(self, term=None):
        term = term or random.choice(CANDIDATES)
        params = {
            'q': term,
            'api_key': API_KEY,
        }
        self.client.get('legal/search', name='legal_search', params=params)

    @locust.task
    def get_document(self, term=None):
        params = {
            'api_key': API_KEY,
        }
        self.client.get('/legal/matter-under-review/7074/', name='legal_get', params=params)

class Swarm(locust.HttpLocust):
    task_set = Tasks
    min_wait = 5000
    max_wait = 10000
