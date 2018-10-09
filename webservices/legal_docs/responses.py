import copy

MUR_ADR_COMMON_SCHEMA = {
    "type": "array",
    "items": {
        "type": "object",
        "properties": {
            "open_date": {
                "type": "string",
                "format": "date"
            },
            "close_date": {
                "type": "string",
                "format": "date"
            },
            "no": {
                "type": "string"
            },
            "name": {
                "type": "string"
            },
            "election_cycles": {
                "type": "integer"
            },
            "documents": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "document_id": {
                            "type": "integer"
                        },
                        "document_date": {
                            "type": "string",
                            "format": "date"
                        },
                        "description": {
                            "type": "string"
                        },
                        "category": {
                            "type": "string"
                        },
                        "length": {
                            "type": "integer"
                        },
                        "url": {
                            "type": "string"
                        }
                    }
                }
            },
            "subjects": {
                "type": "array",
                "items": {
                    "type": "string"
                }
            },
            "doc_id": {
                "type": "string"
            },
            "url": {
                "type": "string"
            },
            "respondents": {
                "type": "array",
                "items": {
                    "type": "string"
                }
            },
            "participants": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "role": {
                            "type": "string"
                        },
                        "citations": {  # TODO
                            "type": "object"
                        },
                        "name": {
                            "type": "string"
                        }
                    }
                }
            },
            "commission_votes": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "vote_date": {
                            "type": "string",
                            "format": "date"
                        },
                        "action": {
                            "type": "string"
                        }
                    }
                }
            },
            "dispositions": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "disposition": {
                            "type": "string"
                        },
                        "penalty": {
                            "type": "number"
                        },
                        "respondent": {
                            "type": "string"
                        },
                        "citations": {
                            "type": "array",
                            "items": {
                                "type": "object",
                                "properties": {
                                    "text": {
                                        "type": "string"
                                    },
                                    "type": {
                                        "type": "string"
                                    },
                                    "title": {
                                        "type": "string"
                                    },
                                    "url": {
                                        "type": "string"
                                    },
                                }
                            }
                        }
                    }
                }
            },
            "highlights": {
                "type": "array",
                "items": {
                    "type": "string"
                }
            },
            "document_highlights": {
                "type": "object"  # Dynamic dictionary
            }
        },
    }
}

