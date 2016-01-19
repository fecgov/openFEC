from .base import db, BaseModel

from webservices import docs


class CommitteeTotals(BaseModel):
    __abstract__ = True

    committee_id = db.Column(db.String, doc=docs.COMMITTEE_ID)
    cycle = db.Column(db.Integer, primary_key=True, index=True, doc=docs.CYCLE)
    offsets_to_operating_expenditures = db.Column(db.Integer, doc=docs.make_generic_def('offsets_to_operating_expenditures'))
    political_party_committee_contributions = db.Column(db.Integer, doc=docs.make_generic_def('political_party_committee_contributions'))
    other_disbursements = db.Column(db.Integer, doc=docs.make_generic_def('other_disbursements'))
    other_political_committee_contributions = db.Column(db.Integer, doc=docs.make_generic_def('other_political_committee_contributions'))
    individual_itemized_contributions = db.Column(db.Integer, doc=docs.make_generic_def('individual_itemized_contributions'))
    individual_unitemized_contributions = db.Column(db.Integer, doc=docs.make_generic_def('individual_unitemized_contributions'))
    operating_expenditures = db.Column(db.Integer, doc=docs.make_generic_def('operating_expenditures'))
    disbursements = db.Column(db.Integer, doc=docs.DISBURSEMENTS)
    contributions = db.Column(db.Integer, doc=docs.CONTRIBUTIONS)
    contribution_refunds = db.Column(db.Integer, doc=docs.make_generic_def('contribution_refunds'))
    individual_contributions = db.Column(db.Integer, doc=docs.make_generic_def('individual_contributions'))
    refunded_individual_contributions = db.Column(db.Integer, doc=docs.make_generic_def('refunded_individual_contributions'))
    refunded_other_political_committee_contributions = db.Column(db.Integer, doc=docs.make_generic_def('refunded_other_political_committee_contributions'))
    refunded_political_party_committee_contributions = db.Column(db.Integer, doc=docs.make_generic_def('refunded_political_party_committee_contributions'))
    receipts = db.Column(db.Integer, doc=docs.RECEIPTS)
    coverage_start_date = db.Column(db.DateTime(), index=True, doc=docs.COVERAGE_START_DATE)
    coverage_end_date = db.Column(db.DateTime(), index=True, doc=docs.COVERAGE_START_DATE)

    last_report_year = db.Column(db.Integer)
    last_report_type_full = db.Column(db.String)
    last_beginning_image_number = db.Column(db.BigInteger)
    last_cash_on_hand_end_period = db.Column(db.Numeric(30, 2))
    last_debts_owed_by_committee = db.Column(db.Numeric(30, 2))


class CommitteeTotalsPacParty(CommitteeTotals):
    __tablename__ = 'ofec_totals_pacs_parties_mv'

    all_loans_received = db.Column(db.Integer, doc=docs.make_generic_def('all_loans_received'))
    allocated_federal_election_levin_share = db.Column(db.Integer, doc=docs.make_generic_def('allocated_federal_election_levin_share'))
    coordinated_expenditures_by_party_committee = db.Column(db.Integer, doc=docs.make_generic_def('coordinated_expenditures_by_party_committee'))
    fed_candidate_committee_contributions = db.Column(db.Integer, doc=docs.make_generic_def('fed_candidate_committee_contributions'))
    fed_candidate_contribution_refunds = db.Column(db.Integer, doc=docs.make_generic_def('fed_candidate_contribution_refunds'))
    fed_disbursements = db.Column(db.Integer, doc=docs.make_generic_def('fed_disbursements'))
    fed_election_activity = db.Column(db.Integer, doc=docs.make_generic_def('fed_election_activity'))
    fed_operating_expenditures = db.Column(db.Integer, doc=docs.make_generic_def('fed_operating_expenditures'))
    fed_receipts = db.Column(db.Integer, doc=docs.make_generic_def('fed_receipts'))
    independent_expenditures = db.Column(db.Integer, doc=docs.make_generic_def('independent_expenditures'))
    loan_repayments_made = db.Column(db.Integer, doc=docs.make_generic_def('loan_repayments_made'))
    loan_repayments_received = db.Column(db.Integer, doc=docs.make_generic_def('loan_repayments_received'))
    loans_made = db.Column(db.Integer, doc=docs.make_generic_def('loans_made'))
    net_contributions = db.Column(db.Integer, doc=docs.make_generic_def('net_contributions'))
    net_operating_expenditures = db.Column(db.Integer, doc=docs.make_generic_def('net_operating_expenditures'))
    non_allocated_fed_election_activity = db.Column(db.Integer, doc=docs.make_generic_def('non_allocated_fed_election_activity'))
    nonfed_transfers = db.Column(db.Integer, doc=docs.make_generic_def('nonfed_transfers'))
    other_fed_operating_expenditures = db.Column(db.Integer, doc=docs.make_generic_def('other_fed_operating_expenditures'))
    other_fed_receipts = db.Column(db.Integer, doc=docs.make_generic_def('other_fed_receipts'))
    shared_fed_activity = db.Column(db.Integer, doc=docs.make_generic_def('shared_fed_activity'))
    shared_fed_activity_nonfed = db.Column(db.Integer, doc=docs.make_generic_def('shared_fed_activity_nonfed'))
    shared_fed_operating_expenditures = db.Column(db.Integer, doc=docs.make_generic_def('shared_fed_operating_expenditures'))
    shared_nonfed_operating_expenditures = db.Column(db.Integer, doc=docs.make_generic_def('shared_nonfed_operating_expenditures'))
    transfers_from_affiliated_party = db.Column(db.Integer, doc=docs.make_generic_def('transfers_from_affiliated_party'))
    transfers_from_nonfed_account = db.Column(db.Integer, doc=docs.make_generic_def('transfers_from_nonfed_account'))
    transfers_from_nonfed_levin = db.Column(db.Integer, doc=docs.make_generic_def('transfers_from_nonfed_levin'))
    transfers_to_affiliated_committee = db.Column(db.Integer, doc=docs.make_generic_def('transfers_to_affiliated_committee'))


