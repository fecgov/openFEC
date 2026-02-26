#!/usr/bin/env python

import click
import logging
import manage

from flask.cli import FlaskGroup
from webservices.rest import create_app
import webservices.legal.legal_docs as legal_docs
import webservices.legal.rulemaking_docs as rulemaking_docs
import webservices.legal.utils_opensearch as utils_opensearch
import webservices.legal.utils_load as load_utils
from webservices.legal.constants import CASE_REPO, CASE_INDEX


cli = FlaskGroup(create_app=create_app)
logger = logging.getLogger("cli")


# begin -- rulemaking commands


@cli.command('load_rulemaking')
@click.argument('rm_no', default=None, required=False)
def load_rulemaking_cli(rm_no):
    rulemaking_docs.load_rulemaking(rm_no)


@cli.command('load_large_rulemaking')
@click.argument('rm_no', required=True)
def load_large_rulemaking_cli(rm_no):
    rulemaking_docs.load_large_rulemaking(rm_no)


# end -- rulemaking commands


@cli.command('load_statutes')
def load_statutes_cli():
    legal_docs.load_statutes()


@cli.command('load_advisory_opinions')
@click.argument('from_ao_no', default=None, required=False)
def load_advisory_opinions_cli(from_ao_no):
    legal_docs.load_advisory_opinions(from_ao_no)


@cli.command('load_current_murs')
@click.argument('specific_mur_no', default=None, required=False)
def load_current_murs_cli(specific_mur_no):
    legal_docs.load_current_murs(specific_mur_no)


@cli.command('load_adrs')
@click.argument('specific_adr_no', default=None, required=False)
def load_adrs_cli(specific_adr_no):
    legal_docs.load_adrs(specific_adr_no)


@cli.command('load_admin_fines')
@click.argument('specific_af_no', default=None, required=False)
def load_admin_fines_cli(specific_af_no):
    legal_docs.load_admin_fines(specific_af_no)


@cli.command('load_archived_murs')
@click.argument('mur_no', default=None, required=False)
def load_archived_murs_cli(mur_no):
    legal_docs.load_archived_murs(mur_no)


@cli.command('extract_pdf_text')
@click.argument('mur_no', default=None, required=False)
def extract_pdf_text_cli(mur_no):
    legal_docs.extract_pdf_text(mur_no)


@cli.command('delete_doctype_from_opensearch')
@click.argument('index_name', default=None, required=False)
@click.argument('doc_type', default=None, required=False)
def delete_doctype_from_opensearch_cli(index_name, doc_type):
    utils_opensearch.delete_doctype_from_opensearch(index_name, doc_type)


@cli.command('delete_single_doctype_from_opensearch')
@click.argument('index_name', default=None, required=False)
@click.argument('doc_type', default=None, required=False)
@click.argument('num_doc_id', default=None, required=False)
def delete_single_doctype_from_opensearch_cli(index_name, doc_type, num_doc_id):
    utils_opensearch.delete_single_doctype_from_opensearch(index_name, doc_type, num_doc_id)


@cli.command('delete_murs_from_s3')
def delete_murs_from_s3_cli():
    utils_opensearch.delete_murs_from_s3()


@cli.command('show_legal_data')
def show_legal_data_cli():
    legal_docs.show_legal_data()


@cli.command('create_index')
@click.argument('index_name', default=None, required=False)
def create_index_cli(index_name):
    utils_opensearch.create_index(index_name)


@cli.command('delete_index')
@click.argument('index_name', required=True)
def delete_index_cli(index_name):
    utils_opensearch.delete_index(index_name)


@cli.command('display_index_alias')
def display_index_alias_cli():
    utils_opensearch.display_index_alias()


@cli.command('display_mapping')
@click.argument('index_name', default=None, required=False)
def display_mapping_cli(index_name):
    utils_opensearch.display_mapping(index_name)


@cli.command('reload_all_data_by_index')
@click.argument('index_name', default=None, required=False)
def reload_all_data_by_index_cli(index_name):
    load_utils.reload_all_data_by_index(index_name)


@cli.command('initialize_legal_data')
@click.argument('index_name', default=None, required=False)
def initialize_legal_data_cli(index_name):
    load_utils.initialize_legal_data(index_name)


@cli.command('update_mapping_and_reload_legal_data')
@click.argument('index_name', default=None, required=False)
def update_mapping_and_reload_legal_data_cli(index_name):
    load_utils.update_mapping_and_reload_legal_data(index_name)


