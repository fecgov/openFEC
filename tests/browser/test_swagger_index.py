# """
# Called by `pytest` or `pytest -v tests/browser/test_swagger_index.py`
# Checks the local version of Swagger
#
# The current functionality checks that the local version loads
# and that JavaScript creates the expected number of sections
# and that the legal section is created.
# TODO: add a check for whether the page fails to load, e.g. content-security-policy error
# TODO: add another mark for more extensive testing.
# Deeper tests will test specific sections, fields, error states, and API responses
# More complicated browser tests should not be part of the everyday build as they could add minutes to the build time.
# Instead, those tests should be called on demand and executed by themselves.
# """

import unittest
import pytest

from tests.browser.swagger_index import swagger_index

@pytest.mark.browser_quick
def test_swagger_index_loads(browser):
  
  the_page = swagger_index(browser)

  the_page.load()

  assert the_page.last_element_as_expected(), "Browser test: The last element did not load correctly"

  assert the_page.all_sections_exist(), "Browser test: Unexpected number of sections exist"
