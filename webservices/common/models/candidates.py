from sqlalchemy.dialects.postgresql import ARRAY, TSVECTOR

from webservices import docs

from .base import db, BaseModel


class CandidateSearch(BaseModel):
    __tablename__ = 'ofec_candidate_fulltext'

    id = db.Column(db.String)
    name = db.Column(db.String, doc=docs.CANDIDATE_NAME)
    office_sought = db.Column(db.String, doc=docs.OFFICE)
    fulltxt = db.Column(TSVECTOR)
    receipts = db.Column(db.Numeric(30, 2))


class BaseCandidate(BaseModel):
    __abstract__ = True

    load_date = db.Column(db.Date, index=True, doc=docs.LOAD_DATE)
    candidate_status = db.Column(db.String(1), index=True, doc=docs.CANDIDATE_STATUS)
    # ? difference between district and district_number
    district = db.Column(db.String(2), index=True, doc=docs.DISTRICT)
    district_number = db.Column(db.Integer, index=True, doc=docs.CANDIDATE_STATUS)
    election_years = db.Column(ARRAY(db.Integer), index=True, doc='Years in which a candidate ran for office.')
    election_districts = db.Column(ARRAY(db.String), index=True, doc=docs.DISTRICT)
    cycles = db.Column(ARRAY(db.Integer), index=True, doc=docs.CANDIDATE_CYCLE)
    incumbent_challenge = db.Column(db.String(1), index=True, doc=docs.INCUMBENT_CHALLENGE)
    incumbent_challenge_full = db.Column(db.String(10), doc=docs.INCUMBENT_CHALLENGE_FULL)
    office = db.Column(db.String(1), index=True, doc=docs.OFFICE)
    office_full = db.Column(db.String(9), doc=docs.OFFICE_FULL)
    party = db.Column(db.String(3), index=True, doc=docs.PARTY)
    party_full = db.Column(db.String(255), doc=docs.PARTY_FULL)
    state = db.Column(db.String(2), index=True, doc=docs.STATE)
    name = db.Column(db.String(100), index=True, doc=docs.CANDIDATE_NAME)


class BaseConcreteCandidate(BaseCandidate):
    __tablename__ = 'ofec_candidate_detail'

    candidate_id = db.Column(db.String, unique=True, doc=docs.CANDIDATE_ID)


class Candidate(BaseConcreteCandidate):
    __table_args__ = {'extend_existing': True}

    active_through = db.Column(db.Integer, doc=docs.ACTIVE_THROUGH)

    # Customize join to restrict to principal committees
    principal_committees = db.relationship(
        'Committee',
        secondary='ofec_cand_cmte_linkage',
        secondaryjoin='''and_(
            Committee.committee_id == ofec_cand_cmte_linkage.c.cmte_id,
            ofec_cand_cmte_linkage.c.cmte_dsgn == 'P',
        )''',
        order_by=(
            'desc(ofec_cand_cmte_linkage.c.cand_election_yr),'
            'desc(Committee.last_file_date),'
        )
    )


class CandidateDetail(BaseConcreteCandidate):
    __table_args__ = {'extend_existing': True}

    address_city = db.Column(db.String(100), doc='City of candidate\'s address, as reported on their Form 2.')
    address_state = db.Column(db.String(2), doc='State of candidate\'s address, as reported on their Form 2.')
    address_street_1 = db.Column(db.String(200), doc='Street of candidate\'s address, as reported on their Form 2.')
    address_street_2 = db.Column(db.String(200), doc='Additional street information of candidate\'s address, as reported on their Form 2.')
    address_zip = db.Column(db.String(10), doc='Zip code of candidate\'s address, as reported on their Form 2.')
    candidate_inactive = db.Column(db.Boolean, doc='True indicates that a candidate is inactive.')
    active_through = db.Column(db.Integer, doc=docs.ACTIVE_THROUGH)


class CandidateHistory(BaseCandidate):
    __tablename__ = 'ofec_candidate_history'

    candidate_id = db.Column(db.String, primary_key=True, index=True, doc=docs.CANDIDATE_ID)
    two_year_period = db.Column(db.Integer, primary_key=True, index=True, doc=docs.CANDIDATE_CYCLE)
    address_city = db.Column(db.String(100), doc='City of candidate\'s address, as reported on their Form 2.')
    address_state = db.Column(db.String(2), doc='State of candidate\'s address, as reported on their Form 2.')
    address_street_1 = db.Column(db.String(200), doc='Street of candidate\'s address, as reported on their Form 2.')
    address_street_2 = db.Column(db.String(200), doc='Additional street information of candidate\'s address, as reported on their Form 2.')
    address_zip = db.Column(db.String(10), doc='Zip code of candidate\'s address, as reported on their Form 2.')
    candidate_inactive = db.Column(db.Boolean, doc='True indicates that a candidate is inactive.')


class CandidateElection(db.Model):
    __tablename__ = 'ofec_candidate_election'

    candidate_id = db.Column(db.String, primary_key=True, index=True, doc=docs.CANDIDATE_ID)
    cand_election_year = db.Column(db.Integer, primary_key=True, index=True, doc='Year a candidate runs for federal office.')
    prev_election_year = db.Column(db.Integer, index=True)


class CandidateHistoryLatest(BaseCandidate):
    __tablename__ = 'ofec_candidate_history_latest'

    candidate_id = db.Column(db.String, primary_key=True, index=True)
    two_year_period = db.Column(db.Integer, primary_key=True, index=True)
    cand_election_year = db.Column(db.Integer, index=True)
    address_city = db.Column(db.String(100))
    address_state = db.Column(db.String(2))
    address_street_1 = db.Column(db.String(200))
    address_street_2 = db.Column(db.String(200))
    address_zip = db.Column(db.String(10))
    candidate_inactive = db.Column(db.Boolean)


class CandidateTotal(db.Model):
    __tablename__ = 'ofec_candidate_totals'
    candidate_id = db.Column(db.String, index=True, primary_key=True)
    election_year = db.Column(db.Integer, index=True, primary_key=True)
    cycle = db.Column(db.Integer, index=True, primary_key=True)
    is_election = db.Column(db.Boolean, index=True, primary_key=True)
    receipts = db.Column(db.Numeric(30, 2), index=True)
    disbursements = db.Column(db.Numeric(30, 2), index=True)
    cash_on_hand_end_period = db.Column(db.Numeric(30, 2))
    debts_owed_by_committee = db.Column(db.Numeric(30, 2))
