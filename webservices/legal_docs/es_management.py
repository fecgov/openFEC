import logging
import datetime
import json
import time

from webservices.utils import (
    create_es_client,
    get_service_instance,
    get_service_instance_credentials,
    DateTimeEncoder,
)
from webservices.env import env
from webservices.tasks.utils import get_bucket

logger = logging.getLogger(__name__)
# for debug, uncomment this line
# logger.setLevel(logging.DEBUG)

CASE_INDEX = "case_index"
CASE_ALIAS = "case_alias"
CASE_SWAP_INDEX = "case_swap_index"
CASE_REPO = "case_repo"
CASE_SNAPSHOT = "case_snapshot"

AO_INDEX = "ao_index"
AO_ALIAS = "ao_alias"
AO_SWAP_INDEX = "ao_swap_index"
AO_REPO = "ao_repo"
AO_SNAPSHOT = "ao_snapshot"

ARCH_MUR_INDEX = "arch_mur_index"
ARCH_MUR_ALIAS = "arch_mur_alias"
ARCH_MUR_SWAP_INDEX = "arch_mur_swap_index"
ARCH_MUR_REPO = "arch_mur_repo"
ARCH_MUR_SNAPSHOT = "arch_mur_snapshot"

SEARCH_ALIAS = "search_alias"
S3_BACKUP_DIRECTORY = "es-backups"
S3_PRIVATE_SERVICE_INSTANCE_NAME = "fec-s3-snapshot"

DOCS_PATH = "docs"

SORT_MAPPING = {
    "sort1": {"type": "integer"},
    "sort2": {"type": "integer"},
}

# ==== start define XXXX_MAPPING for index: XXXX_INDEX
CASE_DOCUMENT_MAPPING = {
    "type": "nested",
    "properties": {
        "document_id": {"type": "long"},
        "category": {"type": "keyword"},
        "description": {"type": "text"},
        "length": {"type": "long"},
        "text": {
            "type": "text",
            "term_vector": "with_positions_offsets",
        },
        "document_date": {"type": "date", "format": "dateOptionalTime"},
        "url": {"type": "text"},
        "doc_order_id": {"type": "integer"},
    },
}

ADMIN_FINE_MAPPING = {
    "type": {"type": "keyword"},
    "doc_id": {"type": "keyword"},
    "no": {"type": "keyword"},
    "case_serial": {"type": "integer"},
    "name": {"type": "text", "analyzer": "english"},
    "published_flg": {"type": "boolean"},
    "commission_votes": {
        "properties": {
            "vote_date": {"type": "date", "format": "dateOptionalTime"},
            "action": {"type": "text"},
        }
    },
    "documents": CASE_DOCUMENT_MAPPING,
    "url": {"type": "text", "index": False},
    "committee_id": {"type": "text"},
    "report_year": {"type": "keyword"},
    "report_type": {"type": "text", "index": False},
    "reason_to_believe_action_date": {
        "type": "date",
        "format": "dateOptionalTime",
    },
    "reason_to_believe_fine_amount": {"type": "long"},
    "challenge_receipt_date": {
        "type": "date",
        "format": "dateOptionalTime",
    },
    "challenge_outcome": {"type": "text", "index": False},
    "final_determination_date": {
        "type": "date",
        "format": "dateOptionalTime",
    },
    "final_determination_amount": {"type": "long"},
    "payment_amount": {"type": "long", "index": False},
    "treasury_referral_date": {
        "type": "date",
        "format": "dateOptionalTime",
    },
    "treasury_referral_amount": {"type": "long", "index": False},
    "petition_court_filing_date": {
        "type": "date",
        "format": "dateOptionalTime",
    },
    "petition_court_decision_date": {
        "type": "date",
        "format": "dateOptionalTime",
    },
    "civil_penalty_payment_status": {
        "type": "text",
        "index": False,
    },
    "civil_penalty_due_date": {
        "type": "date",
        "format": "dateOptionalTime",
    },
    "af_dispositions": {
        "properties": {
            "disposition_description": {
                "type": "text",
                "index": False,
            },
            "disposition_date": {
                "type": "date",
                "format": "dateOptionalTime",
            },
            "amount": {
                "type": "long",
                "index": False,
            },
        }
    },
}

CITATION_MAPPING = {
    "type": {"type": "keyword"},
    "citation_type": {"type": "keyword"},
    "citation_text": {"type": "text"},
}

