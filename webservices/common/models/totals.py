from .base import db, BaseModel

from webservices import docs


class CommitteeTotals(BaseModel):
    __abstract__ = True

    committee_id = db.Column(db.String, doc=docs.COMMITTEE_ID)
    cycle = db.Column(db.Integer, primary_key=True, index=True, doc=docs.CYCLE)
    offsets_to_operating_expenditures = db.Column(db.Numeric(30, 2))
    political_party_committee_contributions = db.Column(db.Numeric(30, 2))
    other_disbursements = db.Column(db.Numeric(30, 2))
    other_political_committee_contributions = db.Column(db.Numeric(30, 2))
    individual_itemized_contributions = db.Column(db.Numeric(30, 2), doc=docs.INDIVIDUAL_ITEMIZED_CONTRIBUTIONS)
    individual_unitemized_contributions = db.Column(db.Numeric(30, 2), doc=docs.INDIVIDUAL_UNITEMIZED_CONTRIBUTIONS)
    operating_expenditures = db.Column(db.Numeric(30, 2))
    disbursements = db.Column(db.Numeric(30, 2), doc=docs.DISBURSEMENTS)
    contributions = db.Column(db.Numeric(30, 2), doc=docs.CONTRIBUTIONS)
    contribution_refunds = db.Column(db.Numeric(30, 2))
    individual_contributions = db.Column(db.Numeric(30, 2))
    refunded_individual_contributions = db.Column(db.Numeric(30, 2))
    refunded_other_political_committee_contributions = db.Column(db.Numeric(30, 2))
    refunded_political_party_committee_contributions = db.Column(db.Numeric(30, 2))
    receipts = db.Column(db.Numeric(30, 2))
    coverage_start_date = db.Column(db.DateTime(), index=True)
    coverage_end_date = db.Column(db.DateTime(), index=True)
    net_contributions = db.Column(db.Numeric(30, 2))
    net_operating_expenditures = db.Column(db.Numeric(30, 2))

    last_report_year = db.Column(db.Integer)
    last_report_type_full = db.Column(db.String)
    last_beginning_image_number = db.Column(db.BigInteger)
    last_cash_on_hand_end_period = db.Column(db.Numeric(30, 2))
    last_debts_owed_by_committee = db.Column(db.Numeric(30, 2))
    last_debts_owed_to_committee = db.Column(db.Numeric(30, 2))

class CandidateCommitteeTotals(db.Model):
    __abstract__ = True
    #making this it's own model hieararchy until can figure out
    #how to maybe use existing classes while removing primary
    #key stuff on cycle
    candidate_id = db.Column(db.String, primary_key=True, doc=docs.CANDIDATE_ID)
    cycle = db.Column(db.Integer, primary_key=True, index=True, doc=docs.CYCLE)
    offsets_to_operating_expenditures = db.Column(db.Numeric(30, 2))
    political_party_committee_contributions = db.Column(db.Numeric(30, 2))
    other_disbursements = db.Column(db.Numeric(30, 2))
    other_political_committee_contributions = db.Column(db.Numeric(30, 2))
    individual_itemized_contributions = db.Column(db.Numeric(30, 2), doc=docs.INDIVIDUAL_ITEMIZED_CONTRIBUTIONS)
    individual_unitemized_contributions = db.Column(db.Numeric(30, 2), doc=docs.INDIVIDUAL_UNITEMIZED_CONTRIBUTIONS)
    disbursements = db.Column(db.Numeric(30, 2), doc=docs.DISBURSEMENTS)
    contributions = db.Column(db.Numeric(30, 2), doc=docs.CONTRIBUTIONS)
    contribution_refunds = db.Column(db.Numeric(30, 2))
    individual_contributions = db.Column(db.Numeric(30, 2))
    refunded_individual_contributions = db.Column(db.Numeric(30, 2))
    refunded_other_political_committee_contributions = db.Column(db.Numeric(30, 2))
    refunded_political_party_committee_contributions = db.Column(db.Numeric(30, 2))
    receipts = db.Column(db.Numeric(30, 2))
    coverage_start_date = db.Column(db.DateTime(), index=True)
    coverage_end_date = db.Column(db.DateTime(), index=True)
    operating_expenditures = db.Column(db.Numeric(30, 2))


    last_report_year = db.Column(db.Integer)
    last_report_type_full = db.Column(db.String)
    last_beginning_image_number = db.Column(db.BigInteger)
    last_cash_on_hand_end_period = db.Column(db.Numeric(30, 2))
    last_debts_owed_by_committee = db.Column(db.Numeric(30, 2))
    last_debts_owed_to_committee = db.Column(db.Numeric(30, 2))


