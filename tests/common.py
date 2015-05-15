import os
import json
import codecs
import unittest
import subprocess

from webservices import rest


TEST_CONN = os.getenv('SQLA_TEST_CONN', 'postgresql:///cfdm-unit-test')


def _reset_schema():
    rest.db.engine.execute('drop schema if exists public cascade;')
    rest.db.engine.execute('create schema public;')


class BaseTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        rest.app.config['TESTING'] = True
        rest.app.config['SQLALCHEMY_DATABASE_URI'] = TEST_CONN
        cls.app = rest.app.test_client()
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
        rest.db.create_all()

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
        self.assertEqual(result['api_version'], '0.2')
        return result

    def assertResultsEqual(self, actual, expected, prefix=""):
        """This method provides some quick debugging info (rather than the
        cryptic "this 500 attribute dict is different than that one"). prefix
        is an identifier to see where we are in the tree
        Inspiration from 18f/hourglass's assertResultsEqual()"""
        if isinstance(expected, dict) and isinstance(actual, dict):
            self.assertDictsEqual(actual, expected, prefix)
        elif isinstance(expected, list) and isinstance(actual, list):
            self.assertListsEqual(actual, expected, prefix)
        else:
            self.assertEqual(actual, expected)

    def assertDictsEqual(self, actual, expected, prefix):
        """Match keys and values. Recurse"""
        actual_keys, expected_keys = set(actual.keys()), set(expected.keys())
        self.assertEqual(
            actual_keys, expected_keys,
            prefix + ": Different keys:\n"
            + ("Unique to actual: %s\n" % (actual_keys - expected_keys))
            + ("Unique to expected: %s" % (expected_keys - actual_keys)))
        for key in expected_keys:
            self.assertResultsEqual(actual[key], expected[key],
                                    prefix + '.' + key)

    def assertListsEqual(self, actual, expected, prefix):
        """Check length, order, and recurse"""
        self.assertEqual(
            len(actual), len(expected),
            prefix + ": Different number of elements "
            "(actual: %d, expected: %d)" % (len(actual), len(expected)))
        # Check for out of order. Note we can't use set as we might have an
        # unhashable type
        if len(actual) == len(expected) and all(a in expected for a in actual):
            self.assertEqual(actual, expected,
                             prefix + ": Sort order is wrong")
        for i in range(len(expected)):
            self.assertResultsEqual(actual[i], expected[i],
                                    prefix + '[%d]' % i)

    def prettyPrint(self, thing):
        """
        Pretty-printing for debugging purposes.
        """
        import pprint; pp = pprint.PrettyPrinter(indent=4)
        pp.pprint(thing)


class IntegrationTestCase(BaseTestCase):
    """Base test case for tests that depend on the test data subset.
    """

    @classmethod
    def setUpClass(cls):
        super(IntegrationTestCase, cls).setUpClass()
        with open(os.devnull, 'w') as null:
            subprocess.check_call(
                ['pg_restore', './data/subset.dump', '--dbname', TEST_CONN, '--no-acl', '--no-owner'],
                stdout=null,
            )
