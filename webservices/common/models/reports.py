from webservices import docs, utils

from .base import db, BaseModel

from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.dialects.postgresql import ARRAY, TSVECTOR

from webservices.common.models.dates import ReportType
from sqlalchemy.ext.declarative import declared_attr

from webservices.common.models.dates import clean_report_type


class PdfMixin(object):
    @property
    def pdf_url(self):
        if self.has_pdf:
            return utils.make_report_pdf_url(self.beginning_image_number)
        return None

    @property
    def has_pdf(self):
        return self.report_year and self.report_year >= 1993


class CsvMixin(object):
    @property
    def csv_url(self):
        if self.file_number:
            return utils.make_csv_url(self.file_number)


class FecMixin(object):
    @property
    def fec_url(self):
        if self.file_number:
            return utils.make_fec_url(self.beginning_image_number, self.file_number)


class TreasurerMixin(object):

    treasurer_last_name = db.Column('lname', db.String)
    treasurer_middle_name = db.Column('mname', db.String)
    treasurer_first_name = db.Column('fname', db.String)
    prefix = db.Column(db.String)
    suffix = db.Column(db.String)

    @hybrid_property
    def treasurer_name(self):
        name = name_generator(
            self.treasurer_last_name,
            self.prefix,
            self.treasurer_first_name,
            self.treasurer_middle_name,
            self.suffix,
        )
        name = name if name else None
        return name


class AmendmentChainMixin(object):
    @property
    def most_recent(self):
        return self.file_number == self.amendment.most_recent_filing

    @hybrid_property
    def most_recent_filing(self):
        return self.amendment.most_recent_filing

    @hybrid_property
    def amendment_chain(self):
        return self.amendment.amendment_chain

    @property
    def is_amended(self):
        return not self.most_recent

    @property
    def amended_by(self):
        amender_file_number = self.amendment.next_in_chain(self.file_number)
        if amender_file_number > 0:
            return amender_file_number
        else:
            return None


class FecFileNumberMixin(object):
    @property
    def fec_file_id(self):
        if self.file_number and self.file_number > 0:
            return "FEC-" + str(self.file_number)
        else:
            return None