MUR_MAPPING = {
    "type": {"type": "keyword"},
    "doc_id": {"type": "keyword"},
    "no": {"type": "keyword"},
    "case_serial": {"type": "integer"},
    "name": {"type": "text", "analyzer": "english"},
    "published_flg": {"type": "boolean"},
    "commission_votes": {
        "properties": {
            "vote_date": {"type": "date", "format": "dateOptionalTime"},
            "action": {"type": "text"},
        }
    },
    "documents": CASE_DOCUMENT_MAPPING,
    "url": {"type": "text", "index": False},
    "mur_type": {"type": "keyword"},
    "subjects": {"type": "text"},
    "election_cycles": {"type": "long"},
    "participants": {
        "properties": {
            "citations": {"type": "object"},
            "name": {"type": "text"},
            "role": {"type": "text"},
        }
    },
    "respondents": {"type": "text"},
    "dispositions": {
        "type": "nested",
        "properties": {
            "citations": {
                "type": "nested",
                "properties": {
                    "text": {"type": "text"},
                    "title": {"type": "text"},
                    "type": {"type": "text"},
                    "url": {"type": "text"},
                }
            },
            "disposition": {"type": "text"},
            "penalty": {"type": "double"},
            "respondent": {"type": "text"},
        }
    },
    "open_date": {"type": "date", "format": "dateOptionalTime"},
    "close_date": {"type": "date", "format": "dateOptionalTime"},
}

ADR_MAPPING = {
    "type": {"type": "keyword"},
    "doc_id": {"type": "keyword"},
    "no": {"type": "keyword"},
    "case_serial": {"type": "integer"},
    "name": {"type": "text", "analyzer": "english"},
    "published_flg": {"type": "boolean"},
    "complainant": {"type": "text"},
    "commission_votes": {
        "properties": {
            "vote_date": {"type": "date", "format": "dateOptionalTime"},
            "action": {"type": "text"},
            "commissioner_name": {"type": "text"},
            "vote_type": {"type": "text"},
        }
    },
    "non_monetary_terms": {"type": "text"},
    "non_monetary_terms_respondents": {"type": "text"},
    "documents": CASE_DOCUMENT_MAPPING,
    "url": {"type": "text", "index": False},
    "mur_type": {"type": "keyword"},
    "subjects": {"type": "text"},
    "election_cycles": {"type": "long"},
    "participants": {
        "properties": {
            "name": {"type": "text"},
            "role": {"type": "text"},
        }
    },
    "respondents": {"type": "text"},
    "case_status": {"type": "text"},
    "adr_dispositions": {
        "type": "nested",
        "properties": {
            "disposition": {"type": "text"},
            "penalty": {"type": "double"},
            "respondent": {"type": "text"},
        }
    },
    "open_date": {"type": "date", "format": "dateOptionalTime"},
    "close_date": {"type": "date", "format": "dateOptionalTime"},
}

REGULATION_MAPPING = {
    "type": {"type": "keyword"},
    "doc_id": {"type": "keyword"},
    "name": {"type": "text", "analyzer": "english"},
    "text": {"type": "text", "analyzer": "english"},
    "no": {"type": "text"},
    "url": {"type": "text", "index": False},
}

STATUTE_MAPPING = {
    "type": {"type": "keyword"},
    "doc_id": {"type": "keyword"},
    "name": {"type": "text", "analyzer": "english"},
    "text": {"type": "text", "analyzer": "english"},
    "no": {"type": "keyword"},
    "title": {"type": "text"},
    "chapter": {"type": "text"},
    "subchapter": {"type": "text"},
    "url": {"type": "text", "index": False},
}

ALL_MAPPING = {}
ALL_MAPPING.update(ADMIN_FINE_MAPPING)
ALL_MAPPING.update(CITATION_MAPPING)
ALL_MAPPING.update(ADR_MAPPING)
ALL_MAPPING.update(MUR_MAPPING)
ALL_MAPPING.update(REGULATION_MAPPING)
ALL_MAPPING.update(STATUTE_MAPPING)
ALL_MAPPING.update(SORT_MAPPING)

CASE_MAPPING = {"properties": ALL_MAPPING}
# ==== end define CASE_MAPPING for index: CASE_INDEX

