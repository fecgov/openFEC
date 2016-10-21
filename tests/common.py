import os
import json
import codecs
import unittest
import subprocess

from webtest import TestApp
from nplusone.ext.flask_sqlalchemy import NPlusOne

import manage
from webservices import rest
from webservices import __API_VERSION__


TEST_CONN = os.getenv('SQLA_TEST_CONN', 'postgresql:///cfdm_unit_test')

rest.app.config['NPLUSONE_RAISE'] = True
NPlusOne(rest.app)


def _reset_schema():
    rest.db.engine.execute('drop schema if exists public cascade;')
    rest.db.engine.execute('drop schema if exists disclosure cascade;')
    rest.db.engine.execute('create schema public;')
    rest.db.engine.execute('create schema disclosure;')


def _reset_schema_for_integration():
    rest.db.engine.execute('drop schema if exists public cascade;')
    rest.db.engine.execute('drop schema if exists disclosure cascade;')
    rest.db.engine.execute('create schema public;')


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
        _reset_schema()

    def setUp(self):
        self.connection = rest.db.engine.connect()
        self.transaction = self.connection.begin()

    def tearDown(self):
        self.transaction.rollback()
        self.connection.close()
        rest.db.session.remove()

    @classmethod
    def tearDownClass(cls):
        _reset_schema()
        cls.app_context.pop()


class ApiBaseTest(BaseTestCase):

    @classmethod
    def setUpClass(cls):
        super(ApiBaseTest, cls).setUpClass()
        manage.load_districts()
        manage.update_functions()
        rest.db.metadata.create_all(
            rest.db.engine,
            tables=[
                each.__table__ for each in rest.db.Model._decl_class_registry.values()
                if hasattr(each, '__table__')
            ]
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
        self.assertEquals(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        self.assertNotEqual(result, [], "Empty response!")
        self.assertEqual(result['api_version'], __API_VERSION__)
        return result

    def _results(self, qry):
        response = self._response(qry)
        return response['results']


def assert_dicts_subset(first, second):
    expected = {key: first.get(key) for key in second}
    assert expected == second


class IntegrationTestCase(BaseTestCase):
    """Base test case for tests that depend on the test data subset.
    """
    @classmethod
    def setUpClass(cls):
        #super(IntegrationTestCase, cls).setUpClass()
        rest.app.config['TESTING'] = True
        rest.app.config['SQLALCHEMY_DATABASE_URI'] = TEST_CONN
        rest.app.config['PRESERVE_CONTEXT_ON_EXCEPTION'] = False
        cls.app = rest.app.test_client()
        cls.client = TestApp(rest.app)
        cls.app_context = rest.app.app_context()
        cls.app_context.push()
        _reset_schema_for_integration()
        with open(os.devnull, 'w') as null:
            subprocess.check_call(
                ['pg_restore', './data/subset.dump', '--dbname', TEST_CONN, '--no-acl', '--no-owner'],
                stdout=null,
            )
