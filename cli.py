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

cli.command(legal_docs.load_regulations)
cli.command(legal_docs.load_statutes)
cli.command(legal_docs.load_advisory_opinions)
cli.command(legal_docs.load_current_murs)
cli.command(legal_docs.load_adrs)
cli.command(legal_docs.load_admin_fines)
cli.command(legal_docs.load_archived_murs)
cli.command(legal_docs.extract_pdf_text)

cli.command(legal_docs.delete_doctype_from_es)
cli.command(legal_docs.delete_single_doctype_from_es)
cli.command(legal_docs.delete_murs_from_s3)
cli.command(legal_docs.show_legal_data)

cli.command(legal_docs.create_index)
cli.command(legal_docs.restore_from_staging_index)
cli.command(legal_docs.delete_index)
cli.command(legal_docs.display_index_alias)
cli.command(legal_docs.display_mappings)

cli.command(legal_docs.initialize_current_legal_docs)
cli.command(legal_docs.initialize_archived_mur_docs)
cli.command(legal_docs.refresh_current_legal_docs_zero_downtime)

cli.command(legal_docs.configure_snapshot_repository)
cli.command(legal_docs.delete_repository)
cli.command(legal_docs.display_repositories)

cli.command(legal_docs.create_es_snapshot)
cli.command(legal_docs.restore_es_snapshot)
cli.command(legal_docs.restore_es_snapshot_downtime)
cli.command(legal_docs.delete_snapshot)
cli.command(legal_docs.display_snapshots)
cli.command(legal_docs.display_snapshot_detail)


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
