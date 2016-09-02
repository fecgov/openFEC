from webservices import rest
import json
import codecs
import unittest
import mock
from mock import patch

from webservices.resources.legal import es, parse_query_string

# TODO: integrate more with API Schema so that __API_VERSION__ is returned
# self.assertEqual(result['api_version'], __API_VERSION__)

def es_advisory_opinion(*args, **kwargs):
    return {'hits': {'hits': [{'_source': {'text': 'abc'}, '_type': 'advisory_opinions'},
           {'_source': {'no': '123'}, '_type': 'advisory_opinions'}]}}

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


class AdvisoryOpinionTest(unittest.TestCase):
    @patch('webservices.rest.legal.es.search', es_advisory_opinion)
    def test_advisory_opinion_search(self):
        app = rest.app.test_client()
        response = app.get('/v1/legal/advisory_opinion/1993-02?api_key=1234')
        assert response.status_code == 200
        result = json.loads(codecs.decode(response.data))
        assert result == {'docs': [{'text': 'abc'}, {'no': '123'}]}

    @patch.object(es, 'search')
    def test_query_dsl(self, es_search):
        app = rest.app.test_client()
        response = app.get('/v1/legal/advisory_opinion/1993-02?api_key=1234')
        assert response.status_code == 200

        # This is mostly copy/pasted from the dict-based query. This is not a
        # very meaningful test but helped to ensure we're using the
        # elasitcsearch_dsl correctly.
        expected_query = {"query": {"bool": {"must": [{"term": {"no": "1993-02"}},
                          {"term": {"_type": "advisory_opinions"}}]}},
                          "_source": {"exclude": "text"}, "size": 200}
        es_search.assert_called_with(body=expected_query,
                                     doc_type=mock.ANY,
                                     index=mock.ANY)
        result = json.loads(codecs.decode(response.data))

class SearchTest(unittest.TestCase):
    def setUp(self):
        self.app = rest.app.test_client()

    @patch('webservices.rest.legal.es.search', es_search)
    def test_default_search(self):
        response = self.app.get('/v1/legal/search/?q=president&api_key=1234')
        assert response.status_code == 200
        result = json.loads(codecs.decode(response.data))
        assert result == {
            'regulations': [{'highlights': ['a', 'b']}],
            'total_advisory_opinions': 2,
            'statutes': [{'highlights': ['e']}], 'total_statutes': 3,
            'total_regulations': 1,
            'advisory_opinions': [{'highlights': ['a', 'b']},
              {'highlights': ['c', 'd']}], 'total_all': 6}

    @patch('webservices.rest.legal.es.search', es_search)
    def test_type_search(self):
        response = self.app.get('/v1/legal/search/' +
                                '?q=president&type=advisory_opinions')
        assert response.status_code == 200
        result = json.loads(codecs.decode(response.data))
        assert result == {
            'total_advisory_opinions': 2,
            'advisory_opinions': [{'highlights': ['a', 'b']},
              {'highlights': ['c', 'd']}], 'total_all': 2}

    @patch.object(es, 'search')
    def test_query_dsl(self, es_search):
        response = self.app.get('/v1/legal/search/', query_string={
                                'q': 'president',
                                'type': 'advisory_opinions'})
        assert response.status_code == 200

        # This is mostly copy/pasted from the dict-based query. This is not a
        # very meaningful test but helped to ensure we're using the
        # elasitcsearch_dsl correctly.
        expected_query = {"query": {"bool": {
                 "must": [
                     {"term": {"_type": "advisory_opinions"}},
                     {"match": {"_all": "president"}},
                     ],
                 "should": [
                     {"match": {"no": "president"}},
                     {"match_phrase": {"_all": {"query": "president", "slop": 50}}},
                     ]
                 }},
            "highlight": {"fields": {"description": {}, "summary": {}, "no": {}, "text": {}, "name": {}}},
            "_source": {"exclude": "text"},
            "from": 0,
            "size": 20}

        es_search.assert_called_with(body=expected_query,
                                     index=mock.ANY,
                                     doc_type=mock.ANY)

    @patch.object(es, 'search')
    def test_query_dsl_phrase_search(self, es_search):
        response = self.app.get('/v1/legal/search/', query_string={
                                'q': '"electronic filing"',
                                'type': 'advisory_opinions'})
        assert response.status_code == 200

        # This is mostly copy/pasted from the dict-based query. This is not a
        # very meaningful test but helped to ensure we're using the
        # elasitcsearch_dsl correctly.
        expected_query = {"query": {"bool": {
                 "must": [
                     {"term": {"_type": "advisory_opinions"}},
                     {"match_phrase": {"_all": "electronic filing"}},
                     ],
                 "should": [
                     {"match": {"no": '"electronic filing"'}},
                     {"match_phrase": {"_all": {"query": '"electronic filing"', "slop": 50}}},
                     ]
                 }},
            "highlight": {"fields": {"description": {}, "summary": {}, "no": {}, "text": {}, "name": {}},
                          "highlight_query": {"bool": {"must": [{"match_phrase": {"_all": "electronic filing"}}]}}},
            "_source": {"exclude": "text"},
            "from": 0,
            "size": 20}

        es_search.assert_called_with(body=expected_query,
                                     index=mock.ANY,
                                     doc_type=mock.ANY)