# ==== start define AO_MAPPING for index: AO_INDEX
AO_MAPPING = {
    "dynamic": "false",
    "properties": {
        "type": {"type": "keyword"},
        "no": {"type": "keyword"},
        "ao_no": {"type": "keyword"},
        "ao_serial": {"type": "integer"},
        "ao_year": {"type": "integer"},
        "doc_id": {"type": "keyword"},
        "name": {"type": "text", "analyzer": "english"},
        "summary": {"type": "text", "analyzer": "english"},
        "request_date": {"type": "date", "format": "dateOptionalTime"},
        "issue_date": {"type": "date", "format": "dateOptionalTime"},
        "is_pending": {"type": "boolean"},
        "status": {"type": "text"},
        "ao_citations": {
            "properties": {
                "name": {"type": "text"},
                "no": {"type": "text"},
            }
        },
        "aos_cited_by": {
            "properties": {
                "name": {"type": "text"},
                "no": {"type": "text"},
            }
        },
        "statutory_citations": {
            "type": "nested",
            "properties": {
                "title": {"type": "long"},
                "section": {"type": "text"},
            },
        },
        "regulatory_citations": {
            "type": "nested",
            "properties": {
                "part": {"type": "long"},
                "title": {"type": "long"},
                "section": {"type": "long"},
            },
        },
        "documents": {
            "type": "nested",
            "properties": {
                "document_id": {"type": "long"},
                "category": {"type": "keyword"},
                "description": {"type": "text"},
                "text": {
                    "type": "text",
                    "term_vector": "with_positions_offsets",
                },
                "date": {"type": "date", "format": "dateOptionalTime"},
                "url": {"type": "text", "index": False},
            },
        },
        "requestor_names": {"type": "text"},
        "requestor_types": {"type": "keyword"},
        "commenter_names": {"type": "text"},
        "representative_names": {"type": "text"},
        "entities": {
            "properties": {
                "role": {"type": "keyword"},
                "name": {"type": "text"},
                "type": {"type": "text"},
            },
        },
        "sort1": {"type": "integer"},
        "sort2": {"type": "integer"},
    }
}
# ==== end define AO_MAPPING for index: AO_INDEX

# ==== start define ARCH_MUR_MAPPING for index: ARCH_MUR_INDEX
ARCH_MUR_DOCUMENT_MAPPING = {
    "type": "nested",
    "properties": {
        "document_id": {"type": "integer"},
        "length": {"type": "long"},
        "text": {
            "type": "text",
            "term_vector": "with_positions_offsets",
        },
        "url": {"type": "text", "index": False},
    },
}

ARCH_MUR_SUBJECT_MAPPING = {
    "properties": {
        "text": {"type": "text"},
        "children": {
            "properties": {
                "text": {"type": "text"},
                "children": {
                    "properties": {
                        "text": {"type": "text"}
                    }
                }
            }
        }
    }
}

ARCH_MUR_CITATION_MAPPING = {
    "properties": {
        "us_code": {
            "properties": {"text": {"type": "text"}, "url": {"type": "text"}}
        },
        "regulations": {
            "properties": {"text": {"type": "text"}, "url": {"type": "text"}}
        }
    }
}

ARCH_MUR_MAPPING = {
    "dynamic": "false",
    "properties": {
        "type": {"type": "keyword"},
        "doc_id": {"type": "keyword"},
        "no": {"type": "keyword"},
        "case_serial": {"type": "integer"},
        "mur_name": {"type": "text"},
        "mur_type": {"type": "keyword"},
        "open_date": {"type": "date", "format": "dateOptionalTime"},
        "close_date": {"type": "date", "format": "dateOptionalTime"},
        "url": {"type": "text", "index": False},
        "complainants": {"type": "text"},
        "respondent": {"type": "text"},
        "documents": ARCH_MUR_DOCUMENT_MAPPING,
        "citations": ARCH_MUR_CITATION_MAPPING,
        "subject": ARCH_MUR_SUBJECT_MAPPING,
        "sort1": {"type": "integer"},
        "sort2": {"type": "integer"},
    }
}
# ==== end define ARCH_MUR_MAPPING for index: ARCH_MUR_INDEX

ANALYZER_SETTING = {
    "analysis": {
        "analyzer": {
            "default": {
                "type": "english"
            }
        }
    },
    "highlight.max_analyzed_offset": 60000000,
}

# SEARCH_ALIAS is used for legal/search endpoint
# XXXX_ALIAS is used for load data to XXXX_INDEX on Elasticsearch
INDEX_DICT = {
    CASE_INDEX: (CASE_MAPPING, CASE_ALIAS, SEARCH_ALIAS, CASE_SWAP_INDEX,
                 CASE_REPO, CASE_SNAPSHOT),
    AO_INDEX: (AO_MAPPING, AO_ALIAS, SEARCH_ALIAS, AO_SWAP_INDEX,
               AO_REPO, AO_SNAPSHOT),
    ARCH_MUR_INDEX: (ARCH_MUR_MAPPING, ARCH_MUR_ALIAS, SEARCH_ALIAS, ARCH_MUR_SWAP_INDEX,
                     ARCH_MUR_REPO, ARCH_MUR_SNAPSHOT),
    CASE_SWAP_INDEX: (CASE_MAPPING, "", "", "", "", ""),
    AO_SWAP_INDEX: (AO_MAPPING, "", "", "", "", ""),
    ARCH_MUR_SWAP_INDEX: (ARCH_MUR_MAPPING, "", "", "", "", ""),
}


