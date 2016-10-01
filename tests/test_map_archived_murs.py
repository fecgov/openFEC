import mock
import unittest
import urllib

from webservices import load_legal_docs


class TestRemapCitations(unittest.TestCase):
    def mur_factory(self, us_code_citations, regulations_citations, id='mur1'):
        """Create a MUR partial object for tests"""
        return dict(id=id, citations=dict(us_code=us_code_citations, regulations=regulations_citations))

    def dict_to_es_result(self, result):
        """Convert a MUR partial object to a dict suitable for ES libs. i.e. a
        dict that the raw elasticsearch-py would return."""
        return dict(id=result['id'], _source=result)


    @mock.patch('webservices.utils.get_elasticsearch_connection')
    @mock.patch('elasticsearch.helpers.scan')
    @mock.patch('elasticsearch.helpers.bulk')
    def test_citations(self, mock_bulk, mock_scan, mock_get_elasticsearch_connection):
        es_mock = mock.Mock()
        mock_get_elasticsearch_connection.return_value = es_mock


        # Should be unchanged
        regulations_citations = [dict(text="11 C.F.R. 6.1", url="http://api.fdsys.gov/link?collection=cfr&titlenum=11&partnum=6&year=mostrecent&sectionnum=1")]

        mur1 = self.mur_factory(
            us_code_citations=[
                dict(text="2 U.S.C. 431", url="http://api.fdsys.gov/link?collection=uscode&title=2&year=mostrecent&section=431"),
                dict(text="2 U.S.C. 432", url="http://api.fdsys.gov/link?collection=uscode&title=2&year=mostrecent&section=432"),
            ],
            regulations_citations=regulations_citations,
            id='mur1'
        )
        expected_mur1 = self.mur_factory(
            us_code_citations=[
                # re-mapped citations
                dict(text="52 U.S.C. 30101", url="http://api.fdsys.gov/link?collection=uscode&title=52&year=mostrecent&section=30101"),
                dict(text="52 U.S.C. 30102", url="http://api.fdsys.gov/link?collection=uscode&title=52&year=mostrecent&section=30102"),
            ],
            regulations_citations=regulations_citations,
            id='mur1'
        )


        mur2 = self.mur_factory(
            us_code_citations=[
                dict(text="2 U.S.C. 433", url="http://api.fdsys.gov/link?collection=uscode&title=2&year=mostrecent&section=433"),
                dict(text="2 U.S.C. 434", url="http://api.fdsys.gov/link?collection=uscode&title=2&year=mostrecent&section=434"),
            ],
            regulations_citations=regulations_citations,
            id='mur2'
        )
        expected_mur2 = self.mur_factory(
            us_code_citations=[
                # re-mapped citations
                dict(text="52 U.S.C. 30103", url="http://api.fdsys.gov/link?collection=uscode&title=52&year=mostrecent&section=30103"),
                dict(text="52 U.S.C. 30104", url="http://api.fdsys.gov/link?collection=uscode&title=52&year=mostrecent&section=30104"),
            ],
            regulations_citations=regulations_citations,
            id='mur2'
        )

        expected_bulk_ops = [dict(_op_type='update', _id='mur1', doc=expected_mur1), dict(_op_type='update', _id='mur2', doc=expected_mur2)]

        mock_scan.return_value = (self.dict_to_es_result(mur1), self.dict_to_es_result(mur2))
        mock_bulk.return_value = [2, []] # Update count, error list

        load_legal_docs.remap_archived_murs_citations()

        # Assert no real calls to ES
        es_mock.assert_not_called()

        # Scan was called exactly once
        assert len(mock_scan.mock_calls) == 1

        # Assert bulk was called exactly once
        assert len(mock_bulk.mock_calls) == 1

        # Check bulk was called with the re-mapped citations
        args, kwargs = mock_bulk.call_args
        _, bulk_ops = args
        assert list(bulk_ops) == expected_bulk_ops


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
        citation_text = [
            '11 C.F.R. 23.421',
        ]

        citations = load_legal_docs.get_citations(citation_text)
        regulations = citations['regulations']
        assert len(regulations) == 1

        parsed_url = urllib.parse.urlparse(regulations[0]['url'])
        query = urllib.parse.parse_qs(parsed_url.query)

        assert query == dict(collection=['cfr'], year=['mostrecent'], titlenum=['11'], partnum=['23'], sectionnum=['421'])


    def test_get_citations_regulation_no_section(self):
        citation_text = [
            '11 C.F.R. 19',
        ]

        citations = load_legal_docs.get_citations(citation_text)
        regulations = citations['regulations']
        assert len(regulations) == 1

        parsed_url = urllib.parse.urlparse(regulations[0]['url'])
        query = urllib.parse.parse_qs(parsed_url.query)

        assert query == dict(collection=['cfr'], year=['mostrecent'], titlenum=['11'], partnum=['19'])
