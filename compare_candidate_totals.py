import os
import requests
import click

api_key = os.environ.get("FEC_API_KEY")


@click.command()
@click.option(
    '--office-types',
    default=['H', 'S', 'P'],
    help='Which offices to check. Format as H,S',
)
@click.option('--year', default=2020, help='Start year')
@click.option('--candidate-id', help='Check one candidate')
# @click.option('--envs', default=['dev', 'prod'], help='Which envs to check')
def compare_candidate_totals(office_types, year, candidate_id, envs):

    mismatch_list = set([])

    # local_url = 'http://localhost:5000'
    dev_url = 'https://fec-dev-api.app.cloud.gov'
    prod_url = 'https://api.open.fec.gov'

    # TODO: Ask about local/dev/prod
    envs_to_check = {'dev': dev_url, 'prod': prod_url}

    candidate_datatable = "/candidates/totals/?candidate_id={0}&election_year={1}&election_full={2}&api_key={3}&sort=-receipts"
    candidate_profile = "/candidate/{0}/totals/?cycle={1}&api_key={2}"
    election_profile = "/elections/?candidate_id={0}&cycle={1}&election_full={2}&api_key={3}&office={4}&sort_nulls_last=true&sort=-total_receipts&per_page=100"

    endpoints = ['datatable', 'candidate', 'election']
    values_to_check = ['receipts', 'disbursements', 'cash_on_hand_end_period']

    for candidate in get_top_candidates(office_types, year, candidate_id):

        result_list = []
        candidate_id = candidate.get('candidate_id')
        candidate_name = candidate.get('name')
        candidate_election = candidate.get('election_year')

        for env, url in envs_to_check.items():

            results = Results(env)

            datatable_url = (url + "/v1" + candidate_datatable).format(
                candidate_id, candidate_election, 'true', api_key
            )
            candidate_profile_url = (url + "/v1" + candidate_profile).format(
                candidate_id, candidate_election, api_key
            )
            election_profile_url = (url + "/v1" + election_profile).format(
                candidate_id,
                candidate_election,
                'true',
                api_key,
                candidate.get('office_full').lower(),
            )

            # show full election for S, P
            if candidate.get('office') in ("S", "P"):
                candidate_profile_url += "&full_election=True"
            else:
                candidate_profile_url += "&full_election=False"

            # Add state for House/Senate and District for House
            if candidate.get('office') != "P":
                election_profile_url += "&state={}&election_full={}".format(
                    candidate.get('state'), 'True'
                )
            if candidate.get('office') == "H":
                election_profile_url += "&district={}&election_full={}".format(
                    candidate.get('district'), 'False'
                )

            print(
                "\n****Checking: {}, {} in {}. Election year is {}****\n".format(
                    candidate_id, candidate_name, env, candidate_election
                )
            )

            print(
                "\nCandidate totals datatable url: {}".format(
                    get_printable_url(datatable_url)
                )
            )
            print(
                "\nCandidate profile page totals url: {}".format(
                    get_printable_url(candidate_profile_url)
                )
            )
            print(
                "\nElection profile page totals url: {}".format(
                    get_printable_url(election_profile_url)
                )
            )

            datatable_results = requests.get(datatable_url).json().get('results')
            candidate_results = (requests.get(candidate_profile_url).json().get('results'))

            # This is a list of all candidates - we'll need to loop through them to match
            all_election_results = (
                requests.get(election_profile_url).json().get('results')
            )

            for election_result in all_election_results:
                if election_result.get('candidate_id') == candidate_id:
                    election_match = election_result
                    break

            if not all([datatable_results, candidate_results, election_match]):
                print("\nERROR: No results for one endpoint")
                print(
                    "Candidate datatable has results? {}".format(
                        datatable_results is not None
                    )
                )
                print(
                    "Candidate profile page has results? {}".format(
                        candidate_results is not None
                    )
                )
                print(
                    "Election profile page has results? {}".format(
                        election_match is not None
                    )
                )
                mismatch_list.add((candidate_id, candidate_name))
            else:
                # Take the top result
                results.set('datatable', datatable_results[0])
                results.set('candidate', candidate_results[0])
                # Take the matched results
                results.set('election', election_match)
                for value in values_to_check:
                    baseline = results.get('datatable').get(value)
                    # for endpoint in endpoints:
                    #     print("{}: {}".format(endpoint, results.get(endpoint).get(value)))
                    if any(
                        results.get(endpoint).get(value) != baseline
                        for endpoint in endpoints
                    ):
                        print("\n!!! ERROR - {} results don't match!!!\n".format(value))
                        print("| Data source | Total {} |\n|--|--|".format(value))
                        for endpoint in endpoints:
                            print(
                                "| {} datatable or profile page \t\t|\t${:,.2f}|".format(
                                    endpoint, results.get(endpoint).get(value)
                                )
                            )
                        mismatch_list.add((candidate_id, candidate_name))

            result_list.append(results)

            print("\nMismatch list ({}): {}".format(env, mismatch_list))

        for endpoint in endpoints:
            print("\n****Checking across environments: {} ****\n".format(endpoint))
            for value in values_to_check:
                # Grab the baseline value for the first environment
                baseline = result_list[0].get(endpoint).get(value)

                # If any values differ across environment
                if any(
                    result.get(endpoint).get(value) != baseline
                    for result in result_list
                ):
                    print("\n!!! ERROR - environment results don't match!!!")
                    print("| Data source | Total {} |\n|--|--|".format(value))
                    for result in result_list:
                        print(
                            "| {} {} {}\t\t|\t${:,.2f}|".format(
                                endpoint,
                                value,
                                result.env,
                                result.get(endpoint).get(value),
                            )
                        )
                    mismatch_list.add((candidate_id, candidate_name))


