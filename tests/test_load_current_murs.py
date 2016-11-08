import re
import subprocess
from mock import patch
from datetime import datetime
from decimal import Decimal

import pytest

import manage
from webservices import rest
from webservices.legal_docs.current_murs import parse_regulatory_citations, parse_statutory_citations
from tests.common import TEST_CONN, BaseTestCase

@pytest.mark.parametrize("test_input,case_id,entity_id,expected", [
    ("110", 1, 2,
        [{'text': '11 C.F.R. 110', 'url': '/regulations/110/CURRENT'}]),
    ("110.21", 1, 2,
        [{'text': '11 C.F.R. 110.21', 'url': '/regulations/110-21/CURRENT'}]),
    ("114.5(a)(3)", 1, 2,
        [{'text': '11 C.F.R. 114.5(a)(3)', 'url': '/regulations/114-5/CURRENT'}]),
    ("114.5(a)(3)-(5)", 1, 2,
        [{'text': '11 C.F.R. 114.5(a)(3)-(5)', 'url': '/regulations/114-5/CURRENT'}]),
    ("102.17(a)(l)(i), (b)(l), (b)(2), and (c)(3)", 1, 2,
        [{'text': '11 C.F.R. 102.17(a)(l)(i)', 'url': '/regulations/102-17/CURRENT'},
         {'text': '11 C.F.R. 102.17(b)(l)', 'url': '/regulations/102-17/CURRENT'},
         {'text': '11 C.F.R. 102.17(b)(2)', 'url': '/regulations/102-17/CURRENT'},
         {'text': '11 C.F.R. 102.17(c)(3)', 'url': '/regulations/102-17/CURRENT'}
         ]),
    ("102.5(a)(2); 104.3(a)(4)(i); 114.5(a)(3)-(5); 114.5(g)(1)", 1, 2,
        [{'text': '11 C.F.R. 102.5(a)(2)', 'url': '/regulations/102-5/CURRENT'},
         {'text': '11 C.F.R. 104.3(a)(4)(i)', 'url': '/regulations/104-3/CURRENT'},
         {'text': '11 C.F.R. 114.5(a)(3)-(5)', 'url': '/regulations/114-5/CURRENT'},
         {'text': '11 C.F.R. 114.5(g)(1)', 'url': '/regulations/114-5/CURRENT'}
         ]),
])
def test_parse_regulatory_citations(test_input, case_id, entity_id, expected):
    assert parse_regulatory_citations(test_input, case_id, entity_id) == expected

