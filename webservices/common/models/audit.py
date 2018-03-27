import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import TSVECTOR
from sqlalchemy.ext.declarative import declared_attr

from webservices import docs

from .base import db

class AuditBase(object):
    __table_args__ = {"schema": "auditsearch"}


# endpoint: audit-primary-category
class AuditPrimaryCategory(AuditBase, db.Model):
    __tablename__ = 'finding_vw'

    primary_category_id = db.Column(db.String, index=True, primary_key=True, doc=docs.PRIMARY_CATEGORY_ID)
    primary_category_name = db.Column(db.String, doc=docs.PRIMARY_CATEGORY_NAME)
    tier = db.Column(db.Integer, doc=docs.AUDIT_TIER)


# endpoint: audit-category
class AuditCategoryRelation(AuditBase, db.Model):
    __tablename__ = 'finding_rel_vw'

    primary_category_id = db.Column(db.String, index=True, primary_key=True, doc=docs.PRIMARY_CATEGORY_ID)
    primary_category_name = db.Column(db.String, doc=docs.PRIMARY_CATEGORY_NAME)
    sub_category_id = db.Column(db.String, index=True, primary_key=True, doc=docs.SUB_CATEGORY_ID)
    sub_category_name = db.Column(db.String, index=True, doc=docs.SUB_CATEGORY_NAME)


# endpoint: audit-category
class AuditCategory(AuditPrimaryCategory):
    @declared_attr
    def sub_category_list(self):
        return sa.orm.relationship(
            AuditCategoryRelation,
            primaryjoin=sa.orm.foreign(AuditCategoryRelation.primary_category_id) == self.primary_category_id,
            uselist=True,
        )

# endpoint audit-case
class AuditCaseSubCategory(db.Model):
    __tablename__ = 'ofec_audit_case_sub_category_rel_mv'
    audit_case_id = db.Column(db.String, primary_key=True, doc=docs.AUDIT_CASE_ID)
    primary_category_id = db.Column(db.String, primary_key=True, doc=docs.PRIMARY_CATEGORY_ID)
    primary_category_name = db.Column(db.String, doc=docs.PRIMARY_CATEGORY_NAME)
    sub_category_id = db.Column(db.String, primary_key=True, doc=docs.SUB_CATEGORY_ID)
    sub_category_name = db.Column(db.String, primary_key=True, doc=docs.SUB_CATEGORY_NAME)


# endpoint audit-case
class AuditCaseCategoryRelation(db.Model):
    __tablename__ = 'ofec_audit_case_category_rel_mv'
    audit_case_id = db.Column(db.String, primary_key=True, doc=docs.AUDIT_CASE_ID)
    primary_category_id = db.Column(db.String, primary_key=True, doc=docs.PRIMARY_CATEGORY_ID)
    primary_category_name = db.Column(db.String, doc=docs.PRIMARY_CATEGORY_NAME)
    sub_category_list = db.relationship(
        'AuditCaseSubCategory',
        primaryjoin='''and_(
            foreign(AuditCaseCategoryRelation.audit_case_id) == AuditCaseSubCategory.audit_case_id,
            foreign(AuditCaseCategoryRelation.primary_category_id) == AuditCaseSubCategory.primary_category_id
       )''',
        uselist=True,
        lazy='joined'
    )


# endpoint audit-case
class AuditCase(db.Model):
    __tablename__ = 'ofec_audit_case_mv'
    idx = db.Column(db.Integer, primary_key=True, index=True)
    primary_category_id = db.Column(db.String, index=True, doc=docs.PRIMARY_CATEGORY_ID)
    sub_category_id = db.Column(db.String, doc=docs.SUB_CATEGORY_ID)

    # sa.Index('primary_category_id', 'sub_category_id')
    audit_case_id = db.Column(db.String, index=True, doc=docs.AUDIT_CASE_ID)
    cycle = db.Column(db.Integer, doc=docs.CYCLE)
    committee_id = db.Column(db.String, doc=docs.COMMITTEE_ID)
    committee_name = db.Column(db.String, doc=docs.COMMITTEE_NAME)
    committee_designation = db.Column(db.String, doc=docs.DESIGNATION)
    committee_type = db.Column(db.String, doc=docs.COMMITTEE_TYPE)
    committee_description = db.Column(db.String, doc=docs.COMMITTEE_DESCRIPTION)
    far_release_date = db.Column(db.Date, doc=docs.FAR_RELEASE_DATE)
    link_to_report = db.Column(db.String, doc=docs.LINK_TO_REPORT)
    audit_id = db.Column(db.Integer, doc=docs.AUDIT_ID)
    candidate_id = db.Column(db.String, doc=docs.CANDIDATE_ID)
    candidate_name = db.Column(db.String, doc=docs.CANDIDATE_NAME)
    primary_category_list = db.relationship(
        AuditCaseCategoryRelation,
        primaryjoin='''and_(
            foreign(AuditCaseCategoryRelation.audit_case_id) == AuditCase.audit_case_id
        )''',
        uselist=True,
        lazy='joined'
    )


# endpoint audit/search/name/candidates
class AuditCandidateSearch(db.Model):
    __tablename__ = 'ofec_candidate_fulltext_audit_mv'

    idx = db.Column(db.String, primary_key=True)
    id = db.Column(db.String)
    name = db.Column(db.String, doc=docs.CANDIDATE_NAME)
    fulltxt = db.Column(TSVECTOR)


# endpoint audit/search/name/committees
class AuditCommitteeSearch(db.Model):
    __tablename__ = 'ofec_committee_fulltext_audit_mv'

    idx = db.Column(db.String, primary_key=True)
    id = db.Column(db.String)
    name = db.Column(db.String, doc=docs.COMMITTEE_NAME)
    fulltxt = db.Column(TSVECTOR)