class LegalPhraseParseTests(unittest.TestCase):
    def test_parse_query_no_phrase(self):
        parsed = parse_query_string('hello world')
        assert parsed == dict(terms=['hello world'], phrases=[])

    def test_parse_query_with_phrase(self):
        parsed = parse_query_string('require "electronic filing" 2016')
        assert parsed == dict(terms=['require', '2016'], phrases=['electronic filing'])

    def test_parse_query_with_many_phrases(self):
        parsed = parse_query_string('require "electronic filing" 2016 "sans computer"')
        assert parsed == dict(terms=['require', '2016'], phrases=['electronic filing', 'sans computer'])

    def test_parse_query_with_only_phrase(self):
        parsed = parse_query_string('"electronic filing"')
        assert parsed == dict(terms=[], phrases=['electronic filing'])

    def test_parse_query_terms_after_phrase(self):
        parsed = parse_query_string('"electronic filing" 2016')
        assert parsed == dict(terms=['2016'], phrases=['electronic filing'])


class LegalPhraseSearchTests(unittest.TestCase):
    def setUp(self):
        self.app = rest.app.test_client()

    @patch.object(es, 'search')
    def test_with_only_phrase(self, es_search):
        es_search.return_value = {'hits': {'hits': [], 'total': 0}}
        response = self.app.get('/v1/legal/search/', query_string=dict(q='"electronic filing"', type='advisory_opinions'))

        assert response.status_code == 200
        assert es_search.call_count == 1

        _, args = es_search.call_args
        query = args['body']
        assert query['query']['bool']['must'], "Expected query to have path `query.bool.must`"

        # Get the first `match_phrase` in the `must` clause
        must_clause = query['query']['bool']['must']
        match_phrase = next((q for q in must_clause if 'match_phrase' in q), None)
        assert match_phrase == {'match_phrase': {'_all': 'electronic filing'}}, "Could not find a `match_phrase` with the key phrase"

        # No `match` clause for terms
        match = next((q for q in must_clause if 'match' in q), None)
        assert match is None, "Unexpected `match` clause"

    @patch.object(es, 'search')
    def test_with_terms_and_phrase(self, es_search):
        es_search.return_value = {'hits': {'hits': [], 'total': 0}}
        response = self.app.get('/v1/legal/search/', query_string=dict(q='required "electronic filing" 2016', type='advisory_opinions'))

        assert response.status_code == 200
        assert es_search.call_count == 1

        _, args = es_search.call_args
        query = args['body']
        assert query['query']['bool']['must'], "Expected query to have path `query.bool.must`"

        # Get the first `match_phrase` in the `must` clause
        must_clause = query['query']['bool']['must']
        match_phrase = next((q for q in must_clause if 'match_phrase' in q), None)
        assert match_phrase == {'match_phrase': {'_all': 'electronic filing'}}, "Could not find a `match_phrase` with the key phrase"

        match = next((q for q in must_clause if 'match' in q), None)
        assert match == {'match': {'_all': 'required 2016'}}, "Expected `match` clause for non-phrase terms"

    @patch.object(es, 'search')
    def test_with_terms_and_many_phrases(self, es_search):
        es_search.return_value = {'hits': {'hits': [], 'total': 0}}
        response = self.app.get('/v1/legal/search/', query_string=dict(
            q='"vice president" required "electronic filing" 2016',
            type='advisory_opinions'))

        assert response.status_code == 200
        assert es_search.call_count == 1

        _, args = es_search.call_args
        query = args['body']
        assert query['query']['bool']['must'], "Expected query to have path `query.bool.must`"

        # Get all the `match_phrase`s in the `must` clause
        must_clause = query['query']['bool']['must']
        match_phrases = [q for q in must_clause if 'match_phrase' in q]
        assert len(match_phrases) == 2
        assert match_phrases[0] == {'match_phrase': {'_all': 'vice president'}}, "Could not find a `match_phrase` with the key phrase"
        assert match_phrases[1] == {'match_phrase': {'_all': 'electronic filing'}}, "Could not find a `match_phrase` with the key phrase"

        match = next((q for q in must_clause if 'match' in q), None)
        assert match == {'match': {'_all': 'required 2016'}}, "Expected `match` clause for non-phrase terms"
