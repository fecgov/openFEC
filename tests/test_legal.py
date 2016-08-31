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

def es_search(q, index, size, es_from):
    _type = q["query"]["bool"]["must"][0]["term"]["_type"]
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

        # This is mostly copy/pasted from the code to test
        # elasticsearch_dsl. This is not a very meaningful test but helped to
        # ensure we're using the dsl correctly.
        expected_query = {"query": {"bool": {"must": [{"term": {"no": "1993-02"}},
                          {"term": {"_type": "advisory_opinions"}}]}},
                          "_source": {"exclude": "text"}, "size": 200}
        es_search.assert_called_with(body=expected_query,
                                     doc_type=mock.ANY,
                                     index=mock.ANY)
        result = json.loads(codecs.decode(response.data))

@patch('webservices.rest.legal.es.search', es_search)
class SearchTest(unittest.TestCase):
    def setUp(self):
        self.app = rest.app.test_client()

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

    def test_type_search(self):
        response = self.app.get('/v1/legal/search/' +
                                '?q=president&type=advisory_opinions')
        assert response.status_code == 200
        result = json.loads(codecs.decode(response.data))
        assert result == {
            'total_advisory_opinions': 2,
            'advisory_opinions': [{'highlights': ['a', 'b']},
              {'highlights': ['c', 'd']}], 'total_all': 2}


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

        (query,), _ = es_search.call_args
        assert query['query']['bool']['must'], "Expected query to have path `query.bool.must`"

        # Get the first `match_phrase` in the `must` clause
        must_clause = query['query']['bool']['must']
        match_phrase = next((q for q in must_clause if 'match_phrase' in q), None)
        assert match_phrase == {'match_phrase': {'text': 'electronic filing'}}, "Could not find a `match_phrase` with the key phrase"

        # No `match` clause for terms
        match = next((q for q in must_clause if 'match' in q), None)
        assert match is None, "Unexpected `match` clause"

    @patch.object(es, 'search')
    def test_with_terms_and_phrase(self, es_search):
        es_search.return_value = {'hits': {'hits': [], 'total': 0}}
        response = self.app.get('/v1/legal/search/', query_string=dict(q='required "electronic filing" 2016', type='advisory_opinions'))

        assert response.status_code == 200
        assert es_search.call_count == 1

        (query,), _ = es_search.call_args
        assert query['query']['bool']['must'], "Expected query to have path `query.bool.must`"

        # Get the first `match_phrase` in the `must` clause
        must_clause = query['query']['bool']['must']
        match_phrase = next((q for q in must_clause if 'match_phrase' in q), None)
        assert match_phrase == {'match_phrase': {'text': 'electronic filing'}}, "Could not find a `match_phrase` with the key phrase"

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

        (query,), _ = es_search.call_args
        assert query['query']['bool']['must'], "Expected query to have path `query.bool.must`"

        # Get all the `match_phrase`s in the `must` clause
        must_clause = query['query']['bool']['must']
        match_phrases = [q for q in must_clause if 'match_phrase' in q]
        assert len(match_phrases) == 2
        assert match_phrases[0] == {'match_phrase': {'text': 'vice president'}}, "Could not find a `match_phrase` with the key phrase"
        assert match_phrases[1] == {'match_phrase': {'text': 'electronic filing'}}, "Could not find a `match_phrase` with the key phrase"

        match = next((q for q in must_clause if 'match' in q), None)
        assert match == {'match': {'_all': 'required 2016'}}, "Expected `match` clause for non-phrase terms"