def create_index(index_name=None):
    """
    Creating an index for storing legal data on Elasticsearch based on 'INDEX_DICT'.
    - 'INDEX_DICT' description:
    1) CASE_INDEX includes DOCUMENT_TYPE=('statutes','regulations','murs','adrs','admin_fines')
    'murs' means current mur only.
    2) AO_INDEX includes DOCUMENT_TYPE=('advisory_opinions')
    3) ARCH_MUR_INDEX includes DOCUMENT_TYPE=('murs'), archived mur only

    -Two aliases will be created under each index: XXXX_ALIAS and SEARCH_ALIAS
    a) XXXX_ALIAS is used for load data to XXXX_INDEX on Elasticsearch
    b) SEARCH_ALIAS is used for '/legal/search/' endpoint

    -How to call this function in python code:
    a) create_index(CASE_INDEX)
    b) create_index(AO_INDEX)
    c) create_index(ARCH_MUR_INDEX)

    -How to run command from terminal:
    a) python cli.py create_index case_index (or 'python cli.py create_index')
    b) python cli.py create_index ao_index
    c) python cli.py create_index arch_mur_index

    -How to call task command:
    a) cf run-task api --command "python cli.py create_index" -m 2G --name create_case_index
    b) cf run-task api --command "python cli.py create_index ao_index" -m 2G --name create_ao_index
    b) cf run-task api --command "python cli.py create_index arch_mur_index" -m 2G --name create_arch_mur_index

    -This function won't allow to create any other index that is not in 'INDEX_DICT'.
    """
    index_name = index_name or CASE_INDEX
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
        logger.info(" Invalid index '{0}'.".format(index_name))


def display_index_alias():
    """
    Display all indices and aliases on Elasticsearch.
    -How to run from terminal:
    'python cli.py display_index_alias'

    -How to call task command:
    cf run-task api --command "python cli.py display_index_alias" -m 2G --name display_index_alias
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
    a) python cli.py display_mapping case_index (or 'python cli.py display_mapping')
    b) python cli.py display_mapping ao_index
    c) python cli.py display_mapping arch_mur_index

    -How to call task command:
    a) cf run-task api --command "python cli.py display_mapping case_index" -m 2G --name display_case_index_mapping
    b) cf run-task api --command "python cli.py display_mapping ao_index" -m 2G --name display_ao_index_mapping
    c) cf run-task api --command "python cli.py display_mapping arch_mur_index" -m 2G
    --name display_arch_mur_index_mapping
    """
    index_name = index_name or CASE_INDEX
    es_client = create_es_client()
    logger.info(" The mapping for index '{0}': \n{1}".format(
        index_name,
        json.dumps(es_client.indices.get_mapping(index=index_name), indent=3)))


def delete_index(index_name):
    """
    Delete an index, the argument 'index_name' is required
    -How to call this function in python code:
    a) delete_index(CASE_INDEX)
    b) delete_index(AO_INDEX)
    c) delete_index(ARCH_MUR_INDEX)

    -How to run from terminal:
    a) python cli.py delete_index case_index
    b) python cli.py delete_index ao_index
    c) python cli.py delete_index arch_mur_index

    -How to call task command:
    a) cf run-task api --command "python cli.py delete_index case_index" -m 2G --name delete_case_index
    b) cf run-task api --command "python cli.py delete_index ao_index" -m 2G --name delete_ao_index
    c) cf run-task api --command "python cli.py delete_index arch_mur_index" -m 2G --name delete_arch_mur_index
    """
    es_client = create_es_client()
    logger.info(" Checking if index '{0}' already exist...".format(index_name))
    if es_client.indices.exists(index=index_name):
        try:
            logger.info(" Deleting index '{0}'...".format(index_name))
            es_client.indices.delete(index_name)
            # sleep 120 second (2 mins)
            time.sleep(120)
            logger.info(" The index '{0}' is deleted successfully.".format(index_name))
        except Exception:
            pass
    else:
        logger.info(" The index '{0}' is not found.".format(index_name))


