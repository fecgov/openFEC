import pytest

from webservices.legal_docs.current_murs import (
    parse_regulatory_citations,
    parse_statutory_citations,
)

@pytest.mark.parametrize("test_input,case_id,entity_id,expected", [
    ("110", 1, 2,
        [{'text': '110', 'title': '11', 'type': 'regulation', 'url': '/regulations/110/CURRENT'}]),
    ("110.21", 1, 2,
        [{'text': '110.21', 'title': '11', 'type': 'regulation', 'url': '/regulations/110-21/CURRENT'}]),
    ("114.5(a)(3)", 1, 2,
        [{'text': '114.5(a)(3)', 'title': '11', 'type': 'regulation', 'url': '/regulations/114-5/CURRENT'}]),
    ("114.5(a)(3)-(5)", 1, 2,
        [{'text': '114.5(a)(3)-(5)', 'title': '11', 'type': 'regulation', 'url': '/regulations/114-5/CURRENT'}]),
    ("102.17(a)(l)(i), (b)(l), (b)(2), and (c)(3)", 1, 2,
        [{'text': '102.17(a)(l)(i), (b)(l), (b)(2), and (c)(3)', 'title': '11',
          'type': 'regulation', 'url': '/regulations/102-17/CURRENT'}
         ]),
    ("102.5(a)(2); 104.3(a)(4)(i); 114.5(a)(3)-(5); 114.5(g)(1)", 1, 2,
        [{'text': '102.5(a)(2)', 'title': '11', 'type': 'regulation', 'url': '/regulations/102-5/CURRENT'},
         {'text': '104.3(a)(4)(i)', 'title': '11', 'type': 'regulation', 'url': '/regulations/104-3/CURRENT'},
         {'text': '114.5(a)(3)-(5)', 'title': '11', 'type': 'regulation', 'url': '/regulations/114-5/CURRENT'},
         {'text': '114.5(g)(1)', 'title': '11', 'type': 'regulation', 'url': '/regulations/114-5/CURRENT'}
         ]),
])
def test_parse_regulatory_citations(test_input, case_id, entity_id, expected):
    assert parse_regulatory_citations(test_input, case_id, entity_id) == expected

@pytest.mark.parametrize("test_input,case_id,entity_id,expected", [
    ("431", 1, 2,    # With reclassification
        [{'text': '431',
          'title': '2',
          'type': 'statute',
          'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html'
          '&title=52&section=30101'}]),
    ("30116", 1, 2,  # Already reclassified
        [{'text': '30116',
          'title': '52',
          'type': 'statute',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=52&section=30116'}]),
    ("434(a)(11)", 1, 2,
        [{'text': '434(a)(11)',
          'title': '2',
          'type': 'statute',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=52&section=30104'}]),
    ("9999", 1, 2,
        [{'text': '9999',
          'title': '2',
          'type': 'statute',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=9999'}]),
    ("9993(c)(2)", 1, 2,
        [{'text': '9993(c)(2)',
          'title': '2',
          'type': 'statute',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=9993'}]),
    ("9993(a)(4) formerly 438(a)(4)", 1, 2,
        [{'text': '9993(a)(4)',
          'title': '2',
          'type': 'statute',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=9993'}]),
    ("9116(a)(2)(A), 9114(b) (formerly 441a(a)(2)(A), 434(b)), 30116(f) (formerly 441a(f))", 1, 2,
        [{'text': '9116(a)(2)(A)',
          'title': '2',
          'type': 'statute',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=9116'},
        {'text': '9114(b)',
          'title': '2',
          'type': 'statute',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=9114'},
        {'text': '30116(f)',
          'title': '52',
          'type': 'statute',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=52&section=30116'}]),
    ("9993(a)(4) (formerly 438(a)(4)", 1, 2,  # No matching ')' for (formerly
        [{'text': '9993(a)(4)',
          'title': '2',
          'type': 'statute',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=9993'}]),
])
def test_parse_statutory_citations(test_input, case_id, entity_id, expected):
    assert parse_statutory_citations(test_input, case_id, entity_id) == expected
