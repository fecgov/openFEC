import logging
import sys

from .advisory_opinions import load_advisory_opinions # noqa

from .current_cases import ( # noqa
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


from webservices.legal.constants import (  # noqa
    CASE_INDEX,
    ARCH_MUR_INDEX,
    AO_INDEX,
    CASE_ALIAS,
    AO_ALIAS,
    ARCH_MUR_ALIAS,
    SEARCH_ALIAS,
    TEST_CASE_INDEX,
    TEST_CASE_ALIAS,
    TEST_AO_INDEX,
    TEST_AO_ALIAS,
    TEST_SEARCH_ALIAS,
    TEST_ARCH_MUR_INDEX,
    TEST_ARCH_MUR_ALIAS,
)

from webservices.legal.utils_opensearch import( # noqa
    INDEX_DICT,
    create_index,
    delete_index,
    display_index_alias,
    switch_alias,
    display_mapping,
    restore_from_swapping_index,
    configure_snapshot_repository,
    delete_repository,
    display_repositories,
    create_opensearch_snapshot,
    restore_opensearch_snapshot,
    restore_opensearch_snapshot_downtime,
    delete_snapshot,
    display_snapshots,
    display_snapshot_detail,
    delete_murs_from_s3,
    delete_doctype_from_es,
    delete_single_doctype_from_es,
    create_test_indices
)

from .show_legal_data import ( # noqa
    show_legal_data,
)

logging.basicConfig(level=logging.INFO, stream=sys.stdout)
logger = logging.getLogger("opensearch")
logger.setLevel("WARN")
logger = logging.getLogger("botocore")
logger.setLevel("WARN")
