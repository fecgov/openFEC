import json
import unittest
import rest

class OverallTest(unittest.TestCase):

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
        response = self._results('/candidate?candidate_id=P80003338&year=2012')
        self.assertEquals(response[0]['candidate_id'], 'P80003338')
        self.assertEquals(response[0]['name']['full_name'], 'OBAMA, BARACK')
        self.assertEquals(response[0]['elections'][0]['party_affiliation'], "Democratic Party")
        self.assertEquals(response[0]['elections'][0]['primary_committee']['committee_id'], 'C00431445')
        self.assertEquals(response[0]['elections'][0]['primary_committee']['designation'], "Principal campaign committee")
        self.assertEquals(response[0]['elections'][0]['state'], "US")
        self.assertEquals(response[0]['elections'][0]['district'], None)
        self.assertEquals(response[0]['elections'][0]['incumbent_challenge'], 'incumbent')
        self.assertEquals(response[0]['elections'][0]['primary_committee']['designation'], 'Principal campaign committee')
        self.assertEquals(response[0]['elections'][0].has_key('affiliated_committees'), False)
        self.assertEquals(response[0]['elections'][0].has_key('mailing_addresses'), False)
        self.assertEquals(response[0]['elections'][0].has_key('candidate_status'), True)
        self.assertEquals(response[0]['elections'][0].has_key('candidate_inactive'), True)
        self.assertEquals(response[0]['elections'][0].has_key('office_sought'), True)
        self.assertEquals(response[0]['elections'][0].has_key('election_year'), True)

    def test_extra_fields(self):
        response = self._results('/candidate?candidate_id=P80003338&fields=mailing_addresses,affiliated_committees')
        self.assertIn('C00507830', [c['committee_id'] for c in response[0]['elections'][0]['affiliated_committees']])
        self.assertIn('233 NORTH MICHIGAN AVE STE 1720', [a['street_1'] for a in response[0]['mailing_addresses']])
        self.assertEquals(response[0].has_key('candidate_id'), False)
        self.assertEquals(response[0].has_key('name'), False)

    def test_no_fields(self):
        response = self._results('/candidate?candidate_id=P80003338&fields=wrong')
        self.assertEquals(response[0], {})

    def test_candidate_committes(self):
        response = self._results('/candidate?candidate_id=P80003338&fields=*')

        self.assertEquals(response[0]['elections'][0]['affiliated_committees'][0].has_key('committee_id'), True)
        self.assertEquals(response[0]['elections'][0]['affiliated_committees'][0].has_key('designation'), True)
        self.assertEquals(response[0]['elections'][0]['affiliated_committees'][0].has_key('designation_code'), True)
        self.assertEquals(response[0]['elections'][0]['affiliated_committees'][0].has_key('type'), True)
        self.assertEquals(response[0]['elections'][0]['affiliated_committees'][0].has_key('type_code'), True)

        self.assertEquals(response[0]['elections'][0]['primary_committee'].has_key('committee_id'), True)
        self.assertEquals(response[0]['elections'][0]['primary_committee'].has_key('designation'), True)
        self.assertEquals(response[0]['elections'][0]['primary_committee'].has_key('designation_code'), True)
        self.assertEquals(response[0]['elections'][0]['primary_committee'].has_key('type'), True)
        self.assertEquals(response[0]['elections'][0]['primary_committee'].has_key('type_code'), True)

    def test_committee_basics(self):
        response = self._response('/committee')
        results = response['results']
        self.assertEquals(results[0][0].has_key('committee_id'), True)
        self.assertEquals(results[0][0].has_key('form_type'), True)
        self.assertEquals(results[0][0].has_key('expire_date'), True)
        self.assertEquals(results[0][0].has_key('name'), True)
        self.assertEquals(results[0][0]['status'][0].has_key('designation'), True)
        self.assertEquals(results[0][0]['status'][0].has_key('designation_code'), True)
        self.assertEquals(results[0][0]['status'][0].has_key('type_code'), True)
        self.assertEquals(results[0][0]['status'][0].has_key('type'), True)
        self.assertEquals(results[0][0].has_key('address'), True)

    def test_committee_candidate(self):
        response = self._response('/committee/C00431445')
        print response['results']
        cand = response['results'][0][0]['candidates'][0]

        fields = ('candidate_id', 'designation','designation_code',
                    'election_year', 'expire_date', 'link_date', 'type', 'type_code'
        )

        for field in fields:
            self.assertEquals(cand.has_key(field), True)

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
