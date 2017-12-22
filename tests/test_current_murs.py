import re
import subprocess
from unittest.mock import patch
from datetime import datetime
from decimal import Decimal

import pytest

from webservices import rest
from webservices.legal_docs.current_murs import (
    get_murs,
    parse_regulatory_citations,
    parse_statutory_citations,
)
from tests.common import TEST_CONN, BaseTestCase

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

class TestLoadCurrentMURs(BaseTestCase):
    @classmethod
    def setUpClass(cls):
        super(TestLoadCurrentMURs, cls).setUpClass()
        subprocess.check_call(
            ['psql', TEST_CONN, '-f', 'data/load_murs_schema.sql'])

    @classmethod
    def tearDownClass(cls):
        subprocess.check_call(
            ['psql', TEST_CONN, '-c', 'DROP SCHEMA fecmur CASCADE'])
        super(TestLoadCurrentMURs, cls).tearDownClass()

    def setUp(self):
        self.connection = rest.db.engine.connect()

    def tearDown(self):
        self.clear_test_data()
        self.connection.close()
        rest.db.session.remove()

    @patch('webservices.legal_docs.current_murs.get_bucket')
    def test_simple_mur(self, get_bucket):
        mur_subject = 'Fraudulent misrepresentation'
        expected_mur = {
            'no': '1',
            'name': 'Simple MUR',
            'mur_type': 'current',
            'election_cycles': [2016],
            'doc_id': 'mur_1',
            'participants': [],
            'subjects': [mur_subject],
            'respondents': [],
            'documents': [],
            'commission_votes': [],
            'dispositions': [],
            'close_date': None,
            'open_date': None,
            'url': '/legal/matter-under-review/1/',
            'sort1': -1,
            'sort2': None
        }
        self.create_mur(1, expected_mur['no'], expected_mur['name'], mur_subject)
        actual_mur = next(get_murs(None))

        assert actual_mur == expected_mur

    @patch('webservices.env.env.get_credential', return_value='BUCKET_NAME')
    @patch('webservices.legal_docs.current_murs.get_bucket')
    def test_mur_with_participants_and_documents(self, get_bucket, get_credential):
        case_id = 1
        mur_subject = 'Fraudulent misrepresentation'
        expected_mur = {
            'no': '1',
            'name': 'MUR with participants',
            'mur_type': 'current',
            'election_cycles': [2016],
            'doc_id': 'mur_1',
            'subjects': [mur_subject],
            'respondents': ["Bilbo Baggins", "Thorin Oakenshield"]
        }
        participants = [
            ("Complainant", "Gollum"),
            ("Respondent", "Bilbo Baggins"),
            ("Respondent", "Thorin Oakenshield")
        ]
        documents = [
            ('A Category', 'Some text', '123124123.pdf'),
            ('Another Category', 'Different text', '1231 24123.pdf'),
        ]

        self.create_mur(case_id, expected_mur['no'], expected_mur['name'], mur_subject)
        for entity_id, participant in enumerate(participants):
            role, name = participant
            self.create_participant(case_id, entity_id, role, name)
        for document_id, document in enumerate(documents):
            category, ocrtext, filename = document
            self.create_document(case_id, document_id, category, ocrtext, filename)

        actual_mur = next(get_murs(None))

        for key in expected_mur:
            assert actual_mur[key] == expected_mur[key]

        assert participants == [(p['role'], p['name'])
                                for p in actual_mur['participants']]

        assert [(d[0], d[1], len(d[1])) for d in documents] == [
            (d['category'], d['text'], d['length']) for d in actual_mur['documents']]
        for d in actual_mur['documents']:
            assert re.match(r'/files/legal/murs/', d['url'])

    @patch('webservices.env.env.get_credential', return_value='BUCKET_NAME')
    @patch('webservices.legal_docs.current_murs.get_bucket')
    def test_mur_with_disposition(self, get_bucket, get_credential):
        case_id = 1
        case_no = '1'
        name = 'Open Elections LLC'
        mur_subject = 'Fraudulent misrepresentation'
        pg_date = '2016-10-08'
        self.create_mur(case_id, case_no, name, mur_subject)

        entity_id = 1
        event_date = '2005-01-01'
        event_id = 1
        self.create_calendar_event(entity_id, event_date, event_id, case_id)

        entity_id = 1
        event_date = '2008-01-01'
        event_id = 2
        self.create_calendar_event(entity_id, event_date, event_id, case_id)

        parent_event = 0
        event_name = 'Conciliation-PPC'
        path = ''
        is_key_date = 0
        check_primary_respondent = 0
        pg_date = '2016-01-01'
        self.create_event(event_id, parent_event, event_name, path, is_key_date,
        check_primary_respondent, pg_date)

        first_name = "Commander"
        last_name = "Data"
        middle_name, prefix, suffix, type = ('', '', '', '')
        self.create_entity(entity_id, first_name, last_name, middle_name, prefix, suffix, type, name, pg_date)

        master_key = 1
        detail_key = 1
        relation_id = 1
        self.create_relatedobjects(master_key, detail_key, relation_id)

        settlement_id = 1
        initial_amount = 0
        final_amount = 50000
        amount_received, settlement_type = (0, '')
        self.create_settlement(settlement_id, case_id, initial_amount, final_amount,
        amount_received, settlement_type, pg_date)

        stage = 'Closed'
        statutory_citation = '431'
        regulatory_citation = '456'
        self.create_violation(case_id, entity_id, stage, statutory_citation, regulatory_citation)

        commission_id = 1
        agenda_date = event_date
        vote_date = event_date
        action = 'Conciliation Reached.'
        self.create_commission(commission_id, agenda_date, vote_date, action, case_id, pg_date)

        actual_mur = next(get_murs(None))

        expected_mur = {
            'commission_votes': [{'action': 'Conciliation Reached.', 'vote_date': datetime(2008, 1, 1, 0, 0)}],
            'dispositions': [{
                'disposition': 'Conciliation-PPC',
                'respondent': 'Open Elections LLC', 'penalty': Decimal('50000.00'),
                'citations': [
                    {'text': '431',
                    'title': '2',
                    'type': 'statute',
                    'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=52'
                    '&section=30101'},
                    {'text': '456',
                    'title': '11',
                    'type': 'regulation',
                    'url': '/regulations/456/CURRENT'}
                ]
            }],
            'subjects': ['Fraudulent misrepresentation'],
            'respondents': [],
            'documents': [], 'participants': [], 'no': '1', 'doc_id': 'mur_1',
            'mur_type': 'current', 'name': 'Open Elections LLC', 'open_date': datetime(2005, 1, 1, 0, 0),
            'election_cycles': [2016],
            'close_date': datetime(2008, 1, 1, 0, 0),
            'url': '/legal/matter-under-review/1/',
            'sort1': -1,
            'sort2': None
        }
        assert actual_mur == expected_mur

    @patch('webservices.legal_docs.current_murs.get_bucket')
    def test_mur_offsets(self, get_bucket):
        mur_subject = 'Fraudulent misrepresentation'
        expected_mur1 = {
            'no': '1',
            'name': 'Simple MUR1',
            'mur_type': 'current',
            'election_cycles': [2016],
            'doc_id': 'mur_1',
            'participants': [],
            'subjects': [mur_subject],
            'respondents': [],
            'documents': [],
            'commission_votes': [],
            'dispositions': [],
            'close_date': None,
            'open_date': None,
            'url': '/legal/matter-under-review/1/',
            'sort1': -1,
            'sort2': None
        }
        expected_mur2 = {
            'no': '2',
            'name': 'Simple MUR2',
            'mur_type': 'current',
            'election_cycles': [2016],
            'doc_id': 'mur_2',
            'participants': [],
            'subjects': [mur_subject],
            'respondents': [],
            'documents': [],
            'commission_votes': [],
            'dispositions': [],
            'close_date': None,
            'open_date': None,
            'url': '/legal/matter-under-review/2/',
            'sort1': -2,
            'sort2': None
        }
        expected_mur3 = {
            'no': '3',
            'name': 'Simple MUR',
            'mur_type': 'current',
            'election_cycles': [2016],
            'doc_id': 'mur_3',
            'participants': [],
            'subjects': [mur_subject],
            'respondents': [],
            'documents': [],
            'commission_votes': [],
            'dispositions': [],
            'close_date': None,
            'open_date': None,
            'url': '/legal/matter-under-review/3/',
            'sort1': -3,
            'sort2': None
        }
        self.create_mur(1, expected_mur1['no'], expected_mur1['name'], mur_subject)
        self.create_mur(2, expected_mur2['no'], expected_mur2['name'], mur_subject)
        self.create_mur(3, expected_mur3['no'], expected_mur3['name'], mur_subject)

        gen = get_murs(None)
        assert(next(gen)) == expected_mur1
        assert(next(gen)) == expected_mur2
        assert(next(gen)) == expected_mur3

        gen = get_murs('2')
        assert(next(gen)) == expected_mur2
        assert(next(gen)) == expected_mur3

    def create_mur(self, case_id, case_no, name, subject_description):
        subject_id = self.connection.execute(
            "SELECT subject_id FROM fecmur.subject "
            " WHERE description = %s ", subject_description).scalar()
        self.connection.execute(
            "INSERT INTO fecmur.case (case_id, case_no, name, case_type) "
            "VALUES (%s, %s, %s, 'MUR')", case_id, case_no, name)
        self.connection.execute(
            "INSERT INTO fecmur.case_subject (case_id, subject_id, relatedsubject_id) "
            "VALUES (%s, %s, -1)", case_id, subject_id)
        self.connection.execute(
            "INSERT INTO fecmur.electioncycle (case_id, election_cycle) "
            "VALUES (%s, 2016)", case_id)

    def create_participant(self, case_id, entity_id, role, name,
            stage=None, statutory_citation=None, regulatory_citation=None):
        role_id = self.connection.execute(
            "SELECT role_id FROM fecmur.role "
            " WHERE description = %s ", role).scalar()
        self.connection.execute(
            "INSERT INTO fecmur.entity (entity_id, name) "
            "VALUES (%s, %s)", entity_id, name)
        self.connection.execute(
            "INSERT INTO fecmur.players (player_id, entity_id, case_id, role_id) "
            "VALUES (%s, %s, %s, %s)", entity_id, entity_id, case_id, role_id)
        if stage:
            self.create_violation(case_id, entity_id, stage, statutory_citation, regulatory_citation)

    def create_violation(self, case_id, entity_id, stage, statutory_citation, regulatory_citation):
        self.connection.execute(
            "INSERT INTO fecmur.violations (case_id, entity_id, stage, statutory_citation, regulatory_citation) "
            "VALUES (%s, %s, %s, %s, %s)", case_id, entity_id, stage, statutory_citation, regulatory_citation)

    def create_document(self, case_id, document_id, category, ocrtext, filename):
        self.connection.execute(
            "INSERT INTO fecmur.document (document_id, doc_order_id, case_id, category, ocrtext, fileimage, filename) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)", document_id, document_id, case_id, category, ocrtext, ocrtext, filename)

    def create_calendar_event(self, entity_id, event_date, event_id, case_id):
        self.connection.execute(
            "INSERT INTO fecmur.calendar (entity_id, event_date, event_id, case_id) "
            "VALUES (%s, %s, %s, %s)", entity_id, event_date, event_id, case_id)

    def create_entity(self, entity_id, first_name, last_name, middle_name, prefix, suffix, type, name, pg_date):
        self.connection.execute(
            "INSERT INTO fecmur.entity (entity_id, first_name, last_name, middle_name, "
            "prefix, suffix, type, name, pg_date) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)", entity_id, first_name,
            last_name, middle_name, prefix, suffix, type, name, pg_date)

    def create_event(self, event_id, parent_event, event_name, path, is_key_date, check_primary_respondent, pg_date):
        self.connection.execute(
            "INSERT INTO fecmur.event (event_id, parent_event, event_name, path, is_key_date, "
            "check_primary_respondent, pg_date) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)", event_id, parent_event,
            event_name, path, is_key_date, check_primary_respondent, pg_date)

    def create_relatedobjects(self, master_key, detail_key, relation_id):
        self.connection.execute(
            "INSERT INTO fecmur.relatedobjects (master_key, detail_key, relation_id) "
            "VALUES (%s, %s, %s)", master_key, detail_key, relation_id)

    def create_settlement(self, settlement_id, case_id, initial_amount, final_amount,
      amount_received, settlement_type, pg_date):
        self.connection.execute(
            "INSERT INTO fecmur.settlement (settlement_id, case_id, initial_amount, "
            "final_amount, amount_received, settlement_type, pg_date) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)", settlement_id, case_id, initial_amount, final_amount,
            amount_received, settlement_type, pg_date)

    def create_commission(self, commission_id, agenda_date, vote_date, action, case_id, pg_date):
        self.connection.execute(
            "INSERT INTO fecmur.commission (commission_id, agenda_date, vote_date, action, case_id, pg_date) "
            "VALUES (%s, %s, %s, %s, %s, %s)", commission_id, agenda_date, vote_date, action, case_id, pg_date)

    def clear_test_data(self):
        tables = [
            "violations",
            "document",
            "players",
            "entity",
            "case_subject",
            "electioncycle",
            "case",
            "calendar",
            "settlement",
            "event",
            "commission"
        ]
        for table in tables:
            self.connection.execute("DELETE FROM fecmur.{}".format(table))
