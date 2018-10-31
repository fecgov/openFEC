import pytest
import unittest

from webservices.legal_docs.advisory_opinions import (
    parse_ao_citations,
    parse_regulatory_citations,
    parse_statutory_citations,
    validate_statute_citation,
    validate_regulation_citation,
    fix_citations,
)

EMPTY_SET = set()


@pytest.mark.parametrize("text,ao_nos,expected", [
    ("1994-01", {"1994-01"}, {"1994-01"}),
    ("Nothing here", {"1994-01"}, EMPTY_SET),
    ("1994-01 not in filter set", {"1994-02"}, EMPTY_SET),
    ("1994-01 remove duplicates 1994-01", {"1994-01"}, {"1994-01"}),
    ("1994-01 find multiple 1994-02", {"1994-01", "1994-02"}, {"1994-01", "1994-02"}),
    ("1994-01not a word boundary", {"1994-01"}, EMPTY_SET),
    ("1994-doesn't match pattern", {"1994-01"}, EMPTY_SET),
    ("1994-123 works if the serial number has 3 digits", {"1994-123"}, {"1994-123"}),
    ("1994-1 works if the citation drops leading 0 in serial number", {"1994-01"}, {"1994-01"}),
    ("1994-01 also works if the actual AO drops leading 0 in serial number", {"1994-1"}, {"1994-1"}),
])
def test_parse_ao_citations(text, ao_nos, expected):
    ao_component_to_name_map = {tuple(map(int, a.split('-'))): a for a in ao_nos}
    assert parse_ao_citations(text, ao_component_to_name_map) == expected

@pytest.mark.parametrize("title,section,expected", [
    ("52", "10-Day", False),
    ("2", "431", True),
    ("2", "590", False),
    ("18", "590", True),
    ("18", "100", True),
    ("18", "620", False),
    ("26", "9001", True),
    ("26", "9050", False),
    ("26", "501", True),
    ("26", "525", False),
    ("52", "30101", True),
    ("26", "30201", False),
    ("123", "123456", True),
])
def test_validate_statute_citation(title, section, expected):
    assert validate_statute_citation(title, section) == expected

@pytest.mark.parametrize("text,expected", [
    ("2 U.S.C. 432", set([(52, '30102')])),
    ("52 U.S.C. 30116(a", set([(52, '30116')])),
    ("52 USC § 30116a", set([(52, '30116a')])),
    ("2 U.S.C. 441a-1", set([(52, '30117')])),
    (" 2 U.S.C. §437f", set([(52, '30108')])),
    ("52 U.S.C. §§ 30101-30146", set([(52, '30101')])),
    ("52 U.S.C. § 30101", set([(52, '30101')])),
    (" 2 USC §437f **test with no . in USC**", set([(52, '30108')])),
    ("52 U.S.C. § 30101 **newline needed to ensure two entries**,\n 52 USC. § 30101 other words", set([(52, '30101')])),
    ("18 U.S.C. 613 (1970)", set([(18, '613')])),
    # Test multiples
    ("52 U.S.C §§ 30106(c), 30107(a)(7) other words.", set([(52, '30106'), (52, '30107')])),
    ("2 U.S.C. §§431(9) and 439a;", set([(52, '30101'), (52, '30114')])),
    ("2 U.S.C. 441b, 441c, 441e.", set([(52, '30118'), (52, '30119'), (52, '30121')])),
    ("52 U.S.C. 30101, 30108 and 10 days.", set([(52, '30101'), (52, '30108')])),
    ("18 U.S.C. §§610, 611, 613, 614 and 615.", set([(18, '610'), (18, '611'), (18, '613'), (18, '613'), (18, '614'), (18, '615')])),
    ("2 U.S.C. §§434(b)(2)(A) and (3)(A), and 431(13) *we need the sentence to end*.", set([(52, '30104'), (52, '30101')])),
    ("2 U.S.C. 439a and 11 CFR Part 113.", set([(52, '30114')])),
    ("52 U.S.C. §§ 30101(4) (defining political committee), 30104(a), (b) (reporting requirements of political committees).", set([(52, '30101'), (52, '30104')])),
    ("2 U.S.C. 432(e)(1), 433, and 434(a).", set([(52, '30102'), (52, '30103'), (52, '30104')])),
])
def test_parse_statutory_citations(text, expected):
    assert parse_statutory_citations(text) == expected


