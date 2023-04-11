from webservices import rest
import json
import codecs
import unittest
from unittest.mock import patch
from elasticsearch import RequestError
from webservices.legal_docs.es_management import (  # noqa
    DOCS_PATH, CASE_INDEX
)
from webservices.resources.legal import (  # noqa
    ALL_DOCUMENT_TYPES,
)


# TODO: integrate more with API Schema so that __API_VERSION__ is returned
# self.assertEqual(result["api_version"], __API_VERSION__)
def get_path(obj, path):
    parts = path.split(".")
    first = parts[0]
    assert first in obj

    if len(parts) == 1:
        return obj[first]
    else:
        return get_path(obj[first], ".".join(parts[1:]))


# ========Start test endpoint: '/legal/search/'========
# It is called in legal docs search page.
# ex: https://www.fec.gov/data/legal/search/advisory-opinions/?type=advisory_opinions

# Request DSL query:
# body={
#    "query": {
#         "bool": {
#             "must": [
#                 {
#                     "term": {"type": "admin_fines"}
#                 },
#                 {...},
#             ],
#             ......
#         }
#     }
# }


def legal_search_data(**kwargs):
    type_ = kwargs["body"]["query"]["bool"]["must"][0]["term"]["type"]

    for one_doc_type in ALL_DOCUMENT_TYPES:
        if type_ == one_doc_type:
            return {
                "hits": {
                    "total": {
                        "value": 2,
                        "relation": "eq"
                    },
                    "hits": [
                        {
                            "_source": {
                                "type": one_doc_type,
                                "no": "1111",
                                "highlights": [],
                                "document_highlights": {},
                                "documents": [
                                    {
                                        "document_id": 100,
                                        "text": "aaa bbb",
                                    }],
                            },
                        },
                        {
                            "_source": {
                                "type": one_doc_type,
                                "no": "2222",
                                "highlights": [],
                                "document_highlights": {},
                                "documents": [
                                    {
                                        "document_id": 200,
                                        "text": "ccc ddd",
                                    }],
                            },
                        }
                    ],
                    "total_all": 2,
                }
            }


def legal_invalid_search(*args, **kwargs):
    raise RequestError("invalid query")


class TestLegalSearch(unittest.TestCase):
    def setUp(self):
        self.app = rest.app.test_client()

    @patch("webservices.rest.legal.es_client.search", legal_search_data)
    def test_default_search(self):
        response = self.app.get(
            "/v1/legal/search/?&api_key=1234"
        )
        assert response.status_code == 200
        result = json.loads(codecs.decode(response.data))

        result_data = {}
        for one_doc_type in ALL_DOCUMENT_TYPES:
            type_ = result[one_doc_type][0]["type"]

            if type_ == one_doc_type:
                one_type_data = {
                    one_doc_type: [
                        {
                            "type": one_doc_type,
                            "no": "1111",
                            "highlights": [],
                            "document_highlights": {},
                            "documents": [
                                {
                                    "document_id": 100,
                                    "text": "aaa bbb",
                                }],
                        },
                        {
                            "type": one_doc_type,
                            "no": "2222",
                            "highlights": [],
                            "document_highlights": {},
                            "documents": [
                                {
                                    "document_id": 200,
                                    "text": "ccc ddd",
                                }],
                        },
                    ],
                    ("total_" + one_doc_type): 2,
                }
                result_data.update(one_type_data)

        result_data.update({"total_all": 12})
        assert result == result_data

    @patch("webservices.rest.legal.es_client.search", legal_search_data)
    def test_search_by_type(self):
        for one_doc_type in ALL_DOCUMENT_TYPES:
            response = self.app.get(
                "/v1/legal/search/?type=" + one_doc_type + "&api_key=1234"
            )
            assert response.status_code == 200
            result = json.loads(codecs.decode(response.data))

            type_ = result[one_doc_type][0]["type"]

            if type_ == one_doc_type:
                assert result == {
                    one_doc_type: [
                        {
                            "type": one_doc_type,
                            "no": "1111",
                            "highlights": [],
                            "document_highlights": {},
                            "documents": [
                                {
                                    "document_id": 100,
                                    "text": "aaa bbb",
                                }],
                        },
                        {
                            "type": one_doc_type,
                            "no": "2222",
                            "highlights": [],
                            "document_highlights": {},
                            "documents": [
                                {
                                    "document_id": 200,
                                    "text": "ccc ddd",
                                }],
                        },
                    ],
                    ("total_" + one_doc_type): 2,
                    "total_all": 2,
                }

    @patch("webservices.rest.legal.es_client.search", legal_invalid_search)
    def test_invalid_search(self):
        response = self.app.get(
            "/v1/legal/search/?%20AND%20OR&type=advisory_opinions"
        )
        assert response.status_code == 400
# ========End test endpoint: '/legal/search/'========


# =====Start test endpoint: '/legal/docs/<doc_type>/<no>'=====
# It is called in legal docs canonical page.
# ex: https://www.fec.gov/data/legal/advisory-opinions/2013-17/
# This endpoint always returns one doc.
def legal_doc_data(*args, **kwargs):
    return {
        "hits": {
            "hits": [{
                "_source": {
                    "type": "document type",
                    "no": "100",
                    "summary": "summery 100",
                    "documents": [
                        {
                            "document_id": 111,
                            "category": "Final Opinion",
                            "description": "Closeout Letter",
                            "url": "files/legal/aos/100/111.pdf",
                        },
                        {
                            "document_id": 222,
                            "category": "Draft Documents",
                            "description": "Vote",
                            "url": "files/legal/aos/100/222.pdf",
                        }
                    ]
                },
            }]
        }
    }


class TestLegalDoc(unittest.TestCase):
    @patch("webservices.rest.legal.es_client.search", legal_doc_data)
    def test_legal_doc(self):
        app = rest.app.test_client()
        response = app.get("/v1/legal/" + DOCS_PATH + "/doc_type/1?api_key=1234")
        assert response.status_code == 200
        result = json.loads(codecs.decode(response.data))
        assert result == {
            DOCS_PATH: [{
                "type": "document type",
                "no": "100",
                "summary": "summery 100",
                "documents": [
                    {
                        "document_id": 111,
                        "category": "Final Opinion",
                        "description": "Closeout Letter",
                        "url": "files/legal/aos/100/111.pdf",
                    },
                    {
                        "document_id": 222,
                        "category": "Draft Documents",
                        "description": "Vote",
                        "url": "files/legal/aos/100/222.pdf",
                    }
                ]
            }]
        }

    def test_legal_doc_wrong_path(self):
        app = rest.app.test_client()
        response = app.get("/v1/legal/wrong_path/doc_type/1?api_key=1234")
        assert response.status_code == 404
# =====End test endpoint: '/legal/docs/<doc_type>/<no>'=====
