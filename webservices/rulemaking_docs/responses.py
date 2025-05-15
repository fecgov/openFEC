
RULEMAKING_SEARCH_RESPONSE_1 = {
    "default": {
        "description": "Rulemaking search results",
        "schema": {
            "type": "object",
            "properties": {
                "rulemakings": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "admin_close_date": {"type": "string", "format": "date"},
                            "calculated_comment_close_date": {"type": "string", "format": "date"},
                            "comment_close_date": {"type": "string", "format": "date"},
                            # "commenter_names": {
                            #     "type": "array",
                            #     "items": {"type": "string"}
                            # },
                            # "counsel_names": {
                            #     "type": "array",
                            #     "items": {"type": "string"}
                            # },
                            # "descriptions": {"type": "string"},
                            # "documents": {
                            #     "type": "array",
                            #     "items": {
                            #         "type": "object",
                            #         "properties": {
                            #             "doc_category_id": {"type": "string"},
                            #             "doc_category_label": {"type": "string"},
                            #             "doc_date": {"type": "string", "format": "date"},
                            #             "doc_description": {"type": "string"},
                            #             "doc_entities": {
                            #                 "type": "object",
                            #                 "properties": {
                            #                     "name": {"type": "string"},
                            #                     "role": {"type": "string"}
                            #                 }
                            #             },
                            #             "doc_id": {"type": "integer"},
                            #             "doc_type_id": {"type": "integer"},
                            #             "doc_type_label": {"type": "string"},
                            #             "filename": {"type": "string"},
                            #             "is_key_document": {"type": "boolean"},
                            #             "level_1": {"type": "integer"},
                            #             "level_1_label": {"type": "string"},
                            #             "level_2": {"type": "integer"},
                            #             "level_2_label": {"type": "string"},
                            #             "level_2_labels": {
                            #                 "type": "object",
                            #                 "properties": {
                            #                     "level_2": {"type": "integer"},
                            #                     "level_2_label": {"type": "text"},
                            #                     "level_2_docs": {
                            #                         "type": "object",
                            #                         "properties": {
                            #                             "doc_category_id": {"type": "integer"},
                            #                             "doc_category_label": {"type": "string"},
                            #                             "document_date": {"type": "string", "format": "date"},
                            #                             "doc_description": {"type": "string"},
                            #                             "document_id": {"type": "integer"},
                            #                             "doc_entities": {
                            #                                 "type": "object",
                            #                                 "properties": {
                            #                                     "role": {"type": "string"},
                            #                                     "name": {"type": "string"}
                            #                                 }
                            #                             },
                            #                             "doc_type_id": {"type": "integer"},
                            #                             "doc_type_label": {"type": "string"},
                            #                             "filename": {"type": "string"},
                            #                             "is_key_document": {"type": "boolean"},
                            #                             "level_1": {"type": "integer"},
                            #                             "level_1_label": {"type": "string"},
                            #                             "level_2": {"type": "integer"},
                            #                             "level_2_label": {"type": "string"},
                            #                             "sort_order": {"type": "integer"},
                            #                             "url": {"type": "text", "index": False}
                            #                         }
                            #                     }
                            #                 }
                            #             },
                            #             "sort_order": {"type": "integer"},
                            #             "url": {"type": "text", "index": False}
                            #         }
                            #     }
                            # },
                            # "fr_publication_dates": {
                            #     "type": "array",
                            #     "items": {"type": "string", "format": "date"}
                            # },
                            # "hearing_dates": {
                            #     "type": "array",
                            #     "items": {"type": "string", "format": "date"}
                            # },
                            # "is_open_for_comment": {"type": "boolean"},
                            # "key_documents": {
                            #     "type": "array",
                            #     "items": {
                            #         "type": "object",
                            #         "properties": {
                            #             "doc_date": {"type": "date", "format": "dateOptionalTime"},
                            #             "doc_description": {"type": "text"},
                            #             "doc_id": {"type": "long"},
                            #             "filename": {"type": "text"},
                            #             "level_1": {"type": "integer"},
                            #             "level_1_label": {"type": "keyword"},
                            #             "level_2": {"type": "integer"},
                            #             "url": {"type": "text", "index": False}
                            #         }
                            #     }
                            # },
                            # "last_updated_date": {"type": "string", "format": "date"},
                            # "petitioner_names": {
                            #     "type": "array",
                            #     "items": {"type": "string"}
                            # },
                            # "representative_names": {
                            #     "type": "array",
                            #     "items": {"type": "string"}
                            # },
                            # "rm_entities": {
                            #     "type": "array",
                            #     "items": {
                            #         "type": "object",
                            #         "properties": {
                            #             "role": {"type": "string"},
                            #             "name": {"type": "string"},
                            #             "type": {"type": "string"}
                            #         }
                            #     }
                            # },
                            # "rm_id": {"type": "integer"},
                            # "rm_name": {"type": "string"},
                            "rm_no": {"type": "string"},
                            # "rm_serial": {"type": "integer"},
                            # "rm_year": {"type": "integer"},
                            # "sort1": {"type": "integer"},
                            # "sort2": {"type": "integer"},
                            # "sync_status": {"type": "string"},
                            # "title": {"type": "string"},
                            # "type": {"type": "string"},
                            # "witness": {"type": "string"},
                            # "vote_dates": {"type": "string", "format": "date"},
                            # "highlights": {
                            #     "type": "array",
                            #     "items": {"type": "string"}
                            # },
                            # "document_highlights": {
                            #     "type": "object"  # Dynamic dictionary
                            # }
                        }
                    }
                }
            }
        }
    }
}