def switch_alias(original_index=None, original_alias=None, swapping_index=None):
    """
    1) After create swapping_index(=XXXX_SWAP_INDEX)
    2) Switch the original_alias to point to swapping_index instead of original_index.

    -How to call this function in Python code:
    a) switch_alias(index_name, original_alias, swapping_index)
    """
    original_index = original_index or CASE_INDEX
    original_alias = original_alias or INDEX_DICT.get(original_index)[1]
    swapping_index = swapping_index or INDEX_DICT.get(original_index)[3]

    es_client = create_es_client()
    # 1) Remove original_alias from original_index
    logger.info(" Removing original_alias '{0}' from original_index '{1}'...".format(
        original_alias, original_index)
    )
    try:
        es_client.indices.update_aliases(
            body={
                "actions": [
                    {"remove": {"index": original_index, "alias": original_alias}},
                ]
            }
        )
        logger.info(" Removed original_alias '{0}' from original_index '{1}' successfully.".format(
            original_alias, original_index)
        )
    except Exception:
        pass

    # 2) Switch original_alias to swapping_index
    logger.info(" Switching original_alias '{0}' to swapping_index '{1}'...".format(
        original_alias, swapping_index)
    )
    es_client.indices.update_aliases(
        body={
            "actions": [
                {"add": {"index": swapping_index, "alias": original_alias}},
            ]
        }
    )
    logger.info(" Switched original_alias '{0}' to swapping_index '{1}' successfully.".format(
        original_alias, swapping_index)
    )


def restore_from_swapping_index(index_name=None):
    """
    1. Swith the SEARCH_ALIAS to point to XXXX_SWAP_INDEX instead of index_name(original_index).
    2. Re-create original_index (XXXX_INDEX)
    3. Re-index XXXX_INDEX based on XXXX_SWAP_INDEX
    4. Switch aliases (XXXX_ALIAS,SEARCH_ALIAS) point back to XXXX_INDEX
    5. Delete XXXX_SWAP_INDEX

    -How to call this function in Python code:
    a) restore_from_swapping_index(index_name)
    """
    index_name = index_name or CASE_INDEX
    swapping_index = INDEX_DICT.get(index_name)[3]
    es_client = create_es_client()

    # 1) Swith the SEARCH_ALIAS to point to XXXX_SWAP_INDEX instead of index_name(original_index).
    switch_alias(index_name, SEARCH_ALIAS, swapping_index)

    # 2) Re-create original_index (XXXX_INDEX)
    create_index(index_name)

    # 3) Re-index XXXX_INDEX based on XXXX_SWAP_INDEX
    try:
        logger.info(" Reindexing all documents from index '{0}' to index '{1}'...".format(
            swapping_index, index_name)
        )
        body = {
            "source": {"index": swapping_index},
            "dest": {"index": index_name}
        }
        es_client.reindex(
            body=body,
            wait_for_completion=True,
            request_timeout=1500
        )
    except Exception as e:
        logger.error(" Reindex exception error = {0}".format(e.args))

    # sleep 30 second (0.5 min)
    time.sleep(30)
    logger.info(" Reindexed all documents from index '{0}' to index '{1}' successfully.".format(
        swapping_index, index_name)
    )
    switch_aliases_to_original_index(index_name)


def switch_aliases_to_original_index(index_name=None):
    """
    1. Switch aliases (XXXX_ALIAS,SEARCH_ALIAS) point back to XXXX_INDEX
    2. Delete XXXX_SWAP_INDEX

    -How to call this function in Python code:
    a) switch_aliases_to_original_index(index_name)
    """
    index_name = index_name or CASE_INDEX
    swapping_index = INDEX_DICT.get(index_name)[3]
    es_client = create_es_client()

    logger.info(" Moving aliases '{0}' and '{1}' to point to {2}...".format(
        INDEX_DICT.get(index_name)[1], SEARCH_ALIAS, index_name)
    )
    es_client.indices.update_aliases(
        body={
            "actions": [
                {"remove": {"index": swapping_index, "alias": INDEX_DICT.get(index_name)[1]}},
                {"remove": {"index": swapping_index, "alias": SEARCH_ALIAS}},
                {"add": {"index": index_name, "alias": INDEX_DICT.get(index_name)[1]}},
                {"add": {"index": index_name, "alias": SEARCH_ALIAS}},
            ]
        }
    )
    logger.info(" Moved aliases '{0}' and '{1}' to point to '{2}' successfully.".format(
        INDEX_DICT.get(index_name)[1], SEARCH_ALIAS, index_name)
    )

    # sleep 60 second (1 min)
    time.sleep(60)

    logger.info(" Deleting index '{0}'...".format(swapping_index))
    es_client.indices.delete(swapping_index)
    logger.info(" Deleted swapping index '{0}' successfully.".format(swapping_index))
    logger.info(" Task update_mapping_and_reload_legal_data on '{0}' has been completed successfully !!!".format(
        index_name)
    )
# =========== end index management =============


