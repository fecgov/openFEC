import threading
import requests

BASE_URL = "https://fec-dev-api.app.cloud.gov//v1/download/"

DOWNLOAD_PATHS = [
    "schedules/schedule_a/?contributor_zip=59601&two_year_transaction_period=2022",
    "schedules/schedule_a/?contributor_zip=57501&two_year_transaction_period=2022",
    "schedules/schedule_a/?contributor_zip=05401&two_year_transaction_period=2022",
    "schedules/schedule_a/?contributor_zip=87501&two_year_transaction_period=2022",
    "schedules/schedule_a/?contributor_zip=58501&two_year_transaction_period=2022",
    "schedules/schedule_a/?contributor_zip=40601&two_year_transaction_period=2022",
    "schedules/schedule_a/?contributor_zip=83702&two_year_transaction_period=2022",
    "schedules/schedule_a/?contributor_zip=97401&two_year_transaction_period=2022",
    "schedules/schedule_a/?contributor_zip=68502&two_year_transaction_period=2022",
    "schedules/schedule_a/?contributor_zip=72201&two_year_transaction_period=2022",
]


def post(path):
    url = BASE_URL + path
    try:
        resp = requests.post(url, timeout=15)
        print(f"[{resp.status_code}] {url}  {resp.json()}")
    except Exception as exc:
        print(f"[ERR] {url}  {exc}")


threads = [threading.Thread(target=post, args=(path,)) for path in DOWNLOAD_PATHS]

for t in threads:
    t.start()
for t in threads:
    t.join()
