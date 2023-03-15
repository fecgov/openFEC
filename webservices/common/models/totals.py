from sqlalchemy.dialects.postgresql import TSVECTOR, ARRAY
from webservices import docs, utils
from .base import db, BaseModel
from sqlalchemy.ext.declarative import declared_attr


class CommitteeTotals(BaseModel):
    __abstract__ = True

    committee_id = db.Column(db.String, index=True, doc=docs.COMMITTEE_ID)
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

    # Add additional fields and filters to /totals/{committee-type} endpoint#2631
    committee_name = db.Column(db.String, doc=docs.COMMITTEE_NAME)
    committee_type = db.Column(db.String, doc=docs.COMMITTEE_TYPE)
    committee_designation = db.Column(db.String, doc=docs.DESIGNATION)
    committee_type_full = db.Column(db.String, doc=docs.COMMITTEE_TYPE)
    committee_designation_full = db.Column(db.String, doc=docs.DESIGNATION)
    party_full = db.Column(db.String, doc=docs.PARTY_FULL)

    treasurer_name = db.Column(db.String(100), index=True, doc=docs.TREASURER_NAME)
    treasurer_text = db.Column(TSVECTOR)
    committee_state = db.Column(db.String(2), index=True, doc=docs.COMMITTEE_STATE)
    filing_frequency = db.Column(db.String(1), doc=docs.FILING_FREQUENCY)
    filing_frequency_full = db.Column(db.String, doc=docs.FILING_FREQUENCY)
    first_file_date = db.Column(db.Date, index=True, doc=docs.FIRST_FILE_DATE)
    organization_type = db.Column(db.String(1), index=True, doc=docs.ORGANIZATION_TYPE)
    organization_type_full = db.Column(db.String(100), index=True, doc=docs.ORGANIZATION_TYPE)
    first_f1_date = db.Column(db.Date, index=True, doc=docs.FIRST_F1_DATE)

    @declared_attr
    def transaction_coverage(self):
        return db.relationship(
            'TransactionCoverage',
            primaryjoin='''and_(
                foreign({0}.committee_id) == TransactionCoverage.committee_id,
                {0}.cycle  == TransactionCoverage.fec_election_year,
            )'''.format(self.__name__),
            viewonly=True,
            lazy='joined',
        )


class CandidateCommitteeTotals(db.Model):
    __abstract__ = True
    # making this it's own model hieararchy until can figure out
    # how to maybe use existing classes while removing primary
    # key stuff on cycle
    candidate_id = db.Column(db.String, primary_key=True, doc=docs.CANDIDATE_ID)
    cycle = db.Column(db.Integer, primary_key=True, index=True, doc=docs.CYCLE)
    candidate_election_year = db.Column(db.Integer, primary_key=True, index=True, doc=docs.CYCLE)
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
    transaction_coverage_date = db.Column(db.DateTime())
    operating_expenditures = db.Column(db.Numeric(30, 2))

    last_report_year = db.Column(db.Integer)
    last_report_type_full = db.Column(db.String)
    last_beginning_image_number = db.Column(db.BigInteger)
    last_cash_on_hand_end_period = db.Column(db.Numeric(30, 2))
    last_debts_owed_by_committee = db.Column(db.Numeric(30, 2))
    last_debts_owed_to_committee = db.Column(db.Numeric(30, 2))


class CandidateCommitteeTotalsPresidential(CandidateCommitteeTotals):
    __table_args__ = {'extend_existing': True}
    __tablename__ = 'ofec_candidate_totals_detail_mv'

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
    election_full = db.Column(db.Boolean, primary_key=True)
    net_operating_expenditures = db.Column('last_net_operating_expenditures', db.Numeric(30, 2))
    net_contributions = db.Column('last_net_contributions', db.Numeric(30, 2))
    transaction_coverage_date = db.Column(db.DateTime())


class CandidateCommitteeTotalsHouseSenate(CandidateCommitteeTotals):
    __table_args__ = {'extend_existing': True}
    __tablename__ = 'ofec_candidate_totals_detail_mv'

    all_other_loans = db.Column('other_loans_received', db.Numeric(30, 2))
    candidate_contribution = db.Column(db.Numeric(30, 2))
    loan_repayments = db.Column('loan_repayments_made', db.Numeric(30, 2))
    loan_repayments_candidate_loans = db.Column('repayments_loans_made_by_candidate', db.Numeric(30, 2))
    loan_repayments_other_loans = db.Column('repayments_other_loans', db.Numeric(30, 2))
    loans = db.Column('loans_received', db.Numeric(30, 2))
    loans_made_by_candidate = db.Column('loans_received_from_candidate', db.Numeric(30, 2))
    other_receipts = db.Column(db.Numeric(30, 2))
    transfers_from_other_authorized_committee = db.Column('transfers_from_affiliated_committee', db.Numeric(30, 2))
    transfers_to_other_authorized_committee = db.Column(db.Numeric(30, 2))
    election_full = db.Column(db.Boolean, primary_key=True)
    net_operating_expenditures = db.Column(db.Numeric(30, 2))
    net_contributions = db.Column(db.Numeric(30, 2))


