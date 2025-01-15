from tests.common import ElasticSearchBaseTest
from webservices.rest import api
from webservices.resources.legal import UniversalSearch
from webservices.legal_docs import TEST_SEARCH_ALIAS

import unittest.mock as mock
# import logging


@mock.patch("webservices.resources.legal.SEARCH_ALIAS", TEST_SEARCH_ALIAS)
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
