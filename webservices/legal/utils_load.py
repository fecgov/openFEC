import webservices.legal.constants as constants
import logging

from webservices.legal.utils_opensearch import create_index, switch_alias, restore_from_swapping_index, INDEX_DICT

from webservices.legal.legal_docs.current_cases import (
    load_current_murs,
    load_adrs,
    load_admin_fines,
)

from webservices.legal.legal_docs.archived_murs import ( # noqa
    load_archived_murs,
)

from webservices.legal.legal_docs.advisory_opinions import ( # noqa
    load_advisory_opinions,
)

from webservices.legal.legal_docs.statutes import (  # noqa
    load_statutes,
)

from webservices.legal.rulemaking_docs.rulemaking import load_rulemaking


logger = logging.getLogger(__name__)


def reload_all_data_by_index(index_name=None):
    """
    - Reload all legal data by specify 'XXXX_INDEX' (it takes 15mins ~ 2+ hours) without downtime.
    'INDEX_DICT' description:
    1) CASE_INDEX includes DOCUMENT_TYPE=('murs','adrs','admin_fines')
    'murs' means current mur only.
    2) AO_INDEX includes DOCUMENT_TYPE=('advisory_opinions','statutes')
    3) ARCH_MUR_INDEX includes DOCUMENT_TYPE=('murs'), archived mur only

    - How to call task command:
    a) cf run-task api --command "python cli.py reload_all_data_by_index case_index" -m 4G --name reload_all_data_case
    b) cf run-task api --command "python cli.py reload_all_data_by_index ao_index" -m 4G --name reload_all_data_ao
    c) cf run-task api --command "python cli.py reload_all_data_by_index arch_mur_index" -m 4G
    --name reload_all_data_arch_mur
    d) cf run-task api --command "python cli.py reload_all_data_by_index rm_index" -m 4G
    --name reload_all_data_rm
    """
    index_name = index_name or constants.CASE_INDEX
    if index_name in INDEX_DICT.keys():
        if index_name == constants.CASE_INDEX:
            load_current_murs()
            load_adrs()
            load_admin_fines()
        elif index_name == constants.AO_INDEX:
            load_advisory_opinions()
            load_statutes()
        elif index_name == constants.ARCH_MUR_INDEX:
            load_archived_murs()
        elif index_name == constants.RM_INDEX:
            load_rulemaking()
    else:
        logger.error(" Invalid index '{0}', unable to reload this index.".format(index_name))


def initialize_legal_data(index_name=None):
    """
    When first time load legal data, run this command with downtime (15mins ~ 2+ hours)
    - Create a XXXX_INDEX on Opensearch based on 'INDEX_DICT'.
    'INDEX_DICT' description:
    1) CASE_INDEX includes DOCUMENT_TYPE=('murs','adrs','admin_fines')
    'murs' means current mur only.
    2) AO_INDEX includes DOCUMENT_TYPE=('advisory_opinions','statutes')
    3) ARCH_MUR_INDEX includes DOCUMENT_TYPE=('murs'), archived mur only
    - Loads legal data to XXXX_INDEX
    - How to call task command:
    a) cf run-task api --command "python cli.py initialize_legal_data case_index" -m 4G --name init_case_data
    b) cf run-task api --command "python cli.py initialize_legal_data ao_index" -m 4G --name init_ao_data
    c) cf run-task api --command "python cli.py initialize_legal_data arch_mur_index" -m 4G --name init_arch_mur_data
    d) cf run-task api --command "python cli.py initialize_legal_data rm_index" -m 4G --name init_rm_data
    """
    index_name = index_name or constants.CASE_INDEX
    if index_name in INDEX_DICT.keys():
        create_index(index_name)
        reload_all_data_by_index(index_name)
    else:
        logger.error(" Invalid index '{0}', unable to initialize this index.".format(index_name))


def update_mapping_and_reload_legal_data(index_name=None):
    """
    When mapping change, run this command with short downtime(<5 mins)

    Nine steps process:
    1. Create a XXXX_SWAP_INDEX
    2. Switch original_alias(XXXX_ALIAS) point to XXXX_SWAP_INDEX
    3. Load the legal data into original_alias(==XXXX_SWAP_INDEX)
    4. Switch the SEARCH_ALIAS point to XXXX_SWAP_INDEX
    5. Re-create original_index (XXXX_INDEX)
    6. Remove XXXX_ALIAS and SEARCH_ALIAS that point new empty XXXX_INDEX
    7. Re-index XXXX_INDEX based on XXXX_SWAP_INDEX
    8. Switch aliases (XXXX_ALIAS,SEARCH_ALIAS) point back to XXXX_INDEX
    9. Delete XXXX_SWAP_INDEX

    -How to call task command:
    a) cf run-task api --command "python cli.py update_mapping_and_reload_legal_data case_index" -m 4G
    --name update_mapping_reload_data_case
    b) cf run-task api --command "python cli.py update_mapping_and_reload_legal_data ao_index" -m 4G
    --name update_mapping_reload_data_ao
    c) cf run-task api --command "python cli.py update_mapping_and_reload_legal_data arch_mur_index" -m 4G
    --name update_mapping_reload_data_arch_mur
    """
    index_name = index_name or constants.CASE_INDEX
    if index_name in INDEX_DICT.keys():
        # 1) Create 'XXXX_SWAP_INDEX'
        create_index(INDEX_DICT.get(index_name)[3])

        # 2) Switch the XXXX_ALIAS to point to XXXX_SWAP_INDEX instead of XXXX_INDEX.
        switch_alias(index_name, INDEX_DICT.get(index_name)[1], INDEX_DICT.get(index_name)[3])

        # 3) Load legal data to original_alias(XXXX_ALIAS) that points to XXXX_SWAP_INDEX now
        reload_all_data_by_index(index_name)

        # 4) Restore data from XXXX_SWAP_INDEX
        restore_from_swapping_index(index_name)
