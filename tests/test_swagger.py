import unittest
from apispec import utils, exceptions

import webservices.rest
import webservices.schemas  # needed to generate full spec
from webservices.spec import spec, format_docstring


class TestSwagger(unittest.TestCase):

    def test_swagger_valid(self):
        try:
            utils.validate_swagger(spec)
        except exceptions.SwaggerError as error:
            self.fail(str(error))

    def test_format_docstring(self):
        DOCSTRING = '''
        a
        b

        c
        '''

        after_format = format_docstring(DOCSTRING)
        expected_format = 'a b \n\n c'
        self.assertEqual(after_format, expected_format)

    def test_format_not_docstring(self):
        after_format = format_docstring(None)
        expected_format = ''
        self.assertEqual(after_format, expected_format)
