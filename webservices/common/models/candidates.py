from sqlalchemy.dialects.postgresql import ARRAY, TSVECTOR

from webservices import docs

from .base import db, BaseModel


class CandidateSearch(BaseModel):
    __tablename__ = 'ofec_candidate_fulltext_mv'

    id = db.Column(db.String)
    name = db.Column(db.String, description=docs.CANDIDATE_NAME)
    office_sought = db.Column(db.String, description=docs.OFFICE_SOUGHT)
    fulltxt = db.Column(TSVECTOR)
    receipts = db.Column(db.Numeric(30, 2))


class BaseCandidate(BaseModel):
    __abstract__ = True

    load_date = db.Column(db.Date, index=True, description=docs.LOAD_DATE)
    candidate_status = db.Column(db.String(1), index=True, description=docs.CANDIDATE_STATUS)
    # ? difference between district and district_number
    district = db.Column(db.String(2), index=True, description=docs.DISTRICT)
    district_number = db.Column(db.Integer, index=True, description=docs.CANDIDATE_STATUS)
    election_years = db.Column(ARRAY(db.Integer), index=True, description='Years in which a candidate ran for office.')
    election_districts = db.Column(ARRAY(db.String), index=True, description=docs.DISTRICT)
    cycles = db.Column(ARRAY(db.Integer), index=True, description=docs.CANDIDATE_CYCLE)
    incumbent_challenge = db.Column(db.String(1), index=True, description=docs.INCUMBENT_CHALLENGE)
    incumbent_challenge_full = db.Column(db.String(10), description=docs.INCUMBENT_CHALLENGE_FULL)
    office = db.Column(db.String(1), index=True, description=docs.OFFICE)
    office_full = db.Column(db.String(9), description=docs.OFFICE_FULL)
    party = db.Column(db.String(3), index=True, description=docs.PARTY)
    party_full = db.Column(db.String(255), description=docs.PARTY_FULL)
    state = db.Column(db.String(2), index=True, description=docs.STATE)
    name = db.Column(db.String(100), index=True, description=docs.CANDIDATE_NAME)


class BaseConcreteCandidate(BaseCandidate):
    __tablename__ = 'ofec_candidate_detail_mv'

    candidate_id = db.Column(db.String, unique=True, description=docs.CANDIDATE_ID)


class Candidate(BaseConcreteCandidate):
    __table_args__ = {'extend_existing': True}

    active_through = db.Column(db.Integer, description=docs.ACTIVE_THROUGH)

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

    address_city = db.Column(db.String(100), description='City of candidate\'s address, as reported on their Form 2.')
    address_state = db.Column(db.String(2), description='State of candidate\'s address, as reported on their Form 2.')
    address_street_1 = db.Column(db.String(200), description='Street of candidate\'s address, as reported on their Form 2.')
    address_street_2 = db.Column(db.String(200), description='Additional street information of candidate\'s address, as reported on their Form 2.')
    address_zip = db.Column(db.String(10), description='Zip code of candidate\'s address, as reported on their Form 2.')
    candidate_inactive = db.Column(db.Boolean, description='True indicates that a candidate is inactive.')
    active_through = db.Column(db.Integer, description=docs.ACTIVE_THROUGH)


class CandidateHistory(BaseCandidate):
    __tablename__ = 'ofec_candidate_history_mv'

    candidate_id = db.Column(db.String, primary_key=True, index=True, description=docs.CANDIDATE_ID)
    two_year_period = db.Column(db.Integer, primary_key=True, index=True, description=docs.CANDIDATE_CYCLE)
    address_city = db.Column(db.String(100), description='City of candidate\'s address, as reported on their Form 2.')
    address_state = db.Column(db.String(2), description='State of candidate\'s address, as reported on their Form 2.')
    address_street_1 = db.Column(db.String(200), description='Street of candidate\'s address, as reported on their Form 2.')
    address_street_2 = db.Column(db.String(200), description='Additional street information of candidate\'s address, as reported on their Form 2.')
    address_zip = db.Column(db.String(10), description='Zip code of candidate\'s address, as reported on their Form 2.')
    candidate_inactive = db.Column(db.Boolean, description='True indicates that a candidate is inactive.')


class CandidateElection(BaseModel):
    __tablename__ = 'ofec_candidate_election_mv'

    candidate_id = db.Column(db.String, primary_key=True, index=True, description=docs.CANDIDATE_ID)
    cand_election_year = db.Column(db.Integer, primary_key=True, index=True, description="Year a candidate runs for federal office.")
