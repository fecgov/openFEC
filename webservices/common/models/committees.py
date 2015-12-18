from sqlalchemy.dialects.postgresql import ARRAY, TSVECTOR

from .base import db, BaseModel


class CommitteeSearch(BaseModel):
    __tablename__ = 'ofec_committee_fulltext_mv'

    id = db.Column(db.String)
    name = db.Column(db.String)
    fulltxt = db.Column(TSVECTOR)
    receipts = db.Column(db.Numeric(30, 2))


class BaseCommittee(BaseModel):
    __abstract__ = True

    committee_id = db.Column(db.String, primary_key=True, index=True)
    cycles = db.Column(ARRAY(db.Integer), index=True)
    designation = db.Column(db.String(1), index=True)
    designation_full = db.Column(db.String(25), index=True)
    treasurer_name = db.Column(db.String(100), index=True)
    treasurer_text = db.Column(TSVECTOR)
    organization_type = db.Column(db.String(1), index=True)
    organization_type_full = db.Column(db.String(100), index=True)
    state = db.Column(db.String(2), index=True)
    committee_type = db.Column(db.String(1), index=True)
    committee_type_full = db.Column(db.String(50), index=True)
    expire_date = db.Column(db.DateTime())
    party = db.Column(db.String(3), index=True)
    party_full = db.Column(db.String(50))
    name = db.Column(db.String(100), index=True)


class BaseConcreteCommittee(BaseCommittee):
    __tablename__ = 'ofec_committee_detail_mv'

    committee_id = db.Column(db.String, primary_key=True, unique=True, index=True)
    candidate_ids = db.Column(ARRAY(db.Text))


class Committee(BaseConcreteCommittee):
    __table_args__ = {'extend_existing': True}

    first_file_date = db.Column(db.Date)
    last_file_date = db.Column(db.Date)


class CommitteeHistory(BaseCommittee):
    __tablename__ = 'ofec_committee_history_mv'

    street_1 = db.Column(db.String(50))
    street_2 = db.Column(db.String(50))
    city = db.Column(db.String(50))
    state_full = db.Column(db.String(50))
    zip = db.Column(db.String(9))
    cycle = db.Column(db.Integer, primary_key=True)


class CommitteeDetail(BaseConcreteCommittee):
    __table_args__ = {'extend_existing': True}

    first_file_date = db.Column(db.Date)
    last_file_date = db.Column(db.Date)
    filing_frequency = db.Column(db.String(1))
    email = db.Column(db.String(50))
    fax = db.Column(db.String(10))
    website = db.Column(db.String(50))
    form_type = db.Column(db.String(3))
    leadership_pac = db.Column(db.String(50))
    lobbyist_registrant_pac = db.Column(db.String(1))
    party_type = db.Column(db.String(3))
    party_type_full = db.Column(db.String(15))
    qualifying_date = db.Column(db.Date())
    street_1 = db.Column(db.String(50))
    street_2 = db.Column(db.String(50))
    city = db.Column(db.String(50))
    state_full = db.Column(db.String(50))
    zip = db.Column(db.String(9))
    treasurer_city = db.Column(db.String(50))
    treasurer_name_1 = db.Column(db.String(50))
    treasurer_name_2 = db.Column(db.String(50))
    treasurer_name_middle = db.Column(db.String(50))
    treasurer_name_prefix = db.Column(db.String(50))
    treasurer_phone = db.Column(db.String(15))
    treasurer_state = db.Column(db.String(50))
    treasurer_street_1 = db.Column(db.String(50))
    treasurer_street_2 = db.Column(db.String(50))
    treasurer_name_suffix = db.Column(db.String(50))
    treasurer_name_title = db.Column(db.String(50))
    treasurer_zip = db.Column(db.String(9))
    custodian_city = db.Column(db.String(50))
    custodian_name_1 = db.Column(db.String(50))
    custodian_name_2 = db.Column(db.String(50))
    custodian_name_middle = db.Column(db.String(50))
    custodian_name_full = db.Column(db.String(100))
    custodian_phone = db.Column(db.String(15))
    custodian_name_prefix = db.Column(db.String(50))
    custodian_state = db.Column(db.String(2))
    custodian_street_1 = db.Column(db.String(50))
    custodian_street_2 = db.Column(db.String(50))
    custodian_name_suffix = db.Column(db.String(50))
    custodian_name_title = db.Column(db.String(50))
    custodian_zip = db.Column(db.String(9))
