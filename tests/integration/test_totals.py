import codecs
import pytest
import json

import manage

from tests import common
from webservices import rest, __API_VERSION__
from webservices.rest import db
from webservices.resources.totals import CandidateTotalsView, TotalsCommitteeView

@pytest.mark.usefixtures("migrate_db")
class TotalTestCase(common.BaseTestCase):
    def setUp(self):
        super().setUp()
        self.longMessage = True
        self.maxDiff = None
        self.request_context = rest.app.test_request_context()
        self.request_context.push()
        self.connection = db.engine.connect()

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

    def test_cand_and_cmte_totals(self):
        cmte_valid_fec_yr_data = [
            {
                'valid_fec_yr_id': 1,
                'cmte_id': 'C001',
                'fec_election_yr': 2020,
                'cmte_tp': 'P',
                'cmte_dsgn': 'P',
                'date_entered': 'now()',
            },
            {
                'valid_fec_yr_id': 2,
                'cmte_id': 'C002',
                'fec_election_yr': 2020,
                'cmte_tp': 'P',
                'cmte_dsgn': 'A',
                'date_entered': 'now()',
            },
        ]
        self.create_cmte_valid(cmte_valid_fec_yr_data)

        cand_cmte_linkage_data = [
            {
                'linkage_id': 1,
                'cand_id': 'P01',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cmte_id': 'C001',
                'cmte_count_cand_yr': 1,
                'cmte_tp': 'P',
                'cmte_dsgn': 'P',
                'linkage_type': 'P',
                'date_entered': 'now()',
            },
            {
                'linkage_id': 3,
                'cand_id': 'P01',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cmte_id': 'C002',
                'cmte_count_cand_yr': 1,
                'cmte_tp': 'P',
                'cmte_dsgn': 'A',
                'linkage_type': 'A',
                'date_entered': 'now()',
            },
        ]
        self.create_cand_cmte_linkage(cand_cmte_linkage_data)

        filing_f3p_q1 = {
            'committee_id': 'C001',
            'report_year': 2019,
            'file_number': 10001,
            'ttl_receipts': 100,
            'ttl_disb': 30,
            'form_type': 'F3P',
            'sub_id': 1,
            'rpt_year': 2019
        }
        filing_f3x_q2 = {
            'committee_id': 'C001',
            'report_year': 2019,
            'file_number': 10002,
            'ttl_receipts': 200,
            'ttl_disb': 50,
            'form_type': 'F3X',
            'sub_id': 2,
            'rpt_year': 2019
        }
        filing_f3_q1 = {
            'committee_id': 'C002',
            'report_year': 2019,
            'file_number': 10004,
            'ttl_receipts': 11,
            'ttl_disb': 5,
            'form_type': 'F3',
            'sub_id': 3,
            'rpt_year': 2019
        }
        self.insert_vsum(filing_f3p_q1)
        self.insert_vsum(filing_f3x_q2)
        self.insert_vsum(filing_f3_q1)

        manage.refresh_materialized(concurrent=False)

        """
        To test the committee totals if committee filed wrong type of form.
        """
        params_cmte = {
            'committee_id': 'C001',
        }
        committee_totals_api = self._results(
            rest.api.url_for(TotalsCommitteeView, **params_cmte)
        )

        assert (len(committee_totals_api) == 1)
        assert committee_totals_api[0]['receipts'] == 300
        assert committee_totals_api[0]['disbursements'] == 80

        """
        To test the candidate totals that includes all the committees even filing wrong form
        """
        params_cand = {
            'candidate_id': 'P01',
            'election_full': True,
        }
        candidate_totals_api = self._results(
            rest.api.url_for(CandidateTotalsView, **params_cand)
        )

        assert (len(candidate_totals_api) == 1)
        assert candidate_totals_api[0]['receipts'] == 311
        assert candidate_totals_api[0]['disbursements'] == 85

    def create_cmte_valid(self, committee_data):
        sql_insert = (
            "INSERT INTO disclosure.cmte_valid_fec_yr"
            "(valid_fec_yr_id, cmte_id, fec_election_yr, cmte_tp, cmte_dsgn, date_entered)"
            "VALUES (%(valid_fec_yr_id)s, %(cmte_id)s, %(fec_election_yr)s, %(cmte_tp)s, "
            "%(cmte_dsgn)s, %(date_entered)s)"
        )
        self.connection.execute(sql_insert, committee_data)

    def insert_vsum(self, filing):
        self.connection.execute(
            """
            INSERT INTO disclosure.v_sum_and_det_sum_report
            (orig_sub_id, form_tp_cd, cmte_id, file_num, ttl_receipts, ttl_disb, rpt_yr)
            VALUES (%s, %s, %s, %s, %s, %s, %s)""",
            filing['sub_id'],
            filing['form_type'],
            filing['committee_id'],
            filing['file_number'],
            filing['ttl_receipts'],
            filing['ttl_disb'],
            filing['rpt_year']
        )
        
    def create_cand_cmte_linkage(self, linkage_data):
        sql_insert = (
            "INSERT INTO disclosure.cand_cmte_linkage "
            "(linkage_id, cand_id, fec_election_yr, cand_election_yr, "
            "cmte_id, cmte_count_cand_yr, cmte_tp, cmte_dsgn, linkage_type, date_entered) "
            "VALUES (%(linkage_id)s, %(cand_id)s, "
            "%(fec_election_yr)s, %(cand_election_yr)s, %(cmte_id)s, %(cmte_count_cand_yr)s, "
            "%(cmte_tp)s, %(cmte_dsgn)s, %(linkage_type)s, %(date_entered)s)"
        )
        self.connection.execute(sql_insert, linkage_data)
