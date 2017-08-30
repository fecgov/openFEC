
import sqlalchemy as sa
from .base import db, BaseModel
from webservices import docs

class AuditSearchMixin(object):
    __table_args__ = {"schema": "auditsearch"}

class AuditCase(AuditSearchMixin, db.Model):
    __tablename__ = 'audit_case'

    audit_case_id = db.Column('audit_case_id', db.String, index=True, primary_key=True, doc=docs.AUDIT_CASE_ID)
    audit_id = db.Column('audit_id', db.String, doc=docs.AUDIT_ID)
    election_cycle = db.Column('election_cycle', db.Integer, doc=docs.ELECTION_CYCLE)
    committee_id = db.Column('cmte_id', db.String, doc=docs.COMMITTEE_ID)
    candidate_id = db.Column('cand_id', db.String, doc=docs.CANDIDATE_ID)

class AuditFinding(AuditSearchMixin, db.Model):
    __tablename__ = 'finding'

    finding_id = db.Column('finding_pk', db.String, index=True, primary_key=True, doc=docs.FINDING_ID)
    finding = db.Column('finding', db.String, doc=docs.FINDING)
    tier = db.Column('tier', db.Integer, doc=docs.TIER)

class AuditFindingRel(AuditSearchMixin, db.Model):
    __tablename__ = 'finding_rel'

    relation_pk = db.Column('rel_pk', db.Integer, index=True, primary_key=True)
    parent_finding_pk = db.Column('parent_finding_pk', db.Integer)
    child_finding_pk = db.Column('child_finding_pk', db.Integer)

class AuditFindingsView(AuditSearchMixin, db.Model):
    __tablename__ = 'audit_findings_vw'

    idx = db.Column(db.Integer, primary_key=True)
    tier_one_id = db.Column('parent_finding_pk', db.String, index=True, doc=docs.TIER)
    tier_one_finding = db.Column('parent_finding', db.String, doc=docs.FINDING)
    tier_two_id = db.Column('child_finding_pk', db.String)
    tier_two_finding = db.Column('child_finding', db.String, doc=docs.FINDING)
    audit_case_id = db.Column('audit_case_id', db.String)
    audit_id = db.Column('audit_id', db.String)
    election_cycle = db.Column('election_cycle', db.String)
    far_release_date = db.Column('far_release_date', db.String)
    link_to_report = db.Column('link_to_report', db.String)
    cand_id = db.Column('cand_id', db.String)
    cmte_id = db.Column('cmte_id', db.String)
    cand_name = db.Column('cand_name', db.String)
    cmte_name = db.Column('cmte_name', db.String)








 

