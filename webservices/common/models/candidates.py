from sqlalchemy.dialects.postgresql import ARRAY, TSVECTOR

from .base import db, BaseModel


class CandidateSearch(BaseModel):
    __tablename__ = 'ofec_candidate_fulltext_mv'

    id = db.Column(db.String)
    name = db.Column(db.String)
    office_sought = db.Column(db.String)
    fulltxt = db.Column(TSVECTOR)
    receipts = db.Column(db.Numeric(30, 2))


class BaseCandidate(BaseModel):
    __abstract__ = True

    candidate_status = db.Column(db.String(1), index=True)
    candidate_status_full = db.Column(db.String(11))
    district = db.Column(db.String(2), index=True)
    district_number = db.Column(db.Integer, index=True)
    election_years = db.Column(ARRAY(db.Integer), index=True)
    election_districts = db.Column(ARRAY(db.String), index=True)
    cycles = db.Column(ARRAY(db.Integer), index=True)
    incumbent_challenge = db.Column(db.String(1), index=True)
    incumbent_challenge_full = db.Column(db.String(10))
    office = db.Column(db.String(1), index=True)
    office_full = db.Column(db.String(9))
    party = db.Column(db.String(3), index=True)
    party_full = db.Column(db.String(255))
    state = db.Column(db.String(2), index=True)
    name = db.Column(db.String(100), index=True)


class BaseConcreteCandidate(BaseCandidate):
    __tablename__ = 'ofec_candidate_detail_mv'

    candidate_id = db.Column(db.String, unique=True)


class Candidate(BaseConcreteCandidate):
    __table_args__ = {'extend_existing': True}

    active_through = db.Column(db.Integer)

    # Customize join to restrict to principal committees
    principal_committees = db.relationship(
        'Committee',
        secondary='ofec_cand_cmte_linkage_mv',
        secondaryjoin='''and_(
            Committee.committee_id == ofec_cand_cmte_linkage_mv.c.cmte_id,
            ofec_cand_cmte_linkage_mv.c.cmte_dsgn == 'P',
        )''',
        order_by=(
            'desc(ofec_cand_cmte_linkage_mv.c.cand_election_yr),'
            'desc(Committee.last_file_date),'
        )
    )


class CandidateDetail(BaseConcreteCandidate):
    __table_args__ = {'extend_existing': True}

    form_type = db.Column(db.String(3))
    address_city = db.Column(db.String(100))
    address_state = db.Column(db.String(2))
    address_street_1 = db.Column(db.String(200))
    address_street_2 = db.Column(db.String(200))
    address_zip = db.Column(db.String(10))
    candidate_inactive = db.Column(db.String(1))
    active_through = db.Column(db.Integer)
    load_date = db.Column(db.DateTime)
    expire_date = db.Column(db.DateTime, index=True)


class CandidateHistory(BaseCandidate):
    __tablename__ = 'ofec_candidate_history_mv'

    candidate_id = db.Column(db.String, primary_key=True)
    two_year_period = db.Column(db.Integer, primary_key=True, index=True)
    form_type = db.Column(db.String(3))
    address_city = db.Column(db.String(100))
    address_state = db.Column(db.String(2))
    address_street_1 = db.Column(db.String(200))
    address_street_2 = db.Column(db.String(200))
    address_zip = db.Column(db.String(10))
    candidate_inactive = db.Column(db.String(1))
    load_date = db.Column(db.DateTime)
    expire_date = db.Column(db.DateTime, index=True)