class CommitteeReports(FecFileNumberMixin, PdfMixin, CsvMixin, BaseModel):
    __abstract__ = True

    committee_id = db.Column(db.String, index=True, doc=docs.COMMITTEE_ID)
    committee_name = db.Column(db.String, doc=docs.COMMITTEE_NAME)  # mapped
    committee = utils.related(
        'CommitteeHistory', 'committee_id', 'committee_id', 'report_year', 'cycle'
    )

    # These columns derived from amendments materializeds view
    amendment_chain = db.Column(ARRAY(db.Numeric), doc=docs.AMENDMENT_CHAIN)
    previous_file_number = db.Column(db.Numeric)
    most_recent_file_number = db.Column(db.Numeric)

    cycle = db.Column(db.Integer, index=True, doc=docs.CYCLE)
    file_number = db.Column(db.Integer)
    amendment_indicator = db.Column('amendment_indicator', db.String)
    amendment_indicator_full = db.Column(db.String)
    beginning_image_number = db.Column(db.BigInteger, doc=docs.BEGINNING_IMAGE_NUMBER)
    cash_on_hand_beginning_period = db.Column(
        db.Numeric(30, 2), doc=docs.CASH_ON_HAND_BEGIN_PERIOD
    )  # P
    cash_on_hand_end_period = db.Column(
        'cash_on_hand_end_period', db.Numeric(30, 2), doc=docs.CASH_ON_HAND_END_PERIOD
    )  # P
    coverage_end_date = db.Column(
        db.DateTime, index=True, doc=docs.COVERAGE_END_DATE
    )  # P
    coverage_start_date = db.Column(
        db.DateTime, index=True, doc=docs.COVERAGE_START_DATE
    )  # P
    debts_owed_by_committee = db.Column(
        'debts_owed_by_committee', db.Numeric(30, 2), doc=docs.DEBTS_OWED_BY_COMMITTEE
    )  # P
    debts_owed_to_committee = db.Column(
        db.Numeric(30, 2), doc=docs.DEBTS_OWED_TO_COMMITTEE
    )  # P
    end_image_number = db.Column(db.BigInteger, doc=docs.ENDING_IMAGE_NUMBER)
    other_disbursements_period = db.Column(
        db.Numeric(30, 2), doc=docs.add_period(docs.OTHER_DISBURSEMENTS)
    )  # PX
    other_disbursements_ytd = db.Column(
        db.Numeric(30, 2), doc=docs.add_ytd(docs.OTHER_DISBURSEMENTS)
    )  # PX
    other_political_committee_contributions_period = db.Column(
        db.Numeric(30, 2),
        doc=docs.add_period(docs.OTHER_POLITICAL_COMMITTEE_CONTRIBUTIONS),
    )  # P
    other_political_committee_contributions_ytd = db.Column(
        db.Numeric(30, 2),
        doc=docs.add_ytd(docs.OTHER_POLITICAL_COMMITTEE_CONTRIBUTIONS),
    )  # P
    political_party_committee_contributions_period = db.Column(
        db.Numeric(30, 2),
        doc=docs.add_period(docs.POLITICAL_PARTY_COMMITTEE_CONTRIBUTIONS),
    )  # P
    political_party_committee_contributions_ytd = db.Column(
        db.Numeric(30, 2),
        doc=docs.add_ytd(docs.POLITICAL_PARTY_COMMITTEE_CONTRIBUTIONS),
    )  # P
    report_type = db.Column(db.String, doc=docs.REPORT_TYPE)
    report_type_full = db.Column(db.String, doc=docs.REPORT_TYPE)
    report_year = db.Column(db.Integer, doc=docs.REPORT_YEAR)
    total_contribution_refunds_period = db.Column(
        db.Numeric(30, 2), doc=docs.add_period(docs.CONTRIBUTION_REFUNDS)
    )  # P
    total_contribution_refunds_ytd = db.Column(
        db.Numeric(30, 2), doc=docs.add_ytd(docs.CONTRIBUTION_REFUNDS)
    )  # P
    refunded_individual_contributions_period = db.Column(
        db.Numeric(30, 2), doc=docs.add_period(docs.REFUNDED_INDIVIDUAL_CONTRIBUTIONS)
    )  # P
    refunded_individual_contributions_ytd = db.Column(
        db.Numeric(30, 2), doc=docs.add_ytd(docs.REFUNDED_INDIVIDUAL_CONTRIBUTIONS)
    )  # P
    refunded_other_political_committee_contributions_period = db.Column(
        db.Numeric(30, 2),
        doc=docs.add_period(docs.REFUNDED_OTHER_POLITICAL_COMMITTEE_CONTRIBUTIONS),
    )  # P
    refunded_other_political_committee_contributions_ytd = db.Column(
        db.Numeric(30, 2),
        doc=docs.add_ytd(docs.REFUNDED_OTHER_POLITICAL_COMMITTEE_CONTRIBUTIONS),
    )  # P
    refunded_political_party_committee_contributions_period = db.Column(
        db.Numeric(30, 2),
        doc=docs.add_period(docs.REFUNDED_POLITICAL_PARTY_COMMITTEE_CONTRIBUTIONS),
    )  # P
    refunded_political_party_committee_contributions_ytd = db.Column(
        db.Numeric(30, 2),
        doc=docs.add_ytd(docs.REFUNDED_POLITICAL_PARTY_COMMITTEE_CONTRIBUTIONS),
    )  # P
    total_contributions_period = db.Column(
        'total_contributions_period',
        db.Numeric(30, 2),
        doc=docs.add_period(docs.CONTRIBUTIONS),
    )  # P
    total_contributions_ytd = db.Column(
        db.Numeric(30, 2), doc=docs.add_ytd(docs.CONTRIBUTIONS)
    )  # P
    total_disbursements_period = db.Column(
        'total_disbursements_period',
        db.Numeric(30, 2),
        doc=docs.add_period(docs.DISBURSEMENTS),
    )  # P
    total_disbursements_ytd = db.Column(
        db.Numeric(30, 2), doc=docs.add_ytd(docs.DISBURSEMENTS)
    )  # P
    total_receipts_period = db.Column(
        'total_receipts_period', db.Numeric(30, 2), doc=docs.add_period(docs.RECEIPTS)
    )  # P
    total_receipts_ytd = db.Column(
        db.Numeric(30, 2), doc=docs.add_ytd(docs.RECEIPTS)
    )  # P
    offsets_to_operating_expenditures_ytd = db.Column(
        db.Numeric(30, 2), doc=docs.add_ytd(docs.OFFSETS_TO_OPERATING_EXPENDITURES)
    )  # P
    offsets_to_operating_expenditures_period = db.Column(
        db.Numeric(30, 2), doc=docs.add_period(docs.OFFSETS_TO_OPERATING_EXPENDITURES)
    )  # P
    total_individual_contributions_ytd = db.Column(
        db.Numeric(30, 2), doc=docs.add_ytd(docs.INDIVIDUAL_CONTRIBUTIONS)
    )  # P
    total_individual_contributions_period = db.Column(
        db.Numeric(30, 2), doc=docs.add_period(docs.INDIVIDUAL_CONTRIBUTIONS)
    )  # P
    individual_unitemized_contributions_ytd = db.Column(
        db.Numeric(30, 2), doc=docs.add_ytd(docs.INDIVIDUAL_UNITEMIZED_CONTRIBUTIONS)
    )  # P \
    individual_unitemized_contributions_period = db.Column(
        db.Numeric(30, 2), doc=docs.add_period(docs.INDIVIDUAL_UNITEMIZED_CONTRIBUTIONS)
    )  # P
    individual_itemized_contributions_ytd = db.Column(
        db.Numeric(30, 2), doc=docs.add_ytd(docs.INDIVIDUAL_ITEMIZED_CONTRIBUTIONS)
    )  # P
    individual_itemized_contributions_period = db.Column(
        db.Numeric(30, 2), doc=docs.add_period(docs.INDIVIDUAL_ITEMIZED_CONTRIBUTIONS)
    )  # P
    is_amended = db.Column('is_amended', db.Boolean, doc=docs.IS_AMENDED)
    receipt_date = db.Column('receipt_date', db.Date, doc=docs.RECEIPT_DATE)
    means_filed = db.Column('means_filed', db.String, doc=docs.MEANS_FILED)
    fec_url = db.Column(db.String, doc=docs.FEC_URL)
    html_url = db.Column(db.String, doc=docs.HTML_URL)
    most_recent = db.Column('most_recent', db.Boolean, doc=docs.MOST_RECENT)
    filer_name_text = db.Column(TSVECTOR, doc=docs.FILER_NAME_TEXT)

    @property
    def document_description(self):
        return utils.document_description(
            self.coverage_end_date.year,
            clean_report_type(str(self.report_type_full)),
            None,
            None,
        )