class CommitteeTotalsPacPartyBase(CommitteeTotals):
    __abstract__ = True

    all_loans_received = db.Column(db.Numeric(30, 2))
    allocated_federal_election_levin_share = db.Column(db.Numeric(30, 2))
    coordinated_expenditures_by_party_committee = db.Column(db.Numeric(30, 2))
    fed_candidate_committee_contributions = db.Column(db.Numeric(30, 2))
    fed_candidate_contribution_refunds = db.Column(db.Numeric(30, 2))
    fed_disbursements = db.Column(db.Numeric(30, 2))
    fed_election_activity = db.Column(db.Numeric(30, 2))
    fed_operating_expenditures = db.Column(db.Numeric(30, 2))
    fed_receipts = db.Column(db.Numeric(30, 2))
    independent_expenditures = db.Column(db.Numeric(30, 2))
    loan_repayments_made = db.Column(db.Numeric(30, 2))
    loan_repayments_received = db.Column(db.Numeric(30, 2))
    loans_made = db.Column(db.Numeric(30, 2))
    non_allocated_fed_election_activity = db.Column(db.Numeric(30, 2))
    total_transfers = db.Column(db.Numeric(30,2))
    other_fed_operating_expenditures = db.Column(db.Numeric(30, 2))
    other_fed_receipts = db.Column(db.Numeric(30, 2))
    shared_fed_activity = db.Column(db.Numeric(30, 2))
    shared_fed_activity_nonfed = db.Column(db.Numeric(30, 2))
    shared_fed_operating_expenditures = db.Column(db.Numeric(30, 2))
    shared_nonfed_operating_expenditures = db.Column(db.Numeric(30, 2))
    transfers_from_affiliated_party = db.Column(db.Numeric(30, 2))
    transfers_from_nonfed_account = db.Column(db.Numeric(30, 2))
    transfers_from_nonfed_levin = db.Column(db.Numeric(30, 2))
    transfers_to_affiliated_committee = db.Column(db.Numeric(30, 2))
    cash_on_hand_beginning_period = db.Column(db.Numeric(30, 2))


class CommitteeTotalsPresidential(CommitteeTotals):
    __tablename__ = 'ofec_totals_presidential_mv'

    candidate_contribution = db.Column(db.Numeric(30, 2))
    exempt_legal_accounting_disbursement = db.Column(db.Numeric(30, 2))
    federal_funds = db.Column(db.Numeric(30, 2))
    fundraising_disbursements = db.Column(db.Numeric(30, 2))
    loan_repayments_made = db.Column(db.Numeric(30, 2))
    loans_received = db.Column(db.Numeric(30, 2))
    loans_received_from_candidate = db.Column(db.Numeric(30, 2))
    offsets_to_fundraising_expenditures = db.Column(db.Numeric(30, 2))
    offsets_to_legal_accounting = db.Column(db.Numeric(30, 2))
    total_offsets_to_operating_expenditures = db.Column(db.Numeric(30, 2))
    other_loans_received = db.Column(db.Numeric(30, 2))
    other_receipts = db.Column(db.Numeric(30, 2))
    repayments_loans_made_by_candidate = db.Column(db.Numeric(30, 2))
    repayments_other_loans = db.Column(db.Numeric(30, 2))
    transfers_from_affiliated_committee = db.Column(db.Numeric(30, 2))
    transfers_to_other_authorized_committee = db.Column(db.Numeric(30, 2))
    cash_on_hand_beginning_period = db.Column(db.Numeric(30, 2))


class CandidateCommitteeTotalsPresidential(CandidateCommitteeTotals):
    __table_args__ = {'extend_existing': True}
    __tablename__ = 'ofec_totals_candidate_committees_mv'

    candidate_contribution = db.Column(db.Numeric(30, 2))
    exempt_legal_accounting_disbursement = db.Column(db.Numeric(30, 2))
    federal_funds = db.Column(db.Numeric(30, 2))
    fundraising_disbursements = db.Column(db.Numeric(30, 2))
    loan_repayments_made = db.Column(db.Numeric(30, 2))
    loans_received = db.Column(db.Numeric(30, 2))
    loans_received_from_candidate = db.Column(db.Numeric(30, 2))
    offsets_to_fundraising_expenditures = db.Column(db.Numeric(30, 2))
    offsets_to_legal_accounting = db.Column(db.Numeric(30, 2))
    total_offsets_to_operating_expenditures = db.Column(db.Numeric(30, 2))
    other_loans_received = db.Column(db.Numeric(30, 2))
    other_receipts = db.Column(db.Numeric(30, 2))
    repayments_loans_made_by_candidate = db.Column(db.Numeric(30, 2))
    repayments_other_loans = db.Column(db.Numeric(30, 2))
    transfers_from_affiliated_committee = db.Column(db.Numeric(30, 2))
    transfers_to_other_authorized_committee = db.Column(db.Numeric(30, 2))
    #cash_on_hand_beginning_of_period = db.Column(db.Numeric(30, 2))
    full_election = db.Column(db.Boolean, primary_key=True)
    net_operating_expenditures = db.Column('last_net_operating_expenditures', db.Numeric(30, 2))
    net_contributions = db.Column('last_net_contributions', db.Numeric(30, 2))


