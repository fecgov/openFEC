import unittest
from mock import patch
from webservices.load_legal_docs import (index_statutes, index_regulations,
    index_advisory_opinions, delete_advisory_opinions_from_s3,
    load_advisory_opinions_into_s3, remove_legal_docs, get_xml_tree_from_url,
    get_title_26_statutes, get_title_52_statutes, load_archived_murs,
    delete_murs_from_s3, delete_murs_from_es)
from zipfile import ZipFile
from tempfile import NamedTemporaryFile
import json

class ElasticSearchMock:
    def __init__(self, dictToIndex):
        self.dictToIndex = dictToIndex
    def search():
        pass

    def index(self, index, doc_type, doc, id):
        print(doc)
        assert self.dictToIndex == doc

    def delete_index(self, index):
        assert index == 'docs'

    def create_index(self, index, mappings):
        assert index == 'docs'
        assert mappings

    def delete_all(self, index, doc_type):
        assert index == 'docs'
        assert doc_type == 'murs'

def get_es_with_doc(doc):
    def get_es():
        return ElasticSearchMock(doc)
    return get_es

def mock_xml(xml):
    def request_zip(url, stream=False):
        with NamedTemporaryFile('w+') as f:
            f.write(xml)
            f.seek(0)
            with NamedTemporaryFile('w+') as n:
                with ZipFile(n.name, 'w') as z:
                    z.write(f.name)
                    return open(n.name, 'rb')

    return request_zip

def mock_archived_murs_get_request(html):
    def request_murs_data(url, stream=False):
        if stream:
            return [b'ABC', b'def']
        else:
            return RequestResult(html)
    return request_murs_data

class Engine:
    def __init__(self, legal_loaded):
        self.legal_loaded = legal_loaded

    def __iter__(self):
        return self.result.__iter__()

    def __next__(self):
        return self.result.__next__()

    def fetchone(self):
        return self.result[0]

    def fetchall(self):
        return self.result

    def connect(self):
        return self

    def execution_options(self, stream_results):
        return self

    def execute(self, sql):
        if sql == 'select document_id from document':
            self.result = [(1,), (2,)]
        if 'fileimage' in sql:
            return [(1, 'ABC'.encode('utf8'))]
        if 'EXISTS' in sql:
            self.result = [(self.legal_loaded,)]
        if 'count' in sql:
            self.result = [(5,)]
        if 'DOCUMENT_ID' in sql:
            self.result = [(123, 'textAB', 'description123', 'category123', 'id123',
                           'name4U', 'summaryABC', 'tags123', 'no123', 'date123')]
        return self


class Db:
    def __init__(self, legal_loaded=True):
        self.engine = Engine(legal_loaded)

def get_credential_mock(var, default):
    return 'https://eregs.api.com/'

class RequestResult:
    def __init__(self, result):
        self.result = result
        self.text = result

    def json(self):
        return self.result

def mock_get_regulations(url):
    if url.endswith('regulation'):
        return RequestResult({'versions': [{'version': 'versionA',
                             'regulation': 'reg104'}]})
    if url.endswith('reg104/versionA'):
        return RequestResult({'children': [{'children': [{'label': ['104', '1'],
                               'title': 'Section 104.1 Title',
                               'text': 'sectionContentA',
                               'children': [{'text': 'sectionContentB',
                               'children': []}]}]}]})

class obj:
    def __init__(self, key):
        self.key = key

    def delete(self):
        pass

class S3Objects:
    def __init__(self, objects):
        self.objects = objects

    def filter(self, Prefix):
        return [o for o in self.objects if o.key.startswith(Prefix)]

class BucketMock:
    def __init__(self, existing_pdfs, key):
        self.objects = S3Objects(existing_pdfs)
        self.key = key

    def put_object(self, Key, Body, ContentType, ACL):
        assert Key == self.key

def get_bucket_mock(existing_pdfs, key):
    def get_bucket():
        return BucketMock(existing_pdfs, key)
    return get_bucket

