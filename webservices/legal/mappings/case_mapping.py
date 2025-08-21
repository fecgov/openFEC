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
        "filename": {"type": "keyword"},
        "doc_order_id": {"type": "integer"},
    },
}

ADMIN_FINE_MAPPING = {
    "type": {"type": "keyword"},
    "doc_id": {"type": "keyword"},
    "no": {"type": "keyword"},
    "case_serial": {"type": "integer"},
    "name": {"type": "text"},
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
    "dispositions": {
        "properties": {
            "disposition_description": {
                "type": "text",
                "index": False,
            },
            "disposition_date": {
                "type": "date",
                "format": "dateOptionalTime",
            },
            "penalty": {
                "type": "scaled_float",
                "scaling_factor": 100,
                "index": False,
                "null_value": -1
            },
        }
    },
}

CITATION_MAPPING = {
    "type": {"type": "keyword"},
    "citation_type": {"type": "keyword"},
    "citation_text": {"type": "keyword"},
    "doc_type": {"type": "keyword"},
}

MUR_MAPPING = {
    "type": {"type": "keyword"},
    "doc_id": {"type": "keyword"},
    "no": {"type": "keyword"},
    "case_serial": {"type": "integer"},
    "name": {"type": "text"},
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
    "subjects": {
        "type": "nested",
        "properties": {
            "subject": {"type": "text"},
            "primary_subject_id": {"type": "keyword"},
            "secondary_subject_id": {"type": "keyword"},
        }
    },
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
            "penalty": {"type": "scaled_float", "scaling_factor": 100, "null_value": -1},
            "respondent": {"type": "text"},
            "mur_disposition_catagory_id": {"type": "keyword"},
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
    "name": {"type": "text"},
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
    "subjects": {
        "type": "nested",
        "properties": {
            "subject": {"type": "text"},
            "primary_subject_id": {"type": "keyword"},
            "secondary_subject_id": {"type": "keyword"},
        }
    },
    "election_cycles": {"type": "long"},
    "participants": {
        "properties": {
            "name": {"type": "text"},
            "role": {"type": "text"},
        }
    },
    "respondents": {"type": "text"},
    "case_status": {"type": "text"},
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
            "penalty": {"type": "scaled_float", "scaling_factor": 100, "null_value": -1},
            "respondent": {"type": "text"},
        }
    },
    "open_date": {"type": "date", "format": "dateOptionalTime"},
    "close_date": {"type": "date", "format": "dateOptionalTime"},
}

STATUTE_MAPPING = {
    "type": {"type": "keyword"},
    "doc_id": {"type": "keyword"},
    "name": {"type": "text"},
    "text": {"type": "text"},
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
ALL_MAPPING.update(STATUTE_MAPPING)
ALL_MAPPING.update(SORT_MAPPING)

CASE_MAPPING = {"properties": ALL_MAPPING}
