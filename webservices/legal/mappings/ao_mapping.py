AO_MAPPING = {
    "dynamic": "false",
    "properties": {
        "type": {"type": "keyword"},
        "no": {"type": "keyword"},
        "ao_no": {"type": "keyword"},
        "ao_serial": {"type": "integer"},
        "ao_year": {"type": "integer"},
        "doc_id": {"type": "keyword"},
        "name": {"type": "text"},
        "summary": {"type": "text"},
        "request_date": {"type": "date", "format": "dateOptionalTime"},
        "issue_date": {"type": "date", "format": "dateOptionalTime"},
        "is_pending": {"type": "boolean"},
        "status": {"type": "text"},
        "published_flg": {"type": "boolean"},
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
                "ao_doc_category_id": {"type": "keyword"},
                "category": {"type": "keyword"},
                "description": {"type": "text"},
                "text": {
                    "type": "text",
                    "term_vector": "with_positions_offsets",
                },
                "date": {"type": "date", "format": "dateOptionalTime"},
                "url": {"type": "text", "index": False},
                "filename": {"type": "keyword"},
            },
        },
        "requestor_names": {"type": "text"},
        "requestor_types": {"type": "keyword"},
        "commenter_names": {"type": "text"},
        "representative_names": {"type": "text"},
        "citation_type": {"type": "keyword"},
        "citation_text": {"type": "keyword"},
        "doc_type": {"type": "keyword"},
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
