#!/usr/bin/env python

import glob
import subprocess
import multiprocessing
import networkx as nx
import sqlalchemy as sa
import datetime
import requests
from webservices import flow
from webservices.env import env
from webservices.rest import db
from webservices.config import SQL_CONFIG, check_config
from webservices.common.util import get_full_path
from webservices.utils import post_to_slack
from cli import logger


def execute_sql_file(path):
    """This helper is typically used within a multiprocessing pool; create a new database
    engine for each job.
    """
    db.engine.dispose()
    logger.info(("Running {}".format(path)))
    with open(path) as fp:
        cmd = "\n".join(
            [line for line in fp.readlines() if not line.strip().startswith("--")]
        )
        db.engine.execute(sa.text(cmd), **SQL_CONFIG)


def execute_sql_folder(path, processes):
    sql_dir = get_full_path(path)
    if not sql_dir.endswith("/"):
        sql_dir += "/"
    paths = sorted(glob.glob(sql_dir + "*.sql"))
    if processes > 1:
        pool = multiprocessing.Pool(processes=processes)
        pool.map(execute_sql_file, sorted(paths))
    else:
        for path in paths:
            execute_sql_file(path)


def refresh_materialized(concurrent=True):
    """Refresh materialized views in dependency order
       We usually want to refresh them concurrently so that we don't block other
       connections that use the DB. In the case of tests, we cannot refresh concurrently as the
       tables are not initially populated.
    """
    logger.info("Refreshing materialized views...")

    materialized_view_names = {
        "audit_case": [
            "ofec_audit_case_mv",
            "ofec_audit_case_category_rel_mv",
            "ofec_audit_case_sub_category_rel_mv",
            "ofec_committee_fulltext_audit_mv",
            "ofec_candidate_fulltext_audit_mv",
        ],
        "cand_cmte_linkage": ["ofec_cand_cmte_linkage_mv"],
        "candidate_aggregates": ["ofec_candidate_totals_mv"],
        "candidate_detail": ["ofec_candidate_detail_mv"],
        "candidate_election": ["ofec_candidate_election_mv"],
        "candidate_flags": ["ofec_candidate_flag_mv"],
        "candidate_fulltext": ["ofec_candidate_fulltext_mv"],
        "candidate_history": ["ofec_candidate_history_mv"],
        "candidate_history_future": ["ofec_candidate_history_with_future_election_mv"],
        "candidate_totals_detail": ["ofec_candidate_totals_detail_mv"],
        "committee_detail": ["ofec_committee_detail_mv"],
        "committee_fulltext": ["ofec_committee_fulltext_mv"],
        "committee_history": ["ofec_committee_history_mv"],
        "communication_cost": ["ofec_communication_cost_mv"],
        "communication_cost_by_candidate": [
            "ofec_communication_cost_aggregate_candidate_mv"
        ],
        "electioneering": ["ofec_electioneering_mv"],
        "electioneering_by_candidate": ["ofec_electioneering_aggregate_candidate_mv"],
        "elections_list": ["ofec_elections_list_mv"],
        "filing_amendments_house_senate": [
            "ofec_house_senate_electronic_amendments_mv",
            "ofec_house_senate_paper_amendments_mv",
        ],
        "filing_amendments_pac_party": [
            "ofec_pac_party_electronic_amendments_mv",
            "ofec_pac_party_paper_amendments_mv",
        ],
        "filing_amendments_presidential": [
            "ofec_presidential_electronic_amendments_mv",
            "ofec_presidential_paper_amendments_mv",
        ],
        "filings": [
            "ofec_filings_amendments_all_mv",
            "ofec_filings_all_mv",
        ],
        "ofec_agg_coverage_date": ["ofec_agg_coverage_date_mv"],
        "ofec_pcc_to_pac": ["ofec_pcc_to_pac_mv"],
        "ofec_sched_a_agg_state": ["ofec_sched_a_agg_state_mv"],
        "ofec_sched_e_mv": ["ofec_sched_e_mv"],
        "reports_house_senate": ["ofec_reports_house_senate_mv"],
        "reports_ie": ["ofec_reports_ie_only_mv"],
        "reports_pac_party": ["ofec_reports_pac_party_mv"],
        "reports_presidential": ["ofec_reports_presidential_mv"],
        "sched_a_by_size_merged": ["ofec_sched_a_aggregate_size_merged_mv"],
        "sched_a_by_state_recipient_totals": [
            "ofec_sched_a_aggregate_state_recipient_totals_mv"
        ],
        "sched_e_by_candidate": ["ofec_sched_e_aggregate_candidate_mv"],
        "totals_combined": ["ofec_totals_combined_mv"],
        "totals_house_senate": ["ofec_totals_house_senate_mv"],
        "totals_ie": ["ofec_totals_ie_only_mv"],
        "totals_presidential": ["ofec_totals_presidential_mv"],
        "sched_b_by_recipient": ["ofec_sched_b_aggregate_recipient_mv"],
        "totals_inaugural_donations": ["ofec_totals_inaugural_donations_mv"],
        "sched_h4": ["ofec_sched_h4_mv"],
        "schedule_d": ["ofec_sched_d_mv"],
        "schedule_a_national_party": ["ofec_sched_a_national_party_mv"],
        "schedule_b_national_party": ["ofec_sched_b_national_party_mv"],
        "ofec_sched_a_aggregate_employer": ["ofec_sched_a_aggregate_employer_mv"],
        "ofec_sched_a_aggregate_occupation": ["ofec_sched_a_aggregate_occupation_mv"]
    }

    graph = flow.get_graph()

    with db.engine.begin() as connection:
        for node in nx.topological_sort(graph):
            materialized_views = materialized_view_names.get(node, None)

            if materialized_views:
                for mv in materialized_views:
                    logger.info("Refreshing %s", mv)

                    if concurrent:
                        refresh_command = "REFRESH MATERIALIZED VIEW CONCURRENTLY {}".format(
                            mv
                        )
                    else:
                        refresh_command = "REFRESH MATERIALIZED VIEW {}".format(mv)

                    connection.execute(
                        sa.text(refresh_command).execution_options(autocommit=True)
                    )
            else:
                logger.error("Error refreshing node {}: not found.".format(node))

    logger.info("Finished refreshing materialized views.")


