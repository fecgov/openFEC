from flask.ext.sqlalchemy import SQLAlchemy
from sqlalchemy.dialects.postgresql import ARRAY, TSVECTOR


db = SQLAlchemy()


class BaseModel(db.Model):
    __abstract__ = True
    idx = db.Column(db.Integer, primary_key=True)


class CandidateSearch(BaseModel):
    __tablename__ = 'ofec_candidate_fulltext_mv'

    id = db.Column(db.String)
    name = db.Column(db.String)
    office_sought = db.Column(db.String)
    fulltxt = db.Column(TSVECTOR)


class CommitteeSearch(BaseModel):
    __tablename__ = 'ofec_committee_fulltext_mv'

    id = db.Column(db.String)
    name = db.Column(db.String)
    fulltxt = db.Column(TSVECTOR)


class BaseCandidate(BaseModel):
    __abstract__ = True

    candidate_id = db.Column(db.String(10))
    candidate_status = db.Column(db.String(1))
    candidate_status_full = db.Column(db.String(11))
    district = db.Column(db.String(2))
    election_years = db.Column(ARRAY(db.Integer))
    cycles = db.Column(ARRAY(db.Integer))
    incumbent_challenge = db.Column(db.String(1))
    incumbent_challenge_full = db.Column(db.String(10))
    office = db.Column(db.String(1))
    office_full = db.Column(db.String(9))
    party = db.Column(db.String(3))
    party_full = db.Column(db.String(255))
    state = db.Column(db.String(2))
    name = db.Column(db.String(100))


class BaseConcreteCandidate(BaseCandidate):
    __tablename__ = 'ofec_candidate_detail_mv'

    candidate_key = db.Column(db.Integer, unique=True)


