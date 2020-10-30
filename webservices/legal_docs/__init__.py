import logging
import sys

from .advisory_opinions import load_advisory_opinions

from .current_cases import (
    load_current_murs,
    load_adrs,
    load_admin_fines,
)

from .archived_murs import ( # noqa
    load_archived_murs,
    extract_pdf_text,
)

from .statutes import (  # noqa
    load_statutes,
)

from .regulations import (  # noqa
    load_regulations,
)

from .es_management import (  # noqa
    DOCS_INDEX,
    DOCS_INDEX_ALIAS,
    DOCS_STAGING_INDEX,
    SEARCH_ALIAS,
    ARCHIVED_MURS_INDEX,
    ARCHIVED_MURS_INDEX_ALIAS,
    create_index,
    delete_index,
    display_index_alias,
    move_alias,
    display_mappings,
    restore_from_staging_index,
    configure_snapshot_repository,
    delete_repository,
    display_repositories,
    create_es_snapshot,
    restore_es_snapshot,
    restore_es_snapshot_downtime,
    delete_snapshot,
    display_snapshots,
    display_snapshot_detail,
    delete_advisory_opinions_from_es,
    delete_current_murs_from_es,
    delete_murs_from_s3,
)

from .show_legal_data import ( # noqa
    show_legal_data,
)

logging.basicConfig(level=logging.INFO, stream=sys.stdout)
logger = logging.getLogger("elasticsearch")
logger.setLevel("WARN")
logger = logging.getLogger("pdfminer")
logger.setLevel("ERROR")
logger = logging.getLogger("botocore")
logger.setLevel("WARN")


def load_current_legal_docs():
    load_advisory_opinions()
    load_current_murs()
    load_adrs()
    load_admin_fines()
    load_statutes()
    load_regulations()


def initialize_current_legal_docs():
    """
    Create the Elasticsearch DOCS_INDEX and loads all the different types of legal documents.
    This would lead to a brief outage while the docs are reloaded.
    """
    create_index(DOCS_INDEX, (DOCS_INDEX_ALIAS + "," + SEARCH_ALIAS))
    load_current_legal_docs()


def initialize_archived_mur_docs():
    """
    Create the Elasticsearch ARCHIVED_MURS_INDEX and loads all the archived mur legal documents.
    This would lead to a brief outage while the docs are reloaded.
    """
    create_index(ARCHIVED_MURS_INDEX, (ARCHIVED_MURS_INDEX_ALIAS + "," + SEARCH_ALIAS))
    load_archived_murs()


def refresh_current_legal_docs_zero_downtime():
    """
    Create a staging index and loads all the different types of legal documents into it.
    When done, moves the staging index to the production index with no downtime.
    This is typically used when there is a schema change.
    """

    # Create docs_staging index
    create_index(DOCS_STAGING_INDEX)

    # Move the alias docs_index to point to `docs_staging` instead of `docs`
    move_alias(DOCS_INDEX, DOCS_INDEX_ALIAS, DOCS_STAGING_INDEX)

    load_current_legal_docs()
    restore_from_staging_index()
