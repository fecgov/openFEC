"""
this is a simple scipt to test the status of all endpoints after deployment
Pls note that some endpoints need required parameters and some example data
are given hereself.
the endpoints list could be exapanded or improved in the future.
"""
import os
import click
import requests

API_KEY = os.environ['FEC_API_KEY']

COMMITTEE_ID = 'C00496067'
CANDIDATE_ID = 'P40002172'
SUB_ID = '1'
COMMITTEE_TYPE = 'P'

# a list of endpoints pulled from rest.py
endpoints = [
"/committees/?api_key={api_key}",
"/candidates/?api_key={api_key}",
"/candidates/search/?api_key={api_key}" ,
"/candidate/{candidate_id}/",
"/committee/{committee_id}/candidates/",
'/candidate/{candidate_id}/history/',
'/candidate/{candidate_id}/history/2018/',
'/committee/{committee_id}/candidates/history/',
'/committee/{committee_id}/candidates/history/2018/',
'/committee/{committee_id}/',
'/candidate/{candidate_id}/committees/',
'/committee/{committee_id}/history/',
'/committee/{committee_id}/history/2018/',
'/candidate/{candidate_id}/committees/history/',
'/candidate/{candidate_id}/committees/history/2018/',
"/totals/{committee_type}/?api_key={api_key}",
"/committee/{committee_id}/totals/?api_key={api_key}",
"/candidate/{candidate_id}/totals/?api_key={api_key}",
"/reports/{committee_type}/?api_key={api_key}",
"/committee/{committee_id}/reports/?api_key={api_key}",
"/names/candidates/?q=clinton&api_key={api_key}",
"/names/committees/?q=clinton&api_key={api_key}",
"/schedules/schedule_a/{sub_id}/?api_key={api_key}",
"/schedules/schedule_a/efile/?api_key={api_key}",
"/schedules/schedule_b/{sub_id}/?api_key={api_key}",
"/schedules/schedule_b/efile/?api_key={api_key}",
"/schedules/schedule_c/?api_key={api_key}",
"/schedules/schedule_d/?api_key={api_key}",
"/schedules/schedule_e/?api_key={api_key}",
"/schedules/schedule_e/efile/?api_key={api_key}",
"/schedules/schedule_f/{sub_id}/?api_key={api_key}",
"/communication-costs/?api_key={api_key}",
"/electioneering/?api_key={api_key}",
"/elections/?cycle=2018&office=president&api_key={api_key}",
"/elections/search/?api_key={api_key}",
"/elections/summary/?cycle=2018&office=president&api_key={api_key}",
"/state-election-office/?state=MD&api_key={api_key}",
"/election-dates/?api_key={api_key}",
"/reporting-dates/?api_key={api_key}",
"/calendar-dates/?api_key={api_key}",
"/calendar-dates/export/?api_key={api_key}",
"/rad-analyst/?api_key={api_key}",
"/efile/filings/?api_key={api_key}",
"/totals/by_entity/?cycle=2018&api_key={api_key}",
"/audit-primary-category/?api_key={api_key}",
"/audit-category/?api_key={api_key}",
"/audit-case/?api_key={api_key}",
"/names/audit_candidates/?q=clinton&api_key={api_key}",
"/names/audit_committees/?q=&clinton&api_key={api_key}",
"/schedules/schedule_a/by_size/by_candidate/?candidate_id={candidate_id}&cycle=2018&api_key={api_key}",
"/schedules/schedule_a/by_state/by_candidate/?candidate_id={candidate_id}&cycle=2018&aapi_key={api_key}",
"/candidates/totals/?api_key={api_key}",
"/schedules/schedule_a/by_state/totals/?api_key={api_key}",
"/communication_costs/by_candidate/?api_key={api_key}",
"/committee/{committee_id}/communication_costs/by_candidate/?api_key={api_key}",
"/electioneering/by_candidate/?api_key={api_key}",
"/committee/{committee_id}/electioneering/by_candidate/?api_key={api_key}",
"/committee/{committee_id}/filings/?api_key={api_key}",
"/candidate/{candidate_id}/filings/?api_key={api_key}",
"/efile/reports/house-senate/?api_key={api_key}",
"/efile/reports/presidential/?api_key={api_key}",
"/efile/reports/pac-party/?api_key={api_key}",
"/filings/?api_key={api_key}" # this one is also shooting for trailing slash issue
]

@click.command()
@click.option('--server', default="https://fec-dev-api.app.cloud.gov/v1", help='server to check with.')
def check_endpoints(server):
    """Simple script to check all endpoints status quickly."""

    for endp in endpoints:
        r = requests.get((server + endp).format(api_key=API_KEY,
                                                committee_id=COMMITTEE_ID,
                                                candidate_id=CANDIDATE_ID,
                                                committee_type=COMMITTEE_TYPE,
                                                sub_id = SUB_ID))
        if r.status_code == 200:
            print('{}: ok'.format(endp))
        else:
            print('******{}: not working'.format(endp))


if __name__ == '__main__':
    check_endpoints()
