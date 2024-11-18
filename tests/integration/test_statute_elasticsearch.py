from tests.common import ElasticSearchBaseTest
from webservices.rest import api
from webservices.resources.legal import UniversalSearch
# import logging


class TestStatuteDocsElasticsearch(ElasticSearchBaseTest):

    def test_q_search(self):
        q = "Payments"
        response = self._results_statute(api.url_for(UniversalSearch, q=q))
        # logging.info(response)

        assert all(
            all(q in highlight
                for highlight in statute["highlights"])
            for statute in response
        )