class CommitteeReportsHouseSenate(CommitteeReports):
    __tablename__ = 'ofec_reports_house_senate_mv'
    aggregate_amount_personal_contributions_general = db.Column(
        db.Numeric(30, 2)
    )  # missing
    aggregate_contributions_personal_funds_primary = db.Column(
        db.Numeric(30, 2)
    )  # missing
    all_other_loans_period = db.Column(db.Numeric(30, 2))  # mapped
    all_other_loans_ytd = db.Column(db.Numeric(30, 2))  # mapped
    candidate_contribution_period = db.Column(db.Numeric(30, 2))  # mapped
    candidate_contribution_ytd = db.Column(db.Numeric(30, 2))  # mapped
    gross_receipt_authorized_committee_general = db.Column(db.Numeric(30, 2))  # missing
    gross_receipt_authorized_committee_primary = db.Column(db.Numeric(30, 2))  # missing
    gross_receipt_minus_personal_contribution_general = db.Column(
        db.Numeric(30, 2)
    )  # missing
    gross_receipt_minus_personal_contributions_primary = db.Column(
        db.Numeric(30, 2)
    )  # missing
    loan_repayments_candidate_loans_period = db.Column(db.Numeric(30, 2))  # mapped
    loan_repayments_candidate_loans_ytd = db.Column(db.Numeric(30, 2))  # mapped
    loan_repayments_other_loans_period = db.Column(db.Numeric(30, 2))  # mapped
    loan_repayments_other_loans_ytd = db.Column(db.Numeric(30, 2))  # mapped
    loans_made_by_candidate_period = db.Column(db.Numeric(30, 2))  # mapped
    loans_made_by_candidate_ytd = db.Column(db.Numeric(30, 2))  # mapped
    net_contributions_ytd = db.Column(db.Numeric(30, 2))  # mapped
    net_contributions_period = db.Column(db.Numeric(30, 2), index=True)  # mapped
    net_operating_expenditures_period = db.Column(db.Numeric(30, 2))  # mapped
    net_operating_expenditures_ytd = db.Column(db.Numeric(30, 2))  # mapped
    operating_expenditures_period = db.Column(db.Numeric(30, 2))  # mapped
    operating_expenditures_ytd = db.Column(db.Numeric(30, 2))  # mapped
    other_receipts_period = db.Column(db.Numeric(30, 2))  # mapped
    other_receipts_ytd = db.Column(db.Numeric(30, 2))  # mapped
    refunds_total_contributions_col_total_ytd = db.Column(
        db.Numeric(30, 2)
    )  # mapped, but maybe needs to be renamed?
    subtotal_period = db.Column(db.Numeric(30, 2))  # mapped
    # mapped, but rename to match column above
    total_contribution_refunds_col_total_period = db.Column(db.Numeric(30, 2))
    total_contributions_column_total_period = db.Column(db.Numeric(30, 2))  # missing
    total_loan_repayments_made_period = db.Column(db.Numeric(30, 2))  # mapped
    total_loan_repayments_made_ytd = db.Column(db.Numeric(30, 2))  # mapped
    total_loans_received_period = db.Column(db.Numeric(30, 2))  # mapped
    total_loans_received_ytd = db.Column(db.Numeric(30, 2))  # mapped
    total_offsets_to_operating_expenditures_period = db.Column(
        db.Numeric(30, 2)
    )  # mapped
    total_offsets_to_operating_expenditures_ytd = db.Column(db.Numeric(30, 2))  # mapped
    total_operating_expenditures_period = db.Column(db.Numeric(30, 2))  # mapped
    total_operating_expenditures_ytd = db.Column(db.Numeric(30, 2))  # mapped
    transfers_from_other_authorized_committee_period = db.Column(
        db.Numeric(30, 2)
    )  # mapped
    transfers_from_other_authorized_committee_ytd = db.Column(
        db.Numeric(30, 2)
    )  # mapped
    transfers_to_other_authorized_committee_period = db.Column(
        db.Numeric(30, 2)
    )  # mapped
    transfers_to_other_authorized_committee_ytd = db.Column(db.Numeric(30, 2))  # mapped
    report_form = 'Form 3'

    @property
    def has_pdf(self):
        committee = self.committee
        return (
            self.report_year
            and committee
            and (
                committee.committee_type == 'H'
                and self.report_year >= 1996
                or committee.committee_type == 'S'
                and self.report_year >= 2000
            )
        )


