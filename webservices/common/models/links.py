from .base import db
from webservices import docs


class CandidateCommitteeLink(db.Model):
    __tablename__ = "ofec_cand_cmte_linkage_mv"

    linkage_id = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column(
        "cmte_id",
        db.String,
        db.ForeignKey("ofec_committee_detail_mv.committee_id"),
        doc=docs.COMMITTEE_ID,
    )
    candidate_id = db.Column(
        "cand_id",
        db.String,
        db.ForeignKey("ofec_candidate_detail_mv.candidate_id"),
        doc=docs.CANDIDATE_ID,
    )
    cand_election_year = db.Column("cand_election_yr", db.Integer, doc=docs.CANDIDATE_ELECTION_YEARS)
    fec_election_year = db.Column("fec_election_yr", db.Integer, doc=docs.FEC_CYCLES_IN_ELECTION)
    committee_designation = db.Column("cmte_dsgn", db.String, doc=docs.DESIGNATION)
    committee_type = db.Column("cmte_tp", db.String, doc=docs.COMMITTEE_TYPE)
    election_yr_to_be_included = db.Column("election_yr_to_be_included", db.Integer)


# Leadership PAC and sponsor candidate linkage
class CandidateCommitteeAlternateLink(db.Model):
    __table_args__ = {"schema": "disclosure"}
    __tablename__ = "cand_cmte_linkage_alternate"

    sub_id = db.Column(db.Integer, primary_key=True, doc=docs.SUB_ID)
    candidate_id = db.Column(
        "cand_id",
        db.String,
        db.ForeignKey("ofec_candidate_detail_mv.candidate_id"),
        doc=docs.CANDIDATE_ID,
    )
    candidate_election_year = db.Column("cand_election_yr", db.Integer, doc=docs.CANDIDATE_ELECTION_YEARS)
    fec_election_year = db.Column("fec_election_yr", db.Integer, doc=docs.FEC_CYCLES_IN_ELECTION)
    committee_id = db.Column(
        "cmte_id",
        db.String,
        db.ForeignKey("ofec_committee_detail_mv.committee_id"),
        doc=docs.COMMITTEE_ID,
    )
    committee_type = db.Column("cmte_tp", db.String, doc=docs.COMMITTEE_TYPE)
    committee_designation = db.Column("cmte_dsgn", db.String, doc=docs.DESIGNATION)
    linkage_type = db.Column(db.String)
