from webservices import docs, utils

from .base import db, BaseModel


class PdfMixin(object):

    @property
    def pdf_url(self):
        if self.has_pdf:
            return utils.make_report_pdf_url(self.beginning_image_number)
        return None

    @property
    def has_pdf(self):
        return self.report_year and self.report_year >= 1993


class CommitteeReports(PdfMixin, BaseModel):
    __abstract__ = True

    committee_id = db.Column(db.String, index=True, doc=docs.COMMITTEE_ID)
    committee = utils.related('CommitteeHistory', 'committee_id', 'committee_id', 'report_year', 'cycle')
    cycle = db.Column(db.Integer, index=True, doc=docs.CYCLE)
    beginning_image_number = db.Column(db.BigInteger, doc=docs.BEGINNING_IMAGE_NUMBER)
    cash_on_hand_beginning_period = db.Column(db.Integer, doc=docs.CASH_ON_HAND_BEGIN_PERIOD)
    cash_on_hand_end_period = db.Column(db.Integer, doc=docs.CASH_ON_HAND_END_PERIOD)
    coverage_end_date = db.Column(db.DateTime, index=True, doc=docs.COVERAGE_END_DATE)
    coverage_start_date = db.Column(db.DateTime, index=True, doc=docs.COVERAGE_START_DATE)
    debts_owed_by_committee = db.Column(db.Integer, doc=docs.DEBTS_OWED_BY_COMMITTEE)
    debts_owed_to_committee = db.Column(db.Integer, doc=docs.DEBTS_OWED_TO_COMMITTEE)
    end_image_number = db.Column(db.BigInteger, doc=docs.ENDING_IMAGE_NUMBER)
    expire_date = db.Column(db.DateTime)
    other_disbursements_period = db.Column(db.Integer, doc=docs.add_period(docs.OTHER_DISBURSEMENTS))
    other_disbursements_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.OTHER_DISBURSEMENTS))
    other_political_committee_contributions_period = db.Column(db.Integer, doc=docs.add_period(docs.OTHER_POLITICAL_COMMITTEE_CONTRIBUTIONS))
    other_political_committee_contributions_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.OTHER_POLITICAL_COMMITTEE_CONTRIBUTIONS))
    political_party_committee_contributions_period = db.Column(db.Integer, doc=docs.POLITICAL_PARTY_COMMITTEE_CONTRIBUTIONS)
    political_party_committee_contributions_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.POLITICAL_PARTY_COMMITTEE_CONTRIBUTIONS))
    report_type = db.Column(db.String, doc=docs.REPORT_TYPE)
    report_type_full = db.Column(db.String, doc=docs.REPORT_TYPE)
    report_year = db.Column(db.Integer, doc=docs.REPORT_YEAR)
    total_contribution_refunds_period = db.Column(db.Integer, doc=docs.add_period(docs.CONTRIBUTION_REFUNDS))
    total_contribution_refunds_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.CONTRIBUTION_REFUNDS))
    refunded_individual_contributions_period = db.Column(db.Integer, doc=docs.add_period(docs.REFUNDED_INDIVIDUAL_CONTRIBUTIONS))
    refunded_individual_contributions_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.REFUNDED_INDIVIDUAL_CONTRIBUTIONS))
    refunded_other_political_committee_contributions_period = db.Column(db.Integer, doc=docs.add_period(docs.REFUNDED_OTHER_POLITICAL_COMMITTEE_CONTRIBUTIONS))
    refunded_other_political_committee_contributions_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.REFUNDED_OTHER_POLITICAL_COMMITTEE_CONTRIBUTIONS))
    refunded_political_party_committee_contributions_period = db.Column(db.Integer,  doc=docs.add_period(docs.REFUNDED_POLITICAL_PARTY_COMMITTEE_CONTRIBUTIONS))
    refunded_political_party_committee_contributions_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.REFUNDED_POLITICAL_PARTY_COMMITTEE_CONTRIBUTIONS))
    total_contributions_period = db.Column(db.Integer, doc=docs.add_period(docs.CONTRIBUTIONS))
    total_contributions_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.CONTRIBUTIONS))
    total_disbursements_period = db.Column(db.Integer, doc=docs.add_period(docs.DISBURSEMENTS))
    total_disbursements_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.DISBURSEMENTS))
    total_receipts_period = db.Column(db.Integer, doc=docs.add_period(docs.RECEIPTS))
    total_receipts_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.RECEIPTS))
    offsets_to_operating_expenditures_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.OFFSETS_TO_OPERATING_EXPENDITURES))
    offsets_to_operating_expenditures_period = db.Column(db.Integer, doc=docs.add_period(docs.OFFSETS_TO_OPERATING_EXPENDITURES))
    total_individual_contributions_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.INDIVIDUAL_CONTRIBUTIONS))
    total_individual_contributions_period = db.Column(db.Integer, doc=docs.add_period(docs.INDIVIDUAL_CONTRIBUTIONS))
    individual_unitemized_contributions_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.INDIVIDUAL_UNITEMIZED_CONTRIBUTIONS))
    individual_unitemized_contributions_period = db.Column(db.Integer, doc=docs.add_period(docs.INDIVIDUAL_UNITEMIZED_CONTRIBUTIONS))
    individual_itemized_contributions_ytd = db.Column(db.Integer, doc=docs.add_ytd(docs.INDIVIDUAL_ITEMIZED_CONTRIBUTIONS))
    individual_itemized_contributions_period = db.Column(db.Integer, doc=docs.add_period(docs.INDIVIDUAL_ITEMIZED_CONTRIBUTIONS))


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
    net_contributions_period = db.Column(db.Integer, index=True)
    net_operating_expenditures_period = db.Column(db.Integer)
    operating_expenditures_period = db.Column(db.Integer)
    operating_expenditures_ytd = db.Column(db.Integer)
    other_receipts_period = db.Column(db.Integer)
    other_receipts_ytd = db.Column(db.Integer)
    refunds_total_contributions_col_total_ytd = db.Column(db.Integer)
    subtotal_period = db.Column(db.Integer)
    total_contribution_refunds_col_total_period = db.Column(db.Integer)
    total_contributions_column_total_period = db.Column(db.Integer)
    total_loan_repayments_made_period = db.Column(db.Integer)
    total_loan_repayments_made_ytd = db.Column(db.Integer)
    total_loans_received_period = db.Column(db.Integer)
    total_loans_received_ytd = db.Column(db.Integer)
    total_offsets_to_operating_expenditures_period = db.Column(db.Integer)
    total_offsets_to_operating_expenditures_ytd = db.Column(db.Integer)
    total_operating_expenditures_period = db.Column(db.Integer)
    total_operating_expenditures_ytd = db.Column(db.Integer)
    transfers_from_other_authorized_committee_period = db.Column(db.Integer)
    transfers_from_other_authorized_committee_ytd = db.Column(db.Integer)
    transfers_to_other_authorized_committee_period = db.Column(db.Integer)
    transfers_to_other_authorized_committee_ytd = db.Column(db.Integer)
    report_form = 'Form 3'

    @property
    def has_pdf(self):
        committee = self.committee
        return (
            self.report_year and committee and
            (
                committee.committee_type == 'H' and self.report_year >= 1996 or
                committee.committee_type == 'S' and self.report_year >= 2000
            )
        )


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
    loan_repayments_made_period = db.Column(db.Integer)
    loan_repayments_made_ytd = db.Column(db.Integer)
    loan_repayments_received_period = db.Column(db.Integer)
    loan_repayments_received_ytd = db.Column(db.Integer)
    loans_made_period = db.Column(db.Integer)
    loans_made_ytd = db.Column(db.Integer)
    net_contributions_period = db.Column(db.Integer, index=True)
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
    report_form = 'Form 3X'


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
    transfers_from_affiliated_committee_period = db.Column(db.Integer)
    transfers_from_affiliated_committee_ytd = db.Column(db.Integer)
    transfers_to_other_authorized_committee_period = db.Column(db.Integer)
    transfers_to_other_authorized_committee_ytd = db.Column(db.Integer)
    net_contributions_cycle_to_date = db.Column(db.Numeric(30, 2))
    net_operating_expenditures_cycle_to_date = db.Column(db.Numeric(30, 2))
    report_form = 'Form 3P'


class CommitteeReportsIEOnly(PdfMixin, BaseModel):
    __tablename__ = 'ofec_reports_ie_only_mv'

    expire_date = db.Column(db.DateTime)
    beginning_image_number = db.Column(db.BigInteger)
    committee_id = db.Column(db.String)
    cycle = db.Column(db.Integer)
    coverage_start_date = db.Column(db.DateTime(), index=True)
    coverage_end_date = db.Column(db.DateTime(), index=True)
    election_type = db.Column(db.String)
    election_type_full = db.Column(db.String)
    report_year = db.Column(db.Integer)
    independent_contributions_period = db.Column(db.Integer)
    independent_expenditures_period = db.Column(db.Integer)
    report_type = db.Column(db.String)
    report_type_full = db.Column(db.String)
    report_form = 'Form 5'
