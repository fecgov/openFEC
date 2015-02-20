import json
import unittest

from .tests.common import ApiBaseTest


class OverallTest(ApiBaseTest):
    # Candidate
    def test_header_info(self):
        response = self._response('/candidate')
        self.assertIn('api_version', response)
        self.assertIn('pagination', response)


    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_full_text_search(self):
        # changed from 'james' to 'arnold' because 'james' falls victim to stemming, and some results return 'jame' causing the assert to fail
        results = self._results('/candidate?q=arnold&fields=*')
        for r in results:
            #txt = json.dumps(r).lower()
            self.assertIn('arnold', r['name'].lower())

    def test_full_text_search_with_whitespace(self):
        results = self._results('/candidate?q=barack obama&fields=*')
        for r in results:
            txt = json.dumps(r).lower()
            self.assertIn('obama', txt)

    def test_full_text_no_results(self):
        results = self._results('/candidate?q=asdlkflasjdflkjasdl;kfj')
        self.assertEquals(results, [])

    def test_year_filter(self):
        results = self._results('/candidate?year=1988&fields=*')
        for r in results:
            self.assertEqual(r.get('active_through'), 1988)

    def test_per_page_defaults_to_20(self):
        results = self._results('/candidate')
        self.assertEquals(len(results), 20)

    def test_per_page_param(self):
        results = self._results('/candidate?per_page=5')
        self.assertEquals(len(results), 5)

    def test_invalid_per_page_param(self):
        response = self.app.get('/candidate?per_page=-10')
        self.assertEquals(response.status_code, 400)
        response = self.app.get('/candidate?per_page=34.2')
        self.assertEquals(response.status_code, 400)
        response = self.app.get('/candidate?per_page=dynamic-wombats')
        self.assertEquals(response.status_code, 400)

    def test_page_param(self):
        page_one_and_two = self._results('/candidate?per_page=10&page=1')
        page_two = self._results('/candidate?per_page=5&page=2')
        self.assertEqual(page_two[0], page_one_and_two[5])
        for itm in page_two:
            self.assertIn(itm, page_one_and_two)

    ### Candidates ###
    def test_fields(self):
        # testing key defaults
        response = self._results('/candidate/P80003338?year=2008')
        response= response[0]

        self.assertEquals(response['name']['full_name'], 'OBAMA, BARACK')

        fields = ('party_affiliation', 'primary_committee', 'state', 'district', 'incumbent_challenge_full', 'incumbent_challenge', 'candidate_status', 'office_sought', 'election_year', 'primary_committee')

        election = response['elections'][0]
        for field in fields:
            print field
            print election[field]
            self.assertEquals(election.has_key(field), True)

        # not in default fields
        self.assertEquals(response['elections'][0].has_key('affiliated_committees'), False)
        self.assertEquals(response.has_key('mailing_addresses'), False)
        # making sure primary committee is in the right bucket
        self.assertEquals(response['elections'][0]['primary_committee']['designation'], 'P')

    def test_extra_fields(self):
        response = self._results('/candidate/P80003338?fields=mailing_addresses,affiliated_committees')
        self.assertIn('C00434357', [c['committee_id'] for c in response[0]['elections'][0]['affiliated_committees']])
        self.assertIn('233 NORTH MICHIGAN AVE STE 1720', [a['street_1'] for a in response[0]['mailing_addresses']])
        self.assertEquals(response[0].has_key('candidate_id'), False)
        self.assertEquals(response[0].has_key('name'), False)

    def test_candidate_committes(self):
        response = self._results('/candidate/P80003338?fields=affiliated_committees')

        fields = ('committee_id', 'designation', 'designation_full', 'type', 'type_full', 'election_year', 'committee_name')

        election = response[0]['elections'][0]
        print election
        for field in fields:
            print field
            self.assertEquals(election['primary_committee'].has_key(field), True)
            self.assertEquals(election['affiliated_committees'][0].has_key(field), True)

    @unittest.skip("Year aggregation needs to be implemented.")
    def test_years_all(self):
        # testing search
        response = self._results('/candidate?candidate_id=P80003338&year=*')
        elections = response[0]['elections']
        self.assertEquals(len(elections), 2)
        # testing single resource
        response = self._results('/candidate/P80003338?year=*')
        elections = response[0]['elections']
        self.assertEquals(len(elections), 2)


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

    def test_year_default(self):
        # we are currently defaulting to last 4 years
        # also the test data is weird but it should still work for this purpose
        results = self._results('/candidate/H0VA08040')
        self.assertNotIn('elections', results)

        results = self._results('/candidate/H0VA08040?year=1996,1998')
        elections = results[0]['elections']
        self.assertEquals(len(elections), 2)

    def test_cand_filters(self):
        # checking one example from each field
        orig_response = self._response('/candidate')
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
            page = "/candidate?%s=%s" % (field, example)
            print page
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])


    def test_name_endpoint_returns_unique_candidates_and_committees(self):
        results = self._results('/name?q=obama')
        cand_ids = [r['candidate_id'] for r in results if r['candidate_id']]
        self.assertEqual(len(cand_ids), len(set(cand_ids)))
        cmte_ids = [r['committee_id'] for r in results if r['committee_id']]
        self.assertEqual(len(cmte_ids), len(set(cmte_ids)))



