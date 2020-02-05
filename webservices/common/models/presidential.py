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
    candidate_active = db.Column(db.String, doc='Candidate is actively seeking office')
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


class PresidentialBySize(db.Model):

    __table_args__ = {'schema': 'public', 'extend_existing': True}
    __tablename__ = 'ofec_rad_analyst_vw'

    idx = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column(db.String, primary_key=True,  doc=docs.COMMITTEE_ID)
    committee_name = db.Column(db.String(100),  doc=docs.COMMITTEE_NAME)
    analyst_id = db.Column(db.Numeric(38, 0),  doc='ID of RAD analyst.')
    analyst_short_id = db.Column(db.Numeric(4, 0), doc='Short ID of RAD analyst.')
    first_name = db.Column(db.String(255),  doc='Fist name of RAD analyst')
    last_name = db.Column(db.String(100),  doc='Last name of RAD analyst')
    email = db.Column('analyst_email', db.String(100),  doc='Email of RAD analyst')
    title = db.Column('analyst_title', db.String(100),  doc='Title of RAD analyst')
    telephone_ext = db.Column(db.Numeric(4, 0),  doc='Telephone extension of RAD analyst')
    rad_branch = db.Column(db.String(100),  doc='Branch of RAD analyst')
    name_txt = db.Column(TSVECTOR)
    assignment_update_date = db.Column(db.Date, doc="Date of most recent RAD analyst assignment change")


class PresidentialByState(db.Model):

    __table_args__ = {'schema': 'public'}
    __tablename__ = 'ofec_presidential_by_state_vw'

    # TODO: Update docstrings
    idx = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String(0), doc=docs.CANDIDATE_ID)
    contribution_state = db.Column(db.String(2), doc='')
    contribution_receipt_amount = db.Column(db.Numeric(30, 2), doc='')
    election_year = db.Column(db.Integer, doc='')

class PresidentialCoverage(db.Model):

    __table_args__ = {'schema': 'public', 'extend_existing': True}
    __tablename__ = 'ofec_rad_analyst_vw'

    idx = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column(db.String, primary_key=True,  doc=docs.COMMITTEE_ID)
    committee_name = db.Column(db.String(100),  doc=docs.COMMITTEE_NAME)
    analyst_id = db.Column(db.Numeric(38, 0),  doc='ID of RAD analyst.')
    analyst_short_id = db.Column(db.Numeric(4, 0), doc='Short ID of RAD analyst.')
    first_name = db.Column(db.String(255),  doc='Fist name of RAD analyst')
    last_name = db.Column(db.String(100),  doc='Last name of RAD analyst')
    email = db.Column('analyst_email', db.String(100),  doc='Email of RAD analyst')
    title = db.Column('analyst_title', db.String(100),  doc='Title of RAD analyst')
    telephone_ext = db.Column(db.Numeric(4, 0),  doc='Telephone extension of RAD analyst')
    rad_branch = db.Column(db.String(100),  doc='Branch of RAD analyst')
    name_txt = db.Column(TSVECTOR)
    assignment_update_date = db.Column(db.Date, doc="Date of most recent RAD analyst assignment change")