@pytest.mark.parametrize("title,part,expected", [
    ("11", "123c", False),
    ("11", "1", True),
    ("11", "9", False),
    ("11", "100", True),
    ("11", "121", False),
    ("11", "200", True),
    ("11", "210", False),
    ("11", "300", True),
    ("11", "310", False),
    ("11", "9001", True),
    ("11", "9100", False),
    ("12", "544", True),
    ("11", "400", True),
    # Check on 11 CFR 140.8-142
])
def test_validate_regulation_citation(title, part, expected):
    assert validate_regulation_citation(title, part) == expected


@pytest.mark.parametrize("text,expected", [
    ("11 CFR 113.2", set([(11, 113, 2)])),
    ("11 CFR §9034.4(b)(4)", set([(11, 9034, 4)])),
    # Doubles
    ("11 CFR 300.60 and 11 CFR 300.62", set([(11, 300, 60), (11, 300, 62)])),
    ("11 C.F.R. § 100.15", set([(11, 100, 15)])),
    ("11 C.F.R. § 100.15 **newline needed to ensure two entries**,\n 11 C.F.R. § 100.15", set([(11, 100, 15)])),
    ("11 CFR 300.60 through 300.65", set([(11, 300, 60), (11, 300, 65)])),
    ("11 C.F.R. §§ 100.73,100.132; The next", set([(11, 100, 73), (11, 100, 132)])),
    ("11 C.F.R. §§ 100.5(g)(4)(ii)(F) and 110.3(a)(3)(ii)(F)",
        set([(11, 100, 5), (11, 110, 3)])),
    ("11 CFR 300.60 and 300.61.", set([(11, 300, 60), (11, 300, 61)])),
    # Three or more
    ("2 U.S.C. 432(e)(1), 433, and 434(a); 11 CFR 101.1, 102.1, and 104.1; Then the 10-day rule applies.", set([(11, 101, 1), (11, 102, 1), (11, 104, 1)])),
    ("11 CFR 100.7(a)(1), 110.1(b)(3), 110.2(b)(3), and 110.3(g)",
            set([(11, 100, 7), (11, 110, 1), (11, 110, 2), (11, 110, 3)])),
    ("11 CFR 101.1, 102.1, 103.1, 104.1 and 105.1; Then the 10-day rule applies.",
        set([(11, 101, 1), (11, 102, 1), (11, 103, 1), (11, 104, 1), (11, 105, 1)])),
    # Sets
    ("11 CFR 100.4(b)(15) and 100.7(b)(17) as 11 CFR 100.6(b)(20) and 100.8(b)(20)", set([(11, 100, 4), (11, 100, 7), (11, 100, 6), (11, 100, 8)])),


])
def test_parse_regulatory_citations(text, expected):
    assert parse_regulatory_citations(text) == expected


class TestManualCitations(unittest.TestCase):
    def test_exclude_citations(self):
        original_ao_citations = set(['2011-12', '2017-03', '2014-18', '2010-11', '2004-41', '2007-13', '1996-26', '2005-17', '2017-01', '2016-02', '2012-21', '2012-23', '2014-11', '2002-15', '2006-12', '2015-16', '2014-21'])
        expected_citations = set(['2017-03', '2014-18', '2004-41', '2007-13', '1996-26', '2005-17', '2017-01', '2016-02', '2012-21', '2012-23', '2014-11', '2002-15', '2006-12', '2014-21'])

        fixed_citations = fix_citations('2017-03', 'ao', original_ao_citations)
        assert fixed_citations == expected_citations

    def test_include_citations(self):
        original_reg_citations = set([(11, 110, 4), (11, 110, 1), (11, 102, 9), (11, 102, 6), (11, 114, 5), (11, 100, 8), (11, 114, 1), (11, 100, 5), (11, 103, 3), (11, 104, 14), (11, 100, 6), (11, 102, 8), (11, 114, 7)])
        expected_citations = set([(11, 110, 4), (11, 110, 1), (11, 102, 9), (11, 102, 6), (11, 114, 5), (11, 100, 8), (11, 114, 1), (11, 100, 5), (11, 103, 3), (11, 104, 14), (11, 100, 6), (11, 102, 8), (11, 114, 7), (11, 110, 3)])
        fixed_citations = fix_citations('1999-40', 'regulation', original_reg_citations)
        assert fixed_citations == expected_citations
