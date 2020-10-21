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

# for debug, uncomment this line
# logger.setLevel(logging.DEBUG)

logger = logging.getLogger(__name__)

# ==== start define mapping for index: docs
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
# ==== end define mapping for index: docs

# ==== start define mapping for index: archived_murs
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

# ==== end define mapping for index: archived_murs

# ANALYZER_SETTINGS = {"analysis": {"analyzer": {"default": {"type": "english"}}}}

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


BACKUP_REPOSITORY_NAME = "legal_s3_repository"

BACKUP_DIRECTORY = "es-backups"

S3_PRIVATE_SERVICE_INSTANCE_NAME = "fec-s3-snapshot"


def create_docs_index():
    """
    Initialize Elasticsearch for storing legal documents.
    Create the `docs` index, and set up the aliases `docs_index` and `docs_search`
    to point to the `docs` index. If the `docs` index already exists, delete it.
    """

    es_client = create_es_client()
    try:
        logger.info("Delete index 'docs'")
        es_client.indices.delete('docs')
    except elasticsearch.exceptions.NotFoundError:
        pass

    try:
        logger.info("Delete index 'docs_index'")
        es_client.indices.delete('docs_index')
    except elasticsearch.exceptions.NotFoundError:
        pass

    logger.info("Create index 'docs'")
    es_client.indices.create(
        'docs',
        {
            "mappings": MAPPINGS,
            "settings": ANALYZER_SETTINGS,
            "aliases": {'docs_index': {}, 'docs_search': {}},
        },
    )


def create_archived_murs_index():
    """
    Initialize Elasticsearch for storing archived MURs.
    If the `archived_murs` index already exists, delete it.
    Create the `archived_murs` index.
    Set up the alias `archived_murs_index` to point to the `archived_murs` index.
    Set up the alias `docs_search` to point `archived_murs` index, allowing the
    legal search to work across current and archived MURs
    """

    es_client = create_es_client()

    try:
        logger.info("Delete index 'archived_murs'")
        es_client.indices.delete('archived_murs')
    except elasticsearch.exceptions.NotFoundError:
        pass

    logger.info(
        "Create index 'archived_murs' with aliases 'docs_search' and 'archived_murs_index'"
    )

    es_client.indices.create(
        'archived_murs',
        {
            "mappings": ARCH_MUR_MAPPINGS,
            "settings": ANALYZER_SETTINGS,
            "aliases": {'archived_murs_index': {}, 'docs_search': {}},
        },
    )
    logger.info(
        "index 'archived_murs' with aliases 'docs_search' and 'archived_murs_index are created.'"
    )


def delete_all_indices():
    """
    Delete index `docs`.
    This is usually done in preparation for restoring indexes from a snapshot backup.
    """

    es_client = create_es_client()
    try:
        logger.info("Delete index 'docs'")
        es_client.indices.delete('docs')
    except elasticsearch.exceptions.NotFoundError:
        pass

    try:
        logger.info("Delete index 'archived_murs'")
        es_client.indices.delete('archived_murs')
    except elasticsearch.exceptions.NotFoundError:
        pass


def create_staging_index():
    """
    Create the index `docs_staging`.
    Move the alias docs_index to point to `docs_staging` instead of `docs`.
    """
    es_client = create_es_client()
    try:
        logger.info("Delete index 'docs_staging'")
        es_client.indices.delete('docs_staging')
    except Exception:
        pass

    logger.info("Create index 'docs_staging'")
    es_client.indices.create(
        'docs_staging', {"mappings": MAPPINGS, "settings": ANALYZER_SETTINGS, }
    )

    logger.info("Move alias 'docs_index' to point to 'docs_staging'")
    es_client.indices.update_aliases(
        body={
            "actions": [
                {"remove": {"index": 'docs', "alias": 'docs_index'}},
                {"add": {"index": 'docs_staging', "alias": 'docs_index'}},
            ]
        }
    )


def restore_from_staging_index():
    """
    A 4-step process:
    1. Move the alias docs_search to point to `docs_staging` instead of `docs`.
    2. Reinitialize the index `docs`.
    3. Reindex `doc_staging` to `docs`
    4. Move `docs_index` and `docs_search` aliases to point to the `docs` index.
       Delete index `docs_staging`.
    """
    es_client = create_es_client()

    logger.info("Move alias 'docs_search' to point to 'docs_staging'")
    es_client.indices.update_aliases(
        body={
            "actions": [
                {"remove": {"index": 'docs', "alias": 'docs_search'}},
                {"add": {"index": 'docs_staging', "alias": 'docs_search'}},
            ]
        }
    )

    logger.info("Delete and re-create index 'docs'")
    es_client.indices.delete('docs')
    es_client.indices.create('docs', {"mappings": MAPPINGS, "settings": ANALYZER_SETTINGS})

    logger.info("Reindex all documents from index 'docs_staging' to index 'docs'")

    body = {"source": {"index": "docs_staging", }, "dest": {"index": "docs"}}
    es_client.reindex(body=body, wait_for_completion=True, request_timeout=1500)

    move_aliases_to_docs_index()


def move_aliases_to_docs_index():
    """
    Move `docs_index` and `docs_search` aliases to point to the `docs` index.
    Delete index `docs_staging`.
    """
    es_client = create_es_client()

    logger.info("Move aliases 'docs_index' and 'docs_search' to point to 'docs'")
    es_client.indices.update_aliases(
        body={
            "actions": [
                {"remove": {"index": 'docs_staging', "alias": 'docs_index'}},
                {"remove": {"index": 'docs_staging', "alias": 'docs_search'}},
                {"add": {"index": 'docs', "alias": 'docs_index'}},
                {"add": {"index": 'docs', "alias": 'docs_search'}},
            ]
        }
    )
    logger.info("Delete index 'docs_staging'")
    es_client.indices.delete('docs_staging')