class CommitteeTotalsPresidential(CommitteeTotals):
    __tablename__ = 'ofec_totals_presidential_mv'

    candidate_contribution = db.Column(db.Integer, doc=docs.make_generic_def('candidate_contribution'))
    exempt_legal_accounting_disbursement = db.Column(db.Integer, doc=docs.make_generic_def('exempt_legal_accounting_disbursement'))
    federal_funds = db.Column(db.Integer, doc=docs.make_generic_def('federal_funds'))
    fundraising_disbursements = db.Column(db.Integer, doc=docs.make_generic_def('fundraising_disbursements'))
    loan_repayments_made = db.Column(db.Integer, doc=docs.make_generic_def('loan_repayments_made'))
    loans_received = db.Column(db.Integer, doc=docs.make_generic_def('loans_received'))
    loans_received_from_candidate = db.Column(db.Integer, doc=docs.make_generic_def('loans_received_from_candidate'))
    offsets_to_fundraising_expenditures = db.Column(db.Integer, doc=docs.make_generic_def('offsets_to_fundraising_expenditures'))
    offsets_to_legal_accounting = db.Column(db.Integer, doc=docs.make_generic_def('offsets_to_legal_accounting'))
    other_loans_received = db.Column(db.Integer, doc=docs.make_generic_def('other_loans_received'))
    other_receipts = db.Column(db.Integer, doc=docs.make_generic_def('other_receipts'))
    repayments_loans_made_by_candidate = db.Column(db.Integer, doc=docs.make_generic_def('repayments_loans_made_by_candidate'))
    repayments_other_loans = db.Column(db.Integer, doc=docs.make_generic_def('repayments_other_loans'))
    total_offsets_to_operating_expenditures = db.Column(db.Integer, doc=docs.make_generic_def('total_offsets_to_operating_expenditures'))
    transfers_from_affiliated_committee = db.Column(db.Integer, doc=docs.make_generic_def('transfers_from_affiliated_committee'))
    transfers_to_other_authorized_committee = db.Column(db.Integer, doc=docs.make_generic_def('transfers_to_other_authorized_committee'))


class CommitteeTotalsHouseSenate(CommitteeTotals):
    __tablename__ = 'ofec_totals_house_senate_mv'

    all_other_loans = db.Column(db.Integer, doc=docs.make_generic_def('all_other_loans'))
    candidate_contribution = db.Column(db.Integer, doc=docs.make_generic_def('candidate_contribution'))
    loan_repayments = db.Column(db.Integer, doc=docs.make_generic_def('loan_repayments'))
    loan_repayments_candidate_loans = db.Column(db.Integer, doc=docs.make_generic_def('loan_repayments_candidate_loans'))
    loan_repayments_other_loans = db.Column(db.Integer, doc=docs.make_generic_def('loan_repayments_other_loans'))
    loans = db.Column(db.Integer, doc=docs.make_generic_def('loans'))
    loans_made_by_candidate = db.Column(db.Integer, doc=docs.make_generic_def('loans_made_by_candidate'))
    net_contributions = db.Column(db.Integer, doc=docs.make_generic_def('net_contributions'))
    net_operating_expenditures = db.Column(db.Integer, doc=docs.make_generic_def('net_operating_expenditures'))
    other_receipts = db.Column(db.Integer, doc=docs.make_generic_def('other_receipts'))
    transfers_from_other_authorized_committee = db.Column(db.Integer, doc=docs.make_generic_def('transfers_from_other_authorized_committee'))
    transfers_to_other_authorized_committee = db.Column(db.Integer, doc=docs.make_generic_def('transfers_to_other_authorized_committee'))


class CommitteeTotalsIEOnly(BaseModel):
    __tablename__ = 'ofec_totals_ie_only_mv'

    committee_id = db.Column(db.String, index=True, doc=docs.COMMITTEE_ID)
    cycle = db.Column(db.Integer, index=True, doc=docs.CYCLE)
    coverage_start_date = db.Column(db.DateTime, doc=docs.COVERAGE_START_DATE)
    coverage_end_date = db.Column(db.DateTime, doc=docs.COVERAGE_END_DATE)
    total_independent_contributions = db.Column(db.Integer, doc=docs.make_generic_def('total_independent_contributions'))
    total_independent_expenditures = db.Column(db.Integer, doc=docs.make_generic_def('total_independent_expenditures'))
