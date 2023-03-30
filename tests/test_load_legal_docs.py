# import unittest
# from unittest.mock import patch
# from webservices.legal_docs import (
#     index_regulations,
#     index_statutes,
#     create_index,
# )

# from webservices.legal_docs.load_legal_docs import (
#     get_title_26_statutes,
#     get_title_52_statutes,
#     get_xml_tree_from_url,
# )

# from zipfile import ZipFile
# from tempfile import NamedTemporaryFile


# class ElasticSearchMock:
#     class ElasticSearchIndicesMock:
#         def delete(self, index):
#             assert index in ['docs', 'archived_murs', 'case_index']

#         def create(self, index, mappings):
#             assert index in ['docs', 'archived_murs']
#             assert mappings

#         def update_aliases(self, body):
#             pass

#     def __init__(self, dictToIndex):
#         self.dictToIndex = dictToIndex
#         self.indices = ElasticSearchMock.ElasticSearchIndicesMock()

#     def index(self, index, doc, id):
#         assert self.dictToIndex == doc

#     def delete_by_query(self, index, body, doc_type):
#         assert index == 'case_index'


# def get_es_with_doc(doc):
#     def get_es():
#         return ElasticSearchMock(doc)

#     return get_es


# def mock_xml(xml):
#     def request_zip(url, stream=False):
#         with NamedTemporaryFile('w+') as f:
#             f.write(xml)
#             f.seek(0)
#             with NamedTemporaryFile('w+') as n:
#                 with ZipFile(n.name, 'w') as z:
#                     z.write(f.name)
#                     return open(n.name, 'rb')

#     return request_zip


# def mock_archived_murs_get_request(html):
#     def request_murs_data(url, stream=False):
#         if stream:
#             return [b'ABC', b'def']
#         else:
#             return RequestResult(html)

#     return request_murs_data


# def get_credential_mock(var, default):
#     return 'https://eregs.api.com/'


# class RequestResult:
#     def __init__(self, result):
#         self.result = result
#         self.text = result

#     def json(self):
#         return self.result


# def mock_get_regulations(url):
#     if url.endswith('regulation'):
#         return RequestResult(
#             {'versions': [{'version': 'versionA', 'regulation': 'reg104'}]}
#         )
#     if url.endswith('reg104/versionA'):
#         return RequestResult(
#             {
#                 'children': [
#                     {
#                         'children': [
#                             {
#                                 'label': ['104', '1'],
#                                 'title': 'Section 104.1 Title',
#                                 'text': 'sectionContentA',
#                                 'children': [
#                                     {'text': 'sectionContentB', 'children': []}
#                                 ],
#                             }
#                         ]
#                     }
#                 ]
#             }
#         )


# class S3Objects:
#     def __init__(self):
#         self.objects = []

#     def filter(self, Prefix):
#         return [o for o in self.objects if o.key.startswith(Prefix)]


# class BucketMock:
#     def __init__(self, keys):
#         self.objects = S3Objects()
#         self.keys = keys

#     def put_object(self, Key, Body, ContentType, ACL):
#         assert Key in self.keys


# def get_bucket_mock(keys):
#     def get_bucket():
#         return BucketMock(keys)

#     return get_bucket


# class IndexStatutesTest(unittest.TestCase):
#     @patch(
#         'webservices.legal_docs.load_legal_docs.requests.get', mock_xml('<test></test>')
#     )
#     def test_get_xml_tree_from_url(self):
#         etree = get_xml_tree_from_url('anything.com')
#         assert etree.getroot().tag == 'test'

#     @patch(
#         'webservices.utils.create_es_client',
#         get_es_with_doc(
#             {
#                 'type': 'statutes',
#                 'name': 'title',
#                 'chapter': '1',
#                 'title': '26',
#                 'no': '123',
#                 'text': '   title  content ',
#                 'doc_id': '/us/usc/t26/s123',
#                 'url': 'https://www.govinfo.gov/link/uscode/26/123',
#                 'sort1': 26,
#                 'sort2': 123,
#             }
#         ),
#     )
#     @patch(
#         'webservices.legal_docs.load_legal_docs.requests.get',
#         mock_xml(
#             """<?xml version="1.0" encoding="UTF-8"?>
#             <uscDoc xmlns="http://xml.house.gov/schemas/uslm/1.0">
#             <subtitle identifier="/us/usc/t26/stH">
#             <chapter identifier="/us/usc/t26/stH/ch1">
#             <section identifier="/us/usc/t26/s123">
#             <heading>title</heading>
#             <subsection>content</subsection>
#             </section></chapter></subtitle></uscDoc>
#             """
#         ),
#     )
#     def test_title_26(self):
#         get_title_26_statutes()

#     @patch(
#         'webservices.utils.create_es_client',
#         get_es_with_doc(
#             {
#                 'type': 'statutes',
#                 'subchapter': 'I',
#                 'doc_id': '/us/usc/t52/s123',
#                 'chapter': '1',
#                 'text': '   title  content ',
#                 'url': 'https://www.govinfo.gov/link/uscode/52/123',
#                 'title': '52',
#                 'name': 'title',
#                 'no': '123',
#                 'sort1': 52,
#                 'sort2': 123,
#             }
#         ),
#     )
#     @patch(
#         'webservices.legal_docs.load_legal_docs.requests.get',
#         mock_xml(
#             """<?xml version="1.0" encoding="UTF-8"?>
#             <uscDoc xmlns="http://xml.house.gov/schemas/uslm/1.0">
#             <subtitle identifier="/us/usc/t52/stIII">
#             <subchapter identifier="/us/usc/t52/stIII/ch1/schI">
#             <section identifier="/us/usc/t52/s123">
#             <heading>title</heading>
#             <subsection>content</subsection>
#             </section></subchapter></subtitle></uscDoc>
#             """
#         ),
#     )
#     def test_title_52(self):
#         get_title_52_statutes()

#     @patch('webservices.legal_docs.load_legal_docs.get_title_52_statutes', lambda: '')
#     @patch('webservices.legal_docs.load_legal_docs.get_title_26_statutes', lambda: '')
#     def test_index_statutes(self):
#         index_statutes()


# class IndexRegulationsTest(unittest.TestCase):
#     @patch(
#         'webservices.legal_docs.load_legal_docs.env.get_credential', get_credential_mock
#     )
#     @patch('webservices.legal_docs.load_legal_docs.requests.get', mock_get_regulations)
#     @patch(
#         'webservices.utils.create_es_client',
#         get_es_with_doc(
#             {
#                 'type': 'regulations',
#                 'text': 'sectionContentA sectionContentB',
#                 'no': '104.1',
#                 'name': 'Title',
#                 'url': '/regulations/104-1/versionA#104-1',
#                 'doc_id': '104_1',
#                 'sort1': 104,
#                 'sort2': 1,
#             }
#         ),
#     )
#     def test_index_regulations(self):
#         index_regulations()

#     @patch('webservices.legal_docs.load_legal_docs.env.get_credential', lambda e, d: '')
#     def test_no_env_variable(self):
#         index_regulations()


# class InitializeLegalDocsTest(unittest.TestCase):
#     @patch('webservices.utils.create_es_client', get_es_with_doc({}))
#     def test_create_index(self):
#         create_index()