class IndexStatutesTest(unittest.TestCase):
    @patch('webservices.load_legal_docs.requests.get', mock_xml('<test></test>'))
    def test_get_xml_tree_from_url(self):
        etree = get_xml_tree_from_url('anything.com')
        assert etree.getroot().tag == 'test'

    @patch('webservices.utils.get_elasticsearch_connection',
            get_es_with_doc({'name': 'title',
            'chapter': '1', 'title': '26', 'no': '123',
            'text': '   title  content ', 'doc_id': '/us/usc/t26/s123',
            'url': 'http://api.fdsys.gov/link?collection=uscode&title=26&' +
                    'year=mostrecent&section=123'}))
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
            'url': 'http://api.fdsys.gov/link?collection=uscode&title=52&' +
                   'year=mostrecent&section=123',
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

    @patch('webservices.load_legal_docs.get_title_52_statutes', lambda: '')
    @patch('webservices.load_legal_docs.get_title_26_statutes', lambda: '')
    def test_index_statutes(self):
        index_statutes()

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

    @patch('webservices.load_legal_docs.env.get_credential', lambda e, d: '')
    def test_no_env_variable(self):
        index_regulations()

class IndexAdvisoryOpinionsTest(unittest.TestCase):
    @patch('webservices.load_legal_docs.db', Db())
    @patch('webservices.load_legal_docs.env.get_credential',
        lambda cred: cred + '123')
    @patch('webservices.utils.get_elasticsearch_connection',
            get_es_with_doc({'category': 'category123',
            'summary': 'summaryABC', 'no': 'no123', 'date': 'date123',
            'tags': 'tags123', 'name': 'name4U', 'text': 'textAB',
            'description': 'description123',
            'url': 'https://bucket123.s3.amazonaws.com/legal/aos/123.pdf',
            'doc_id': 123, 'id': 'id123'}))
    def test_advisory_opinion_load(self):
        index_advisory_opinions()

    @patch('webservices.load_legal_docs.db', Db(False))
    def test_no_legal_loaded(self):
        index_advisory_opinions()

class LoadAdvisoryOpinionsIntoS3Test(unittest.TestCase):
    @patch('webservices.load_legal_docs.db', Db())
    @patch('webservices.load_legal_docs.get_bucket',
     get_bucket_mock([obj('legal/aos/2.pdf')], 'legal/aos/1.pdf'))
    @patch('webservices.load_legal_docs.env.get_credential',
        lambda cred: cred + '123')
    def test_load_advisory_opinions_into_s3(self):
        load_advisory_opinions_into_s3()

    @patch('webservices.load_legal_docs.db', Db())
    @patch('webservices.load_legal_docs.get_bucket',
     get_bucket_mock([obj('legal/aos/1.pdf'), obj('legal/aos/2.pdf')],
     'legal/aos/1.pdf'))
    @patch('webservices.load_legal_docs.env.get_credential',
        lambda cred: cred + '123')
    def test_load_advisory_opinions_into_s3_already_loaded(self):
        load_advisory_opinions_into_s3()

    @patch('webservices.load_legal_docs.get_bucket',
     get_bucket_mock([obj('legal/aos/2.pdf')], 'legal/aos/1.pdf'))
    def test_delete_advisory_opinions_from_s3(self):
        delete_advisory_opinions_from_s3()

class RemoveLegalDocsTest(unittest.TestCase):
    @patch('webservices.utils.get_elasticsearch_connection',
    get_es_with_doc({}))
    def test_remove_legal_docs(self):
        remove_legal_docs()

def raise_pdf_exception(PDF):
    raise Exception('Could not parse PDF')