def move_archived_murs():
    '''
    Move archived MURs from `docs` index to `archived_murs_index`
    This should only need to be run once.
    Once archived MURs are on their own index, we will be able to
    re-index current legal docs after a schema change much more quickly.
    '''
    es_client = create_es_client()

    body = {
        "source": {
            "index": "docs",
            "type": "murs",
            "query": {"match": {"mur_type": "archived"}},
        },
        "dest": {"index": "archived_murs"},
    }

    logger.info("Copy archived MURs from 'docs' index to 'archived_murs' index")
    es_client.reindex(body=body, wait_for_completion=True, request_timeout=1500)


def configure_snapshot_repository(repository=BACKUP_REPOSITORY_NAME):
    '''
    Configure s3 backup repository using api credentials.
    This needs to get re-run when s3 credentials change for each API deployment
    '''
    es_client = create_es_client()
    logger.info("Configuring snapshot repository: {0}".format(repository))

    credentials = get_service_instance_credentials(
        get_service_instance(
            S3_PRIVATE_SERVICE_INSTANCE_NAME))

    try:
        body = {
            "type": "s3",
            "settings": {
                "bucket": credentials["bucket"],
                "region": credentials["region"],
                "access_key": credentials["access_key_id"],
                "secret_key": credentials["secret_access_key"],
                "base_path": BACKUP_DIRECTORY,
                "role_arn": env.get_credential("ES_SNAPSHOT_ROLE_ARN"),
            },
        }
        es_client.snapshot.create_repository(repository=repository, body=body)
        logger.info("Configuring snapshot repository done.: {0}".format(repository))

    except Exception as err:
        logger.error('configure_snapshot_repository.{0}'.format(err))


def create_elasticsearch_backup(repository_name=None, snapshot_name="auto_backup"):
    '''
    Create elasticsearch shapshot in the `legal_s3_repository` or specified repository.
    '''
    es_client = create_es_client()

    repository_name = repository_name or BACKUP_REPOSITORY_NAME
    configure_snapshot_repository(repository_name)

    snapshot_name = "{0}_{1}".format(
        datetime.datetime.today().strftime('%Y%m%d'), snapshot_name
    )
    logger.info("Creating snapshot {0}".format(snapshot_name))
    result = es_client.snapshot.create(repository=repository_name, snapshot=snapshot_name)
    if result.get('accepted'):
        logger.info("Successfully created snapshot: {0}".format(snapshot_name))
    else:
        logger.error("Unable to create snapshot: {0}".format(snapshot_name))


def restore_elasticsearch_backup(repository_name=None, snapshot_name=None):
    '''
    Restore elasticsearch from backup in the event of catastrophic failure at the infrastructure layer or user error.

    -Delete docs index
    -Restore from elasticsearch snapshot
    -Default to most recent snapshot, optionally specify `snapshot_name`
    '''
    es_client = create_es_client()

    repository_name = repository_name or BACKUP_REPOSITORY_NAME
    configure_snapshot_repository(repository_name)

    most_recent_snapshot_name = get_most_recent_snapshot(repository_name)
    snapshot_name = snapshot_name or most_recent_snapshot_name

    if es_client.indices.exists('docs'):
        logger.info(
            'Found docs index. Creating staging index for zero-downtime restore'
        )
        create_staging_index()

    delete_all_indices()

    logger.info("Retrieving snapshot: {0}".format(snapshot_name))
    body = {"indices": "docs,archived_murs"}
    result = es_client.snapshot.restore(
        repository=BACKUP_REPOSITORY_NAME, snapshot=snapshot_name, body=body
    )
    if result.get('accepted'):
        logger.info("Successfully restored snapshot: {0}".format(snapshot_name))
        if es_client.indices.exists('docs_staging'):
            move_aliases_to_docs_index()
    else:
        logger.error("Unable to restore snapshot: {0}".format(snapshot_name))
        logger.info(
            "You may want to try the most recent snapshot: {0}".format(
                most_recent_snapshot_name
            )
        )


def get_most_recent_snapshot(repository_name=None):
    '''
    Get the list of snapshots (sorted by date, ascending) and
    return most recent snapshot name
    '''
    es_client = create_es_client()

    repository_name = repository_name or BACKUP_REPOSITORY_NAME
    logger.info("Retreiving most recent snapshot")
    snapshot_list = es_client.snapshot.get(repository=repository_name, snapshot="*").get(
        'snapshots'
    )
    return snapshot_list.pop().get('snapshot')


def retrieve_snapshots(repository_name=None):
    '''
    Display all the snapshots available on ES cluster (sorted by date, ascending) 
    '''
    es_client = create_es_client()

    repository_name = repository_name or BACKUP_REPOSITORY_NAME
    logger.info("Retreiving all the snapshots available on elastic search cluster")
    snapshot_list = es_client.snapshot.get(repository=repository_name, snapshot="*").get(
        'snapshots'
    )
    logger.info("snapshots  =" + json.dumps(snapshot_list, indent=3, cls=DateTimeEncoder))


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
    delete_from_es('docs_index', 'murs')


def delete_advisory_opinions_from_es():
    """
    Deletes all advisory opinions from Elasticsearch
    """
    delete_from_es('docs_index', 'advisory_opinions')


def delete_from_es(index, doc_type):
    """
    Deletes all documents with the given `doc_type` from Elasticsearch
    """
    es_client = create_es_client()
    es_client.delete_by_query(
        index=index, body={'query': {'match_all': {}}}, doc_type=doc_type
    )

