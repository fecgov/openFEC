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
        self.assertIn('api_version', response[0])
        self.assertIn('pagination', response[1])

    def _results(self, qry):
        response = self._response(qry)
        return response[2]['results']

    def test_full_text_search(self):
        results = self._results('/candidate?q=stapleton&fields=*')
        for r in results:
            txt = json.dumps(r).lower()
            print "\n\n", txt, "\n\n"
            self.assertIn('stapleton', txt)

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

    def test_fields(self):
        # testing key defaults
        response = self._results('/candidate?cand_id=P80003338')
        self.assertEquals(response[0]['cand_id'], 'P80003338')
        self.assertEquals(response[0]['name']['full_name'], 'OBAMA, BARACK')
        self.assertEquals(response[0]['elections']['2008']['party_affiliation'], "Democratic Party")
        self.assertEquals(response[0]['elections']['2008']['primary_cmte']['cmte_id'], 'C00431445')
        self.assertEquals(response[0]['elections']['2008']['primary_cmte']['designation'], "Principal campaign committee")
        self.assertEquals(response[0]['elections']['2008']['state'], "US")
        self.assertEquals(response[0]['elections']['2008']['incumbent_challenge'], 'open_seat')
        self.assertEquals(response[0]['elections']['2012']['district'], None)
        self.assertEquals(response[0]['elections']['2012']['incumbent_challenge'], 'incumbent')
        self.assertEquals(response[0]['elections']['2012']['primary_cmte']['designation'], 'Principal campaign committee')
        self.assertEquals(response[0]['elections']['2012'].has_key('affiliated_cmtes'), False)
        self.assertEquals(response[0]['elections']['2012'].has_key('mailing_addresses'), False)

    def test_extra_fields(self):
        response = self._results('/candidate?cand_id=P80003338&fields=mailing_addresses,affiliated_cmtes')
        self.assertEquals(response[0]['elections']['2008']['affiliated_cmtes'][0]['cmte_id'], 'C00430892')
        self.assertEquals(response[0]['mailing_addresses'][0]['street_1'], '5450 SOUTH EAST VIEW PARK')
        self.assertEquals(response[0].has_key('cand_id'), False)
        self.assertEquals(response[0].has_key('name'), False)
        ## It also shouldn't show elections