class CommitteeTotalsPacParty(CommitteeTotals):
    __tablename__ = 'ofec_totals_pac_party_vw'

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
    total_transfers = db.Column(db.Numeric(30, 2))
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
    # For Form 4
    federal_funds = db.Column(db.Numeric(30, 2))
    loans_and_loan_repayments_received = db.Column(db.Numeric(30, 2))
    loans_and_loan_repayments_made = db.Column(db.Numeric(30, 2))
    exp_subject_limits = db.Column(db.Numeric(30, 2))
    exp_prior_years_subject_limits = db.Column(db.Numeric(30, 2))
    total_exp_subject_limits = db.Column(db.Numeric(30, 2))
    refunds_relating_convention_exp = db.Column(db.Numeric(30, 2))
    itemized_refunds_relating_convention_exp = db.Column(db.Numeric(30, 2))
    unitemized_refunds_relating_convention_exp = db.Column(db.Numeric(30, 2))
    other_refunds = db.Column(db.Numeric(30, 2))
    itemized_other_refunds = db.Column(db.Numeric(30, 2))
    unitemized_other_refunds = db.Column(db.Numeric(30, 2))
    itemized_other_income = db.Column(db.Numeric(30, 2))
    unitemized_other_income = db.Column(db.Numeric(30, 2))
    convention_exp = db.Column(db.Numeric(30, 2))
    itemized_convention_exp = db.Column(db.Numeric(30, 2))
    unitemized_convention_exp = db.Column(db.Numeric(30, 2))
    itemized_other_disb = db.Column(db.Numeric(30, 2))
    unitemized_other_disb = db.Column(db.Numeric(30, 2))
    sponsor_candidate_ids = db.Column(ARRAY(db.Text), doc=docs.SPONSOR_CANDIDATE_ID)

    @property
    def individual_contributions_percent(self):
        """ Line 11(a)(iii) divided by Line 19 """
        numerators = [self.individual_contributions]
        denominators = [self.receipts]
        return utils.get_percentage(numerators, denominators)

    @property
    def party_and_other_committee_contributions_percent(self):
        """  (Line 11(b) + Line 11(c)) divided by Line 19 """
        numerators = [
            self.other_political_committee_contributions,
            self.political_party_committee_contributions,
        ]
        denominators = [self.receipts]
        return utils.get_percentage(numerators, denominators)

    @property
    def contributions_ie_and_party_expenditures_made_percent(self):
        """  (Line 23 + 24 + 25) divided by Line 31 """

        numerators = [
            self.fed_candidate_committee_contributions,
            self.independent_expenditures,
            self.coordinated_expenditures_by_party_committee,
        ]
        denominators = [self.disbursements]
        return utils.get_percentage(numerators, denominators)

    @property
    def operating_expenditures_percent(self):
        """  Line 21(c) divided by Line 31 """

        numerators = [self.operating_expenditures]
        denominators = [self.disbursements]
        return utils.get_percentage(numerators, denominators)

    sponsor_candidate_list = db.relationship(
        'PacSponsorCandidatePerCycle',
        primaryjoin='''and_(
                    foreign(PacSponsorCandidatePerCycle.committee_id) == CommitteeTotalsPacParty.committee_id,
                    PacSponsorCandidatePerCycle.cycle == CommitteeTotalsPacParty.cycle,
                )''',
        lazy='joined'
    )


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

    committee_state = db.Column(db.String(2), index=True, doc=docs.COMMITTEE_STATE)
    filing_frequency = db.Column(db.String(1), doc=docs.FILING_FREQUENCY)
    filing_frequency_full = db.Column(db.String, doc=docs.FILING_FREQUENCY)
    first_file_date = db.Column(db.Date, index=True, doc=docs.FIRST_FILE_DATE)

    transaction_coverage = db.relationship(
        'TransactionCoverage',
        primaryjoin='''and_(
            foreign(CommitteeTotalsIEOnly.committee_id) == TransactionCoverage.committee_id,
            CommitteeTotalsIEOnly.cycle  == TransactionCoverage.fec_election_year,
        )''',
        viewonly=True,
        lazy='joined',
    )


class ScheduleAByStateRecipientTotals(BaseModel):
    __tablename__ = 'ofec_sched_a_aggregate_state_recipient_totals_mv'

    total = db.Column(db.Numeric(30, 2), index=True, doc='The calculated total.')
    count = db.Column(db.Integer, index=True, doc='Number of records making up the total.')
    cycle = db.Column(db.Integer, index=True, doc=docs.CYCLE)
    state = db.Column(db.String, index=True, doc=docs.STATE_GENERIC)
    state_full = db.Column(db.String, index=True, doc=docs.STATE_GENERIC)
    committee_type = db.Column(db.String, index=True, doc=docs.COMMITTEE_TYPE)
    committee_type_full = db.Column(db.String, index=True, doc=docs.COMMITTEE_TYPE)


class CommitteeTotalsCombined(CommitteeTotals):
    __tablename__ = 'ofec_totals_combined_vw'

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
    net_operating_expenditures = db.Column('last_net_operating_expenditures', db.Numeric(30, 2))
    net_contributions = db.Column('last_net_contributions', db.Numeric(30, 2))


class CommitteeTotalsPerCycle(CommitteeTotals):
    __tablename__ = 'ofec_committee_totals_per_cycle_vw'

    idx = db.Column('sub_id', db.Integer, primary_key=True)
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
    net_operating_expenditures = db.Column('last_net_operating_expenditures', db.Numeric(30, 2))
    net_contributions = db.Column('last_net_contributions', db.Numeric(30, 2))

# used for endpoint:'/totals/inaugural_committees/by_contributor/'
class InauguralDonations(db.Model):
    __tablename__ = 'ofec_totals_inaugural_donations_mv'

    committee_id = db.Column(db.String, primary_key=True, index=True, doc=docs.COMMITTEE_ID)
    contributor_name = db.Column(db.String(100), primary_key=True, index=True, doc=docs.CONTRIBUTOR_NAME)
    cycle = db.Column(db.Numeric(4), primary_key=True, index=True, doc=docs.COMMITTEE_CYCLE)
    total_donation = db.Column(db.Numeric(30, 2))
