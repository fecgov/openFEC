import mock
import unittest
import urllib


from webservices import load_legal_docs

class TestMapCitations(unittest.TestCase):
    def test_citations(self):
        pass

class TestGetCitations(unittest.TestCase):

    def test_map_pre2012_citation(self):
        # spot check a few cases from the csv
        assert load_legal_docs.map_pre2012_citation('2', '431') == ('52', '30101')
        assert load_legal_docs.map_pre2012_citation('2', '437g') == ('52', '30109')
        assert load_legal_docs.map_pre2012_citation('42', '1973aa-1a') == ('52', '10503')

        # and a fallback
        assert load_legal_docs.map_pre2012_citation('99', '12345') == ('99', '12345')


    @mock.patch.object(load_legal_docs, 'map_pre2012_citation')
    def test_get_citations_statute(self, map_pre2012_citation):
        map_pre2012_citation.return_value = ('99', '31999')
        citation_text = ''.join([
            '2 U.S.C. 23<br>',
            '2 U.S.C. 23a<br>',
            '2 U.S.C. 23a-1<br>',
            '4 U.S.C. 23a-1(a)(i)<br>',
            '4 U.S.C. 24ff<br>',
        ])

        expected_calls = [
            mock.call('2', '23'),
            mock.call('2', '23a'),
            mock.call('2', '23a-1'),
            mock.call('4', '23a-1'),
            mock.call('4', '24ff'),
        ]

        citations = load_legal_docs.get_citations(citation_text)
        us_code = citations['us_code']

        assert len(us_code) == len(expected_calls)
        assert map_pre2012_citation.call_args_list == expected_calls

        assert us_code[0]['text'] == '99 U.S.C. 31999'
        assert us_code[1]['text'] == '99 U.S.C. 31999'
        assert us_code[2]['text'] == '99 U.S.C. 31999'
        assert us_code[3]['text'] == '99 U.S.C. 31999(a)(i)'
        assert us_code[4]['text'] == '99 U.S.C. 31999'

        parsed_url = urllib.parse.urlparse(us_code[0]['url'])
        query = urllib.parse.parse_qs(parsed_url.query)

        assert query == dict(collection=['uscode'], year=['mostrecent'], title=['99'], section=['31999'])

    def test_get_citations_regulation(self):
        citation_text = ''.join([
            '11 C.F.R. 23.421<br>',
        ])

        citations = load_legal_docs.get_citations(citation_text)
        regulations = citations['regulations']
        assert len(regulations) == 1

        parsed_url = urllib.parse.urlparse(regulations[0]['url'])
        query = urllib.parse.parse_qs(parsed_url.query)

        assert query == dict(collection=['cfr'], year=['mostrecent'], titlenum=['11'], partnum=['23'], sectionnum=['421'])


    def test_get_citations_regulation_no_section(self):
        citation_text = ''.join([
            '11 C.F.R. 19<br>',
        ])

        citations = load_legal_docs.get_citations(citation_text)
        regulations = citations['regulations']
        assert len(regulations) == 1

        parsed_url = urllib.parse.urlparse(regulations[0]['url'])
        query = urllib.parse.parse_qs(parsed_url.query)

        assert query == dict(collection=['cfr'], year=['mostrecent'], titlenum=['11'], partnum=['19'])
