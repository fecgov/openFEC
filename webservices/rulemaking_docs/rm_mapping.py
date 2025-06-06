
# ==== RM_MAPPING for index: RM_INDEX
RM_MAPPING = {
    "dynamic": "false",
    "properties": {
        "admin_close_date": {"type": "date", "format": "dateOptionalTime"},
        "calculated_comment_close_date": {"type": "date", "format": "dateOptionalTime"},
        "comment_close_date": {"type": "date", "format": "dateOptionalTime"},
        "commenter_names": {"type": "text"},
        "counsel_names": {"type": "text"},
        "description": {"type": "text"},
        "documents": {
            "type": "nested",
            "properties": {  # Level 1 documents: level_1=x,level_2=0
                "doc_comment_eligibility": {"type": "boolean"},
                "doc_category_id": {"type": "keyword"},
                "doc_category_label": {"type": "keyword"},
                "doc_date": {"type": "date", "format": "dateOptionalTime"},
                "doc_description": {"type": "text"},
                "doc_entities": {
                    "properties": {
                        "name": {"type": "text"},
                        "role": {"type": "keyword"},
                    },
                },
                "doc_id": {"type": "long"},
                "doc_type_id": {"type": "integer"},
                "doc_type_label": {"type": "keyword"},
                "filename": {"type": "text"},
                "is_key_document": {"type": "boolean"},
                "level_1": {"type": "integer"},
                "level_1_label": {"type": "keyword"},
                "level_2": {"type": "integer"},
                "level_2_label": {"type": "keyword"},
                "level_2_labels": {
                    "properties": {
                        "level_2": {"type": "integer"},
                        "level_2_label": {"type": "keyword"},
                        "level_2_docs": {
                            "properties": {
                                "doc_comment_eligibility": {"type": "boolean"},
                                "doc_category_id": {"type": "integer"},
                                "doc_category_label": {"type": "keyword"},
                                "document_date": {"type": "date", "format": "dateOptionalTime"},
                                "doc_description": {"type": "text"},
                                "document_id": {"type": "long"},
                                "doc_entities": {
                                    "properties": {
                                        "role": {"type": "keyword"},
                                        "name": {"type": "text"},
                                    },
                                },
                                "doc_type_id": {"type": "integer"},
                                "doc_type_label": {"type": "keyword"},
                                "filename": {"type": "text"},
                                "is_key_document": {"type": "boolean"},
                                "level_1": {"type": "integer"},
                                "level_1_label": {"type": "keyword"},
                                "level_2": {"type": "integer"},
                                "level_2_label": {"type": "keyword"},
                                "sort_order": {"type": "integer"},
                                "text": {"type": "text", "term_vector": "with_positions_offsets", },
                                "url": {"type": "text", "index": False},
                             }
                        },  # End: level_2_docs
                    }
                },
                "sort_order": {"type": "integer"},
                "text": {"type": "text", "term_vector": "with_positions_offsets", },
                "url": {"type": "text", "index": False},
            }  # End: level_2_labels
        },  # End: documents
        "fr_publication_dates": {"type": "date", "format": "dateOptionalTime"},
        "hearing_dates": {"type": "date", "format": "dateOptionalTime"},
        "is_open_for_comment": {"type": "boolean"},
        "key_documents": {
            "properties": {
                "doc_date": {"type": "date", "format": "dateOptionalTime"},
                "doc_description": {"type": "text"},
                "doc_id": {"type": "long"},
                "filename": {"type": "text"},
                "level_1": {"type": "integer"},
                "level_1_label": {"type": "keyword"},
                "level_2": {"type": "integer"},
                "url": {"type": "text", "index": False},
            }
        },
        "last_updated": {"type": "date", "format": "dateOptionalTime"},
        "no_tier_documents": {
            "properties": {
                "doc_comment_eligibility": {"type": "boolean"},
                "doc_category_id": {"type": "keyword"},
                "doc_category_label": {"type": "keyword"},
                "doc_date": {"type": "date", "format": "dateOptionalTime"},
                "doc_description": {"type": "text"},
                "doc_id": {"type": "long"},
                "doc_type_id": {"type": "integer"},
                "filename": {"type": "text"},
                "is_key_document": {"type": "boolean"},
                "sort_order": {"type": "integer"},
                "text": {"type": "text", "term_vector": "with_positions_offsets", },
                "url": {"type": "text", "index": False},
            }
        },
        "petitioner_names": {"type": "text"},
        "representative_names": {"type": "text"},
        "rm_entities": {
            "type": "nested",
            "properties": {
                "name": {"type": "text"},
                "role": {"type": "keyword"},
            },
        },
        "rm_id": {"type": "integer"},
        "rm_name": {"type": "keyword"},
        "rm_no": {"type": "keyword"},
        "rm_number": {"type": "keyword"},
        "rm_serial": {"type": "integer"},
        "rm_year": {"type": "integer"},
        "sort1": {"type": "integer"},
        "sort2": {"type": "integer"},
        "sync_status": {"type": "text"},
        "title": {"type": "text"},
        "type": {"type": "keyword"},
        "vote_dates": {"type": "date", "format": "dateOptionalTime"},
        "witness_names": {"type": "text"},
    }
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