class CommitteeReportsPacParty(CommitteeReports):
    __tablename__ = 'ofec_reports_pac_party_mv'

    all_loans_received_period = db.Column(db.Numeric(30, 2))  # mapped
    all_loans_received_ytd = db.Column(db.Numeric(30, 2))  # mapped
    allocated_federal_election_levin_share_period = db.Column(
        db.Numeric(30, 2)
    )  # missing
    calendar_ytd = db.Column(db.Integer)  # missing
    cash_on_hand_beginning_calendar_ytd = db.Column(
        db.Numeric(30, 2)
    )  # mapped, but it's period not ytd
    cash_on_hand_close_ytd = db.Column(db.Numeric(30, 2))  # mapped
    coordinated_expenditures_by_party_committee_period = db.Column(
        'coordinated_expenditures_by_party_committee_period', db.Numeric(30, 2)
    )  # mapped
    coordinated_expenditures_by_party_committee_ytd = db.Column(
        db.Numeric(30, 2)
    )  # mapped
    fed_candidate_committee_contribution_refunds_ytd = db.Column(
        db.Numeric(30, 2)
    )  # mapped,should this match line 164
    fed_candidate_committee_contributions_period = db.Column(
        db.Numeric(30, 2)
    )  # mapped
    fed_candidate_committee_contributions_ytd = db.Column(db.Numeric(30, 2))  # mapped
    fed_candidate_contribution_refunds_period = db.Column(db.Numeric(30, 2))  # mapped
    independent_expenditures_period = db.Column(
        'independent_expenditures_period', db.Numeric(30, 2)
    )  # mapped
    independent_expenditures_ytd = db.Column(db.Numeric(30, 2))  # mapped
    loan_repayments_made_period = db.Column(db.Numeric(30, 2))  # mapped
    loan_repayments_made_ytd = db.Column(db.Numeric(30, 2))  # mapped
    loan_repayments_received_period = db.Column(db.Numeric(30, 2))  # mapped
    loan_repayments_received_ytd = db.Column(db.Numeric(30, 2))  # mapped
    loans_made_period = db.Column(db.Numeric(30, 2))  # mapped
    loans_made_ytd = db.Column(db.Numeric(30, 2))  # mapped
    net_contributions_period = db.Column(db.Numeric(30, 2), index=True)  # mapped
    net_contributions_ytd = db.Column(db.Numeric(30, 2))  # mapped
    net_operating_expenditures_period = db.Column(db.Numeric(30, 2))  # mapped
    net_operating_expenditures_ytd = db.Column(db.Numeric(30, 2))  # mapped
    non_allocated_fed_election_activity_period = db.Column(db.Numeric(30, 2))  # mapped
    non_allocated_fed_election_activity_ytd = db.Column(db.Numeric(30, 2))  # mapped
    nonfed_share_allocated_disbursements_period = db.Column(
        db.Numeric(30, 2)
    )  # missing!
    other_fed_operating_expenditures_period = db.Column(db.Numeric(30, 2))  # mapped
    other_fed_operating_expenditures_ytd = db.Column(db.Numeric(30, 2))  # mapped
    other_fed_receipts_period = db.Column(db.Numeric(30, 2))  # mapped
    other_fed_receipts_ytd = db.Column(db.Numeric(30, 2))  # mapped
    shared_fed_activity_nonfed_ytd = db.Column(db.Numeric(30, 2))  # mapped
    shared_fed_activity_period = db.Column(db.Numeric(30, 2))  # mapped
    shared_fed_activity_ytd = db.Column(db.Numeric(30, 2))  # mapped
    shared_fed_operating_expenditures_period = db.Column(db.Numeric(30, 2))  # mapped
    shared_fed_operating_expenditures_ytd = db.Column(db.Numeric(30, 2))  # mapped
    shared_nonfed_operating_expenditures_period = db.Column(db.Numeric(30, 2))  # mapped
    shared_nonfed_operating_expenditures_ytd = db.Column(db.Numeric(30, 2))  # mapped
    subtotal_summary_page_period = db.Column(
        db.Numeric(30, 2)
    )  # check this one in the json
    subtotal_summary_ytd = db.Column(db.Numeric(30, 2))  # mapped
    total_fed_disbursements_period = db.Column(db.Numeric(30, 2))  # mapped
    total_fed_disbursements_ytd = db.Column(db.Numeric(30, 2))  # mapped
    total_fed_election_activity_period = db.Column(db.Numeric(30, 2))  # mapped
    total_fed_election_activity_ytd = db.Column(db.Numeric(30, 2))  # mapped
    total_fed_operating_expenditures_period = db.Column(db.Numeric(30, 2))  # mapped
    total_fed_operating_expenditures_ytd = db.Column(db.Numeric(30, 2))  # mapped
    total_fed_receipts_period = db.Column(db.Numeric(30, 2))  # mapped
    total_fed_receipts_ytd = db.Column(db.Numeric(30, 2))  # mapped
    total_nonfed_transfers_period = db.Column(db.Numeric(30, 2))  # mapped
    total_nonfed_transfers_ytd = db.Column(db.Numeric(30, 2))  # mapped
    total_operating_expenditures_period = db.Column(db.Numeric(30, 2))  # mapped
    total_operating_expenditures_ytd = db.Column(db.Numeric(30, 2))  # mapped
    transfers_from_affiliated_party_period = db.Column(
        db.Numeric(30, 2)
    )  # this should be committee not party
    transfers_from_affiliated_party_ytd = db.Column(db.Numeric(30, 2))  # ditto
    transfers_from_nonfed_account_period = db.Column(db.Numeric(30, 2))  # mapped
    transfers_from_nonfed_account_ytd = db.Column(db.Numeric(30, 2))  # mapped
    transfers_from_nonfed_levin_period = db.Column(db.Numeric(30, 2))  # mapped
    transfers_from_nonfed_levin_ytd = db.Column(db.Numeric(30, 2))  # mapped
    transfers_to_affiliated_committee_period = db.Column(db.Numeric(30, 2))  # mapped
    transfers_to_affilitated_committees_ytd = db.Column(db.Numeric(30, 2))  # mapped
    report_form = db.Column('form_tp', db.String)  # mapped


