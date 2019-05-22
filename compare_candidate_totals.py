import os
import requests
import click

api_key = os.environ.get("FEC_API_KEY")

# TODO: Do a manual deploy with a bug to test this.
# Maybe election profile page since that's python and won't mess up the db

# Click can't take lists as args - must be strings
@click.command()
@click.option(
    '--office-types', default='H, S, P', help='Which offices to check. Format as H,S'
)
@click.option('--year', default=2020, help='Start year')
@click.option('--candidate-id', default=None, help='Check one candidate')
@click.option(
    '--envs', default='dev,prod', help='Which envs to check. No spaces please'
)
def compare_candidate_totals(office_types, year, candidate_id, envs):

    mismatch_list = set([])
    envs_list = envs.split(",")

    url_lookup = {
        'local': 'http://localhost:5000',
        'dev': 'https://fec-dev-api.app.cloud.gov',
        'stage': 'https://api-stage.open.fec.gov',
        'prod': 'https://api.open.fec.gov',
    }
    envs_to_check = {env: url_lookup[env] for env in envs_list}

    candidate_datatable = (
        "/candidates/totals/?candidate_id={0}&election_year={1}"
        "&election_full={2}&sort=-receipts&api_key=" + api_key
    )
    candidate_profile = "/candidate/{0}/totals/?cycle={1}&api_key=" + api_key
    election_profile = (
        "/elections/?candidate_id={0}&cycle={1}&election_full={2}"
        "&office={3}&sort_nulls_last=true&sort=-total_receipts&per_page=100"
        "&api_key=" + api_key
    )

    endpoints = ['datatable', 'candidate', 'election']
    values_to_check = ['receipts', 'disbursements', 'cash_on_hand_end_period']

    for candidate in get_top_candidates(office_types, year, candidate_id):

        result_list = []
        candidate_id = candidate.get('candidate_id')
        candidate_name = candidate.get('name')
        candidate_election = candidate.get('election_year')

        for env, base_url in envs_to_check.items():

            results = Results(env)

            datatable_url = (base_url + "/v1" + candidate_datatable).format(
                candidate_id, candidate_election, 'true'
            )
            candidate_profile_url = (base_url + "/v1" + candidate_profile).format(
                candidate_id, candidate_election
            )
            election_profile_url = (base_url + "/v1" + election_profile).format(
                candidate_id,
                candidate_election,
                'true',
                candidate.get('office_full').lower(),
            )

            # Office-specific queries
            if candidate.get('office') == "H":
                # Add state and district to elections
                election_profile_url += "&state={}&district={}&election_full={}".format(
                    candidate.get('state'), candidate.get('district'), 'False'
                )
                # 2-year totals for candidate profile page
                candidate_profile_url += "&full_election=False"

            if candidate.get('office') == "S":
                # Add state to elections
                election_profile_url += "&state={}&election_full={}".format(
                    candidate.get('state'), 'True'
                )
                # 6-year totals for candidate profile page
                candidate_profile_url += "&full_election=True"

            if candidate.get('office') == "P":
                # 4-year totals for candidate profile page
                candidate_profile_url += "&full_election=True"

            print(
                "\n**** Checking: {}, {} in {}. Election year is {}. ****\n".format(
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
            candidate_results = (
                requests.get(candidate_profile_url).json().get('results')
            )

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
                    baseline = results.get('datatable', value)
                    if any(
                        results.get(endpoint, value) != baseline
                        for endpoint in endpoints
                    ):
                        print("\n!!! ERROR - {} results don't match!!!\n".format(value))
                        print("| Data source | Total {} |\n|--|--|".format(value))
                        for endpoint in endpoints:
                            print(
                                "| {} datatable or profile page \t\t|\t${:,.2f}|".format(
                                    endpoint, results.get(endpoint, value)
                                )
                            )
                        mismatch_list.add((candidate_id, candidate_name))

            result_list.append(results)

            print("\nMismatch list ({}): {}".format(env, mismatch_list))

        for endpoint in endpoints:
            print("\n****Checking across environments: {} ****\n".format(endpoint))
            for value in values_to_check:
                # Grab the baseline value for the first environment
                baseline = result_list[0].get(endpoint, value)

                # If any values differ across environment
                if any(
                    result.get(endpoint, value) != baseline for result in result_list
                ):
                    print("\n!!! ERROR - environment results don't match!!!")
                    print("| Data source | Total {} |\n|--|--|".format(value))
                    for result in result_list:
                        print(
                            "| {} {} {}\t\t|\t${:,.2f}|".format(
                                endpoint, value, result.env, result.get(endpoint, value)
                            )
                        )
                    mismatch_list.add((candidate_id, candidate_name))


def get_top_candidates(office_types, start_year, candidate_id):

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

    def get(self, result_type, value):
        return self.result_type.get(value)


def get_printable_url(url):
    return url.replace(api_key, 'DEMO_KEY')


if __name__ == "__main__":
    compare_candidate_totals()
