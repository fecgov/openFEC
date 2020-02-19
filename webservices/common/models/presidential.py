from .base import db
from webservices import docs


class PresidentialByCandidate(db.Model):

    __table_args__ = {'schema': 'public'}
    __tablename__ = 'ofec_presidential_by_candidate_vw'

    idx = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String, doc=docs.CANDIDATE_ID_PRESIDENTIAL)
    candidate_last_name = db.Column(db.String, doc=docs.CANDIDATE_LAST_NAME)
    candidate_party_affiliation = db.Column(db.String, doc=docs.PARTY)
    net_receipts = db.Column(db.Numeric(30, 2), doc=docs.NET_CONTRIBUTIONS)
    rounded_net_receipts = db.Column(db.Numeric(30, 2), doc=docs.ROUND_CONTRIBUTIONS)
    contributor_state = db.Column(db.String(2), doc=docs.CONTRIBUTOR_STATE)
    election_year = db.Column(db.Integer, doc=docs.ELECTION_YEAR)


class PresidentialSummary(db.Model):

    __table_args__ = {'schema': 'public'}
    __tablename__ = 'ofec_presidential_financial_summary_vw'

    idx = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column(db.String, doc=docs.CANDIDATE_ID)
    committee_name = db.Column(db.String, doc=docs.COMMITTEE_NAME)
    committee_type = db.Column(db.String, doc=docs.COMMITTEE_TYPE)
    committee_designation = db.Column(db.String, doc=docs.DESIGNATION)
    candidate_party_affiliation = db.Column(db.String, doc=docs.PARTY)
    candidate_id = db.Column(db.String, doc=docs.CANDIDATE_ID_PRESIDENTIAL)
    candidate_name = db.Column(db.String, doc=docs.CANDIDATE_NAME)
    candidate_last_name = db.Column(db.String, doc=docs.CANDIDATE_LAST_NAME)
    election_year = db.Column(db.Integer, doc=docs.ELECTION_YEAR)

    # Amounts
    net_receipts = db.Column(db.Numeric(30, 2), doc=docs.CONTRIBUTION_RECEIPTS)
    rounded_net_receipts = db.Column(db.Numeric(30, 2), doc=docs.ROUND_CONTRIBUTIONS)
    individual_contributions_less_refunds = db.Column(db.Numeric(30, 2), doc=docs.INDIVIDUAL_CONTRIBUTIONS_LESS_REFUNDS)
    pac_contributions_less_refunds = db.Column(db.Numeric(30, 2), doc=docs.PAC_CONTRIBUTIONS_LESS_REFUNDS)
    party_contributions_less_refunds = db.Column(db.Numeric(30, 2), doc=docs.PARTY_CONTRIBUTIONS_LESS_REFUNDS)
    candidate_contributions_less_repayments = db.Column(
        db.Numeric(30, 2), doc=docs.CANDIDATE_CONTRIBUTION_LESS_REPAYMENTS)

    disbursements_less_offsets = db.Column(db.Numeric(30, 2), doc=docs.DISBURSEMENTS_LESS_OFFSETS)
    operating_expenditures = db.Column(db.Numeric(30, 2), doc=docs.OPERATING_EXPENDITURES)
    transfers_to_other_authorized_committees = db.Column(
        db.Numeric(30, 2), doc=docs.TRANSACTION_TO_OTHER_AUTHORIZED_COMMITTEES)

    transfers_from_affiliated_committees = db.Column(db.Numeric(30, 2), doc=docs.TRANSACTION_FROM_AFFILIATED_COMMITTEES)
    fundraising_disbursements = db.Column(db.Numeric(30, 2), doc=docs.FUNDRAISING_DISBURSEMENTS)
    exempt_legal_accounting_disbursement = db.Column(db.Numeric(30, 2), doc=docs.EXEMPT_LEGAL_ACCOUNTING_DISBURSEMENT)
    total_loan_repayments_made = db.Column(db.Numeric(30, 2), doc=docs.TOTAL_LOAN_REPAYMENTS_MADE)
    repayments_loans_made_by_candidate = db.Column(db.Numeric(30, 2), doc=docs.REPAYMENTS_OTHER_LOANS_MADE_BY_CANDIDATE)
    repayments_other_loans = db.Column(db.Numeric(30, 2), doc=docs.REPAYMENTS_OTHER_LOANS)
    other_disbursements = db.Column(db.Numeric(30, 2), doc=docs.OTHER_DISBURSEMENTS)
    offsets_to_operating_expenditures = db.Column(db.Numeric(30, 2), doc=docs.OFFSETS_TO_OPERATING_EXPENDITURES)
    total_contribution_refunds = db.Column(db.Numeric(30, 2), doc=docs.TOTAL_CONTRIBUTION_REFUNDS)
    debts_owed_by_committee = db.Column(db.Numeric(30, 2), doc=docs.DEBTS_OWED_BY_COMMITTEE)
    federal_funds = db.Column(db.Numeric(30, 2), doc=docs.FEDERAL_FUNDS)
    cash_on_hand_end = db.Column(db.Numeric(30, 2), doc=docs.CASH_ON_HAND_END_PERIOD)


class PresidentialBySize(db.Model):

    __table_args__ = {'schema': 'public'}
    __tablename__ = 'ofec_presidential_by_size_vw'

    idx = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String(0), doc=docs.CANDIDATE_ID_PRESIDENTIAL)
    contribution_receipt_amount = db.Column(db.Numeric(30, 2), doc=docs.CONTRIBUTION_RECEIPTS)
    election_year = db.Column(db.Integer, doc=docs.ELECTION_YEAR)
    size_range_id = db.Column(db.Integer, doc=docs.SIZE_RANGE_ID)
    size = db.Column(db.Integer, doc=docs.SIZE)


class PresidentialByState(db.Model):

    __table_args__ = {'schema': 'public'}
    __tablename__ = 'ofec_presidential_by_state_vw'

    idx = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String(0), doc=docs.CANDIDATE_ID_PRESIDENTIAL)
    contribution_state = db.Column(db.String(2), doc=docs.CONTRIBUTOR_STATE)
    contribution_receipt_amount = db.Column(db.Numeric(30, 2), doc=docs.CONTRIBUTION_RECEIPTS)
    election_year = db.Column(db.Integer, doc=docs.ELECTION_YEAR)


class PresidentialCoverage(db.Model):

    __table_args__ = {'schema': 'public'}
    __tablename__ = 'ofec_presidential_coverage_date_vw'

    idx = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String, doc=docs.CANDIDATE_ID_PRESIDENTIAL)
    coverage_end_date = db.Column(db.DateTime, doc=docs.COVERAGE_END_DATE)
    election_year = db.Column(db.Integer, doc=docs.ELECTION_YEAR)
