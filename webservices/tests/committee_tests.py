import json
import unittest

from .common import ApiBaseTest

## old, re-factored Committee tests ##
class CommitteeFormatTest(ApiBaseTest):
    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_committee_list_fields(self):
        # example with committee
        response = self._response('/committee?committee_id=C00048587')
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
        self.assertEqual(candidate_result['candidate_name'], 'CARTER, JIMMY')
        self.assertEqual(candidate_result['active_through'], 1976)
        self.assertEqual(candidate_result['link_date'], '2007-10-12 13:38:33')
        # Example with org type
        response = self._response('/committee?organization_type=C')
        results = response['results'][0]
        self.assertEqual(results['organization_type_full'], 'Corporation')
        self.assertEqual(results['organization_type'], 'C')

    def test_committee_detail_fields(self):
        response = self._response('/committee/C00048587')
        result = response['results'][0]
        # main fields
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
        self.assertEqual(candidate_result['candidate_name'], 'CARTER, JIMMY')
        self.assertEqual(candidate_result['active_through'], 1976)
        self.assertEqual(candidate_result['link_date'], '2007-10-12 13:38:33')
        # Things on the detailed view
        self.assertEqual(result['filing_frequency'], 'T')
        self.assertEqual(result['form_type'], 'F1Z')
        self.assertEqual(result['load_date'], '1982-12-31 00:00:00')
        self.assertEqual(result['street_1'], '1795 PEACHTREE ROAD , NE')
        self.assertEqual(result['zip'], '30309')
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


    def test2committees(self):
        response = self._results('/committee/C00484188?year=2012')
        self.assertEquals(len(response[0]['candidates']), 2)

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

    def test_committees_by_cand_id(self):
        results =  self._results('/candidate/P60000247/committees')

        ids = [x['committee_id'] for x in results]

        self.assertIn('C00048587', ids)
        self.assertIn('C00111245', ids)
        self.assertIn('C00108407', ids)

    def test_committee_by_cand_filter(self):
        results =  self._results('/candidate/P60000247/committees?designation=P')
        self.assertEquals(1, len(results))

    def test_committee_by_cand(self):
        results =  self._results('http://localhost:5000/candidate/P60000247/committees?year=*')
        self.assertEquals(3, len(results))

    def test_canditites_by_com(self):
        results =  self._results('/committee/C00111245/candidates?year=*')
        self.assertEquals(1, len(results))