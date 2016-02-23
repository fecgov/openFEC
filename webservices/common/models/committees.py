from sqlalchemy.dialects.postgresql import ARRAY, TSVECTOR

from webservices import docs

from .base import db, BaseModel


class CommitteeSearch(BaseModel):
    __tablename__ = 'ofec_committee_fulltext'

    id = db.Column(db.String)
    name = db.Column(db.String, doc=docs.COMMITTEE_NAME)
    fulltxt = db.Column(TSVECTOR)
    receipts = db.Column(db.Numeric(30, 2))


class BaseCommittee(BaseModel):
    __abstract__ = True

    committee_id = db.Column(db.String, primary_key=True, index=True, doc=docs.COMMITTEE_ID)
    cycles = db.Column(ARRAY(db.Integer), index=True, doc=docs.COMMITTEE_CYCLE)
    designation = db.Column(db.String(1), index=True, doc=docs.DESIGNATION)
    designation_full = db.Column(db.String(25), index=True, doc=docs.DESIGNATION)
    treasurer_name = db.Column(db.String(100), index=True, doc=docs.TREASURER_NAME)
    treasurer_text = db.Column(TSVECTOR)
    organization_type = db.Column(db.String(1), index=True, doc=docs.ORGANIZATION_TYPE)
    organization_type_full = db.Column(db.String(100), index=True, doc=docs.ORGANIZATION_TYPE)
    state = db.Column(db.String(2), index=True, doc=docs.COMMITTEE_STATE)
    committee_type = db.Column(db.String(1), index=True, doc=docs.COMMITTEE_TYPE)
    committee_type_full = db.Column(db.String(50), index=True, doc=docs.COMMITTEE_TYPE)
    # ? how to explain
    expire_date = db.Column(db.DateTime())
    party = db.Column(db.String(3), index=True, doc=docs.PARTY)
    party_full = db.Column(db.String(50), doc=docs.PARTY)
    name = db.Column(db.String(100), index=True, doc=docs.COMMITTEE_NAME)


class BaseConcreteCommittee(BaseCommittee):
    __tablename__ = 'ofec_committee_detail'

    committee_id = db.Column(db.String, primary_key=True, unique=True, index=True, doc=docs.COMMITTEE_ID)
    candidate_ids = db.Column(ARRAY(db.Text), doc=docs.CANDIDATE_ID)


class Committee(BaseConcreteCommittee):
    __table_args__ = {'extend_existing': True}

    first_file_date = db.Column(db.Date, doc=docs.FIRST_FILE_DATE)
    last_file_date = db.Column(db.Date, doc=docs.LAST_FILE_DATE)
    last_f1_date = db.Column(db.Date, doc=docs.LAST_F1_DATE)


class CommitteeHistory(BaseCommittee):
    __tablename__ = 'ofec_committee_history'

    street_1 = db.Column(db.String(50), doc='Street address of committee as reported on the Form 1')
    street_2 = db.Column(db.String(50), doc='Second line of street address of committee as reported on the Form 1')
    city = db.Column(db.String(50), doc='City of committee as reported on the Form 1')
    state_full = db.Column(db.String(50), doc='State of committee as reported on the Form 1')
    zip = db.Column(db.String(9), doc='Zip code of committee as reported on the Form 1')
    cycle = db.Column(db.Integer, primary_key=True, index=True, doc=docs.COMMITTEE_CYCLE)


class CommitteeDetail(BaseConcreteCommittee):
    __table_args__ = {'extend_existing': True}

    first_file_date = db.Column(db.Date, doc=docs.FIRST_FILE_DATE)
    last_file_date = db.Column(db.Date, doc=docs.LAST_FILE_DATE)
    filing_frequency = db.Column(db.String(1))
    email = db.Column(db.String(50), doc='Email as reported on the Form 1')
    fax = db.Column(db.String(10), doc='Fax as reported on the Form 1')
    website = db.Column(db.String(50), doc='Website url as reported on the Form 1')
    form_type = db.Column(db.String(3), doc='Form where the information was reported')
    leadership_pac = db.Column(db.String(50), doc='Indicates if the committee is a leadership PAC')
    lobbyist_registrant_pac = db.Column(db.String(1), doc='Indicates if the committee is a lobbyist registrant PAC')
    party_type = db.Column(db.String(3), doc='Code for the type of party the committee is, only if applicable')
    party_type_full = db.Column(db.String(15), doc='Description of the type of party the committee is, only if applicable')
    #? explain this more
    qualifying_date = db.Column(db.Date(), doc='Date the committee became a qualified committee.')
    street_1 = db.Column(db.String(50), doc='Street address of committee as reported on the Form 1')
    street_2 = db.Column(db.String(50), doc='Second line of street address of committee as reported on the Form 1')
    city = db.Column(db.String(50), doc='City of committee as reported on the Form 1')
    state_full = db.Column(db.String(50), doc='State of committee as reported on the Form 1')
    zip = db.Column(db.String(9), doc='Zip code of committee as reported on the Form 1')
    treasurer_city = db.Column(db.String(50), doc='City of committee treasurer as reported on the Form 1')
    treasurer_name_1 = db.Column(db.String(50))
    treasurer_name_2 = db.Column(db.String(50))
    treasurer_name_middle = db.Column(db.String(50))
    treasurer_name_prefix = db.Column(db.String(50))
    treasurer_phone = db.Column(db.String(15), doc='Phone number of the committee treasurer as reported on the Form 1')
    treasurer_state = db.Column(db.String(50), doc='State of the committee treasurer as reported on the Form 1')
    treasurer_street_1 = db.Column(db.String(50), doc='Street of the committee treasurer as reported on the Form 1')
    treasurer_street_2 = db.Column(db.String(50), doc='Second line of the street address of the committee treasurer as reported on the Form 1')
    treasurer_name_suffix = db.Column(db.String(50))
    treasurer_name_title = db.Column(db.String(50))
    treasurer_zip = db.Column(db.String(9), doc='Zip code of the committee treasurer as reported on the Form 1')
    custodian_city = db.Column(db.String(50), doc='City of committee custodian as reported on the Form 1')
    custodian_name_1 = db.Column(db.String(50))
    custodian_name_2 = db.Column(db.String(50))
    custodian_name_middle = db.Column(db.String(50))
    custodian_name_full = db.Column(db.String(100), doc='Name of custodian')
    custodian_phone = db.Column(db.String(15), doc='Phone number of the committee custodian as reported on the Form 1')
    custodian_name_prefix = db.Column(db.String(50))
    custodian_state = db.Column(db.String(2), doc='State of the committee custodian as reported on the Form 1')
    custodian_street_1 = db.Column(db.String(50), doc='Street address of the committee custodian as reported on the Form 1')
    custodian_street_2 = db.Column(db.String(50), doc='Second line of the street address of the committee custodian as reported on the Form 1')
    custodian_name_suffix = db.Column(db.String(50))
    custodian_name_title = db.Column(db.String(50))
    custodian_zip = db.Column(db.String(9), doc='Zip code of the committee custodian as reported on the Form 1')
