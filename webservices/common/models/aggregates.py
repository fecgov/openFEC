from webservices import utils

from .base import db, BaseModel


class BaseAggregate(BaseModel):
    __abstract__ = True

    committee_id = db.Column('cmte_id', db.String, primary_key=True)
    cycle = db.Column(db.Integer, primary_key=True)
    total = db.Column(db.Numeric(30, 2), index=True)
    count = db.Column(db.Integer, index=True)


class ScheduleABySize(BaseAggregate):
    __tablename__ = 'ofec_sched_a_aggregate_size_merged_mv'
    size = db.Column(db.Integer, primary_key=True)


class ScheduleAByState(BaseAggregate):
    __tablename__ = 'ofec_sched_a_aggregate_state'
    state = db.Column(db.String, primary_key=True)
    state_full = db.Column(db.String, primary_key=True)


class ScheduleAByZip(BaseAggregate):
    __tablename__ = 'ofec_sched_a_aggregate_zip'
    zip = db.Column(db.String, primary_key=True)
    state = db.Column(db.String)
    state_full = db.Column(db.String)


class ScheduleAByEmployer(BaseAggregate):
    __tablename__ = 'ofec_sched_a_aggregate_employer'
    employer = db.Column(db.String, primary_key=True)


class ScheduleAByOccupation(BaseAggregate):
    __tablename__ = 'ofec_sched_a_aggregate_occupation'
    occupation = db.Column(db.String, primary_key=True)


class ScheduleBByRecipient(BaseAggregate):
    __tablename__ = 'ofec_sched_b_aggregate_recipient'
    recipient_name = db.Column('recipient_nm', db.String, primary_key=True)


class ScheduleBByRecipientID(BaseAggregate):
    __tablename__ = 'ofec_sched_b_aggregate_recipient_id'
    recipient_id = db.Column('recipient_cmte_id', db.String, primary_key=True)
    committee = utils.related_committee('committee_id')
    recipient = utils.related('CommitteeHistory', 'recipient_id', 'committee_id', cycle_label='cycle')

    @property
    def committee_name(self):
        return self.committee.name

    @property
    def recipient_name(self):
        return self.recipient.name


class ScheduleBByPurpose(BaseAggregate):
    __tablename__ = 'ofec_sched_b_aggregate_purpose'
    purpose = db.Column(db.String, primary_key=True)


class BaseSpendingAggregate(BaseAggregate):
    __abstract__ = True

    committee_id = db.Column('cmte_id', db.String, primary_key=True)
    committee = utils.related_committee('committee_id')
    candidate_id = db.Column('cand_id', db.String, primary_key=True)
    candidate = utils.related_candidate('candidate_id')


class ScheduleEByCandidate(BaseSpendingAggregate):
    __tablename__ = 'ofec_sched_e_aggregate_candidate_mv'
    support_oppose_indicator = db.Column(db.String, primary_key=True)


class CommunicationCostByCandidate(BaseSpendingAggregate):
    __tablename__ = 'ofec_communication_cost_aggregate_candidate_mv'
    support_oppose_indicator = db.Column(db.String, primary_key=True)


class ElectioneeringByCandidate(BaseSpendingAggregate):
    __tablename__ = 'ofec_electioneering_aggregate_candidate_mv'
