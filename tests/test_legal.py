from webservices import rest
import json
import codecs
import unittest
from mock import patch

# TODO: integrate more with API Schema so that __API_VERSION__ is returned
# self.assertEqual(result['api_version'], __API_VERSION__)

def es_advisory_opinion(query, size):
    return {'hits': {'hits': [{'_source': {'text': 'abc'}},
            {'_source': {'no': '123'}}]}}

def es_search(q, index, size, es_from):
    _type = q["query"]["bool"]["must"][1]["term"]["_type"]
    if _type == 'regulations':
        return {'hits': {'hits': [{'highlight': {'text': ['a', 'b']},
                                    '_source': {}}], 'total': 1}}
    if _type == 'advisory_opinions':
        return {'hits': {'hits': [{'highlight': {'text': ['a', 'b']},
                                    '_source': {}},
                                  {'highlight': {'text': ['c', 'd']},
                                    '_source': {}}], 'total': 2}}
    if _type == 'statutes':
        return {'hits': {'hits': [{'highlight': {'text': ['e']},
                                    '_source': {}}], 'total': 3}}


@patch('webservices.rest.legal.es.search', side_effect=es_advisory_opinion)
class AdvisoryOpinionTest(unittest.TestCase):
    def test_advisory_opinion_search(self, es_search):
        app = rest.app.test_client()
        response = app.get('/v1/legal/advisory_opinion/1993-02?api_key=1234')
        self.assertEquals(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        self.assertNotEqual(result, [], "Empty response!")
        self.assertDictEqual(result, {'docs': [{'text': 'abc'}, {'no': '123'}]})

@patch('webservices.rest.legal.es.search', side_effect=es_search)
class SearchTest(unittest.TestCase):
    def setUp(self):
        self.app = rest.app.test_client()

    def test_default_search(self, es_search):
        response = self.app.get('/v1/legal/search/?q=president&api_key=1234')
        self.assertEquals(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        self.assertNotEqual(result, [], "Empty response!")
        self.assertDictEqual(result, {
            'regulations': [{'highlights': ['a', 'b']}],
            'total_advisory_opinions': 2,
            'statutes': [{'highlights': ['e']}], 'total_statutes': 3,
            'total_regulations': 1,
            'advisory_opinions': [{'highlights': ['a', 'b']},
              {'highlights': ['c', 'd']}], 'total_all': 6})

    def test_type_search(self, es_search):
        response = self.app.get('/v1/legal/search/?q=president&type=advisory_opinions')
        self.assertEquals(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        self.assertNotEqual(result, [], "Empty response!")
        self.assertDictEqual(result, {
            'total_advisory_opinions': 2,
            'advisory_opinions': [{'highlights': ['a', 'b']},
              {'highlights': ['c', 'd']}], 'total_all': 2})