class CommitteeReportsPresidential(CommitteeReports):
    __tablename__ = 'ofec_reports_presidential_mv'

    candidate_contribution_period = db.Column(db.Numeric(30, 2))  # mapped
    candidate_contribution_ytd = db.Column(db.Numeric(30, 2))  # mapped
    exempt_legal_accounting_disbursement_period = db.Column(db.Numeric(30, 2))  # mapped
    exempt_legal_accounting_disbursement_ytd = db.Column(db.Numeric(30, 2))  # """
    expenditure_subject_to_limits = db.Column(db.Numeric(30, 2))  # mapped
    federal_funds_period = db.Column(db.Numeric(30, 2))  # mapped
    federal_funds_ytd = db.Column(db.Numeric(30, 2))  # """
    fundraising_disbursements_period = db.Column(db.Numeric(30, 2))  # mapped
    fundraising_disbursements_ytd = db.Column(db.Numeric(30, 2))  # """
    items_on_hand_liquidated = db.Column(db.Numeric(30, 2))  # mapped
    loans_received_from_candidate_period = db.Column(db.Numeric(30, 2))  # mapped
    loans_received_from_candidate_ytd = db.Column(db.Numeric(30, 2))  # """
    offsets_to_fundraising_expenditures_ytd = db.Column(db.Numeric(30, 2))  # mapped
    offsets_to_fundraising_expenditures_period = db.Column(db.Numeric(30, 2))  # mapped
    offsets_to_legal_accounting_period = db.Column(db.Numeric(30, 2))  # mapped
    offsets_to_legal_accounting_ytd = db.Column(db.Numeric(30, 2))  # mapped
    operating_expenditures_period = db.Column(db.Numeric(30, 2))  # mapped
    operating_expenditures_ytd = db.Column(db.Numeric(30, 2))  # """
    other_loans_received_period = db.Column(db.Numeric(30, 2))  # mapped
    other_loans_received_ytd = db.Column(db.Numeric(30, 2))  # """
    other_receipts_period = db.Column(db.Numeric(30, 2))  # mapped
    other_receipts_ytd = db.Column(db.Numeric(30, 2))  # """
    repayments_loans_made_by_candidate_period = db.Column(db.Numeric(30, 2))  # mapped
    repayments_loans_made_candidate_ytd = db.Column(db.Numeric(30, 2))  # """
    repayments_other_loans_period = db.Column(db.Numeric(30, 2))  # mapped
    repayments_other_loans_ytd = db.Column(db.Numeric(30, 2))  # """
    subtotal_summary_period = db.Column(db.Numeric(30, 2))  # mapped
    total_loan_repayments_made_period = db.Column(db.Numeric(30, 2))  # mapped
    total_loan_repayments_made_ytd = db.Column(db.Numeric(30, 2))  # """
    total_loans_received_period = db.Column(db.Numeric(30, 2))  # mapped
    total_loans_received_ytd = db.Column(db.Numeric(30, 2))  # mapped
    total_offsets_to_operating_expenditures_period = db.Column(
        db.Numeric(30, 2)
    )  # mapped
    total_offsets_to_operating_expenditures_ytd = db.Column(db.Numeric(30, 2))  # """
    total_period = db.Column(db.Numeric(30, 2))  # mapped
    total_ytd = db.Column(db.Numeric(30, 2))  # mapped
    transfers_from_affiliated_committee_period = db.Column(db.Numeric(30, 2))  # mapped
    transfers_from_affiliated_committee_ytd = db.Column(db.Numeric(30, 2))  # """
    transfers_to_other_authorized_committee_period = db.Column(
        db.Numeric(30, 2)
    )  # mapped
    transfers_to_other_authorized_committee_ytd = db.Column(db.Numeric(30, 2))  # """
    net_contributions_cycle_to_date = db.Column(db.Numeric(30, 2))  # mapped
    net_operating_expenditures_cycle_to_date = db.Column(db.Numeric(30, 2))  # mapped
    report_form = 'Form 3P'  # do we want this for the efile tables?


