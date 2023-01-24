import logging
import elasticsearch
import datetime
import json

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

DOCS_REPOSITORY_NAME = "repository_docs"
ARCHIVED_MURS_REPOSITORY_NAME = "repository_archived_murs"
DOCS_INDEX = "docs"
DOCS_ALIAS = "docs_alias"
SEARCH_ALIAS = "docs_search"
ARCHIVED_MURS_INDEX = "archived_murs"
ARCHIVED_MURS_ALIAS = "archived_murs_alias"
DOCS_STAGING_INDEX = "docs_staging"

S3_BACKUP_DIRECTORY = "es-backups"
S3_PRIVATE_SERVICE_INSTANCE_NAME = "fec-s3-snapshot"


# ==== start define mapping for index: DOCS_INDEX
SORT_MAPPINGS = {
    "sort1": {"type": "integer"},
    "sort2": {"type": "integer"},
}

CASE_DOCUMENT_MAPPINGS = {
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

ADMIN_FINES = {
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
    "documents": CASE_DOCUMENT_MAPPINGS,
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

ADVISORY_OPINIONS = {
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
}

CITATIONS = {
    "type": {"type": "keyword"},
    "citation_type": {"type": "keyword"},
    "citation_text": {"type": "text"},
}

MUR_MAPPINGS = {
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
    "documents": CASE_DOCUMENT_MAPPINGS,
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

ADR_MAPPINGS = {
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
    "documents": CASE_DOCUMENT_MAPPINGS,
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

REGULATIONS = {
    "type": {"type": "keyword"},
    "doc_id": {"type": "keyword"},
    "name": {"type": "text", "analyzer": "english"},
    "text": {"type": "text", "analyzer": "english"},
    "no": {"type": "text"},
    "url": {"type": "text", "index": False},
}

STATUTES = {
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

ALL_MAPPINGS = {}
ALL_MAPPINGS.update(ADMIN_FINES)
ALL_MAPPINGS.update(ADVISORY_OPINIONS)
ALL_MAPPINGS.update(CITATIONS)
ALL_MAPPINGS.update(ADR_MAPPINGS)
ALL_MAPPINGS.update(MUR_MAPPINGS)
ALL_MAPPINGS.update(REGULATIONS)
ALL_MAPPINGS.update(STATUTES)
ALL_MAPPINGS.update(SORT_MAPPINGS)

MAPPINGS = {"properties": ALL_MAPPINGS}
# ==== end define mapping for index: DOCS_INDEX

# ==== start define mapping for index: ARCHIVED_MURS_INDEX
ARCH_MUR_DOCUMENT_MAPPINGS = {
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

ARCH_MUR_SUBJECT_MAPPINGS = {
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

ARCH_MUR_CITATION_MAPPINGS = {
    "properties": {
        "us_code": {
            "properties": {"text": {"type": "text"}, "url": {"type": "text"}}
        },
        "regulations": {
            "properties": {"text": {"type": "text"}, "url": {"type": "text"}}
        }
    }
}

ARCH_MUR_MAPPINGS = {
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
        "documents": ARCH_MUR_DOCUMENT_MAPPINGS,
        "citations": ARCH_MUR_CITATION_MAPPINGS,
        "subject": ARCH_MUR_SUBJECT_MAPPINGS,
        "sort1": {"type": "integer"},
        "sort2": {"type": "integer"}
    }
}

# ==== end define mapping for index: ARCHIVED_MURS_INDEX

ANALYZER_SETTINGS = {
    "analysis": {
        "analyzer": {
            "default": {
                "type": "english"
            }
        }
    },
    "highlight.max_analyzed_offset": 60000000,
}


# =========== start index management =============
def create_index(index_name=None, aliases_name=None):
    """
    Initialize Elasticsearch for storing legal documents:

    1)DOCS_INDEX: ('statutes','regulations','advisory_opinions','murs','adrs','admin_fines')
    if the DOCS_INDEX already exists, delete it.
    -create the DOCS_INDEX
    -set up the alias DOCS_ALIAS to point to the DOCS_INDEX.
    -set up the alias SEARCH_ALIAS to point to the DOCS_INDEX.

    How to call this command:
    create_index(DOCS_INDEX, (DOCS_ALIAS + "," + SEARCH_ALIAS))

    2)ARCHIVED_MURS_INDEX: ('archived_murs')
    if the ARCHIVED_MURS_INDEX already exists, delete it.
    -create the ARCHIVED_MURS_INDEX.
    -set up the alias ARCHIVED_MURS_ALIAS to point to the ARCHIVED_MURS_INDEX.
    -set up the alias SEARCH_ALIAS to point the ARCHIVED_MURS_INDEX.
    allowing the legal search to work across both current and archived MURs.

    How to call this command in python:
    a)create_index()
    b)create_index(ARCHIVED_MURS_INDEX, (ARCHIVED_MURS_ALIAS + "," + SEARCH_ALIAS))

    How to run locally:
    a) python cli.py create_index
    b) python  cli.py create_index archived_murs archived_murs_index,docs_search

    How to call task command:
    a) cf run-task api --command "python cli.py create_index" -m 2G --name create_index
    b) cf run-task api --command "python cli.py create_index archived_murs archived_murs_index,docs_search" -m 2G --name create_index
    """
    index_name = index_name or DOCS_INDEX
    aliases_list = []
    body = {}
    aliases = {}
    body.update({"mappings": MAPPINGS})
    body.update({"settings": ANALYZER_SETTINGS})

    if index_name == DOCS_INDEX:
        # by default, use DOCS_INDEX and SEARCH_ALIAS, DOCS_ALIAS
        aliases_list = [SEARCH_ALIAS, DOCS_ALIAS]
        for alias in aliases_list:
            aliases.update({alias: {}})

        logger.debug(" aliases under index '" + DOCS_INDEX + "' = " + json.dumps(
            aliases, indent=3, cls=DateTimeEncoder))
        body.update({"aliases": aliases})

    elif index_name == ARCHIVED_MURS_INDEX:
        # by default, use ARCHIVED_MURS_INDEX and SEARCH_ALIAS, ARCHIVED_MURS_ALIAS
        aliases_list = [SEARCH_ALIAS, ARCHIVED_MURS_ALIAS]
        for alias in aliases_list:
            aliases.update({alias: {}})

        logger.debug(" aliases under index '" + ARCHIVED_MURS_INDEX + "' = " + json.dumps(
            aliases, indent=3, cls=DateTimeEncoder))
        body.update({"aliases": aliases})

    else:
        if aliases_name:
            aliases_list = aliases_name.split(",")
            aliases = {}
            for alias in aliases_list:
                aliases.update({alias: {}})

            logger.debug(" aliases =" + json.dumps(aliases, indent=3, cls=DateTimeEncoder))
            body.update({"aliases": aliases})

    es_client = create_es_client()
    delete_index(index_name)

    logger.info(" Creating index '{0}'...".format(index_name))
    es_client.indices.create(
        index=index_name,
        body=body,
    )

    if aliases_list:
        logger.info(
            " The index '{0}' with aliases=[{1}] is created successfully.".format(
                index_name, "".join(alias + "," for alias in aliases_list)
            )
        )

    else:
        logger.info(" The index '{0}' is created successfully.".format(index_name))


def display_index_alias():
    """
    Returns all indices and aliases.

    How to run locally:
        python cli.py display_index_alias

    How to call task command:
        cf run-task api --command "python cli.py display_index_alias" -m 2G --name display_index_alias
    """
    es_client = create_es_client()
    indices = es_client.cat.indices(format="JSON")
    logger.info(" All indices = " + json.dumps(indices, indent=3))

    for row in indices:
        logger.info(" The aliases under index '{0}': \n{1}".format(
            row["index"],
            json.dumps(es_client.indices.get_alias(index=row["index"]), indent=3)))


def display_mappings():
    """
    Returns all index mappings.

    How to run locally:
        python cli.py display_mappings

    How to call task command:
        cf run-task api --command "python cli.py display_mappings" -m 2G --name display_mappings
    """
    es_client = create_es_client()
    indices = es_client.cat.indices(format="JSON")

    for row in indices:
        logger.info(" The mapping for index '{0}': \n{1}".format(
            row["index"],
            json.dumps(es_client.indices.get_mapping(index=row["index"]), indent=3)))


def delete_index(index_name=None):
    """
    Delete an index.
    This is usually done in preparation for restoring indexes from a snapshot backup.

    How to call this command in python:
    a)delete_index()
    b)delete_index(ARCHIVED_MURS_INDEX)

    How to run locally:
    a) python cli.py delete_index docs
    b) python cli.py delete_index archived_murs

    How to call task command:
    a) cf run-task api --command "python cli.py delete_index docs" -m 2G --name delete_index
    b) cf run-task api --command "python cli.py delete_index archived_murs" -m 2G --name delete_index
    """
    # TODO: check if DOCS_INDEX exist before deleting.
    es_client = create_es_client()
    index_name = index_name or DOCS_INDEX
    try:
        logger.info(" Deleting index '{0}'...".format(index_name))
        es_client.indices.delete(index_name)
        logger.info(" The index '{0}' is deleted successfully.".format(index_name))
    except elasticsearch.exceptions.NotFoundError:
        pass

    # TODO: check if DOCS_INDEX exist before deleting. use exists_alias()
    if index_name == DOCS_INDEX:
        try:
            logger.info(" Deleting alias '{0}' under index '{1}' ...".format(DOCS_ALIAS, DOCS_INDEX))
            es_client.indices.delete(DOCS_ALIAS)
            logger.info(" The alias '{0}' is deleted successfully.".format(DOCS_ALIAS))
        except Exception:
            pass

    if index_name == ARCHIVED_MURS_INDEX:
        try:
            logger.info(" Deleting alias '{0}' under index '{1}'...".format(
                ARCHIVED_MURS_ALIAS, ARCHIVED_MURS_INDEX))
            es_client.indices.delete(ARCHIVED_MURS_ALIAS)
            logger.info(" The alias '{0}' is deleted successfully.".format(ARCHIVED_MURS_ALIAS))
        except Exception:
            pass


def move_alias(original_index=None, original_alias=None, staging_index=None):
    """
    1) After creating docs_staging index using this command:create_index(DOCS_STAGING_INDEX)
    2) Move the alias docs_index to point to `docs_staging` instead of `docs`.

    How to call this command:
        move_alias(DOCS_INDEX, DOCS_ALIAS, DOCS_STAGING_INDEX)
    """
    original_index = original_index or DOCS_INDEX
    original_alias = original_alias or DOCS_ALIAS
    staging_index = staging_index or DOCS_STAGING_INDEX

    es_client = create_es_client()

    # Remove original_alias from original_index
    logger.info(" Removing alias '{0}' from '{1}'...".format(
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
        logger.info(" Removed alias '{0}' from '{1}' successfully.".format(
            original_alias, original_index)
        )
    except Exception:
        pass

    # Add original_alias to staging_index
    logger.info(" Adding alias '{0}' to point to '{1}'...".format(
        original_alias, staging_index)
    )
    es_client.indices.update_aliases(
        body={
            "actions": [
                {"add": {"index": staging_index, "alias": original_alias}},
            ]
        }
    )
    logger.info(" Added alias '{0}' to point to '{1}' successfully.".format(
        original_alias, staging_index)
    )


def restore_from_staging_index():
    """
    A 4-step process:
    1. Move the alias docs_search to point to DOCS_STAGING_INDEX instead of DOCS_INDEX.
    2. Reinitialize the index DOCS_INDEX.
    3. Reindex DOCS_STAGING_INDEX to DOCS_INDEX
    4. Move DOCS_ALIAS and SEARCH_ALIAS aliases to point to the DOCS_INDEX.
       Delete index DOCS_STAGING_INDEX.
    """
    es_client = create_es_client()

    # Remove SEARCH_ALIAS from DOCS_INDEX
    logger.info(" Removing alias '{0}' from '{1}'...".format(
        SEARCH_ALIAS, DOCS_INDEX)
    )
    try:
        es_client.indices.update_aliases(
            body={
                "actions": [
                    {"remove": {"index": DOCS_INDEX, "alias": SEARCH_ALIAS}},
                ]
            }
        )
        logger.info(" Removed alias '{0}' from '{1}' successfully.".format(
            SEARCH_ALIAS, DOCS_INDEX)
        )
    except Exception:
        pass

    # Add SEARCH_ALIAS points to DOCS_STAGING_INDEX
    logger.info(" Adding alias '{0}' to point to '{1}'...".format(
        SEARCH_ALIAS, DOCS_STAGING_INDEX)
    )
    es_client.indices.update_aliases(
        body={
            "actions": [
                {"add": {"index": DOCS_STAGING_INDEX, "alias": SEARCH_ALIAS}},
            ]
        }
    )
    logger.info(" Added alias '{0}' to point to '{1}' successfully.".format(
        SEARCH_ALIAS, DOCS_STAGING_INDEX)
    )

    delete_index(DOCS_INDEX)

    # Create index 'DOCS_INDEX' with SEARCH_ALIAS, DOCS_ALIAS
    create_index()

    logger.info(" Reindexing all documents from index '{0}' to index '{1}'...".format(
        DOCS_STAGING_INDEX, DOCS_INDEX)
    )
    body = {
        "source": {"index": DOCS_STAGING_INDEX},
        "dest": {"index": DOCS_INDEX}
    }
    es_client.reindex(
        body=body,
        wait_for_completion=True,
        request_timeout=1500
    )
    logger.info(" Reindexed all documents from index '{0}' to index '{1}' successfully.".format(
        DOCS_STAGING_INDEX, DOCS_INDEX)
    )
    move_aliases_to_docs_index()


def move_aliases_to_docs_index():
    """
    Move DOCS_ALIAS and SEARCH_ALIAS aliases to point to the DOCS_INDEX.
    Delete index DOCS_STAGING_INDEX.
    """
    es_client = create_es_client()

    logger.info(" Moving aliases '{0}' and '{1}' to point to 'docs'...".format(
        DOCS_ALIAS, SEARCH_ALIAS)
    )
    es_client.indices.update_aliases(
        body={
            "actions": [
                {"remove": {"index": DOCS_STAGING_INDEX, "alias": DOCS_ALIAS}},
                {"remove": {"index": DOCS_STAGING_INDEX, "alias": SEARCH_ALIAS}},
                {"add": {"index": DOCS_INDEX, "alias": DOCS_ALIAS}},
                {"add": {"index": DOCS_INDEX, "alias": SEARCH_ALIAS}},
            ]
        }
    )
    logger.info(" Moved aliases '{0}' and '{1}' to point to 'docs' successfully.".format(
        DOCS_ALIAS, SEARCH_ALIAS)
    )

    logger.info(" Deleting index '{0}'...".format(DOCS_STAGING_INDEX))
    es_client.indices.delete(DOCS_STAGING_INDEX)
    logger.info(" Deleted index '{0}' successfully.".format(DOCS_STAGING_INDEX))
    logger.info(" Task refresh_current_legal_docs_zero_downtime has been completed successfully !!!")

# =========== end index management =============


# =========== start repository management =============
def configure_snapshot_repository(repository_name=DOCS_REPOSITORY_NAME):
    """
    Configure a s3 repository to store the snapshots, default repository_name = DOCS_REPOSITORY_NAME
    This needs to get re-run when s3 credentials change for each api app deployment.

    How to call task command:
    cf run-task api --command "python cli.py configure_snapshot_repository repository_docs" -m 2G --name configure_snapshot_repository_docs
    cf run-task api --command "python cli.py configure_snapshot_repository repository_archived_murs" -m 2G --name configure_snapshot_repository_arch_mur
    """
    es_client = create_es_client()
    logger.info(" Configuring snapshot repository: {0}".format(repository_name))
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
            repository=repository_name,
            body=body,
        )
        logger.info(" Configured snapshot repository: {0} successfully.".format(repository_name))

    except Exception as err:
        logger.error(" Error occured in configure_snapshot_repository.{0}".format(err))


def delete_repository(repository_name=None):
    """
    Delete a s3 repository.

    How to call task command:
    cf run-task api --command "python cli.py delete_repository repository_test" -m 2G --name delete_repository
    """
    if repository_name:
        try:
            es_client = create_es_client()
            es_client.snapshot.delete_repository(repository=repository_name)
            logger.info(" Deleted snapshot repository: {0} successfully.".format(repository_name))
        except Exception as err:
            logger.error(" Error occured in delete_repository.{0}".format(err))
    else:
        logger.info(" Please input a snapshot repository name.")

    display_repositories()


def display_repositories():
    """
    Returns all the repositories.

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

def create_es_snapshot(repository_name=None, snapshot_name="auto_backup", index_name=None):
    """
    Create elasticsearch shapshot of specific 'index_name'(=index1,index2...) in 'repository_name'.

    How to call task command:
    ex1: cf run-task api --command "python cli.py create_es_snapshot repository_docs docs" -m 2G --name snapshot_docs
    ex1: cf run-task api --command "python cli.py create_es_snapshot repository_archived_murs archived_murs" -m 2G --name snapshot_archived_murs
    ex3: cf run-task api --command "python cli.py create_es_snapshot docs archived_murs" -m 2G --name create_snapshot_2index
    """
    es_client = create_es_client()
    index_name_list = []
    if index_name:
        index_name_list = index_name.split(',')
    else:
        index_name_list = [DOCS_INDEX]

    body = {
        "indices": index_name_list,
    }

    repository_name = repository_name or DOCS_REPOSITORY_NAME
    configure_snapshot_repository(repository_name)

    snapshot_name = "{0}_{1}_{2}".format(
        index_name_list[0], datetime.datetime.today().strftime("%Y%m%d%H%M"), snapshot_name
    )
    logger.info(" Creating snapshot {0} ...".format(snapshot_name))
    result = es_client.snapshot.create(
        repository=repository_name,
        snapshot=snapshot_name,
        body=body,
    )
    if result.get("accepted"):
        logger.info(" The snapshot: {0} is created successfully.".format(snapshot_name))
    else:
        logger.error(" Unable to create snapshot: {0}".format(snapshot_name))


def delete_snapshot(repository_name=None, snapshot_name=None):
    """
    Delete a snapshot.

    How to call task command:
    ex1: cf run-task api --command "python cli.py delete_snapshot repository_docs docs_202010272134_auto_backup" -m 2G --name delete_snapshot
    ex2: cf run-task api --command "python cli.py delete_snapshot docs_202010272132_auto_backup" -m 2G --name delete_snapshot
    """
    if repository_name and snapshot_name:
        configure_snapshot_repository(repository_name)
        try:
            logger.info(" Deleting snapshot {0} from {1} ...".format(snapshot_name, repository_name))
            es_client = create_es_client()
            es_client.snapshot.delete(repository=repository_name, snapshot=snapshot_name)
            logger.info(" The snapshot {0} from {1} is deleted successfully.".format(snapshot_name, repository_name))
        except Exception as err:
            logger.error(" Error occured in delete_snapshot.{0}".format(err))
    else:
        logger.info(" Please provide both snapshot and repository names.")


def restore_es_snapshot(repository_name=None, snapshot_name=None, index_name=None):
    """
    Restore elasticsearch from snapshot in the event of catastrophic failure at the infrastructure layer or user error.
    This command restores 'docs' index snapshot only.

    -Delete DOCS_INDEX
    -Default to most recent snapshot, optionally specify `snapshot_name`

    How to call task command:
    ex: cf run-task api --command "python cli.py restore_es_snapshot repository_docs docs_202010272132_auto_backup docs" -m 2G --name restore_es_snapshot
    """
    es_client = create_es_client()

    repository_name = repository_name or DOCS_REPOSITORY_NAME
    configure_snapshot_repository(repository_name)

    index_name = index_name or DOCS_INDEX

    most_recent_snapshot_name = get_most_recent_snapshot(repository_name)
    snapshot_name = snapshot_name or most_recent_snapshot_name

    if es_client.indices.exists(index_name):
        logger.info(
            " Found '{0}' index. Creating staging index for zero-downtime restore".format(index_name)
        )
        # Create docs_staging index
        create_index(DOCS_STAGING_INDEX)

        # Move the alias docs_index to point to `docs_staging` instead of `docs`
        move_alias(DOCS_INDEX, DOCS_ALIAS, DOCS_STAGING_INDEX)

    delete_index(index_name)

    logger.info(" Retrieving snapshot: {0}".format(snapshot_name))
    body = {"indices": index_name}
    result = es_client.snapshot.restore(
        repository=repository_name,
        snapshot=snapshot_name,
        body=body,
    )
    if result.get("accepted"):
        logger.info(" The snapshot: {0} is restored successfully.".format(snapshot_name))
        if es_client.indices.exists(DOCS_STAGING_INDEX):
            move_aliases_to_docs_index()
    else:
        logger.error(" Unable to restore snapshot: {0}".format(snapshot_name))
        logger.info(
            " You may want to try the most recent snapshot: {0}".format(
                most_recent_snapshot_name
            )
        )


def restore_es_snapshot_downtime(repository_name=None, snapshot_name=None, index_name=None):
    """
    Restore elasticsearch from snapshot with downtime

    -Delete index
    -Restore from elasticsearch snapshot
    -Default to most recent snapshot, optionally specify `snapshot_name`

    How to call task command:
    ex: cf run-task api --command "python cli.py restore_es_snapshot_downtime repository_docs docs_202010272130_auto_backup docs" -m 2G --name restore_es_snapshot_downtime
    ex: cf run-task api --command "python cli.py restore_es_snapshot_downtime repository_archived_murs archived_murs_202010272130_auto_backup archived_murs" -m 2G --name restore_es_snapshot_downtime
    """
    es_client = create_es_client()

    repository_name = repository_name or DOCS_REPOSITORY_NAME
    configure_snapshot_repository(repository_name)

    index_name = index_name or DOCS_INDEX

    if not snapshot_name:
        most_recent_snapshot_name = get_most_recent_snapshot(repository_name)
        snapshot_name = most_recent_snapshot_name

    delete_index(index_name)

    logger.info(" Restoring snapshot: '{0}'...".format(snapshot_name))
    body = {"indices": index_name}
    result = es_client.snapshot.restore(
        repository=repository_name,
        snapshot=snapshot_name,
        body=body,
    )
    if result.get("accepted"):
        logger.info(" Restored snapshot: '{0}' successfully.".format(snapshot_name))
    else:
        logger.error(" Unable to restore snapshot: {0}".format(snapshot_name))


def get_most_recent_snapshot(repository_name=None):
    """
    Get the list of snapshots (sorted by date, ascending) and
    return most recent snapshot name
    """
    es_client = create_es_client()

    repository_name = repository_name or DOCS_REPOSITORY_NAME
    logger.info(" Retreiving most recent snapshot...")
    snapshot_list = es_client.snapshot.get(repository=repository_name, snapshot="*").get(
        "snapshots"
    )
    return snapshot_list.pop().get("snapshot")


def display_snapshots(repository_name=None):
    """
    Returns all the snapshots in the repository.

    How to call task command:
    ex1: cf run-task api --command "python cli.py display_snapshots repository_docs" -m 2G --name display_snapshots
    ex2: cf run-task api --command "python cli.py display_snapshots repository_archived_murs" -m 2G --name display_snapshots
    """
    es_client = create_es_client()
    repository_name = repository_name or DOCS_REPOSITORY_NAME
    configure_snapshot_repository(repository_name)
    result = es_client.cat.snapshots(
        repository=repository_name,
        format="JSON",
        v=True,
        s="id",
        h="id,repository,status,start_time,end_time,duration,indices"
    )
    logger.info(" Snapshot list=" + json.dumps(result, indent=3, cls=DateTimeEncoder))


def display_snapshot_detail(repository_name=None, snapshot_name=None):
    """
    Returns all the snapshot detail (include uuid) in the repository.

    How to call task command:
    ex1: cf run-task api --command "python cli.py display_snapshot_detail repository_name docs_202010*" -m 2G --name display_snapshot
    ex2: cf run-task api --command "python cli.py display_snapshot_detail repository_archived_murs archived_murs*" -m 2G --name display_snapshot_detail
    """
    es_client = create_es_client()
    repository_name = repository_name or DOCS_REPOSITORY_NAME
    snapshot_name = snapshot_name or "*"
    configure_snapshot_repository(repository_name)
    result = es_client.snapshot.get(
        repository=repository_name,
        snapshot=snapshot_name
    )
    logger.info(" Snapshot details =" + json.dumps(result, indent=3, cls=DateTimeEncoder))

# =========== end snapshot management =============


# =========== start es document management =============

def delete_doctype_from_es(index_name=None, doc_type=None):
    """
    Deletes all records with the given `doc_type` from Elasticsearch
    Ex: cf run-task api --command "python cli.py delete_doctype_from_es docs adrs" -m 2G --name delete_adrs
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
    Ex: cf run-task api --command "python cli.py delete_single_doctype_from_es docs admin_fines af_4201" -m 2G --name delete_one_af
        cf run-task api --command "python cli.py delete_single_doctype_from_es docs advisory_opinions advisory_opinions_2021-08" -m 2G --name delete_one_ao
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