# =========== start repository management =============
def configure_snapshot_repository(repo_name=None):
    """
    Configure a s3 repository to store the snapshots, default repository_name = CASE_REPO
    This needs to get re-run when s3 credentials change for each api app deployment.

    How to call task command:
    ex1: cf run-task api --command "python cli.py configure_snapshot_repository case_repo" -m 2G
    --name configure_snapshot_repository
    ex2: cf run-task api --command "python cli.py configure_snapshot_repository ao_repo" -m 2G
    --name configure_snapshot_repository_ao
    ex3: cf run-task api --command "python cli.py configure_snapshot_repository arch_mur_repo" -m 2G
    --name configure_snapshot_repository_arch_mur
    """
    repo_name = repo_name or CASE_REPO
    es_client = create_es_client()

    logger.info(" Configuring snapshot repository: {0}".format(repo_name))
    credentials = get_service_instance_credentials(get_service_instance(
        S3_PRIVATE_SERVICE_INSTANCE_NAME))

    try:
        body = {
            "type": "s3",
            "settings": {
                "bucket": credentials["bucket"],
                "region": credentials["region"],
                "access_key": credentials["access_key_id"],
                "secret_key": credentials["secret_access_key"],
                "base_path": S3_BACKUP_DIRECTORY,
                "role_arn": env.get_credential("ES_SNAPSHOT_ROLE_ARN"),
            },
        }
        es_client.snapshot.create_repository(
            repository=repo_name,
            body=body,
        )
        logger.info(" Configured snapshot repository: {0} successfully.".format(repo_name))

    except Exception as err:
        logger.error(" Error occured in configure_snapshot_repository.{0}".format(err))


def delete_repository(repo_name):
    """
    Delete a s3 snapshot repository.

    How to call task command:
     ex1: cf run-task api --command "python cli.py delete_repository repository_name" -m 2G --name delete_repository
    """
    if repo_name:
        try:
            es_client = create_es_client()
            es_client.snapshot.delete_repository(repository=repo_name)
            logger.info(" Deleted snapshot repository: {0} successfully.".format(repo_name))
        except Exception as err:
            logger.error(" Error occured in delete_repository.{0}".format(err))
    else:
        logger.info(" Please input a s3 repository name.")

    display_repositories()


def display_repositories():
    """
    Show all repositories.

    How to call task command:
    cf run-task api --command "python cli.py display_repositories" -m 2G --name display_repositories
    """

    es_client = create_es_client()
    result = es_client.cat.repositories(
        format="JSON",
        v=True,
        s="id",
    )
    logger.info(" Repositories list=" + json.dumps(result, indent=3, cls=DateTimeEncoder))

# =========== end repository management =============


# =========== start snapshot management =============

def create_es_snapshot(index_name):
    """
    Create elasticsearch snapshot of specific XXXX_INDEX in XXXX_REPO.
    snapshot name likes: case_snapshot_202303091720, ao_snapshot_202303091728

    How to call task command:
    ex1: cf run-task api --command "python cli.py create_es_snapshot case_index" -m 2G
    --name create_snapshot_case
    ex2: cf run-task api --command "python cli.py create_es_snapshot ao_index" -m 2G
    --name create_snapshot_ao
    ex3: cf run-task api --command "python cli.py create_es_snapshot arch_mur_index" -m 2G
    --name create_snapshot_arch_mur
    """
    index_name = index_name or CASE_INDEX
    if index_name in INDEX_DICT.keys():
        repo_name = INDEX_DICT.get(index_name)[4]
        prefix_snapshot = INDEX_DICT.get(index_name)[5]
        index_name_list = [index_name]
        es_client = create_es_client()
        body = {
            "indices": index_name_list,
        }
        configure_snapshot_repository(repo_name)
        snapshot_name = "{0}_{1}".format(
            prefix_snapshot, datetime.datetime.today().strftime("%Y%m%d%H%M")
        )
        logger.info(" Creating snapshot {0} ...".format(snapshot_name))
        result = es_client.snapshot.create(
            repository=repo_name,
            snapshot=snapshot_name,
            body=body,
        )
        if result.get("accepted"):
            logger.info(" The snapshot: {0} is created successfully.".format(snapshot_name))
        else:
            logger.error(" Unable to create snapshot: {0}".format(snapshot_name))
    else:
        logger.info(" Invalid index '{0}', no snapshot created.".format(index_name))


def delete_snapshot(repo_name, snapshot_name):
    """
    Delete a snapshot.

    How to call task command:
    ex1: cf run-task api --command "python cli.py delete_snapshot case_repo case_snapshot_202010272134" -m 2G
    --name delete_snapshot_case
    ex2: cf run-task api --command "python cli.py delete_snapshot ao_repo ao_snapshot_202010272132" -m 2G
    --name delete_snapshot_ao
    ex3: cf run-task api --command "python cli.py delete_snapshot arch_mur_repo arch_mur_snapshot_202010272132" -m 2G
    --name delete_snapshot_arch_mur
    """
    if repo_name and snapshot_name:
        configure_snapshot_repository(repo_name)
        try:
            logger.info(" Deleting snapshot {0} from {1} ...".format(snapshot_name, repo_name))
            es_client = create_es_client()
            es_client.snapshot.delete(repository=repo_name, snapshot=snapshot_name)
            logger.info(" The snapshot {0} from {1} is deleted successfully.".format(snapshot_name, repo_name))
        except Exception as err:
            logger.error(" Error occured in delete_snapshot.{0}".format(err))
    else:
        logger.info(" Please provide both snapshot and repository names.")


