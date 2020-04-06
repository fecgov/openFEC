from .base import db

from webservices import docs


class ElectionsList(db.Model):
    __tablename__ = 'ofec_elections_list_mv'

    idx = db.Column(db.Integer, primary_key=True)
    sort_order = db.Column(db.Integer)
    office = db.Column(db.String, doc=docs.OFFICE)
    state = db.Column(db.String, doc=docs.STATE_GENERIC)
    district = db.Column(db.String, doc=docs.DISTRICT)
    cycle = db.Column(db.Integer)
    incumbent_id = db.Column(db.String, doc=docs.CANDIDATE_ID)
    incumbent_name = db.Column(db.String, doc=docs.CANDIDATE_NAME)


class ZipsDistricts(db.Model):
    __table_args__ = {'schema': 'staging'}
    __tablename__ = 'ref_zip_to_district'

    zip_district_id = db.Column(db.Integer, primary_key=True)
    district = db.Column(db.String, doc=docs.DISTRICT)
    zip_code = db.Column(db.String)
    state_abbrevation = db.Column(db.String)
    active = db.Column(db.String)


class StateElectionOfficeInfo(db.Model):
    __table_args__ = {'schema': 'fecapp'}
    __tablename__ = 'trc_st_elect_office'

    office_type = db.Column('state_access_type', db.String, primary_key=True)
    office_name = db.Column(db.String)
    address_line1 = db.Column('address1', db.String)
    address_line2 = db.Column('address2', db.String)
    city = db.Column(db.String)
    state = db.Column('st', db.String, primary_key=True)
    state_full_name = db.Column('state_name', db.String)
    zip_code = db.Column(db.String)
    website_url1 = db.Column('url1', db.String)
    website_url2 = db.Column('url2', db.String)
    email = db.Column(db.String)
    primary_phone_number = db.Column('primary_phone', db.String)
    secondary_phone_number = db.Column('phone2', db.String)
    fax_number = db.Column(db.String)
    mailing_address1 = db.Column(db.String)
    mailing_address2 = db.Column(db.String)
    mailing_city = db.Column(db.String)
    mailing_state = db.Column(db.String)
    mailing_zipcode = db.Column(db.String)
