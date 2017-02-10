import re

import pytest

from webservices.legal_docs.advisory_opinions import get_filtered_matches

EMPTY_SET = set()

@pytest.mark.parametrize("text,filter_set,expected", [
    ("1994-01", {"1994-01"}, {"1994-01"}),
    ("Nothing here", {"1994-01"}, EMPTY_SET),
    ("1994-01 not in filter set", {"1994-02"}, EMPTY_SET),
    ("1994-01 remove duplicates 1994-01", {"1994-01"}, {"1994-01"}),
    ("1994-01 find multiple 1994-02", {"1994-01", "1994-02"}, {"1994-01", "1994-02"}),
    ("1994-01not a word boundary", {"1994-01"}, EMPTY_SET),
    ("1994-doesn't match pattern", {"1994-01"}, EMPTY_SET),
])
def test_parse_regulatory_citations(text, filter_set, expected):
    regex = re.compile(r'\b\d{4,4}-\d+\b')
    assert get_filtered_matches(text, regex, filter_set) == expected
