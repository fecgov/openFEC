import codecs
import json
import unittest

from webservices import rest


class ApiBaseTest(unittest.TestCase):
    @property
    def __test__(self):
        """Don't test the base class"""
        return self.__class__ != ApiBaseTest

    def setUp(self):
        rest.app.config['TESTING'] = True
        self.app = rest.app.test_client()
        self.ctx = rest.app.app_context()
        self.ctx.push()
        self.longMessage = True
        self.maxDiff = None

    def tearDown(self):
        self.ctx.pop()

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

