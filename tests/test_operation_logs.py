
from tests import factories
from tests.common import ApiBaseTest, assert_dicts_subset
from webservices.rest import api
from webservices.resources.operations_log import OperationsLogView

class TestOperationsLog(ApiBaseTest):

    def setUp(self):
        super().setUp()
        factories.OperationsLogFactory(candidate_committee_id='00', report_year=2000),
        factories.OperationsLogFactory(candidate_committee_id='01', report_year=2012),
        factories.OperationsLogFactory(candidate_committee_id='02', report_year=2014),

    def test_search_cand_cmte_id(self):

        results = self._results(api.url_for(OperationsLogView, candidate_committee_id='01', report_year=2000))
        self.assertEqual(len(results), 2)
        assert_dicts_subset(results[0], {'candidate_committee_id': '01'})
        assert_dicts_subset(results[1], {'candidate_committee_id': '01', 'report_year': 2000})

    # def test_counts(self):
    #     response = self._response(api.url_for(OperationsLogView))
    #     footer_count = response['pagination']['count']
    #     results_count = len(response['results'])
    #     self.assertEqual(footer_count, results_count)
