from tests.common import ElasticSearchBaseTest
from webservices.rest import api
from webservices.resources.legal import GetLegalCitation
# import logging


class TestCitationsElasticsearch(ElasticSearchBaseTest):
    def test_citations(self):

        citations = [
            ["statute", "10"],
            ["regulation", "16"]
        ]
        for citation in citations:
            response = self._results_citations(api.url_for(GetLegalCitation, citation_type=citation[0],
                                                           citation=citation[1]))
            # logging.info(response)

            for res in response:
                self.assertEqual(res["citation_type"], citation[0])
                assert citation[1] in res["citation_text"]

    def test_incorrect_citations(self):
        response = self.app.get(api.url_for(GetLegalCitation, citation_type="abc", citation="10"))
        # logging.info(response.json)

        self.assertEqual(len(response.json["citations"]), 0)

        response = self.app.get(api.url_for(GetLegalCitation, citation_type="statute", citation="444444444"))
        # logging.info(response.json)

        self.assertEqual(len(response.json["citations"]), 0)

    def test_doc_type_filter(self):
        cit = "12"
        doc_type = "murs"

        response = self._results_citations(api.url_for(GetLegalCitation, citation_type="regulation", citation=cit,
                                                       doc_type=doc_type))
        # logging.info(response)

        assert all(
            citation["doc_type"] == doc_type
            for citation in response
        )

        response = self.app.get(api.url_for(GetLegalCitation, citation_type="regulation", citation=cit,
                                            doc_type="wrong_type"))

        self.assertEqual(response.status_code, 422)
