# -*- coding: utf-8 -*-
"""Load testing for the API and web app. Run from the root directory using the

`locust --host=https://api-stage.open.fec.gov/v1/` (stage)
`locust --host=https://api.open.fec.gov/v1/` (prod)
`locust --host=https://fec-dev-api.app.cloud.gov/v1/` (dev)

command, then open localhost:8089 to run tests.
"""

import os
import random
import resource

import locust


# Avoid "Too many open files" error
resource.setrlimit(resource.RLIMIT_NOFILE, (9999, 999999))

API_KEY = os.environ["FEC_API_KEY"]

# it seems like AUTH is NOT used for current tests
try:
    AUTH = (os.environ["FEC_USERNAME"], os.environ["FEC_PASSWORD"])
except KeyError:
    AUTH = None

CYCLES = range(1980, 2018, 2)
CANDIDATES = [
    "bush" "cheney",
    "gore",
    "lieberman",
    "kerry",
    "edwards",
    "obama",
    "biden",
    "mccain",
    "palin",
    "clinton",
    "sanders" "omalley",
    "rubio",
    "graham",
    "kasich",
]
TERMS = ["embezzle", "email", "department", "contribution", "commission"]

# TODO: Add more small
small_records_sched_a = [
    {"contributor_name": "Teachout Zephyr"},
    {"contributor_state": "GU"},
]

medium_records_sched_a = [
    # this one gave us issues before because it was mid-sized about 21,000
    {"committee_id": "C00496067"},
    # these seemed mid sized on a given two year period
    {"contributor_city": "Fresno"},
    {"contirbutor_city": "Sedona"},
    {"contributor_occupation": "government"},
]

large_records_sched_a = [
    {"committee_id": "C00401224"},
    {
        "committee_id": [
            "C00401224",
            "C00003418",
            "C00010603",
            "C00027466",
            "C00005561",
            "C00484642",
        ]
    },
    {"contributor_state": "NY"},
    {"contributor_state": "TX"},
    # some common last names in the US
    {"contributor_name": "Smith"},
    {"contributor_name": "Johnson"},
    # seeing this problem in production
    {
        "data_type": "processed",
        "sort_hide_null": "true",
        "committee_id": "C00401224",
        "two_year_transaction_period": 2016,
        "min_date": "07/01/2016",
        "max_date": "07/31/2016",
        "sort": "-contribution_receipt_date",
        "per_page": 30,
    },
]


# took the worst performing queries from the log https://logs.fr.cloud.gov/goto/be56820fc05ef241c62c5641f16dcd3e
poor_performance_a = [
    {
        "sort_nulls_large": True,
        "contributor_name": "paul+johnson",
        "two_year_transaction_period": 2014,
        "min_date": "01%2F01%2F2013",
        "max_date": "12%2F31%2F2014",
        "contributor_state": "IN",
        "sort": "-contribution_receipt_date",
        "per_page": 30,
        "is_individual": True,
    },
    {
        "sort_nulls_large": True,
        "contributor_name": "Robert+F+Pence",
        "two_year_transaction_period": 2014,
        "min_date": "01%2F01%2F2013",
        "max_date": "12%2F31%2F2014",
        "sort": "-contribution_receipt_date",
        "per_page": 100,
        "is_individual": True,
    },
    {
        "sort_nulls_large": True,
        "contributor_name": "tom+lewis",
        "contributor_name": "thomas+lewis",
        "two_year_transaction_period": 2016,
        "min_date": "01%2F01%2F2015",
        "max_date": "12%2F31%2F2016",
        "sort": "-contribution_receipt_amount",
        "per_page": 30,
        "is_individual": True,
    },
    {
        "sort_nulls_large": True,
        "contributor_name": "Becher%2C+S",
        "two_year_transaction_period": 2016,
        "min_date": "01%2F01%2F2015",
        "max_date": "12%2F31%2F2016&",
        "contributor_state": "FL",
        "sort": "-contribution_receipt_date",
        "per_page": 30,
        "is_individual": True,
    },
    {
        "sort_nulls_large": True,
        "contributor_name": "Becher",
        "two_year_transaction_period": 2016,
        "min_date": "01%2F01%2F2015",
        "max_date": "12%2F31%2F2016",
        "contributor_state": "FL",
        "sort": "-contribution_receipt_date",
        "per_page": 30,
        "is_individual": True,
    },
]

