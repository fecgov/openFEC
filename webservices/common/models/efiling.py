import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import ARRAY, TSVECTOR
from sqlalchemy.ext.declarative import declared_attr

from webservices import docs

from .base import db, BaseModel

class BaseFilingSummary(db.Model):
    __tablename__ = 'real_efile_summary'
    repid = db.Column(db.Integer, primary_key=True)
    line_number = db.Column('lineno', db.Integer, primary_key=True)
    column_a = db.Column('cola', db.Float)
    column_b = db.Column('colb', db.Float)

class BaseFiling(db.Model):
    __abstract__ = True
    repid = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column('comid',db.Integer, index=True, doc=docs.COMMITTEE_ID)
    from_date = db.Column(db.Date)
    through_date = db.Column(db.Date)
    rpt_pgi = db.Column('rptpgi', db.String, doc=docs.ELECTION_TYPE)
    rpt_code = db.Column('rptcode', db.String)
    image_number = db.Column('imageno', db.Integer)
    street_address_one = db.Column('str1', db.String)
    street_address_two = db.Column('str2', db.String)
    city = db.Column(db.String)
    state = db.Column(db.String)
    zip = db.Column(db.String)

class BaseF3PFiling(BaseFiling):
    __tablename__ = 'real_efile_f3p'
    repid = db.Column(db.Integer, primary_key=True)

    candidate_name = db.Column('c_name', db.String, index=True, doc=docs.CANDIDATE_NAME)
    street_address_one = db.Column('c_str1', db.String)
    street_address_two = db.Column('c_str2', db.String)
    city = db.Column('c_city', db.String)
    state = db.Column('c_state', db.String)
    zip = db.Column('c_zip', db.String)
    total_receipts = db.Column('tot_rec', db.Float)
    total_disbursements = db.Column('tot_dis', db.Float)
    cash = db.Column(db.Float)

    summary_lines = db.relationship(
        'BaseFilingSummary',
        primaryjoin='''and_(
                BaseF3PFiling.repid == BaseFilingSummary.repid,
            )''',
        foreign_keys=repid,
        uselist=True,
    )

class BaseF3Filing(BaseFiling):
    __tablename__ = 'real_efile_f3'
    repid = db.Column(db.Integer, primary_key=True)


    summary_lines = db.relationship(
        'BaseFilingSummary',
        primaryjoin='''and_(
                BaseF3Filing.repid == BaseFilingSummary.repid,
            )''',
        foreign_keys=repid,
        uselist=True,
    )

class BaseF3XFiling(BaseFiling):
    __tablename__ = 'real_efile_f3x'
    repid = db.Column(db.Integer, primary_key=True)

    committee_name = db.Column('com_name', db.String, index=True, doc=docs.COMMITTEE_NAME)




    summary_lines = db.relationship(
        'BaseFilingSummary',
        primaryjoin='''and_(
                BaseF3XFiling.repid == BaseFilingSummary.repid,
            )''',
        foreign_keys=repid,
        uselist=True,
    )





