import calendar
from datetime import date, datetime, timedelta

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
    receipts = db.Column('sum', db.Float, doc="Total adjusted receipts for that entity type")

    @property
    def date(self):
        end_day = calendar.monthrange(int(self.year), int(self.month))[1]
        formatted_date = datetime(int(self.year), int(self.month), int(end_day))
        if formatted_date >= datetime.now():
            formatted_date = date.today() - timedelta(1)
        return formatted_date




class EntityDisbursementsTotals(db.Model):
    """two year disbursement totals by entity type and two-year election period"""
    __tablename__ = 'entity_disbursements_chart'

    idx = db.Column(db.Integer, primary_key=True)
    cycle = db.Column(db.Integer, doc=docs.RECORD_CYCLE)
    type = db.Column(db.String, doc="Candidate, PAC, party or other")
    month = db.Column(db.Integer, doc="Numeric representation of year")
    year = db.Column(db.Integer, doc="Numeric representation of month")
    disbursements = db.Column('sum', db.Float, doc="Total adjusted disbursements for that entity type")

    @property
    def date(self):
        end_day = calendar.monthrange(int(self.year), int(self.month))[1]
        formatted_date = datetime(int(self.year), int(self.month), int(end_day))
        if formatted_date >= datetime.now():
            formatted_date = date.today() - timedelta(1)
        return formatted_date
