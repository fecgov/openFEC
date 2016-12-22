import calendar
from datetime import date, datetime, timedelta

from .base import db

from webservices import docs


class EntityReceiptDisbursementTotals(db.Model):
    """two year receipt and disbursement totals by entity type and two-year election period"""
    __tablename__ = 'ofec_entity_chart_mv'

    idx = db.Column(db.Integer, primary_key=True)
    cycle = db.Column(db.Integer, doc=docs.RECORD_CYCLE)
    month = db.Column(db.Integer, doc="Numeric representation of year")
    year = db.Column(db.Integer, doc="Numeric representation of month")
    cumulative_candidate_receipts = db.Column(db.Float, doc="Cumulative candidate receipts in a two year period, adjusted to avoid double counting.")
    cumulative_candidate_disbursements = db.Column(db.Float, doc="Cumulative candidate disbursements in a two year period, adjusted to avoid double counting.")
    cumulative_pac_receipts = db.Column(db.Float, doc="Cumulative PAC recipts in a two year period, adjusted to avoid double counting.")
    cumulative_pac_disbursements = db.Column(db.Float, doc="Cumulative PAC disbursements in a two year period, adjusted to avoid double counting.")
    cumulative_party_receipts = db.Column(db.Float, doc="Cumulative party receipts in a two year period, adjusted to avoid double counting.")
    cumulative_party_disbursements = db.Column(db.Float, doc="Cumulative party disbursements in a two year period, adjusted to avoid double counting.")

    @property
    def date(self):
        end_day = calendar.monthrange(int(self.year), int(self.month))[1]
        formatted_date = datetime(int(self.year), int(self.month), int(end_day))
        if formatted_date >= datetime.now():
            formatted_date = date.today() - timedelta(1)
        return formatted_date

