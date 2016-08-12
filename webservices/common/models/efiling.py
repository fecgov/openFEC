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
    election_date = db.Column('el_date', db.Date)
    election_state = db.Column('el_state', db.String)
    create_date = db.Column('create_dt', db.Date)
    sign_date = db.Column(db.Date)

class BaseF3PFiling(BaseFiling):
    __tablename__ = 'real_efile_f3p'
    repid = db.Column(db.Integer, primary_key=True)

    treasurer_last_name = db.Column('lname', db.String)
    treasurer_middle_name = db.Column('mname', db.String)
    treasurer_first_name = db.Column('fname', db.String)
    prefix = db.Column(db.String)
    suffix = db.Column(db.String)
    committee_name = db.Column('c_name', db.String, index=True, doc=docs.CANDIDATE_NAME)
    street_address_one = db.Column('c_str1', db.String)
    street_address_two = db.Column('c_str2', db.String)
    city = db.Column('c_city', db.String)
    state = db.Column('c_state', db.String)
    zip = db.Column('c_zip', db.String)
    total_receipts = db.Column('tot_rec', db.Float)
    total_disbursements = db.Column('tot_dis', db.Float)
    cash = db.Column(db.Float)
    cash_close = db.Column(db.Float)
    debts_to = db.Column(db.Float)
    expe = db.Column(db.Float)
    net_contributions = db.Column('net_con', db.Float)
    net_operating_expenditures = db.Column('net_op', db.Float)
    primary_election = db.Column('act_pri', db.String)
    general_election = db.Column('act_gen', db.String)
    sub_total_sum = db.Column('sub', db.String)

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
    candidate_last_name = db.Column('can_lname', db.String)
    candidate_first_name = db.Column('can_fname', db.String)
    candidate_middle_name = db.Column('can_mname', db.String)
    candidate_prefix = db.Column('can_prefix', db.String)
    candidate_suffix = db.Column('can_suffix', db.String)
    f3z1 = db.Column(db.Integer)
    primary_election = db.Column('act_pri', db.String)
    general_election = db.Column('act_gen', db.String)
    special_election = db.Column('act_spe', db.String)
    runoff_election = db.Column('act_run', db.String)
    election_district = db.Column('eld', db.Integer)
    amend_address = db.Column('amend_addr', db.String)

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
    sign_date = db.Column('date_signed', db.Date)
    amend_address = db.Column('amend_addr', db.String)
    qual = db.Column(db.String)



    summary_lines = db.relationship(
        'BaseFilingSummary',
        primaryjoin='''and_(
                BaseF3XFiling.repid == BaseFilingSummary.repid,
            )''',
        foreign_keys=repid,
        uselist=True,
    )





