import datetime

from tests import factories
from tests.common import ApiBaseTest
from webservices.rest import api
from webservices.resources.operations_log import OperationsLogView


class TestOperationsLog(ApiBaseTest):
    def setUp(self):
        super().setUp()
        factories.OperationsLogFactory(
            candidate_committee_id='00', report_year=2000, status_num=1
        ),
        factories.OperationsLogFactory(
            candidate_committee_id='01', report_year=2012, status_num=0
        ),
        factories.OperationsLogFactory(
            candidate_committee_id='02', report_year=2014, status_num=1
        ),
        factories.OperationsLogFactory(
            candidate_committee_id='03',
            report_year=2017,
            receipt_date=datetime.date(2017, 3, 1),
        ),
        factories.OperationsLogFactory(
            candidate_committee_id='03',
            report_year=2017,
            coverage_end_date=datetime.date(2018, 4, 30),
        ),
        factories.OperationsLogFactory(
            candidate_committee_id='03',
            report_year=2017,
            transaction_data_complete_date=datetime.date(2016, 10, 15),
        )

    def test_empty_query(self):

        results = self._results(
            api.url_for(
                OperationsLogView, candidate_committee_id='10', report_year=2030
            )
        )
        self.assertEqual(len(results), 0)

    def test_search_cand_cmte_id(self):

        response = self.app.get(
            api.url_for(
                OperationsLogView, candidate_committee_id='01', report_year=2012
            )
        )
        self.assertEqual(response.status_code, 200)

    def test_unverified_reports(self):

        results = self._results(
            api.url_for(OperationsLogView, candidate_committee_id='01', status_num=0)
        )
        self.assertEqual(len(results), 1)
        for result in results:
            self.assertTrue(1, result['status_num'])

    def test_verified_reports(self):

        results = self._results(
            api.url_for(OperationsLogView, candidate_committee_id='02', status_num=1)
        )
        self.assertEqual(len(results), 1)
        for result in results:
            self.assertTrue(1, result['status_num'])

    def test_receipt_date_range(self):

        min_date = datetime.date(2017, 1, 1)
        max_date = datetime.date(2017, 12, 31)

        results = self._results(
            api.url_for(OperationsLogView, min_receipt_date=min_date)
        )
        self.assertTrue(
            all(
                each for each in results if each['receipt_date'] >= min_date.isoformat()
            )
        )

        results = self._results(
            api.url_for(OperationsLogView, max_receipt_date=max_date)
        )
        self.assertTrue(
            all(
                each for each in results if each['receipt_date'] <= max_date.isoformat()
            )
        )

        results = self._results(
            api.url_for(
                OperationsLogView, min_receipt_date=min_date, max_receipt_date=max_date
            )
        )
        self.assertTrue(
            all(
                each
                for each in results
                if min_date.isoformat() <= each['receipt_date'] <= max_date.isoformat()
            )
        )

    def test_coverage_end_date_range(self):

        min_date = datetime.date(2018, 1, 1)
        max_date = datetime.date(2018, 12, 31)

        results = self._results(
            api.url_for(OperationsLogView, min_coverage_end_date=min_date)
        )
        self.assertTrue(
            all(
                each
                for each in results
                if each['coverage_end_date'] >= min_date.isoformat()
            )
        )

        results = self._results(
            api.url_for(OperationsLogView, max_coverage_end_date=max_date)
        )
        self.assertTrue(
            all(
                each
                for each in results
                if each['coverage_end_date'] <= max_date.isoformat()
            )
        )

        results = self._results(
            api.url_for(
                OperationsLogView,
                min_coverage_end_date=min_date,
                max_coverage_end_date=max_date,
            )
        )
        self.assertTrue(
            all(
                each
                for each in results
                if min_date.isoformat()
                <= each['coverage_end_date']
                <= max_date.isoformat()
            )
        )

    def test_transaction_data_complete_date_range(self):

        min_date = datetime.date(2016, 1, 1)
        max_date = datetime.date(2016, 12, 31)

        results = self._results(
            api.url_for(OperationsLogView, min_transaction_data_complete_date=min_date)
        )
        self.assertTrue(
            all(
                each
                for each in results
                if each['transaction_data_complete_date'] >= min_date.isoformat()
            )
        )

        results = self._results(
            api.url_for(OperationsLogView, max_transaction_data_complete_date=max_date)
        )
        self.assertTrue(
            all(
                each
                for each in results
                if each['transaction_data_complete_date'] <= max_date.isoformat()
            )
        )

        results = self._results(
            api.url_for(
                OperationsLogView,
                min_transaction_data_complete_date=min_date,
                max_transaction_data_complete_date=max_date,
            )
        )
        self.assertTrue(
            all(
                each
                for each in results
                if min_date.isoformat()
                <= each['transaction_data_complete_date']
                <= max_date.isoformat()
            )
        )

    def test_invalid_image_number(self):
        response = self.app.get(
            api.url_for(OperationsLogView, beginning_image_number='fec-12345')
        )
        self.assertEqual(response.status_code, 422)