def restore_es_snapshot(repo_name=None, snapshot_name=None, index_name=None):
    """
    Restore legal data on elasticsearch from a snapshot in the event of catastrophic failure
    at the infrastructure layer or user error.
    This command restores 'index_name' snapshot only.

    -Delete index_name
    -Default to most recent snapshot, optionally specify `snapshot_name`

    How to call task command:
    ex1: cf run-task api --command "python cli.py restore_es_snapshot case_repo case_snapshot_202010272132 case_index"
    -m 2G --name restore_es_snapshot_case
    ex2: cf run-task api --command "python cli.py restore_es_snapshot ao_repo ao_snapshot_202010272132 ao_index"
    -m 2G --name restore_es_snapshot_ao
    ex3: cf run-task api --command "python cli.py restore_es_snapshot arch_mur_repo
    arch_mur_snapshot_202010272132 arch_mur_index" -m 2G --name restore_es_snapshot_arch_mur
    """
    es_client = create_es_client()

    repo_name = repo_name or CASE_REPO
    configure_snapshot_repository(repo_name)

    index_name = index_name or CASE_INDEX
    swapping_index = INDEX_DICT.get(index_name)[3]
    most_recent_snapshot_name = get_most_recent_snapshot(repo_name)
    snapshot_name = snapshot_name or most_recent_snapshot_name

    if es_client.indices.exists(index_name):
        logger.info(
            " Found '{0}' index. Creating swapping index for zero-downtime restore".format(index_name)
        )
        # Create XXXX_SWAP_INDEX
        create_index(swapping_index)

        # Move the alias `XXXX_ALIAS` to point to `XXXX_SWAP_INDEX` instead of `XXXX_INDEX`
        switch_alias(index_name, INDEX_DICT.get(index_name)[1], swapping_index)

    delete_index(index_name)

    logger.info(" Retrieving snapshot: {0}".format(snapshot_name))
    body = {"indices": index_name}
    result = es_client.snapshot.restore(
        repository=repo_name,
        snapshot=snapshot_name,
        body=body,
    )
    time.sleep(20)
    if result.get("accepted"):
        logger.info(" The snapshot: {0} is restored successfully.".format(snapshot_name))
        if es_client.indices.exists(swapping_index):
            # 1. Switch aliases (XXXX_ALIAS,SEARCH_ALIAS) point back to XXXX_INDEX
            # 2. Delete XXXX_SWAP_INDEX
            switch_aliases_to_original_index(index_name)
    else:
        logger.error(" Unable to restore snapshot: {0}".format(snapshot_name))
        logger.info(
            " You may want to try the most recent snapshot: {0}".format(
                most_recent_snapshot_name
            )
        )


def restore_es_snapshot_downtime(repo_name=None, snapshot_name=None, index_name=None):
    """
    Restore elasticsearch from snapshot with downtime

    -Delete index
    -Restore from elasticsearch snapshot
    -Default to most recent snapshot, optionally specify `snapshot_name`

    How to call task command:
    ex1: cf run-task api --command "python cli.py restore_es_snapshot_downtime
    case_repo case_snapshot_202010272130 case_index" -m 2G --name restore_es_snapshot_downtime_case
    ex2: cf run-task api --command "python cli.py restore_es_snapshot_downtime
    ao_repo ao_snapshot_202010272130 ao_index" -m 2G --name restore_es_snapshot_downtime_ao
    ex3: cf run-task api --command "python cli.py restore_es_snapshot_downtime
    arch_mur_repo arch_mur_snapshot_202010272130 arch_mur_index" -m 2G --name restore_es_snapshot_downtime_arch_mur
    """
    es_client = create_es_client()

    repo_name = repo_name or CASE_REPO
    configure_snapshot_repository(repo_name)

    index_name = index_name or CASE_INDEX

    if not snapshot_name:
        most_recent_snapshot_name = get_most_recent_snapshot(repo_name)
        snapshot_name = most_recent_snapshot_name

    delete_index(index_name)

    logger.info(" Restoring snapshot: '{0}'...".format(snapshot_name))
    body = {"indices": index_name}
    result = es_client.snapshot.restore(
        repository=repo_name,
        snapshot=snapshot_name,
        body=body,
    )
    time.sleep(20)
    if result.get("accepted"):
        logger.info(" Restored snapshot: '{0}' successfully.".format(snapshot_name))
    else:
        logger.error(" Unable to restore snapshot: {0}".format(snapshot_name))