class CommitteeReportsIEOnly(PdfMixin, BaseModel):
    __tablename__ = 'ofec_reports_ie_only_mv'

    beginning_image_number = db.Column(db.BigInteger)
    committee_id = db.Column(db.String)
    committee_name = db.Column(db.String)
    cycle = db.Column(db.Integer)
    coverage_start_date = db.Column(db.DateTime(), index=True)
    coverage_end_date = db.Column(db.DateTime(), index=True)
    report_year = db.Column(db.Integer)
    independent_contributions_period = db.Column(
        'independent_contributions_period', db.Numeric(30, 2)
    )
    independent_expenditures_period = db.Column(db.Numeric(30, 2))
    report_type = db.Column(db.String)
    report_type_full = db.Column(db.String)
    report_form = 'Form 5'
    is_amended = db.Column(db.Boolean, doc=docs.IS_AMENDED)
    receipt_date = db.Column(db.Date, doc=docs.RECEIPT_DATE)
    means_filed = db.Column(db.String, doc=docs.MEANS_FILED)
    fec_url = db.Column(db.String)
    spender_name_text = db.Column(TSVECTOR, doc=docs.SPENDER_NAME_TEXT)


class BaseFilingSummary(db.Model):
    __table_args__ = {'schema': 'real_efile'}
    __tablename__ = 'summary'
    file_number = db.Column('repid', db.Integer, index=True, primary_key=True)
    line_number_short = db.Column('lineno', db.Integer, primary_key=True)
    column_a = db.Column('cola', db.Float)
    column_b = db.Column('colb', db.Float)