@cli.command('configure_snapshot_repository')
@click.argument('repo_name', default=CASE_REPO, required=False)
def configure_snapshot_repository_cli(repo_name):
    utils_opensearch.configure_snapshot_repository(repo_name)


@cli.command('delete_repository')
@click.argument('repo_name', required=True)
def delete_repository_cli(repo_name):
    utils_opensearch.delete_repository(repo_name)


@cli.command('display_repositories')
def display_repositories_cli():
    utils_opensearch.display_repositories()


@cli.command('create_opensearch_snapshot')
@click.argument('index_name', default=CASE_INDEX, required=False)
def create_opensearch_snapshot_cli(index_name):
    utils_opensearch.create_opensearch_snapshot(index_name)


@cli.command('restore_opensearch_snapshot')
@click.argument('repo_name', default=None, required=False)
@click.argument('snapshot_name', default=None, required=False)
@click.argument('index_name', default=None, required=False)
def restore_opensearch_snapshot_cli(repo_name, snapshot_name, index_name):
    utils_opensearch.restore_opensearch_snapshot(repo_name, snapshot_name, index_name)


@cli.command('restore_opensearch_snapshot_downtime')
@click.argument('repo_name', default=None, required=False)
@click.argument('snapshot_name', default=None, required=False)
@click.argument('index_name', default=None, required=False)
def restore_opensearch_snapshot_downtime_cli(repo_name, snapshot_name, index_name):
    utils_opensearch.restore_opensearch_snapshot_downtime(repo_name, snapshot_name, index_name)


@cli.command('delete_snapshot')
@click.argument('repo_name', default=None, required=False)
@click.argument('snapshot_name', default=None, required=False)
def delete_snapshot_cli(repo_name, snapshot_name):
    utils_opensearch.delete_snapshot(repo_name, snapshot_name)


@cli.command('display_snapshots')
@click.argument('repo_name', default=None, required=False)
def display_snapshots_cli(repo_name):
    utils_opensearch.display_snapshots(repo_name)


@cli.command('display_snapshot_detail')
@click.argument('repo_name', default=None, required=False)
@click.argument('snapshot_name', default=None, required=False)
def display_snapshot_detail_cli(repo_name, snapshot_name):
    utils_opensearch.display_snapshot_detail(repo_name, snapshot_name)


@cli.command('refresh_materialized')
@click.argument('concurrent', default=True, type=bool)
def refresh_materialized_cli(concurrent=True):
    manage.refresh_materialized()


@cli.command('cf_startup')
def cf_startup_cli():
    manage.cf_startup()


@cli.command('update_public_api_key')
@click.argument('space', default=None, required=True)
@click.argument('service_instance_name', default=None, required=True)
@click.argument('token', default=None, required=True)
@click.argument('first_rate_limit', default=250, required=False)
@click.argument('first_rate_limit_duration', default=60000, required=False)
@click.argument('second_rate_limit', default=30000, required=False)
@click.argument('second_rate_limit_duration', default=86400000, required=False)
def create_and_update_public_api_key_cli(
        space,
        service_instance_name,
        token,
        first_rate_limit,
        first_rate_limit_duration,
        second_rate_limit,
        second_rate_limit_duration):
    manage.create_and_update_public_api_key(
        space,
        service_instance_name,
        token,
        first_rate_limit,
        first_rate_limit_duration,
        second_rate_limit,
        second_rate_limit_duration)


@cli.command('remove_env_var')
@click.argument('space', default=None, required=True)
@click.argument('service_instance_name', default=None, required=True)
@click.argument('key_to_remove', required=True)
def remove_env_var_cli(
        space,
        service_instance_name,
        key_to_remove):
    manage.add_update_remove_env_var(
        space,
        service_instance_name,
        key_to_remove)


@cli.command('add_update_env_var')
@click.argument('space', default=None, required=True)
@click.argument('service_instance_name', default=None, required=True)
@click.argument('key', required=True)
@click.argument('value', required=True)
def add_update_env_var_cli(
        space,
        service_instance_name,
        key,
        value):
    manage.add_update_remove_env_var(
        space,
        service_instance_name,
        key,
        value)


@cli.command('slack_message')
@click.argument('message')
def slack_message_cli(message):
    manage.slack_message(message)


if __name__ == "__main__":
    cli()
