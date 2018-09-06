import logging

import elasticsearch

from webservices import utils

logger = logging.getLogger(__name__)

CASE_MAPPINGS = {
    "properties": {
        "no": {
            "type": "string",
            "index": "not_analyzed"
        },
        "doc_id": {
            "type": "string",
            "index": "no"
        },
        "mur_type": {
            "type": "string"
        },
        "name": {
            "type": "string",
            "analyzer": "english"
        },
        "election_cycles": {
            "type": "long"
        },
        "open_date": {
            "type": "date",
            "format": "dateOptionalTime"
        },
        "close_date": {
            "type": "date",
            "format": "dateOptionalTime"
        },
        "url": {
            "type": "string",
            "index": "no"
        },
        "subjects": {
            "type": "string"
        },
        "commission_votes": {
            "properties": {
                "text": {
                    "type": "string"
                },
                "vote_date": {
                    "type": "date",
                    "format": "dateOptionalTime"
                }
            }
        },
        "dispositions": {
            "properties": {
                "citations": {
                    "properties": {
                        "text": {
                            "type": "string"
                        },
                        "title": {
                            "type": "string"
                        },
                        "type": {
                            "type": "string"
                        },
                        "url": {
                            "type": "string"
                        }
                    }
                },
                "disposition": {
                    "type": "string",
                    "index": "not_analyzed"
                },
                "penalty": {
                    "type": "double"
                },
                "respondent": {
                    "type": "string"
                }
            }
        },
        "documents": {
            "type": "nested",
            "properties": {
                "category": {
                    "type": "string",
                    "index": "not_analyzed"
                },
                "description": {
                    "type": "string"
                },
                "document_date": {
                    "type": "date",
                    "format": "dateOptionalTime"
                },
                "document_id": {
                    "type": "long",
                    "index": "no"
                },
                "length": {
                    "type": "long",
                    "index": "no"
                },
                "text": {
                    "type": "string"
                },
                "url": {
                    "type": "string",
                    "index": "no"
                }
            }
        },
        "participants": {
            "properties": {
                "citations": {
                    "type": "object"
                },
                "name": {
                    "type": "string"
                },
                "role": {
                    "type": "string"
                }
            }
        },
        "respondents": {
            "type": "string"
        }
    }
}

MAPPINGS = {
    "_default_": {
        "properties": {
            "sort1": {
                "type": "integer",
                "include_in_all": False
            },
            "sort2": {
                "type": "integer",
                "include_in_all": False
            },
        }
    },
    "citations": {
        "properties": {
            "citation_type": {
                "type": "string",
                "index": "not_analyzed"
            },
            "citation_text": {
                "type": "string",
                "index": "not_analyzed"
            }
        }
    },
    "murs": CASE_MAPPINGS,
    "adrs": CASE_MAPPINGS,
    "admin_fines": CASE_MAPPINGS,
    "statutes": {
        "properties": {
            "doc_id": {
                "type": "string",
                "index": "no"
            },
            "name": {
                "type": "string",
                "analyzer": "english"
            },
            "text": {
                "type": "string",
                "analyzer": "english"
            },
            "no": {
                "type": "string",
                "index": "not_analyzed"
            },
            "title": {
                "type": "string"
            },
            "chapter": {
                "type": "string"
            },
            "subchapter": {
                "type": "string"
            },
            "url": {
                "type": "string",
                "index": "no"
            }
        }
    },
    "regulations": {
        "properties": {
            "doc_id": {
                "type": "string",
                "index": "no"
            },
            "name": {
                "type": "string",
                "analyzer": "english"
            },
            "text": {
                "type": "string",
                "analyzer": "english"
            },
            "no": {
                "type": "string",
                "index": "not_analyzed"
            },
            "url": {
                "type": "string",
                "index": "no"
            }
        }
    },
    "advisory_opinions": {
        "properties": {
            "no": {
                "type": "string",
                "index": "not_analyzed"
            },
            "name": {
                "type": "string",
                "analyzer": "english"
            },
            "summary": {
                "type": "string",
                "analyzer": "english"
            },
            "issue_date": {
                "type": "date",
                "format": "dateOptionalTime"
            },
            "is_pending": {
                "type": "boolean"
            },
            "status": {
                "type": "string"
            },
            "ao_citations": {
                "properties": {
                    "name": {
                        "type": "string"
                    },
                    "no": {
                        "type": "string"
                    }
                }
            },
            "aos_cited_by": {
                "properties": {
                    "name": {
                        "type": "string"
                    },
                    "no": {
                        "type": "string"
                    }
                }
            },
            "statutory_citations": {
                "type": "nested",
                "properties": {
                    "section": {
                        "type": "string"
                    },
                    "title": {
                        "type": "long"
                    }
                }
            },
            "regulatory_citations": {
                "type": "nested",
                "properties": {
                    "part": {
                        "type": "long"
                    },
                    "section": {
                        "type": "long"
                    },
                    "title": {
                        "type": "long"
                    }
                }
            },
            "requestor_names": {
                "type": "string"
            },
            "requestor_types": {
                "type": "string",
                "index": "not_analyzed"
            },
            "documents": {
                "type": "nested",
                "properties": {
                    "document_id": {
                        "type": "long",
                        "index": "no"
                    },
                    "category": {
                        "type": "string",
                        "index": "not_analyzed"
                    },
                    "description": {
                        "type": "string"
                    },
                    "date": {
                        "type": "date",
                        "format": "dateOptionalTime"
                    },
                    "text": {
                        "type": "string"
                    },
                    "url": {
                        "type": "string",
                        "index": "no"
                    }
                }
            }
        }
    }
}

