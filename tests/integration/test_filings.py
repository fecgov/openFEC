import pytest
import codecs
import json

import manage
from tests.common import BaseTestCase
from webservices import rest, __API_VERSION__
from webservices.resources.filings import FilingsView, FilingsList


@pytest.mark.usefixtures("migrate_db")
class TestFilings(BaseTestCase):

    committee = {
        'valid_fec_yr_id': 1,
        'committee_id': 'C001',
        'fec_election_yr': 1996,
        'committee_type': 'H',
        'date_entered': 'now()',
    }

    FIRST_FILING = {
        'cand_cmte_id': 'C001',
        'report_year': 1996,
        'form_type': 'F1',
        'begin_image_num': '95039770818',
        'pdf_url': 'https://docquery.fec.gov/pdf/818/95039770818/95039770818.pdf'
    }

    SECOND_FILING = {
        'cand_cmte_id': 'P001',
        'report_year': 1994,
        'form_type': 'F2',
        'begin_image_num': '95030061615',
        'pdf_url': 'https://docquery.fec.gov/pdf/615/95030061615/95030061615.pdf'
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
        self.assertEqual(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        self.assertNotEqual(result, [], "Empty response!")
        self.assertEqual(result['api_version'], __API_VERSION__)
        return result

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_f1_pdf_url(self):
        expected_filing = self.FIRST_FILING
        self.insert_committee(self.committee)
        self.insert_filing(100, expected_filing)

        # Refresh `ofec_filings_all_mv`
        manage.refresh_materialized(concurrent=False)

        # FilingsList view
        # /filings/ endpoint
        results = self._results(
            rest.api.url_for(FilingsList, committee_id=expected_filing['cand_cmte_id'])
        )
        assert len(results) == 1
        list_result = results[0]

        self.assert_filings_equal(list_result, expected_filing)

        # FilingsView view
        # /committee/<committee_id>/filings/ and /candidate/<candidate_id>/filings/
        results = self._results(
            rest.api.url_for(FilingsView, committee_id=expected_filing['cand_cmte_id'])
        )
        assert len(results) == 1
        view_result = results[0]

        self.assert_filings_equal(view_result, expected_filing)

    def test_f2_pdf_url(self):
        expected_filing = self.SECOND_FILING
        self.insert_filing(101, expected_filing)

        # Refresh `ofec_filings_all_mv`
        manage.refresh_materialized(concurrent=False)

        # FilingsList view
        # /filings/ endpoint
        results = self._results(
            rest.api.url_for(FilingsList, candidate_id=expected_filing['cand_cmte_id'])
        )
        assert len(results) == 1
        list_result = results[0]

        self.assert_filings_equal(list_result, expected_filing)

        # FilingsView view
        # /committee/<committee_id>/filings/ and /candidate/<candidate_id>/filings/
        results = self._results(
            rest.api.url_for(FilingsView, candidate_id=expected_filing['cand_cmte_id'])
        )
        assert len(results) == 1
        view_result = results[0]

        self.assert_filings_equal(view_result, expected_filing)

    def insert_committee(self, committee):
        self.connection.execute(
            "INSERT INTO disclosure.cmte_valid_fec_yr \
            (valid_fec_yr_id, cmte_id, fec_election_yr, cmte_tp, date_entered) "
            "VALUES (%s, %s, %s, %s, %s)",
            committee['valid_fec_yr_id'],
            committee['committee_id'],
            committee['fec_election_yr'],
            committee['committee_type'],
            committee['date_entered'],
        )

    def insert_filing(self, sub_id, expected_filing):
        self.connection.execute(
            "INSERT INTO disclosure.f_rpt_or_form_sub \
            (sub_id, cand_cmte_id, form_tp, rpt_yr, begin_image_num) "
            "VALUES (%s, %s, %s, %s, %s)",
            sub_id,
            expected_filing['cand_cmte_id'],
            expected_filing['form_type'],
            expected_filing['report_year'],
            expected_filing['begin_image_num'],
        )

    def assert_filings_equal(self, api_result, expected_filing):
        assert api_result['report_year'] == expected_filing['report_year']
        assert api_result['form_type'] == expected_filing['form_type']
        assert api_result['pdf_url'] == expected_filing['pdf_url']

    def clear_test_data(self):
        tables = ["cmte_valid_fec_yr", "f_rpt_or_form_sub"]
        for table in tables:
            self.connection.execute("DELETE FROM disclosure.{}".format(table))
