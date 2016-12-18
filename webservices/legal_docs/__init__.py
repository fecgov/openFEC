DOCS_INDEX = 'docs_index'
DOCS_SEARCH = 'docs_search'

from .current_murs import load_current_murs

from .load_legal_docs import (
    delete_advisory_opinions_from_es,
    delete_advisory_opinions_from_s3,
    delete_murs_from_es,
    delete_murs_from_s3,
    index_advisory_opinions,
    index_regulations,
    index_statutes,
    load_advisory_opinions_into_s3,
    load_archived_murs,
    move_index_for_loads,
    move_index_for_searches,
    initialize_legal_docs)
