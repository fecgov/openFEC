from flask.ext.sqlalchemy import SQLAlchemy
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.ext.associationproxy import association_proxy

db = SQLAlchemy()


class Candidate(db.Model):
    candidate_key = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String(10))
    candidate_status = db.Column(db.String(1))
    candidate_status_full = db.Column(db.String(11))
    district = db.Column(db.String(2))
    active_through = db.Column(db.Integer)
    election_years = db.Column(ARRAY(db.Integer))
    incumbent_challenge = db.Column(db.String(1))
    incumbent_challenge_full = db.Column(db.String(10))
    office = db.Column(db.String(1))
    office_full = db.Column(db.String(9))
    party = db.Column(db.String(3))
    party_full = db.Column(db.String(255))
    state = db.Column(db.String(2))
    name = db.Column(db.String(100))
    candidate_committees = db.relationship('CandidateCommittee', backref='candidate')
    committees = association_proxy('committee_links', 'committee')

    __tablename__ = 'ofec_candidates_vw'


class Committee(db.Model):
    committee_key = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column(db.String(9))
    designation = db.Column(db.String(1))
    designation_full = db.Column(db.String(25))
    treasurer_name = db.Column(db.String(100))
    organization_type = db.Column(db.String(1))
    organization_type_full = db.Column(db.String(100))
    state = db.Column(db.String(2))
    committee_type = db.Column(db.String(1))
    committee_type_full = db.Column(db.String(50))
    expire_date = db.Column(db.DateTime())
    party = db.Column(db.String(3))
    party_full = db.Column(db.String(50))
    original_registration_date = db.Column(db.DateTime())
    name = db.Column(db.String(100))

    __tablename__ = 'ofec_committees_vw'


class CandidateCommittee(db.Model):
    linkages_sk = db.Column(db.Integer, primary_key=True)
    committee_key = db.Column('cmte_sk', db.Integer, db.ForeignKey('ofec_committees_vw.committee_key'))
    candidate_key = db.Column('cand_sk', db.Integer, db.ForeignKey('ofec_candidates_vw.candidate_key'))
    committee_id = db.Column('cmte_id', db.String(10))
    candidate_id = db.Column('cand_id', db.String(10))
    election_year = db.Column('cand_election_yr', db.Integer)
    link_date = db.Column('link_date', db.DateTime())
    expire_date = db.Column('expire_date', db.DateTime())
    committee = db.relationship(Committee, lazy='joined', backref='committee_candidates')

    __tablename__ = 'dimlinkages'
    __table_args__ = (db.ForeignKeyConstraint(['cmte_sk'], ['ofec_committees_vw.committee_key']), db.ForeignKeyConstraint(['cand_sk'], ['ofec_candidates_vw.candidate_key']))


