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

from locust_log_queries import log_queries

# Avoid "Too many open files" error
resource.setrlimit(resource.RLIMIT_NOFILE, (9999, 999999))

API_KEY = os.environ["FEC_API_KEY"]
#DOWNLOAD_KEY = os.environ["FEC_DOWNLOAD_API_KEY"]


class Tasks(locust.TaskSet):

    @locust.task
    def load_big_queries(self, term=None):
        endpoint = random.choice(list(log_queries.keys()))
        params = random.choice(log_queries[endpoint])
        params["api_key"] = API_KEY
        self.client.get(endpoint, name="load_big_queries", params=params)



class Swarm(locust.HttpLocust):
    task_set = Tasks
    min_wait = 5000
    max_wait = 50000
