import json
import unittest

from .tests.common import ApiBaseTest


class OverallTest(ApiBaseTest):
    # Candidate
    def test_header_info(self):
        response = self._response('/candidates')
        self.assertIn('api_version', response)
        self.assertIn('pagination', response)

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_full_text_search(self):
        # changed from 'james' to 'arnold' because 'james' falls victim to stemming, and some results return 'jame' causing the assert to fail
        results = self._results('/candidates?q=arnold')
        for r in results:
            #txt = json.dumps(r).lower()
            self.assertIn('arnold', r['name'].lower())

    def test_full_text_search_with_whitespace(self):
        results = self._results('/candidates?q=barack obama')
        for r in results:
            txt = json.dumps(r).lower()
            self.assertIn('obama', txt)

    def test_full_text_no_results(self):
        results = self._results('/candidates?q=asdlkflasjdflkjasdl;kfj')
        self.assertEquals(results, [])

    def test_year_filter(self):
        results = self._results('/candidates?year=1988')
        for r in results:
            self.assertIn(1988, r['election_years'])

    def test_per_page_defaults_to_20(self):
        results = self._results('/candidates')
        self.assertEquals(len(results), 20)

    def test_per_page_param(self):
        results = self._results('/candidates?per_page=5')
        self.assertEquals(len(results), 5)

    def test_invalid_per_page_param(self):
        response = self.app.get('/candidates?per_page=-10')
        self.assertEquals(response.status_code, 400)
        response = self.app.get('/candidates?per_page=34.2')
        self.assertEquals(response.status_code, 400)
        response = self.app.get('/candidates?per_page=dynamic-wombats')
        self.assertEquals(response.status_code, 400)

    def test_page_param(self):
        page_one_and_two = self._results('/candidates?per_page=10&page=1')
        page_two = self._results('/candidates?per_page=5&page=2')
        self.assertEqual(page_two[0], page_one_and_two[5])
        for itm in page_two:
            self.assertIn(itm, page_one_and_two)


    @unittest.skip("We are just showing one year at a time, this would be a good feature for /candidate/<id> but it is not a priority right now")
    def test_multi_year(self):
        # testing search
        response = self._results('/candidate?candidate_id=P80003338&year=2012,2008')
        # search listing should aggregate years
        self.assertIn('2008, 2012', response)
        # testing single resource
        response = self._results('/candidate/P80003338?year=2012,2008')
        elections = response[0]['elections']
        self.assertEquals(len(elections), 2)

    @unittest.skip("We are just showing one year at a time, this would be a good feature for /candidate/<id> but it is not a priority right now")
    def test_multi_year(self):
        # testing search
        response = self._results('/candidates?candidate_id=P80003338&year=2012,2008')
        # search listing should aggregate years
        self.assertIn('2008, 2012', response)
        # testing single resource
        response = self._results('/candidate/P80003338?year=2012,2008')
        elections = response[0]['elections']
        self.assertEquals(len(elections), 2)

    def test_cand_filters(self):
        # checking one example from each field
        orig_response = self._response('/candidates')
        original_count = orig_response['pagination']['count']

        filter_fields = (
            ('office','H'),
            ('district', '00,02'),
            ('state', 'CA'),
            ('name', 'Obama'),
            ('party', 'DEM'),
            ('year', '2012,2014'),
            ('candidate_id', 'H0VA08040,P80003338'),
        )

        for field, example in filter_fields:
            page = "/candidates?%s=%s" % (field, example)
            print(page)
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])


    def test_name_endpoint_returns_unique_candidates_and_committees(self):
        results = self._results('/names?q=obama')
        cand_ids = [r['candidate_id'] for r in results if r['candidate_id']]
        self.assertEqual(len(cand_ids), len(set(cand_ids)))
        cmte_ids = [r['committee_id'] for r in results if r['committee_id']]
        self.assertEqual(len(cmte_ids), len(set(cmte_ids)))


    @unittest.skip('This is not a great view anymore')
    def test_multiple_cmtes_in_detail(self):
        response = self._results('/candidate/P80003338/committees')
        self.assertEquals(len(response[0]), 11)
        self.assertEquals(response['pagination']['count'], 11)

