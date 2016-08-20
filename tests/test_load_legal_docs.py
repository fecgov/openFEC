from mock import patch, MagicMock
import unittest
from webservices.load_legal_docs import *
from zipfile import ZipFile

class ElasticSearchMock:
    def __init__(self, dictToIndex):
        self.dictToIndex = dictToIndex
    def search():
        pass

    def index(self, index, doc_type, doc, id):
        print(doc)
        assert self.dictToIndex == doc

def get_es_with_doc(doc):
    def get_es():
        return ElasticSearchMock(doc)
    return get_es

def mock_xml(xml):
    def request_zip(url, stream=False):
        with open('test_xml.xml', 'w') as f:
            f.write(xml)

        with ZipFile('xml_test.zip', 'w') as z:
            z.write('test_xml.xml')

        return open('xml_test.zip', 'rb')

    return request_zip

class Engine:
    def __iter__(self):
        return self.result.__iter__()

    def __next__(self):
        return self.result.__next__()

    def fetchone(self):
        return self.result

    def execute(self, sql):
        if 'EXISTS' in sql:
            self.result = [(True,)]
        if 'count' in sql:
            self.result = [(5,)]
        if 'DOCUMENT_ID' in sql:
            self.result = [(123, 'textAB', 'description123', 'category123', 'id123',
                           'name4U', 'summaryABC', 'tags123', 'no123', 'date123')]
        return self


class Db:
    engine = Engine()

def get_credential_mock(var, default):
    print(var)
    return 'https://eregs.api.com/'

class RequestResult:
    def __init__(self, result):
        self.result = result

    def json(self):
        return self.result

def mock_get_regulations(url):
    if url.endswith('regulation'):
        return RequestResult({'versions': [{'version': 'versionA',
                             'regulation': 'reg104'}]})
    print(url)
    if url.endswith('reg104/versionA'):
        return RequestResult({'children': [{'children': [{'label': ['104', '1'],
                               'title': 'Section 104.1 Title',
                               'text': 'sectionContentA',
                               'children': [{'text': 'sectionContentB',
                               'children': []}]}]}]})
class IndexStatutesTest(unittest.TestCase):
    @patch('webservices.load_legal_docs.requests.get', mock_xml('<test></test>'))
    def test_get_xml_tree_from_url(self):
        etree = get_xml_tree_from_url('anything.com')
        self.assertEquals(etree.getroot().tag, 'test')

    @patch('webservices.utils.get_elasticsearch_connection',
            get_es_with_doc({'name': 'title',
            'chapter': '1', 'title': '26', 'no': '123',
            'text': '   title  content ', 'doc_id': '/us/usc/t26/s123',
            'url': 'https://www.gpo.gov/fdsys/pkg/USCODE-2014-title26/' +
            'pdf/USCODE-2014-title26-subtitleH-chap1-sec123.pdf'}))
    @patch('webservices.load_legal_docs.requests.get', mock_xml(
            """<?xml version="1.0" encoding="UTF-8"?>
            <uscDoc xmlns="http://xml.house.gov/schemas/uslm/1.0">
            <subtitle identifier="/us/usc/t26/stH">
            <chapter identifier="/us/usc/t26/stH/ch1">
            <section identifier="/us/usc/t26/s123">
            <heading>title</heading>
            <subsection>content</subsection>
            </section></chapter></subtitle></uscDoc>
            """))
    def test_title_26(self):
        get_title_26_statutes()

    @patch('webservices.utils.get_elasticsearch_connection',
            get_es_with_doc({'subchapter': 'I',
            'doc_id': '/us/usc/t52/s123', 'chapter': '1',
            'text': '   title  content ',
            'url': 'https://www.gpo.gov/fdsys/pkg/USCODE-2014-title52/pdf/' +
                'USCODE-2014-title52-subtitleIII-chap1-subchapI-sec123.pdf',
            'title': '52', 'name': 'title', 'no': '123'}))
    @patch('webservices.load_legal_docs.requests.get', mock_xml(
            """<?xml version="1.0" encoding="UTF-8"?>
            <uscDoc xmlns="http://xml.house.gov/schemas/uslm/1.0">
            <subtitle identifier="/us/usc/t52/stIII">
            <subchapter identifier="/us/usc/t52/stIII/ch1/schI">
            <section identifier="/us/usc/t52/s123">
            <heading>title</heading>
            <subsection>content</subsection>
            </section></subchapter></subtitle></uscDoc>
            """))
    def test_title_52(self):
        get_title_52_statutes()

class IndexRegulationsTest(unittest.TestCase):
    @patch('webservices.load_legal_docs.env.get_credential', get_credential_mock)
    @patch('webservices.load_legal_docs.requests.get', mock_get_regulations)
    @patch('webservices.utils.get_elasticsearch_connection',
            get_es_with_doc({'text': 'sectionContentA sectionContentB',
            'no': '104.1', 'name': 'Title',
            'url': '/regulations/104-1/versionA#104-1',
            'doc_id': '104_1'}))
    def test_index_regulations(self):
        index_regulations()

class IndexAdvisoryOpinionsTest(unittest.TestCase):
    @patch('webservices.load_legal_docs.db', Db())
    @patch('webservices.utils.get_elasticsearch_connection',
            side_effect=get_es_with_doc({'category': 'category123',
            'summary': 'summaryABC', 'no': 'no123', 'date': 'date123',
            'tags': 'tags123', 'name': 'name4U', 'text': 'textAB',
            'description': 'description123',
            'url': 'https://None.s3.amazonaws.com/legal/aos/123.pdf',
            'doc_id': 123, 'id': 'id123'}))
    def test_advisory_opinion_load(self, es_mock):
        index_advisory_opinions()