poor_performance_b = [
    {
        "sort_nulls_large": True,
        "two_year_transaction_period": 2016,
        "per_page": 100,
        "sort": "disbursement_date",
        "last_disbursement_date": "2016-03-03",
        "last_index": 4070720161305573871,
    },
    {
        "sort_nulls_large": True,
        "two_year_transaction_period": 2016,
        "per_page": 100,
        "sort": "disbursement_date",
        "last_disbursement_date": "2016-03-03",
        "last_index": 4062420161300286190,
    },
    {
        "sort_nulls_large": True,
        "two_year_transaction_period": 2016,
        "per_page": 100,
        "sort": "disbursement_date",
        "last_disbursement_date": "2016-03-03",
        "last_index": 4062120161299938749,
    },
    {
        "sort_nulls_large": True,
        "two_year_transaction_period": 2016,
        "per_page": 100,
        "sort": "disbursement_date",
        "last_disbursement_date": "2016-03-03",
        "last_index": 4061720161299122923,
    },
    {
        "sort_nulls_large": True,
        "two_year_transaction_period": 2016,
        "per_page": 100,
        "sort": "disbursement_date",
        "last_disbursement_date": "2016-03-03",
        "last_index": 4061720161299122723,
    },
]


def get_random_date():
    """
    A handy function to get a random date
    e.g. '2018-01-01'
    # TODO: could be updated to something like this:
    https://stackoverflow.com/questions/553303/
    generate-a-random-date-between-two-other-dates
    """
    month = random.choice(range(1, 13))
    year = random.choice(range(1979, 2019))
    date = random.choice(range(1, 29))
    if len(str(date)) == 1:
        date = "0" + str(date)
    return "{y}-{m}-{d}".format(y=str(year), m=str(month), d=str(date))


