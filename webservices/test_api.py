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
            print "\n\n", txt, "\n\n"
            self.assertIn('james', txt)

    def test_full_text_search_with_whitespace(self):
        results = self._results('/candidate?q=barack obama&fields=*')
        for r in results:
            txt = json.dumps(r).lower()
            print "\n\n", txt, "\n\n"
            self.assertIn('obama', txt)

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

    def test_fields(self):
        # testing key defaults
        response = self._results('/candidate?candidate_id=P80003338&year=2008')

        response= response[0]
        print "\n%s\n" % response

        #self.assertEquals(response['candidate_id'], 'P80003338')
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

    def test_no_fields(self):
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

    #Committee

    def test_committee_fields(self):
        response = self._response('/committee')
        item = response['results'][0]

        property_fields = ('committee_id', 'expire_date', 'form_type', 'load_date')
        for field in property_fields:
            print field
            self.assertEquals(item['properties'].has_key(field), True)



    def test_committee_filter(self):
        response = self._response('/committee')
        type_response = self._response('/committee?type_code=P')
        desig_response = self._response('/committee?designation_code=P')
        org_response = self._response('/committee?organization_type_code=C')


        original_count = response['pagination']['count']
        type_count = type_response['pagination']['count']
        desig_count = desig_response['pagination']['count']
        org_count = org_response['pagination']['count']

        self.assertEquals((original_count > type_count), True)
        self.assertEquals((original_count > desig_count), True)
        self.assertEquals((original_count > org_count), True)


    # def test_committee_basics(self):
    #     response = self._response('/committee')
    #     results = response['results']
    #     # not all records in the test db have statuses; find one that does
    #     result = [r[0] for r in results if r[0]['status']][0]

    #     fields = ('committee_id', 'form_type', 'form_type', 'expire_date', 'name', 'address')
    #     for field in fields:
    #         self.assertEquals(result.has_key(field), True)


    # def test_committee_status(self):
    #     response = self._response('/committee')
    #     results = response['results']
    #     # not all records in the test db have statuses; find one that does
    #     result = [r[0] for r in results if r[0]['status']][0]
    #     status = result['status'][0]
    #     print status, "\n"

    #     fields = ('designation', 'designation_full', 'type_full', 'type')
    #     for field in fields:
    #         print field
    #         self.assertEquals(status.has_key(field), True)


    # def test_committee_candidate(self):
    #     response = self._response('/committee/C00431445')
    #     print response['results']
    #     cand = response['results'][0][0]['candidates'][0]

    #     fields = ('candidate_id', 'designation','designation_full',
    #                 'election_year', 'expire_date', 'link_date', 'type', 'type_code'
    #     )

    #     for field in fields:
    #         self.assertEquals(cand.has_key(field), True)



    # def test_treasurer(self):
    #     # These fields really vary
    #     response = self._response('/committee/C00031054')
    #     results = response['results'][0]['treasurer']
    #     self.assertEquals(status.has_key(name_full), True)


