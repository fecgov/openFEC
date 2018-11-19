
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
        factories.OperationsLogFactory(candidate_committee_id='03', report_year=2017, receipt_date='2017-03-01'),

    def test_empty_query(self):

        results = self._results(api.url_for(OperationsLogView, candidate_committee_id='10', report_year=2030))
        self.assertEqual(len(results), 0)

    def test_search_cand_cmte_id(self):

        response = self.app.get(api.url_for(OperationsLogView, candidate_committee_id='01', report_year=2012))
        self.assertEquals(response.status_code, 200)

    def test_unverified_reports(self):

        results = self._results(api.url_for(OperationsLogView, candidate_committee_id='01', status_num=0))
        self.assertEqual(len(results), 1)
        for result in results:
            self.assertTrue(1, result['status_num'])

    def test_verified_reports(self):

        results = self._results(api.url_for(OperationsLogView, candidate_committee_id='02', status_num=1))
        self.assertEqual(len(results), 1)
        for result in results:
            self.assertTrue(1, result['status_num'])

    def test_receipt_date(self):

        results = self._results(api.url_for(OperationsLogView, min_receipt_date='2017-01-01'))
        self.assertEqual(len(results), 1)
        for result in results:
            self.assertTrue('2017-01-01', result['receipt_date'])

    def test_max_receipt_date(self):

        results = self._results(api.url_for(OperationsLogView, max_receipt_date='2017-12-31'))
        self.assertEqual(len(results), 1)
        for result in results:
            self.assertTrue('2017-01-01', result['receipt_date'])
