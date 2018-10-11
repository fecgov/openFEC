import pytest
import codecs
import json
import datetime
import copy

import manage
from tests.common import BaseTestCase
from webservices import rest, __API_VERSION__
from webservices.resources.filings import FilingsView, FilingsList


@pytest.mark.usefixtures("migrate_db")
class TestAmendmentChain(BaseTestCase):

    STOCK_FIRST_F1 = {
        'committee_id': 'C006',
        'report_year': 2018,
        'amendment_indicator': 'N',
        'receipt_date': datetime.date(2018, 1, 31),
        'file_number': 1180841,
        'amendment_chain': [1180841],
        'previous_file_number': 1180841,
        'most_recent_file_number': 1180841,
        'most_recent': True,
        'report_type': None,
        'form_type': 'F1',
    }
    STOCK_SECOND_F1 = {
        'committee_id': 'C006',
        'report_year': 2018,
        'amendment_indicator': 'A',
        'receipt_date': datetime.date(2018, 2, 28),
        'file_number': 1180862,
        'amendment_chain': [1180841, 1180862],
        'previous_file_number': 1180841,
        'most_recent_file_number': 1180862,
        'most_recent': True,
        'report_type': None,
        'form_type': 'F1',
    }

    def setUp(self):
        super().setUp()
        self.longMessage = True
        self.maxDiff = None
        self.request_context = rest.app.test_request_context()
        self.request_context.push()
        self.connection = rest.db.engine.connect()

    def tearDown(self):
        rest.db.session.remove()
        self.request_context.pop()
        self.clear_test_data()
        super().tearDown()

    # _response and _results from APIBaseCase
    def _response(self, qry):
        response = self.app.get(qry)
        self.assertEquals(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        self.assertNotEqual(result, [], "Empty response!")
        self.assertEqual(result['api_version'], __API_VERSION__)
        return result

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_simple_first_filing(self):
        expected_filing = self.STOCK_FIRST_F1
        self.create_filing(1, expected_filing)

        # Refresh downstream `ofec_amendments_mv` and `ofec_filings_all_mv`
        manage.refresh_materialized(concurrent=False)

        # FilingsList view
        # /filings/ endpoint

        results = self._results(
            rest.api.url_for(FilingsList, committee_id=expected_filing['committee_id'])
        )
        assert len(results) == 1
        list_result = results[0]

        self.assert_filings_equal(list_result, expected_filing)

        # FilingsView view
        # /committee/<committee_id>/filings/ and /candidate/<candidate_id>/filings/

        results = self._results(
            rest.api.url_for(FilingsView, committee_id=expected_filing['committee_id'])
        )
        assert len(results) == 1
        view_result = results[0]

        self.assert_filings_equal(view_result, expected_filing)

    def test_simple_amended_filing(self):
        expected_filing = self.STOCK_SECOND_F1

        self.create_filing(1, self.STOCK_FIRST_F1)
        self.create_filing(2, expected_filing)

        # Refresh downstream `ofec_amendments_mv` and `ofec_filings_all_mv`
        manage.refresh_materialized(concurrent=False)

        # /filings/ endpoint

        results = self._results(
            rest.api.url_for(
                FilingsList,
                committee_id=expected_filing['committee_id'],
                most_recent=True,
            )
        )
        assert len(results) == 1
        list_result = results[0]

        self.assert_filings_equal(list_result, expected_filing)

        # FilingsView view
        # /committee/<committee_id>/filings/ and /candidate/<candidate_id>/filings/

        results = self._results(
            rest.api.url_for(
                FilingsView,
                committee_id=expected_filing['committee_id'],
                most_recent=True,
            )
        )
        assert len(results) == 1
        view_result = results[0]

        self.assert_filings_equal(view_result, expected_filing)

    def test_multiple_form_3s(self):
        form_3_q2_new = {
            'committee_id': 'C006',
            'report_year': 2018,
            'amendment_indicator': 'N',
            'receipt_date': datetime.date(2018, 7, 15),
            'file_number': 20001,
            'amendment_chain': [20001],
            'previous_file_number': 20001,
            'most_recent_file_number': 20003,
            'most_recent': False,
            'report_type': 'Q2',
            'form_type': 'F3',
        }
        form_3_q2_amend_1 = {
            'committee_id': 'C006',
            'report_year': 2018,
            'amendment_indicator': 'A',
            'receipt_date': datetime.date(2018, 8, 15),
            'file_number': 20002,
            'amendment_chain': [20001, 20002],
            'previous_file_number': 20001,
            'most_recent_file_number': 20003,
            'most_recent': False,
            'report_type': 'Q2',
            'form_type': 'F3',
        }
        form_3_q3_new = {
            'committee_id': 'C006',
            'report_year': 2018,
            'amendment_indicator': 'N',
            'receipt_date': datetime.date(2018, 10, 15),
            'file_number': 30001,
            'amendment_chain': [30001],
            'previous_file_number': 30001,
            'most_recent_file_number': 30002,
            'most_recent': False,
            'report_type': 'Q3',
            'form_type': 'F3',
        }
        form_3_q3_amend_1 = {
            'committee_id': 'C006',
            'report_year': 2018,
            'amendment_indicator': 'A',
            'receipt_date': datetime.date(2018, 11, 15),
            'file_number': 30002,
            'amendment_chain': [30001, 30002],
            'previous_file_number': 30001,
            'most_recent_file_number': 30002,
            'most_recent': True,
            'report_type': 'Q3',
            'form_type': 'F3',
        }
        form_3_q2_amend_2 = {
            'committee_id': 'C006',
            'report_year': 2018,
            'amendment_indicator': 'A',
            'receipt_date': datetime.date(2018, 12, 15),
            'file_number': 20003,
            'amendment_chain': [20001, 20002, 20003],
            'previous_file_number': 20002,
            'most_recent_file_number': 20003,
            'most_recent': True,
            'report_type': 'Q2',
            'form_type': 'F3',
        }
        self.create_filing(1, form_3_q2_new)
        self.create_filing(2, form_3_q2_amend_1)
        self.create_filing(3, form_3_q3_new)
        self.create_filing(4, form_3_q3_amend_1)
        self.create_filing(5, form_3_q2_amend_2)

        # Refresh downstream `ofec_amendments_mv` and `ofec_filings_all_mv`
        manage.refresh_materialized(concurrent=False)

        q2_results = self._results(
            rest.api.url_for(
                FilingsList,
                committee_id=form_3_q2_new['committee_id'],
                report_type='Q2',
            )
        )

        for result in q2_results:
            for filing in (form_3_q2_new, form_3_q2_amend_1, form_3_q2_amend_2):
                if result['file_number'] == filing['file_number']:
                    self.assert_filings_equal(result, filing)

        q3_results = self._results(
            rest.api.url_for(
                FilingsList,
                committee_id=form_3_q3_new['committee_id'],
                report_type='Q3',
            )
        )

        for result in q3_results:
            for filing in (form_3_q3_new, form_3_q3_amend_1):
                if result['file_number'] == filing['file_number']:
                    self.assert_filings_equal(result, filing)

    def test_multiple_form_1s(self):
        first_f1 = {
            'committee_id': 'C006',
            'report_year': 2018,
            'amendment_indicator': 'N',
            'receipt_date': datetime.date(2018, 1, 31),
            'file_number': 1111,
            'amendment_chain': [1111],
            'previous_file_number': 1111,
            'most_recent_file_number': 3333,
            'most_recent': False,
            'report_type': None,
            'form_type': 'F1',
        }
        second_f1 = {
            'committee_id': 'C006',
            'report_year': 2018,
            'amendment_indicator': 'A',
            'receipt_date': datetime.date(2018, 2, 28),
            'file_number': 2222,
            'amendment_chain': [1111, 2222],
            'previous_file_number': 1111,
            'most_recent_file_number': 3333,
            'most_recent': False,
            'report_type': None,
            'form_type': 'F1',
        }
        third_f1 = {
            'committee_id': 'C006',
            'report_year': 2018,
            'amendment_indicator': 'A',
            'receipt_date': datetime.date(2018, 3, 28),
            'file_number': 3333,
            'amendment_chain': [1111, 2222, 3333],
            'previous_file_number': 2222,
            'most_recent_file_number': 3333,
            'most_recent': True,
            'report_type': None,
            'form_type': 'F1',
        }
        unusual_entry_for_second_f1 = copy.deepcopy(second_f1)
        unusual_entry_for_second_f1[
            'previous_file_number'
        ] = unusual_entry_for_second_f1['file_number']

        self.create_filing(1, first_f1)
        self.create_filing(2, unusual_entry_for_second_f1)
        self.create_filing(3, third_f1)

        # Refresh downstream `ofec_amendments_mv` and `ofec_filings_all_mv`
        manage.refresh_materialized(concurrent=False)

        results = self._results(
            rest.api.url_for(FilingsList, committee_id=first_f1['committee_id'])
        )

        for result in sorted(results, key=lambda x: x['file_number']):
            for filing in (first_f1, unusual_entry_for_second_f1, third_f1):
                if result['file_number'] == filing['file_number']:
                    self.assert_filings_equal(result, filing)
                    # Note: we're leaving data-entered previous_file_number alone
                    assert (
                        result['previous_file_number'] == filing['previous_file_number']
                    )

    def test_negative_filing_chain(self):
        # Make sure no negative numbers appear in amendment chain
        negative_f1 = {
            'committee_id': 'C006',
            'report_year': 2018,
            'amendment_indicator': 'N',
            'receipt_date': datetime.date(2018, 1, 31),
            'file_number': -1180841,
            'amendment_chain': None,
            'previous_file_number': -1180841,
            'most_recent_file_number': None,
            'most_recent': None,
            'report_type': None,
            'form_type': 'F1',
        }

        non_negative_f1 = copy.deepcopy(self.STOCK_FIRST_F1)

        self.create_filing(1, negative_f1)
        self.create_filing(2, non_negative_f1)

        # Refresh downstream `ofec_amendments_mv` and `ofec_filings_all_mv`
        manage.refresh_materialized(concurrent=False)

        results = self._results(
            rest.api.url_for(
                FilingsList,
                committee_id=non_negative_f1['committee_id'],
                most_recent=True,
            )
        )
        assert len(results) == 1

        result = results[0]
        self.assert_filings_equal(result, non_negative_f1)

    def create_filing(self, sub_id, expected_filing):
        self.connection.execute(
            "INSERT INTO disclosure.f_rpt_or_form_sub (sub_id, cand_cmte_id, form_tp, rpt_yr, rpt_tp, amndt_ind, receipt_dt, file_num, prev_file_num) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
            sub_id,
            expected_filing['committee_id'],
            expected_filing['form_type'],
            expected_filing['report_year'],
            expected_filing['report_type'],
            expected_filing['amendment_indicator'],
            int(expected_filing['receipt_date'].strftime("%Y%m%d")),
            expected_filing['file_number'],
            expected_filing['previous_file_number'],
        )

    def assert_filings_equal(self, api_result, expected_filing):
        assert api_result['committee_id'] == expected_filing['committee_id']
        assert api_result['report_year'] == expected_filing['report_year']
        assert (
            api_result['amendment_indicator'] == expected_filing['amendment_indicator']
        )
        assert (
            api_result['receipt_date'][:10]
            == expected_filing['receipt_date'].isoformat()
        )
        assert api_result['file_number'] == expected_filing['file_number']
        assert api_result['amendment_chain'] == expected_filing['amendment_chain']
        assert (
            api_result['most_recent_file_number']
            == expected_filing['most_recent_file_number']
        )
        assert api_result['most_recent'] == expected_filing['most_recent']
        assert api_result['report_type'] == expected_filing['report_type']
        assert api_result['form_type'] == expected_filing['form_type']

    def clear_test_data(self):
        tables = [('disclosure', 'f_rpt_or_form_sub')]
        for table in tables:
            self.connection.execute("DELETE FROM {0}.{1}".format(table[0], table[1]))
