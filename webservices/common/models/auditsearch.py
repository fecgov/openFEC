
import sqlalchemy as sa
from .base import db, BaseModel
from webservices import docs

class AuditSearchMixin(object):
    __table_args__ = {"schema": "auditsearch"}


class AuditFindingsView(AuditSearchMixin, db.Model):
    __tablename__ = 'findings_vw'

    idx = db.Column('finding_pk',db.Integer, primary_key=True)
    tier = db.Column('tier', db.Integer, index=True, doc=docs.TIER)
    tier_one_id = db.Column('parent_finding_pk', db.Integer)
    tier_one_finding = db.Column('tier_one_finding', db.String)
    tier_two_id = db.Column('child_finding_pk', db.Integer)
    tier_two_finding = db.Column('tier_two_finding', db.String)

class AuditSearchView(db.Model):
    __tablename__ = 'ofec_audit_search_mv'

    idx = db.Column(db.Integer, primary_key=True)
    finding_id = db.Column('finding_id', db.Integer, index=True, doc=docs.FINDING_ID)
    finding = db.Column('finding', db.String, doc=docs.FINDING)
    issue_id = db.Column('issue_id', db.Integer, index=True, doc=docs.ISSUE_ID)
    issue = db.Column('issue', db.String, doc=docs.ISSUE)
    audit_case_id = db.Column('audit_case_id', db.Integer)
    audit_id = db.Column('audit_id', db.Integer, index=True)
    election_cycle = db.Column('election_cycle', db.Integer, index=True)
    far_release_date = db.Column('far_release_date', db.Date)
    link_to_report = db.Column('link_to_report', db.String)
    committee_id = db.Column('committee_id', db.String, index=True)
    committee_name = db.Column('committee_name', db.String)
    committee_designation = db.Column('committee_designation', db.String)
    committee_type = db.Column('committee_type', db.String)
    committee_description = db.Column('committee_description', db.String)
    candidate_id = db.Column('candidate_id', db.String, index=True)
    candidate_name = db.Column('candidate_name', db.String)
