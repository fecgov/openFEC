import datetime

from webservices import docs, utils
from webservices.common.models.dates import ReportType
from webservices.common.models.dates import clean_report_type
from webservices.common.models.reports import CsvMixin

from .base import db


class Filings(db.Model, CsvMixin):
    __tablename__ = 'ofec_filings_mv'

    committee_id = db.Column(db.String, index=True, doc=docs.COMMITTEE_ID)
    committee = utils.related_committee_history('committee_id', cycle_label='report_year')
    committee_name = db.Column(db.String, doc=docs.COMMITTEE_NAME)
    candidate_id = db.Column(db.String, index=True, doc=docs.CANDIDATE_ID)
    candidate_name = db.Column(db.String, doc=docs.CANDIDATE_NAME)
    cycle = db.Column(db.Integer, doc=docs.RECORD_CYCLE)
    sub_id = db.Column(db.BigInteger, index=True, primary_key=True)
    coverage_start_date = db.Column(db.Date, doc=docs.COVERAGE_START_DATE)
    coverage_end_date = db.Column(db.Date, doc=docs.COVERAGE_END_DATE)
    receipt_date = db.Column(db.Date, index=True, doc=docs.RECEIPT_DATE)
    election_year = db.Column(db.Integer, doc=docs.ELECTION_YEAR)
    form_type = db.Column(db.String, index=True, doc=docs.FORM_TYPE)
    report_year = db.Column(db.Integer, index=True, doc=docs.REPORT_YEAR)
    report_type = db.Column(db.String, index=True, doc=docs.REPORT_TYPE)
    document_type = db.Column(db.String, index=True, doc=docs.DOCUMENT_TYPE)
    document_type_full = db.Column(db.String, doc=docs.DOCUMENT_TYPE)
    report_type_full = db.Column(db.String, doc=docs.REPORT_TYPE)
    beginning_image_number = db.Column(db.BigInteger, index=True, doc=docs.BEGINNING_IMAGE_NUMBER)
    ending_image_number = db.Column(db.BigInteger, doc=docs.ENDING_IMAGE_NUMBER)
    pages = db.Column(db.Integer, doc='Number of pages in the document')
    total_receipts = db.Column(db.Numeric(30, 2))
    total_individual_contributions = db.Column(db.Numeric(30, 2))
    net_donations = db.Column(db.Numeric(30, 2))
    total_disbursements = db.Column(db.Numeric(30, 2))
    total_independent_expenditures = db.Column(db.Numeric(30, 2))
    total_communication_cost = db.Column(db.Numeric(30, 2))
    cash_on_hand_beginning_period = db.Column(db.Numeric(30, 2), doc=docs.CASH_ON_HAND_BEGIN_PERIOD)
    cash_on_hand_end_period = db.Column(db.Numeric(30, 2), doc=docs.CASH_ON_HAND_END_PERIOD)
    debts_owed_by_committee = db.Column(db.Numeric(30, 2), doc=docs.DEBTS_OWED_BY_COMMITTEE)
    debts_owed_to_committee = db.Column(db.Numeric(30, 2), doc=docs.DEBTS_OWED_TO_COMMITTEE)
    house_personal_funds = db.Column(db.Numeric(30, 2))
    senate_personal_funds = db.Column(db.Numeric(30, 2))
    opposition_personal_funds = db.Column(db.Numeric(30, 2))
    treasurer_name = db.Column(db.String, doc=docs.TREASURER_NAME)
    file_number = db.Column(db.BigInteger)
    previous_file_number = db.Column(db.BigInteger)
    primary_general_indicator = db.Column(db.String, index=True)
    report_type_full = db.Column(db.String, doc=docs.REPORT_TYPE)
    request_type = db.Column(db.String)
    amendment_indicator = db.Column(db.String, index=True)
    update_date = db.Column(db.Date)
    pdf_url = db.Column(db.String)

    @property
    def document_description(self):
        return utils.document_description(
            self.report_year,
            self.report_type_full,
            self.document_type_full,
            self.form_type,
        )


class EFilings(db.Model, CsvMixin):
    __tablename__ = 'real_efile_reps'

    file_number = db.Column('repid', db.BigInteger, index=True, primary_key=True, doc=docs.FILE_NUMBER)
    form_type = db.Column('form', db.String, doc=docs.FORM_TYPE)
    committee_id = db.Column('comid', db.String, index=True, doc=docs.COMMITTEE_ID)
    committee_name = db.Column('com_name', db.String, doc=docs.COMMITTEE_NAME)
    receipt_date = db.Column('timestamp', db.DateTime, index=True, doc=docs.RECEIPT_DATE)
    load_timestamp = db.Column('create_dt', db.DateTime, doc=docs.LOAD_DATE)
    coverage_start_date = db.Column('from_date', db.Date, doc=docs.COVERAGE_START_DATE)
    coverage_end_date = db.Column('through_date', db.Date, doc=docs.COVERAGE_END_DATE)
    beginning_image_number = db.Column('starting', db.BigInteger, doc=docs.BEGINNING_IMAGE_NUMBER)
    ending_image_number = db.Column('ending', db.BigInteger, doc=docs.ENDING_IMAGE_NUMBER)
    report_type = db.Column('rptcode', db.String, db.ForeignKey(ReportType.report_type), doc=docs.REPORT_TYPE)
    amended_by = db.Column('superceded', db.BigInteger, doc=docs.AMENDED_BY)
    amends_file = db.Column('previd', db.BigInteger, doc=docs.AMENDS_FILE)
    amendment_number = db.Column('rptnum', db.Integer, doc=docs.AMENDMENT_NUMBER)

    report = db.relationship(ReportType)

    @property
    def document_description(self):
        return utils.document_description(
            self.coverage_end_date.year,
            clean_report_type(self.report.report_type_full),
            None,
            self.form_type,
        )

    @property
    def is_amended(self):
        if self.superceded is not None:
            return True
        return False

    @property
    def pdf_url(self):
        image_number = str(self.beginning_image_number)
        return 'http://docquery.fec.gov/pdf/{0}/{1}/{1}.pdf'.format(image_number[-3:], image_number)


# TODO: add index on committee id and filed_date
    #  version -- this is the efiling version and I don't think we need this - let's document in API for now, see if there are objections
