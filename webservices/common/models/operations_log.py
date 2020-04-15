from .base import db
from webservices import docs

class OperationsLog(db.Model):
    __tablename__ = 'fec_operations_log_vw'

    sub_id = db.Column(db.Integer, primary_key=True, doc=docs.SUB_ID)
    status_num = db.Column(db.Integer, doc=docs.STATUS_NUM)
    form_type = db.Column('form_tp', db.String, doc=docs.FORM_TYPE)
    report_year = db.Column('rpt_yr', db.Integer, doc=docs.REPORT_YEAR)
    candidate_committee_id = db.Column('cand_cmte_id', db.String, doc=docs.CAND_CMTE_ID)
    beginning_image_number = db.Column('beg_image_num', db.String, doc=docs.BEGINNING_IMAGE_NUMBER)
    ending_image_number = db.Column('end_image_num', db.String, doc=docs.ENDING_IMAGE_NUMBER)
    receipt_date = db.Column('receipt_dt', db.DateTime, doc=docs.RECEIPT_DATE)
    coverage_start_date = db.Column('beginning_coverage_dt', db.DateTime, doc=docs.COVERAGE_START_DATE)
    coverage_end_date = db.Column('ending_coverage_dt', db.DateTime, doc=docs.COVERAGE_END_DATE)
    amendment_indicator = db.Column('amndt_ind', db.String, doc=docs.AMENDMENT_INDICATOR)
    report_type = db.Column('rpt_tp', db.String, doc=docs.REPORT_TYPE)
    summary_data_complete_date = db.Column('pass_1_entry_dt', db.DateTime, doc=docs.SUMMERY_DATA_COMPLETE_DATE)
    summary_data_verification_date = db.Column('pass_1_verified_dt', db.DateTime,
        doc=docs.SUMMERY_DATA_VERIFICATION_DATE)
    transaction_data_complete_date = db.Column('pass_3_entry_done_dt', db.Date, doc=docs.TRANSACTION_DATA_COMPLETE_DATE)


class TransactionCoverage(db.Model):
    __tablename__ = 'ofec_agg_coverage_date_mv'

    idx = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column('committee_id', db.String, doc=docs.COMMITTEE_ID)
    fec_election_year = db.Column('fec_election_yr', db.Integer)
    transaction_coverage_date = db.Column(db.Date, doc=docs.TRANSACTION_COVERAGE_DATE)
