import logging
import sys

from .advisory_opinions import load_advisory_opinions
from .current_murs import load_current_murs

logging.basicConfig(level=logging.INFO, stream=sys.stdout)
logger = logging.getLogger('elasticsearch')
logger.setLevel('WARN')
logger = logging.getLogger('pdfminer')
logger.setLevel('ERROR')
logger = logging.getLogger('botocore')
logger.setLevel('WARN')

from .load_legal_docs import (
    delete_advisory_opinions_from_es,
    delete_current_murs_from_es,
    delete_murs_from_s3,
    index_regulations,
    index_statutes,
    load_archived_murs
)

from .index_management import (
    create_docs_index,
    create_archived_murs_index,
    delete_docs_index,
    create_staging_index,
    restore_from_staging_index,
    move_archived_murs
)

def load_current_legal_docs():
    index_statutes()
    index_regulations()
    load_advisory_opinions()
    load_current_murs()

def initialize_current_legal_docs():
    """
    Creates the Elasticsearch index and loads all the different types of legal documents.
    This would lead to a brief outage while the docs are reloaded.
    """
    create_docs_index()
    load_current_legal_docs()

def refresh_current_legal_docs_zero_downtime():
    """
    Creates a staging index and loads all the different types of legal documents into it.
    When done, moves the staging index to the production index with no downtime.
    This is typically used when there is a schema change.
    """
    create_staging_index()
    load_current_legal_docs()
    restore_from_staging_index()
