import webservices.legal.constants as constants
import logging

from webservices.legal.utils_opensearch import (
    create_index, switch_alias, restore_from_swapping_index,
    INDEX_DICT, create_opensearch_client, delete_index,
)

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
        swap_index = INDEX_DICT.get(index_name)[3]
        delete_index(swap_index)
        create_index(index_name)
        reload_all_data_by_index(index_name)
    else:
        logger.error(" Invalid index '{0}', unable to initialize this index.".format(index_name))


def slow_reload_zero_downtime(index_name=None):
    """
    Reload all legal data into a fresh index, then switch aliases once complete (no downtime).
    Alternates between XXXX_INDEX and XXXX_SWAP_INDEX on each run by checking which physical
    index search_alias currently points to. Safe to re-run after failure: deletes any stale
    incomplete new index before starting.

    Steps:
    1. Check search_alias to find the current live index; the other becomes the new target
    2. Delete the new target index if it exists (cleanup from a prior failed run)
    3. Create the new target index with correct mapping (no aliases yet)
    4. Move XXXX_ALIAS to new index so loaders write there; SEARCH_ALIAS stays on old index
    5. Load all legal data into new index
    6. Atomically move both aliases to new index (only after load completes)
    7. Delete old index

    How to call task command:
    a) cf run-task api --command "python cli.py slow_reload_zero_downtime case_index" -m 4G
    --name slow_reload_zero_downtime_case
    b) cf run-task api --command "python cli.py slow_reload_zero_downtime ao_index" -m 4G
    --name slow_reload_zero_downtime_ao
    c) cf run-task api --command "python cli.py slow_reload_zero_downtime arch_mur_index" -m 4G
    --name slow_reload_zero_downtime_arch_mur
    d) cf run-task api --command "python cli.py slow_reload_zero_downtime rm_index" -m 4G
    --name slow_reload_zero_downtime_rm
    """
    index_name = index_name or constants.CASE_INDEX
    if index_name not in INDEX_DICT.keys():
        logger.error(" Invalid index '{0}', unable to reload.".format(index_name))
        return

    swap_index = INDEX_DICT.get(index_name)[3]
    xxxx_alias = INDEX_DICT.get(index_name)[1]
    search_alias = INDEX_DICT.get(index_name)[2]

    opensearch_client = create_opensearch_client()

    # 1) Find the current live index via xxxx_alias (unique per index), determine the new target
    try:
        aliases = opensearch_client.indices.get_alias(name=xxxx_alias)
        old_index = list(aliases.keys())[0]
        logger.info(" Alias '{0}' currently points to '{1}'.".format(xxxx_alias, old_index))
        new_index = swap_index if old_index == index_name else index_name
    except Exception:
        # Alias doesn't exist yet (first run or broken state), default to swap_index
        logger.warning(" Alias '{0}' not found, defaulting to first run.".format(xxxx_alias))
        old_index = None
        new_index = swap_index

    # 2) Delete new_index if it exists (stale from a prior failed run)
    if opensearch_client.indices.exists(index=new_index):
        opensearch_client.indices.delete(index=new_index)
        logger.info(" Deleted stale index '{0}'.".format(new_index))

    # 3) Create new index with correct mapping, no aliases yet
    _create_index_without_aliases(new_index, INDEX_DICT.get(index_name)[0], opensearch_client)

    # 4) Move xxxx_alias to new_index so loaders write there; search_alias stays on old_index
    actions = [{"add": {"index": new_index, "alias": xxxx_alias}}]
    if old_index and opensearch_client.indices.exists(index=old_index):
        actions.append({"remove": {"index": old_index, "alias": xxxx_alias}})
    opensearch_client.indices.update_aliases(body={"actions": actions})
    logger.info(" Pointed write alias '{0}' at '{1}' for loading.".format(xxxx_alias, new_index))

    # 5) Load all data into new_index via xxxx_alias
    reload_all_data_by_index(index_name)
    logger.info(" Load complete. Switching aliases to '{0}'.".format(new_index))

    # 6) Move both aliases to new_index now that load is complete
    actions = [{"add": {"index": new_index, "alias": search_alias}}]
    if old_index and opensearch_client.indices.exists(index=old_index):
        actions += [
            {"remove": {"index": old_index, "alias": search_alias}},
            {"remove": {"index": old_index, "alias": xxxx_alias}},
        ]
    opensearch_client.indices.update_aliases(body={"actions": actions})
    logger.info(" Aliases '{0}' and '{1}' now point to '{2}'.".format(
        xxxx_alias, search_alias, new_index))

    # 7) Delete old_index now that new_index is live
    if old_index and opensearch_client.indices.exists(index=old_index):
        opensearch_client.indices.delete(old_index)
        logger.info(" Deleted old index '{0}'.".format(old_index))

    logger.info(" slow_reload_zero_downtime on '{0}' completed successfully.".format(index_name))


def _create_index_without_aliases(index_name, mapping, opensearch_client):
    body = {
        "settings": constants.ANALYZER_SETTING,
        "mappings": mapping,
    }
    logger.info(" Creating index '{0}'...".format(index_name))
    opensearch_client.indices.create(index=index_name, body=body)
    logger.info(" Created index '{0}'.".format(index_name))


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
