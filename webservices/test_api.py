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
        results = self._results('/candidate?q=stapleton')
        for r in results:
            txt = json.dumps(r).lower()
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

    # def test_year_default(self):
    #     # finds obama only if 2012 is specified
    #     results = self._results('candidate?cand_id=P80003338')
    #     self.assertEquals(results, [])
    #     results = self._results('candidate?cand_id=P80003338&year=2012')
    #     self.assertNotEqual(results, [])