@pytest.mark.parametrize("test_input,case_id,entity_id,expected", [
    ("431", 1, 2,    # With reclassification
        [{'text': '52 U.S.C. 30101',
          'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html'
          '&title=52&section=30101'}]),
    ("9999", 1, 2,
        [{'text': '2 U.S.C. 9999',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=9999'}]),
    ("9993(c)(2)", 1, 2,
        [{'text': '2 U.S.C. 9993(c)(2)',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=9993'}]),
    ("9993(a)(4) formerly 438(a)(4)", 1, 2,
        [{'text': '2 U.S.C. 9993(a)(4)',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=9993'}]),
    ("9116(a)(2)(A), 9114(b) (formerly 441a(a)(2)(A), 434(b)), 30116(f) (formerly 441a(f))", 1, 2,
        [{'text': '2 U.S.C. 9116(a)(2)(A)',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=9116'},
        {'text': '2 U.S.C. 9114(b)',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=9114'},
        {'text': '2 U.S.C. 30116(f)',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=30116'}]),
    ("9993(a)(4) (formerly 438(a)(4)", 1, 2,  # No matching ')' for (formerly
        [{'text': '2 U.S.C. 9993(a)(4)',
        'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=2&section=9993'}]),
])
def test_parse_statutory_citations(test_input, case_id, entity_id, expected):
    assert parse_statutory_citations(test_input, case_id, entity_id) == expected

def assert_es_index_call(call_args, expected_mur):
    index, doc_type, mur = call_args[0]
    assert index == 'docs'
    assert doc_type == 'murs'
    assert mur == expected_mur

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
    @patch('webservices.legal_docs.current_murs.get_elasticsearch_connection')
    def test_simple_mur(self, get_es_conn, get_bucket):
        mur_subject = 'Fraudulent misrepresentation'
        expected_mur = {
            'no': '1',
            'name': 'Simple MUR',
            'mur_type': 'current',
            'text': '',
            'doc_id': 'mur_1',
            'participants': [],
            'subject': {"text": [mur_subject]},
            'documents': [],
            'disposition': {'data': [], 'text': []},
            'close_date': None,
            'open_date': None,
            'url': '/legal/matter-under-review/1/'
        }
        self.create_mur(1, expected_mur['no'], expected_mur['name'], mur_subject)
        manage.legal_docs.load_current_murs()
        index, doc_type, mur = get_es_conn.return_value.index.call_args[0]

        assert index == 'docs'
        assert doc_type == 'murs'
        assert mur == expected_mur

    @patch('webservices.env.env.get_credential', return_value='BUCKET_NAME')
    @patch('webservices.legal_docs.current_murs.get_bucket')
    @patch('webservices.legal_docs.current_murs.get_elasticsearch_connection')
    def test_mur_with_participants_and_documents(self, get_es_conn, get_bucket, get_credential):
        case_id = 1
        mur_subject = 'Fraudulent misrepresentation'
        expected_mur = {
            'no': '1',
            'name': 'MUR with participants',
            'mur_type': 'current',
            'doc_id': 'mur_1',
            'subject': {"text": [mur_subject]},
        }
        participants = [
            ("Complainant", "Gollum"),
            ("Respondent", "Bilbo Baggins"),
            ("Respondent", "Thorin Oakenshield")
        ]
        documents = [
            ('A Category', 'Some text'),
            ('Another Category', 'Different text'),
        ]

        self.create_mur(case_id, expected_mur['no'], expected_mur['name'], mur_subject)
        for entity_id, participant in enumerate(participants):
            role, name = participant
            self.create_participant(case_id, entity_id, role, name)
        for document_id, document in enumerate(documents):
            category, ocrtext = document
            self.create_document(case_id, document_id, category, ocrtext)

        manage.legal_docs.load_current_murs()
        index, doc_type, mur = get_es_conn.return_value.index.call_args[0]

        assert index == 'docs'
        assert doc_type == 'murs'
        for key in expected_mur:
            assert mur[key] == expected_mur[key]

        assert participants == [(p['role'], p['name'])
                                for p in mur['participants']]

        assert mur['text'].strip() == "Some text Different text"

        assert [(d[0], len(d[1])) for d in documents] == [
            (d['category'], d['length']) for d in mur['documents']]
        for d in mur['documents']:
            assert re.match(r'https://BUCKET_NAME.s3.amazonaws.com/legal/murs/current', d['url'])

    @patch('webservices.env.env.get_credential', return_value='BUCKET_NAME')
    @patch('webservices.legal_docs.current_murs.get_bucket')
    @patch('webservices.legal_docs.current_murs.get_elasticsearch_connection')
    def test_mur_with_disposition(self, get_es_conn, get_bucket, get_credential):
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

        manage.legal_docs.load_current_murs()
        index, doc_type, mur = get_es_conn.return_value.index.call_args[0]

        expected_mur = {'disposition': {'data': [{'disposition': 'Conciliation-PPC',
            'respondent': 'Open Elections LLC', 'penalty': Decimal('50000.00'),
            'citations': [{'text': '52 U.S.C. 30101',
            'url': 'https://api.fdsys.gov/link?collection=uscode&year=mostrecent&link-type=html&title=52'
                '&section=30101'},
            {'text': '11 C.F.R. 456',
            'url': '/regulations/456/CURRENT'}]}],
            'text': [{'text': 'Conciliation Reached.', 'vote_date': datetime(2008, 1, 1, 0, 0)}]},
            'text': '', 'subject': {'text': ['Fraudulent misrepresentation']},
            'documents': [], 'participants': [], 'no': '1', 'doc_id': 'mur_1',
            'mur_type': 'current', 'name': 'Open Elections LLC', 'open_date': datetime(2005, 1, 1, 0, 0),
            'close_date': datetime(2008, 1, 1, 0, 0),
            'url': '/legal/matter-under-review/1/'}

        assert mur == expected_mur

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

    def create_document(self, case_id, document_id, category, ocrtext):
        self.connection.execute(
            "INSERT INTO fecmur.document (document_id, doc_order_id, case_id, category, ocrtext, fileimage) "
            "VALUES (%s, %s, %s, %s, %s, %s)", document_id, document_id, case_id, category, ocrtext, ocrtext)

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
            "case",
            "calendar",
            "settlement",
            "event",
            "commission"
        ]
        for table in tables:
            self.connection.execute("DELETE FROM fecmur.{}".format(table))
