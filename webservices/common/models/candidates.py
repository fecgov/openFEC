import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import ARRAY, TSVECTOR
from sqlalchemy.ext.declarative import declared_attr

from webservices import docs

from .base import db, BaseModel


class CandidateSearch(BaseModel):
    __tablename__ = "ofec_candidate_fulltext_mv"

    id = db.Column(db.String)
    name = db.Column(db.String, doc=docs.CANDIDATE_NAME)
    office_sought = db.Column(db.String, doc=docs.OFFICE)
    fulltxt = db.Column(TSVECTOR)
    receipts = db.Column(db.Numeric(30, 2))
    disbursements = db.Column(db.Numeric(30, 2))
    total_activity = db.Column(db.Numeric(30, 2))


class CandidateFlags(db.Model):
    __tablename__ = "ofec_candidate_flag_mv"

    candidate_id = db.Column(
        db.String, index=True, primary_key=True, doc=docs.CANDIDATE_ID
    )
    federal_funds_flag = db.Column(db.Boolean, index=True, doc=docs.FEDERAL_FUNDS_FLAG)
    has_raised_funds = db.Column(db.Boolean, index=True, doc=docs.HAS_RAISED_FUNDS)


class BaseCandidate(BaseModel):
    __abstract__ = True

    name = db.Column(db.String(100), index=True, doc=docs.CANDIDATE_NAME)
    office = db.Column(db.String(1), index=True, doc=docs.OFFICE)
    office_full = db.Column(db.String(9), doc=docs.OFFICE_FULL)
    party = db.Column(db.String(3), index=True, doc=docs.PARTY)
    party_full = db.Column(db.String(255), doc=docs.PARTY_FULL)
    state = db.Column(db.String(2), index=True, doc=docs.STATE)
    district = db.Column(db.String(2), index=True, doc=docs.DISTRICT)
    # ? difference between district and district_number
    district_number = db.Column(db.Integer, index=True, doc=docs.CANDIDATE_STATUS)
    election_districts = db.Column(ARRAY(db.String), index=True, doc=docs.DISTRICT)
    election_years = db.Column(
        ARRAY(db.Integer), index=True, doc=docs.CANDIDATE_ELECTION_YEARS
    )
    cycles = db.Column(ARRAY(db.Integer), index=True, doc=docs.CANDIDATE_CYCLE)
    candidate_status = db.Column(db.String(1), index=True, doc=docs.CANDIDATE_STATUS)
    incumbent_challenge = db.Column(
        db.String(1), index=True, doc=docs.INCUMBENT_CHALLENGE
    )
    incumbent_challenge_full = db.Column(
        db.String(10), doc=docs.INCUMBENT_CHALLENGE_FULL
    )
    load_date = db.Column(db.DateTime, index=True, doc=docs.LOAD_DATE)

    first_file_date = db.Column(db.Date, index=True, doc=docs.FIRST_CANDIDATE_FILE_DATE)
    last_file_date = db.Column(db.Date, doc=docs.LAST_CANDIDATE_FILE_DATE)
    last_f2_date = db.Column(db.Date, doc=docs.LAST_F2_DATE)

    @declared_attr
    def flags(self):
        return sa.orm.relationship(
            CandidateFlags,
            primaryjoin=sa.orm.foreign(CandidateFlags.candidate_id)
            == self.candidate_id,
            uselist=False,
        )


class BaseConcreteCandidate(BaseCandidate):
    __tablename__ = "ofec_candidate_detail_mv"

    candidate_id = db.Column(db.String, unique=True, doc=docs.CANDIDATE_ID)


class Candidate(BaseConcreteCandidate):
    __table_args__ = {"extend_existing": True}
    __tablename__ = "ofec_candidate_detail_mv"

    active_through = db.Column(db.Integer, doc=docs.ACTIVE_THROUGH)
    candidate_inactive = db.Column(db.Boolean, doc=docs.ACTIVE_CANDIDATE)
    inactive_election_years = db.Column(
        ARRAY(db.Integer), index=True, doc="inactive years"
    )

    # Customize join to restrict to principal committees
    principal_committees = db.relationship(
        "Committee",
        secondary="ofec_cand_cmte_linkage_mv",
        secondaryjoin="""and_(
            Committee.committee_id == ofec_cand_cmte_linkage_mv.c.cmte_id,
            ofec_cand_cmte_linkage_mv.c.cmte_dsgn == 'P',
        )""",
        order_by=(
            "desc(ofec_cand_cmte_linkage_mv.c.cand_election_yr),"
            "desc(Committee.last_file_date),"
        ),
    )


class CandidateDetail(BaseConcreteCandidate):
    __table_args__ = {"extend_existing": True}
    __tablename__ = "ofec_candidate_detail_mv"

    address_city = db.Column(
        db.String(100), doc="City of candidate's address, as reported on their Form 2."
    )
    address_state = db.Column(
        db.String(2), doc="State of candidate's address, as reported on their Form 2."
    )
    address_street_1 = db.Column(
        db.String(200),
        doc="Street of candidate's address, as reported on their Form 2.",
    )
    address_street_2 = db.Column(
        db.String(200),
        doc="Additional street information of candidate's address, as reported on their Form 2.",
    )
    address_zip = db.Column(
        db.String(10),
        doc="Zip code of candidate's address, as reported on their Form 2.",
    )
    candidate_inactive = db.Column(
        db.Boolean, doc="True indicates that a candidate is inactive."
    )
    active_through = db.Column(db.Integer, doc=docs.ACTIVE_THROUGH)


