import logging
# import datetime
import json
import time
import webservices.constants as constants

from webservices.utils import (
    create_es_client,
    DateTimeEncoder,
)
# from webservices.env import env
# from webservices.tasks.utils import get_bucket
from webservices.legal_docs import es_management
from webservices.rulemaking import rm_mapping


logger = logging.getLogger(__name__)
# To debug, uncomment the line below:
# logger.setLevel(logging.DEBUG)

# SEARCH_ALIAS is used for legal/search endpoint
# RM_SEARCH_ALIAS is used for rulemaking/search endpoint
# XXXX_ALIAS is used for load data to XXXX_INDEX on Elasticsearch
INDEX_DICT = {
    constants.CASE_INDEX: (es_management.CASE_MAPPING, constants.CASE_ALIAS,
                           constants.SEARCH_ALIAS, constants.CASE_SWAP_INDEX,
                           constants.CASE_REPO, constants.CASE_SNAPSHOT),
    constants.AO_INDEX: (es_management.AO_MAPPING, constants.AO_ALIAS,
                         constants.SEARCH_ALIAS, constants.AO_SWAP_INDEX,
                         constants.AO_REPO, constants.AO_SNAPSHOT),
    constants.ARCH_MUR_INDEX: (es_management.ARCH_MUR_MAPPING, constants.ARCH_MUR_ALIAS, constants.SEARCH_ALIAS,
                               constants.ARCH_MUR_SWAP_INDEX,
                               constants.ARCH_MUR_REPO, constants.ARCH_MUR_SNAPSHOT),
    constants.CASE_SWAP_INDEX: (es_management.CASE_MAPPING, "", "", "", "", ""),
    constants.AO_SWAP_INDEX: (es_management.AO_MAPPING, "", "", "", "", ""),
    constants.ARCH_MUR_SWAP_INDEX: (es_management.ARCH_MUR_MAPPING, "", "", "", "", ""),
    constants.RM_INDEX: (rm_mapping.RM_MAPPING, constants.RM_ALIAS,
                         constants.RM_SEARCH_ALIAS, constants.RM_SWAP_INDEX,
                         constants.RM_REPO, constants.RM_SNAPSHOT),
}

TEST_INDEX_DICT = {
        constants.TEST_CASE_INDEX: (es_management.CASE_MAPPING,
                                    constants.TEST_CASE_ALIAS, constants.TEST_SEARCH_ALIAS),
        constants.TEST_AO_INDEX: (es_management.AO_MAPPING, constants.TEST_AO_ALIAS,
                                  constants.TEST_SEARCH_ALIAS),
        constants.TEST_ARCH_MUR_INDEX: (es_management.ARCH_MUR_MAPPING,
                                        constants.TEST_ARCH_MUR_ALIAS, constants.TEST_SEARCH_ALIAS)
}

ANALYZER_SETTING = {
    "analysis": {
        "analyzer": {
            "default": {
                "type": "standard"
            }
        }
    },
    "highlight.max_analyzed_offset": 60000000,
}


def create_index(index_name=None):
    """
    Creating an index for storing legal or rulemaking data on Elasticsearch based on 'INDEX_DICT'.
    - 'INDEX_DICT' description:
    1) CASE_INDEX includes DOCUMENT_TYPE=('statutes','murs','adrs','admin_fines')
    'murs' means current mur only.
    2) AO_INDEX includes DOCUMENT_TYPE=('advisory_opinions')
    3) ARCH_MUR_INDEX includes DOCUMENT_TYPE=('murs'), archived mur only
    4) RM_INDEX includes DOCUMENT_TYPE=('rulemaking')?

    -Two aliases will be created under each index: XXXX_ALIAS and SEARCH_ALIAS or RM_SEARCH_ALIAS
    a) XXXX_ALIAS is used for load data to XXXX_INDEX on Elasticsearch
    b) SEARCH_ALIAS is used for '/legal/search/' endpoint
    c) RM_SEARCH_ALIAS is used for '/rulemaking/search/' endpoint

    -How to call this function in python code:
    a) es_create_index(CASE_INDEX)
    b) es_create_index(AO_INDEX)
    c) es_create_index(ARCH_MUR_INDEX)
    d) es_create_index(RM_INDEX)

    -How to run command from terminal:
    a) python cli.py es_create_index case_index
    b) python cli.py es_create_index ao_index
    c) python cli.py es_create_index arch_mur_index
    d) python cli.py es_create_index rm_index

    -How to call task command:
    a) cf run-task api --command "python cli.py es_create_index" -m 2G --name create_case_index
    b) cf run-task api --command "python cli.py es_create_index ao_index" -m 2G --name create_ao_index
    c) cf run-task api --command "python cli.py es_create_index arch_mur_index" -m 2G --name create_arch_mur_index
    d) cf run-task api --command "python cli.py es_create_index rm_index" -m 2G --name create_rm_index

    -This function won't allow to create any other index that is not in 'INDEX_DICT'.
    """
    # index_name = index_name or CASE_INDEX
    body = {}
    aliases = {}
    body.update({"settings": ANALYZER_SETTING})

    if index_name in INDEX_DICT.keys():
        # Before creating index, delete this index and corresponding aliases first.
        delete_index(index_name)

        mapping, alias1, alias2 = INDEX_DICT.get(index_name)[:3]
        body.update({"mappings": mapping})

        if alias1 and alias2:
            aliases.update({alias1: {}})
            aliases.update({alias2: {}})
            body.update({"aliases": aliases})

        es_client = create_es_client()
        logger.info(" Creating index '{0}'...".format(index_name))
        es_client.indices.create(
            index=index_name,
            body=body,
        )
        logger.info(" The index '{0}' is created successfully.".format(index_name))
        if alias1 and alias2:
            logger.info(" The aliases for index '{0}': {1}, {2} are created successfully.".format(
                index_name,
                alias1,
                alias2))
    else:
        logger.error(" Invalid index '{0}'.".format(index_name))


