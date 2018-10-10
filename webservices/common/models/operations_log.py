from .base import db
from webservices import docs


class OperationsLog(db.Model):

    __tablename__ = 'fec_operations_log_vw'

    sub_id = db.Column(db.Integer, primary_key=True, doc=docs.SUB_ID)
    status_num = db.Column(db.Integer, doc=docs.STATUS_NUM)
    form_type = db.Column('form_tp', db.String, doc=docs.FORM_TYPE)
    report_year = db.Column('rpt_yr', db.Integer, doc=docs.REPORT_YEAR)
    candidate_committee_id = db.Column('cand_cmte_id', db.String, doc=docs.CAND_CMTE_ID)
    beginning_image_number = db.Column(
        'beg_image_num', db.String, doc=docs.BEGINNING_IMAGE_NUMBER
    )
    ending_image_number = db.Column(
        'end_image_num', db.String, doc=docs.ENDING_IMAGE_NUMBER
    )
    receipt_date = db.Column('receipt_dt', db.DateTime, doc=docs.RECEIPT_DATE)
    coverage_start_date = db.Column(
        'beginning_coverage_dt', db.DateTime, doc=docs.COVERAGE_START_DATE
    )
    coverage_end_date = db.Column(
        'ending_coverage_dt', db.DateTime, doc=docs.COVERAGE_END_DATE
    )
    amendment_indicator = db.Column(
        'amndt_ind', db.String, doc="Type of the report.N(new), A(amended) or T(cancel)"
    )
    report_type = db.Column(
        'rpt_tp', db.String, doc="Monthly, quarterly or other period covered reports"
    )
    summary_data_complete_date = db.Column(
        'pass_1_entry_dt',
        db.DateTime,
        doc="Date when the report is entered into the database",
    )
    summary_data_verification_date = db.Column(
        'pass_1_verified_dt',
        db.DateTime,
        doc="Same day or a day after the report is loaded in the database",
    )
    transaction_data_complete_date = db.Column(
        'pass_3_entry_done_dt',
        db.Date,
        doc="Date when the report is processed completely",
    )


class TransactionCoverage(db.Model):

    __tablename__ = 'ofec_agg_coverage_date_mv'

    idx = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column('committee_id', db.String, doc=docs.COMMITTEE_ID)
    fec_election_year = db.Column('fec_election_yr', db.Integer)
    transaction_coverage_date = db.Column(
        db.Date, doc="Date through which transaction-level data is available"
    )