RULEMAKING_SEARCH_RESPONSE = {
    "default": {
        "description": "Rulemaking search results",
        "schema": {
            "type": "object",
            "properties": {
                "rulemakings": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "admin_close_date": {"type": "string", "format": "date"},
                            "calculated_comment_close_date": {"type": "string", "format": "date"},
                            "comment_close_date": {"type": "string", "format": "date"},
                            "commenter_names": {
                                "type": "array",
                                "items": {"type": "string"}
                            },
                            "counsel_names": {
                                "type": "array",
                                "items": {"type": "string"}
                            },
                            "descriptions": {"type": "string"},
                            "documents": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "doc_category_id": {"type": "string"},
                                        "doc_category_label": {"type": "string"},
                                        "doc_date": {"type": "string", "format": "date"},
                                        "doc_description": {"type": "string"},
                                        "doc_entities": {
                                            "type": "object",
                                            "properties": {
                                                "name": {"type": "string"},
                                                "role": {"type": "string"}
                                            }
                                        },
                                        "doc_id": {"type": "integer"},
                                        "doc_type_id": {"type": "integer"},
                                        "doc_type_label": {"type": "string"},
                                        "filename": {"type": "string"},
                                        "is_key_document": {"type": "boolean"},
                                        "level_1": {"type": "integer"},
                                        "level_1_label": {"type": "string"},
                                        "level_2": {"type": "integer"},
                                        "level_2_label": {"type": "string"},
                                        "level_2_labels": {
                                            "type": "object",
                                            "properties": {
                                                "level_2": {"type": "integer"},
                                                "level_2_label": {"type": "text"},
                                                "level_2_docs": {
                                                    "type": "object",
                                                    "properties": {
                                                        "doc_category_id": {"type": "integer"},
                                                        "doc_category_label": {"type": "string"},
                                                        "document_date": {"type": "string", "format": "date"},
                                                        "doc_description": {"type": "string"},
                                                        "document_id": {"type": "integer"},
                                                        "doc_entities": {
                                                            "type": "object",
                                                            "properties": {
                                                                "role": {"type": "string"},
                                                                "name": {"type": "string"}
                                                            }
                                                        },
                                                        "doc_type_id": {"type": "integer"},
                                                        "doc_type_label": {"type": "string"},
                                                        "filename": {"type": "string"},
                                                        "is_key_document": {"type": "boolean"},
                                                        "level_1": {"type": "integer"},
                                                        "level_1_label": {"type": "string"},
                                                        "level_2": {"type": "integer"},
                                                        "level_2_label": {"type": "string"},
                                                        "sort_order": {"type": "integer"},
                                                        "url": {"type": "text", "index": False}
                                                    }
                                                }
                                            }
                                        },
                                        "sort_order": {"type": "integer"},
                                        "url": {"type": "text", "index": False}
                                    }
                                }
                            },
                            "fr_publication_dates": {
                                "type": "array",
                                "items": {"type": "string", "format": "date"}
                            },
                            "hearing_dates": {
                                "type": "array",
                                "items": {"type": "string", "format": "date"}
                            },
                            "is_open_for_comment": {"type": "boolean"},
                            "key_documents": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "doc_date": {"type": "date", "format": "dateOptionalTime"},
                                        "doc_description": {"type": "text"},
                                        "doc_id": {"type": "long"},
                                        "filename": {"type": "text"},
                                        "level_1": {"type": "integer"},
                                        "level_1_label": {"type": "keyword"},
                                        "level_2": {"type": "integer"},
                                        "url": {"type": "text", "index": False}
                                    }
                                }
                            },
                            "last_updated_date": {"type": "string", "format": "date"},
                            "petitioner_names": {
                                "type": "array",
                                "items": {"type": "string"}
                            },
                            "representative_names": {
                                "type": "array",
                                "items": {"type": "string"}
                            },
                            "rm_entities": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "role": {"type": "string"},
                                        "name": {"type": "string"},
                                        "type": {"type": "string"}
                                    }
                                }
                            },
                            "rm_id": {"type": "integer"},
                            "rm_name": {"type": "string"},
                            "rm_no": {"type": "string"},
                            "rm_serial": {"type": "integer"},
                            "rm_year": {"type": "integer"},
                            "sort1": {"type": "integer"},
                            "sort2": {"type": "integer"},
                            "sync_status": {"type": "string"},
                            "title": {"type": "string"},
                            "type": {"type": "string"},
                            "witness": {"type": "string"},
                            "vote_dates": {"type": "string", "format": "date"},
                            "highlights": {
                                "type": "array",
                                "items": {"type": "string"}
                            },
                            "document_highlights": {
                                "type": "object"  # Dynamic dictionary
                            }
                        }
                    }
                }
            }
        }
    }
}
