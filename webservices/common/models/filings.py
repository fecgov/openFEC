from webservices import utils

from .base import db


class Filings(db.Model):
    __tablename__ = 'ofec_filings_mv'

    committee_id = db.Column(db.String, index=True)
    committee = utils.related_committee_history('committee_id', cycle_label='report_year')
    committee_name = db.Column(db.String)
    candidate_id = db.Column(db.String, index=True)
    candidate_name = db.Column(db.String)
    cycle = db.Column(db.Integer)
    sub_id = db.Column(db.BigInteger, primary_key=True)
    coverage_start_date = db.Column(db.Date)
    coverage_end_date = db.Column(db.Date)
    receipt_date = db.Column(db.Date, index=True)
    election_year = db.Column(db.Integer)
    form_type = db.Column(db.String, index=True)
    report_year = db.Column(db.Integer, index=True)
    report_type = db.Column(db.String, index=True)
    document_type = db.Column(db.String, index=True)
    document_type_full = db.Column(db.String)
    report_type_full = db.Column(db.String)
    beginning_image_number = db.Column(db.BigInteger, index=True)
    ending_image_number = db.Column(db.BigInteger)
    pages = db.Column(db.Integer)
    total_receipts = db.Column(db.Integer)
    total_individual_contributions = db.Column(db.Integer)
    net_donations = db.Column(db.Integer)
    total_disbursements = db.Column(db.Integer)
    total_independent_expenditures = db.Column(db.Integer)
    total_communication_cost = db.Column(db.Integer)
    cash_on_hand_beginning_period = db.Column(db.Integer)
    cash_on_hand_end_period = db.Column(db.Integer)
    debts_owed_by_committee = db.Column(db.Integer)
    debts_owed_to_committee = db.Column(db.Integer)
    house_personal_funds = db.Column(db.Integer)
    senate_personal_funds = db.Column(db.Integer)
    opposition_personal_funds = db.Column(db.Integer)
    treasurer_name = db.Column(db.String)
    file_number = db.Column(db.BigInteger)
    previous_file_number = db.Column(db.BigInteger)
    primary_general_indicator = db.Column(db.String, index=True)
    report_type_full = db.Column(db.String)
    request_type = db.Column(db.String)
    amendment_indicator = db.Column(db.String, index=True)
    update_date = db.Column(db.Date)

    @property
    def document_description(self):
        return utils.document_description(
            self.report_year,
            self.report_type_full,
            self.document_type_full,
            self.form_type,
        )

    @property
    def pdf_url(self):
        return utils.report_pdf_url(
            self.report_year,
            self.beginning_image_number,
            committee_type=self.committee.committee_type if self.committee else None,
            form_type=self.form_type,
        )
