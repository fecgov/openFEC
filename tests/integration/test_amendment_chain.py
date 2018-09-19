import pytest
import codecs
import json
import datetime

import manage
from tests.common import BaseTestCase
from webservices import rest, __API_VERSION__
from webservices.resources.filings import FilingsView, FilingsList, EFilingsView


@pytest.mark.usefixtures("migrate_db")
class TestAmendmentChain(BaseTestCase):
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
        print(qry)
        self.assertEquals(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        self.assertNotEqual(result, [], "Empty response!")
        self.assertEqual(result['api_version'], __API_VERSION__)
        print(result)
        return result

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_simple_first_filing(self):
        expected_filing = {
            'committee_id': 'C00639013',
            'report_year': 2017,
            'amendment_indicator': 'N',
            'receipt_date': datetime.date(2018, 1, 31),
            'file_number': 1180841,
            'amendment_chain': [1180841],
            'previous_file_number': 1180841,
            'most_recent_file_number': 1180841,
            'most_recent': True,
            'report_type': None,
            'form_type': 'F1'
        }
        self.create_filing(
            1,
            expected_filing['committee_id'],
            expected_filing['form_type'],
            expected_filing['report_year'],
            expected_filing['report_type'],
            expected_filing['amendment_indicator'],
            expected_filing['receipt_date'],
            expected_filing['file_number'],
            expected_filing['previous_file_number']
        )
        # Refresh upstream `ofec_amendments_mv` and `ofec_filings_all_mv`
        manage.refresh_materialized(concurrent=False)

        results = self._results(rest.api.url_for(FilingsList, committee_id=expected_filing['committee_id']))
        result = results[0]

        assert result['committee_id'] == expected_filing['committee_id']
        assert result['report_year'] == expected_filing['report_year']
        assert result['amendment_indicator'] == expected_filing['amendment_indicator']
        assert result['receipt_date'][:10] == expected_filing['receipt_date'].isoformat()
        assert result['file_number'] == expected_filing['file_number']
        assert result['amendment_chain'] == expected_filing['amendment_chain']
        assert result['previous_file_number'] == expected_filing['previous_file_number']
        assert result['most_recent_file_number'] == expected_filing['most_recent_file_number']
        assert result['most_recent'] == expected_filing['most_recent']
        assert result['report_type'] == expected_filing['report_type']
        assert result['form_type'] == expected_filing['form_type']

    def create_filing(self, sub_id, cand_cmte_id, form_type, report_year, report_type, is_amendment, receipt_date, file_number, previous_file_number):
        self.connection.execute(
            "INSERT INTO disclosure.f_rpt_or_form_sub (sub_id, cand_cmte_id, form_tp, rpt_yr, rpt_tp, amndt_ind, receipt_dt, file_num, prev_file_num) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)", sub_id, cand_cmte_id, form_type, report_year, report_type, is_amendment, int(receipt_date.strftime("%Y%m%d")), file_number, previous_file_number)

    def clear_test_data(self):
        tables = [
            ('disclosure', 'f_rpt_or_form_sub')
        ]
        for table in tables:
            self.connection.execute("DELETE FROM {0}.{1}".format(table[0], table[1]))
