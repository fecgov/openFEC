import codecs
import json
import os
import subprocess
import unittest

from webtest import TestApp
from nplusone.ext.flask_sqlalchemy import NPlusOne

from jdbc_utils import to_jdbc_url
from webservices import rest
from webservices import __API_VERSION__

from webservices.legal_docs import (create_test_indices, TEST_CASE_INDEX, TEST_ARCH_MUR_INDEX, TEST_AO_INDEX,
                                    TEST_CASE_ALIAS, TEST_ARCH_MUR_ALIAS, TEST_AO_ALIAS)
from webservices.utils import create_es_client
from tests.test_legal_data import document_dictionary

TEST_CONN = os.getenv('SQLA_TEST_CONN', 'postgresql:///cfdm_unit_test')
rest.app.config['NPLUSONE_RAISE'] = True
NPlusOne(rest.app)
ALL_INDICES = [TEST_CASE_INDEX, TEST_AO_INDEX, TEST_ARCH_MUR_INDEX]


def _setup_extensions():
    rest.db.engine.execute('create extension if not exists btree_gin;')


def _reset_schema():
    rest.db.engine.execute('drop schema if exists public cascade;')
    rest.db.engine.execute('drop schema if exists disclosure cascade;')
    rest.db.engine.execute('drop schema if exists staging cascade;')
    rest.db.engine.execute('drop schema if exists fecapp cascade;')
    rest.db.engine.execute('drop schema if exists real_efile cascade;')
    rest.db.engine.execute('drop schema if exists auditsearch cascade;')
    rest.db.engine.execute('create schema public;')
    rest.db.engine.execute('create schema disclosure;')
    rest.db.engine.execute('create schema staging;')
    rest.db.engine.execute('create schema fecapp;')
    rest.db.engine.execute('create schema real_efile;')
    rest.db.engine.execute('create schema auditsearch;')


class BaseTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        rest.app.config['TESTING'] = True
        rest.app.config['SQLALCHEMY_DATABASE_URI'] = TEST_CONN
        rest.app.config['PRESERVE_CONTEXT_ON_EXCEPTION'] = False
        cls.app = rest.app.test_client()
        cls.client = TestApp(rest.app)
        cls.app_context = rest.app.app_context()
        cls.app_context.push()
        _setup_extensions()

    def setUp(self):
        self.connection = rest.db.engine.connect()
        self.transaction = self.connection.begin()

    def tearDown(self):
        self.transaction.rollback()
        self.connection.close()
        rest.db.session.remove()

    @classmethod
    def tearDownClass(cls):
        cls.app_context.pop()


class ApiBaseTest(BaseTestCase):
    @classmethod
    def setUpClass(cls):
        super(ApiBaseTest, cls).setUpClass()
        _reset_schema()
        with open(os.devnull, 'w') as null:
            subprocess.check_call(
                [
                    'psql',
                    '-f',
                    'data/migrations/V0039__states_and_zips_data.sql',
                    TEST_CONN,
                ],
                stdout=null,
            )

        rest.db.metadata.create_all(
            rest.db.engine,
            tables=[
                each.__table__
                for each in rest.db.Model._decl_class_registry.values()
                if hasattr(each, '__table__')
            ],
        )

    def setUp(self):
        super(ApiBaseTest, self).setUp()
        self.longMessage = True
        self.maxDiff = None
        self.request_context = rest.app.test_request_context()
        self.request_context.push()

    def tearDown(self):
        super(ApiBaseTest, self).tearDown()
        self.request_context.pop()

    def _response(self, qry):
        response = self.app.get(qry)
        self.assertEqual(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        self.assertNotEqual(result, [], "Empty response!")
        self.assertEqual(result['api_version'], __API_VERSION__)
        return result

    def _results(self, qry):
        response = self._response(qry)
        return response['results']


class ElasticSearchBaseTest(BaseTestCase):
    @classmethod
    def setUpClass(cls):
        super(ElasticSearchBaseTest, cls).setUpClass()
        cls.es_client = create_es_client()
        # ensure environment is completely clean before starting
        _delete_all_indices(cls.es_client)
        _create_all_indices()
        _insert_all_documents(cls.es_client)

    @classmethod
    def tearDownClass(cls):
        super(ElasticSearchBaseTest, cls).tearDownClass()
        _delete_all_indices(cls.es_client)

    def setUp(self):
        self.request_context = rest.app.test_request_context()
        self.request_context.push()

    def tearDown(self):
        self.request_context.pop()

    def _results(self, qry):
        response = self.app.get(qry)
        self.assertEqual(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        return result

    def _response(self, qry):
        response = self._results(qry)
        self.assertNotEqual(response["total_all"], 0)
        return response

    def _results_case(self, qry):
        response = self._response(qry)
        assert response["total_murs"] != 0 or response["total_adrs"] != 0 or response["total_admin_fines"] != 0
        return response

    def _results_adr_mur(self, qry):
        response = self._response(qry)
        assert response["total_murs"] != 0 or response["total_adrs"] != 0
        return response

    def _results_mur(self, qry):
        response = self._response(qry)
        self.assertNotEqual(response["total_murs"], 0)
        return response

    def _results_af(self, qry):
        response = self._response(qry)
        self.assertNotEqual(response["total_admin_fines"], 0)
        return response

    def _results_ao(self, qry):
        response = self._response(qry)
        self.assertNotEqual(response["total_advisory_opinions"], 0)
        return response["advisory_opinions"]

    def _results_statute(self, qry):
        response = self._response(qry)
        self.assertNotEqual(response["total_statutes"], 0)
        return response["statutes"]

    def _results_docs(self, qry):
        response = self._results(qry)
        self.assertEqual(len(response["docs"]), 1)
        return response["docs"]

    def _results_citations(self, qry):
        response = self._results(qry)
        self.assertNotEqual(len(response["citations"]), 0)
        return response["citations"]


def _create_all_indices():
    create_test_indices()


def _delete_all_indices(es_client):
    es_client.indices.delete(index=ALL_INDICES, ignore_unavailable=True)


def wait_for_refresh(es_client, index_name):
    es_client.indices.refresh(index=index_name)


def _insert_all_documents(es_client):
    insert_documents("murs", TEST_CASE_ALIAS, es_client)
    insert_documents("archived_murs", TEST_ARCH_MUR_ALIAS, es_client)
    insert_documents("adrs", TEST_CASE_ALIAS, es_client)
    insert_documents("admin_fines", TEST_CASE_ALIAS, es_client)
    insert_documents("statutes", TEST_AO_ALIAS, es_client)
    insert_documents("advisory_opinions", TEST_AO_ALIAS, es_client)
    insert_documents("ao_citations", TEST_AO_ALIAS, es_client)
    insert_documents("mur_citations", TEST_CASE_ALIAS, es_client)


def insert_documents(doc_type, index, es_client):
    for doc in document_dictionary[doc_type]:
        es_client.index(index=index, body=doc)

    wait_for_refresh(es_client, index)


def assert_dicts_subset(first, second):
    expected = {key: first.get(key) for key in second}
    assert expected == second


def get_test_jdbc_url():
    """
    Return the JDBC URL for TEST_CONN. If TEST_CONN cannot be successfully converted,
    it is probably the default Postgres instance with trust authentication
    """
    jdbc_url = to_jdbc_url(TEST_CONN)
    if jdbc_url is None:
        jdbc_url = "jdbc:" + TEST_CONN
    return jdbc_url