# Totals
    @unittest.skip("not implemented yet")
    def test_reports_house_senate(self):
        results = self._results('/committee/C00002600/reports')

        fields = ('beginning_image_number', 'end_image_number', 'expire_date', 'load_date','report_type', 'report_type_full','report_year', 'type', 'cash_on_hand_beginning_period', 'cash_on_hand_end_period', 'debts_owed_by_committee', 'debts_owed_to_committee', 'operating_expenditures_period', 'other_political_committee_contributions_period', 'refunds_other_political_committee_contributions_period', 'total_disbursements_period', 'total_individual_contributions_period', 'total_receipts_period',)

        for field in fields:
            print(field)
            self.assertEquals(field in results[0]['reports'][0], True)

    @unittest.skip("not implemented yet")
    def test_reports_pac_party(self):
        results = self._results('/committee/C00000422/reports')

        fields = ('beginning_image_number', 'end_image_number', 'expire_date', 'load_date', 'report_type', 'report_type_full', 'report_year', 'total_disbursements_period', 'total_disbursements_summary_page_period', 'total_receipts_period', 'total_receipts_summary_page_period', 'type')

        for field in fields:
            print(field)
            self.assertEquals(field in results[0]['reports'][0], True)

    @unittest.skip("not implemented yet")
    def test_reports_presidental(self):
        results = self._results('/committee/C00347583/reports')

        fields = ('refunds_political_party_committee_contributions_period', 'other_receipts_period', 'total_disbursements_period', 'net_contributions_year', 'beginning_image_number', 'total_receipts_year', 'total_receipts', 'refunds_political_party_committee_contributions_year', 'total_loans_period', 'other_political_committee_contributions_year', 'loan_repayments_other_loans_period', 'net_contributions_period', 'refunds_other_political_committee_contributions_period', 'all_other_loans_year', 'net_operating_expenditures_period', 'loan_repayments_other_loans_year', 'total_individual_itemized_contributions_year', 'subtotal_period', 'other_receipts_year', 'total_contribution_refunds_col_total_period', 'debts_owed_by_committee', 'total_contribution_refunds_year', 'offsets_to_operating_expenditures_period', 'cash_on_hand_beginning_period', 'individual_itemized_contributions_period', 'refunds_individual_contributions_year', 'total_contributions_year', 'operating_expenditures_period', 'political_party_committee_contributions_year', 'total_individual_contributions_year', 'total_individual_unitemized_contributions_year', 'net_operating_expenditures_year', 'expire_date', 'individual_unitemized_contributions_period', 'transfers_to_other_authorized_committee_year', 'report_type', 'total_disbursements_year', 'type', 'operating_expenditures_year', 'transfers_from_other_authorized_committee_period', 'total_offsets_to_operating_expenditures_year', 'total_loan_repayments_year', 'candidate_contribution_year', 'refunds_other_political_committee_contributions_year', 'debts_owed_to_committee', 'other_disbursements_year', 'total_loan_repayments_period', 'candidate_contribution_period', 'transfers_to_other_authorized_committee_period', 'refunds_total_contributions_col_total_year', 'total_contributions_column_total_period', 'political_party_committee_contributions_period', 'cash_on_hand_end_period', 'all_other_loans_period', 'loans_made_by_candidate_year', 'total_individual_contributions_period', 'loans_made_by_candidate_period', 'total_offsets_to_operating_expenditures_period', 'offsets_to_operating_expenditures_year', 'total_contribution_refunds_period', 'report_year', 'total_loans_year', 'transfers_from_other_authorized_committee_year', 'load_date', 'other_disbursements_period', 'loan_repayments_candidate_loans_period', 'other_political_committee_contributions_period', 'total_receipts_period', 'total_contributions_period', 'end_image_number', 'refunds_individual_contributions_period', 'loan_repayments_candidate_loans_year', 'total_operating_expenditures_year', 'total_operating_expenditures_period', 'report_type_full', 'election_cycle',
            )

        for field in fields:
            print(field)
            self.assertEquals(field in results[0]['reports'][0], True)

    @unittest.skip("Not implementing for now.")
    def test_total_field_filter(self):
        results_disbursements = self._results('/committee/C00347583/totals?fields=disbursements')
        results_recipts = self._results('/committee/C00347583/totals?fields=total_receipts_period')

        self.assertIn('disbursements', results_disbursements[0]['totals'][0])
        self.assertIn('total_receipts_period',results_recipts[0]['reports'][0])
        self.assertNotIn('reports', results_disbursements[0])
        self.assertNotIn('totals', results_recipts[0])

    @unittest.skip("Not implementing for now.")
    def test_total_cycle(self):
        results1 = self._results('/committee/C00000422/totals?year=2004')
        total_receipts1 = results1[0]['receipts']

        results2 = self._results('/committee/C00000422/totals?year=2006')
        total_receipts2 = results2[0]['receipts']

        self.assertGreater(total_receipts2, total_receipts1)

    @unittest.skip("Not implementing for now.")
    def test_multiple_committee(self):
        results = self._results('/total?committee_id=C00002600,C00000422&fields=committtee_id')
        print(len(results))
        self.assertEquals(len(results), 2)


    # Typeahead name search
    def test_typeahead_name_search(self):
        results = self._results('/names?q=oba')
        self.assertGreaterEqual(len(results), 10)
        for r in results:
            self.assertIn('OBA', r['name'])


