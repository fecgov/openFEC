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
    date = db.Column(db.DateTime, doc="Date representation of the month and year")
    cumulative_candidate_receipts = db.Column(db.Float, doc="Cumulative candidate receipts in a two year period, adjusted to avoid double counting.")
    cumulative_candidate_disbursements = db.Column(db.Float, doc="Cumulative candidate disbursements in a two year period, adjusted to avoid double counting.")
    cumulative_pac_receipts = db.Column(db.Float, doc="Cumulative PAC recipts in a two year period, adjusted to avoid double counting.")
    cumulative_pac_disbursements = db.Column(db.Float, doc="Cumulative PAC disbursements in a two year period, adjusted to avoid double counting.")
    cumulative_party_receipts = db.Column(db.Float, doc="Cumulative party receipts in a two year period, adjusted to avoid double counting.")
    cumulative_party_disbursements = db.Column(db.Float, doc="Cumulative party disbursements in a two year period, adjusted to avoid double counting.")
    cumulative_communication_totals = db.Column(db.Float, doc="Cumulative communication totals, adjusted to avoid double double counting.")
    cumulative_electioneering_donations = db.Column(db.Float,
                                                doc="Cumulative electioneering donations, adjusted to avoid double double counting.")
    cumulative_electioneering_disbursements = db.Column(db.Float,
                                                doc="Cumulative electioneering disbursements, adjusted to avoid double double counting.")
    cumulative_independent_contributions = db.Column(db.Float,
                                                doc="Cumulative independent contributions, adjusted to avoid double double counting.")
    cumulative_independent_expenditures = db.Column(db.Float,
                                                     doc="Cumulative independent expenditures, adjusted to avoid double double counting.")