def delete_index(index_name):
    """
    Delete an index, the argument 'index_name' is required
    -How to call this function in python code:
    a) es_delete_index(CASE_INDEX)
    b) es_delete_index(AO_INDEX)
    c) es_delete_index(ARCH_MUR_INDEX)
    d) es_delete_index(RM_INDEX)

    -How to run from terminal:
    a) python cli.py es_delete_index case_index
    b) python cli.py es_delete_index ao_index
    c) python cli.py es_delete_index arch_mur_index
    d) python cli.py es_delete_index rm_index

    -How to call task command in cf:
    a) cf run-task api --command "python cli.py es_delete_index case_index" -m 2G --name delete_case_index
    b) cf run-task api --command "python cli.py es_delete_index ao_index" -m 2G --name delete_ao_index
    c) cf run-task api --command "python cli.py es_delete_index arch_mur_index" -m 2G --name delete_arch_mur_index
    d) cf run-task api --command "python cli.py es_delete_index rm_index" -m 2G --name delete_rm_index
    """
    es_client = create_es_client()
    logger.info(" Checking if index '{0}' already exist...".format(index_name))
    if es_client.indices.exists(index=index_name):
        try:
            logger.info(" Deleting index '{0}'...".format(index_name))
            es_client.indices.delete(index_name)
            # sleep 60 seconds (1 min)
            time.sleep(60)
            logger.info(" The index '{0}' is deleted successfully.".format(index_name))
        except Exception:
            pass
    else:
        logger.error(" The index '{0}' is not found.".format(index_name))


def display_index_alias():
    """
    Display all indices and aliases on Elasticsearch.
    -How to run from terminal:
    'python cli.py es_display_index_alias'

    -How to call task command:
    cf run-task api --command "python cli.py es_display_index_alias" -m 2G --name display_index_alias
    """
    es_client = create_es_client()
    indices = es_client.cat.indices(format="JSON")
    logger.info(" All indices = " + json.dumps(indices, indent=3))

    for row in indices:
        logger.info(" The aliases under index '{0}': \n{1}".format(
            row["index"],
            json.dumps(es_client.indices.get_alias(index=row["index"]), indent=3)))


def display_mapping(index_name=None):
    """
    Display the index mapping.
    -How to run from terminal:
    a) python cli.py es_display_mapping case_index
    b) python cli.py es_display_mapping ao_index
    c) python cli.py es_display_mapping arch_mur_index
    d) python cli.py es_display_mapping rm_index

    -How to call task command:
    a) cf run-task api --command "python cli.py es_display_mapping case_index" -m 2G --name display_case_index_mapping
    b) cf run-task api --command "python cli.py es_display_mapping ao_index" -m 2G --name display_ao_index_mapping
    c) cf run-task api --command "python cli.py es_display_mapping arch_mur_index" -m 2G
    --name display_arch_mur_index_mapping
    d) cf run-task api --command "python cli.py es_display_mapping rm_index" -m 2G --name display_rm_index_mapping
    """
    es_client = create_es_client()
    logger.info(" The mapping for index '{0}': \n{1}".format(
        index_name,
        json.dumps(es_client.indices.get_mapping(index=index_name), indent=3)))


def show_index_data():
    """
    Display the index data locally. For debug only
    -How to run from terminal:
    a) modify the following example id
    b) python cli.py es_show_index_data
    """
    es_client = create_es_client()

    try:
        logger.info("\n==================Index rm_index info==================")
        if es_client.indices.exists(index="rm_index"):
            logger.info("\n*** total count in 'rm_index': ***\n{0}".format(
                json.dumps(es_client.count(index="rm_index"), indent=2)))

        # ---display index data:
        try:
            rm_id = "3691"
            logger.info("\n*** rulemaking {0} data: ***\n{1}".format(
                3691,
                json.dumps(es_client.get(index="rm_index", id=3691), indent=2, cls=DateTimeEncoder)))
        except Exception:
            logger.error("current {0} not found.".format(rm_id))

    except Exception as err:
        logger.error("An error occurred while running the get command.{0}".format(err))