def get_most_recent_snapshot(repo_name=None):
    """
    Get the list of snapshots (sorted by date, ascending) and
    return most recent snapshot name
    """
    es_client = create_es_client()

    repo_name = repo_name or CASE_REPO
    logger.info(" Retreiving the most recent snapshot...")
    snapshot_list = es_client.snapshot.get(repository=repo_name, snapshot="*").get(
        "snapshots"
    )
    return snapshot_list.pop().get("snapshot")


def display_snapshots(repo_name=None):
    """
    Currently it shows all the snapshots in all the repo.
    The argument 'repo_name' won't affect,

    How to call task command:
    ex1: cf run-task api --command "python cli.py display_snapshots case_repo" -m 2G
    --name display_snapshots_case
    ex2: cf run-task api --command "python cli.py display_snapshots ao_repo" -m 2G
    --name display_snapshots_ao
    ex3: cf run-task api --command "python cli.py display_snapshots arch_mur_repo" -m 2G
    --name display_snapshots_arch_mur
    """
    es_client = create_es_client()

    repo_name = repo_name or CASE_REPO
    repo_list = [repo_name]
    configure_snapshot_repository(repo_name)
    result = es_client.cat.snapshots(
        repository=repo_list,
        format="JSON",
        v=True,
        s="id",
        h="id,repository,status,start_time,end_time,duration,indices"
    )
    logger.info(" Snapshot list=" + json.dumps(result, indent=3, cls=DateTimeEncoder))


def display_snapshot_detail(repo_name=None, snapshot_name=None):
    """
    Returns all the snapshot detail (include uuid) in the repository.
    Currently it shows all the snapshots in all the repo.
    The argument 'repo_name' won't affect, snapshot_name can use '*' wild card.

    How to call task command:
    ex1: cf run-task api --command "python cli.py display_snapshot_detail case_repo case_snapshot_2023*"
    -m 2G --name display_snapshot_detail_case
    ex2: cf run-task api --command "python cli.py display_snapshot_detail ao_repo ao_snapshot_2023*"
    -m 2G --name display_snapshot_detail_ao
    ex3: cf run-task api --command "python cli.py display_snapshot_detail arch_mur_repo arch_mur*"
    -m 2G --name display_snapshot_detail_arch_mur
    """
    es_client = create_es_client()
    repo_name = repo_name or CASE_REPO
    snapshot_name = snapshot_name or "*"
    configure_snapshot_repository(repo_name)
    result = es_client.snapshot.get(
        repository=repo_name,
        snapshot=snapshot_name
    )
    logger.info(" Snapshot details =" + json.dumps(result, indent=3, cls=DateTimeEncoder))

# =========== end snapshot management =============


# =========== start es document management =============

def delete_doctype_from_es(index_name=None, doc_type=None):
    """
    Deletes all records with the given `doc_type` from Elasticsearch
    Ex: cf run-task api --command "python cli.py delete_doctype_from_es docs adrs" -m 2G
    --name delete_adrs
    """
    body = {"query": {"match": {"type": doc_type}}}

    es_client = create_es_client()
    es_client.delete_by_query(
        index=index_name,
        body=body,
    )
    logger.info(" Successfully deleted doc_type={} from index={} on Elasticsearch.".format(
        doc_type, index_name))


def delete_single_doctype_from_es(index_name=None, doc_type=None, num_doc_id=None):
    """
    Deletes single record with the given `doc_type` and `doc_id` from Elasticsearch
    Ex: cf run-task api --command "python cli.py delete_single_doctype_from_es docs
    admin_fines af_4201" -m 2G --name delete_one_af
        cf run-task api --command "python cli.py delete_single_doctype_from_es docs
        advisory_opinions advisory_opinions_2021-08" -m 2G --name delete_one_ao
    """
    body = {"query": {
        "bool": {
            "must": [
                {"match": {"type": doc_type}},
                {"match": {"doc_id": num_doc_id}}
            ]}}}

    es_client = create_es_client()
    es_client.delete_by_query(
        index=index_name,
        body=body,
    )
    logger.info(" Successfully deleted doc_type={} and doc_id={} from index={} on Elasticsearch.".format(
        doc_type, num_doc_id, index_name))


def delete_murs_from_s3():
    """
    Deletes all MUR documents from S3
    """
    bucket = get_bucket()
    for obj in bucket.objects.filter(Prefix="legal/murs"):
        obj.delete()
