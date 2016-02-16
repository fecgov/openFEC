from .base import db

from webservices import docs


class ElectionResult(db.Model):
    __tablename__ = 'ofec_election_result_mv'

    election_yr = db.Column(db.Integer, primary_key=True, doc=docs.ELECTION_YEAR)
    cand_office = db.Column(db.String, primary_key=True, doc=docs.OFFICE)
    cand_office_st = db.Column(db.String, primary_key=True, doc=docs.STATE_GENERIC)
    cand_office_district = db.Column(db.String, primary_key=True, doc=docs.DISTRICT)

    cand_id = db.Column(db.String, doc=docs.CANDIDATE_ID)
    cand_name = db.Column(db.String, doc=docs.CANDIDATE_NAME)
