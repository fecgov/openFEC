import os
import requests
import click

api_key = os.environ.get("FEC_API_KEY")

url_lookup = {
    "local": "http://localhost:5000",
    "dev": "https://fec-dev-api.app.cloud.gov",
    "stage": "https://api-stage.open.fec.gov",
    "prod": "https://api.open.fec.gov",
}
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

# TODO: Do a manual deploy with a bug to test this.
# Maybe election profile page since that's python and won't mess up the db

# Click can't take lists as args - must be strings
@click.command()
@click.option(
    "--office-types", default="H, S, P", help="Which offices to check. Format as H,S"
)
@click.option("--year", default=2020, help="Start year")
@click.option("--candidate-id", default=None, help="Check one candidate")
@click.option(
    "--envs",
    default="dev,prod",
    help="Which envs to check. Format as dev,stage,prod (No spaces please)",
)
def compare_candidate_totals(office_types, year, candidate_id, envs):

    mismatch_list = set([])
    envs_to_check = {env: url_lookup[env] for env in envs.split(",")}
    endpoints = ["datatable", "candidate", "election"]
    values_to_check = ["receipts", "disbursements", "cash_on_hand_end_period"]

    for candidate_info in get_top_candidates(office_types, year, candidate_id):

        env_results_list = []
        candidate = Candidate(candidate_info)

        for env, base_url in envs_to_check.items():
            # make a Results object to save this env's results
            env_results = Results(env)
            datatable_url, candidate_profile_url, election_profile_url = candidate.get_urls(base_url)

            print(
                f"\n**** Checking: {candidate.id}, {candidate.name} in {env}. Election year is {candidate.election}. ****\n"
            )

            print(f"\nCandidate totals datatable: {get_printable(datatable_url)}")
            print(f"\nCandidate profile totals: {get_printable(candidate_profile_url)}")
            print(f"\nElection profile totals: {get_printable(election_profile_url)}")

            datatable_results = get_results(datatable_url)
            candidate_results = get_results(candidate_profile_url)
            # This is a list of all candidates in an election
            all_election_results = get_results(election_profile_url)
            # Loop through them to match the candidate
            for election_result in all_election_results:
                if election_result.get("candidate_id") == candidate.id:
                    election_match = election_result
                    break

            if not all([datatable_results, candidate_results, election_match]):
                print("\nERROR: No results for one endpoint")
                print(f"Candidate datatable results? {datatable_results is not None}")
                print(f"Candidate profile page results? {candidate_results is not None}")
                print(f"Election profile page results? {election_match is not None}")
                mismatch_list.add((candidate.id, candidate.name))
            else:
                # Take the top result
                env_results.set("datatable", datatable_results[0])
                env_results.set("candidate", candidate_results[0])
                # Take the matched result
                env_results.set("election", election_match)
                for value in values_to_check:
                    baseline = env_results.get("datatable", value)
                    if any(
                        env_results.get(endpoint, value) != baseline
                        for endpoint in endpoints
                    ):
                        print(f"\n!!! ERROR - {value} results don't match!!!\n")
                        print(f"| Data source | Total {value} |\n|--|--|")
                        for endpoint in endpoints:
                            print(
                                "| {} datatable or profile page \t\t|\t${:,.2f}|".format(
                                    endpoint, env_results.get(endpoint, value)
                                )
                            )
                        mismatch_list.add((candidate.id, candidate.name))
            # Add this env's results to the list so we can cross-compare later
            env_results_list.append(env_results)

            print(f"\nMismatch list ({env}): {mismatch_list}")

        for endpoint in endpoints:
            print(f"\n****Checking across environments: {endpoint} ****\n")
            for value in values_to_check:
                # Grab the baseline value for the first environment
                baseline = env_results_list[0].get(endpoint, value)
                # If any values differ across environment
                if any(
                    result.get(endpoint, value) != baseline for result in env_results_list
                ):
                    print("\n!!! ERROR - environment results don't match!!!")
                    print(f"| Data source | Total {value} |\n|--|--|")
                    for result in env_results_list:
                        print(
                            "| {} {} {}\t\t|\t${:,.2f}|".format(
                                endpoint, value, result.env, result.get(endpoint, value)
                            )
                        )
                    mismatch_list.add((candidate.id, candidate.name))


def get_top_candidates(office_types, start_year, candidate_id):

    top_candidates = []
    candidate_url = "https://api.open.fec.gov/v1/candidates/totals/?" \
        "sort_hide_null=false&sort_nulls_last=true&is_active_candidate=True" \
        "&election_full=true&sort=-receipts&page=1&api_key=" + api_key
    if candidate_id:
        candidate_url += f"&candidate_id={candidate_id}"
    print("Getting candidate info")
    if "P" in office_types:
        # Top 20 presidential
        top_candidates.extend(get_results(candidate_url + f"&election_year={start_year}&office=P&per_page=20"))
    elif "S" in office_types:
        # Top 30 senate, 3 cycles
        # Start year plus next two elections
        for year in range(start_year, start_year + 5, 2):
            top_candidates.extend(get_results(candidate_url + f"&election_year={year}&office=S&per_page=30"))
    elif "H" in office_types:
        # Top 100 house
        top_candidates.extend(get_results(candidate_url + f"&election_year={start_year}&office=H&per_page=100"))

    return top_candidates


class Results(object):
    """docstring for Results"""

    def __init__(self, env):
        self.env = env
        self.result_type = None

    def set(self, result_type, value):
        # Clean up inconsistencies in labellings
        # 0.00 is Falsy
        if value.get("total_receipts") is not None:
            value["receipts"] = value["total_receipts"]
        if value.get("total_disbursements") is not None:
            value["disbursements"] = value["total_disbursements"]
        if value.get("last_cash_on_hand_end_period") is not None:
            value["cash_on_hand_end_period"] = value["last_cash_on_hand_end_period"]
        self.result_type = value

    def get(self, result_type, value):
        return self.result_type.get(value)


class Candidate(object):
    """docstring for Candidate"""
    def __init__(self, candidate):
        self.id = candidate.get("candidate_id")
        self.name = candidate.get("name")
        self.election = candidate.get("election_year")
        self.office = candidate.get("office")
        self.office_full = candidate.get("office_full")
        self.state = candidate.get("state")
        self.district = candidate.get("district")

    def get_urls(self, base_url):
        datatable_url = (
            base_url
            + "/v1"
            + candidate_datatable.format(self.id, self.election, "true")
        )
        candidate_profile_url = (
            base_url
            + "/v1"
            + candidate_profile.format(self.id, self.election)
        )
        election_profile_url = (
            base_url
            + "/v1"
            + election_profile.format(
                self.id,
                self.election,
                "true",
                self.office_full.lower(),
            )
        )

        # Office-specific queries
        if self.office == "H":
            # Add state and district to elections
            election_profile_url += f"&state={self.state}&district={self.district}&election_full=False"
            # 2-year totals for candidate profile page
            candidate_profile_url += "&full_election=False"

        elif self.office == "S":
            # Add state to elections
            election_profile_url += (
                f"&state={self.state}&election_full=True"
            )
            # 6-year totals for candidate profile page
            candidate_profile_url += "&full_election=True"

        elif self.office == "P":
            # 4-year totals for candidate profile page
            candidate_profile_url += "&full_election=True"

        return datatable_url, candidate_profile_url, election_profile_url


def get_printable(url):
    return url.replace(api_key, "DEMO_KEY")


def get_results(url):
    return requests.get(url).json().get("results")


if __name__ == "__main__":
    compare_candidate_totals()
