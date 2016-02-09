from .base import db, BaseModel


class CommitteeTotals(BaseModel):
    __abstract__ = True

    committee_id = db.Column(db.String)
    cycle = db.Column(db.Integer, primary_key=True, index=True)
    offsets_to_operating_expenditures = db.Column(db.Numeric(30, 2))
    political_party_committee_contributions = db.Column(db.Numeric(30, 2))
    other_disbursements = db.Column(db.Numeric(30, 2))
    other_political_committee_contributions = db.Column(db.Numeric(30, 2))
    individual_itemized_contributions = db.Column(db.Numeric(30, 2))
    individual_unitemized_contributions = db.Column(db.Numeric(30, 2))
    operating_expenditures = db.Column(db.Numeric(30, 2))
    disbursements = db.Column(db.Numeric(30, 2))
    contributions = db.Column(db.Numeric(30, 2))
    contribution_refunds = db.Column(db.Numeric(30, 2))
    individual_contributions = db.Column(db.Numeric(30, 2))
    refunded_individual_contributions = db.Column(db.Numeric(30, 2))
    refunded_other_political_committee_contributions = db.Column(db.Numeric(30, 2))
    refunded_political_party_committee_contributions = db.Column(db.Numeric(30, 2))
    receipts = db.Column(db.Numeric(30, 2))
    coverage_start_date = db.Column(db.DateTime(), index=True)
    coverage_end_date = db.Column(db.DateTime(), index=True)

    last_report_year = db.Column(db.Integer)
    last_report_type_full = db.Column(db.String)
    last_beginning_image_number = db.Column(db.BigInteger)
    last_cash_on_hand_end_period = db.Column(db.Numeric(30, 2))
    last_debts_owed_by_committee = db.Column(db.Numeric(30, 2))


class CommitteeTotalsPacParty(CommitteeTotals):
    __tablename__ = 'ofec_totals_pacs_parties_mv'

    all_loans_received = db.Column(db.Numeric(30, 2))
    allocated_federal_election_levin_share = db.Column(db.Numeric(30, 2))
    coordinated_expenditures_by_party_committee = db.Column(db.Numeric(30, 2))
    fed_candidate_committee_contributions = db.Column(db.Numeric(30, 2))
    fed_candidate_contribution_refunds = db.Column(db.Numeric(30, 2))
    fed_disbursements = db.Column(db.Numeric(30, 2))
    fed_election_activity = db.Column(db.Numeric(30, 2))
    fed_operating_expenditures = db.Column(db.Numeric(30, 2))
    fed_receipts = db.Column(db.Numeric(30, 2))
    independent_expenditures = db.Column(db.Numeric(30, 2))
    loan_repayments_made = db.Column(db.Numeric(30, 2))
    loan_repayments_received = db.Column(db.Numeric(30, 2))
    loans_made = db.Column(db.Numeric(30, 2))
    non_allocated_fed_election_activity = db.Column(db.Numeric(30, 2))
    nonfed_transfers = db.Column(db.Numeric(30, 2))
    other_fed_operating_expenditures = db.Column(db.Numeric(30, 2))
    other_fed_receipts = db.Column(db.Numeric(30, 2))
    shared_fed_activity = db.Column(db.Numeric(30, 2))
    shared_fed_activity_nonfed = db.Column(db.Numeric(30, 2))
    shared_fed_operating_expenditures = db.Column(db.Numeric(30, 2))
    shared_nonfed_operating_expenditures = db.Column(db.Numeric(30, 2))
    transfers_from_affiliated_party = db.Column(db.Numeric(30, 2))
    transfers_from_nonfed_account = db.Column(db.Numeric(30, 2))
    transfers_from_nonfed_levin = db.Column(db.Numeric(30, 2))
    transfers_to_affiliated_committee = db.Column(db.Numeric(30, 2))
    net_contributions = db.Column(db.Numeric(30, 2))
    net_operating_expenditures = db.Column(db.Numeric(30, 2))


class CommitteeTotalsPresidential(CommitteeTotals):
    __tablename__ = 'ofec_totals_presidential_mv'

    candidate_contribution = db.Column(db.Numeric(30, 2))
    exempt_legal_accounting_disbursement = db.Column(db.Numeric(30, 2))
    federal_funds = db.Column(db.Numeric(30, 2))
    fundraising_disbursements = db.Column(db.Numeric(30, 2))
    loan_repayments_made = db.Column(db.Numeric(30, 2))
    loans_received = db.Column(db.Numeric(30, 2))
    loans_received_from_candidate = db.Column(db.Numeric(30, 2))
    offsets_to_fundraising_expenditures = db.Column(db.Numeric(30, 2))
    offsets_to_legal_accounting = db.Column(db.Numeric(30, 2))
    total_offsets_to_operating_expenditures = db.Column(db.Numeric(30, 2))
    other_loans_received = db.Column(db.Numeric(30, 2))
    other_receipts = db.Column(db.Numeric(30, 2))
    repayments_loans_made_by_candidate = db.Column(db.Numeric(30, 2))
    repayments_other_loans = db.Column(db.Numeric(30, 2))
    transfers_from_affiliated_committee = db.Column(db.Numeric(30, 2))
    transfers_to_other_authorized_committee = db.Column(db.Numeric(30, 2))


class CommitteeTotalsHouseSenate(CommitteeTotals):
    __tablename__ = 'ofec_totals_house_senate_mv'

    all_other_loans = db.Column(db.Numeric(30, 2))
    candidate_contribution = db.Column(db.Numeric(30, 2))
    loan_repayments = db.Column(db.Numeric(30, 2))
    loan_repayments_candidate_loans = db.Column(db.Numeric(30, 2))
    loan_repayments_other_loans = db.Column(db.Numeric(30, 2))
    loans = db.Column(db.Numeric(30, 2))
    loans_made_by_candidate = db.Column(db.Numeric(30, 2))
    other_receipts = db.Column(db.Numeric(30, 2))
    transfers_from_other_authorized_committee = db.Column(db.Numeric(30, 2))
    transfers_to_other_authorized_committee = db.Column(db.Numeric(30, 2))
    net_contributions = db.Column(db.Numeric(30, 2))
    net_operating_expenditures = db.Column(db.Numeric(30, 2))


class CommitteeTotalsIEOnly(BaseModel):
    __tablename__ = 'ofec_totals_ie_only_mv'

    committee_id = db.Column(db.String, index=True)
    cycle = db.Column(db.Integer, index=True)
    coverage_start_date = db.Column(db.DateTime)
    coverage_end_date = db.Column(db.DateTime)
    total_independent_contributions = db.Column(db.Numeric(30, 2))
    total_independent_expenditures = db.Column(db.Numeric(30, 2))