def create_public_api_key(
        space,
        first_rate_limit,
        first_rate_limit_duration,
        second_rate_limit,
        second_rate_limit_duration):

    logger.info("Creating new public API key for {} environment".format(space))
    UMBRELLA_ADMIN_AUTH_TOKEN = env.get_credential("UMBRELLA_ADMIN_AUTH_TOKEN")
    API_KEY = env.get_credential("FEC_WEB_API_KEY_PUBLIC")

    header = {
        "X-Admin-Auth-Token": UMBRELLA_ADMIN_AUTH_TOKEN,
        "X-Api-Key": API_KEY,
        "Content-Type": "application/json; charset=UTF-8",
    }

    create_api_key_params = {
        "first_name": space,
        "last_name": "Public API Key",
        "email": env.get_credential("FEC_EMAIL"),
        "use_description": "FEC_WEB_API_KEY_PUBLIC for prod environment. Rate limited key per IP. Created {}".format(
            datetime.datetime.today()),
        "registration_source": "update_public_api_key task",
        "throttle_by_ip": True,
        "terms_and_conditions": True,
        "created_at": datetime.datetime.now().isoformat(),
        "creator": {
            "username": "auto-generated"
        },
        "settings": {
            "rate_limit_mode": "custom",
            "rate_limits": [{
                "limit_by": "apiKey",
                "response_headers": True,
                "limit": first_rate_limit,
                "duration": first_rate_limit_duration
                },
                {
                "limit_by": "apiKey",
                "response_headers": False,
                "limit": second_rate_limit,
                "duration": second_rate_limit_duration,
                }
            ]
        }
    }

    url = "https://api.data.gov/api-umbrella/v1/users.json"

    response = requests.post(url, json=create_api_key_params, headers=header)

    try:
        response.raise_for_status()
    except requests.exceptions.HTTPError as error:
        error_message = "Error occured when creating API key, check logs"
        slack_message(error_message)
        logger.error("Error occured with creating API key: {}".format(error))
        raise

    response_json = response.json()
    new_api_key = response_json["user"]["api_key"]

    logger.info("New API key: {}".format(new_api_key))

    return new_api_key


def get_space_guid(token, space):
    space_guid = ""

    error_message = "Error occured when retrieving space GUID, check logs"

    header = {
        "Authorization": token,
    }

    data = {
        "names": [space.lower(), ]
    }

    url = "https://api.fr.cloud.gov/v3/spaces"

    response = requests.get(url, params=data, headers=header)

    try:
        response.raise_for_status()
    except requests.exceptions.HTTPError as error:
        if response.status_code == 401:
            logger.error("Token may be expired, try generating new bearer token using `cf oauth-token > token.txt`")
        slack_message(error_message)
        logger.error(error)
        raise

    response_json = response.json()

    if response_json["resources"][0]["name"] == space.lower():
        space_guid = response_json["resources"][0]["guid"]

    if space_guid == "":
        raise Exception("Space GUID not found")

    return space_guid


