import json

from tests import factories
from tests.common import ApiBaseTest

from webservices import utils
from webservices.rest import api
from webservices.resources.totals import TotalsView, ScheduleAByStateRecipientTotalsView


shared_fields = {
    'offsets_to_operating_expenditures': 112,
    'political_party_committee_contributions': 113,
    'other_disbursements': 114,
    'other_political_committee_contributions': 115,
    'individual_itemized_contributions': 116,
    'individual_unitemized_contributions': 117,
    'operating_expenditures': 118,
    'disbursements': 119,
    'contributions': 120,
    'contribution_refunds': 121,
    'individual_contributions': 122,
    'refunded_individual_contributions': 123,
    'refunded_other_political_committee_contributions': 124,
    'refunded_political_party_committee_contributions': 125,
    'receipts': 126,
    'coverage_start_date': None,
    'coverage_end_date': None,
    'last_report_year': 2012,
    'last_report_type_full': 'Q3',
    'last_beginning_image_number': '123',
    'cash_on_hand_beginning_period': 222.0,
    'last_cash_on_hand_end_period': 538,
    'last_debts_owed_by_committee': 42,
    'net_contributions': 123,
    'net_operating_expenditures': 321,
    'last_debts_owed_to_committee': 42,
    # 'committee_name': None,
    # 'committee_type_full': None,
    # 'committee_designation_full': None,
    # 'party_full': None
}