class BaseFiling(FecFileNumberMixin, AmendmentChainMixin, PdfMixin, FecMixin, db.Model):
    __abstract__ = True
    file_number = db.Column('repid', db.Integer, index=True, primary_key=True)
    committee_id = db.Column('comid', db.String, index=True, doc=docs.COMMITTEE_ID)
    coverage_start_date = db.Column('from_date', db.Date)
    coverage_end_date = db.Column('through_date', db.Date)
    rpt_pgi = db.Column('rptpgi', db.String, doc=docs.ELECTION_TYPE)
    report_type = db.Column('rptcode', db.String)
    beginning_image_number = db.Column('imageno', db.BigInteger)
    street_1 = db.Column('str1', db.String)
    street_2 = db.Column('str2', db.String)
    city = db.Column(db.String)
    state = db.Column(db.String)
    zip = db.Column(db.String)
    election_date = db.Column('el_date', db.Date)
    election_state = db.Column('el_state', db.String)
    receipt_date = db.Column('create_dt', db.Date, index=True)
    sign_date = db.Column(db.Date)
    superceded = ''

    @property
    def document_description(self):
        return utils.document_description(
            self.coverage_end_date.year,
            clean_report_type(self.report.report_type_full),
            None,
            None,
        )

    @property
    def report_year(self):
        return self.coverage_end_date.year


def name_generator(*args):
    name = ''
    fields = []
    for field in args:
        field = field.strip() if field else ''
        fields.append(field)
    if fields.count('') == len(fields):
        return None
    fields[0] = fields[0] + ','

    for field in fields:
        name += field + ' '
    return name.strip()


class BaseF3PFiling(TreasurerMixin, BaseFiling):
    __table_args__ = {'schema': 'real_efile'}
    __tablename__ = 'f3p'
    file_number = db.Column('repid', db.Integer, index=True, primary_key=True)
    committee_name = db.Column('c_name', db.String, index=True, doc=docs.COMMITTEE_NAME)
    street_1 = db.Column('c_str1', db.String)
    street_2 = db.Column('c_str2', db.String)
    city = db.Column('c_city', db.String)
    state = db.Column('c_state', db.String)
    zip = db.Column('c_zip', db.String)
    total_receipts = db.Column('tot_rec', db.Float)
    total_disbursements = db.Column('tot_dis', db.Float)
    cash_on_hand_beginning_period = db.Column('cash', db.Float)
    cash_on_hand_end_period = db.Column('cash_close', db.Float)
    debts_owed_to_committee = db.Column('debts_to', db.Float)
    debts_owed_by_committee = db.Column('debts_by', db.Float)
    expenditure_subject_to_limits = db.Column('expe', db.Float)
    net_contributions_cycle_to_date = db.Column('net_con', db.Float)
    net_operating_expenditures_cycle_to_date = db.Column('net_op', db.Float)
    primary_election = db.Column('act_pri', db.String)
    general_election = db.Column('act_gen', db.String)
    subtotal_summary_period = db.Column('sub', db.String)
    report_form = 'Form 3P'

    summary_lines = db.relationship(
        'BaseFilingSummary',
        primaryjoin='''and_(
                BaseF3PFiling.file_number == BaseFilingSummary.file_number,
            )''',
        foreign_keys=file_number,
        uselist=True,
        lazy='subquery',
    )

    amendment = db.relationship(
        'EfilingsAmendments',
        primaryjoin='''and_(
                                EfilingsAmendments.file_number == BaseF3PFiling.file_number,
                            )''',
        foreign_keys=file_number,
        lazy='joined',
    )

    @declared_attr
    def report(self):
        return db.relationship(
            ReportType,
            primaryjoin="and_(BaseF3PFiling.report_type==ReportType.report_type)",
            foreign_keys=self.report_type,
            lazy='subquery',
        )