#Committee
    def test_committee_search_fields(self):
        # example with committee
        response = self._response('/committee?committee_id=C00048587&year=*')
        result = response['results'][0]
        # main fields
        # original registration date doesn't make sense in this example, need to look into this more
        self.assertEqual(result['original_registration_date'], '1982-12-31 00:00:00')
        self.assertEqual(result['committee_type'], 'P')
        self.assertEqual(result['treasurer_name'], 'ROBERT J. LIPSHUTZ')
        self.assertEqual(result['party'], 'DEM')
        self.assertEqual(result['committee_type_full'], 'Presidential')
        self.assertEqual(result['name'], '1976 DEMOCRATIC PRESIDENTIAL CAMPAIGN COMMITTEE, INC. (PCC-1976 GENERAL ELECTION)')
        self.assertEqual(result['committee_id'], 'C00048587')
        self.assertEqual(result['designation_full'], 'Principal campaign committee')
        self.assertEqual(result['state'], 'GA')
        self.assertEqual(result['party_full'], 'Democratic Party')
        self.assertEqual(result['designation'], 'P')
        # no expired committees in test data to test just checking it exists
        self.assertEqual(result['expire_date'], None)
        # candidate fields
        candidate_result = response['results'][0]['candidates'][0]
        self.assertEqual(candidate_result['candidate_id'], 'P60000247')
        self.assertEqual(candidate_result['election_year'], 1976)
        self.assertEqual(candidate_result['link_date'], '2007-10-12 13:38:33')
        # Example with org type
        response = self._response('/committee?organization_type=C')
        results = response['results'][0]
        self.assertEqual(results['organization_type_full'], 'Corporation')
        self.assertEqual(results['organization_type'], 'C')

    def test_committee_search_double_committee_id(self):
        response = self._response('committee?committee_id=C00048587,C00116574&year=*')
        results = response['results']
        self.assertEqual(len(results), 2)

    def test_committee_search_filters(self):
        original_response = self._response('/committee')
        original_count = original_response['pagination']['count']

        party_response = self._response('/committee?party=REP')
        party_count = party_response['pagination']['count']
        self.assertEquals((original_count > party_count), True)

        committee_type_response = self._response('/committee?committee_type=P')
        committee_type_count = committee_type_response['pagination']['count']
        self.assertEquals((original_count > committee_type_count), True)

        name_response = self._response('/committee?name=Obama')
        name_count = name_response['pagination']['count']
        self.assertEquals((original_count > name_count), True)

        committee_id_response = self._response('/committee?committee_id=C00116574')
        committee_id_count = committee_id_response['pagination']['count']
        self.assertEquals((original_count > committee_id_count), True)

        designation_response = self._response('/committee?designation=P')
        designation_count = designation_response['pagination']['count']
        self.assertEquals((original_count > designation_count), True)

        state_response = self._response('/committee?state=CA')
        state_count = state_response['pagination']['count']
        self.assertEquals((original_count > state_count), True)



    def test_committee_cand_fields(self):
        # they were giving different responses
        response_1 = self._response('/committee/C00000851')
        result_1 = response_1['results'][0]['candidates'][0]

        fields = ('candidate_id', 'candidate_name', 'office_sought', 'designation', 'designation_full', 'election_years', 'expire_date', 'link_date', 'type', 'type_full')
        for field in fields:
            print field
            self.assertEquals(result_1.has_key(field), True)

    def test_committee_stats(self):
        response = self._response('/committee/C00000851')
        results = response['results']

        result = results[0]['status']
        fields = ('designation','designation_full', 'expire_date','load_date', 'receipt_date', 'type', 'type_full')
        for field in fields:
            print field
            self.assertEquals(result.has_key(field), True)

    def test_committee_properties_basic(self):
        response = self._response('/committee/C00000851')
        result = response['results'][0]

        fields = ('committee_id','expire_date','form_type','load_date','name','description','status', 'address')
        for field in fields:
            print field
            self.assertEquals(result.has_key(field), True)

        # Not a default field
        self.assertEquals(result.has_key('archive'), False)

    def test_committee_properties_all(self):
        response = self._response('/committee/C00000422?fields=*')
        result = response['results'][0]['archive']

        print result

        description_fields = ('form_type','expire_date','filing_frequency','load_date')
        for field in description_fields:
            print field
            self.assertEquals(result['description'][0].has_key(field), True)

        address_fields = ('city', 'state', 'state_full', 'street_1', 'zip', 'expire_date')
        for field in address_fields:
            print field
            self.assertEquals(response['results'][0]['address'].has_key(field), True)

        self.assertEquals(response['results'][0]['treasurer'].has_key('name_full'), True)
        self.assertEquals(response['results'][0]['treasurer'].has_key('expire_date'), True)

    def test2committees(self):
        response = self._results('/committee/C00484188?year=2012')
        self.assertEquals(len(response[0]['candidates']), 2)

    def test_committee_field_filtering(self):
        response = self._results('/committee/C00000851?fields=committee_id')
        print '\n%s\n' % response
        self.assertEquals(len(response[0]), 1)

    # /committee?
    def test_err_on_unsupported_arg(self):
        response = self.app.get('/committee?bogusArg=1')
        self.assertEquals(response.status_code, 400)

    def test_committee_party(self):
        response = self._results('/committee?party=REP')
        self.assertEquals(response[0]['party'], 'REP')
        self.assertEquals(response[0]['party_full'], 'Republican Party')

    def test_committee_filters(self):
        org_response = self._response('/committee')
        original_count = org_response['pagination']['count']

        # checking one example from each field
        filter_fields = (
            ('committee_id', 'C00484188,C00000422'),
            ('state', 'CA,DC'),
            ('name', 'Obama'),
            ('committee_type', 'S'),
            ('designation', 'P'),
            ('party', 'REP,DEM'),
            ('organization_type','C'),
        )

        for field, example in filter_fields:
            page = "/committee?%s=%s" % (field, example)
            print page
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])

    def test_committe_by_cand_id(self):
        results =  self._results('/candidate/P60000247/committees')

        ids = []
        for com in results:
            ids.append(com['committee_id'])

        self.assertIn('C00048587', ids)
        self.assertIn('C00111245', ids)
        self.assertIn('C00108407', ids)

    def test_committee_by_cand_filter(self):
        results =  self._results('/candidate/P60000247/committees?designation=P')
        self.assertEquals(1, len(results))

