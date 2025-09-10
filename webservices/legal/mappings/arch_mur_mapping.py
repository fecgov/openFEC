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
        "filename": {"type": "keyword"}
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
        "open_date": {"type": "date", "format": "date_optional_time"},
        "close_date": {"type": "date", "format": "date_optional_time"},
        "url": {"type": "text", "index": False},
        "complainants": {"type": "text"},
        "respondents": {"type": "text"},
        "documents": ARCH_MUR_DOCUMENT_MAPPING,
        "citations": ARCH_MUR_CITATION_MAPPING,
        "subject": ARCH_MUR_SUBJECT_MAPPING,
        "sort1": {"type": "integer"},
        "sort2": {"type": "integer"},
    }
}
