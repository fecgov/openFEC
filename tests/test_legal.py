from webservices import rest
import json
import codecs
import unittest
import unittest.mock as mock
from unittest.mock import patch

from webservices.resources.legal import es
from elasticsearch import RequestError
import datetime

# TODO: integrate more with API Schema so that __API_VERSION__ is returned
# self.assertEqual(result['api_version'], __API_VERSION__)

def get_path(obj, path):
    parts = path.split('.')
    first = parts[0]
    assert first in obj

    if len(parts) == 1:
        return obj[first]
    else:
        return get_path(obj[first], '.'.join(parts[1:]))


def es_advisory_opinion(*args, **kwargs):
    return {'hits': {'hits': [{'_source': {'text': 'abc'}, '_type': 'advisory_opinions'},
           {'_source': {'no': '123'}, '_type': 'advisory_opinions'}]}}

def es_mur(*args, **kwargs):
    return {'hits': {'hits': [{'_source': {'text': 'abc'}, '_type': 'murs'},
           {'_source': {'no': '123'}, '_type': 'murs'}]}}

def es_invalid_search(*args, **kwargs):
    raise RequestError("invalid query")

def es_search(**kwargs):
    _type = kwargs["body"]["query"]["bool"]["must"][0]["term"]["_type"]

    if _type == 'regulations':
        return {'hits': {'hits': [{'highlight': {'text': ['a', 'b']},
                                   '_source': {}, '_type': 'regulations'}], 'total': 1}}
    if _type == 'advisory_opinions':
        return {'hits': {'hits': [{'highlight': {'text': ['a', 'b']},
                                    '_source': {}, '_type': 'advisory_opinions'},
                                  {'highlight': {'text': ['c', 'd']},
                                    '_source': {}, '_type': 'advisory_opinions'}], 'total': 2}}
    if _type == 'statutes':
        return {'hits': {'hits': [{'highlight': {'text': ['e']},
                                    '_source': {}, '_type': 'statutes'}], 'total': 3}}

    if _type == 'murs':
        return {'hits': {'hits': [{'highlight': {'text': ['f']},
                                    '_source': {}, '_type': 'murs'}], 'total': 4}}

    if _type == 'adrs':
        return {'hits': {'hits': [{'highlight': {'text': ['f']},
                                    '_source': {}, '_type': 'adrs'}], 'total': 2}}

    if _type == 'admin_fines':
        return {'hits': {'hits': [{'highlight': {'text': ['f']},
                                    '_source': {}, '_type': 'admin_fines'}], 'total': 5}}


class CanonicalPageTest(unittest.TestCase):
    @patch('webservices.rest.legal.es.search', es_advisory_opinion)
    def test_advisory_opinion_search(self):
        app = rest.app.test_client()
        response = app.get('/v1/legal/docs/advisory_opinions/1993-02?api_key=1234')
        assert response.status_code == 200
        result = json.loads(codecs.decode(response.data))
        assert result == {'docs': [{'text': 'abc'}, {'no': '123'}]}

    @patch('webservices.rest.legal.es.search', es_mur)
    def test_mur_search(self):
        app = rest.app.test_client()
        response = app.get('/v1/legal/docs/murs/1?api_key=1234')
        assert response.status_code == 200
        result = json.loads(codecs.decode(response.data))
        assert result == {'docs': [{'text': 'abc'}, {'no': '123'}]}

    @patch.object(es, 'search')
    def test_query_dsl(self, es_search):
        app = rest.app.test_client()
        response = app.get('/v1/legal/docs/advisory_opinions/1993-02?api_key=1234')
        assert response.status_code == 404

        # This is mostly copy/pasted from the dict-based query. This is not a
        # very meaningful test but helped to ensure we're using the
        # elasitcsearch_dsl correctly.
        expected_query = {"query": {"bool": {"must": [{"term": {"no": "1993-02"}},
                          {"term": {"_type": "advisory_opinions"}}]}},
                          "_source": {"exclude": "documents.text"}, "size": 200}
        es_search.assert_called_with(body=expected_query,
                                     doc_type=mock.ANY,
                                     index=mock.ANY)

