from .base import db
from webservices import docs

class OperationsLog(db.Model):
    __table_args__ = {"schema": "staging"}
    __tablename__ = 'operations_log'

    sub_id = db.Column(db.Integer, primary_key=True, doc=docs.SUB_ID)
    status_num = db.Column(db.Integer, doc=docs.STATUS_NUM)
    cand_cmte_id = db.Column(db.String, doc=docs.CAND_CMTE_ID)
    beg_image_num = db.Column(db.String, doc="")
    end_image_num = db.Column(db.String, doc="")
    form_tp = db.Column(db.String, doc=docs.FORM_TYPE)
    rpt_yr = db.Column(db.Integer, doc=docs.REPORT_YEAR)
    amndt_ind = db.Column(db.String, doc="")
    rpt_tp = db.Column(db.String, doc="")
    pass_1_entry_dt = db.Column(db.DateTime, doc="")
    pass_1_verified_dt = db.Column(db.DateTime, doc="")
    pass_3_entry_done_dt = db.Column(db.Date, doc="")
    receipt_dt = db.Column(db.DateTime, doc="")
    beginning_coverage_dt = db.Column(db.DateTime, doc="")
    ending_coverage_dt = db.Column(db.DateTime, doc="")
