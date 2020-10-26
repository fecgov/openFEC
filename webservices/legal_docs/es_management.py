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
DOCS_INDEX_ALIAS = "docs_index"
SEARCH_ALIAS = "docs_search"
ARCHIVED_MURS_INDEX = "archived_murs"
ARCHIVED_MURS_INDEX_ALIAS = "archived_murs_index"
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
    },
}

ADMIN_FINES = {
    "type": {"type": "keyword"},
    "doc_id": {"type": "keyword"},
    "no": {"type": "keyword"},
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
    "check_amount": {"type": "long", "index": False},
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
}

ADVISORY_OPINIONS = {
    "type": {"type": "keyword"},
    "no": {"type": "keyword"},
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

MUR_ADR_MAPPINGS = {
    "type": {"type": "keyword"},
    "doc_id": {"type": "keyword"},
    "no": {"type": "keyword"},
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
        "properties": {
            "citations": {
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
ALL_MAPPINGS.update(MUR_ADR_MAPPINGS)
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
def create_docs_index():
    """
    Initialize Elasticsearch for storing legal documents:
    ('statutes','regulations','advisory_opinions','murs','adrs','admin_fines')

    if the DOCS_INDEX already exists, delete it.
    create the DOCS_INDEX
    set up the alias DOCS_INDEX_ALIASE to point to the DOCS_INDEX.
    set up the alias SEARCH_ALIASE to point to the DOCS_INDEX.
    """
    es_client = create_es_client()
    try:
        logger.info("Delete index '{0}'".format(DOCS_INDEX))
        es_client.indices.delete(DOCS_INDEX)
    except elasticsearch.exceptions.NotFoundError:
        pass

    es_client.indices.create(
        DOCS_INDEX,
        {
            "mappings": MAPPINGS,
            "settings": ANALYZER_SETTINGS,
            "aliases": {DOCS_INDEX_ALIAS: {}, SEARCH_ALIAS: {}},
        },
    )
    logger.info(
        "index '{0}' with aliases '{1}' and '{2}' are created.'".format(
            DOCS_INDEX, DOCS_INDEX_ALIAS, SEARCH_ALIAS)
    )


def create_archived_murs_index():
    """
    Initialize Elasticsearch for storing archived MUR documents.
    if the ARCHIVED_MURS_INDEX already exists, delete it.
    create the ARCHIVED_MURS_INDEX.
    set up the alias ARCHIVED_MURS_INDEX_ALIASE to point to the ARCHIVED_MURS_INDEX.
    set up the alias SEARCH_ALIASE to point the ARCHIVED_MURS_INDEX.
    allowing the legal search to work across both current and archived MURs.
    """
    es_client = create_es_client()
    try:
        logger.info("Delete index '{0}'".format(ARCHIVED_MURS_INDEX))
        es_client.indices.delete(ARCHIVED_MURS_INDEX)
    except elasticsearch.exceptions.NotFoundError:
        pass

    es_client.indices.create(
        "archived_murs",
        {
            "mappings": ARCH_MUR_MAPPINGS,
            "settings": ANALYZER_SETTINGS,
            "aliases": {ARCHIVED_MURS_INDEX_ALIAS: {}, SEARCH_ALIAS: {}},
        },
    )
    logger.info(
        "index '{0}' with aliases '{1}' and '{2}' are created.'".format(
            ARCHIVED_MURS_INDEX, ARCHIVED_MURS_INDEX_ALIAS, SEARCH_ALIAS)
    )


def delete_index(index_name=None):
    """
    Delete an index.
    This is usually done in preparation for restoring indexes from a snapshot backup.
    """
    es_client = create_es_client()
    index_name = index_name or DOCS_INDEX
    try:
        logger.info("Delete index '{0}'".format(index_name))
        es_client.indices.delete(index_name)
    except elasticsearch.exceptions.NotFoundError:
        pass
    logger.info("Deleted the index {0} ".format(index_name))


def create_staging_index():
    """
    Create the index `docs_staging`.
    Move the alias docs_index to point to `docs_staging` instead of `docs`.
    """
    es_client = create_es_client()
    try:
        logger.info("Delete index '{0}'".format(DOCS_STAGING_INDEX))
        es_client.indices.delete(DOCS_STAGING_INDEX)
    except Exception:
        pass

    logger.info("Create index '{0}'".format(DOCS_STAGING_INDEX))
    es_client.indices.create(
        DOCS_STAGING_INDEX, {"mappings": MAPPINGS, "settings": ANALYZER_SETTINGS, }
    )

    logger.info("Move alias '{0}' to point to '{1}'".format(
        DOCS_INDEX_ALIAS, DOCS_STAGING_INDEX)
    )
    es_client.indices.update_aliases(
        body={
            "actions": [
                {"remove": {"index": DOCS_INDEX, "alias": DOCS_INDEX_ALIAS}},
                {"add": {"index": DOCS_STAGING_INDEX, "alias": DOCS_INDEX_ALIAS}},
            ]
        }
    )


def restore_from_staging_index():
    """
    A 4-step process:
    1. Move the alias docs_search to point to DOCS_STAGING_INDEX instead of DOCS_INDEX.
    2. Reinitialize the index DOCS_INDEX.
    3. Reindex DOCS_STAGING_INDEX to DOCS_INDEX
    4. Move DOCS_INDEX_ALIASE and SEARCH_ALIASE aliases to point to the DOCS_INDEX.
       Delete index DOCS_STAGING_INDEX.
    """
    es_client = create_es_client()

    logger.info("Move alias '{0}' to point to '{1}'".format(
        SEARCH_ALIAS, DOCS_STAGING_INDEX)
    )
    es_client.indices.update_aliases(
        body={
            "actions": [
                {"remove": {"index": DOCS_INDEX, "alias": SEARCH_ALIAS}},
                {"add": {"index": DOCS_STAGING_INDEX, "alias": SEARCH_ALIAS}},
            ]
        }
    )

    logger.info("Delete and re-create index '{0}'".format(DOCS_INDEX))
    es_client.indices.delete(DOCS_INDEX)
    es_client.indices.create(DOCS_INDEX, {"mappings": MAPPINGS, "settings": ANALYZER_SETTINGS})

    logger.info("Reindex all documents from index '{0}' to index '{1}'".format(
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
    move_aliases_to_docs_index()


def move_aliases_to_docs_index():
    """
    Move DOCS_INDEX_ALIASE and SEARCH_ALIASE aliases to point to the DOCS_INDEX.
    Delete index DOCS_STAGING_INDEX.
    """
    es_client = create_es_client()

    logger.info("Move aliases '{0}' and '{1}' to point to 'docs'".format(
        DOCS_INDEX_ALIAS, SEARCH_ALIAS)
    )
    es_client.indices.update_aliases(
        body={
            "actions": [
                {"remove": {"index": DOCS_STAGING_INDEX, "alias": DOCS_INDEX_ALIAS}},
                {"remove": {"index": DOCS_STAGING_INDEX, "alias": SEARCH_ALIAS}},
                {"add": {"index": DOCS_INDEX, "alias": DOCS_INDEX_ALIAS}},
                {"add": {"index": DOCS_INDEX, "alias": SEARCH_ALIAS}},
            ]
        }
    )
    logger.info("Delete index '{0}'".format(DOCS_STAGING_INDEX))
    es_client.indices.delete(DOCS_STAGING_INDEX)
# =========== end index management =============


# =========== start repository management =============
def configure_snapshot_repository(repository_name=DOCS_REPOSITORY_NAME):
    """
    Configure a s3 repository to store the snapshots, default repository_name = DOCS_REPOSITORY_NAME
    This needs to get re-run when s3 credentials change for each api app deployment.
    """
    es_client = create_es_client()
    logger.info("Configuring snapshot repository: {0}".format(repository_name))
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
        es_client.snapshot.create_repository(repository=repository_name, body=body)
        logger.info("Configured snapshot repository: {0} successfully.".format(repository_name))

    except Exception as err:
        logger.error('Error occured in configure_snapshot_repository.{0}'.format(err))


def delete_repository(repository_name=None):
    """
    Delete a s3 repository.
    """
    if repository_name:
        try:
            es_client = create_es_client()
            es_client.snapshot.delete_repository(repository=repository_name)
            logger.info("Deleted snapshot repository: {0} successfully.".format(repository_name))
        except Exception as err:
            logger.error('Error occured in delete_repository.{0}'.format(err))
    else:
        logger.info("Please input a snapshot repository name.")

    display_repositories()


def display_repositories():
    """
    Returns all the repositories.
    """
    es_client = create_es_client()
    result = es_client.cat.repositories(
        format="JSON",
        v=True,
        s="id",
    )
    logger.info("Repositories list=" + json.dumps(result, indent=3, cls=DateTimeEncoder))

# =========== end repository management =============


# =========== start snapshot management =============

def create_es_snapshot(repository_name=None, snapshot_name="auto_backup", index_name=[]):
    """
    Create elasticsearch shapshot of specific 'index_name' in 'repository_name'.
    ex: cf run-task api --command "python manage.py create_es_snapshot -i docs" -m 2G --name snapshot_docs
    """
    es_client = create_es_client()

    body = {
        "indices": index_name,
    }

    repository_name = repository_name or DOCS_REPOSITORY_NAME
    configure_snapshot_repository(repository_name)

    if not index_name:
        index_name = [DOCS_INDEX]

    snapshot_name = "{0}_{1}_{2}".format(
        datetime.datetime.today().strftime("%Y%m%d%H%M"), snapshot_name, index_name
    )
    logger.info("Creating snapshot {0}".format(snapshot_name))
    result = es_client.snapshot.create(
        repository=repository_name,
        snapshot=snapshot_name,
        body=body,
    )
    if result.get("accepted"):
        logger.info("Successfully created snapshot: {0}".format(snapshot_name))
    else:
        logger.error("Unable to create snapshot: {0}".format(snapshot_name))


def delete_snapshot(repository_name=None, snapshot_name=None):
    """
    Delete a snapshot.
    """
    if repository_name and snapshot_name:
        configure_snapshot_repository(repository_name)
        try:
            es_client = create_es_client()
            es_client.snapshot.delete(repository=repository_name, snapshot=snapshot_name)
            logger.info("Deleted snapshot {0} from {1} successfully.".format(snapshot_name, repository_name))
        except Exception as err:
            logger.error("Error occured in delete_snapshot.{0}".format(err))
    else:
        logger.info("Please input a snapshot name and a repository name.")


def restore_es_snapshot(repository_name=None, snapshot_name=None, index_name=None):
    """
    Restore elasticsearch from snapshot in the event of catastrophic failure at the infrastructure layer or user error.

    -Delete DOCS_INDEX
    -Restore from elasticsearch snapshot
    -Default to most recent snapshot, optionally specify `snapshot_name`
    """
    es_client = create_es_client()

    repository_name = repository_name or DOCS_REPOSITORY_NAME
    configure_snapshot_repository(repository_name)

    index_name = index_name or DOCS_INDEX

    most_recent_snapshot_name = get_most_recent_snapshot(repository_name)
    snapshot_name = snapshot_name or most_recent_snapshot_name

    if es_client.indices.exists(index_name):
        logger.info(
            "Found '{0}' index. Creating staging index for zero-downtime restore".format(index_name)
        )
        create_staging_index()

    delete_index(index_name)

    logger.info("Retrieving snapshot: {0}".format(snapshot_name))
    body = {"indices": index_name}
    result = es_client.snapshot.restore(
        repository=DOCS_REPOSITORY_NAME,
        snapshot=snapshot_name,
        body=body,
    )
    if result.get("accepted"):
        logger.info("Successfully restored snapshot: {0}".format(snapshot_name))
        if es_client.indices.exists(DOCS_STAGING_INDEX):
            move_aliases_to_docs_index()
    else:
        logger.error("Unable to restore snapshot: {0}".format(snapshot_name))
        logger.info(
            "You may want to try the most recent snapshot: {0}".format(
                most_recent_snapshot_name
            )
        )


def get_most_recent_snapshot(repository_name=None):
    """
    Get the list of snapshots (sorted by date, ascending) and
    return most recent snapshot name
    """
    es_client = create_es_client()

    repository_name = repository_name or DOCS_REPOSITORY_NAME
    logger.info("Retreiving most recent snapshot")
    snapshot_list = es_client.snapshot.get(repository=repository_name, snapshot="*").get(
        "snapshots"
    )
    return snapshot_list.pop().get("snapshot")


def display_snapshots(repository_name=None):
    """
    Returns all the snapshots in the repository.
    """
    es_client = create_es_client()
    repository_name = repository_name or DOCS_REPOSITORY_NAME
    configure_snapshot_repository(repository_name)
    result = es_client.cat.snapshots(
        repository=repository_name,
        format="JSON",
        v=True,
        s="id",
    )
    logger.info("Snapshots result=" + json.dumps(result, indent=3, cls=DateTimeEncoder))


def display_snapshot_detail(repository_name=None):
    """
    Returns all the snapshot detail (include uuid) in the repository.
    """
    es_client = create_es_client()
    repository_name = repository_name or DOCS_REPOSITORY_NAME
    configure_snapshot_repository(repository_name)
    result = es_client.snapshot.get(
        repository=repository_name,
        snapshot="*"
    )
    logger.info("Snapshot detail result =" + json.dumps(result, indent=3, cls=DateTimeEncoder))

# =========== end snapshot management =============


# =========== start es document management =============

def delete_murs_from_s3():
    """
    Deletes all MUR documents from S3
    """
    bucket = get_bucket()
    for obj in bucket.objects.filter(Prefix="legal/murs"):
        obj.delete()


def delete_current_murs_from_es():
    """
    Deletes all current MURs from Elasticsearch
    """
    delete_from_es(DOCS_INDEX_ALIAS, "murs")


def delete_advisory_opinions_from_es():
    """
    Deletes all advisory opinions from Elasticsearch
    """
    delete_from_es(DOCS_INDEX_ALIAS, "advisory_opinions")


def delete_from_es(index, doc_type):
    """
    Deletes all documents with the given `doc_type` from Elasticsearch
    """
    es_client = create_es_client()
    es_client.delete_by_query(
        index=index,
        body={
            "query": {"match_all": {}}
        },
        type=doc_type,
    )
# =========== end es document management =============
