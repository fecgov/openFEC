
from tests import factories
from tests.common import ApiBaseTest
from webservices.rest import api
from webservices.resources.operations_log import OperationsLogView

class TestOperationsLog(ApiBaseTest):

    def setUp(self):
        super().setUp()
        factories.OperationsLogFactory(candidate_committee_id='00', report_year=2000, status_num=1),
        factories.OperationsLogFactory(candidate_committee_id='01', report_year=2012, status_num=0),
        factories.OperationsLogFactory(candidate_committee_id='02', report_year=2014, status_num=1),
        factories.OperationsLogFactory(candidate_committee_id='03', report_year=2016, status_num=0),
        factories.OperationsLogFactory(candidate_committee_id='04', report_year=2018, status_num=1),
        factories.OperationsLogFactory(candidate_committee_id='05', report_year=2020, status_num=1),

    def test_empty_query(self):

        results = self._results(api.url_for(OperationsLogView, candidate_committee_id='10', report_year=2030))
        self.assertEqual(len(results), 0)

    def test_search_cand_cmte_id(self):

        response = self.app.get(api.url_for(OperationsLogView, candidate_committee_id='01', report_year=2012))
        self.assertEquals(response.status_code, 200)

    def test_search_cand_cmte_id_with_status_verified(self):

        results = self._results(api.url_for(OperationsLogView, status_num=1))
        self.assertEqual(len(results), 4)
