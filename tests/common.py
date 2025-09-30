import codecs
import json
import os
import subprocess
import unittest

from flask import current_app
from webtest import TestApp

from webservices.rest import create_app, db
from webservices import __API_VERSION__

from webservices.legal.constants import (TEST_CASE_INDEX, TEST_ARCH_MUR_INDEX, TEST_AO_INDEX,
                                         TEST_CASE_ALIAS, TEST_ARCH_MUR_ALIAS, TEST_AO_ALIAS,
                                         TEST_RM_INDEX, TEST_RM_ALIAS)

from webservices.legal.utils_es import create_test_indices, create_es_client
from tests.test_legal.test_legal_data import document_dictionary
from tests.test_legal.test_rm_data import rm_document_dictionary
from jdbc_utils import to_jdbc_url
from sqlalchemy import text

TEST_CONN = os.getenv('SQLA_TEST_CONN', 'postgresql:///cfdm_unit_test')
ALL_INDICES = [TEST_CASE_INDEX, TEST_AO_INDEX, TEST_ARCH_MUR_INDEX, TEST_RM_INDEX]


def _setup_extensions(db):
    with db.engine.begin() as conn:
        conn.execute(text('create extension if not exists btree_gin;'))


def _reset_schema(db):
    if current_app.config['TESTING']:
        with db.engine.begin() as conn:
            conn.execute(text('drop schema if exists public cascade;'))
            conn.execute(text('drop schema if exists disclosure cascade;'))
            conn.execute(text('drop schema if exists staging cascade;'))
            conn.execute(text('drop schema if exists fecapp cascade;'))
            conn.execute(text('drop schema if exists real_efile cascade;'))
            conn.execute(text('drop schema if exists test_efile cascade;'))
            conn.execute(text('drop schema if exists auditsearch cascade;'))
            conn.execute(text('create schema public;'))
            conn.execute(text('create schema disclosure;'))
            conn.execute(text('create schema staging;'))
            conn.execute(text('create schema fecapp;'))
            conn.execute(text('create schema real_efile;'))
            conn.execute(text('create schema test_efile;'))
            conn.execute(text('create schema auditsearch;'))


class BaseTestCase(unittest.TestCase):
    _extensions_set_up = False  # prevent multiple clients for ext setup
    _application = False

    @classmethod
    def setUpClass(cls):
        if not BaseTestCase._application:
            BaseTestCase.application = create_app(test_config='testing')
            BaseTestCase._application = True
        cls.app = cls.application.test_client()
        cls.client = TestApp(cls.application)
        cls.app_context = cls.application.app_context()
        cls.app_context.push()

        if not cls._extensions_set_up:
            _setup_extensions(db)
            cls._extensions_set_up = True

    def setUp(self):
        self.connection = db.engine.connect()
        self.transaction = self.connection.begin()

    def tearDown(self):
        self.transaction.rollback()
        db.session.remove()
        self.connection.close()

    @classmethod
    def tearDownClass(cls):
        cls.app_context.pop()
        db.engine.dispose()  # fix too many client issues


class ApiBaseTest(BaseTestCase):
    @classmethod
    def setUpClass(cls):
        super(ApiBaseTest, cls).setUpClass()
        _reset_schema(db)
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

        with db.engine.begin() as connection:
            db.metadata.create_all(bind=connection,)

    def setUp(self):
        super(ApiBaseTest, self).setUp()
        self.longMessage = True
        self.maxDiff = None
        self.request_context = self.application.test_request_context()
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

    def _response_rm(self, qry):
        response_rm = self.app.get(qry)
        self.assertEqual(response_rm.status_code, 200)
        result = json.loads(codecs.decode(response_rm.data))
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
        self.request_context = self.application.test_request_context()
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

    def _response_rm(self, qry):
        response_rm = self._results(qry)
        self.assertNotEqual(response_rm["total_rulemakings"], 0)
        return response_rm

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

    def _results_rm(self, qry):
        response_rm = self._response_rm(qry)
        self.assertNotEqual(response_rm["total_rulemakings"], 0)
        return response_rm["rulemakings"]


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
    insert_documents("rulemakings", TEST_RM_ALIAS, es_client, rm_document_dictionary)


def insert_documents(doc_type, index, es_client, doc_dict=document_dictionary):
    for doc in doc_dict[doc_type]:
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