class CandidateHistory(BaseCandidate):
    __tablename__ = "ofec_candidate_history_mv"

    candidate_id = db.Column(
        db.String, primary_key=True, index=True, doc=docs.CANDIDATE_ID
    )
    two_year_period = db.Column(
        db.Integer, primary_key=True, index=True, doc=docs.CANDIDATE_CYCLE
    )
    candidate_election_year = db.Column(
        db.Integer, doc=docs.LAST_CANDIDATE_ELECTION_YEAR
    )
    address_city = db.Column(db.String(100), doc=docs.F2_CANDIDATE_CITY)
    address_state = db.Column(db.String(2), doc=docs.F2_CANDIDATE_STATE)
    address_street_1 = db.Column(db.String(200), doc=docs.F2_CANDIDATE_STREET_1)
    address_street_2 = db.Column(db.String(200), doc=docs.F2_CANDIDATE_STREET_2)
    address_zip = db.Column(db.String(10), doc=docs.F2_CANDIDATE_ZIP)
    candidate_inactive = db.Column(db.Boolean, doc=docs.CANDIDATE_INACTIVE)
    active_through = db.Column(db.Integer, doc=docs.ACTIVE_THROUGH)
    rounded_election_years = db.Column(
        ARRAY(db.Integer), index=True, doc=docs.ROUNDED_ELECTION_YEARS
    )
    fec_cycles_in_election = db.Column(
        ARRAY(db.Integer), index=True, doc=docs.FEC_CYCLES_IN_ELECTION
    )


class CandidateHistoryWithFuture(BaseCandidate):
    __tablename__ = "ofec_candidate_history_with_future_election_mv"

    candidate_id = db.Column(
        db.String, primary_key=True, index=True, doc=docs.CANDIDATE_ID
    )
    two_year_period = db.Column(
        db.Integer, primary_key=True, index=True, doc=docs.CANDIDATE_CYCLE
    )
    candidate_election_year = db.Column(
        db.Integer, doc=docs.LAST_CANDIDATE_ELECTION_YEAR
    )
    address_city = db.Column(db.String(100), doc=docs.F2_CANDIDATE_CITY)
    address_state = db.Column(db.String(2), doc=docs.F2_CANDIDATE_STATE)
    address_street_1 = db.Column(db.String(200), doc=docs.F2_CANDIDATE_STREET_1)
    address_street_2 = db.Column(db.String(200), doc=docs.F2_CANDIDATE_STREET_2)
    address_zip = db.Column(db.String(10), doc=docs.F2_CANDIDATE_ZIP)
    candidate_inactive = db.Column(db.Boolean, doc=docs.CANDIDATE_INACTIVE)
    active_through = db.Column(db.Integer, doc=docs.ACTIVE_THROUGH)


class CandidateTotal(db.Model):
    __tablename__ = "ofec_candidate_totals_mv"
    candidate_id = db.Column(db.String, index=True, primary_key=True)
    election_year = db.Column(
        db.Integer, index=True, primary_key=True, autoincrement=True
    )
    cycle = db.Column(db.Integer, index=True, primary_key=True)
    is_election = db.Column(db.Boolean, index=True, primary_key=True)
    receipts = db.Column(db.Numeric(30, 2), index=True)
    disbursements = db.Column(db.Numeric(30, 2), index=True)
    cash_on_hand_end_period = db.Column(db.Numeric(30, 2))
    debts_owed_by_committee = db.Column(db.Numeric(30, 2))
    coverage_start_date = db.Column(db.Date, doc=docs.COVERAGE_START_DATE)
    coverage_end_date = db.Column(db.Date, doc=docs.COVERAGE_END_DATE)
    federal_funds_flag = db.Column(db.Boolean, index=True, doc=docs.FEDERAL_FUNDS_FLAG)
    has_raised_funds = db.Column(db.Boolean, index=True, doc=docs.HAS_RAISED_FUNDS)
    party = db.Column(db.String(3), index=True, doc=docs.PARTY)
    office = db.Column(db.String(1), index=True, doc=docs.OFFICE)
    candidate_inactive = db.Column(db.Boolean, doc=docs.CANDIDATE_INACTIVE)


class CandidateElection(db.Model):
    __tablename__ = "ofec_candidate_election_mv"

    candidate_id = db.Column(
        db.String, primary_key=True, index=True, doc=docs.CANDIDATE_ID
    )
    cand_election_year = db.Column(
        db.Integer, primary_key=True, index=True, doc=docs.CANDIDATE_ELECTION_YEAR
    )
    prev_election_year = db.Column(db.Integer, index=True)


class PacSponsorCandidate(db.Model):
    __tablename__ = "ofec_pac_sponsor_candidate_vw"

    idx = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column(db.String, doc=docs.COMMITTEE_ID)
    sponsor_candidate_id = db.Column(db.String, doc=docs.CANDIDATE_ID)
    sponsor_candidate_name = db.Column(db.String(100), doc=docs.CANDIDATE_NAME)


class PacSponsorCandidatePerCycle(db.Model):
    __tablename__ = "ofec_pac_sponsor_candidate_per_cycle_vw"

    idx = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column(db.String, doc=docs.COMMITTEE_ID)
    cycle = db.Column(db.Integer)
    sponsor_candidate_id = db.Column(db.String, doc=docs.CANDIDATE_ID)
    sponsor_candidate_name = db.Column(db.String(100), doc=docs.CANDIDATE_NAME)
