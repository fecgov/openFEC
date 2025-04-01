from tests.common import ElasticSearchBaseTest
from webservices.api_setup import api
from webservices.resources.legal import GetLegalDocument
from webservices.legal_docs import TEST_SEARCH_ALIAS

import unittest.mock as mock
# import logging


@mock.patch("webservices.resources.legal.SEARCH_ALIAS", TEST_SEARCH_ALIAS)
class TestLegalDocsElasticsearch(ElasticSearchBaseTest):
    def test_legal_docs(self):

        docs = [
            ["statutes", "9001"],
            ["advisory_opinions", "2024-12"],
            ["murs", "103"],  # archived mur
            ["adrs", "106"],
            ["admin_fines", "108"],
            ["murs", "101"],  # current mur
        ]

        for doc in docs:
            response = self._results_docs(api.url_for(GetLegalDocument, doc_type=doc[0], no=doc[1]))
            # logging.info(response)

            self.assertEqual(response[0]["no"], doc[1])

    def test_legal_docs_incorrect(self):
        response = self.app.get(api.url_for(GetLegalDocument, doc_type="wrong_type", no="100"))

        self.assertEqual(response.status_code, 404)
        # logging.info(response.json)

        response = self.app.get(api.url_for(GetLegalDocument, doc_type="murs", no="555555555"))
        # logging.info(response.json)

        self.assertEqual(response.status_code, 404)
