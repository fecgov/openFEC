#!/usr/bin/env python

import glob
import logging
import subprocess
import multiprocessing
import networkx as nx
import sqlalchemy as sa

from flask_script import Server
from flask_script import Manager
from webservices import flow
from webservices.common import models
from webservices.env import env
from webservices.rest import app, db
from webservices.config import SQL_CONFIG, check_config
from webservices.common.util import get_full_path
import webservices.legal_docs as legal_docs
from webservices.utils import post_to_slack

manager = Manager(app)
logger = logging.getLogger("manager")

# The Flask app server should only be used for local testing, so we default to
# using debug mode and auto-reload. To disable debug mode locally, pass the
# --no-debug flag to `runserver`.
manager.add_command("runserver", Server(use_debugger=True, use_reloader=True))

manager.command(legal_docs.load_regulations)
manager.command(legal_docs.load_statutes)
manager.command(legal_docs.load_advisory_opinions)
manager.command(legal_docs.load_current_murs)
manager.command(legal_docs.load_adrs)
manager.command(legal_docs.load_admin_fines)
manager.command(legal_docs.load_archived_murs)
manager.command(legal_docs.extract_pdf_text)

manager.command(legal_docs.delete_doctype_from_es)
manager.command(legal_docs.delete_single_doctype_from_es)
manager.command(legal_docs.delete_murs_from_s3)
manager.command(legal_docs.show_legal_data)

manager.command(legal_docs.create_index)
manager.command(legal_docs.restore_from_staging_index)
manager.command(legal_docs.delete_index)
manager.command(legal_docs.display_index_alias)
manager.command(legal_docs.display_mappings)

manager.command(legal_docs.initialize_current_legal_docs)
manager.command(legal_docs.initialize_archived_mur_docs)
manager.command(legal_docs.refresh_current_legal_docs_zero_downtime)

manager.command(legal_docs.configure_snapshot_repository)
manager.command(legal_docs.delete_repository)
manager.command(legal_docs.display_repositories)

manager.command(legal_docs.create_es_snapshot)
manager.command(legal_docs.restore_es_snapshot)
manager.command(legal_docs.restore_es_snapshot_downtime)
manager.command(legal_docs.delete_snapshot)
manager.command(legal_docs.display_snapshots)
manager.command(legal_docs.display_snapshot_detail)


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


@manager.command
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
                logger.error("Error refreshing node %s: not found.".format(node))

    logger.info("Finished refreshing materialized views.")


@manager.command
def cf_startup():
    """Migrate schemas on `cf push`."""
    check_config()
    if env.index == "0":
        subprocess.Popen(["python", "manage.py", "refresh_materialized"])


@manager.command
def slack_message(message):
    """ Sends a message to the bots channel. you can add this command to ping you when a task is done, etc.
    run ./manage.py slack_message 'The message you want to post'
    """
    post_to_slack(message, "#bots")


@manager.shell
def make_shell_context():
    return dict(app=app, db=db, models=models)


if __name__ == "__main__":
    manager.run()