def get_service_instance_guid(token, space_guid, service_instance_name):
    GUID = ""

    error_message = "Error occured when retrieving service instance GUID, check logs"

    header = {
        "Authorization": token,
    }

    data = {
        "names": [service_instance_name,],
        "space_guids": [space_guid,]
    }

    url = "https://api.fr.cloud.gov/v3/service_instances"

    response = requests.get(url, params=data, headers=header)

    try:
        response.raise_for_status()
    except requests.exceptions.HTTPError as error:
        if response.status_code == 401:
            logger.error("Token may be expired, try generating new bearer token using `cf oauth-token > token.txt`")
        slack_message(error_message)
        logger.error("Error occured with retrieving service instances: {}".format(error))
        raise

    response_json = response.json()

    if response_json["resources"][0]["name"] == service_instance_name:
        GUID = response_json["resources"][0]["guid"]

    if GUID == "":
        slack_message(error_message)
        raise Exception("Service instance GUID not found for service instance: {}".format(service_instance_name))

    return GUID


def get_credentials_by_guid(token, GUID):

    error_message = "Error occured when retrieving credentials, check logs"

    header = {
        "Authorization": token,
    }

    url = "https://api.fr.cloud.gov/v3/service_instances/{}/credentials".format(GUID)

    response = requests.get(url, headers=header)

    try:
        response.raise_for_status()
    except requests.exceptions.HTTPError as error:
        if response.status_code == 401:
            logger.error("Token may be expired, try generating new bearer token using `cf oauth-token > token.txt`")
        slack_message(error_message)
        logger.error("Error occured with retrieving credentials: {}".format(error))
        raise

    creds = response.json()

    logger.info("Existing Credentials:")
    logger.info(creds)

    return creds


def update_credentials(creds, update_data):
    creds.update(update_data)

    logger.info("Updated Credentials:")
    logger.info(creds)

    return {"credentials": creds}


def update_credentials_by_guid(token, GUID, merged_creds):
    error_message = "Error occured when updating environment variables, check logs"

    header = {
        "Authorization": token,
        "Content-Type": "application/json"
    }

    url = "https://api.fr.cloud.gov/v3/service_instances/{}".format(GUID)

    response = requests.patch(url, json=merged_creds, headers=header)

    try:
        response.raise_for_status()
    except requests.exceptions.HTTPError as error:
        if response.status_code == 401:
            logger.error("Token may be expired, try generating new bearer token using `cf oauth-token > token.txt`")
        slack_message(error_message)
        logger.error("Error occured with updating credentials: {}".format(error))
        raise


def create_and_update_public_api_key(
        space,
        service_instance_name,
        token,
        first_rate_limit,
        first_rate_limit_duration,
        second_rate_limit,
        second_rate_limit_duration):

    new_api_key = create_public_api_key(
        space,
        first_rate_limit,
        first_rate_limit_duration,
        second_rate_limit,
        second_rate_limit_duration)

    update_env_vars(space, service_instance_name, token, {"FEC_WEB_API_KEY_PUBLIC": new_api_key})


def update_env_vars(space, service_instance_name, token, credentials_dict):

    logger.info("Updating environment variable(s) for {} service instance in {} space."
                .format(service_instance_name, space))

    space_guid = get_space_guid(token, space)

    service_guid = get_service_instance_guid(token, space_guid, service_instance_name)

    creds = get_credentials_by_guid(token, service_guid)

    merged_creds = update_credentials(creds, credentials_dict)

    update_credentials_by_guid(token, service_guid, merged_creds)

    message = "Environment variables have been updated for {} service instance in {} space".format(
        service_instance_name,
        space)

    slack_message(message)

    logger.info(message)


def cf_startup():
    """Migrate schemas on `cf push`."""
    check_config()
    if env.index == "0":
        subprocess.Popen(["python", "cli.py", "refresh_materialized"])


def slack_message(message):
    """ Sends a message to the bots channel. you can add this command to ping you when a task is done, etc.
    run ./manage.py slack_message 'The message you want to post'
    """
    post_to_slack(message, "#bots")