class SearchTest(unittest.TestCase):
    def setUp(self):
        self.app = rest.app.test_client()

    @patch('webservices.rest.legal.es.search', es_search)
    def test_default_search(self):
        response = self.app.get('/v1/legal/search/?q=president&api_key=1234')
        assert response.status_code == 200
        result = json.loads(codecs.decode(response.data))
        assert result == {
            'regulations': [
                {'highlights': ['a', 'b'], 'document_highlights': {}}
            ],
            'total_regulations': 1,
            'statutes': [
                {'highlights': ['e'], 'document_highlights': {}}
            ],
            'total_statutes': 3,
            'murs': [
                {'highlights': ['f'], 'document_highlights': {}}
            ],
            'total_murs': 4,
            'adrs': [
                {'highlights': ['f'], 'document_highlights': {}}
            ],
            'total_adrs': 2,
            'admin_fines': [
                {'highlights': ['f'], 'document_highlights': {}}
            ],
            'total_admin_fines': 5,
            'advisory_opinions': [
                {'highlights': ['a', 'b'], 'document_highlights': {}},
                {'highlights': ['c', 'd'], 'document_highlights': {}}
            ],
            'total_advisory_opinions': 2,
            'total_all': 17}

    @patch('webservices.rest.legal.es.search', es_search)
    def test_type_search(self):
        response = self.app.get('/v1/legal/search/' +
                                '?q=president&type=advisory_opinions')
        assert response.status_code == 200
        result = json.loads(codecs.decode(response.data))
        assert result == {
            'total_advisory_opinions': 2,
            'advisory_opinions': [
                {'highlights': ['a', 'b'], 'document_highlights': {}},
                {'highlights': ['c', 'd'], 'document_highlights': {}}
            ],
            'total_all': 2
        }

    @patch('webservices.rest.legal.es.search', es_invalid_search)
    def test_invalid_search(self):
        response = self.app.get('/v1/legal/search/' +
                                '?q=president%20AND%20OR&type=advisory_opinions')
        assert response.status_code == 400

    @patch.object(es, 'search')
    def test_query_dsl(self, es_search):
        response = self.app.get('/v1/legal/search/', query_string={
                                'q': 'president',
                                'type': 'statutes'})
        assert response.status_code == 200

        # This is mostly copy/pasted from the dict-based query. This is not a
        # very meaningful test but helped to ensure we're using the
        # elasitcsearch_dsl correctly.

        expected_query = {'from': 0,
        'sort': ['sort1', 'sort2'],
            'size': 20,
            'query': {'bool': {'must': [{'term': {'_type': 'statutes'}},
            {'query_string': {'query': 'president'}}]}},
            'highlight': {'fields': {'documents.text': {}, 'text': {},
            'no': {}, 'name': {}, 'documents.description': {}, 'summary': {}},
            'require_field_match': False},
            '_source': {'exclude': ['text', 'documents.text', 'sort1', 'sort2']}}

        es_search.assert_called_with(body=expected_query,
                                     index=mock.ANY,
                                     doc_type=mock.ANY)

    @patch.object(es, 'search')
    def test_query_dsl_with_ao_category_filter(self, es_search):
        response = self.app.get('/v1/legal/search/', query_string={
                                'q': 'president',
                                'type': 'advisory_opinions'})
        assert response.status_code == 200

        # This is mostly copy/pasted from the dict-based query. This is not a
        # very meaningful test but helped to ensure we're using the
        # elasitcsearch_dsl correctly.
        expected_query = {'query':
            {'bool':
                {'must': [{'term': {'_type': 'advisory_opinions'}},
                {'bool': {'minimum_should_match': 1}}],
                    'minimum_should_match': 1,
                    'should': [{'nested': {'path': 'documents',
                'inner_hits': {'_source': False,
                'highlight': {'require_field_match': False,
                'fields': {'documents.text': {}, 'documents.description': {}}}},
                        'query': {'bool': {'must': [{'query_string': {'query': 'president',
                        'fields': ['documents.text']}}]}}}},
                    {'query_string': {'query': 'president', 'fields': ['no', 'name', 'summary']}}]}},
            'highlight': {'require_field_match': False,
                'fields': {'text': {}, 'documents.text': {}, 'summary': {},
                'name': {}, 'documents.description': {}, 'no': {}}},
            'from': 0, 'size': 20,
            '_source': {'exclude': ['text', 'documents.text', 'sort1', 'sort2']}, 'sort': ['sort1', 'sort2']}

        es_search.assert_called_with(body=expected_query,
                                     index=mock.ANY,
                                     doc_type=mock.ANY)

    @patch.object(es, 'search')
    def test_query_dsl_with_mur_filters(self, es_search):
        response = self.app.get('/v1/legal/search/', query_string={
                                'q': 'embezzle',
                                'type': 'murs',
                                'mur_min_open_date': '2012-01-01',
                                'mur_max_open_date': '2013-12-31',
                                'mur_min_close_date': '2014-01-01',
                                'mur_max_close_date': '2015-12-31'})
        assert response.status_code == 200

        expected_query = {
            "query": {
                "bool": {
                    "must": [
                        {
                            "term": {
                                "_type": "murs"
                            }
                        },
                        {
                            "query_string": {
                                "query": "embezzle"
                            }
                        },
                        {
                            "range": {
                                "open_date": {
                                    "gte": datetime.date(2012, 1, 1),
                                    "lte": datetime.date(2013, 12, 31)
                                }
                            }
                        },
                        {
                            "range": {
                                "close_date": {
                                    "gte": datetime.date(2014, 1, 1),
                                    "lte": datetime.date(2015, 12, 31)
                                }
                            }
                        }
                    ]
                }
            },
            "sort": [
                "sort1",
                "sort2"
            ],
            "from": 0,
            "_source": {
                "exclude": [
                    "text",
                    "documents.text",
                    "sort1",
                    "sort2"
                ]
            },
            "highlight": {
                "fields": {
                    "text": {},
                    "no": {},
                    "documents.description": {},
                    "documents.text": {},
                    "summary": {},
                    "name": {}
                },
                "require_field_match": False
            },
            "size": 20
        }

        es_search.assert_called_with(body=expected_query,
                                     index=mock.ANY,
                                     doc_type=mock.ANY)
