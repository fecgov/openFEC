import datetime
import subprocess
from unittest.mock import patch

import pytest

from tests.common import TEST_CONN, BaseTestCase

from webservices import rest
from webservices.legal_docs.advisory_opinions import (
    get_advisory_opinions,
    parse_ao_citations,
    parse_regulatory_citations,
    parse_statutory_citations,
    validate_statute_citation,
    validate_regulation_citation,
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


class TestLoadAdvisoryOpinions(BaseTestCase):
    @classmethod
    def setUpClass(cls):
        super(TestLoadAdvisoryOpinions, cls).setUpClass()
        subprocess.check_call(
            ["psql", TEST_CONN, "-f", "data/load_advisory_opinions_schema.sql"])

    @classmethod
    def tearDownClass(cls):
        subprocess.check_call(
            ["psql", TEST_CONN, "-c", "DROP SCHEMA aouser CASCADE"])
        super(TestLoadAdvisoryOpinions, cls).tearDownClass()

    def setUp(self):
        self.connection = rest.db.engine.connect()

    def tearDown(self):
        self.clear_test_data()
        self.connection.close()
        rest.db.session.remove()

    @patch("webservices.legal_docs.advisory_opinions.get_bucket")
    def test_pending_ao(self, get_bucket):
        expected_ao = {
            "no": "2017-01",
            "name": "An AO name",
            "summary": "An AO summary",
            "request_date": datetime.date(2016, 6, 10),
            "issue_date": datetime.date(2016, 12, 15),
            "is_pending": True,
            "status": "Pending",
            "ao_citations": [],
            "statutory_citations": [],
            "regulatory_citations": [],
            "aos_cited_by": [],
            "documents": [],
            "requestor_names": [],
            "requestor_types": [],
            "commenter_names": [],
            "representative_names": [],
            "sort1": -2017,
            "sort2": -1,
            "entities": []
        }
        self.create_ao(1, expected_ao)
        actual_ao = next(get_advisory_opinions(None))

        assert actual_ao == expected_ao

    @patch("webservices.legal_docs.advisory_opinions.get_bucket")
    def test_ao_with_entities(self, get_bucket):
        expected_requestor_names = ["The Manchurian Candidate", "Federation of Interstate Truckers"]
        expected_requestor_types = ["Federal candidate/candidate committee/officeholder", "Labor Organization"]
        expected_commenter_names = ["Tom Troll", "Harry Troll"]
        expected_representative_names = ["Dewey Cheetham and Howe LLC"]
        expected_ao = {
            "no": "2017-01",
            "name": "An AO name",
            "summary": "An AO summary",
            "request_date": datetime.date(2016, 6, 10),
            "issue_date": datetime.date(2016, 12, 15),
            "documents": [],
            "requestor_names": expected_requestor_names,
            "requestor_types": expected_requestor_types,
        }

        self.create_ao(1, expected_ao)
        for i, _ in enumerate(expected_requestor_names):
            self.create_requestor(1, i + 1, expected_requestor_names[i], expected_requestor_types[i])
        offset = len(expected_requestor_names)
        for i, _ in enumerate(expected_commenter_names):
            self.create_commenter(1, i + offset + 1, expected_commenter_names[i])
        offset += len(expected_commenter_names)
        for i, _ in enumerate(expected_representative_names):
            self.create_representative(1, i + offset + 1, expected_representative_names[i])

        actual_ao = next(get_advisory_opinions(None))

        assert set(actual_ao["requestor_names"]) == set(expected_requestor_names)
        assert set(actual_ao["requestor_types"]) == set(expected_requestor_types)
        assert set(actual_ao["commenter_names"]) == set(expected_commenter_names)
        assert set(actual_ao["representative_names"]) == set(expected_representative_names)

    @patch("webservices.legal_docs.advisory_opinions.get_bucket")
    def test_completed_ao_with_docs(self, get_bucket):
        ao_no = "2017-01"
        filename = "Some File.pdf"
        expected_document = {
            "document_id": 1,
            "category": "Final Opinion",
            "text": "Some Text",
            "description": "Some Description",
            "date": datetime.datetime(2017, 2, 9, 0, 0),
            "url": "/files/legal/aos/{0}/{1}".format(ao_no, filename.replace(' ', '-'))
        }
        expected_ao = {
            "no": ao_no,
            "name": "An AO name",
            "summary": "An AO summary",
            "request_date": datetime.date(2016, 6, 10),
            "issue_date": datetime.date(2016, 12, 15),
            "is_pending": True,
            "status": "Final",
            "documents": [expected_document],
        }
        self.create_ao(1, expected_ao)
        self.create_document(1, expected_document, filename)

        actual_ao = next(get_advisory_opinions(None))

        assert actual_ao["is_pending"] is False
        assert actual_ao["status"] == "Final"

        actual_document = actual_ao["documents"][0]
        for key in expected_document:
            assert actual_document[key] == expected_document[key]

    @patch("webservices.legal_docs.advisory_opinions.get_bucket")
    def test_ao_citations(self, get_bucket):
        ao1_document = {
            "document_id": 1,
            "category": "Final Opinion",
            "text": "Not an AO reference 1776-01",
            "description": "Some Description",
            "date": datetime.datetime(2017, 2, 9, 0, 0)
        }
        ao1 = {
            "no": "2017-01",
            "name": "1st AO name",
            "summary": "1st AO summary",
            "status": "Final",
            "request_date": datetime.date(2016, 6, 10),
            "issue_date": datetime.date(2016, 12, 15),
            "documents": [ao1_document],
        }

        ao2_document = {
            "document_id": 2,
            "category": "Final Opinion",
            "text": "Reference to AO 2017-01",
            "description": "Some Description",
            "date": datetime.datetime(2017, 2, 9, 0, 0)
        }
        ao2 = {
            "no": "2017-02",
            "name": "2nd AO name",
            "summary": "2nd AO summary",
            "status": "Final",
            "request_date": datetime.date(2016, 6, 10),
            "issue_date": datetime.date(2016, 12, 15),
            "documents": [ao2_document],
        }

        self.create_ao(1, ao1)
        self.create_document(1, ao1_document)
        self.create_ao(2, ao2)
        self.create_document(2, ao2_document)

        actual_aos = [ao for ao in get_advisory_opinions(None)]
        assert len(actual_aos) == 2

        actual_ao1 = next(filter(lambda a: a["no"] == "2017-01", actual_aos))
        actual_ao2 = next(filter(lambda a: a["no"] == "2017-02", actual_aos))

        assert actual_ao1["ao_citations"] == []
        assert actual_ao1["aos_cited_by"] == [{"no": "2017-02", "name": "2nd AO name"}]

        assert actual_ao2["ao_citations"] == [{"no": "2017-01", "name": "1st AO name"}]
        assert actual_ao2["aos_cited_by"] == []

    @patch("webservices.legal_docs.advisory_opinions.get_bucket")
    @patch("webservices.legal_docs.advisory_opinions.get_elasticsearch_connection")
    def test_statutory_citations(self, get_bucket, get_elasticsearch_connection):
        ao_document = {
            "document_id": 1,
            "category": "Final Opinion",
            "text": "A statutory citation 2 U.S.C. 431 and some text",
            "description": "Some Description",
            "date": datetime.datetime(2017, 2, 9, 0, 0)
        }
        ao = {
            "no": "2017-01",
            "name": "An AO name",
            "summary": "An AO summary",
            "status": "Final",
            "request_date": datetime.date(2016, 6, 10),
            "issue_date": datetime.date(2016, 12, 15),
            "documents": [ao_document],
        }

        self.create_ao(1, ao)
        self.create_document(1, ao_document)

        actual_ao = next(get_advisory_opinions(None))

        assert actual_ao["statutory_citations"] == [{'title': 52, 'section': '30101'}]

    @patch("webservices.legal_docs.advisory_opinions.get_bucket")
    @patch("webservices.legal_docs.advisory_opinions.get_elasticsearch_connection")
    def test_regulatory_citations(self, get_bucket, get_elasticsearch_connection):
        ao_document = {
            "document_id": 1,
            "category": "Final Opinion",
            "text": "A regulatory citation 11 CFR §9034.4(b)(4) and some text",
            "description": "Some Description",
            "date": datetime.datetime(2017, 2, 9, 0, 0)
        }
        ao = {
            "no": "2017-01",
            "name": "An AO name",
            "summary": "An AO summary",
            "status": "Final",
            "request_date": datetime.date(2016, 6, 10),
            "issue_date": datetime.date(2016, 12, 15),
            "documents": [ao_document],
        }

        self.create_ao(1, ao)
        self.create_document(1, ao_document)

        actual_ao = next(get_advisory_opinions(None))

        assert actual_ao["regulatory_citations"] == [{"title": 11, "part": 9034, "section": 4}]


    def create_ao(self, ao_id, ao):

        if "status" not in ao:
            ao["status"] = "Pending"

        self.connection.execute(
            "INSERT INTO aouser.ao (ao_id, ao_no, name, summary, req_date, issue_date, stage)"
            "VALUES (%s, %s, %s, %s, %s, %s, %s)",
            ao_id, ao["no"], ao["name"], ao["summary"], ao["request_date"], ao["issue_date"], ao_status_to_stage(ao["status"]))

    @patch("webservices.legal_docs.advisory_opinions.get_bucket")
    def test_ao_offsets(self, get_bucket):
        expected_ao1 = {
            "no": "2015-01",
            "name": "AO name1",
            "summary": "AO summary1",
            "request_date": datetime.date(2016, 6, 10),
            "issue_date": datetime.date(2016, 12, 15),
            "is_pending": True,
            "status": "Pending",
            "ao_citations": [],
            "statutory_citations": [],
            "regulatory_citations": [],
            "aos_cited_by": [],
            "documents": [],
            "requestor_names": [],
            "requestor_types": [],
            "commenter_names": [],
            "representative_names": [],
            "sort1": -2015,
            "sort2": -1,
            "entities": []
        }
        expected_ao2 = {
            "no": "2015-02",
            "name": "An AO name2",
            "summary": "An AO summary2",
            "request_date": datetime.date(2016, 6, 10),
            "issue_date": datetime.date(2016, 12, 15),
            "is_pending": True,
            "status": "Pending",
            "ao_citations": [],
            "statutory_citations": [],
            "regulatory_citations": [],
            "aos_cited_by": [],
            "documents": [],
            "requestor_names": [],
            "requestor_types": [],
            "commenter_names": [],
            "representative_names": [],
            "sort1": -2015,
            "sort2": -2,
            "entities": []
        }
        expected_ao3 = {
            "no": "2016-01",
            "name": "An AO name3",
            "summary": "An AO summary3",
            "request_date": datetime.date(2016, 6, 10),
            "issue_date": datetime.date(2016, 12, 15),
            "is_pending": True,
            "status": "Pending",
            "ao_citations": [],
            "statutory_citations": [],
            "regulatory_citations": [],
            "aos_cited_by": [],
            "documents": [],
            "requestor_names": [],
            "requestor_types": [],
            "commenter_names": [],
            "representative_names": [],
            "sort1": -2016,
            "sort2": -1,
            "entities": []
        }
        self.create_ao(1, expected_ao1)
        self.create_ao(2, expected_ao2)
        self.create_ao(3, expected_ao3)

        gen = get_advisory_opinions(None)
        assert(next(gen)) == expected_ao1
        assert(next(gen)) == expected_ao2
        assert(next(gen)) == expected_ao3

        gen = get_advisory_opinions('2015-02')
        assert(next(gen)) == expected_ao2
        assert(next(gen)) == expected_ao3

    def create_document(self, ao_id, document, filename='201801_C.pdf'):
        self.connection.execute(
            """
            INSERT INTO aouser.document
            (document_id, ao_id, category, ocrtext, fileimage, description, document_date, filename)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)""",
            document["document_id"],
            ao_id,
            document["category"],
            document["text"],
            document["text"],
            document["description"],
            document["date"],
            filename
        )

    def create_requestor(self, ao_id, entity_id, requestor_name, requestor_type):
        entity_type_id = self.connection.execute(
            "SELECT entity_type_id FROM aouser.entity_type "
            " WHERE description = %s ", requestor_type).scalar()

        self.create_entity(ao_id, entity_id, requestor_name, entity_type_id, 1)

    def create_commenter(self, ao_id, entity_id, requestor_name):
        self.create_entity(ao_id, entity_id, requestor_name, 16, 2)

    def create_representative(self, ao_id, entity_id, requestor_name):
        self.create_entity(ao_id, entity_id, requestor_name, 16, 3)

    def create_entity(self, ao_id, entity_id, requestor_name, entity_type_id, role_id):
        self.connection.execute(
            """
            INSERT INTO aouser.entity
            (entity_id, name, type)
            VALUES (%s, %s, %s)""",
            entity_id,
            requestor_name,
            entity_type_id
        )
        self.connection.execute(
            """
            INSERT INTO aouser.players
            (player_id, ao_id, entity_id, role_id)
            VALUES (%s, %s, %s, %s)""",
            entity_id,
            ao_id,
            entity_id,
            role_id
        )

    def clear_test_data(self):
        tables = [
            "ao",
            "document",
            "players",
            "entity"
        ]
        for table in tables:
            self.connection.execute("DELETE FROM aouser.{}".format(table))


def ao_status_to_stage(status):
    if status == "Withdrawn":
        return 2
    elif status == "Final":
        return 1
    else:
        return 0
