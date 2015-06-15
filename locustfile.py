# -*- coding: utf-8 -*-
"""Load testing for the API and web app. Run from the root directory using the
`locust` command, then open localhost:8089 to run tests. Note: Locust must be
run with Python 2.
"""

import os
import random

import furl
import locust


WEB_URL = 'https://open.fec.gov'
API_URL = 'https://api.open.fec.gov/v1'
API_KEY = os.environ['FEC_API_KEY']

try:
    AUTH = (os.environ['FEC_USERNAME'], os.environ['FEC_PASSWORD'])
except KeyError:
    AUTH = None

CYCLES = range(1980, 2018, 2)
TERMS = [
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


class Tasks(locust.TaskSet):

    def on_start(self):
        self.client.auth = AUTH
        self.candidate_ids = self.fetch_ids('candidates', 'candidate_id')
        self.committee_ids = self.fetch_ids('committees', 'committee_id')

    def fetch_ids(self, endpoint, key):
        url = furl.furl(API_URL)
        url.path.add(endpoint)
        url.args.update({'api_key': API_KEY})
        resp = self.client.get(url.url)
        return [result[key] for result in resp.json()['results']]

    @locust.task
    def load_home(self):
        self.client.get('/', name='home')

    @locust.task
    def load_candidates_search(self, term=None):
        term = term or random.choice(TERMS)
        url = furl.furl('/')
        url.args.update({
            'search_type': 'candidates',
            'search': term,
        })
        self.client.get(url.url, name='candidate_search')

    @locust.task
    def load_committees_search(self, term=None):
        term = term or random.choice(TERMS)
        url = furl.furl('/')
        url.args.update({
            'search_type': 'committees',
            'search': term,
        })
        self.client.get(url.url, name='committee_search')

    @locust.task
    def load_candidates_table(self):
        url = furl.furl(API_URL)
        url.path.add('candidates')
        url.args.update({
            'cycle': [random.choice(CYCLES) for _ in range(3)],
            'api_key': API_KEY,
        })
        self.client.get(url.url, name='candidates_table')

    @locust.task
    def load_committees_table(self):
        url = furl.furl(API_URL)
        url.path.add('committees')
        url.args.update({
            'cycle': [random.choice(CYCLES) for _ in range(3)],
            'api_key': API_KEY,
        })
        self.client.get(url.url, name='committees_table')

    @locust.task
    def load_candidate_detail(self, candidate_id=None):
        candidate_id = candidate_id or random.choice(self.candidate_ids)
        self.client.get(os.path.join('/candidate', candidate_id), name='candidate_detail')

    @locust.task
    def load_committee_detail(self, committee_id=None):
        committee_id = committee_id or random.choice(self.committee_ids)
        self.client.get(os.path.join('/committee', committee_id), name='committee_detail')


class Swarm(locust.HttpLocust):
    task_set = Tasks
    host = WEB_URL
    min_wait = 5000
    max_wait = 10000
