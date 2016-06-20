from .base import db
from sqlalchemy.dialects.postgresql import TSVECTOR

from webservices import docs


class RadAnalyst(db.Model):
    __tablename__ = 'rad_cmte_analyst_search_vw'

    idx =db.Column(db.Integer, primary_key=True)
    committee_id = db.Column(db.String, primary_key=True, index=True, doc=docs.COMMITTEE_ID)
    committee_name = db.Column(db.String(100), index=True, doc=docs.COMMITTEE_NAME)
    anlyst_id = db.Column(db.Numeric(38, 0), index=True, doc='ID of RAD analyst.')
    firstname = db.Column(db.String(255), index=True, doc='Fist name of RAD analyst')
    lastname = db.Column(db.String(100), index=True, doc='Last name of RAD analyst')
    telephone_ext = db.Column(db.Numeric(4, 0), index=True, doc='Telephone extension of RAD analyst')
    rad_branch = db.Column(db.String(100), index=True, doc='Branch of RAD analyst')
    name = db.Column(TSVECTOR)
