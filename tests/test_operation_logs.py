
from tests import factories
from tests.common import ApiBaseTest
from webservices.rest import api
from webservices.resources.operations_log import OperationsLogView

class TestOperationsLog(ApiBaseTest):

    def setUp(self):
        super().setUp()
        factories.OperationsLogFactory(candidate_committee_id='00', report_year=2000),
        factories.OperationsLogFactory(candidate_committee_id='01', report_year=2012),
        factories.OperationsLogFactory(candidate_committee_id='02', report_year=2014),

    def test_empty_query(self):

        results = self._results(api.url_for(OperationsLogView, candidate_committee_id='abcd', report_year=2010))
        self.assertEqual(len(results), 0)

    def test_search_no_match_cand_cmte_id(self):

        response = self.app.get(api.url_for(OperationsLogView, candidate_committee_id='01', report_year=2000))
        self.assertEquals(response.status_code, 200)
