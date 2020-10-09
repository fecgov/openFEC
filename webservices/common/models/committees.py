from sqlalchemy.dialects.postgresql import ARRAY, TSVECTOR

from webservices import docs

from .base import db, BaseModel


class CommitteeSearch(BaseModel):
    __tablename__ = 'ofec_committee_fulltext_mv'

    id = db.Column(db.String)
    name = db.Column(db.String, doc=docs.COMMITTEE_NAME)
    fulltxt = db.Column(TSVECTOR)
    receipts = db.Column(db.Numeric(30, 2))
    disbursements = db.Column(db.Numeric(30, 2))
    independent_expenditures = db.Column(db.Numeric(30, 2))
    total_activity = db.Column(db.Numeric(30, 2))
    is_active = db.Column(db.Boolean, doc=docs.IS_COMMITTEE_ACTIVE)


class BaseCommittee(BaseModel):
    __abstract__ = True

    name = db.Column(db.String(100), index=True, doc=docs.COMMITTEE_NAME)
    committee_id = db.Column(db.String, primary_key=True, index=True, doc=docs.COMMITTEE_ID)
    cycles = db.Column(ARRAY(db.Integer), index=True, doc=docs.COMMITTEE_CYCLE)
    treasurer_name = db.Column(db.String(100), index=True, doc=docs.TREASURER_NAME)
    treasurer_text = db.Column(TSVECTOR)
    committee_type = db.Column(db.String(1), index=True, doc=docs.COMMITTEE_TYPE)
    committee_type_full = db.Column(db.String(50), index=True, doc=docs.COMMITTEE_TYPE)
    filing_frequency = db.Column(db.String(1), doc=docs.FILING_FREQUENCY)
    designation = db.Column(db.String(1), index=True, doc=docs.DESIGNATION)
    designation_full = db.Column(db.String(25), index=True, doc=docs.DESIGNATION)
    organization_type = db.Column(db.String(1), index=True, doc=docs.ORGANIZATION_TYPE)
    organization_type_full = db.Column(db.String(100), index=True, doc=docs.ORGANIZATION_TYPE)
    affiliated_committee_name = db.Column(db.String(100), doc=docs.AFFILIATED_COMMITTEE_NAME)
    party = db.Column(db.String(3), index=True, doc=docs.PARTY)
    party_full = db.Column(db.String(50), doc=docs.PARTY)
    state = db.Column(db.String(2), index=True, doc=docs.COMMITTEE_STATE)


class BaseConcreteCommittee(BaseCommittee):
    __tablename__ = 'ofec_committee_detail_mv'

    committee_id = db.Column(db.String, primary_key=True, unique=True, index=True, doc=docs.COMMITTEE_ID)
    candidate_ids = db.Column(ARRAY(db.Text), doc=docs.CANDIDATE_ID)


class Committee(BaseConcreteCommittee):
    __table_args__ = {'extend_existing': True}
    __tablename__ = 'ofec_committee_detail_mv'

    first_file_date = db.Column(db.Date, index=True, doc=docs.FIRST_FILE_DATE)
    last_file_date = db.Column(db.Date, doc=docs.LAST_FILE_DATE)
    last_f1_date = db.Column(db.Date, doc=docs.LAST_F1_DATE)


class CommitteeHistory(BaseCommittee):
    __tablename__ = 'ofec_committee_history_mv'

    street_1 = db.Column(db.String(50), doc=docs.COMMITTEE_STREET_1)
    street_2 = db.Column(db.String(50), doc=docs.COMMITTEE_STREET_2)
    city = db.Column(db.String(50), doc=docs.COMMITTEE_CITY)
    state_full = db.Column(db.String(50), doc=docs.COMMITTEE_STATE_FULL)
    zip = db.Column(db.String(9), doc=docs.COMMITTEE_ZIP)
    candidate_ids = db.Column(ARRAY(db.Text), doc=docs.CANDIDATE_ID)
    cycle = db.Column(db.Integer, primary_key=True, index=True, doc=docs.COMMITTEE_CYCLE)
    cycles_has_financial = db.Column(ARRAY(db.Integer), doc=docs.COMMITTEE_CYCLES_HAS_FINANCIAL)
    last_cycle_has_financial = db.Column(db.Integer, doc=docs.COMMITTEE_LAST_CYCLE_HAS_FINANCIAL)
    cycles_has_activity = db.Column(ARRAY(db.Integer), doc=docs.COMMITTEE_CYCLES_HAS_ACTIVITY)
    last_cycle_has_activity = db.Column(db.Integer, doc=docs.COMMITTEE_LAST_CYCLE_HAS_ACTIVITY)
    is_active = db.Column(db.Boolean, doc=docs.IS_COMMITTEE_ACTIVE)
    former_committee_name = db.Column(db.String(200), doc=docs.COMMITTEE_NAME)
    former_candidate_id  = db.Column(db.String(9), doc=docs.CANDIDATE_ID)
    former_candidate_name = db.Column(db.String(90), doc=docs.CANDIDATE_NAME)
    former_candidate_election_year = db.Column(db.Integer, doc=docs.CANDIDATE_ELECTION_YEAR)
    convert_to_pac_flag = db.Column(db.Boolean, doc=docs.CONVERT_TO_PAC_FLAG)