def get_top_candidates(office_types=['P', 'S', 'H'], start_year=2020, candidate_id=None):

    top_candidates = []
    candidate_url = "https://api.open.fec.gov/v1/candidates/totals/?api_key={0}&sort_hide_null=false&sort_nulls_last=true&is_active_candidate=True&election_full=true&sort=-receipts&page=1".format(
        api_key
    )
    if candidate_id:
        candidate_url += "&candidate_id={}".format(candidate_id)
    print("Getting candidate info")
    if 'P' in office_types:
        # Top 20 presidential
        top_candidates.extend(
            requests.get(
                candidate_url
                + "&election_year={}&office=P&per_page=20".format(start_year)
            )
            .json()
            .get('results')
        )
    if 'S' in office_types:
        # Top 30 senate, 3 cycles
        # Start year plus next two elections
        for year in range(start_year, start_year + 5, 2):
            top_candidates.extend(
                requests.get(
                    candidate_url
                    + "&election_year={}&office=S&per_page=30".format(year)
                )
                .json()
                .get('results')
            )
    if 'H' in office_types:
        # Top 100 house
        top_candidates.extend(
            requests.get(
                candidate_url
                + "&election_year={}&office=H&per_page=100".format(start_year)
            )
            .json()
            .get('results')
        )
    return top_candidates


class Results(object):
    """docstring for Results"""

    def __init__(self, env):
        self.env = env
        self.result_type = None

    def set(self, result_type, value):
        # Clean up inconsistencies in labellings
        # 0.00 is Falsy
        if value.get('total_receipts') is not None:
            value['receipts'] = value['total_receipts']
        if value.get('total_disbursements') is not None:
            value['disbursements'] = value['total_disbursements']
        if value.get('last_cash_on_hand_end_period') is not None:
            value['cash_on_hand_end_period'] = value['last_cash_on_hand_end_period']
        self.result_type = value

    def get(self, result_type):
        return self.result_type


def get_printable_url(url):
    return url.replace(api_key, 'DEMO_KEY')


if __name__ == "__main__":
    compare_candidate_totals()
