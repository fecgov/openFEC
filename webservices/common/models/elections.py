from .base import db


class ElectionResult(db.Model):
    __tablename__ = 'ofec_election_result_mv'

    election_yr = db.Column(db.Integer, primary_key=True)
    cand_office = db.Column(db.String, primary_key=True)
    cand_office_st = db.Column(db.String, primary_key=True)
    cand_office_district = db.Column(db.String, primary_key=True)

    cand_id = db.Column(db.String)
    cand_name = db.Column(db.String)