ANALYZER_SETTINGS = {
    "analysis": {"analyzer": {"default": {"type": "english"}}}
}


def create_docs_index():
    """
    Initialize Elasticsearch for storing legal documents.
    Create the `docs` index, and set up the aliases `docs_index` and `docs_search`
    to point to the `docs` index. If the `doc` index already exists, delete it.
    """

    es = utils.get_elasticsearch_connection()
    try:
        logger.info("Delete index 'docs'")
        es.indices.delete('docs')
    except elasticsearch.exceptions.NotFoundError:
        pass

    try:
        logger.info("Delete index 'docs_index'")
        es.indices.delete('docs_index')
    except elasticsearch.exceptions.NotFoundError:
        pass

    logger.info("Create index 'docs'")
    es.indices.create('docs', {
        "mappings": MAPPINGS,
        "settings": ANALYZER_SETTINGS,
        "aliases": {
            'docs_index': {},
            'docs_search': {}
        }
    })


def create_archived_murs_index():
    """
    Initialize Elasticsearch for storing archived MURs.
    If the `archived_murs` index already exists, delete it.
    Create the `archived_murs` index.
    Set up the alias `archived_murs_index` to point to the `archived_murs` index.
    Set up the alias `docs_search` to point `archived_murs` index, allowing the
    legal search to work across current and archived MURs
    """

    es = utils.get_elasticsearch_connection()

    try:
        logger.info("Delete index 'archived_murs'")
        es.indices.delete('archived_murs')
    except elasticsearch.exceptions.NotFoundError:
        pass

    logger.info("Create index 'archived_murs' with aliases 'docs_search' and 'archived_murs_index'")
    es.indices.create('archived_murs', {
        "mappings": MAPPINGS,
        "settings": ANALYZER_SETTINGS,
        "aliases": {
            'archived_murs_index': {},
            'docs_search': {}
        }
    })


def delete_docs_index():
    """
    Delete index `docs`.
    This is usually done in preparation for restoring indexes from a snapshot backup.
    """

    es = utils.get_elasticsearch_connection()
    try:
        logger.info("Delete index 'docs'")
        es.indices.delete('docs')
    except elasticsearch.exceptions.NotFoundError:
        pass


def create_staging_index():
    """
    Create the index `docs_staging`.
    Move the alias docs_index to point to `docs_staging` instead of `docs`.
    """
    es = utils.get_elasticsearch_connection()
    try:
        logger.info("Delete index 'docs_staging'")
        es.indices.delete('docs_staging')
    except:
        pass

    logger.info("Create index 'docs_staging'")
    es.indices.create('docs_staging', {
        "mappings": MAPPINGS,
        "settings": ANALYZER_SETTINGS,
    })

    logger.info("Move alias 'docs_index' to point to 'docs_staging'")
    es.indices.update_aliases(body={"actions": [
        {"remove": {"index": 'docs', "alias": 'docs_index'}},
        {"add": {"index": 'docs_staging', "alias": 'docs_index'}}
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

    logger.info("Move alias 'docs_search' to point to 'docs_staging'")
    es.indices.update_aliases(body={"actions": [
        {"remove": {"index": 'docs', "alias": 'docs_search'}},
        {"add": {"index": 'docs_staging', "alias": 'docs_search'}}
    ]})

    logger.info("Delete and re-create index 'docs'")
    es.indices.delete('docs')
    es.indices.create('docs', {
        "mappings": MAPPINGS,
        "settings": ANALYZER_SETTINGS
    })

    logger.info("Reindex all documents from index 'docs_staging' to index 'docs'")

    body = {
      "source": {
        "index": "docs_staging",
      },
      "dest": {
        "index": "docs"
      }
    }
    es.reindex(body=body, wait_for_completion=True, request_timeout=1500)

    logger.info("Move aliases 'docs_index' and 'docs_search' to point to 'docs'")
    es.indices.update_aliases(body={"actions": [
        {"remove": {"index": 'docs_staging', "alias": 'docs_index'}},
        {"remove": {"index": 'docs_staging', "alias": 'docs_search'}},
        {"add": {"index": 'docs', "alias": 'docs_index'}},
        {"add": {"index": 'docs', "alias": 'docs_search'}}
    ]})
    logger.info("Delete index 'docs_staging'")
    es.indices.delete('docs_staging')


def move_archived_murs():
    '''
    Move archived MURs from `docs` index to `archived_murs_index`
    This should only need to be run once.
    Once archived MURs are on their own index, we will be able to
    re-index current legal docs after a schema change much more quickly.
    '''
    es = utils.get_elasticsearch_connection()

    body = {
          "source": {
            "index": "docs",
            "type": "murs",
            "query": {
              "match": {
                "mur_type": "archived"
              }
            }
          },
          "dest": {
            "index": "archived_murs"
          }
        }

    logger.info("Copy archived MURs from 'docs' index to 'archived_murs' index")
    es.reindex(body=body, wait_for_completion=True, request_timeout=1500)
