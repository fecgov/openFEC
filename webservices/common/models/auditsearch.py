
from .base import db, BaseModel

class AuditSearchMixin(object):
    __table_args__ = {"schema": "auditsearch"}

class AuditCase(db.Model, AuditSearchMixin):
    __tablename__ = 'audit_case'

    audit_case_id = db.Column('audit_case_id', db.String, index=True, primary_key=True, doc=docs.AUDIT_CASE_ID)
    audit_id = db.Column('audit_id', db.String, index=True, doc=docs.AUDIT_ID)
    election_cycle = db.Column('election_cycle', db.Integer, index=True, doc=docs.ELECTION_CYCLE)
    far_release_date = db.Column('far_release_date', db.Date, index=True, doc=docs.FAR_RELEASE_DATE)
    link_to_report = db.Column('link_to_report', db.Date, index=True, doc=docs.LINK_TO_REPORT)
    cmte_id = db.Column('cmte_id', db.String, index=True, doc=docs.COMMITTE_ID)
    cand_id = db.Column('cand_id', db.String, index=True, doc=docs.CANDIDATE_ID)

class AuditFinding(db.Model, AuditSearchMixin):
    __tablename__ = 'finding'

    finding_id = db.Column('finding_pk', db.String, index=True, primary_key=True, doc=docs.FINDING_ID)
    finding = db.Column('finding', db.String, index=True, doc=docs.FINDING)
    tier = db.Column('tier', db.Integer, index=True, doc=docs.TIER)




  