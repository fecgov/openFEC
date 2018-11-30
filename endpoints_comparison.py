"""
this is a simple scipt to compare one environment's results to another.

Note: on the production tier, api_key is required.

quick server list for reference:

prod: https://api.open.fec.gov
stage: https://api-stage.open.fec.gov
dev: https://fec-dev-api.app.cloud.gov
"""
import os
import requests

endpoint = "/candidate/{0}/totals/?cycle={1}&full_election={2}&api_key={3}"
dev = 'https://fec-dev-api.app.cloud.gov'
prod = 'https://api.open.fec.gov/'
api_key = os.environ.get("FEC_API_KEY", "")


def compare_endpoints():
    """Simple script to compare endpoint data quickly."""

    top_candidates = []

    candidate_url = "https://api.open.fec.gov/v1/candidates/totals/?api_key={}&sort_hide_null=false&sort_nulls_last=true&election_full=true&sort=-receipts&per_page=30&page=1".format(api_key)

    # Presidential
    top_candidates.extend(requests.get(candidate_url + "&election_year=2020&office=P").json().get('results'))

    # #2020 Senate
    top_candidates.extend(requests.get(candidate_url + "&election_year=2020&office=S").json().get('results'))

    # #2022 Senate
    top_candidates.extend(requests.get(candidate_url + "&election_year=2022&office=S").json().get('results'))

    #2018 House
    top_candidates.extend(requests.get(candidate_url + "&election_year=2018&office=H").json().get('results'))

    mismatch_list = []

    for candidate in top_candidates:
        candidate_id = candidate.get('candidate_id')
        candidate_name = candidate.get('name')


        # Full Cycle totals
        # Logic changed for Pres/Senate:
        # We expect election year "full_election" totals on dev
        # to equal 2018 'full_election' totals on prod

        # dev_url = (dev + "/v1" + endpoint).format(candidate_id, candidate.get('election_year'), 'true', api_key)
        # prod_url = (prod + "/v1" + endpoint).format(candidate_id, '2018', 'true', api_key)

        # 2-year totals
        dev_url = (dev + "/v1" + endpoint).format(candidate_id, '2012', 'false', api_key)
        prod_url = (prod + "/v1" + endpoint).format(candidate_id, '2012', 'false', api_key)

        print("\nChecking: {}, {}".format(candidate_id, candidate_name))
        dev_response = requests.get(dev_url).json().get('results')
        prod_response = requests.get(prod_url).json().get('results')

        if len(dev_response) > len(prod_response):
            print("!!! ERROR - results don't match!!!")
            mismatch_list.append((candidate_id, candidate_name))

        if len(dev_response) > 0 and len(prod_response) > 0:
            dev_results = dev_response[0]
            prod_results = prod_response[0]

            if not dev_results.get('receipts') == prod_results.get('receipts'):
                print("!!! ERROR - results don't match!!!")
                print("Dev results: {}".format(dev_results.get('receipts')))
                print("Prod results: {}".format(prod_results.get('receipts')))
                mismatch_list.append((candidate_id, candidate_name))

            if not dev_results.get('disbursements') == prod_results.get('disbursements'):
                print("!!! ERROR - results don't match!!!")
                print("Dev results: {}".format(dev_results.get('disbursements')))
                print("Prod results: {}".format(prod_results.get('disbursements')))
                mismatch_list.append((candidate_id, candidate_name))

            else:
                print("Results match!")
                print("Dev: {} {} {} {}".format(dev_results.get('full_election'),dev_results.get('cycle'), dev_results.get('receipts'), dev_results.get('disbursements')))
                print("Prod: {} {} {} {}".format(prod_results.get('full_election'),prod_results.get('cycle'), prod_results.get('receipts'), prod_results.get('disbursements')))

        print("Mismatch list: {}".format(mismatch_list))

if __name__ == "__main__":
    compare_endpoints()