class CandidateCommitteeTotalsHouseSenate(CandidateCommitteeTotals):
    __table_args__ = {'extend_existing': True}
    __tablename__ = 'ofec_totals_candidate_committees_mv'

    all_other_loans = db.Column('other_loans_received', db.Numeric(30, 2))
    candidate_contribution = db.Column(db.Numeric(30, 2))
    loan_repayments = db.Column('loan_repayments_made', db.Numeric(30, 2))
    loan_repayments_candidate_loans = db.Column('repayments_loans_made_by_candidate', db.Numeric(30, 2))
    loan_repayments_other_loans = db.Column('repayments_other_loans', db.Numeric(30, 2))
    loans = db.Column('loans_received', db.Numeric(30,2))
    loans_made_by_candidate = db.Column('loans_received_from_candidate', db.Numeric(30, 2))
    other_receipts = db.Column(db.Numeric(30, 2))
    transfers_from_other_authorized_committee = db.Column('transfers_from_affiliated_committee', db.Numeric(30, 2))
    transfers_to_other_authorized_committee = db.Column(db.Numeric(30, 2))
    #cash_on_hand_beginning_of_period = db.Column(db.Numeric(30, 2))
    full_election = db.Column(db.Boolean, primary_key=True)
    net_operating_expenditures = db.Column(db.Numeric(30, 2))
    net_contributions = db.Column(db.Numeric(30, 2))


class CommitteeTotalsParty(CommitteeTotalsPacPartyBase):
    __tablename__ = 'ofec_totals_parties_mv'

    committee_name = db.Column(db.String)
    committee_type = db.Column(db.String)


class CommitteeTotalsPac(CommitteeTotalsPacPartyBase):
    __tablename__ = 'ofec_totals_pacs_mv'

    committee_name = db.Column(db.String)
    committee_type = db.Column(db.String)


class CommitteeTotalsPacParty(CommitteeTotalsPacPartyBase):
    __tablename__ = 'ofec_totals_pacs_parties_mv'


class CommitteeTotalsHouseSenate(CommitteeTotals):
    __tablename__ = 'ofec_totals_house_senate_mv'

    all_other_loans = db.Column(db.Numeric(30, 2))
    candidate_contribution = db.Column(db.Numeric(30, 2))
    loan_repayments = db.Column(db.Numeric(30, 2))
    loan_repayments_candidate_loans = db.Column(db.Numeric(30, 2))
    loan_repayments_other_loans = db.Column(db.Numeric(30, 2))
    loans = db.Column(db.Numeric(30, 2))
    loans_made_by_candidate = db.Column(db.Numeric(30, 2))
    other_receipts = db.Column(db.Numeric(30, 2))
    transfers_from_other_authorized_committee = db.Column(db.Numeric(30, 2))
    transfers_to_other_authorized_committee = db.Column(db.Numeric(30, 2))
    cash_on_hand_beginning_period = db.Column(db.Numeric(30, 2))


class CommitteeTotalsIEOnly(BaseModel):
    __tablename__ = 'ofec_totals_ie_only_mv'

    committee_id = db.Column(db.String, index=True, doc=docs.COMMITTEE_ID)
    cycle = db.Column(db.Integer, index=True, doc=docs.CYCLE)
    coverage_start_date = db.Column(db.DateTime, doc=docs.COVERAGE_START_DATE)
    coverage_end_date = db.Column(db.DateTime, doc=docs.COVERAGE_END_DATE)
    total_independent_contributions = db.Column(db.Numeric(30, 2))
    total_independent_expenditures = db.Column(db.Numeric(30, 2))


class ScheduleAByStateRecipientTotals(BaseModel):
    __tablename__ = 'ofec_sched_a_aggregate_state_recipient_totals_mv'

    total = db.Column(db.Numeric(30, 2), index=True, doc='The calculated total.')
    count = db.Column(db.Integer, index=True, doc='Number of records making up the total.')
    cycle = db.Column(db.Integer, index=True, doc=docs.CYCLE)
    state = db.Column(db.String, index=True, doc=docs.STATE_GENERIC)
    state_full = db.Column(db.String, index=True, doc=docs.STATE_GENERIC)
    committee_type = db.Column(db.String, index=True, doc=docs.COMMITTEE_TYPE)
    committee_type_full = db.Column(db.String, index=True, doc=docs.COMMITTEE_TYPE)


