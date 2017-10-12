
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import ARRAY
from .base import db, BaseModel
from webservices import docs

class AuditSearchMixin(object):
    __table_args__ = {"schema": "auditsearch"}


class FindingIssueCategory(AuditSearchMixin, db.Model):
    __tablename__ = 'finding_issue_category_jl_vw'

    category_id = db.Column(db.Integer, index=True, primary_key=True)
    category = db.Column(db.String, doc=docs.CATEGORY)
    subcategory_id = db.Column(ARRAY(db.String), doc=docs.SUBCATEGORY)
    subcategory = db.Column(ARRAY(db.String), doc=docs.SUBCATEGORY)
 

class AuditSearch(db.Model):
    __tablename__ = 'ofec_audit_search_jl_mv'

    idx = db.Column(db.Integer, primary_key=True)
    audit_case_id = db.Column(db.Integer)
    category_subcategory_id = db.Column('finding_id',ARRAY(db.String), doc=docs.SUBCATEGORY)
    category_subcategory = db.Column('findings', ARRAY(db.String), doc=docs.SUBCATEGORY)
    election_cycle = db.Column(db.Integer, index=True)
    far_release_date = db.Column(db.Date)
    link_to_report = db.Column(db.String)
    committee_id = db.Column(db.String, index=True)
    committee_name = db.Column(db.String)
    committee_designation = db.Column(db.String)
    committee_type = db.Column(db.String)
    committee_description = db.Column(db.String)
    audit_id = db.Column(db.Integer, index=True)
    candidate_id = db.Column(db.String, index=True)
    candidate_name = db.Column(db.String)


class AuditFindingsView(AuditSearchMixin, db.Model):
    __tablename__ = 'findings_vw'

    idx = db.Column('finding_pk', db.Integer, primary_key=True)
    tier = db.Column('tier', db.Integer, index=True, doc=docs.AUDIT_TIER)
    category_id = db.Column('parent_finding_pk', db.Integer, index=True, doc=docs.CATEGORY)
    category = db.Column('tier_one_finding', db.String, doc=docs.CATEGORY)
    subcategory_id = db.Column('child_finding_pk', db.Integer, index=True, doc=docs.SUBCATEGORY)
    subcategory = db.Column('tier_two_finding', db.String, doc=docs.SUBCATEGORY)


class AuditSearchView(db.Model):
   __tablename__ = 'ofec_audit_search_rj_mv'

   idx = db.Column(db.Integer, primary_key=True)
   audit_case_id = db.Column(db.Integer)
   audit_id = db.Column(db.Integer, index=True)
   election_cycle = db.Column(db.Integer, index=True)
   far_release_date = db.Column(db.Date)
   link_to_report = db.Column(db.String)
   committee_id = db.Column(db.String, index=True)
   committee_name = db.Column(db.String)
   committee_designation = db.Column(db.String)
   committee_type = db.Column(db.String)
   committee_description = db.Column(db.String)
   candidate_id = db.Column(db.String, index=True)
   candidate_name = db.Column(db.String)
   category_id = db.Column(ARRAY(db.Integer), index=True, doc=docs.CATEGORY)
   category = db.Column('category_name',ARRAY(db.String), doc=docs.CATEGORY)
   subcategory_id = db.Column('sub_category_id', ARRAY(db.Integer), index=True, doc=docs.SUBCATEGORY)
   subcategory = db.Column('sub_category_name', ARRAY(db.String), doc=docs.SUBCATEGORY)
   cat_sub_cat_ids = db.Column(ARRAY(db.String), doc=docs.SUBCATEGORY)
   cat_sub_cat_names = db.Column(ARRAY(db.String), doc=docs.SUBCATEGORY)

