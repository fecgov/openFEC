from .base import db
from sqlalchemy.dialects.postgresql import TSVECTOR
from webservices import docs


class PresidentialByCandidate(db.Model):

    __table_args__ = {'schema': 'public'}
    __tablename__ = 'ofec_presidential_by_candidate_vw'

    idx = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String(0), doc=docs.CANDIDATE_ID)
    candidate_last_name = db.Column(db.String, doc='Candidate last name')
    candidate_party_affiliation = db.Column(db.String, doc=docs.PARTY)
    net_receipts = db.Column(db.Numeric(30, 2), doc='Net receipts: receipts minus refunds')
    rounded_net_receipts = db.Column(db.Numeric(30, 2), doc='Net receipts, in millions')
    contributor_state = db.Column(db.String(2), doc=docs.CONTRIBUTOR_STATE)
    election_year = db.Column(db.Integer, doc=docs.ELECTION_YEAR)


class PresidentialSummary(db.Model):

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
    __tablename__ = 'ofec_presidential_by_state_vw_jl'

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