MUR_SCHEMA = copy.deepcopy(MUR_ADR_COMMON_SCHEMA)
MUR_SCHEMA["items"]["properties"]["mur_type"] = {
    "type": "string",
    "enum": [
        "current",
        "archived"
    ]
}
LEGAL_SEARCH_RESPONSE = {
    "default": {
        "description": "Legal search results",
        "schema": {
            "type": "object",
            "properties": {
                "total_statutes": {
                    "type": "integer",
                    "description": "Total number of Statutes matching the search criteria"
                },
                "total_regulations": {
                    "type": "integer",
                    "description": "Total number of Regulations matching the search criteria"
                },
                "total_advisory_opinions": {
                    "type": "integer",
                    "description": "Total number of Advisory Opinions matching the search criteria"
                },
                "total_murs": {
                    "type": "integer",
                    "description": "Total number of MURs matching the search criteria"
                },
                "total_adrs": {
                    "type": "integer",
                    "description": "Total number of ADRs matching the search criteria"
                },
                "total_admin_fines": {
                    "type": "integer",
                    "description": "Total number of Admin Fines matching the search criteria"
                },
                "total_all": {
                    "type": "integer",
                    "description": "Total number of legal documents matching the search criteria"
                },
                "regulations": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "name": {
                                "type": "string",
                            },
                            "no": {
                                "type": "string"
                            },
                            "doc_id": {
                                "type": "string"
                            },
                            "url": {
                                "type": "string"
                            },
                            "highlights": {
                                "type": "array",
                                "items": {
                                    "type": "string"
                                }
                            },
                            "document_highlights": {
                                "type": "object"  # Dynamic dictionary
                            }
                        }
                    }
                },
                "statutes": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "name": {
                                "type": "string",
                            },
                            "no": {
                                "type": "string"
                            },
                            "chapter": {
                                "type": "string"
                            },
                            "title": {
                                "type": "string"
                            },
                            "doc_id": {
                                "type": "string"
                            },
                            "url": {
                                "type": "string"
                            },
                            "highlights": {
                                "type": "array",
                                "items": {
                                    "type": "string"
                                }
                            },
                            "document_highlights": {
                                "type": "object"  # Dynamic dictionary
                            }
                        }
                    }
                },
                "advisory_opinions": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "name": {
                                "type": "string",
                            },
                            "request_date": {
                                "type": "string",
                                "format": "date"
                            },
                            "summary": {
                                "type": "string"
                            },
                            "no": {
                                "type": "string"
                            },
                            "issue_date": {
                                "type": "string",
                                "format": "date"
                            },
                            "is_pending": {
                                "type": "boolean"
                            },
                            "status": {
                                "type": "string"
                            },
                            "ao_citations": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "no": {
                                            "type": "string"
                                        },
                                        "name": {
                                            "type": "string"
                                        }
                                    }
                                }
                            },
                            "aos_cited_by": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "no": {
                                            "type": "string"
                                        },
                                        "name": {
                                            "type": "string"
                                        }
                                    }
                                }
                            },
                            "regulatory_citations": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "part": {
                                            "type": "integer"
                                        },
                                        "section": {
                                            "type": "integer"
                                        },
                                        "title": {
                                            "type": "integer"
                                        }
                                    }
                                }
                            },
                            "statutory_citations": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "title": {
                                            "type": "integer"
                                        },
                                        "section": {
                                            "type": "string"
                                        }
                                    }
                                }
                            },
                            "representative_names": {
                                "type": "array",
                                "items": {
                                    "type": "string"
                                }
                            },
                            "requestor_names": {
                                "type": "array",
                                "items": {
                                    "type": "string"
                                }
                            },
                            "commenter_names": {
                                "type": "array",
                                "items": {
                                    "type": "string"
                                }
                            },
                            "requestor_types": {
                                "type": "array",
                                "items": {
                                    "type": "string"
                                }
                            },
                            "documents": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "document_id": {
                                            "type": "integer"
                                        },
                                        "date": {
                                            "type": "string",
                                            "format": "date"
                                        },
                                        "description": {
                                            "type": "string"
                                        },
                                        "category": {
                                            "type": "string"
                                        },
                                        "url": {
                                            "type": "string"
                                        }
                                    }
                                }
                            },
                            "entities": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "role": {
                                            "type": "string"
                                        },
                                        "name": {
                                            "type": "string"
                                        },
                                        "type": {
                                            "type": "string"
                                        }
                                    }
                                }
                            },
                            "highlights": {
                                "type": "array",
                                "items": {
                                    "type": "string"
                                }
                            },
                            "document_highlights": {
                                "type": "object"  # Dynamic dictionary
                            }
                        }
                    }
                },
                "murs": MUR_SCHEMA,
                "adrs": MUR_ADR_COMMON_SCHEMA,
                "admin_fines": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "no": {
                                "type": "string"
                            },
                            "petition_court_decision_date": {
                                "type": "string",
                                "format": "date"
                            },
                            "treasury_referral_amount": {
                                "type": "number"
                            },
                            "documents": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "document_id": {
                                            "type": "integer"
                                        },
                                        "document_date": {
                                            "type": "string",
                                            "format": "date"
                                        },
                                        "description": {
                                            "type": "string"
                                        },
                                        "category": {
                                            "type": "string"
                                        },
                                        "length": {
                                            "type": "integer"
                                        },
                                        "url": {
                                            "type": "string"
                                        }
                                    }
                                }
                            },
                            "commission_votes": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "vote_date": {
                                            "type": "string",
                                            "format": "date"
                                        },
                                        "action": {
                                            "type": "string"
                                        }
                                    }
                                }
                            },
                            "challenge_outcome": {
                                "type": "string"
                            },
                            "report_type": {
                                "type": "string"
                            },
                            "reason_to_believe_action_date": {
                                "type": "string",
                                "format": "date"
                            },
                            "doc_id": {
                                "type": "string"
                            },
                            "url": {
                                "type": "string"
                            },
                            "treasury_referral_date": {
                                "type": "string",
                                "format": "date"
                            },
                            "challenge_receipt_date": {
                                "type": "string",
                                "format": "date"
                            },
                            "final_determination_date": {
                                "type": "string",
                                "format": "date"
                            },
                            "name": {
                                "type": "string"
                            },
                            "report_year": {
                                "type": "string"
                            },
                            "final_determination_amount": {
                                "type": "number"
                            },
                            "check_amount": {
                                "type": "number"
                            },
                            "petition_court_filing_date": {
                                "type": "string",
                                "format": "date"
                            },
                            "committee_id": {
                                "type": "string"
                            },
                            "reason_to_believe_fine_amount": {
                                "type": "number"
                            },
                            "highlights": {
                                "type": "array",
                                "items": {
                                    "type": "string"
                                }
                            },
                            "document_highlights": {
                                "type": "object"  # Dynamic dictionary
                            }
                        }
                    }
                }

            },
            "example": {
                "statutes": [],
                "total_statutes": 0,
                "regulations": [],
                "total_regulations": 0,
                "advisory_opinions": [
                    {
                        "name": "Primerica, Inc.",
                        "request_date": "2012-05-14",
                        "summary": "Disaffiliation of corporations and their SSFs.",
                        "no": "2012-21",
                        "issue_date": "2012-06-21",
                        "is_pending": False,
                        "status": "Final",
                        "ao_citations": [
                            {"no": "1986-42", "name": "Dart & Kraft"}
                        ],
                        "representative_names": [
                            "Doe, John"
                        ],
                        "requestor_names": [
                            "Acme, Inc."
                        ],
                        "documents": [
                            {
                                "date": "2012-06-18T00:00:00", "description": "Draft AO, Agenda Document",
                                "document_id": 1234, "category": "Draft Documents",
                                "url": "/files/legal/some_number.pdf"
                            }
                        ],
                        "commenter_names": [],
                        "regulatory_citations": [
                            {"part": 100, "section": 5, "title": 11},
                            {"part": 110, "section": 3, "title": 11}
                        ],
                        "aos_cited_by": [
                            {"no": "2014-11", "name": "Service Corporation Employees' Political Action Committee"}
                        ],
                        "statutory_citations": [
                            {"section": "30108", "title": 52},
                            {"section": "30116", "title": 52}
                        ],
                        "entities": [
                            {"role": "Counsel/Representative", "name": "Keane, Benjamin", "type": "Individual"},
                            {
                                "role": "Requestor", "name": "Primerica, Inc.",
                                "type": "Corporation (including LLCs electing corporate status)"}
                        ],
                        "requestor_types": ["Law Firm", "Corporation (including LLCs electing corporate status)"],
                        "highlights": ["officer's willful theft, \n\n<em>embezzlement</em> or act of comparable"],
                        "document_highlights": {
                            "1": ["officer's willful theft, \n\n<em>embezzlement</em> or act of comparable"]
                        }
                    }
                ],
                "total_advisory_opinions": 1,
                "murs": [
                    {
                        "open_date": "2016-09-01T00:00:00",
                        "no": "7132",
                        "close_date": "2018-03-01T00:00:00",
                        "documents": [
                            {
                                "length": 181804,
                                "document_date": "2018-03-19T00:00:00",
                                "description": "Michael David Pitts",
                                "document_id": 100488383,
                                "category": "Conciliation Agreements",
                                "url": "/files/legal/murs/7132/18044440286.pdf"
                            },
                            {
                                "length": 36491,
                                "document_date": "2017-06-12T00:00:00",
                                "description": "Consent to Extend the Time to Institute a Civil Law Enforcement Suit",
                                "document_id": 100488382,
                                "category": "Complaint, Responses, Designation of Counsel and Extensions of Time",
                                "url": "/files/legal/murs/7132/18044440271.pdf"
                            }
                        ],
                        "subjects": ["Committees-Candidate", "Other"],
                        "dispositions": [
                            {
                                "disposition": "Approved by Commission",
                                "citations": [
                                    {
                                        "text": "30102(b)(3)", "type": "statute", "title": "52",
                                        "url": "https://api.fdsys.gov/link-type=html&title=52&section=30102"},
                                    {
                                        "text": "102.15", "type": "regulation", "title": "11",
                                        "url": "/regulations/102-15/CURRENT"}
                                ],
                                "penalty": None,
                                "respondent": "Pitts, Michael David"
                            },
                            {
                                "disposition": "Approved Recs.",
                                "citations": [
                                    {
                                        "text": "30102(b)(3)", "type": "statute", "title": "52",
                                        "url": "https://api.fdsys.gov/link?link-type=html&title=52&section=30102"},
                                    {
                                        "text": "102.15", "type": "regulation", "title": "11",
                                        "url": "/regulations/102-15/CURRENT"}
                                ],
                                "penalty": None,
                                "respondent": "Pitts, Michael David"
                            }
                        ],
                        "doc_id": "mur_7132",
                        "url": "/legal/matter-under-review/7132/",
                        "respondents": ["Pitts, Michael David", "Evergreen Incentives LLC"],
                        "name": "MICHAEL DAVID PITTS",
                        "election_cycles": [2014],
                        "commission_votes": [
                            {
                                "vote_date": "2018-03-01T00:00:00",
                                "action": """
The Commission decided by a vote of 4-0 to take the following actions in MUR 7132:
1.  Accept the conciliation agreement with Michael David Pitts, as recommended in the Memorandum to the Commission
dated February 14, 2018.
2.  Approve the appropriate letter.
3.  Close the file.
"""
                            },
                            {
                                "vote_date": "2017-05-10T00:00:00",
                                "action": """
The Commission decided by a vote of 4-1 to take the following actions in \nPre-MUR 596 and MUR 7132:
1. Transfer Pre-MUR 596 to the Office of Alternative Dispute Resolution.
2. Find reason to believe that Michael David Pitts knowingly and willfully violated 52 U.S.C. \u00a7 30102(b)(3) and
11 C.F.R. \u00a7 102.15.
3. Enter into pre-probable cause conciliation with Michael David Pitts prior to a finding of probable cause to believe.
4. Approve the Conciliation Agreement for Michael David Pitts, as recommended in the First General Counsel\u2019s Report
dated March 6, 2017.
5. Approve the Factual and Legal Analysis for Michael David Pitts, as recommended in the First General Counsel\u2019s
Report dated March 6, 2017.
6. Approve the appropriate letter.
"""
                            }
                        ],
                        "mur_type": "current",
                        "participants": [
                            {"role": "Primary Respondent", "citations": {}, "name": "Pitts, Michael David"},
                            {"role": "Complainant", "citations": {}, "name": "AMEDISYS, INC."}
                        ],
                        "highlights": [
                            " to carry out his  <em>embezzlement</em> scheme.  ",
                            "  is prohibited by law.  6. Pitts sought  to conceal the  <em>embezzlement</em> by under",
                            "  execute  his various  <em>embezzlements</em>. That  month, Mr.  Pitts also  transferred",
                            " that  was used to carry out his  <em>embezzlement</em> scheme.  Pitts also  did not  ",
                            " the  <em>embezzlement</em> by under-reporting the  transfer of payroll  deductions from"
                        ],
                        "document_highlights": {}
                    }
                ],
                "total_murs": 2,
                "admin_fines": [],
                "adrs": [],
                "total_admin_fines": None,
                "total_adrs": None,
                "total_all": 3
            }
        }
    }
}