class BaseF3Filing(TreasurerMixin, BaseFiling):
    __table_args__ = {'schema': 'real_efile'}
    __tablename__ = 'f3'
    file_number = db.Column('repid', db.Integer, index=True, primary_key=True)
    committee_name = db.Column(
        'com_name', db.String, index=True, doc=docs.COMMITTEE_NAME
    )
    candidate_id = db.Column('canid', db.String)
    candidate_last_name = db.Column('can_lname', db.String)
    candidate_first_name = db.Column('can_fname', db.String)
    candidate_middle_name = db.Column('can_mname', db.String)
    candidate_prefix = db.Column('can_prefix', db.String)
    candidate_suffix = db.Column('can_suffix', db.String)
    cash_on_hand_beginning_period = db.Column('cash_hand', db.Integer)
    f3z1 = db.Column(db.Integer)
    primary_election = db.Column('act_pri', db.String)
    general_election = db.Column('act_gen', db.String)
    special_election = db.Column('act_spe', db.String)
    runoff_election = db.Column('act_run', db.String)
    district = db.Column('eld', db.Integer)
    amended_address = db.Column('amend_addr', db.String)

    @hybrid_property
    def candidate_name(self):
        name = name_generator(
            self.candidate_last_name,
            self.candidate_prefix,
            self.candidate_first_name,
            self.candidate_middle_name,
            self.candidate_suffix,
        )
        name = name if name else None
        return name

    amendment = db.relationship(
        'EfilingsAmendments',
        primaryjoin='''and_(
                                    EfilingsAmendments.file_number == BaseF3Filing.file_number,
                                )''',
        foreign_keys=file_number,
        lazy='joined',
    )

    summary_lines = db.relationship(
        'BaseFilingSummary',
        primaryjoin='''and_(
                BaseF3Filing.file_number == BaseFilingSummary.file_number,
            )''',
        foreign_keys=file_number,
        uselist=True,
        lazy='subquery',
    )

    @declared_attr
    def report(self):
        return db.relationship(
            ReportType,
            primaryjoin="and_(BaseF3Filing.report_type==ReportType.report_type)",
            foreign_keys=self.report_type,
            lazy='subquery',
        )


class BaseF3XFiling(BaseFiling):
    __table_args__ = {'schema': 'real_efile'}
    __tablename__ = 'f3x'
    file_number = db.Column('repid', db.Integer, index=True, primary_key=True)

    committee_name = db.Column(
        'com_name', db.String, index=True, doc=docs.COMMITTEE_NAME
    )
    sign_date = db.Column('date_signed', db.Date)
    amend_address = db.Column('amend_addr', db.String)
    qualified_multicandidate_committee = db.Column('qual', db.String)

    summary_lines = db.relationship(
        'BaseFilingSummary',
        primaryjoin='''and_(
                BaseF3XFiling.file_number == BaseFilingSummary.file_number,
            )''',
        foreign_keys=file_number,
        uselist=True,
        lazy='subquery',
    )

    amendment = db.relationship(
        'EfilingsAmendments',
        primaryjoin='''and_(
                                    EfilingsAmendments.file_number == BaseF3XFiling.file_number,
                                )''',
        foreign_keys=file_number,
        lazy='joined',
    )

    @declared_attr
    def report(self):
        return db.relationship(
            ReportType,
            primaryjoin="and_(BaseF3XFiling.report_type==ReportType.report_type)",
            foreign_keys=self.report_type,
            lazy='subquery',
        )