# Totals
    def test_reports_house_senate(self):
        results = self._results('/total/C00002600')

        fields = ('beginning_image_number', 'end_image_number', 'expire_date', 'load_date','report_type', 'report_type_full','report_year', 'type', 'cash_on_hand_beginning_period', 'cash_on_hand_end_period', 'debts_owed_by_committee', 'debts_owed_to_committee', 'operating_expenditures_period', 'other_political_committee_contributions_period', 'refunds_other_political_committee_contributions_period', 'total_disbursements_period', 'total_individual_contributions_period', 'total_receipts_period',)

        for field in fields:
            print field
            self.assertEquals(results[0]['reports'][0].has_key(field), True)

    def test_reports_pac_party(self):
        results = self._results('/total/C00000422')

        fields = ('beginning_image_number', 'end_image_number', 'expire_date', 'load_date', 'report_type', 'report_type_full', 'report_year', 'total_disbursements_period', 'total_disbursements_summary_page_period', 'total_receipts_period', 'total_receipts_summary_page_period', 'type')

        for field in fields:
            print field
            self.assertEquals(results[0]['reports'][0].has_key(field), True)

    def test_reports_presidental(self):
        results = self._results('/total/C00347583')

        fields = ('refunds_political_party_committee_contributions_period', 'other_receipts_period', 'total_disbursements_period', 'net_contributions_year', 'beginning_image_number', 'total_receipts_year', 'total_receipts', 'refunds_political_party_committee_contributions_year', 'total_loans_period', 'other_political_committee_contributions_year', 'loan_repayments_other_loans_period', 'net_contributions_period', 'refunds_other_political_committee_contributions_period', 'all_other_loans_year', 'net_operating_expenditures_period', 'loan_repayments_other_loans_year', 'total_individual_itemized_contributions_year', 'subtotal_period', 'other_receipts_year', 'total_contribution_refunds_col_total_period', 'debts_owed_by_committee', 'total_contribution_refunds_year', 'offsets_to_operating_expenditures_period', 'cash_on_hand_beginning_period', 'individual_itemized_contributions_period', 'refunds_individual_contributions_year', 'total_contributions_year', 'operating_expenditures_period', 'political_party_committee_contributions_year', 'total_individual_contributions_year', 'total_individual_unitemized_contributions_year', 'net_operating_expenditures_year', 'expire_date', 'individual_unitemized_contributions_period', 'transfers_to_other_authorized_committee_year', 'report_type', 'total_disbursements_year', 'type', 'operating_expenditures_year', 'transfers_from_other_authorized_committee_period', 'total_offsets_to_operating_expenditures_year', 'total_loan_repayments_year', 'candidate_contribution_year', 'refunds_other_political_committee_contributions_year', 'debts_owed_to_committee', 'other_disbursements_year', 'total_loan_repayments_period', 'candidate_contribution_period', 'transfers_to_other_authorized_committee_period', 'refunds_total_contributions_col_total_year', 'total_contributions_column_total_period', 'political_party_committee_contributions_period', 'cash_on_hand_end_period', 'all_other_loans_period', 'loans_made_by_candidate_year', 'total_individual_contributions_period', 'loans_made_by_candidate_period', 'total_offsets_to_operating_expenditures_period', 'offsets_to_operating_expenditures_year', 'total_contribution_refunds_period', 'report_year', 'total_loans_year', 'transfers_from_other_authorized_committee_year', 'load_date', 'other_disbursements_period', 'loan_repayments_candidate_loans_period', 'other_political_committee_contributions_period', 'total_receipts_period', 'total_contributions_period', 'end_image_number', 'refunds_individual_contributions_period', 'loan_repayments_candidate_loans_year', 'total_operating_expenditures_year', 'total_operating_expenditures_period', 'report_type_full', 'election_cycle',
            )

        for field in fields:
            print field
            self.assertEquals(results[0]['reports'][0].has_key(field), True)

    def test_total_field_filter(self):
        results_disbursements = self._results('/total?committee_id=C00347583&fields=disbursements')
        results_recipts = self._results('/total/C00347583?fields=total_receipts_period')

        self.assertIn('disbursements', results_disbursements[0]['totals'][0])
        self.assertIn('total_receipts_period',results_recipts[0]['reports'][0])
        self.assertNotIn('reports', results_disbursements[0])
        self.assertNotIn('totals', results_recipts[0])

    def test_total_cycle(self):
        results = self._results('/total/C00000422?fields=cash_on_hand_end_period,disbursements')[0]
        print results
        reports_all = len(results['reports'])
        totals_all = len(results['totals'])

        results_after = self._results('/total/C00000422?fields=cash_on_hand_end_period,disbursements&election_cycle=2008')[0]
        print results_after
        reports_04 = len(results_after['reports'])
        totals_04 = len(results_after['totals'])

        self.assertGreater(reports_all, reports_04)
        self.assertGreater(totals_all, totals_04)

    def test_multiple_committee(self):
        results = self._results('/total?committee_id=C00002600,C00000422&fields=committtee_id')
        print len(results)
        self.assertEquals(len(results), 2)



    # Typeahead name search
    def test_typeahead_name_search(self):
        results = self._results('/name?q=oba')
        self.assertGreaterEqual(len(results), 10)
        for r in results:
            self.assertIn('OBA', r['name'])


