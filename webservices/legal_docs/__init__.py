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
    INDEX_DICT,
    CASE_INDEX,
    CASE_ALIAS,
    SEARCH_ALIAS,
    ARCH_MUR_INDEX,
    ARCH_MUR_ALIAS,
    AO_INDEX,
    AO_ALIAS,
    create_index,
    delete_index,
    display_index_alias,
    switch_alias,
    display_mapping,
    restore_from_swapping_index,
    configure_snapshot_repository,
    delete_repository,
    display_repositories,
    create_es_snapshot,
    restore_es_snapshot,
    restore_es_snapshot_downtime,
    delete_snapshot,
    display_snapshots,
    display_snapshot_detail,
    delete_murs_from_s3,
    delete_doctype_from_es,
    delete_single_doctype_from_es,
)

from .show_legal_data import ( # noqa
    show_legal_data,
)

logging.basicConfig(level=logging.INFO, stream=sys.stdout)
logger = logging.getLogger("elasticsearch")
logger.setLevel("WARN")
logger = logging.getLogger("botocore")
logger.setLevel("WARN")


def initialize_legal_data(index_name=None):
    """
    - Create a XXXX_INDEX on Elasticsearch
    'INDEX_DICT' description:
    1) CASE_INDEX include DOCUMENT_TYPE=('statutes','regulations','murs','adrs','admin_fines')
    'murs' means current mur only.
    2) AO_INDEX include DOCUMENT_TYPE=('advisory_opinions')
    3) ARCH_MUR_INDEX include DOCUMENT_TYPE=('murs'), archived mur only

    - Loads legal documents to XXXX_INDEX (a brief outage)

    - How to call task command:
    a) cf run-task api --command "python cli.py initialize_legal_data case_index" -m 4G --name init_case_data
    b) cf run-task api --command "python cli.py initialize_legal_data ao_index" -m 4G --name init_ao_data
    c) cf run-task api --command "python cli.py initialize_legal_data arch_mur_index" -m 4G --name init_arch_mur_data
    """
    index_name = index_name or CASE_INDEX
    if index_name in INDEX_DICT.keys():
        create_index(index_name)
        if index_name == CASE_INDEX:
            load_current_murs()
            load_adrs()
            load_admin_fines()
            load_statutes()
            load_regulations()
        elif index_name == AO_INDEX:
            load_advisory_opinions()
        elif index_name == ARCH_MUR_INDEX:
            load_archived_murs()
    else:
        logger.info(" Invalid index '{0}', unable to initialize this index.".format(index_name))


def refresh_legal_data_zero_downtime(index_name=None):
    """
    Eight steps process:
    1. Create a XXXX_SWAP_INDEX
    2. Switch original_alias(XXXX_ALIAS) point to XXXX_SWAP_INDEX
    3. Load the legal data into original_alias(==XXXX_SWAP_INDEX)
    4. Swith the SEARCH_ALIAS point to XXXX_SWAP_INDEX
    5. Re-create original_index (XXXX_INDEX)
    6. Re-index XXXX_INDEX based on XXXX_SWAP_INDEX
    7. Switch aliases (XXXX_ALIAS,SEARCH_ALIAS) point back to XXXX_INDEX
    8. Delete XXXX_SWAP_INDEX

    -How to call task command:
    a) cf run-task api --command "python cli.py refresh_legal_data_zero_downtime case_index" -m 4G
    --name refresh_case_data
    b) cf run-task api --command "python cli.py refresh_legal_data_zero_downtime ao_index" -m 4G
    --name refresh_ao_data
    c) cf run-task api --command "python cli.py refresh_legal_data_zero_downtime arch_mur_index" -m 4G
    --name refresh_arch_mur_data
    """

    index_name = index_name or CASE_INDEX
    if index_name in INDEX_DICT.keys():
        # 1) Create 'XXXX_SWAP_INDEX'
        create_index(INDEX_DICT.get(index_name)[3])

        # 2) Switch the XXXX_ALIAS to point to XXXX_SWAP_INDEX instead of XXXX_INDEX.
        switch_alias(index_name, INDEX_DICT.get(index_name)[1], INDEX_DICT.get(index_name)[3])

        # 3) Load legal data to original_alias that points to XXXX_SWAP_INDEX now
        if index_name == CASE_INDEX:
            load_current_murs()
            load_adrs()
            load_admin_fines()
            load_statutes()
            load_regulations()

        elif index_name == AO_INDEX:
            load_advisory_opinions()
        elif index_name == ARCH_MUR_INDEX:
            load_archived_murs()

        # 4) Restore data from XXXX_SWAP_INDEX
        restore_from_swapping_index(index_name)
