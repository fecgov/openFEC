import pytest

from webservices.load_current_murs import parse_regulatory_citations, parse_statutory_citations

@pytest.mark.parametrize("test_input,case_id,entity_id,expected", [
    ("110", 1, 2,
        ["https://api.fdsys.gov/link?collection=cfr&year=mostrecent&titlenum=11&partnum=110"]),
    ("110.21", 1, 2,
        ["https://api.fdsys.gov/link?collection=cfr&year=mostrecent&titlenum=11&partnum=110&sectionnum=21"]),
])
def test_parse_regulatory_citations(test_input, case_id, entity_id, expected):
    assert parse_regulatory_citations(test_input, case_id, entity_id) == expected

def test_parse_statutory_citations_with_reclassifications():
    assert parse_statutory_citations("431", 1, 2) == [
        "https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=52&section=30101"]

def test_parse_statutory_citations_no_reclassifications():
    assert parse_statutory_citations("30101", 1, 2) == [
        "https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=52&section=30101"]