class Candidate(BaseConcreteCandidate):
    __table_args__ = {'extend_existing': True}

    active_through = db.Column(db.Integer)

    # Customize join to restrict to principal committees
    principal_committees = db.relationship(
        'Committee',
        secondary='ofec_name_linkage_mv',
        secondaryjoin='''and_(
            Committee.committee_key == ofec_name_linkage_mv.c.committee_key,
            Committee.designation == 'P',
        )''',
        order_by='desc(Committee.last_file_date)',
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
    expire_date = db.Column(db.DateTime)


class CandidateHistory(BaseCandidate):
    __tablename__ = 'ofec_candidate_history_mv'

    candidate_key = db.Column(db.Integer)
    two_year_period = db.Column(db.Integer)
    form_type = db.Column(db.String(3))
    address_city = db.Column(db.String(100))
    address_state = db.Column(db.String(2))
    address_street_1 = db.Column(db.String(200))
    address_street_2 = db.Column(db.String(200))
    address_zip = db.Column(db.String(10))
    candidate_inactive = db.Column(db.String(1))
    load_date = db.Column(db.DateTime)
    expire_date = db.Column(db.DateTime)


class BaseCommittee(BaseModel):
    __abstract__ = True

    committee_key = db.Column(db.Integer, unique=True)
    committee_id = db.Column(db.String(9))
    cycles = db.Column(ARRAY(db.Integer))
    designation = db.Column(db.String(1))
    designation_full = db.Column(db.String(25))
    treasurer_name = db.Column(db.String(100))
    organization_type = db.Column(db.String(1))
    organization_type_full = db.Column(db.String(100))
    state = db.Column(db.String(2))
    committee_type = db.Column(db.String(1))
    committee_type_full = db.Column(db.String(50))
    expire_date = db.Column(db.DateTime())
    party = db.Column(db.String(3))
    party_full = db.Column(db.String(50))
    name = db.Column(db.String(100))


class BaseConcreteCommittee(BaseCommittee):
    __tablename__ = 'ofec_committee_detail_mv'

    candidate_ids = db.Column(ARRAY(db.Text))


class Committee(BaseConcreteCommittee):
    __table_args__ = {'extend_existing': True}

    first_file_date = db.Column(db.DateTime)
    last_file_date = db.Column(db.DateTime)


class CommitteeHistory(BaseCommittee):
    __tablename__ = 'ofec_committee_history_mv'

    street_1 = db.Column(db.String(50))
    street_2 = db.Column(db.String(50))
    city = db.Column(db.String(50))
    state_full = db.Column(db.String(50))
    zip = db.Column(db.String(9))
    cycle = db.Column(db.Integer)


class CommitteeDetail(BaseConcreteCommittee):
    __table_args__ = {'extend_existing': True}

    first_file_date = db.Column(db.DateTime)
    last_file_date = db.Column(db.DateTime)
    filing_frequency = db.Column(db.String(1))
    email = db.Column(db.String(50))
    fax = db.Column(db.String(10))
    website = db.Column(db.String(50))
    form_type = db.Column(db.String(3))
    leadership_pac = db.Column(db.String(50))
    load_date = db.Column(db.DateTime())
    lobbyist_registrant_pac = db.Column(db.String(1))
    party_type = db.Column(db.String(3))
    party_type_full = db.Column(db.String(15))
    qualifying_date = db.Column(db.DateTime())
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


class CandidateCommitteeLink(BaseModel):
    __tablename__ = 'ofec_name_linkage_mv'

    linkage_key = db.Column(db.Integer)
    committee_key = db.Column(
        db.Integer,
        db.ForeignKey('ofec_committee_detail_mv.committee_key'),
    )
    candidate_key = db.Column(
        db.Integer,
        db.ForeignKey('ofec_candidate_detail_mv.candidate_key'),
    )
    committee_id = db.Column(db.String)
    candidate_id = db.Column(db.String)
    election_year = db.Column(db.Integer)
    active_through = db.Column(db.Integer)
    expire_date = db.Column(db.DateTime)
    committee_name = db.Column(db.String)
    candidate_name = db.Column(db.String)
    committee_designation = db.Column(db.String)
    committee_designation_full = db.Column(db.String)
    committee_type = db.Column(db.String)
    committee_type_full = db.Column(db.String)


class CommitteeReports(BaseModel):
    __abstract__ = True

    report_key = db.Column(db.BigInteger)
    committee_id = db.Column(db.String(10))
    cycle = db.Column(db.Integer)

    beginning_image_number = db.Column(db.BigInteger)
    cash_on_hand_beginning_period = db.Column(db.Integer)
    cash_on_hand_end_period = db.Column(db.Integer)
    coverage_end_date = db.Column(db.DateTime)
    coverage_start_date = db.Column(db.DateTime)
    debts_owed_by_committee = db.Column(db.Integer)
    debts_owed_to_committee = db.Column(db.Integer)
    end_image_number = db.Column(db.Integer)
    expire_date = db.Column(db.DateTime)
    other_disbursements_period = db.Column(db.Integer)
    other_disbursements_ytd = db.Column(db.Integer)
    other_political_committee_contributions_period = db.Column(db.Integer)
    other_political_committee_contributions_ytd = db.Column(db.Integer)
    political_party_committee_contributions_period = db.Column(db.Integer)
    political_party_committee_contributions_ytd = db.Column(db.Integer)
    individual_itemized_contributions_period = db.Column(db.Integer)
    individual_unitemized_contributions_period = db.Column(db.Integer)
    net_contributions_period = db.Column(db.Integer)
    net_operating_expenditures_period = db.Column(db.Integer)
    report_type = db.Column(db.String)
    report_type_full = db.Column(db.String)
    report_year = db.Column(db.Integer)
    total_contribution_refunds_period = db.Column(db.Integer)
    total_contribution_refunds_ytd = db.Column(db.Integer)
    refunded_individual_contributions_period = db.Column(db.Integer)
    refunded_individual_contributions_ytd = db.Column(db.Integer)
    refunded_other_political_committee_contributions_period = db.Column(db.Integer)
    refunded_other_political_committee_contributions_ytd = db.Column(db.Integer)
    refunded_political_party_committee_contributions_period = db.Column(db.Integer)
    refunded_political_party_committee_contributions_ytd = db.Column(db.Integer)
    total_contributions_period = db.Column(db.Integer)
    total_contributions_ytd = db.Column(db.Integer)
    total_disbursements_period = db.Column(db.Integer)
    total_disbursements_ytd = db.Column(db.Integer)
    total_receipts_period = db.Column(db.Integer)
    total_receipts_ytd = db.Column(db.Integer)
    offsets_to_operating_expenditures_period = db.Column(db.Integer)
    offsets_to_operating_expenditures_ytd = db.Column(db.Integer)

    @property
    def pdf_url(self):
        if self.report_year is not None and self.report_year > 1994:
            return 'http://docquery.fec.gov/pdf/{0}/{1}/{1}.pdf'.format(
                str(self.beginning_image_number)[-3:],
                self.beginning_image_number,
            )
        else:
            return None


class CommitteeReportsHouseSenate(CommitteeReports):
    __tablename__ = 'ofec_reports_house_senate_mv'

    aggregate_amount_personal_contributions_general = db.Column(db.Integer)
    aggregate_contributions_personal_funds_primary = db.Column(db.Integer)
    all_other_loans_period = db.Column(db.Integer)
    all_other_loans_ytd = db.Column(db.Integer)
    candidate_contribution_period = db.Column(db.Integer)
    candidate_contribution_ytd = db.Column(db.Integer)
    gross_receipt_authorized_committee_general = db.Column(db.Integer)
    gross_receipt_authorized_committee_primary = db.Column(db.Integer)
    gross_receipt_minus_personal_contribution_general = db.Column(db.Integer)
    gross_receipt_minus_personal_contributions_primary = db.Column(db.Integer)
    loan_repayments_candidate_loans_period = db.Column(db.Integer)
    loan_repayments_candidate_loans_ytd = db.Column(db.Integer)
    loan_repayments_other_loans_period = db.Column(db.Integer)
    loan_repayments_other_loans_ytd = db.Column(db.Integer)
    loans_made_by_candidate_period = db.Column(db.Integer)
    loans_made_by_candidate_ytd = db.Column(db.Integer)
    net_contributions_ytd = db.Column(db.Integer)
    net_operating_expenditures_ytd = db.Column(db.Integer)
    operating_expenditures_period = db.Column(db.Integer)
    operating_expenditures_ytd = db.Column(db.Integer)
    other_receipts_period = db.Column(db.Integer)
    other_receipts_ytd = db.Column(db.Integer)
    refunds_total_contributions_col_total_ytd = db.Column(db.Integer)
    subtotal_period = db.Column(db.Integer)
    total_contribution_refunds_col_total_period = db.Column(db.Integer)
    total_contributions_column_total_period = db.Column(db.Integer)
    total_individual_contributions_period = db.Column(db.Integer)
    total_individual_contributions_ytd = db.Column(db.Integer)
    total_individual_itemized_contributions_ytd = db.Column(db.Integer)
    total_individual_unitemized_contributions_ytd = db.Column(db.Integer)
    total_loan_repayments_period = db.Column(db.Integer)
    total_loan_repayments_ytd = db.Column(db.Integer)
    total_loans_period = db.Column(db.Integer)
    total_loans_ytd = db.Column(db.Integer)
    total_offsets_to_operating_expenditures_period = db.Column(db.Integer)
    total_offsets_to_operating_expenditures_ytd = db.Column(db.Integer)
    total_operating_expenditures_period = db.Column(db.Integer)
    total_operating_expenditures_ytd = db.Column(db.Integer)
    transfers_from_other_authorized_committee_period = db.Column(db.Integer)
    transfers_from_other_authorized_committee_ytd = db.Column(db.Integer)
    transfers_to_other_authorized_committee_period = db.Column(db.Integer)
    transfers_to_other_authorized_committee_ytd = db.Column(db.Integer)


class CommitteeReportsPacParty(CommitteeReports):
    __tablename__ = 'ofec_reports_pacs_parties_mv'

    all_loans_received_period = db.Column(db.Integer)
    all_loans_received_ytd = db.Column(db.Integer)
    allocated_federal_election_levin_share_period = db.Column(db.Integer)
    calendar_ytd = db.Column(db.Integer)
    cash_on_hand_beginning_calendar_ytd = db.Column(db.Integer)
    cash_on_hand_close_ytd = db.Column(db.Integer)
    coordinated_expenditures_by_party_committee_period = db.Column(db.Integer)
    coordinated_expenditures_by_party_committee_ytd = db.Column(db.Integer)
    fed_candidate_committee_contribution_refunds_ytd = db.Column(db.Integer)
    fed_candidate_committee_contributions_period = db.Column(db.Integer)
    fed_candidate_committee_contributions_ytd = db.Column(db.Integer)
    fed_candidate_contribution_refunds_period = db.Column(db.Integer)
    independent_expenditures_period = db.Column(db.Integer)
    independent_expenditures_ytd = db.Column(db.Integer)
    individual_itemized_contributions_ytd = db.Column(db.Integer)
    individual_unitemized_contributions_ytd = db.Column(db.Integer)
    loan_repayments_made_period = db.Column(db.Integer)
    loan_repayments_made_ytd = db.Column(db.Integer)
    loan_repayments_received_period = db.Column(db.Integer)
    loan_repayments_received_ytd = db.Column(db.Integer)
    loans_made_period = db.Column(db.Integer)
    loans_made_ytd = db.Column(db.Integer)
    net_contributions_period = db.Column(db.Integer)
    net_contributions_ytd = db.Column(db.Integer)
    net_operating_expenditures_period = db.Column(db.Integer)
    net_operating_expenditures_ytd = db.Column(db.Integer)
    non_allocated_fed_election_activity_period = db.Column(db.Integer)
    non_allocated_fed_election_activity_ytd = db.Column(db.Integer)
    nonfed_share_allocated_disbursements_period = db.Column(db.Integer)
    other_fed_operating_expenditures_period = db.Column(db.Integer)
    other_fed_operating_expenditures_ytd = db.Column(db.Integer)
    other_fed_receipts_period = db.Column(db.Integer)
    other_fed_receipts_ytd = db.Column(db.Integer)
    shared_fed_activity_nonfed_ytd = db.Column(db.Integer)
    shared_fed_activity_period = db.Column(db.Integer)
    shared_fed_activity_ytd = db.Column(db.Integer)
    shared_fed_operating_expenditures_period = db.Column(db.Integer)
    shared_fed_operating_expenditures_ytd = db.Column(db.Integer)
    shared_nonfed_operating_expenditures_period = db.Column(db.Integer)
    shared_nonfed_operating_expenditures_ytd = db.Column(db.Integer)
    subtotal_summary_page_period = db.Column(db.Integer)
    subtotal_summary_ytd = db.Column(db.Integer)
    total_fed_disbursements_period = db.Column(db.Integer)
    total_fed_disbursements_ytd = db.Column(db.Integer)
    total_fed_election_activity_period = db.Column(db.Integer)
    total_fed_election_activity_ytd = db.Column(db.Integer)
    total_fed_operating_expenditures_period = db.Column(db.Integer)
    total_fed_operating_expenditures_ytd = db.Column(db.Integer)
    total_fed_receipts_period = db.Column(db.Integer)
    total_fed_receipts_ytd = db.Column(db.Integer)
    total_individual_contributions = db.Column(db.Integer)
    total_individual_contributions_ytd = db.Column(db.Integer)
    total_nonfed_transfers_period = db.Column(db.Integer)
    total_nonfed_transfers_ytd = db.Column(db.Integer)
    total_operating_expenditures_period = db.Column(db.Integer)
    total_operating_expenditures_ytd = db.Column(db.Integer)
    transfers_from_affiliated_party_period = db.Column(db.Integer)
    transfers_from_affiliated_party_ytd = db.Column(db.Integer)
    transfers_from_nonfed_account_period = db.Column(db.Integer)
    transfers_from_nonfed_account_ytd = db.Column(db.Integer)
    transfers_from_nonfed_levin_period = db.Column(db.Integer)
    transfers_from_nonfed_levin_ytd = db.Column(db.Integer)
    transfers_to_affiliated_committee_period = db.Column(db.Integer)
    transfers_to_affilitated_committees_ytd = db.Column(db.Integer)


class CommitteeReportsPresidential(CommitteeReports):
    __tablename__ = 'ofec_reports_presidential_mv'

    candidate_contribution_period = db.Column(db.Integer)
    candidate_contribution_ytd = db.Column(db.Integer)
    exempt_legal_accounting_disbursement_period = db.Column(db.Integer)
    exempt_legal_accounting_disbursement_ytd = db.Column(db.Integer)
    expentiture_subject_to_limits = db.Column(db.Integer)
    federal_funds_period = db.Column(db.Integer)
    federal_funds_ytd = db.Column(db.Integer)
    fundraising_disbursements_period = db.Column(db.Integer)
    fundraising_disbursements_ytd = db.Column(db.Integer)
    individual_unitemized_contributions_ytd = db.Column(db.Integer)
    individual_itemized_contributions_ytd = db.Column(db.Integer)
    individual_contributions_period = db.Column(db.Integer)
    individual_contributions_ytd = db.Column(db.Integer)
    items_on_hand_liquidated = db.Column(db.Integer)
    loans_received_from_candidate_period = db.Column(db.Integer)
    loans_received_from_candidate_ytd = db.Column(db.Integer)
    offsets_to_fundraising_expenditures_ytd = db.Column(db.Integer)
    offsets_to_fundraising_expenditures_period = db.Column(db.Integer)
    offsets_to_legal_accounting_period = db.Column(db.Integer)
    offsets_to_legal_accounting_ytd = db.Column(db.Integer)
    operating_expenditures_period = db.Column(db.Integer)
    operating_expenditures_ytd = db.Column(db.Integer)
    other_loans_received_period = db.Column(db.Integer)
    other_loans_received_ytd = db.Column(db.Integer)
    other_receipts_period = db.Column(db.Integer)
    other_receipts_ytd = db.Column(db.Integer)
    repayments_loans_made_by_candidate_period = db.Column(db.Integer)
    repayments_loans_made_candidate_ytd = db.Column(db.Integer)
    repayments_other_loans_period = db.Column(db.Integer)
    repayments_other_loans_ytd = db.Column(db.Integer)
    subtotal_summary_period = db.Column(db.Integer)
    total_loan_repayments_made_period = db.Column(db.Integer)
    total_loan_repayments_made_ytd = db.Column(db.Integer)
    total_loans_received_period = db.Column(db.Integer)
    total_loans_received_ytd = db.Column(db.Integer)
    total_offsets_to_operating_expenditures_period = db.Column(db.Integer)
    total_offsets_to_operating_expenditures_ytd = db.Column(db.Integer)
    total_period = db.Column(db.Integer)
    total_ytd = db.Column(db.Integer)
    transfer_from_affiliated_committee_period = db.Column(db.Integer)
    transfer_from_affiliated_committee_ytd = db.Column(db.Integer)
    transfer_to_other_authorized_committee_period = db.Column(db.Integer)
    transfer_to_other_authorized_committee_ytd = db.Column(db.Integer)


class CommitteeTotals(BaseModel):
    __abstract__ = True

    committee_id = db.Column(db.String(10))
    cycle = db.Column(db.Integer, primary_key=True)
    offsets_to_operating_expenditures = db.Column(db.Integer)
    political_party_committee_contributions = db.Column(db.Integer)
    other_disbursements = db.Column(db.Integer)
    other_political_committee_contributions = db.Column(db.Integer)
    individual_itemized_contributions = db.Column(db.Integer)
    individual_unitemized_contributions = db.Column(db.Integer)
    operating_expenditures = db.Column(db.Integer)
    disbursements = db.Column(db.Integer)
    contributions = db.Column(db.Integer)
    contribution_refunds = db.Column(db.Integer)
    refunded_individual_contributions = db.Column(db.Integer)
    refunded_other_political_committee_contributions = db.Column(db.Integer)
    refunded_political_party_committee_contributions = db.Column(db.Integer)
    receipts = db.Column(db.Integer)
    coverage_start_date = db.Column(db.DateTime())
    coverage_end_date = db.Column(db.DateTime())
    net_contributions = db.Column(db.Integer)
    net_operating_expenditures = db.Column(db.Integer)


class CommitteeTotalsPacParty(CommitteeTotals):
    __tablename__ = 'ofec_totals_pacs_parties_mv'

    all_loans_received = db.Column(db.Integer)
    allocated_federal_election_levin_share = db.Column(db.Integer)
    coordinated_expenditures_by_party_committee = db.Column(db.Integer)
    fed_candidate_committee_contributions = db.Column(db.Integer)
    fed_candidate_contribution_refunds = db.Column(db.Integer)
    fed_disbursements = db.Column(db.Integer)
    fed_election_activity = db.Column(db.Integer)
    fed_operating_expenditures = db.Column(db.Integer)
    fed_receipts = db.Column(db.Integer)
    independent_expenditures = db.Column(db.Integer)
    loan_repayments_made = db.Column(db.Integer)
    loan_repayments_received = db.Column(db.Integer)
    loans_made = db.Column(db.Integer)
    non_allocated_fed_election_activity = db.Column(db.Integer)
    nonfed_transfers = db.Column(db.Integer)
    other_fed_operating_expenditures = db.Column(db.Integer)
    other_fed_receipts = db.Column(db.Integer)
    shared_fed_activity = db.Column(db.Integer)
    shared_fed_activity_nonfed = db.Column(db.Integer)
    shared_fed_operating_expenditures = db.Column(db.Integer)
    shared_nonfed_operating_expenditures = db.Column(db.Integer)
    transfers_from_affiliated_party = db.Column(db.Integer)
    transfers_from_nonfed_account = db.Column(db.Integer)
    transfers_from_nonfed_levin = db.Column(db.Integer)
    transfers_to_affiliated_committee = db.Column(db.Integer)


class CommitteeTotalsPresidential(CommitteeTotals):
    __tablename__ = 'ofec_totals_presidential_mv'

    candidate_contribution = db.Column(db.Integer)
    exempt_legal_accounting_disbursement = db.Column(db.Integer)
    federal_funds = db.Column(db.Integer)
    fundraising_disbursements = db.Column(db.Integer)
    individual_contributions = db.Column(db.Integer)
    loan_repayments_made = db.Column(db.Integer)
    loans_received = db.Column(db.Integer)
    loans_received_from_candidate = db.Column(db.Integer)
    offsets_to_fundraising_expenditures = db.Column(db.Integer)
    offsets_to_legal_accounting = db.Column(db.Integer)
    total_offsets_to_operating_expenditures = db.Column(db.Integer)
    other_loans_received = db.Column(db.Integer)
    other_receipts = db.Column(db.Integer)
    repayments_loans_made_by_candidate = db.Column(db.Integer)
    repayments_other_loans = db.Column(db.Integer)
    transfers_from_affiliated_committee = db.Column(db.Integer)
    transfers_to_other_authorized_committee = db.Column(db.Integer)


class CommitteeTotalsHouseSenate(CommitteeTotals):
    __tablename__ = 'ofec_totals_house_senate_mv'

    all_other_loans = db.Column(db.Integer)
    candidate_contribution = db.Column(db.Integer)
    individual_contributions = db.Column(db.Integer)
    loan_repayments = db.Column(db.Integer)
    loan_repayments_candidate_loans = db.Column(db.Integer)
    loan_repayments_other_loans = db.Column(db.Integer)
    loans = db.Column(db.Integer)
    loans_made_by_candidate = db.Column(db.Integer)
    other_receipts = db.Column(db.Integer)
    transfers_from_other_authorized_committee = db.Column(db.Integer)
    transfers_to_other_authorized_committee = db.Column(db.Integer)
