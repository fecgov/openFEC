import re
import subprocess
import manage

from mock import patch
from datetime import datetime
from decimal import Decimal
from webservices import rest
from webservices.legal_docs import DOCS_INDEX
from tests.common import TEST_CONN, BaseTestCase

def assert_es_index_call(call_args, expected_adr):
    index, doc_type, adr = call_args[0]
    assert index == 'docs'
    assert doc_type == 'adrs'
    assert adr == expected_adr

class TestLoadADRs(BaseTestCase):
    @classmethod
    def setUpClass(cls):
        super(TestLoadADRs, cls).setUpClass()
        subprocess.check_call(
            ['psql', TEST_CONN, '-f', 'data/load_murs_schema.sql'])

    @classmethod
    def tearDownClass(cls):
        subprocess.check_call(
            ['psql', TEST_CONN, '-c', 'DROP SCHEMA fecmur CASCADE'])
        super(TestLoadADRs, cls).tearDownClass()

    def setUp(self):
        self.connection = rest.db.engine.connect()

    def tearDown(self):
        self.clear_test_data()
        self.connection.close()
        rest.db.session.remove()

    @patch('webservices.legal_docs.adrs.get_bucket')
    @patch('webservices.legal_docs.adrs.get_elasticsearch_connection')
    def test_simple_adr(self, get_es_conn, get_bucket):
        adr_subject = 'Fraudulent misrepresentation'
        expected_adr = {
            'no': '1',
            'name': 'Simple ADR',
            'adr_type': 'current',
            'election_cycles': [2016],
            'doc_id': 'adr_1',
            'participants': [],
            'subjects': [adr_subject],
            'subject': {"text": [adr_subject]},
            'respondents': [],
            'documents': [],
            'disposition': {'data': [], 'text': []},
            'commission_votes': [],
            'dispositions': [],
            'close_date': None,
            'open_date': None,
            'url': '/legal/alternative-dispute-resolution/1/'
        }
        self.create_adr(1, expected_adr['no'], expected_adr['name'], adr_subject)
        manage.legal_docs.load_adrs()
        index, doc_type, adr = get_es_conn.return_value.index.call_args[0]

        assert index == DOCS_INDEX
        assert doc_type == 'adrs'
        assert adr == expected_adr

    @patch('webservices.env.env.get_credential', return_value='BUCKET_NAME')
    @patch('webservices.legal_docs.adrs.get_bucket')
    @patch('webservices.legal_docs.adrs.get_elasticsearch_connection')
    def test_adr_with_participants_and_documents(self, get_es_conn, get_bucket, get_credential):
        case_id = 1
        adr_subject = 'Fraudulent misrepresentation'
        expected_adr = {
            'no': '1',
            'name': 'ADR with participants',
            'adr_type': 'current',
            'election_cycles': [2016],
            'doc_id': 'adr_1',
            'subjects': [adr_subject],
            'subject': {"text": [adr_subject]},
            'respondents': ["Bilbo Baggins", "Thorin Oakenshield"]
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

        self.create_adr(case_id, expected_adr['no'], expected_adr['name'], adr_subject)
        for entity_id, participant in enumerate(participants):
            role, name = participant
            self.create_participant(case_id, entity_id, role, name)
        for document_id, document in enumerate(documents):
            category, ocrtext = document
            self.create_document(case_id, document_id, category, ocrtext)

        manage.legal_docs.load_adrs()
        index, doc_type, adr = get_es_conn.return_value.index.call_args[0]

        assert index == DOCS_INDEX
        assert doc_type == 'adrs'
        for key in expected_adr:
            assert adr[key] == expected_adr[key]

        assert participants == [(p['role'], p['name'])
                                for p in adr['participants']]

        assert [(d[0], d[1], len(d[1])) for d in documents] == [
            (d['category'], d['text'], d['length']) for d in adr['documents']]
        for d in adr['documents']:
            assert re.match(r'https://BUCKET_NAME.s3.amazonaws.com/legal/murs/current', d['url'])

    @patch('webservices.env.env.get_credential', return_value='BUCKET_NAME')
    @patch('webservices.legal_docs.adrs.get_bucket')
    @patch('webservices.legal_docs.adrs.get_elasticsearch_connection')
    def test_adr_with_disposition(self, get_es_conn, get_bucket, get_credential):
        case_id = 1
        case_no = '1'
        name = 'Open Elections LLC'
        adr_subject = 'Fraudulent misrepresentation'
        pg_date = '2016-10-08'
        self.create_adr(case_id, case_no, name, adr_subject)

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

        manage.legal_docs.load_adrs()
        index, doc_type, adr = get_es_conn.return_value.index.call_args[0]

        expected_adr = {'disposition': {'data': [{'disposition': 'Conciliation-PPC',
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
            ]}],
            'text': [{'text': 'Conciliation Reached.', 'vote_date': datetime(2008, 1, 1, 0, 0)}]},
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
            'subject': {"text": ['Fraudulent misrepresentation']},
            'respondents': [],
            'documents': [], 'participants': [], 'no': '1', 'doc_id': 'adr_1',
            'adr_type': 'current', 'name': 'Open Elections LLC', 'open_date': datetime(2005, 1, 1, 0, 0),
            'election_cycles': [2016],
            'close_date': datetime(2008, 1, 1, 0, 0),
            'url': '/legal/alternative-dispute-resolution/1/'}

        assert adr == expected_adr

    def create_adr(self, case_id, case_no, name, subject_description):
        subject_id = self.connection.execute(
            "SELECT subject_id FROM fecmur.subject "
            " WHERE description = %s ", subject_description).scalar()
        self.connection.execute(
            "INSERT INTO fecmur.case (case_id, case_no, name, case_type) "
            "VALUES (%s, %s, %s, 'ADR')", case_id, case_no, name)
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
            "electioncycle",
            "case",
            "calendar",
            "settlement",
            "event",
            "commission"
        ]
        for table in tables:
            self.connection.execute("DELETE FROM fecmur.{}".format(table))