class Tasks(locust.TaskSet):
    def on_start(self):
        self.candidates = self.fetch_ids("candidates", "candidate_id")
        self.committees = self.fetch_ids("committees", "committee_id")

    def fetch_ids(self, endpoint, key):
        params = {"api_key": API_KEY}
        resp = self.client.get(endpoint, name="preload_ids", params=params)
        print("*********fetch_ids response:{}".format(resp))
        return [result[key] for result in resp.json()["results"]]

    @locust.task
    def load_home(self):
        params = {"api_key": API_KEY}
        self.client.get("", name="home", params=params)

    @locust.task
    def test_download(self):
        """
        a quick test on downlaod api. this test need to generate a aynamic query
        each time in order to be queued for celery processing.
        the filename payload is optional(cms ajax call do pass in a filename each time.)
        """
        rand_date = get_random_date()
        _year = int(rand_date.split("-")[0])
        _cycle = (_year + 1) if _year % 2 == 1 else _year

        params = {
            "api_key": API_KEY,
            "sort_hide_null": False,
            "sort_nulls_last": False,
            "two_year_transaction_period": _cycle,
            "min_date": rand_date,
            "max_date": rand_date,
            "sort": "-contribution_receipt_date",
            "is_individual": True,
        }
        payload = {"filename": "f_" + rand_date + ".csv"}
        self.client.post(
            "download/schedules/schedule_a",
            name="download",
            params=params,
            json=payload,
        )

    @locust.task
    def load_candidates_search(self, term=None):
        term = term or random.choice(CANDIDATES)
        params = {"api_key": API_KEY, "sort": "-receipts", "q": term}
        self.client.get("candidates/search", name="candidate_search", params=params)

    @locust.task
    def load_committees_search(self, term=None):
        term = term or random.choice(CANDIDATES)
        params = {"api_key": API_KEY, "sort": "-receipts", "q": term}
        self.client.get("committees", name="committee_search", params=params)

    @locust.task
    def load_candidates_table(self):
        params = {
            "cycle": [random.choice(CYCLES) for _ in range(3)],
            "api_key": API_KEY,
        }
        self.client.get("candidates", name="candidates_table", params=params)

    @locust.task
    def load_committees_table(self):
        params = {
            "cycle": [random.choice(CYCLES) for _ in range(3)],
            "api_key": API_KEY,
        }
        self.client.get("committees", name="committees_table", params=params)

    @locust.task
    def load_candidate_detail(self, candidate_id=None):
        params = {"api_key": API_KEY}
        candidate_id = candidate_id or random.choice(self.candidates)
        self.client.get(
            os.path.join("candidate", candidate_id),
            name="candidate_detail",
            params=params,
        )

    @locust.task
    def load_committee_detail(self, committee_id=None):
        params = {"api_key": API_KEY}
        committee_id = committee_id or random.choice(self.committees)
        self.client.get(
            os.path.join("committee", committee_id),
            name="committee_detail",
            params=params,
        )

    @locust.task
    def load_candidate_totals(self, candidate_id=None):
        params = {"api_key": API_KEY}
        candidate_id = candidate_id or random.choice(self.candidates)
        self.client.get(
            os.path.join("candidate", candidate_id, "totals"),
            name="candidate_totals",
            params=params,
        )

    @locust.task
    def load_committee_totals(self, committee_id=None):
        params = {"api_key": API_KEY}
        committee_id = committee_id or random.choice(self.committees)
        self.client.get(
            os.path.join("committee", committee_id, "totals"),
            name="committee_totals",
            params=params,
        )

    @locust.task
    def load_legal_documents_search(self, term=None):
        term = term or random.choice(CANDIDATES)
        params = {"q": term, "api_key": API_KEY}
        self.client.get("legal/search", name="legal_search", params=params)

    @locust.task
    def get_mur(self):
        params = {"api_key": API_KEY}
        self.client.get("legal/docs/murs/7074", name="legal_get_mur", params=params)

    @locust.task
    def get_adr(self):
        params = {"api_key": API_KEY}
        self.client.get("legal/docs/adrs/668", name="legal_get_adr", params=params)

    @locust.task
    def get_admin_fine(self):
        params = {"api_key": API_KEY}
        self.client.get(
            "legal/docs/admin_fines/2274", name="legal_get_admin_fine", params=params
        )

    @locust.task
    def get_ao(self):
        params = {"api_key": API_KEY}
        self.client.get(
            "legal/docs/advisory_opinions/2018-07", name="legal_get_ao", params=params
        )

    @locust.task
    def load_schedule_a_small(self):
        params = random.choice(small_records_sched_a)
        params["api_key"] = API_KEY
        self.client.get("schedules/schedule_a/", name="schedule_a_small", params=params)

    @locust.task
    def load_schedule_a_medium(self):
        params = random.choice(medium_records_sched_a)
        params["api_key"] = API_KEY
        self.client.get(
            "schedules/schedule_a/", name="schedule_a_medium", params=params
        )

    @locust.task
    def load_schedule_a_large(self):
        params = random.choice(large_records_sched_a)
        params["api_key"] = API_KEY
        self.client.get(
            "schedules/schedule_a/", name="load_schedule_a_large", params=params
        )

    @locust.task
    def load_schedule_a_problematic(self):
        params = random.choice(poor_performance_a)
        params["api_key"] = API_KEY
        self.client.get(
            "schedules/schedule_a/", name="load_schedule_a_problematic", params=params
        )

    @locust.task
    def load_schedule_b_problematic(self):
        params = random.choice(poor_performance_b)
        params["api_key"] = API_KEY
        self.client.get(
            "schedules/schedule_b/", name="load_schedule_b_problematic", params=params
        )

    @locust.task
    def load_audit_category(self):
        params = {"api_key": API_KEY}
        self.client.get("audit-category/", name="load_audit_category", params=params)

    @locust.task
    def load_filings(self):
        params = {"api_key": API_KEY}
        self.client.get("filings/", name="load_filings", params=params)

    @locust.task
    def load_totals(self):
        params = {"api_key": API_KEY}
        self.client.get("totals/P/", name="load_totals", params=params)

    @locust.task
    def load_reports(self):
        params = {"api_key": API_KEY}
        self.client.get("reports/P/", name="load_reports", params=params)


class Swarm(locust.HttpLocust):
    task_set = Tasks
    min_wait = 5000
    max_wait = 50000
