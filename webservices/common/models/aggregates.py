from sqlalchemy.dialects.postgresql import TSVECTOR
from webservices import docs, utils

from .base import db, BaseModel


class BaseAggregate(BaseModel):
    __abstract__ = True

    committee = utils.related_committee_history('committee_id', cycle_label='cycle')
    committee_id = db.Column('cmte_id', db.String, primary_key=True, doc=docs.COMMITTEE_ID)
    cycle = db.Column(db.Integer, primary_key=True, doc=docs.RECORD_CYCLE)
    total = db.Column(db.Numeric(30, 2), index=True, doc='Sum of transactions')
    count = db.Column(db.Integer, index=True, doc=docs.COUNT)


class ScheduleABySize(BaseAggregate):
    __tablename__ = 'ofec_sched_a_aggregate_size_merged_mv'
    size = db.Column(db.Integer, primary_key=True)


class ScheduleAByState(BaseAggregate):
    __tablename__ = 'ofec_sched_a_agg_state_vw'
    state = db.Column(db.String, primary_key=True, doc=docs.STATE_GENERIC)
    state_full = db.Column(db.String, primary_key=True, doc=docs.STATE_GENERIC)


class ScheduleAByZip(BaseAggregate):
    __table_args__ = {'schema': 'disclosure'}
    __tablename__ = 'dsc_sched_a_aggregate_zip'
    zip = db.Column(db.String, primary_key=True)
    state = db.Column(db.String, doc=docs.STATE_GENERIC)
    state_full = db.Column(db.String, doc=docs.STATE_GENERIC)


class ScheduleAByEmployer(BaseAggregate):
    # __table_args__ = {'schema': 'disclosure'}
    # __tablename__ = 'dsc_sched_a_aggregate_employer'
    __tablename__ = 'ofec_sched_a_aggregate_employer_mv_tmp_jl'
    employer = db.Column(db.String, primary_key=True, doc=docs.EMPLOYER)
    employer_text = db.Column(TSVECTOR)


class ScheduleAByOccupation(BaseAggregate):
    # __table_args__ = {'schema': 'disclosure'}
    # __tablename__ = 'dsc_sched_a_aggregate_occupation'
    __tablename__ = 'ofec_sched_a_aggregate_occupation_mv_tmp_jl'
    occupation = db.Column(db.String, primary_key=True, doc=docs.OCCUPATION)
    occupation_text = db.Column(TSVECTOR)


class BaseDisbursementAggregate(BaseAggregate):
    __abstract__ = True

    total = db.Column('non_memo_total', db.Numeric(30, 2), index=True, doc=docs.NON_MEMO_TOTAL)
    count = db.Column('non_memo_count', db.Integer, index=True, doc=docs.COUNT)
    memo_total = db.Column('memo_total', db.Numeric(30, 2), index=True, doc=docs.MEMO_TOTAL)
    memo_count = db.Column('memo_count', db.Integer, index=True, doc=docs.COUNT)


class ScheduleBByRecipient(BaseDisbursementAggregate):
    __tablename__ = "ofec_sched_b_aggregate_recipient_mv"

    recipient_name = db.Column('recipient_nm', db.String, primary_key=True, doc=docs.RECIPIENT_NAME)
    committee_total_disbursements = db.Column('disbursements', db.Numeric(30, 2), index=True, doc=docs.DISBURSEMENTS)

    @property
    def recipient_disbursement_percent(self):
        numerators = [self.total]
        denominators = [self.committee_total_disbursements]
        return utils.get_percentage(numerators, denominators)


class ScheduleBByRecipientID(BaseDisbursementAggregate):
    __table_args__ = {'schema': 'disclosure'}
    __tablename__ = 'dsc_sched_b_aggregate_recipient_id_new'
    recipient_id = db.Column('recipient_cmte_id', db.String, primary_key=True, doc=docs.RECIPIENT_ID)
    committee = utils.related_committee('committee_id')
    recipient = utils.related('CommitteeHistory', 'recipient_id', 'committee_id', cycle_label='cycle')

    @property
    def committee_name(self):
        return self.committee.name

    @property
    def recipient_name(self):
        return self.recipient.name


class ScheduleBByPurpose(BaseDisbursementAggregate):
    __table_args__ = {'schema': 'disclosure'}
    __tablename__ = 'dsc_sched_b_aggregate_purpose_new'
    purpose = db.Column(db.String, primary_key=True, doc=docs.PURPOSE)


class BaseSpendingAggregate(BaseAggregate):
    __abstract__ = True
    committee_id = db.Column('cmte_id', db.String, primary_key=True, doc=docs.COMMITTEE_ID)
    committee = utils.related_committee_history('committee_id', cycle_label='cycle')
    candidate_id = db.Column('cand_id', db.String, primary_key=True, doc=docs.CANDIDATE_ID)
    candidate = utils.related_candidate_history('candidate_id', cycle_label='cycle')


class ScheduleEByCandidate(BaseSpendingAggregate):
    __tablename__ = 'ofec_sched_e_aggregate_candidate_mv'

    support_oppose_indicator = db.Column(db.String, primary_key=True, doc=docs.SUPPORT_OPPOSE_INDICATOR)


class CommunicationCostByCandidate(BaseSpendingAggregate):
    __tablename__ = 'ofec_communication_cost_aggregate_candidate_mv'
    support_oppose_indicator = db.Column(db.String, primary_key=True, doc=docs.SUPPORT_OPPOSE_INDICATOR)


class ElectioneeringByCandidate(BaseSpendingAggregate):
    __tablename__ = 'ofec_electioneering_aggregate_candidate_mv'
