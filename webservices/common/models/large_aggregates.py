from .base import db

from webservices import docs


class EntityReceiptsTotals(db.Model):
    """two year receipt totals by entity type and two-year election period"""
    __tablename__ = 'entity_receipts_chart'

    idx = db.Column(db.Integer, primary_key=True)
    cycle = db.Column(db.Integer, doc=docs.RECORD_CYCLE)
    type = db.Column(db.String, doc="Candidate, PAC, party or other")
    month = db.Column(db.Integer, doc="Numeric representation of year")
    year = db.Column(db.Integer, doc="Numeric representation of month")
    receipts = db.Column('adjusted_total_receipts', db.Float, doc="Total adjusted receipts for that entity type")


class EntityDisbursementsTotals(db.Model):
    """two year disbursement totals by entity type and two-year election period"""
    __tablename__ = 'entity_disbursements_chart'

    idx = db.Column(db.Integer, primary_key=True)
    cycle = db.Column(db.Integer, doc=docs.RECORD_CYCLE)
    type = db.Column(db.String, doc="Candidate, PAC, party or other")
    month = db.Column(db.Integer, doc="Numeric representation of year")
    year = db.Column(db.Integer, doc="Numeric representation of month")
    disbursements = db.Column('adjusted_total_disbursements', db.Float, doc="Total adjusted disbursements for that entity type")
