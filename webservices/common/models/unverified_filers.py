from .base import db


class UnverifiedFiler(db.Model):
    __tablename__ = 'unverified_filers_vw'

    candidate_committee_id = db.Column('cmte_id', db.String, primary_key=True)
    filer_type = db.Column('filer_tp', db.Integer)
    candidate_committee_type = db.Column('cand_cmte_tp', db.String)
    filed_committee_type_description = db.Column('filed_cmte_tp_desc', db.String)
    committee_name = db.Column('cmte_nm', db.String)
    first_receipt_date = db.Column('first_receipt_dt', db.Date)
