"""
this is a simple scipt to test the status of all endpoints after deployment
Pls note that some endpoints need required parameters and some example data
are given hereself.
the endpoints list could be exapanded or improved in the future.

Note: on the production tier, api_key is required.

quick server list for reference:

prod: https://api.open.fec.gov
stage: https://api-stage.open.fec.gov
dev: https://fec-dev-api.app.cloud.gov
"""
import os
import requests

endpoint = "/legal/docs/murs/{0}?api_key={1}"
dev = 'https://fec-dev-api.app.cloud.gov'
prod = 'https://api.open.fec.gov/'
api_key = os.environ.get("FEC_API_KEY", "")


def compare_endpoints():
    """Simple script to compare endpoint data quickly."""

    mismatch_list = []

    for mur_no in range(4400, 8000):

        dev_url = (dev + "/v1" + endpoint).format(mur_no, api_key)
        dev_response = requests.get(dev_url)
        prod_url = (prod + "/v1" + endpoint).format(mur_no, api_key)
        prod_response = requests.get(prod_url)
        print("\nChecking:", mur_no)
        print("Dev response: {}".format(dev_response.status_code))
        print("Prod response: {}".format(prod_response.status_code))
        if not dev_response.status_code == prod_response.status_code:
            print ("!!! ERROR - responses don't match!!!")
            mismatch_list.append(mur_no)
            print("Mismatch list:")
            print(mismatch_list)

        if dev_response.status_code == prod_response.status_code == 200:
            dev_dispositions = dev_response.json().get('docs')[0].get('dispositions', [])
            prod_dispositions = prod_response.json().get('docs')[0].get('dispositions', [])
            dev_penalties = 0
            prod_penalties = 0
            for disposition in dev_dispositions:
                if disposition.get('penalty'):
                    dev_penalties += disposition.get('penalty')
            for disposition in prod_dispositions:
                if disposition.get('penalty'):
                    prod_penalties += disposition.get('penalty')
            if not dev_penalties == prod_penalties:
                print ("!!! ERROR - disposition penalty totals don't match!!!")
                print("Dev penalties: {}".format(dev_penalties))
                print("Prod penalties: {}".format(prod_penalties))
                mismatch_list.append(mur_no)
                print("Mismatch list:")
                print(mismatch_list)

if __name__ == "__main__":
    compare_endpoints()