class LoadArchivedMursTest(unittest.TestCase):
    @patch('webservices.utils.get_elasticsearch_connection',
        get_es_with_doc(json.load(open('tests/data/archived_mur_doc.json'))))
    @patch('webservices.load_legal_docs.get_bucket',
        get_bucket_mock([obj('legal/murs/2.pdf')], 'legal/murs/1.pdf'))
    @patch('webservices.load_legal_docs.slate.PDF', lambda t: ['page1', 'page2'])
    @patch('webservices.load_legal_docs.env.get_credential', lambda e: 'bucket123')
    @patch('webservices.load_legal_docs.requests.get',
        mock_archived_murs_get_request(open('tests/data/archived_mur_data.html').read()))
    def test_base_case(self):
        load_archived_murs()

    @patch('webservices.utils.get_elasticsearch_connection',
        get_es_with_doc(json.load(open('tests/data/archived_mur_empty_doc.json'))))
    @patch('webservices.load_legal_docs.get_bucket',
        get_bucket_mock([obj('legal/murs/2.pdf')], 'legal/murs/1.pdf'))
    @patch('webservices.load_legal_docs.slate.PDF', lambda t: ['page1', 'page2'])
    @patch('webservices.load_legal_docs.env.get_credential', lambda e: 'bucket123')
    @patch('webservices.load_legal_docs.requests.get',
        mock_archived_murs_get_request(open('tests/data/archived_mur_empty_data.html').read()))
    def test_with_empty_data(self):
        load_archived_murs()

    @patch('webservices.utils.get_elasticsearch_connection',
        get_es_with_doc(json.load(open('tests/data/archived_mur_empty_doc.json'))))
    @patch('webservices.load_legal_docs.get_bucket',
        get_bucket_mock([obj('legal/murs/2.pdf')], 'legal/murs/1.pdf'))
    @patch('webservices.load_legal_docs.slate.PDF', lambda t: ['page1', 'page2'])
    @patch('webservices.load_legal_docs.env.get_credential', lambda e: 'bucket123')
    @patch('webservices.load_legal_docs.requests.get',
        mock_archived_murs_get_request(open('tests/data/archived_mur_bad_subject.html').read()))
    def test_bad_parse(self):
        with self.assertRaises(Exception):
            load_archived_murs()

    @patch('webservices.utils.get_elasticsearch_connection',
        get_es_with_doc(json.load(open('tests/data/archived_mur_empty_doc.json'))))
    @patch('webservices.load_legal_docs.get_bucket',
        get_bucket_mock([obj('legal/murs/2.pdf')], 'legal/murs/1.pdf'))
    @patch('webservices.load_legal_docs.slate.PDF', lambda t: ['page1', 'page2'])
    @patch('webservices.load_legal_docs.env.get_credential', lambda e: 'bucket123')
    @patch('webservices.load_legal_docs.requests.get',
        mock_archived_murs_get_request(open('tests/data/archived_mur_bad_citation.html').read()))
    def test_bad_citation(self):
        with self.assertRaises(Exception):
            load_archived_murs()

    @patch('webservices.utils.get_elasticsearch_connection',
        get_es_with_doc(json.load(open('tests/data/archived_mur_bad_pdf_doc.json'))))
    @patch('webservices.load_legal_docs.get_bucket',
        get_bucket_mock([obj('legal/murs/2.pdf')], 'legal/murs/1.pdf'))
    @patch('webservices.load_legal_docs.env.get_credential', lambda e: 'bucket123')
    @patch('webservices.load_legal_docs.requests.get',
        mock_archived_murs_get_request(open('tests/data/archived_mur_data.html').read()))
    @patch('webservices.load_legal_docs.slate.PDF', raise_pdf_exception)
    def test_with_bad_pdf(self):
        load_archived_murs()

    @patch('webservices.load_legal_docs.get_bucket',
        get_bucket_mock([obj('legal/murs/2.pdf')], 'legal/murs/1.pdf'))
    def test_delete_murs_from_s3(self):
        delete_murs_from_s3()

    @patch('webservices.utils.get_elasticsearch_connection', get_es_with_doc({}))
    def test_delete_murs_from_es(self):
        delete_murs_from_es()
