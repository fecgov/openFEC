import os
import requests
import logging

candidate_datatable = "/candidates/totals/?candidate_id={0}&election_year={1}&election_full={2}&api_key={3}&sort=-receipts"
candidate_profile = "/candidate/{0}/totals/?cycle={1}&api_key={2}"
election_profile = "/elections/?candidate_id={0}&cycle={1}&election_full={2}&api_key={3}&office={4}&sort_nulls_last=true&sort=-total_receipts&per_page=100"
#dev_url = 'https://fec-dev-api.app.cloud.gov'
dev_url = 'http://localhost:5000'
prod_url = 'https://api.open.fec.gov'
api_key = os.environ.get("FEC_API_KEY")

envs = {'dev': dev_url, 'prod': prod_url}


def compare_candidate_totals():

    top_candidates = []
    candidate_url = "https://api.open.fec.gov/v1/candidates/totals/?api_key={0}&sort_hide_null=false&sort_nulls_last=true&is_active_candidate=True&election_full=true&sort=-receipts&page=1".format(api_key)

    # Top 20 Presidential 2020
    top_candidates.extend(requests.get(candidate_url + "&election_year=2020&office=P&per_page=20").json().get('results'))
    # Top 30 Senate 2020
    top_candidates.extend(requests.get(candidate_url + "&election_year=2020&office=S&per_page=30").json().get('results'))
    # Top 30 Senate 2022
    top_candidates.extend(requests.get(candidate_url + "&election_year=2022&office=S&per_page=30").json().get('results'))

    # Top 30 Senate 2024 - check after Q1 2019
    top_candidates.extend(requests.get(candidate_url + "&election_year=2024&office=S").json().get('results'))

    # Top 100 House 2020
    top_candidates.extend(requests.get(candidate_url + "&election_year=2020&office=H&per_page=100").json().get('results'))

    mismatch_list = set([])
    comparison_results = {}

    endpoints = ['datatable', 'candidate', 'election']
    values_to_check = ['receipts', 'disbursements', 'cash_on_hand_end_period']

    ##TODO: Do this with a class and state?
    def set_results(result_type, env, value):
        # Clean up inconsistencies in labellings
        # 0.00 is Falsy
        if value.get('total_receipts') is not None:
            value['receipts'] = value['total_receipts']
        if value.get('total_disbursements') is not None:
            value['disbursements'] = value['total_disbursements']
        if value.get('last_cash_on_hand_end_period') is not None:
            value['cash_on_hand_end_period'] = value['last_cash_on_hand_end_period']
        comparison_results[result_type + '_' + env] = value

    def get_results(result_type, env):
        return comparison_results.get(result_type + '_' + env)

    def get_printable_url(url):
        return url.replace(api_key, 'DEMO_KEY')

    for candidate in top_candidates:

        candidate_id = candidate.get('candidate_id')
        candidate_name = candidate.get('name')
        candidate_election = candidate.get('election_year')

        for env, url in envs.items():

            datatable_url = (url + "/v1" + candidate_datatable).format(candidate_id, candidate_election, 'true', api_key)
            candidate_profile_url = (url + "/v1" + candidate_profile).format(candidate_id, candidate_election, api_key)
            election_profile_url = (url + "/v1" + election_profile).format(candidate_id, candidate_election, 'true', api_key, candidate.get('office_full').lower())

            # show full election for S, P
            if candidate.get('office') in ("S", "P"):
                candidate_profile_url += "&full_election=True"
            else:
                candidate_profile_url += "&full_election=False"

            # Add state for House/Senate and District for House
            if candidate.get('office') != "P":
                election_profile_url += "&state={}&election_full={}".format(candidate.get('state'), 'True')
            if candidate.get('office') == "H":
                election_profile_url += "&district={}&election_full={}".format(candidate.get('district'), 'False')

            print("\n*********Checking: {}, {} in {} ************\n".format(candidate_id, candidate_name, env))

            print("\nCandidate totals datatable url: {}".format(get_printable_url(datatable_url)))
            print("\nCandidate profile page totals url: {}".format(get_printable_url(candidate_profile_url)))
            print("\nElection profile page totals url: {}".format(get_printable_url(election_profile_url)))

            datatable_results = requests.get(datatable_url).json().get('results')
            candidate_results = requests.get(candidate_profile_url).json().get('results')

            # This is a list of all candidates - we'll need to loop through them to match
            all_election_results = requests.get(election_profile_url).json().get('results')

            for election_result in all_election_results:
                if election_result.get('candidate_id') == candidate_id:
                    election_match = election_result
                    break

            if not all([datatable_results, candidate_results, election_match]):
                print("\nERROR: No results for one endpoint")
                print("Candidate datatable has results? {}".format(datatable_results is not None))
                print("Candidate profile page has results? {}".format(candidate_results is not None))
                print("Election profile page has results? {}".format(election_match is not None))
                mismatch_list.add((candidate_id, candidate_name))
            else:
                # Take the top result
                set_results('datatable', env, datatable_results[0])
                set_results('candidate', env, candidate_results[0])
                # Take the matched results
                set_results('election', env, election_match)
                for value in values_to_check:
                    baseline = get_results('datatable', env).get(value)
                    # for endpoint in endpoints:
                    #     print("{}: {}".format(endpoint, get_results(endpoint, env).get(value)))
                    if any(get_results(endpoint, env).get(value) != baseline for endpoint in endpoints):
                        print("\n!!! ERROR - {} results don't match!!!\n".format(value))
                        print("| Data source | Total {} |\n|--|--|".format(value))
                        for endpoint in endpoints:
                            print("| {} datatable or profile page \t\t|\t${:,.2f}|".format(endpoint, get_results(endpoint, env).get(value)))
                        mismatch_list.add((candidate_id, candidate_name))

            print("\nMismatch list ({}): {}".format(env, mismatch_list))

        for endpoint in endpoints:
            print("\n*********Checking across environments: {} ************\n".format(endpoint))
            for value in values_to_check:
                # Grab the baseline value for the first environment
                baseline = get_results(endpoint, list(envs.keys())[0]).get(value)
                # If any values differ across environment
                if any(get_results(endpoint, env).get(value) != baseline for env in envs.keys()):
                    print("\n!!! ERROR - environment results don't match!!!")
                    print("| Data source | Total {} |\n|--|--|".format(value))
                    for env in envs.keys():
                        print("| {} {} {}\t\t|\t${:,.2f}|".format(endpoint, value, env, get_results(endpoint, env).get(value)))
                    mismatch_list.add((candidate_id, candidate_name))


if __name__ == "__main__":
    compare_candidate_totals()
