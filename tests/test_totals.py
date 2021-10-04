import datetime
import json
import sqlalchemy as sa

from tests import factories
from tests.common import ApiBaseTest

from webservices import utils
from webservices.rest import api
from webservices.resources.totals import (
    TotalsCommitteeView,
    TotalsByEntityTypeView,
    ScheduleAByStateRecipientTotalsView,
)


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
    'committee_name': "",
    'committee_type': "",
    'committee_designation': "",
    'committee_type_full': "",
    'committee_designation_full': "",
    'party_full': "",
    'treasurer_name': 'Treasurer, Trudy',
    'committee_state': 'DC',
    'filing_frequency': 'Q',
    'filing_frequency_full': 'Quarterly filer',
    'first_file_date': datetime.date.fromisoformat("1982-12-31"),
    'organization_type': 'L',
    'organization_type_full': 'Labor'
}

transaction_coverage_fields = {'transaction_coverage_date': None}


# test for endpoint: /totals/{entity_type}
class TestTotalsByEntityType(ApiBaseTest):

    # Factories are being weird about test data - base cases to share
    first_pac_total = {
        'committee_id': 'C00001',
        'committee_type': 'O',
        'cycle': 2018,
        'committee_designation': 'A',
        'all_loans_received': 1,
        'allocated_federal_election_levin_share': 2,
        'treasurer_name': 'Treasurer, Trudy',
        'committee_state': 'DC',
        'filing_frequency': 'Q',
        'filing_frequency_full': 'Quarterly filer',
        'first_file_date': datetime.date.fromisoformat("1982-12-31"),
        'receipts': 50,
        'disbursements': 200,
        'sponsor_candidate_ids': ['H01'],
        'organization_type': 'C',
        'organization_type_full': 'Corporation',
    }
    second_pac_total = {
        'committee_id': 'C00002',
        'committee_type': 'N',
        'cycle': 2016,
        'committee_designation': 'B',
        'all_loans_received': 10,
        'allocated_federal_election_levin_share': 20,
        'treasurer_name': 'Treasurer, Tom',
        'committee_state': 'CT',
        'filing_frequency': 'M',
        'filing_frequency_full': 'Monthly filer',
        'first_file_date': datetime.date.fromisoformat("1984-12-31"),
        'receipts': 200,
        'disbursements': 50,
        'sponsor_candidate_ids': ['H02'],
        'organization_type': 'T',
        'organization_type_full': 'Trade',
    }

    def test_pac_total_by_entity_type(self):

        factories.TotalsPacFactory(**self.first_pac_total)
        factories.TotalsPacFactory(**self.second_pac_total)

        results = self._results(
            api.url_for(TotalsByEntityTypeView, entity_type='pac')
        )
        assert len(results) == 2
        assert results[0]['committee_id'] == 'C00001'
        assert results[1]['committee_id'] == 'C00002'

        # Test all fields for result #2

        # Dates are weird - pulling them out to test separately
        result_first_file_date = results[1].pop('first_file_date')
        expected_first_file_date = self.second_pac_total.pop('first_file_date').isoformat()
        self.assertEqual(result_first_file_date, expected_first_file_date)

        # Check all the results for fields we've created in `second_pac_total`
        test_subset = {k: v for k, v in results[1].items() if k in self.second_pac_total}
        self.assertEqual(test_subset, self.second_pac_total)

    def test_cycle_filter(self):
        presidential_fields = {
            'committee_id': 'C00001',
            'cycle': 2016,
            'candidate_contribution': 1,
            'exempt_legal_accounting_disbursement': 2,
            'federal_funds': 300,
        }
        factories.CommitteeTotalsPerCycleFactory(**presidential_fields)
        results = self._results(
            api.url_for(TotalsByEntityTypeView, cycle=2016, entity_type='presidential')
        )
        assert len(results) == 1
        self.assertEqual(results[0]['cycle'], presidential_fields['cycle'])

    def test_designation_filter(self):
        party_fields = {
            'committee_id': 'C00001',
            'cycle': 2014,
            'committee_name': 'REPUBLICAN COMMITTEE',
            'committee_designation': 'U',
            'committee_type': 'X',
            'all_loans_received': 1,
            'allocated_federal_election_levin_share': 2,
        }
        factories.TotalsPacFactory(**party_fields)
        results = self._results(
            api.url_for(TotalsByEntityTypeView, committee_designation='U', entity_type='party')
        )
        assert len(results) == 1
        self.assertEqual(results[0]['committee_designation'], party_fields['committee_designation'])

    def test_pac_party_multi_filters(self):

        factories.TotalsPacFactory(**self.first_pac_total)
        factories.TotalsPacFactory(**self.second_pac_total)

        filters = [
            'committee_type',
            'cycle',
            'committee_id',
            'committee_designation',
            'committee_state',
            'committee_id',
            'filing_frequency',
            'organization_type',
        ]

        for field in filters:
            results = self._results(
                api.url_for(TotalsByEntityTypeView,
                    entity_type='pac-party',
                    **{field: self.second_pac_total.get(field)})
            )
            assert len(results) == 1
            assert results[0][field] == self.second_pac_total.get(field)

    def test_pac_party_multi_committee_id(self):

        factories.TotalsPacFactory(**self.first_pac_total)
        factories.TotalsPacFactory(**self.second_pac_total)
        factories.TotalsPacFactory(
            **{
                "committee_id": "C00003",
                "committee_type": "Q",
                "cycle": 2016,
                "committee_designation": "B",
                "all_loans_received": 10,
                "allocated_federal_election_levin_share": 20,
                "treasurer_name": "Treasurer, Tom",
                "committee_state": "CT",
                "filing_frequency": "M",
                "filing_frequency_full": "Monthly filer",
                "first_file_date": datetime.date.fromisoformat("1984-12-31"),
                "receipts": 200,
                "disbursements": 50,
                "sponsor_candidate_ids": ["H02"],
                "organization_type": "T",
                "organization_type_full": "Trade",
            }
        )

        results = self._results(
            api.url_for(
                TotalsByEntityTypeView,
                entity_type="pac-party",
                committee_id=[
                    self.first_pac_total.get("committee_id"),
                    self.second_pac_total.get("committee_id"),
                ],
            )
        )

        assert len(results) == 2
        self.assertTrue(all(each["committee_id"] != "C00003" for each in results))

    def test_filter_receipts(self):

        factories.TotalsPacFactory(**self.first_pac_total)
        factories.TotalsPacFactory(**self.second_pac_total)

        results = self._results(
            api.url_for(
                TotalsByEntityTypeView,
                entity_type='pac-party',
                min_receipts=100
            )
        )
        self.assertTrue(all(each['receipts'] >= 100 for each in results))
        results = self._results(
            api.url_for(
                TotalsByEntityTypeView,
                entity_type='pac-party',
                max_receipts=150
            )
        )
        self.assertTrue(all(each['receipts'] <= 150 for each in results))
        results = self._results(
            api.url_for(
                TotalsByEntityTypeView,
                entity_type='pac-party',
                min_receipts=60,
                max_receipts=100)
        )
        self.assertTrue(all(60 <= each['receipts'] <= 100 for each in results))

    def test_filter_disbursements(self):

        factories.TotalsPacFactory(**self.first_pac_total)
        factories.TotalsPacFactory(**self.second_pac_total)

        results = self._results(
            api.url_for(
                TotalsByEntityTypeView,
                entity_type='pac-party',
                min_disbursements=100
            )
        )
        self.assertTrue(all(each['disbursements'] >= 100 for each in results))
        results = self._results(
            api.url_for(
                TotalsByEntityTypeView,
                entity_type='pac-party',
                max_disbursements=150
            )
        )
        self.assertTrue(all(each['disbursements'] <= 150 for each in results))
        results = self._results(
            api.url_for(
                TotalsByEntityTypeView,
                entity_type='pac-party',
                min_disbursements=60,
                max_disbursements=100
            )
        )
        self.assertTrue(all(60 <= each['disbursements'] <= 100 for each in results))

    def test_treasurer_filter(self):

        factories.TotalsPacFactory(
            **utils.extend(
                self.first_pac_total,
                {'treasurer_text': sa.func.to_tsvector("Treasurer, Trudy")}
            )
        )
        factories.TotalsPacFactory(
            **utils.extend(
                self.second_pac_total,
                {'treasurer_text': sa.func.to_tsvector("Treasurer, Tom")}
            )
        )

        results = self._results(
            api.url_for(
                TotalsByEntityTypeView,
                entity_type='pac-party',
                treasurer_name='Tom'
            )
        )
        assert len(results) == 1
        assert results[0]["committee_id"] == self.second_pac_total.get("committee_id")

    def test_sponsor_candidate_id_filter(self):

        factories.TotalsPacFactory(**self.first_pac_total)
        factories.TotalsPacFactory(**self.second_pac_total)

        results = self._results(
            api.url_for(
                TotalsByEntityTypeView,
                entity_type='pac-party',
                sponsor_candidate_id='H02'
            )
        )
        assert len(results) == 1
        assert results[0]["committee_id"] == self.second_pac_total.get("committee_id")

    def test_field_sponsor_candidate_list(self):

        committee = factories.TotalsPacFactory(**self.first_pac_total)

        factories.PacSponsorCandidatePerCycleFactory(
            committee_id=committee.committee_id,
            cycle=committee.cycle,
            sponsor_candidate_id="H01",
            sponsor_candidate_name="Sponsor A",
        )
        factories.PacSponsorCandidatePerCycleFactory(
            committee_id='C007',
            cycle=committee.cycle + 2,
            sponsor_candidate_id="S03",
            sponsor_candidate_name="Sponsor B",
        )
        factories.PacSponsorCandidatePerCycleFactory(
            committee_id='C007',
            cycle=committee.cycle,
            sponsor_candidate_id="S03",
            sponsor_candidate_name="Sponsor B",
        )
        results = self._results(
            api.url_for(
                TotalsByEntityTypeView,
                entity_type='pac-party',
                committee_id=committee.committee_id
            )
        )
        self.assertEqual(len(results), 1)
        self.assertIn("sponsor_candidate_list", results[0])
        self.assertEqual(
            results[0]["sponsor_candidate_list"][0]["sponsor_candidate_name"], "Sponsor A"
        )
        self.assertEqual(
            results[0]["sponsor_candidate_list"][0]["sponsor_candidate_id"], "H01"
        )


