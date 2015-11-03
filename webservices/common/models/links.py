from .base import db


class CandidateCommitteeLink(db.Model):
    __tablename__ = 'ofec_cand_cmte_linkage_mv'

    linkage_id = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column('cmte_id', db.String, db.ForeignKey('ofec_committee_detail_mv.committee_id'))
    candidate_id = db.Column('cand_id', db.String, db.ForeignKey('ofec_candidate_detail_mv.candidate_id'))
    cand_election_year = db.Column('cand_election_yr', db.Integer)
    fec_election_year = db.Column('fec_election_yr', db.Integer)
    committee_designation = db.Column('cmte_dsgn', db.String)
    committee_type = db.Column('cmte_tp', db.String)
