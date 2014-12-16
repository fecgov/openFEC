import json
import unittest
import rest

class OverallTest(unittest.TestCase):
    # Candidate

    def setUp(self):
        rest.app.config['TESTING'] = True
        self.app = rest.app.test_client()

    def tearDown(self):
        pass

    def _response(self, qry):
        response = self.app.get(qry)
        self.assertEquals(response.status_code, 200)
        return json.loads(response.data)

    def test_header_info(self):
        response = self._response('/candidate')
        self.assertIn('api_version', response)
        self.assertIn('pagination', response)


    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_full_text_search(self):
        results = self._results('/candidate?q=james&fields=*')
        for r in results:
            txt = json.dumps(r).lower()
            self.assertIn('james', txt)

    def test_full_text_search_with_whitespace(self):
        results = self._results('/candidate?q=barack obama&fields=*')
        for r in results:
            txt = json.dumps(r).lower()
            self.assertIn('obama', txt)

    def test_year_filter(self):
        results = self._results('/candidate?year=1988&fields=*')
        for r in results:
            for e in r['elections']:
                if 'primary_committee' in e:
                    self.assertEqual(e['primary_committee']['election_year'], 1988)

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

    # def test_year_default(self):
    #     # finds obama only if 2012 is specified
    #     results = self._results('candidate?cand_id=P80003338')
    #     self.assertEquals(results, [])
    #     results = self._results('candidate?cand_id=P80003338&year=2012')
    #     self.assertNotEqual(results, [])

# Candidates
    def test_fields(self):
        # testing key defaults
        response = self._results('/candidate?candidate_id=P80003338&year=2008')
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
        response = self._results('/candidate?candidate_id=P80003338&fields=mailing_addresses,affiliated_committees')
        self.assertIn('C00434357', [c['committee_id'] for c in response[0]['elections'][0]['affiliated_committees']])
        self.assertIn('233 NORTH MICHIGAN AVE STE 1720', [a['street_1'] for a in response[0]['mailing_addresses']])
        self.assertEquals(response[0].has_key('candidate_id'), False)
        self.assertEquals(response[0].has_key('name'), False)

    def test_no_candidate_fields(self):
        response = self._results('/candidate?candidate_id=P80003338&fields=wrong')
        self.assertEquals(response[0], {})

    def test_candidate_committes(self):
        response = self._results('/candidate?candidate_id=P80003338&fields=*')

        fields = ('committee_id', 'designation', 'designation_full', 'type', 'type_full', 'election_year')

        election = response[0]['elections'][0]
        print election
        for field in fields:
            print field
            self.assertEquals(election['primary_committee'].has_key(field), True)
            self.assertEquals(election['affiliated_committees'][0].has_key(field), True)

    def test_years_all(self):
        # testing search
        response = self._results('/candidate?candidate_id=P80003338&year=*')
        elections = response[0]['elections']
        self.assertEquals(len(elections), 2)
        # testing single resource
        response = self._results('/candidate/P80003338?year=*')
        elections = response[0]['elections']
        self.assertEquals(len(elections), 2)


    def test_multi_year(self):
        # testing search
        response = self._results('/candidate?candidate_id=P80003338&year=2012,2008')
        elections = response[0]['elections']
        self.assertEquals(len(elections), 2)
        # testing single resource
        response = self._results('/candidate/P80003338?year=2012,2008')
        elections = response[0]['elections']
        self.assertEquals(len(elections), 2)

#Committee

    def test_committee_cand_fields(self):
        response = self._response('/committee/C00000851')
        results = response['results']
        # not all records in the test db have candidates; find one that does
        result = results[0]['candidates'][0]

        fields = ('candidate_id', 'designation', 'designation_full', 'election_year', 'expire_date', 'link_date', 'type', 'type_full')
        for field in fields:
            print field
            self.assertEquals(result.has_key(field), True)

    def test_committee_stats(self):
        response = self._response('/committee/C00000851')
        results = response['results']

        result = results[0]['status']
        fields = ('designation','designation_full', 'expire_date','load_date', 'receipt_date', 'type', 'type_full')
        for field in fields:
            print field
            self.assertEquals(result.has_key(field), True)


    def test_committee_filter(self):
        # one filter from each table
        response = self._response('/committee')
        type_response = self._response('/committee?type=P')
        org_response = self._response('/committee?organization_type=C')

        original_count = response['pagination']['count']
        type_count = type_response['pagination']['count']
        org_count = org_response['pagination']['count']

        self.assertEquals((original_count > type_count), True)
        self.assertEquals((original_count > org_count), True)

    def test_committee_properties_basic(self):
        response = self._response('/committee/C00000851')
        result = response['results'][0]

        fields = ('committee_id','expire_date','form_type','load_date')
        for field in fields:
            print field
            self.assertEquals(result.has_key(field), True)

        # Not a default field
        self.assertEquals(result.has_key('archive'), False)

    def test_committee_properties_all(self):
        response = self._response('/committee/C00000851?fields=*')
        result = response['results'][0]['archive'][0]

        print result

        description_fields = ('form_type','expire_date','filing_frequency','load_date')
        for field in description_fields:
            print field
            self.assertEquals(result['description'][0].has_key(field), True)

        address_fields = ('city', 'state', 'state_full', 'street_1', 'zip', 'expire_date')
        for field in address_fields:
            print field
            self.assertEquals(result['address'][0].has_key(field), True)

        self.assertEquals(result['treasurer'][0].has_key('name_full'), True)
        self.assertEquals(result['treasurer'][0].has_key('expire_date'), True)

    def test_committee_field_filtering(self):
        response = self._results('/committee/C00000851?fields=committee_id')
        print '\n%s\n' % response
        self.assertEquals(len(response[0]), 1)

    def test_err_on_unsupported_arg(self):
        response = self.app.get('/committee?bogusArg=1')
        self.assertEquals(response.status_code, 400)
