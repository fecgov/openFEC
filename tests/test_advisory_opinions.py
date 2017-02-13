import datetime
import re
import subprocess
from mock import patch

import pytest

from tests.common import TEST_CONN, BaseTestCase

from webservices import rest
from webservices.legal_docs.advisory_opinions import (
    get_advisory_opinions,
    get_filtered_matches
)

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


class TestLoadAdvisoryOpinions(BaseTestCase):
    @classmethod
    def setUpClass(cls):
        super(TestLoadAdvisoryOpinions, cls).setUpClass()
        subprocess.check_call(
            ['psql', TEST_CONN, '-f', 'data/load_advisory_opinions_schema.sql'])

    @classmethod
    def tearDownClass(cls):
        subprocess.check_call(
            ['psql', TEST_CONN, '-c', 'DROP SCHEMA aouser CASCADE'])
        super(TestLoadAdvisoryOpinions, cls).tearDownClass()

    def setUp(self):
        self.connection = rest.db.engine.connect()

    def tearDown(self):
        self.clear_test_data()
        self.connection.close()
        rest.db.session.remove()

    @patch('webservices.legal_docs.advisory_opinions.get_bucket')
    def test_pending_ao(self, get_bucket):
        expected_ao = {
            "no": '2017-01',
            "name": "An AO name",
            "summary": "An AO summary",
            "is_pending": True,
            "citations": [],
            "cited_by": [],
            "documents": [],
            "requestor_names": [],
            "requestor_types": [],
        }
        self.create_ao(1, expected_ao)
        actual_ao = next(get_advisory_opinions())

        assert actual_ao == expected_ao

    @patch('webservices.legal_docs.advisory_opinions.get_bucket')
    def test_ao_with_requestors(self, get_bucket):
        expected_requestor_names = ["The Manchurian Candidate", "Federation of Interstate Truckers"]
        expected_requestor_types = ["Federal candidate/candidate committee/officeholder", "Labor Organization"]
        expected_ao = {
            "no": '2017-01',
            "name": "An AO name",
            "summary": "An AO summary",
            "is_pending": True,
            "citations": [],
            "cited_by": [],
            "documents": [],
            "requestor_names": expected_requestor_names,
            "requestor_types": expected_requestor_types,
        }

        self.create_ao(1, expected_ao)
        for i, _ in enumerate(expected_requestor_names):
            self.create_requestor(1, i + 1, expected_requestor_names[i], expected_requestor_types[i])

        actual_ao = next(get_advisory_opinions())

        assert set(actual_ao["requestor_names"]) == set(expected_requestor_names)
        assert set(actual_ao["requestor_types"]) == set(expected_requestor_types)

    @patch('webservices.legal_docs.advisory_opinions.get_bucket')
    def test_completed_ao_with_docs(self, get_bucket):
        expected_document = {
            "document_id": 1,
            "category": "Final Opinion",
            "text": 'Some Text',
            "description": 'Some Description',
            "document_date": datetime.datetime(2017, 2, 9, 0, 0)
        }
        expected_ao = {
            "no": '2017-01',
            "name": "An AO name",
            "summary": "An AO summary",
            "is_pending": False,
            "citations": [],
            "cited_by": [],
            "documents": [expected_document],
            "requestor_names": [],
            "requestor_types": [],
        }
        self.create_ao(1, expected_ao)
        self.create_document(1, expected_document)

        actual_ao = next(get_advisory_opinions())
        assert actual_ao["is_pending"] is False

        actual_document = actual_ao['documents'][0]
        for key in expected_document:
            assert actual_document[key] == expected_document[key]

    @patch('webservices.legal_docs.advisory_opinions.get_bucket')
    def test_ao_citations(self, get_bucket):
        ao1_document = {
            "document_id": 1,
            "category": "Final Opinion",
            "text": 'Not an AO reference 1776-01',
            "description": 'Some Description',
            "document_date": datetime.datetime(2017, 2, 9, 0, 0)
        }
        ao1 = {
            "no": '2017-01',
            "name": "1st AO name",
            "summary": "1st AO summary",
            "is_pending": False,
            "citations": [],
            "cited_by": [],
            "documents": [ao1_document],
            "requestor_names": [],
            "requestor_types": [],
        }

        ao2_document = {
            "document_id": 2,
            "category": "Final Opinion",
            "text": 'Reference to AO 2017-01',
            "description": 'Some Description',
            "document_date": datetime.datetime(2017, 2, 9, 0, 0)
        }
        ao2 = {
            "no": '2017-02',
            "name": "2nd AO name",
            "summary": "2nd AO summary",
            "is_pending": False,
            "citations": [],
            "cited_by": [],
            "documents": [ao2_document],
            "requestor_names": [],
            "requestor_types": [],
        }

        self.create_ao(1, ao1)
        self.create_document(1, ao1_document)
        self.create_ao(2, ao2)
        self.create_document(2, ao2_document)

        actual_aos = [ao for ao in get_advisory_opinions()]
        assert len(actual_aos) == 2

        actual_ao1 = next(filter(lambda a: a['no'] == '2017-01', actual_aos))
        actual_ao2 = next(filter(lambda a: a['no'] == '2017-02', actual_aos))

        assert actual_ao1['citations'] == []
        assert actual_ao1['cited_by'] == [{'no': '2017-02', 'name': '2nd AO name'}]

        assert actual_ao2['citations'] == [{'no': '2017-01', 'name': '1st AO name'}]
        assert actual_ao2['cited_by'] == []

    def create_ao(self, ao_id, ao):
        self.connection.execute(
            "INSERT INTO aouser.ao (ao_id, ao_no, name, summary) "
            "VALUES (%s, %s, %s, %s)", ao_id, ao['no'], ao['name'], ao['summary'])

    def create_document(self, ao_id, document):
        self.connection.execute(
            """
            INSERT INTO aouser.document
            (document_id, ao_id, category, ocrtext, fileimage, description, document_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s)""",
            document['document_id'],
            ao_id,
            document['category'],
            document['text'],
            document['text'],
            document['description'],
            document['document_date']
        )

    def create_requestor(self, ao_id, entity_id, requestor_name, requestor_type):
        entity_type_id = self.connection.execute(
            "SELECT entity_type_id FROM aouser.entity_type "
            " WHERE description = %s ", requestor_type).scalar()
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
            1
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
