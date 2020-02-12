from .base import db
from sqlalchemy.dialects.postgresql import TSVECTOR
from webservices import docs


class PresidentialByCandidate(db.Model):

    __table_args__ = {'schema': 'public'}
    __tablename__ = 'ofec_presidential_by_candidate_vw'

    idx = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String, doc=docs.CANDIDATE_ID)
    candidate_last_name = db.Column(db.String, doc='Candidate last name')
    candidate_party_affiliation = db.Column(db.String, doc=docs.PARTY)
    net_receipts = db.Column(db.Numeric(30, 2), doc='Net receipts: receipts minus refunds')
    rounded_net_receipts = db.Column(db.Numeric(30, 2), doc='Net receipts, in millions')
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
    candidate_id = db.Column(db.String, doc=docs.CANDIDATE_ID)
    candidate_name = db.Column(db.String, doc=docs.CANDIDATE_NAME)
    candidate_last_name = db.Column(db.String, doc='Candidate last name')
    election_year = db.Column(db.Integer, doc=docs.ELECTION_YEAR)

    # Amounts
    net_receipts = db.Column(db.Numeric(30, 2), doc='Net receipts: receipts minus refunds')
    rounded_net_receipts = db.Column(db.Numeric(30, 2), doc='Net receipts, in millions')
    individual_contributions_less_refunds = db.Column(db.Numeric(30, 2), doc='TODO')
    pac_contributions_less_refunds = db.Column(db.Numeric(30, 2), doc='TODO')
    party_contributions_less_refunds = db.Column(db.Numeric(30, 2), doc='TODO')
    candidate_contributions_less_repayments = db.Column(db.Numeric(30, 2), doc='TODO')
    disbursements_less_offsets = db.Column(db.Numeric(30, 2), doc='TODO')
    operating_expenditures = db.Column(db.Numeric(30, 2), doc='TODO')
    transfers_to_other_authorized_committees = db.Column(db.Numeric(30, 2), doc='TODO')
    fundraising_disbursements = db.Column(db.Numeric(30, 2), doc='TODO')
    exempt_legal_accounting_disbursement = db.Column(db.Numeric(30, 2), doc='TODO')
    total_loan_repayments_made = db.Column(db.Numeric(30, 2), doc='TODO')
    repayments_loans_made_by_candidate = db.Column(db.Numeric(30, 2), doc='TODO')
    repayments_other_loans = db.Column(db.Numeric(30, 2), doc='TODO')
    other_disbursements = db.Column(db.Numeric(30, 2), doc='TODO')
    offsets_to_operating_expenditures = db.Column(db.Numeric(30, 2), doc='TODO')
    total_contribution_refunds = db.Column(db.Numeric(30, 2), doc='TODO')
    debts_owed_by_committee = db.Column(db.Numeric(30, 2), doc='TODO')
    federal_funds = db.Column(db.Numeric(30, 2), doc='TODO')
    cash_on_hand_end = db.Column(db.Numeric(30, 2), doc='TODO')


class PresidentialBySize(db.Model):

    __table_args__ = {'schema': 'public'}
    __tablename__ = 'ofec_presidential_by_size_vw'

    idx = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String(0), doc=docs.CANDIDATE_ID)
    contribution_receipt_amount = db.Column(db.Numeric(30, 2), doc=docs.CONTRIBUTION_RECEIPTS)
    election_year = db.Column(db.Integer, doc=docs.ELECTION_YEAR)
    size_range_id = db.Column(db.Integer, doc=docs.SIZE_RANGE_ID)
    size = db.Column(db.Integer, doc=docs.SIZE)


class PresidentialByState(db.Model):

    __table_args__ = {'schema': 'public'}
    __tablename__ = 'ofec_presidential_by_state_vw'

    idx = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String(0), doc=docs.CANDIDATE_ID)
    contribution_state = db.Column(db.String(2), doc=docs.CONTRIBUTOR_STATE)
    contribution_receipt_amount = db.Column(db.Numeric(30, 2), doc=docs.CONTRIBUTION_RECEIPTS)
    election_year = db.Column(db.Integer, doc=docs.ELECTION_YEAR)


class PresidentialCoverage(db.Model):

    __table_args__ = {'schema': 'public'}
    __tablename__ = 'ofec_presidential_coverage_date_vw'

    idx = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String, doc=docs.CANDIDATE_ID)
    coverage_end_date = db.Column(db.DateTime, doc=docs.COVERAGE_END_DATE)
    election_year = db.Column(db.Integer, doc=docs.ELECTION_YEAR)