class CommitteeDetail(BaseConcreteCommittee):
    __table_args__ = {'extend_existing': True}
    __tablename__ = 'ofec_committee_detail_mv'

    first_file_date = db.Column(db.Date, doc=docs.FIRST_FILE_DATE)
    last_file_date = db.Column(db.Date, doc=docs.LAST_FILE_DATE)
    email = db.Column(db.String(50), doc=docs.COMMITTEE_EMAIL)
    fax = db.Column(db.String(10), doc=docs.COMMITTEE_FAX)
    website = db.Column(db.String(50), doc=docs.COMMITTEE_WEBSITE)
    form_type = db.Column(db.String(3), doc=docs.FORM_TYPE)
    leadership_pac = db.Column(db.String(50), doc=docs.LEADERSHIP_PAC_INDICATE)
    lobbyist_registrant_pac = db.Column(db.String(1), doc=docs.LOBBIST_REGISTRANT_PAC_INDICATE)
    party_type = db.Column(db.String(3), doc=docs.PARTY_TYPE)
    party_type_full = db.Column(db.String(15), doc=docs.PARTY_TYPE_FULL)
    street_1 = db.Column(db.String(50), doc=docs.COMMITTEE_STREET_1)
    street_2 = db.Column(db.String(50), doc=docs.COMMITTEE_STREET_2)
    city = db.Column(db.String(50), doc=docs.COMMITTEE_CITY)
    state_full = db.Column(db.String(50), doc=docs.COMMITTEE_STATE_FULL)
    zip = db.Column(db.String(9), doc=docs.COMMITTEE_ZIP)
    treasurer_city = db.Column(db.String(50), doc=docs.TREASURER_CITY)
    treasurer_name_1 = db.Column(db.String(50), doc=docs.TREASURER_NAME_1)
    treasurer_name_2 = db.Column(db.String(50), doc=docs.TREASURER_NAME_2)
    treasurer_name_middle = db.Column(db.String(50), doc=docs.TREASURER_NAME_MIDDLE)
    treasurer_name_prefix = db.Column(db.String(50), doc=docs.TREASURER_NAME_PREFIX)
    treasurer_name_suffix = db.Column(db.String(50), doc=docs.TREASURER_NAME_SUFFIX)
    treasurer_phone = db.Column(db.String(15), doc=docs.TREASURER_PHONE)
    treasurer_state = db.Column(db.String(50), doc=docs.TREASURER_STATE)
    treasurer_street_1 = db.Column(db.String(50), doc=docs.TREASURER_STREET_1)
    treasurer_street_2 = db.Column(db.String(50), doc=docs.TREASURER_STREET_2)
    treasurer_name_title = db.Column(db.String(50), doc=docs.TREASURER_NAME_TITLE)
    treasurer_zip = db.Column(db.String(9), doc=docs.TREASURER_ZIP)
    custodian_city = db.Column(db.String(50), doc=docs.CUSTODIAN_CITY)
    custodian_name_1 = db.Column(db.String(50), doc=docs.CUSTODIAN_NAME1)
    custodian_name_2 = db.Column(db.String(50), doc=docs.CUSTODIAN_NAME2)
    custodian_name_middle = db.Column(db.String(50), doc=docs.CUSTODIAN_MIDDLE_NAME)
    custodian_name_full = db.Column(db.String(100), doc=docs.CUSTODIAN_NAME_FULL)
    custodian_phone = db.Column(db.String(15), doc=docs.CUSTODIAN_PHONE)
    custodian_name_prefix = db.Column(db.String(50), doc=docs.CUSTODIAN_NAME_PREFIX)
    custodian_state = db.Column(db.String(2), doc=docs.CUSTODIAN_STATE)
    custodian_street_1 = db.Column(db.String(50), doc=docs.CUSTODIAN_STREET_1)
    custodian_street_2 = db.Column(db.String(50), doc=docs.CUSTODIAN_STREET_2)
    custodian_name_suffix = db.Column(db.String(50), doc=docs.CUSTODIAN_NAME_SUFFIX)
    custodian_name_title = db.Column(db.String(50), doc=docs.CUSTODIAN_NAME_TITLE)
    custodian_zip = db.Column(db.String(9), doc=docs.CUSTODIAN_ZIP)
