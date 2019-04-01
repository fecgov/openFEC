"""
this is a simple scipt to test the status of all endpoints after deployment
Pls note that some endpoints need required parameters and some example data
are given hereself.
the endpoints list could be exapanded or improved in the future.

Note: on the production tier, api_key is required.

quick server list for reference:

local: http://127.0.0.1:5000
prod: https://api.open.fec.gov
stage: https://api-stage.open.fec.gov
dev: https://fec-dev-api.app.cloud.gov
"""
import os
import click
import requests
import time, math


COMMITTEE_ID = "C00496067"
CANDIDATE_ID = "P40002172"
SUB_ID = "1"
COMMITTEE_TYPE = "P"

endpoints = [
    # actblue across multiple partitions
    '/schedules/schedule_a/?api_key=NICAR16&sort_hide_null=false&'+
    'sort_nulls_last=false&data_type=processed&two_year_transaction_period'+
    '=2016&min_date=01%2F01%2F2013&max_date=12%2F31%2F2018&sort=-contribution_receipt_date'+
    '&per_page=30&committee_id=C00401224&two_year_transaction_period=2018'+
    '&two_year_transaction_period=2014',

    # 3 cycels with actblue
    '/schedules/schedule_a/?api_key=NICAR16&sort_hide_null=false&'+
    'sort_nulls_last=false&data_type=processed&two_year_transaction_period'+
    '=2018&sort=-contribution_receipt_date&per_page=30&committee_id='+
    'C00401224&two_year_transaction_period=2014&wo_year_transaction_period=2016',

    # multiple committee ids across multiple partitions
    '/schedules/schedule_a/?api_key=NICAR16&sort_hide_null=false&sort_nulls_last=false&'+
    'data_type=processed&committee_id=C00577999&committee_id=C00585810'+
    '&committee_id=C00651232&two_year_transaction_period=2016&'+
    'min_date=01%2F01%2F2013&max_date=12%2F31%2F2018&'+
    'sort=-contribution_receipt_date&per_page=30&two_year_transaction_period'+
    '=2018&two_year_transaction_period=2014',

    # schedule_b: actblue across  multiple partitions
    '/schedules/schedule_b/?api_key=NICAR16&sort_hide_null=false&'+
    'sort_nulls_last=false&data_type=processed&two_year_transaction_period'+
    '=2018&per_page=30&committee_id=C00401224&two_year_transaction_period='+
    '2014&wo_year_transaction_period=2016',

    # multiple committee ids across multiple partitions
    '/schedules/schedule_b/?api_key=NICAR16&sort_hide_null=false&sort_nulls_last=false&'+
    'data_type=processed&committee_id=C00577999&committee_id=C00585810'+
    '&committee_id=C00651232&two_year_transaction_period=2016&'+
    'min_date=01%2F01%2F2013&max_date=12%2F31%2F2018&'+
    'per_page=30&two_year_transaction_period'+
    '=2018&two_year_transaction_period=2014',

]


@click.command()
@click.option(
    "--server",
    default="https://fec-dev-api.app.cloud.gov",
    help="server to check with.",
)
@click.option(
    "--api_key",
    default=lambda: os.environ.get("FEC_API_KEY", ""),
    help="an api_key is needed for testing.",
)
def check_endpoints(server, api_key):
    """Simple script to check all endpoints status quickly."""
    for endp in endpoints:
        t1 = time.time()
        curr_request = (server + "/v1" + endp).format(
                api_key=api_key,
            )
        print('current request:\n{}'.format(curr_request))
        r = requests.get(curr_request)
        if r.status_code == 200:
            t2 = time.time()
            print("-- response comes back in: {} second.".format(round(t2-t1,2)))
        else:
            print("******{}: not working. Status: {}".format(endp,r.status_code))


if __name__ == "__main__":
    check_endpoints()
