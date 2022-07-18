#!/usr/bin/env python

import click
import logging
import manage

from flask.cli import FlaskGroup
from webservices.common import models
from webservices.rest import app, db
import webservices.legal_docs as legal_docs


cli = FlaskGroup(app)
logger = logging.getLogger("cli")

@app.cli.command('load_regulations')
def load_regulations():
    legal_docs.load_regulations()  

@app.cli.command('load_statutes')
def load_statutes():
    legal_docs.load_statutes()

@app.cli.command('load_advisory_opinions')
def load_advisory_opinions():
    legal_docs.load_advisory_opinions()

@app.cli.command('load_current_murs')
def load_current_murs():
    legal_docs.load_current_murs()  

@app.cli.command('load_adrs')
def load_adrs():
    legal_docs.load_adrs()

@app.cli.command('load_admin_fines')
def load_admin_fines():
    legal_docs.load_admin_fines()

@app.cli.command('load_archived_murs')
def load_archived_murs():
    legal_docs.load_archived_murs()

@app.cli.command('extract_pdf_text')
def extract_pdf_text():
    legal_docs.extract_pdf_text()

@app.cli.command('delete_doctype_from_es')
def delete_doctype_from_es():
    legal_docs.delete_doctype_from_es()

@app.cli.command('delete_single_doctype_from_es')
def delete_single_doctype_from_es():
    legal_docs.delete_single_doctype_from_es()

@app.cli.command('delete_murs_from_s3')
def delete_murs_from_s3():
    legal_docs.delete_murs_from_s3()

@app.cli.command('show_legal_data')
def show_legal_data():
    legal_docs.show_legal_data()

@app.cli.command('create_index')
def create_index():
    legal_docs.create_index()  

@app.cli.command('restore_from_staging_index')
def restore_from_staging_index():
    legal_docs.restore_from_staging_index()

@app.cli.command('delete_index')
def delete_index():
    legal_docs.delete_index()

@app.cli.command('display_index_alias')
def display_index_alias():
    legal_docs.display_index_alias()  

@app.cli.command('display_mappings')
def display_mappings():
    legal_docs.display_mappings()

@app.cli.command('initialize_current_legal_docs')
def initialize_current_legal_docs():
    legal_docs.initialize_current_legal_docs()

@app.cli.command('initialize_archived_mur_docs')
def initialize_archived_mur_docs():
    legal_docs.initialize_archived_mur_docs()

@app.cli.command('refresh_current_legal_docs_zero_downtime')
def refresh_current_legal_docs_zero_downtime():
    legal_docs.refresh_current_legal_docs_zero_downtime()

@app.cli.command('configure_snapshot_repository')
def configure_snapshot_repository():
    legal_docs.configure_snapshot_repository()

@app.cli.command('delete_repository')
def delete_repository():
    legal_docs.delete_repository()

@app.cli.command('display_repositories')
def display_repositories():
    legal_docs.display_repositories()

@app.cli.command('create_es_snapshot')
def create_es_snapshot():
    legal_docs.create_es_snapshot()

@app.cli.command('restore_es_snapshot')
def restore_es_snapshot():
    legal_docs.restore_es_snapshot()

@app.cli.command('restore_es_snapshot_downtime')
def restore_es_snapshot_downtime():
    legal_docs.restore_es_snapshot_downtime()

@app.cli.command('delete_snapshot')
def delete_snapshot():
    legal_docs.delete_snapshot()

@app.cli.command('display_snapshots')
def display_snapshots():
    legal_docs.display_snapshots()

@app.cli.command('display_snapshot_detail')
def display_snapshot_detail():
    legal_docs.display_snapshot_detail()


@app.cli.command('refresh_materialized')
# @click.option('--concurrent/--no-concurrent', type=bool, default=True)
@click.argument('concurrent', default=True, type=bool)
def refresh_materialized_cli(concurrent=True):
    manage.refresh_materialized()


@app.cli.command('cf_startup')
def cf_startup_cli():
    manage.cf_startup()


@app.cli.command('slack_message')
@click.argument('message')
def slack_message_cli(message):
    manage.slack_message(message)


@app.shell_context_processor
def make_shell_context():
    return {'app': app, 'db': db, 'models': models}


if __name__ == "__main__":
    cli()