# test for endpoint: /committee/{committee_id}/totals/
class TestTotals(ApiBaseTest):
    def test_Presidential_totals(self):
        committee_id = 'C8675309'
        transaction_coverage = factories.TransactionCoverageFactory(  # noqa
            committee_id=committee_id, fec_election_year=2016
        )
        history = factories.CommitteeHistoryFactory(  # noqa
            committee_id=committee_id, committee_type='P',
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
        committee_total = factories.CommitteeTotalsPerCycleFactory(**fields)  # noqa

        fields = utils.extend(fields, transaction_coverage_fields)

        results = self._results(
            api.url_for(TotalsCommitteeView, committee_id=committee_id.lower())
        )

        # Dates are weird - pulling them out to test separately
        result_first_file_date = results[0].pop('first_file_date')
        fields_first_file_date = fields.pop('first_file_date').isoformat()
        self.assertEqual(result_first_file_date, fields_first_file_date)

        # Test other fields
        self.assertEqual(results[0], fields)

    def test_House_Senate_totals(self):
        committee_id = 'C8675310'
        transaction_coverage = factories.TransactionCoverageFactory(  # noqa
            committee_id=committee_id, fec_election_year=2016
        )
        history = factories.CommitteeHistoryFactory(  # noqa
            committee_id=committee_id, committee_type='S',
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
        committee_total = factories.TotalsHouseSenateFactory(**fields)  # noqa

        fields = utils.extend(fields, transaction_coverage_fields)

        results = self._results(
            api.url_for(TotalsCommitteeView, committee_id=committee_id)
        )

        # Dates are weird - pulling them out to test separately
        result_first_file_date = results[0].pop('first_file_date')
        fields_first_file_date = fields.pop('first_file_date').isoformat()
        self.assertEqual(result_first_file_date, fields_first_file_date)

        # Test other fields
        self.assertEqual(results[0], fields)

    def test_House_Senate_Jointed_totals(self):
        committee_id = 'C009'
        history = factories.CommitteeHistoryFactory(  # noqa
            committee_id=committee_id, committee_type='S',
        )

        house_senate_fields = {
            'committee_id': committee_id,
            'cycle': 2016,
            'all_other_loans': 1,
            'candidate_contribution': 2,
            'loan_repayments': 3,
            'loan_repayments_candidate_loans': 4,
            'loan_repayments_other_loans': 5,
            'committee_type': 'S',
            'committee_designation': 'J',
        }

        committee_total = factories.TotalsHouseSenateFactory(**house_senate_fields) # noqa
        results = self._results(
            api.url_for(TotalsCommitteeView, committee_id=committee_id)
        )

        self.assertEqual(len(results), 1)

    def test_Pac_Party_totals(self):
        committee_id = 'C8675311'
        transaction_coverage = factories.TransactionCoverageFactory(  # noqa
            committee_id=committee_id, fec_election_year=2016
        )
        history = factories.CommitteeHistoryFactory(  # noqa
            committee_id=committee_id, committee_type='Q',
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
            'federal_funds': 2,
            'independent_expenditures': 10,
            'loan_repayments_made': 11,
            'loan_repayments_received': 12,
            'loans_made': 13,
            'loans_and_loan_repayments_received': 2,
            'loans_and_loan_repayments_made': 2,
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
            'exp_subject_limits': 4,
            'exp_prior_years_subject_limits': 4,
            'total_exp_subject_limits': 4,
            'refunds_relating_convention_exp': 4,
            'itemized_refunds_relating_convention_exp': 4,
            'unitemized_refunds_relating_convention_exp': 4,
            'other_refunds': 4,
            'itemized_other_refunds': 4,
            'unitemized_other_refunds': 4,
            'itemized_other_income': 4,
            'unitemized_other_income': 4,
            'convention_exp': 4,
            'itemized_convention_exp': 4,
            'unitemized_convention_exp': 4,
            'itemized_other_disb': 4,
            'unitemized_other_disb': 4,
            'sponsor_candidate_ids': ['H01'],
            'sponsor_candidate_list': [],
        }
        fields = utils.extend(pac_party_fields, shared_fields)
        committee_total = factories.TotalsPacPartyFactory(**fields)  # noqa

        fields = utils.extend(fields, transaction_coverage_fields)

        results = self._results(
            api.url_for(TotalsCommitteeView, committee_id=committee_id)
        )
        # Dates are weird - pulling them out to test separately
        result_first_file_date = results[0].pop('first_file_date')
        fields_first_file_date = fields.pop('first_file_date').isoformat()
        self.assertEqual(result_first_file_date, fields_first_file_date)

        # Test calculated percentages

        # `individual_itemized_contributions_percent`
        itemized_percent = utils.get_percentage(
            [fields.get('individual_itemized_contributions')],
            [fields.get('receipts')]
        )
        itemized_percent_result = results[0].pop('individual_itemized_contributions_percent')
        self.assertEqual(itemized_percent, itemized_percent_result)

        # `individual_unitemized_contributions_percent`
        unitemized_percent = utils.get_percentage(
            [fields.get('individual_unitemized_contributions')],
            [fields.get('receipts')]
        )
        unitemized_percent_result = results[0].pop('individual_unitemized_contributions_percent')
        self.assertEqual(unitemized_percent, unitemized_percent_result)

        # `individual_contributions_percent`
        individual_percent = utils.get_percentage(
            [fields.get('individual_contributions')],
            [fields.get('receipts')]
        )
        individual_percent_result = results[0].pop('individual_contributions_percent')
        self.assertEqual(individual_percent, individual_percent_result)

        # `contributions_percent`
        contributions_percent = utils.get_percentage(
            [fields.get('contributions')],
            [fields.get('receipts')]
        )
        contributions_percent_result = results[0].pop('contributions_percent')
        self.assertEqual(contributions_percent, contributions_percent_result)

        # `other_federal_receipts_percent`
        other_percent = utils.get_percentage(
            [fields.get('other_fed_receipts')],
            [fields.get('receipts')]
        )
        other_percent_result = results[0].pop('other_federal_receipts_percent')
        self.assertEqual(other_percent, other_percent_result)

        # `party_and_other_committee_contributions_percent`
        party_percent = utils.get_percentage(
            [
                fields.get('other_political_committee_contributions'),
                fields.get('political_party_committee_contributions')
            ],
            [fields.get('receipts')]
        )
        party_percent_result = results[0].pop(
            'party_and_other_committee_contributions_percent'
        )
        self.assertEqual(party_percent, party_percent_result)

        # `contributions_ie_and_party_expenditures_made_percent`

        contributions_made_percent = utils.get_percentage(
            [
                fields.get('fed_candidate_committee_contributions'),
                fields.get('independent_expenditures'),
                fields.get('coordinated_expenditures_by_party_committee'),

            ],
            [fields.get('disbursements')]
        )
        contributions_made_percent_result = results[0].pop(
            'contributions_ie_and_party_expenditures_made_percent'
        )
        self.assertEqual(
            contributions_made_percent, contributions_made_percent_result
        )

        # `operating_expenditures_percent`
        operating_expenditures_percent = utils.get_percentage(
            [fields.get('operating_expenditures')],
            [fields.get('disbursements')]
        )
        operating_expenditures_percent_result = results[0].pop(
            'operating_expenditures_percent'
        )
        self.assertEqual(
            operating_expenditures_percent, operating_expenditures_percent_result
        )

        # Test the rest of the fields
        self.assertEqual(results[0], fields)

    def test_Pac_totals(self):
        committee_id = 'C8675311'
        transaction_coverage = factories.TransactionCoverageFactory(  # noqa
            committee_id=committee_id, fec_election_year=2016
        )
        history = factories.CommitteeHistoryFactory(  # noqa
            committee_id=committee_id, committee_type='O',
        )
        pac_fields = {
            'committee_id': committee_id,
            'cycle': 2016,
            'treasurer_name': 'Treasurer, Trudy',
            'all_loans_received': 1,
            'allocated_federal_election_levin_share': 2,
            'coordinated_expenditures_by_party_committee': 3,
            'fed_candidate_committee_contributions': 4,
            'fed_candidate_contribution_refunds': 5,
            'fed_disbursements': 6,
            'fed_election_activity': 7,
            'fed_operating_expenditures': 8,
            'fed_receipts': 9,
            'federal_funds': 2,
            'independent_expenditures': 10,
            'loan_repayments_made': 11,
            'loan_repayments_received': 12,
            'loans_made': 13,
            'loans_and_loan_repayments_received': 2,
            'loans_and_loan_repayments_made': 2,
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
            'exp_subject_limits': 4,
            'exp_prior_years_subject_limits': 4,
            'total_exp_subject_limits': 4,
            'refunds_relating_convention_exp': 4,
            'itemized_refunds_relating_convention_exp': 4,
            'unitemized_refunds_relating_convention_exp': 4,
            'other_refunds': 4,
            'itemized_other_refunds': 4,
            'unitemized_other_refunds': 4,
            'itemized_other_income': 4,
            'unitemized_other_income': 4,
            'convention_exp': 4,
            'itemized_convention_exp': 4,
            'unitemized_convention_exp': 4,
            'itemized_other_disb': 4,
            'unitemized_other_disb': 4,
            'sponsor_candidate_ids': ['S01'],
            'sponsor_candidate_list': [],
        }
        fields = utils.extend(pac_fields, shared_fields)
        committee_total = factories.TotalsPacFactory(**fields)  # noqa

        fields = utils.extend(fields, transaction_coverage_fields)

        results = self._results(
            api.url_for(TotalsCommitteeView, committee_id=committee_id)
        )
        # Dates are weird - pulling them out to test separately
        result_first_file_date = results[0].pop('first_file_date')
        fields_first_file_date = fields.pop('first_file_date').isoformat()
        self.assertEqual(result_first_file_date, fields_first_file_date)

        # Test calculated percentages

        # `individual_itemized_contributions_percent`
        itemized_percent = utils.get_percentage(
            [fields.get('individual_itemized_contributions')],
            [fields.get('receipts')]
        )
        itemized_percent_result = results[0].pop('individual_itemized_contributions_percent')
        self.assertEqual(itemized_percent, itemized_percent_result)

        # `individual_unitemized_contributions_percent`
        unitemized_percent = utils.get_percentage(
            [fields.get('individual_unitemized_contributions')],
            [fields.get('receipts')]
        )
        unitemized_percent_result = results[0].pop('individual_unitemized_contributions_percent')
        self.assertEqual(unitemized_percent, unitemized_percent_result)

        # `individual_contributions_percent`
        individual_percent = utils.get_percentage(
            [fields.get('individual_contributions')],
            [fields.get('receipts')]
        )
        individual_percent_result = results[0].pop('individual_contributions_percent')
        self.assertEqual(individual_percent, individual_percent_result)

        # `contributions_percent`
        contributions_percent = utils.get_percentage(
            [fields.get('contributions')],
            [fields.get('receipts')]
        )
        contributions_percent_result = results[0].pop('contributions_percent')
        self.assertEqual(contributions_percent, contributions_percent_result)

        # `other_federal_receipts_percent`
        other_percent = utils.get_percentage(
            [fields.get('other_fed_receipts')],
            [fields.get('receipts')]
        )
        other_percent_result = results[0].pop('other_federal_receipts_percent')
        self.assertEqual(other_percent, other_percent_result)

        # `party_and_other_committee_contributions_percent`
        party_percent = utils.get_percentage(
            [
                fields.get('other_political_committee_contributions'),
                fields.get('political_party_committee_contributions')
            ],
            [fields.get('receipts')]
        )
        party_percent_result = results[0].pop(
            'party_and_other_committee_contributions_percent'
        )
        self.assertEqual(party_percent, party_percent_result)

        # `contributions_ie_and_party_expenditures_made_percent`

        contributions_made_percent = utils.get_percentage(
            [
                fields.get('fed_candidate_committee_contributions'),
                fields.get('independent_expenditures'),
                fields.get('coordinated_expenditures_by_party_committee'),

            ],
            [fields.get('disbursements')]
        )
        contributions_made_percent_result = results[0].pop(
            'contributions_ie_and_party_expenditures_made_percent'
        )
        self.assertEqual(
            contributions_made_percent, contributions_made_percent_result
        )

        # `operating_expenditures_percent`
        operating_expenditures_percent = utils.get_percentage(
            [fields.get('operating_expenditures')],
            [fields.get('disbursements')]
        )
        operating_expenditures_percent_result = results[0].pop(
            'operating_expenditures_percent'
        )
        self.assertEqual(
            operating_expenditures_percent, operating_expenditures_percent_result
        )

        # Test the rest of the fields
        self.assertEqual(results[0], fields)

    def test_party_totals(self):

        committee_id = 'C00540005'
        transaction_coverage = factories.TransactionCoverageFactory(  # noqa
            committee_id=committee_id, fec_election_year=2014
        )
        history = factories.CommitteeHistoryFactory(  # noqa
            committee_id=committee_id, committee_type='X',
        )
        party_fields = {
            'committee_id': committee_id,
            'cycle': 2014,
            'committee_name': 'PRESIDENTIAL INAUGURAL COMMITTEE',
            'coverage_start_date': '2012-12-10 00:00:00',
            'coverage_end_date': '2013-08-07 00:00:00',
            'all_loans_received': 1,
            'allocated_federal_election_levin_share': 2,
            'coordinated_expenditures_by_party_committee': 3,
            'fed_candidate_committee_contributions': 4,
            'fed_candidate_contribution_refunds': 5,
            'fed_disbursements': 6,
            'fed_election_activity': 7,
            'fed_operating_expenditures': 8,
            'fed_receipts': 9,
            'federal_funds': 2,
            'independent_expenditures': 10,
            'loan_repayments_made': 11,
            'loan_repayments_received': 12,
            'loans_and_loan_repayments_received': 2,
            'loans_and_loan_repayments_made': 2,
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
            'exp_subject_limits': 4,
            'exp_prior_years_subject_limits': 4,
            'total_exp_subject_limits': 4,
            'refunds_relating_convention_exp': 4,
            'itemized_refunds_relating_convention_exp': 4,
            'unitemized_refunds_relating_convention_exp': 4,
            'other_refunds': 4,
            'itemized_other_refunds': 4,
            'unitemized_other_refunds': 4,
            'itemized_other_income': 4,
            'unitemized_other_income': 4,
            'convention_exp': 4,
            'itemized_convention_exp': 4,
            'unitemized_convention_exp': 4,
            'itemized_other_disb': 4,
            'unitemized_other_disb': 4,
            'sponsor_candidate_ids': ['S02'],
            'sponsor_candidate_list': [],
        }
        fields = utils.extend(party_fields, shared_fields)
        committee_total = factories.TotalsPartyFactory(**fields)  # noqa

        fields = utils.extend(fields, transaction_coverage_fields)

        results = self._results(
            api.url_for(TotalsCommitteeView, committee_id=committee_id)
        )
        # Dates are weird - pulling them out to test separately
        result_first_file_date = results[0].pop('first_file_date')
        fields_first_file_date = fields.pop('first_file_date').isoformat()
        self.assertEqual(result_first_file_date, fields_first_file_date)

        # Test calculated percentages

        # `individual_itemized_contributions_percent`
        itemized_percent = utils.get_percentage(
            [fields.get('individual_itemized_contributions')],
            [fields.get('receipts')]
        )
        itemized_percent_result = results[0].pop('individual_itemized_contributions_percent')
        self.assertEqual(itemized_percent, itemized_percent_result)

        # `individual_unitemized_contributions_percent`
        unitemized_percent = utils.get_percentage(
            [fields.get('individual_unitemized_contributions')],
            [fields.get('receipts')]
        )
        unitemized_percent_result = results[0].pop('individual_unitemized_contributions_percent')
        self.assertEqual(unitemized_percent, unitemized_percent_result)

        # `individual_contributions_percent`
        individual_percent = utils.get_percentage(
            [fields.get('individual_contributions')],
            [fields.get('receipts')]
        )
        individual_percent_result = results[0].pop('individual_contributions_percent')
        self.assertEqual(individual_percent, individual_percent_result)

        # `contributions_percent`
        contributions_percent = utils.get_percentage(
            [fields.get('contributions')],
            [fields.get('receipts')]
        )
        contributions_percent_result = results[0].pop('contributions_percent')
        self.assertEqual(contributions_percent, contributions_percent_result)

        # `other_federal_receipts_percent`
        other_percent = utils.get_percentage(
            [fields.get('other_fed_receipts')],
            [fields.get('receipts')]
        )
        other_percent_result = results[0].pop('other_federal_receipts_percent')
        self.assertEqual(other_percent, other_percent_result)

        # `party_and_other_committee_contributions_percent`
        party_percent = utils.get_percentage(
            [
                fields.get('other_political_committee_contributions'),
                fields.get('political_party_committee_contributions')
            ],
            [fields.get('receipts')]
        )
        party_percent_result = results[0].pop(
            'party_and_other_committee_contributions_percent'
        )
        self.assertEqual(party_percent, party_percent_result)

        # `contributions_ie_and_party_expenditures_made_percent`

        contributions_made_percent = utils.get_percentage(
            [
                fields.get('fed_candidate_committee_contributions'),
                fields.get('independent_expenditures'),
                fields.get('coordinated_expenditures_by_party_committee'),

            ],
            [fields.get('disbursements')]
        )
        contributions_made_percent_result = results[0].pop(
            'contributions_ie_and_party_expenditures_made_percent'
        )
        self.assertEqual(
            contributions_made_percent, contributions_made_percent_result
        )

        # `operating_expenditures_percent`
        operating_expenditures_percent = utils.get_percentage(
            [fields.get('operating_expenditures')],
            [fields.get('disbursements')]
        )
        operating_expenditures_percent_result = results[0].pop(
            'operating_expenditures_percent'
        )
        self.assertEqual(
            operating_expenditures_percent, operating_expenditures_percent_result
        )

        # Test other fields
        self.assertEqual(results[0], fields)

    def test_ie_totals(self):
        committee_id = 'C8675312'
        history = factories.CommitteeHistoryFactory(  # noqa
            committee_id=committee_id, committee_type='I',
        )
        ie_fields = {
            'committee_id': committee_id,
            'cycle': 2014,
            'coverage_start_date': None,
            'coverage_end_date': None,
            'total_independent_contributions': 1,
            'total_independent_expenditures': 2,
            'committee_state': 'DC',
            'filing_frequency': 'Q',
            'filing_frequency_full': 'Quarterly filer',
            'first_file_date': datetime.date.fromisoformat("1982-12-31"),
        }
        committee_total = factories.TotalsIEOnlyFactory(**ie_fields)  # noqa

        fields = utils.extend(ie_fields, transaction_coverage_fields)

        results = self._results(
            api.url_for(TotalsCommitteeView, committee_id=committee_id)
        )

        # Dates are weird - pulling them out to test separately
        result_first_file_date = results[0].pop('first_file_date')
        fields_first_file_date = fields.pop('first_file_date').isoformat()
        self.assertEqual(result_first_file_date, fields_first_file_date)

        # Test other fields
        self.assertEqual(results[0], fields)

    def test_totals_house_senate(self):
        committee = factories.CommitteeFactory(committee_type='H')
        committee_id = committee.committee_id
        [
            factories.TransactionCoverageFactory(
                committee_id=committee_id, fec_election_year=2008
            ),
            factories.TransactionCoverageFactory(
                committee_id=committee_id, fec_election_year=2012
            ),
        ]
        factories.CommitteeHistoryFactory(committee_id=committee_id, committee_type='H')
        [
            factories.TotalsHouseSenateFactory(committee_id=committee_id, cycle=2008),
            factories.TotalsHouseSenateFactory(committee_id=committee_id, cycle=2012),
        ]
        response = self._results(
            api.url_for(TotalsCommitteeView, committee_id=committee_id)
        )
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['cycle'], 2012)
        self.assertEqual(response[1]['cycle'], 2008)

    def test_totals_committee_not_found(self):
        resp = self.app.get(api.url_for(TotalsCommitteeView, committee_id='fake'))
        self.assertEqual(resp.status_code, 404)
        self.assertEqual(resp.content_type, 'application/json')
        data = json.loads(resp.data.decode('utf-8'))
        self.assertIn('not found', data['message'].lower())

    def test_sched_a_by_state_recipient_totals(self):
        rows = [  # noqa
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=50000,
                count=10,
                cycle=2008,
                state='CA',
                state_full='California',
                committee_type='P',
                committee_type_full='Presidential',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=10000,
                count=5,
                cycle=2010,
                state='ND',
                state_full='North Dakota',
                committee_type='H',
                committee_type_full='House',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=20000,
                count=15,
                cycle=2012,
                state='NC',
                state_full='North Carolina',
                committee_type='S',
                committee_type_full='Senate',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=90000,
                count=4,
                cycle=2014,
                state='NY',
                state_full='New York',
                committee_type='U',
                committee_type_full='single candidate independent expenditure',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=150000,
                count=15,
                cycle=2016,
                state='TX',
                state_full='Texas',
                committee_type='',
                committee_type_full='All',
            ),
        ]

        response = self._results(api.url_for(ScheduleAByStateRecipientTotalsView))

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
        rows = [  # noqa
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=50000,
                count=10,
                cycle=2008,
                state='CA',
                state_full='California',
                committee_type='P',
                committee_type_full='Presidential',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=10000,
                count=5,
                cycle=2010,
                state='ND',
                state_full='North Dakota',
                committee_type='H',
                committee_type_full='House',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=20000,
                count=15,
                cycle=2012,
                state='NC',
                state_full='North Carolina',
                committee_type='S',
                committee_type_full='Senate',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=90000,
                count=4,
                cycle=2014,
                state='NY',
                state_full='New York',
                committee_type='U',
                committee_type_full='single candidate independent expenditure',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=150000,
                count=15,
                cycle=2016,
                state='TX',
                state_full='Texas',
                committee_type='',
                committee_type_full='All',
            ),
        ]

        response = self._results(
            api.url_for(ScheduleAByStateRecipientTotalsView, sort='-cycle')
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
        rows = [  # noqa
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=50000,
                count=10,
                cycle=2008,
                state='CA',
                state_full='California',
                committee_type='P',
                committee_type_full='Presidential',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=10000,
                count=5,
                cycle=2010,
                state='ND',
                state_full='North Dakota',
                committee_type='H',
                committee_type_full='House',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=20000,
                count=15,
                cycle=2012,
                state='NC',
                state_full='North Carolina',
                committee_type='S',
                committee_type_full='Senate',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=90000,
                count=4,
                cycle=2014,
                state='NY',
                state_full='New York',
                committee_type='U',
                committee_type_full='single candidate independent expenditure',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=150000,
                count=15,
                cycle=2016,
                state='TX',
                state_full='Texas',
                committee_type='',
                committee_type_full='All',
            ),
        ]

        response = self._results(
            api.url_for(
                ScheduleAByStateRecipientTotalsView, committee_type=['P', 'H', 'S', ]
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
        rows = [  # noqa
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=50000,
                count=10,
                cycle=2008,
                state='CA',
                state_full='California',
                committee_type='P',
                committee_type_full='Presidential',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=10000,
                count=5,
                cycle=2010,
                state='ND',
                state_full='North Dakota',
                committee_type='H',
                committee_type_full='House',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=20000,
                count=15,
                cycle=2012,
                state='NC',
                state_full='North Carolina',
                committee_type='S',
                committee_type_full='Senate',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=90000,
                count=4,
                cycle=2014,
                state='NY',
                state_full='New York',
                committee_type='U',
                committee_type_full='single candidate independent expenditure',
            ),
            factories.ScheduleAByStateRecipientTotalsFactory(
                total=150000,
                count=15,
                cycle=2016,
                state='TX',
                state_full='Texas',
                committee_type='',
                committee_type_full='All',
            ),
        ]

        response = self._results(
            api.url_for(ScheduleAByStateRecipientTotalsView, state='NY')
        )

        self.assertEqual(len(response), 1)
        self.assertEqual(response[0]['total'], 90000)
        self.assertEqual(response[0]['cycle'], 2014)
        self.assertEqual(response[0]['state'], 'NY')
        self.assertEqual(response[0]['committee_type'], 'U')
