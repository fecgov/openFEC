import unittest
import unittest.mock as mock

from webservices.legal_docs import load_legal_docs, reclassify_statutory_citation


class TestGetCitations(unittest.TestCase):
    def test_reclassify_statutory_citation(self):
        # spot check a few cases from the csv
        assert reclassify_statutory_citation.reclassify_statutory_citation(
            '2', '431'
        ) == ('52', '30101')
        assert reclassify_statutory_citation.reclassify_statutory_citation(
            '2', '437g'
        ) == ('52', '30109')
        assert reclassify_statutory_citation.reclassify_statutory_citation(
            '2', '441a-1'
        ) == ('52', '30117')

        # and a fallback
        assert reclassify_statutory_citation.reclassify_statutory_citation(
            '99', '12345'
        ) == ('99', '12345')

    @mock.patch.object(reclassify_statutory_citation, 'reclassify_statutory_citation')
    def test_get_citations_statute(self, reclassify_statutory_citation):
        reclassify_statutory_citation.return_value = ('99', '31999')
        citation_text = [
            '2 U.S.C. 23',
            '2 U.S.C. 23a',
            '2 U.S.C. 23a-1',
            '4 U.S.C. 23a-1(a)(i)',
            '4 U.S.C. 24ff',
        ]

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
        assert reclassify_statutory_citation.call_args_list == expected_calls

        assert us_code[0]['text'] == '99 U.S.C. 31999'
        assert us_code[1]['text'] == '99 U.S.C. 31999'
        assert us_code[2]['text'] == '99 U.S.C. 31999'
        assert us_code[3]['text'] == '99 U.S.C. 31999(a)(i)'
        assert us_code[4]['text'] == '99 U.S.C. 31999'

        url = us_code[0]['url']
        assert url == 'https://www.govinfo.gov/link/uscode/99/31999'

    def test_get_citations_regulation(self):
        citation_text = [
            '11 C.F.R. 23.421',
        ]

        citations = load_legal_docs.get_citations(citation_text)
        regulations = citations['regulations']
        assert len(regulations) == 1

        assert regulations[0]['url'] == '/regulations/23-421/CURRENT'

    def test_get_citations_regulation_no_section(self):
        citation_text = [
            '11 C.F.R. 19',
        ]

        citations = load_legal_docs.get_citations(citation_text)
        regulations = citations['regulations']
        assert len(regulations) == 1

        assert regulations[0]['url'] == '/regulations/19/CURRENT'