class TestTotals(ApiBaseTest):

    def test_Presidential_totals(self):
        committee_id = 'C8675309'
        history = factories.CommitteeHistoryFactory(
            committee_id=committee_id,
            committee_type='P',
        )
        presidential_fields = {
            'committee_id': 'C8675309',
            'cycle': 2016,
            'candidate_contribution': 1,
            'exempt_legal_accounting_disbursement': 2,
            'federal_funds': 3,
            'fundraising_disbursements': 4,
            'loan_repayments_made': 16,
            'loans_received': 5,
            'loans_received_from_candidate': 6,
            'offsets_to_fundraising_expenditures': 7,
            'offsets_to_legal_accounting': 8,
            'total_offsets_to_operating_expenditures': 9,
            'other_loans_received': 10,
            'other_receipts': 11,
            'repayments_loans_made_by_candidate': 12,
            'repayments_other_loans': 13,
            'transfers_from_affiliated_committee': 14,
            'transfers_to_other_authorized_committee': 15,

        }

        fields = utils.extend(shared_fields, presidential_fields)

        committee_total = factories.TotalsPresidentialFactory(**fields)

        results = self._results(api.url_for(TotalsView, committee_id=committee_id))
        for key, value in results[0].items():
            if key not in fields:
                print(key)
        print(results[0] == fields)
        self.assertEqual(results[0], fields)

    def test_House_Senate_totals(self):
        committee_id = 'C8675310'
        history = factories.CommitteeHistoryFactory(
            committee_id=committee_id,
            committee_type='S',
        )

        house_senate_fields = {
            'committee_id': committee_id,
            'cycle': 2016,
            'all_other_loans': 1,
            'candidate_contribution': 2,
            'loan_repayments': 3,
            'loan_repayments_candidate_loans': 4,
            'loan_repayments_other_loans': 5,
            'loans': 6,
            'loans_made_by_candidate': 7,
            'other_receipts': 8,
            'transfers_from_other_authorized_committee': 9,
            'transfers_to_other_authorized_committee': 10,
            'net_contributions': 127,
            'net_operating_expenditures': 128,
        }
        fields = utils.extend(house_senate_fields, shared_fields)

        committee_total = factories.TotalsHouseSenateFactory(**fields)
        results = self._results(api.url_for(TotalsView, committee_id=committee_id))

        self.assertEqual(results[0], fields)

    def test_Pac_Party_totals(self):
        committee_id = 'C8675311'
        history = factories.CommitteeHistoryFactory(
            committee_id=committee_id,
            committee_type='Q',
        )
        pac_party_fields = {
            'committee_id': committee_id,
            'cycle': 2016,
            'all_loans_received': 1,
            'allocated_federal_election_levin_share': 2,
            'coordinated_expenditures_by_party_committee': 3,
            'fed_candidate_committee_contributions': 4,
            'fed_candidate_contribution_refunds': 5,
            'fed_disbursements': 6,
            'fed_election_activity': 7,
            'fed_operating_expenditures': 8,
            'fed_receipts': 9,
            'independent_expenditures': 10,
            'loan_repayments_made': 11,
            'loan_repayments_received': 12,
            'loans_made': 13,
            'non_allocated_fed_election_activity': 14,
            'total_transfers': 15,
            'other_fed_operating_expenditures': 16,
            'other_fed_receipts': 17,
            'shared_fed_activity': 18,
            'shared_fed_activity_nonfed': 19,
            'shared_fed_operating_expenditures': 20,
            'shared_nonfed_operating_expenditures': 21,
            'transfers_from_affiliated_party': 22,
            'transfers_from_nonfed_account': 23,
            'transfers_from_nonfed_levin': 24,
            'transfers_to_affiliated_committee': 25,
            'net_contributions': 127,
            'net_operating_expenditures': 128,
        }
        fields = utils.extend(pac_party_fields, shared_fields)

        committee_total = factories.TotalsPacPartyFactory(**fields)
        results = self._results(api.url_for(TotalsView, committee_id=committee_id))

        self.assertEqual(results[0], fields)

    def test_ie_totals(self):
        committee_id = 'C8675312'
        history = factories.CommitteeHistoryFactory(
            committee_id=committee_id,
            committee_type='I',
        )
        ie_fields = {
            'committee_id': committee_id,
            'cycle': 2014,
            'coverage_start_date': None,
            'coverage_end_date': None,
            'total_independent_contributions': 1,
            'total_independent_expenditures': 2,
        }

        committee_total = factories.TotalsIEOnlyFactory(**ie_fields)
        results = self._results(api.url_for(TotalsView, committee_id=committee_id))

        self.assertEqual(results[0], ie_fields)

    def test_totals_house_senate(self):
        committee = factories.CommitteeFactory(committee_type='H')
        committee_id = committee.committee_id
        factories.CommitteeHistoryFactory(committee_id=committee_id, committee_type='H')
        [
            factories.TotalsHouseSenateFactory(committee_id=committee_id, cycle=2008),
            factories.TotalsHouseSenateFactory(committee_id=committee_id, cycle=2012),
        ]
        response = self._results(api.url_for(TotalsView, committee_id=committee_id))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['cycle'], 2012)
        self.assertEqual(response[1]['cycle'], 2008)

    def test_totals_committee_not_found(self):
        resp = self.app.get(api.url_for(TotalsView, committee_id='fake'))
        self.assertEqual(resp.status_code, 404)
        self.assertEqual(resp.content_type, 'application/json')
        data = json.loads(resp.data.decode('utf-8'))
        self.assertIn('not found', data['message'].lower())

    def test_sched_a_by_state_recipient_totals(self):
        rows = [
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=50000,
                count=10,
                cycle=2008,
                state='CA',
                state_full='California',
                committee_type='P',
                committee_type_full='Presidential'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=10000,
                count=5,
                cycle=2010,
                state='ND',
                state_full='North Dakota',
                committee_type='H',
                committee_type_full='House'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=20000,
                count=15,
                cycle=2012,
                state='NC',
                state_full='North Carolina',
                committee_type='S',
                committee_type_full='Senate'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=90000,
                count=4,
                cycle=2014,
                state='NY',
                state_full='New York',
                committee_type='U',
                committee_type_full='single candidate independent expenditure'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=150000,
                count=15,
                cycle=2016,
                state='TX',
                state_full='Texas',
                committee_type='',
                committee_type_full='All'
            ),
        ]

        response = self._results(
            api.url_for(ScheduleAByStateRecipientTotalsView)
        )

        self.assertEqual(len(response), 5)
        self.assertEqual(response[0]['total'], 50000)
        self.assertEqual(response[0]['cycle'], 2008)
        self.assertEqual(response[0]['state'], 'CA')
        self.assertEqual(response[0]['committee_type'], 'P')
        self.assertEqual(response[4]['total'], 150000)
        self.assertEqual(response[4]['cycle'], 2016)
        self.assertEqual(response[4]['state'], 'TX')
        self.assertEqual(response[4]['committee_type'], '')

    def test_sched_a_by_state_recipient_totals_sort_by_cycle(self):
        rows = [
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=50000,
                count=10,
                cycle=2008,
                state='CA',
                state_full='California',
                committee_type='P',
                committee_type_full='Presidential'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=10000,
                count=5,
                cycle=2010,
                state='ND',
                state_full='North Dakota',
                committee_type='H',
                committee_type_full='House'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=20000,
                count=15,
                cycle=2012,
                state='NC',
                state_full='North Carolina',
                committee_type='S',
                committee_type_full='Senate'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=90000,
                count=4,
                cycle=2014,
                state='NY',
                state_full='New York',
                committee_type='U',
                committee_type_full='single candidate independent expenditure'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=150000,
                count=15,
                cycle=2016,
                state='TX',
                state_full='Texas',
                committee_type='',
                committee_type_full='All'
            ),
        ]

        response = self._results(
            api.url_for(
                ScheduleAByStateRecipientTotalsView,
                sort='-cycle'
            )
        )

        self.assertEqual(len(response), 5)
        self.assertEqual(response[0]['total'], 150000)
        self.assertEqual(response[0]['cycle'], 2016)
        self.assertEqual(response[0]['state'], 'TX')
        self.assertEqual(response[0]['committee_type'], '')
        self.assertEqual(response[4]['total'], 50000)
        self.assertEqual(response[4]['cycle'], 2008)
        self.assertEqual(response[4]['state'], 'CA')
        self.assertEqual(response[4]['committee_type'], 'P')

    def test_sched_a_by_state_recipient_totals_filter_by_committee_types(self):
        rows = [
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=50000,
                count=10,
                cycle=2008,
                state='CA',
                state_full='California',
                committee_type='P',
                committee_type_full='Presidential'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=10000,
                count=5,
                cycle=2010,
                state='ND',
                state_full='North Dakota',
                committee_type='H',
                committee_type_full='House'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=20000,
                count=15,
                cycle=2012,
                state='NC',
                state_full='North Carolina',
                committee_type='S',
                committee_type_full='Senate'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=90000,
                count=4,
                cycle=2014,
                state='NY',
                state_full='New York',
                committee_type='U',
                committee_type_full='single candidate independent expenditure'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=150000,
                count=15,
                cycle=2016,
                state='TX',
                state_full='Texas',
                committee_type='',
                committee_type_full='All'
            ),
        ]

        response = self._results(
            api.url_for(
                ScheduleAByStateRecipientTotalsView,
                committee_type=['P', 'H', 'S',]
            )
        )

        self.assertEqual(len(response), 3)
        self.assertEqual(response[0]['total'], 50000)
        self.assertEqual(response[0]['cycle'], 2008)
        self.assertEqual(response[0]['state'], 'CA')
        self.assertEqual(response[0]['committee_type'], 'P')

        self.assertEqual(response[1]['total'], 10000)
        self.assertEqual(response[1]['cycle'], 2010)
        self.assertEqual(response[1]['state'], 'ND')
        self.assertEqual(response[1]['committee_type'], 'H')

        self.assertEqual(response[2]['total'], 20000)
        self.assertEqual(response[2]['cycle'], 2012)
        self.assertEqual(response[2]['state'], 'NC')
        self.assertEqual(response[2]['committee_type'], 'S')

    def test_sched_a_by_state_recipient_totals_filter_by_state(self):
        rows = [
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=50000,
                count=10,
                cycle=2008,
                state='CA',
                state_full='California',
                committee_type='P',
                committee_type_full='Presidential'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=10000,
                count=5,
                cycle=2010,
                state='ND',
                state_full='North Dakota',
                committee_type='H',
                committee_type_full='House'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=20000,
                count=15,
                cycle=2012,
                state='NC',
                state_full='North Carolina',
                committee_type='S',
                committee_type_full='Senate'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=90000,
                count=4,
                cycle=2014,
                state='NY',
                state_full='New York',
                committee_type='U',
                committee_type_full='single candidate independent expenditure'
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=150000,
                count=15,
                cycle=2016,
                state='TX',
                state_full='Texas',
                committee_type='',
                committee_type_full='All'
            ),
        ]

        response = self._results(
            api.url_for(
                ScheduleAByStateRecipientTotalsView,
                state='NY'
            )
        )

        self.assertEqual(len(response), 1)
        self.assertEqual(response[0]['total'], 90000)
        self.assertEqual(response[0]['cycle'], 2014)
        self.assertEqual(response[0]['state'], 'NY')
        self.assertEqual(response[0]['committee_type'], 'U')
