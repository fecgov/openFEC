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
    create_docs_index,
    create_archived_murs_index,
    delete_all_indices,
    create_staging_index,
    restore_from_staging_index,
    move_archived_murs,
    configure_backup_repository,
    configure_snapshot_repository,
    create_elasticsearch_backup,
    restore_elasticsearch_backup,
    delete_advisory_opinions_from_es,
    delete_current_murs_from_es,
    delete_murs_from_s3,
)

from .check_legal_data import ( # noqa
    check_legal_data,
)

logging.basicConfig(level=logging.INFO, stream=sys.stdout)
logger = logging.getLogger('elasticsearch')
logger.setLevel('WARN')
logger = logging.getLogger('pdfminer')
logger.setLevel('ERROR')
logger = logging.getLogger('botocore')
logger.setLevel('WARN')


def load_current_legal_docs():
    load_advisory_opinions()
    load_current_murs()
    load_adrs()
    load_admin_fines()
    load_statutes()
    load_regulations()


def initialize_current_legal_docs():
    """
    Create the Elasticsearch index and loads all the different types of legal documents.
    This would lead to a brief outage while the docs are reloaded.
    """
    create_docs_index()
    load_current_legal_docs()


def refresh_current_legal_docs_zero_downtime():
    """
    Create a staging index and loads all the different types of legal documents into it.
    When done, moves the staging index to the production index with no downtime.
    This is typically used when there is a schema change.
    """
    create_staging_index()
    load_current_legal_docs()
    restore_from_staging_index()
