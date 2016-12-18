import elasticsearch
import elasticsearch.helpers

from . import (
    DOCS_INDEX,
    DOCS_SEARCH
)
from webservices import utils

DEFAULT_MAPPINGS = {
    "_default_": {
        "properties": {
            "no": {
                "type": "string",
                "index": "not_analyzed"
            },
            "text": {
                "type": "string",
                "analyzer": "english"
            },
            "name": {
                "type": "string",
                "analyzer": "english"
            },
            "description": {
                "type": "string",
                "analyzer": "english"
            },
            "summary": {
                "type": "string",
                "analyzer": "english"
            }
        }
    }
}

ANALYZER_SETTINGS = {
    "analysis": {"analyzer": {"default": {"type": "english"}}}
}


def initialize_legal_docs():
    """
    Initialize elasticsearch for storing legal documents.
    Create the `docs` index, and set up the aliases `docs_index` and `docs_search`
    to point to the `docs` index. If the `doc` index already exists, delete it.
    """

    es = utils.get_elasticsearch_connection()
    try:
        es.indices.delete('docs')
    except elasticsearch.exceptions.NotFoundError:
        pass
    es.indices.create('docs', {
        "mappings": DEFAULT_MAPPINGS,
        "settings": ANALYZER_SETTINGS,
        "aliases": {
            DOCS_INDEX: {},
            DOCS_SEARCH: {}
        }
    })

def create_staging_index():
    """
    Create the index `docs_staging`.
    Move the alias docs_index to point to `docs_staging` instead of `docs`.
    """
    es = utils.get_elasticsearch_connection()
    es.indices.create('docs_staging', {
        "mappings": DEFAULT_MAPPINGS,
        "settings": ANALYZER_SETTINGS,
    })
    es.indices.update_aliases(body={"actions": [
        {"remove": {"index": 'docs', "alias": DOCS_INDEX}},
        {"add": {"index": 'docs_staging', "alias": DOCS_INDEX}}
    ]})

def restore_from_staging_index():
    """
    A 4-step process:
    1. Move the alias docs_search to point to `docs_staging` instead of `docs`.
    2. Reinitialize the index `docs`.
    3. Reindex `doc_staging` to `docs`
    4. Move `docs_index` and `docs_search` aliases to point to the `docs` index.
       Delete index `docs_staging`.
    """
    es = utils.get_elasticsearch_connection()
    es.indices.update_aliases(body={"actions": [
        {"remove": {"index": 'docs', "alias": DOCS_SEARCH}},
        {"add": {"index": 'docs_staging', "alias": DOCS_SEARCH}}
    ]})

    es.indices.delete('docs')
    es.indices.create('docs', {
        "mappings": DEFAULT_MAPPINGS,
        "settings": ANALYZER_SETTINGS
    })

    elasticsearch.helpers.reindex(es, 'docs_staging', 'docs')

    es.indices.update_aliases(body={"actions": [
        {"remove": {"index": 'docs_staging', "alias": DOCS_INDEX}},
        {"remove": {"index": 'docs_staging', "alias": DOCS_SEARCH}},
        {"add": {"index": 'docs', "alias": DOCS_INDEX}},
        {"add": {"index": 'docs', "alias": DOCS_SEARCH}}
    ]})
    es.indices.delete('docs_staging')
