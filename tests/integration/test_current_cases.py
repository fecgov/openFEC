import subprocess
from unittest.mock import patch
from datetime import datetime, date
from decimal import Decimal
import pytest


from webservices import rest
from webservices.legal_docs.current_cases import get_cases

from tests.common import TEST_CONN, BaseTestCase


@pytest.mark.usefixtures("migrate_db")
class TestLoadCurrentCases(BaseTestCase):
    def setUp(self):
        self.connection = rest.db.engine.connect()
        subprocess.check_call(['psql', TEST_CONN, '-f', 'data/load_base_mur_data.sql'])

    def tearDown(self):
        self.clear_test_data()
        self.connection.close()
        rest.db.session.remove()

    @patch('webservices.legal_docs.current_cases.get_bucket')
    def test_simple_mur(self, get_bucket):
        mur_subject = 'Fraudulent misrepresentation'
        expected_mur = {
            "type": "murs",
            'no': '1',
            'name': 'Simple MUR',
            'mur_type': 'current',
            'election_cycles': [2016],
            'doc_id': 'mur_1',
            'case_serial': 1,
            'published_flg': True,
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
            'sort2': None,
        }
        self.create_case(
            1,
            expected_mur['no'],
            expected_mur['name'],
            mur_subject,
            expected_mur['published_flg'],
        )
        actual_mur = next(get_cases('MUR'))

        assert actual_mur == expected_mur

    @patch('webservices.legal_docs.current_cases.get_bucket')
    def test_unpublished_mur(self, get_bucket):
        mur_subject = 'Unpublished MUR'
        expected_mur = {
            "type": "murs",
            'no': '101',
            'name': 'Test Unpublished MUR',
            'mur_type': 'current',
            'election_cycles': [2016],
            'doc_id': 'mur_101',
            'case_serial': 101,
            'published_flg': False,
            'participants': [],
            'subjects': [mur_subject],
            'respondents': [],
            'documents': [],
            'commission_votes': [],
            'dispositions': [],
            'close_date': None,
            'open_date': None,
            'url': '/legal/matter-under-review/101/',
            'sort1': -101,
            'sort2': None,
        }
        self.create_case(
            101,
            expected_mur['no'],
            expected_mur['name'],
            mur_subject,
            expected_mur['published_flg'],
        )
        actual_mur = next(get_cases('MUR'))

        assert actual_mur == expected_mur

    @patch('webservices.legal_docs.current_cases.get_bucket')
    def test_simple_adr(self, get_bucket):
        adr_subject = 'Personal use'

        expected_adr = {
            "type": "adrs",
            'no': '1',
            'name': 'Simple ADR',
            'election_cycles': [2016],
            'doc_id': 'adr_1',
            'case_serial': 1,
            'published_flg': True,
            'participants': [],
            'non_monetary_terms': [],
            'non_monetary_terms_respondents': ['Commander Data'],
            'subjects': [adr_subject],
            'respondents': [],
            'documents': [],
            'commission_votes': [],
            'adr_dispositions': [],
            'close_date': None,
            'open_date': None,
            'url': '/legal/alternative-dispute-resolution/1/',
            'complainant': [],
            'case_status': [],
            'citations': [],
            'sort1': -1,
            'sort2': None,
        }
        self.create_case(
            1,
            expected_adr['no'],
            expected_adr['name'],
            adr_subject,
            expected_adr['published_flg'],
            'ADR',
        )

        # create entity
        entity_id = 1
        first_name = "Commander"
        last_name = "Data"
        middle_name, prefix, suffix, type = ('', '', '', '')
        name = "Commander Data"
        pg_date = '2022-07-27'
        self.create_entity(
            entity_id,
            first_name,
            last_name,
            middle_name,
            prefix,
            suffix,
            type,
            name,
            pg_date,
        )

        # create complainant
        player_id = 1
        role_id = 1
        case_id = 1
        self.create_complainant(
            player_id,
            entity_id,
            case_id,
            role_id,
            pg_date,
        )

        # create settlement
        settlement_id = 1
        initial_amount = 0
        final_amount = 50000
        amount_received, settlement_type = (0, '')
        self.create_settlement(
            settlement_id,
            case_id,
            initial_amount,
            final_amount,
            amount_received,
            settlement_type,
            pg_date,
        )

        actual_adr = next(get_cases('ADR'))

        assert actual_adr == expected_adr

    @patch('webservices.legal_docs.current_cases.get_bucket')
    def test_admin_fine(self, get_bucket):
        dummy_subject = 'Personal use'
        case_id = 1
        expected_admin_fine = {
            "type": "admin_fines",
            'no': '1',
            'name': 'Big Admin Fine',
            'doc_id': 'af_1',
            'case_serial': 1,
            'published_flg': True,
            'documents': [],
            'commission_votes': [{'action': None, 'vote_date': None}],
            'committee_id': 'C001',
            'report_year': '2016',
            'report_type': '30G',
            'reason_to_believe_action_date': None,
            'reason_to_believe_fine_amount': 5000,
            'challenge_receipt_date': None,
            'challenge_outcome': '',
            'final_determination_date': None,
            'final_determination_amount': 5000,
            'payment_amount': 5000,
            'treasury_referral_date': None,
            'treasury_referral_amount': 0,
            'petition_court_filing_date': None,
            'petition_court_decision_date': None,
            'url': '/legal/administrative-fine/1/',
            'civil_penalty_due_date': None,
            'civil_penalty_payment_status': 'Paid In Full',
            'af_dispositions': [
                {
                    'amount': Decimal('350'),
                    'disposition_description': 'Challenged',
                    "disposition_date": date(2021, 6, 25)
                }
            ],
            'sort1': -1,
            'sort2': None,
        }

        expected_af_case_disposition = {
            'amount': Decimal('350'),
            'disposition_description': 'Challenged',
            'disposition_date': date(2021, 6, 25),
        }
        self.create_case(
            case_id,
            expected_admin_fine['no'],
            expected_admin_fine['name'],
            dummy_subject,
            expected_admin_fine['published_flg'],
            'AF',
        )
        self.create_admin_fine(
            case_id,
            expected_admin_fine['committee_id'],
            expected_admin_fine['report_year'],
            expected_admin_fine['report_type'],
            expected_admin_fine['reason_to_believe_action_date'],
            expected_admin_fine['reason_to_believe_fine_amount'],
            expected_admin_fine['challenge_receipt_date'],
            expected_admin_fine['challenge_outcome'],
            expected_admin_fine['final_determination_date'],
            expected_admin_fine['final_determination_amount'],
            expected_admin_fine['payment_amount'],
            expected_admin_fine['treasury_referral_date'],
            expected_admin_fine['treasury_referral_amount'],
            expected_admin_fine['petition_court_filing_date'],
            expected_admin_fine['petition_court_decision_date'],
            expected_admin_fine['civil_penalty_due_date'],
            expected_admin_fine['civil_penalty_payment_status'],
        )

        self.create_af_case_disposition(
            case_id,
            expected_af_case_disposition['amount'],
            expected_af_case_disposition['disposition_description'],
            expected_af_case_disposition['disposition_date'],
        )
        actual_admin_fine = next(get_cases('AF'))

        assert actual_admin_fine == expected_admin_fine

    @patch('webservices.env.env.get_credential', return_value='BUCKET_NAME')
    @patch('webservices.legal_docs.current_cases.get_bucket')
    def test_mur_with_participants_and_documents(self, get_bucket, get_credential):
        case_id = 1
        mur_subject = 'Fraudulent misrepresentation'
        expected_mur = {
            "type": "murs",
            'no': '1',
            'case_serial': 1,
            'name': 'MUR with participants',
            'mur_type': 'current',
            'published_flg': True,
            'election_cycles': [2016],
            'doc_id': 'mur_1',
            'subjects': [mur_subject],
            'respondents': ["Bilbo Baggins", "Thorin Oakenshield"],
        }
        participants = [
            ("Complainant", "Gollum"),
            ("Respondent", "Bilbo Baggins"),
            ("Respondent", "Thorin Oakenshield"),
        ]
        filename = "Some File.pdf"
        documents = [
            (
                'A Category',
                'Some text',
                'legal/murs/{0}/{1}'.format('1', filename.replace(' ', '-')),
            ),
            (
                'Another Category',
                'Different text',
                'legal/murs/{0}/{1}'.format('1', filename.replace(' ', '-')),
            ),
        ]

        self.create_case(
            case_id,
            expected_mur['no'],
            expected_mur['name'],
            mur_subject,
            expected_mur['published_flg'],
        )
        for entity_id, participant in enumerate(participants):
            role, name = participant
            self.create_participant(case_id, entity_id, role, name)
        for document_id, document in enumerate(documents):
            category, ocrtext, url = document
            self.create_document(case_id, document_id, category, ocrtext, filename)

        actual_mur = next(get_cases('MUR'))

        # ?? to do list:
        # for key in expected_mur:
        #     assert actual_mur[key] == expected_mur[key]

        assert participants == [
            (p['role'], p['name']) for p in actual_mur['participants']
        ]

        assert [(d[0], d[1], len(d[1])) for d in documents] == [
            (d['category'], d['text'], d['length']) for d in actual_mur['documents']
        ]

    @patch('webservices.env.env.get_credential', return_value='BUCKET_NAME')
    @patch('webservices.legal_docs.current_cases.get_bucket')
    def test_mur_with_disposition(self, get_bucket, get_credential):
        case_id = 1
        case_no = '1'
        name = 'Open Elections LLC'
        mur_subject = 'Fraudulent misrepresentation'
        pg_date = '2016-10-08'
        published_flg = True
        self.create_case(case_id, case_no, name, mur_subject, published_flg)

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
        self.create_event(
            event_id,
            parent_event,
            event_name,
            path,
            is_key_date,
            check_primary_respondent,
            pg_date,
        )

        first_name = "Commander"
        last_name = "Data"
        middle_name, prefix, suffix, type = ('', '', '', '')
        self.create_entity(
            entity_id,
            first_name,
            last_name,
            middle_name,
            prefix,
            suffix,
            type,
            name,
            pg_date,
        )

        master_key = 1
        detail_key = 1
        relation_id = 1
        self.create_relatedobjects(master_key, detail_key, relation_id)

        settlement_id = 1
        initial_amount = 0
        final_amount = 50000
        amount_received, settlement_type = (0, '')
        self.create_settlement(
            settlement_id,
            case_id,
            initial_amount,
            final_amount,
            amount_received,
            settlement_type,
            pg_date,
        )

        stage = 'Closed'
        statutory_citation = '431'
        regulatory_citation = '456'
        self.create_violation(
            case_id, entity_id, stage, statutory_citation, regulatory_citation
        )

        commission_id = 1
        agenda_date = event_date
        vote_date = event_date
        action = 'Conciliation Reached.'
        self.create_commission(
            commission_id, agenda_date, vote_date, action, case_id, pg_date
        )

        actual_mur = next(get_cases('MUR'))

        expected_mur = {
            "type": "murs",
            'commission_votes': [
                {
                    'action': 'Conciliation Reached.',
                    'vote_date': datetime(2008, 1, 1, 0, 0),
                }
            ],
            'dispositions': [
                {
                    'disposition': 'Conciliation-PPC',
                    'respondent': 'Open Elections LLC',
                    'penalty': Decimal('50000.00'),
                    'citations': [
                        {
                            'text': '431',
                            'title': '2',
                            'type': 'statute',
                            'url': 'https://www.govinfo.gov/link/uscode/52/30101',
                        },
                        {
                            'text': '456',
                            'title': '11',
                            'type': 'regulation',
                            'url': '/regulations/456/CURRENT',
                        },
                    ],
                }
            ],
            'subjects': ['Fraudulent misrepresentation'],
            'respondents': [],
            'documents': [],
            'participants': [],
            'no': '1',
            'doc_id': 'mur_1',
            'case_serial': 1,
            'published_flg': True,
            'mur_type': 'current',
            'name': 'Open Elections LLC',
            'open_date': datetime(2005, 1, 1, 0, 0),
            'election_cycles': [2016],
            'close_date': datetime(2008, 1, 1, 0, 0),
            'url': '/legal/matter-under-review/1/',
            'sort1': -1,
            'sort2': None,
        }
        assert actual_mur == expected_mur

    @patch('webservices.legal_docs.current_cases.get_bucket')
    def test_mur_offsets(self, get_bucket):
        mur_subject = 'Fraudulent misrepresentation'
        expected_mur1 = {
            "type": "murs",
            'no': '1',
            'name': 'Simple MUR1',
            'mur_type': 'current',
            'election_cycles': [2016],
            'doc_id': 'mur_1',
            'case_serial': 1,
            'published_flg': True,
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
            'sort2': None,
        }
        expected_mur2 = {
            "type": "murs",
            'no': '2',
            'name': 'Simple MUR2',
            'mur_type': 'current',
            'election_cycles': [2016],
            'doc_id': 'mur_2',
            'case_serial': 2,
            'published_flg': True,
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
            'sort2': None,
        }
        expected_mur3 = {
            "type": "murs",
            'no': '3',
            'name': 'Simple MUR',
            'mur_type': 'current',
            'election_cycles': [2016],
            'doc_id': 'mur_3',
            'case_serial': 3,
            'published_flg': True,
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
            'sort2': None,
        }
        self.create_case(
            1,
            expected_mur1['no'],
            expected_mur1['name'],
            mur_subject,
            expected_mur1['published_flg'],
        )
        self.create_case(
            2,
            expected_mur2['no'],
            expected_mur2['name'],
            mur_subject,
            expected_mur2['published_flg'],
        )
        self.create_case(
            3,
            expected_mur3['no'],
            expected_mur3['name'],
            mur_subject,
            expected_mur3['published_flg'],
        )

        gen = get_cases('MUR')
        assert (next(gen)) == expected_mur3
        assert (next(gen)) == expected_mur2
        assert (next(gen)) == expected_mur1

        actual_murs = [mur for mur in get_cases('MUR', '2')]
        assert actual_murs == [expected_mur2]

    def create_case(
        self,
        case_id,
        case_no,
        name,
        subject_description,
        published_flg,
        case_type='MUR',
    ):
        subject_id = self.connection.execute(
            "SELECT subject_id FROM fecmur.subject " " WHERE description = %s ",
            subject_description,
        ).scalar()
        self.connection.execute(
            "INSERT INTO fecmur.case (case_id, case_no, name, published_flg, case_type) "
            "VALUES (%s, %s, %s, %s, %s)",
            case_id,
            case_no,
            name,
            published_flg,
            case_type,
        )
        if case_type != 'AF':
            self.connection.execute(
                "INSERT INTO fecmur.case_subject (case_id, subject_id, relatedsubject_id) "
                "VALUES (%s, %s, -1)",
                case_id,
                subject_id,
            )
            self.connection.execute(
                "INSERT INTO fecmur.electioncycle (case_id, election_cycle) "
                "VALUES (%s, 2016)",
                case_id,
            )

    def create_admin_fine(
        self,
        case_id,
        committee_id,
        report_year,
        report_type,
        reason_to_believe_action_date,
        reason_to_believe_fine_amount,
        challenge_receipt_date,
        challenge_outcome,
        final_determination_date,
        final_determination_amount,
        payment_amount,
        treasury_referral_date,
        treasury_referral_amount,
        petition_court_filing_date,
        petition_court_decision_date,
        civil_penalty_due_date,
        civil_penalty_pymt_status_flg,
    ):

        self.connection.execute(
            "INSERT INTO fecmur.af_case (case_id, committee_id, report_year, report_type, \
            rtb_action_date, rtb_fine_amount, chal_receipt_date, chal_outcome_code_desc, \
            fd_date, fd_final_fine_amount, check_amount, treasury_date, treasury_amount, \
            petition_court_filing_date, petition_court_decision_date, civil_penalty_due_date, \
            civil_penalty_pymt_status_flg ) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
            case_id,
            committee_id,
            report_year,
            report_type,
            reason_to_believe_action_date,
            reason_to_believe_fine_amount,
            challenge_receipt_date,
            challenge_outcome,
            final_determination_date,
            final_determination_amount,
            payment_amount,
            treasury_referral_date,
            treasury_referral_amount,
            petition_court_filing_date,
            petition_court_decision_date,
            civil_penalty_due_date,
            civil_penalty_pymt_status_flg,
        )

    def create_participant(
        self,
        case_id,
        entity_id,
        role,
        name,
        stage=None,
        statutory_citation=None,
        regulatory_citation=None,
    ):
        role_id = self.connection.execute(
            "SELECT role_id FROM fecmur.role " " WHERE description = %s ", role
        ).scalar()
        self.connection.execute(
            "INSERT INTO fecmur.entity (entity_id, name) " "VALUES (%s, %s)",
            entity_id,
            name,
        )
        self.connection.execute(
            "INSERT INTO fecmur.players (player_id, entity_id, case_id, role_id) "
            "VALUES (%s, %s, %s, %s)",
            entity_id,
            entity_id,
            case_id,
            role_id,
        )
        if stage:
            self.create_violation(
                case_id, entity_id, stage, statutory_citation, regulatory_citation
            )

    def create_violation(
        self, case_id, entity_id, stage, statutory_citation, regulatory_citation
    ):
        self.connection.execute(
            "INSERT INTO fecmur.violations (case_id, entity_id, stage, statutory_citation, regulatory_citation) "
            "VALUES (%s, %s, %s, %s, %s)",
            case_id,
            entity_id,
            stage,
            statutory_citation,
            regulatory_citation,
        )

    def create_document(
        self, case_id, document_id, category, ocrtext, filename='129812.pdf'
    ):
        self.connection.execute(
            "INSERT INTO fecmur.document (document_id, doc_order_id, case_id, category, ocrtext, fileimage, filename) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)",
            document_id,
            document_id,
            case_id,
            category,
            ocrtext,
            ocrtext,
            filename,
        )

    def create_calendar_event(self, entity_id, event_date, event_id, case_id):
        self.connection.execute(
            "INSERT INTO fecmur.calendar (entity_id, event_date, event_id, case_id) "
            "VALUES (%s, %s, %s, %s)",
            entity_id,
            event_date,
            event_id,
            case_id,
        )

    def create_entity(
        self,
        entity_id,
        first_name,
        last_name,
        middle_name,
        prefix,
        suffix,
        type,
        name,
        pg_date,
    ):
        self.connection.execute(
            "INSERT INTO fecmur.entity (entity_id, first_name, last_name, middle_name, "
            "prefix, suffix, type, name, pg_date) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
            entity_id,
            first_name,
            last_name,
            middle_name,
            prefix,
            suffix,
            type,
            name,
            pg_date,
        )

    def create_event(
        self,
        event_id,
        parent_event,
        event_name,
        path,
        is_key_date,
        check_primary_respondent,
        pg_date,
    ):
        self.connection.execute(
            "INSERT INTO fecmur.event (event_id, parent_event, event_name, path, is_key_date, "
            "check_primary_respondent, pg_date) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)",
            event_id,
            parent_event,
            event_name,
            path,
            is_key_date,
            check_primary_respondent,
            pg_date,
        )

    def create_relatedobjects(self, master_key, detail_key, relation_id):
        self.connection.execute(
            "INSERT INTO fecmur.relatedobjects (master_key, detail_key, relation_id) "
            "VALUES (%s, %s, %s)",
            master_key,
            detail_key,
            relation_id,
        )

    def create_settlement(
        self,
        settlement_id,
        case_id,
        initial_amount,
        final_amount,
        amount_received,
        settlement_type,
        pg_date,
    ):
        self.connection.execute(
            "INSERT INTO fecmur.settlement (settlement_id, case_id, initial_amount, "
            "final_amount, amount_received, settlement_type, pg_date) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)",
            settlement_id,
            case_id,
            initial_amount,
            final_amount,
            amount_received,
            settlement_type,
            pg_date,
        )

    def create_commission(
        self, commission_id, agenda_date, vote_date, action, case_id, pg_date
    ):
        self.connection.execute(
            "INSERT INTO fecmur.commission (commission_id, agenda_date, vote_date, action, case_id, pg_date) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            commission_id,
            agenda_date,
            vote_date,
            action,
            case_id,
            pg_date,
        )

    def create_complainant(
        self, player_id, entity_id, case_id, role_id, pg_date
    ):
        self.connection.execute(
            "INSERT INTO fecmur.players (player_id, entity_id, case_id, role_id, pg_date) "
            "VALUES (%s, %s, %s, %s, %s)",
            player_id,
            entity_id,
            case_id,
            role_id,
            pg_date,
        )

    def create_af_case_disposition(
        self, case_id, amount, description, dates
    ):
        self.connection.execute(
            "INSERT INTO fecmur.af_case_disposition (case_id, amount, description, dates) "
            "VALUES ( %s, %s, %s, %s )",
            case_id,
            amount,
            description,
            dates,
        )

    def create_non_monetary_term(
        self, term_id, term_description, pg_date
    ):
        self.connection.execute(
            "INSERT INTO fecmur.non_monetary_term (term_id, term_description, pg_date) "
            "VALUES (%s, %s, %s)",
            term_id,
            term_description,
            pg_date,
        )

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
            "commission",
            "subject",
            "role",
            "af_case",
            "af_case_disposition",
            "non_monetary_term",
        ]
        for table in tables:
            self.connection.execute("DELETE FROM fecmur.{}".format(table))
