import datetime

from marshmallow.utils import isoformat

from .common import ApiBaseTest
from tests import factories

from webservices.rest import db
from webservices.rest import api
from webservices.resources.totals import TotalsView


class TestTotals(ApiBaseTest):

    def _check_committee_ids(self, results, positives=None, negatives=None):
        ids = [each['committee_id'] for each in results]
        for positive in (positives or []):
            self.assertIn(positive.committee_id, ids)
        for negative in (negatives or []):
            self.assertNotIn(negative.committee_id, ids)

    def test_Presidential_totals(self):
        committee_id = 'C8675309'
        history = factories.CommitteeHistoryFactory(
            committee_id=committee_id,
            committee_type='P',
        )
        committee_total = factories.TotalsPresidentialFactory(
            committee_id=committee_id,
            cycle =2016,
            # fields unique to presidential
            candidate_contribution = 1,
            exempt_legal_accounting_disbursement = 2,
            federal_funds = 3,
            fundraising_disbursements = 4,
            loan_repayments_made = 16,
            loans_received = 5,
            loans_received_from_candidate = 6,
            offsets_to_fundraising_expenditures = 7,
            offsets_to_legal_accounting = 8,
            total_offsets_to_operating_expenditures = 9,
            other_loans_received = 10,
            other_receipts = 11,
            repayments_loans_made_by_candidate = 12,
            repayments_other_loans = 13,
            transfers_from_affiliated_committee = 14,
            transfers_to_other_authorized_committee = 15,
        )
        results = self._results(api.url_for(TotalsView, committee_id=committee_id))
        self._check_committee_ids(results, [committee_total])

    def test_House_Senate_totals(self):
        committee_id = 'C8675310'
        history = factories.CommitteeHistoryFactory(
            committee_id=committee_id,
            committee_type='S',
        )
        committee_total = factories.TotalsHouseSenateFactory(
            committee_id=committee_id,
            cycle =2016,
            # fields unique to House and Senate
            all_other_loans = 1,
            candidate_contribution = 2,
            loan_repayments = 3,
            loan_repayments_candidate_loans = 4,
            loan_repayments_other_loans = 5,
            loans = 6,
            loans_made_by_candidate = 7,
            other_receipts = 8,
            transfers_from_other_authorized_committee = 9,
            transfers_to_other_authorized_committee = 10,
        )
        results = self._results(api.url_for(TotalsView, committee_id=committee_id))
        self._check_committee_ids(results, [committee_total])

    def test_Pac_Party_totals(self):
        committee_id = 'C8675311'
        history = factories.CommitteeHistoryFactory(
            committee_id=committee_id,
            committee_type='Q',
        )
        committee_total = factories.TotalsPacPartyFactory(
            committee_id=committee_id,
            cycle =2016,
            # fields unique to PACs and Parties
            all_loans_received = 1,
            allocated_federal_election_levin_share = 2,
            coordinated_expenditures_by_party_committee = 3,
            fed_candidate_committee_contributions = 4,
            fed_candidate_contribution_refunds = 5,
            fed_disbursements = 6,
            fed_election_activity = 7,
            fed_operating_expenditures = 8,
            fed_receipts = 9,
            independent_expenditures = 10,
            loan_repayments_made = 11,
            loan_repayments_received = 12,
            loans_made = 13,
            non_allocated_fed_election_activity = 14,
            nonfed_transfers = 15,
            other_fed_operating_expenditures = 16,
            other_fed_receipts = 17,
            shared_fed_activity = 18,
            shared_fed_activity_nonfed = 19,
            shared_fed_operating_expenditures = 20,
            shared_nonfed_operating_expenditures = 21,
            transfers_from_affiliated_party = 22,
            transfers_from_nonfed_account = 23,
            transfers_from_nonfed_levin = 24,
            transfers_to_affiliated_committee = 25,
        )
        results = self._results(api.url_for(TotalsView, committee_id=committee_id))
        self._check_committee_ids(results, [committee_total])




