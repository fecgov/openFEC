import marshmallow as ma
import sqlalchemy as sa

from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.dialects.postgresql import TSVECTOR

from webservices import docs, utils

from .base import db
from .reports import PdfMixin, name_generator


class BaseItemized(db.Model):
    __abstract__ = True

    committee = utils.related_committee_history('committee_id', cycle_label='report_year')
    committee_id = db.Column('cmte_id', db.String, doc=docs.COMMITTEE_ID)
    report_year = db.Column('rpt_yr', db.Integer, doc=docs.REPORT_YEAR)
    report_type = db.Column('rpt_tp', db.String, doc=docs.REPORT_TYPE)
    image_number = db.Column('image_num', db.String, doc=docs.IMAGE_NUMBER)
    filing_form = db.Column(db.String)
    link_id = db.Column(db.Integer)
    line_number = db.Column('line_num', db.String)
    transaction_id = db.Column('tran_id', db.String)
    file_number = db.Column('file_num', db.Integer)

    @hybrid_property
    def memoed_subtotal(self):
        return self.memo_code == 'X'


class BaseRawItemized(db.Model):
    __abstract__ = True

    line_number = db.Column("line_num", db.String)
    transaction_id = db.Column('tran_id', db.String)
    image_number = db.Column('imageno', db.String, doc=docs.IMAGE_NUMBER)
    entity_type = db.Column('entity', db.String)
    amendment_indicator = db.Column('amend', db.String)
    memo_code = db.Column(db.String)
    memo_text = db.Column(db.String)
    back_reference_transaction_id = db.Column('br_tran_id', db.String)
    back_reference_schedule_name = db.Column('br_sname', db.String)
    load_timestamp = db.Column('create_dt', db.DateTime)

    @hybrid_property
    def report_type(self):
        return self.filing.form_type

    @hybrid_property
    def cycle(self):
        return self.load_timestamp.year

    @hybrid_property
    def memoed_subtotal(self):
        return self.memo_code == 'X'

    @hybrid_property
    def fec_election_type_desc(self):
        election_map = {'P': 'PRIMARY', 'G': 'GENERAL', 'O': 'OTHER'}
        if self.pgo:
            return election_map.get(str(self.pgo).upper()[0])
        return None

    @property
    def pdf_url(self):
        return utils.make_schedule_pdf_url(str(self.image_number))


class ScheduleA(BaseItemized):
    __table_args__ = {'schema': 'disclosure'}
    __tablename__ = 'fec_fitem_sched_a'

    """
    override the entry from the BaseItemized using either one of the following two
    committee = utils.related_committee_history('committee_id',
    cycle_label='two_year_transaction_period', use_modulus=False)
    """
    committee = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
            foreign(ScheduleA.committee_id) == CommitteeHistory.committee_id,
            ScheduleA.two_year_transaction_period == CommitteeHistory.cycle,
        )'''
    )

    committee_name = db.Column('cmte_nm', db.String, doc=docs.COMMITTEE_NAME)

    # Contributor info
    entity_type = db.Column('entity_tp', db.String)
    entity_type_desc = db.Column('entity_tp_desc', db.String)
    unused_contbr_id = db.Column('contbr_id', db.String)
    contributor_prefix = db.Column('contbr_prefix', db.String)
    # bring in committee info of the contributor_id
    contributor = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
            foreign(ScheduleA.contributor_id) == CommitteeHistory.committee_id,
            ScheduleA.two_year_transaction_period == CommitteeHistory.cycle,
        )'''
    )

    contributor_name = db.Column('contbr_nm', db.String, doc=docs.CONTRIBUTOR_NAME)
    recipient_committee_type = db.Column('cmte_tp', db.String(1), index=True)
    recipient_committee_org_type = db.Column('org_tp', db.String(1), index=True)
    recipient_committee_designation = db.Column('cmte_dsgn', db.String(1), index=True)

    contributor_name_text = db.Column(TSVECTOR)
    contributor_first_name = db.Column('contbr_nm_first', db.String)
    contributor_middle_name = db.Column('contbr_m_nm', db.String)
    contributor_last_name = db.Column('contbr_nm_last', db.String)
    contributor_suffix = db.Column('contbr_suffix', db.String)
    # confirm policy was changed before exposing
    contributor_street_1 = db.Column('contbr_st1', db.String)
    contributor_street_2 = db.Column('contbr_st2', db.String)
    contributor_city = db.Column('contbr_city', db.String, doc=docs.CONTRIBUTOR_CITY)
    contributor_state = db.Column('contbr_st', db.String, doc=docs.CONTRIBUTOR_STATE)
    contributor_zip = db.Column('contbr_zip', db.String, doc=docs.CONTRIBUTOR_ZIP)
    contributor_employer = db.Column('contbr_employer', db.String, doc=docs.CONTRIBUTOR_EMPLOYER)
    contributor_employer_text = db.Column(TSVECTOR)
    contributor_occupation = db.Column('contbr_occupation', db.String, doc=docs.CONTRIBUTOR_OCCUPATION)
    contributor_occupation_text = db.Column(TSVECTOR)
    contributor_id = db.Column('clean_contbr_id', db.String, doc=docs.CONTRIBUTOR_ID)
    is_individual = db.Column(db.Boolean, index=True)

    # Primary transaction info
    receipt_type = db.Column('receipt_tp', db.String)
    receipt_type_desc = db.Column('receipt_tp_desc', db.String)
    receipt_type_full = db.Column('receipt_desc', db.String)
    memo_code = db.Column('memo_cd', db.String)
    memo_code_full = db.Column('memo_cd_desc', db.String)
    memo_text = db.Column(db.String)
    contribution_receipt_date = db.Column('contb_receipt_dt', db.Date)
    contribution_receipt_amount = db.Column('contb_receipt_amt', db.Numeric(30, 2))
    contributor_aggregate_ytd = db.Column('contb_aggregate_ytd', db.Numeric(30, 2))

    # Related candidate info
    candidate_id = db.Column('cand_id', db.String, doc=docs.CANDIDATE_ID)
    candidate_name = db.Column('cand_nm', db.String, doc=docs.CANDIDATE_NAME)
    candidate_first_name = db.Column('cand_nm_first', db.String)
    candidate_last_name = db.Column('cand_nm_last', db.String)
    candidate_middle_name = db.Column('cand_m_nm', db.String)
    candidate_prefix = db.Column('cand_prefix', db.String)
    candidate_suffix = db.Column('cand_suffix', db.String)
    candidate_office = db.Column('cand_office', db.String)
    candidate_office_full = db.Column('cand_office_desc', db.String)
    candidate_office_state = db.Column('cand_office_st', db.String)
    candidate_office_state_full = db.Column('cand_office_st_desc', db.String)
    candidate_office_district = db.Column('cand_office_district', db.String, doc=docs.DISTRICT)

    # Conduit info
    conduit_committee_id = db.Column('conduit_cmte_id', db.String)
    conduit_committee_name = db.Column('conduit_cmte_nm', db.String)
    conduit_committee_street1 = db.Column('conduit_cmte_st1', db.String)
    conduit_committee_street2 = db.Column('conduit_cmte_st2', db.String)
    conduit_committee_city = db.Column('conduit_cmte_city', db.String)
    conduit_committee_state = db.Column('conduit_cmte_st', db.String)
    conduit_committee_zip = db.Column('conduit_cmte_zip', db.Integer)

    donor_committee_name = db.Column('donor_cmte_nm', db.String)
    national_committee_nonfederal_account = db.Column('national_cmte_nonfed_acct', db.String)

    # Transaction meta info
    election_type = db.Column('election_tp', db.String)
    election_type_full = db.Column('election_tp_desc', db.String)
    fec_election_type_desc = db.Column('fec_election_tp_desc', db.String)
    fec_election_year = db.Column('fec_election_yr', db.String)
    two_year_transaction_period = db.Column(db.SmallInteger, doc=docs.TWO_YEAR_TRANSACTION_PERIOD)
    amendment_indicator = db.Column('action_cd', db.String)
    amendment_indicator_desc = db.Column('action_cd_desc', db.String)
    schedule_type = db.Column('schedule_type', db.String)
    schedule_type_full = db.Column('schedule_type_desc', db.String)
    increased_limit = db.Column(db.String)
    load_date = db.Column('pg_date', db.DateTime)
    sub_id = db.Column(db.Integer, primary_key=True)
    original_sub_id = db.Column('orig_sub_id', db.Integer)
    back_reference_transaction_id = db.Column('back_ref_tran_id', db.String)
    back_reference_schedule_name = db.Column('back_ref_sched_nm', db.String)
    pdf_url = db.Column(db.String)
    line_number_label = db.Column(db.String)


class ScheduleAEfile(BaseRawItemized):
    __table_args__ = {'schema': 'real_efile'}
    __tablename__ = 'sa7'

    file_number = db.Column("repid", db.Integer, index=True, primary_key=True)
    related_line_number = db.Column("rel_lineno", db.Integer, primary_key=True)
    committee_id = db.Column("comid", db.String, index=True, doc=docs.COMMITTEE_ID)
    contributor_prefix = db.Column('prefix', db.String)
    contributor_name_text = db.Column(TSVECTOR)
    contributor_first_name = db.Column('fname', db.String)
    contributor_middle_name = db.Column('mname', db.String)
    contributor_last_name = db.Column('name', db.String)
    contributor_suffix = db.Column('suffix', db.String)
    # Street address omitted per FEC policy in schemas
    # contributor_street_1 = db.Column('contbr_st1', db.String)
    # contributor_street_2 = db.Column('contbr_st2', db.String)
    contributor_city = db.Column('city', db.String, doc=docs.CONTRIBUTOR_CITY)
    contributor_state = db.Column('state', db.String, index=True, doc=docs.CONTRIBUTOR_STATE)
    contributor_zip = db.Column('zip', db.String, doc=docs.CONTRIBUTOR_ZIP)
    contributor_employer = db.Column('indemp', db.String, doc=docs.CONTRIBUTOR_EMPLOYER)
    contributor_employer_text = db.Column(TSVECTOR)
    contributor_occupation = db.Column('indocc', db.String, doc=docs.CONTRIBUTOR_OCCUPATION)
    contributor_occupation_text = db.Column(TSVECTOR)
    contributor_aggregate_ytd = db.Column('ytd', db.Numeric(30, 2))
    contribution_receipt_amount = db.Column('amount', db.Numeric(30, 2))
    contribution_receipt_date = db.Column('date_con', db.Date)

    # Conduit info
    conduit_committee_id = db.Column('other_comid', db.String)
    conduit_committee_name = db.Column('donor_comname', db.String)
    conduit_committee_street1 = db.Column('other_str1', db.String)
    conduit_committee_street2 = db.Column('other_str2', db.String)
    conduit_committee_city = db.Column('other_city', db.String)
    conduit_committee_state = db.Column('other_state', db.String)
    conduit_committee_zip = db.Column('other_zip', db.Integer)
    pgo = db.Column(db.String)

    committee = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
                            ScheduleAEfile.committee_id == CommitteeHistory.committee_id,
                            extract('year', ScheduleAEfile.load_timestamp) +cast(extract('year',
                            ScheduleAEfile.load_timestamp), Integer) % 2 == CommitteeHistory.cycle,
                            )''',
        foreign_keys=committee_id,
        lazy='joined',
    )

    filing = db.relationship(
        'EFilings',
        primaryjoin='''and_(
                    ScheduleAEfile.file_number == EFilings.file_number,
                )''',
        foreign_keys=file_number,
        lazy='joined',
    )

    @hybrid_property
    def contributor_name(self):
        name = name_generator(
            self.contributor_last_name,
            self.contributor_prefix,
            self.contributor_first_name,
            self.contributor_middle_name,
            self.contributor_suffix
        )
        name = (
            name
            if name
            else None
        )
        return name


class ScheduleB(BaseItemized):
    __table_args__ = {'schema': 'disclosure'}
    __tablename__ = 'fec_fitem_sched_b'

    """
    override the entry from the BaseItemized using either one of the following two
    committee = utils.related_committee_history('committee_id',
    cycle_label='two_year_transaction_period', use_modulus=False)
    """
    committee = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
            foreign(ScheduleB.committee_id) == CommitteeHistory.committee_id,
            ScheduleB.two_year_transaction_period == CommitteeHistory.cycle,
        )'''
    )

    # Recipient info
    entity_type = db.Column('entity_tp', db.String)
    entity_type_desc = db.Column('entity_tp_desc', db.String)
    unused_recipient_committee_id = db.Column('recipient_cmte_id', db.String)
    recipient_committee_id = db.Column('clean_recipient_cmte_id', db.String)
    # bring in committee info of the recipient_committee
    recipient_committee = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
            foreign(ScheduleB.recipient_committee_id) == CommitteeHistory.committee_id,
            ScheduleB.two_year_transaction_period == CommitteeHistory.cycle,
        )'''
    )
    recipient_name = db.Column('recipient_nm', db.String)
    recipient_name_text = db.Column(TSVECTOR)
    recipient_street_1 = db.Column('recipient_st1', db.String)
    recipient_street_2 = db.Column('recipient_st2', db.String)
    recipient_city = db.Column(db.String)
    recipient_state = db.Column('recipient_st', db.String)
    recipient_zip = db.Column(db.String)
    beneficiary_committee_name = db.Column('benef_cmte_nm', db.String)
    national_committee_nonfederal_account = db.Column('national_cmte_nonfed_acct', db.String)

    # Primary transaction info
    disbursement_type = db.Column('disb_tp', db.String)
    disbursement_type_description = db.Column('disb_tp_desc', db.String)
    disbursement_description = db.Column('disb_desc', db.String)
    disbursement_description_text = db.Column(TSVECTOR)
    disbursement_purpose_category = db.Column(db.String)
    memo_code = db.Column('memo_cd', db.String)
    memo_code_full = db.Column('memo_cd_desc', db.String)
    memo_text = db.Column(db.String)
    disbursement_date = db.Column('disb_dt', db.Date)
    disbursement_amount = db.Column('disb_amt', db.Numeric(30, 2))

    # Related candidate info
    candidate_office = db.Column('cand_office', db.String)
    candidate_office_description = db.Column('cand_office_desc', db.String)
    candidate_office_district = db.Column('cand_office_district', db.String)
    candidate_id = db.Column('cand_id', db.String, doc=docs.CANDIDATE_ID)
    candidate_name = db.Column('cand_nm', db.String, doc=docs.CANDIDATE_NAME)
    candidate_first_name = db.Column('cand_nm_first', db.String)
    candidate_last_name = db.Column('cand_nm_last', db.String)
    candidate_middle_name = db.Column('cand_m_nm', db.String)
    candidate_prefix = db.Column('cand_prefix', db.String)
    candidate_suffix = db.Column('cand_suffix', db.String)
    candidate_office_state = db.Column('cand_office_st', db.String)
    candidate_office_state_full = db.Column('cand_office_st_desc', db.String)

    # Transaction meta info
    election_type = db.Column('election_tp', db.String)
    election_type_full = db.Column('election_tp_desc', db.String)
    fec_election_type_desc = db.Column('fec_election_tp_desc', db.String)
    fec_election_year = db.Column('fec_election_tp_year', db.String)
    two_year_transaction_period = db.Column(db.SmallInteger, doc=docs.TWO_YEAR_TRANSACTION_PERIOD)
    amendment_indicator = db.Column('action_cd', db.String)
    amendment_indicator_desc = db.Column('action_cd_desc', db.String)
    schedule_type = db.Column('schedule_type', db.String)
    schedule_type_full = db.Column('schedule_type_desc', db.String)
    load_date = db.Column('pg_date', db.DateTime)
    sub_id = db.Column(db.Integer, primary_key=True)
    original_sub_id = db.Column('orig_sub_id', db.Integer)
    back_reference_transaction_id = db.Column('back_ref_tran_id', db.String)
    back_reference_schedule_id = db.Column('back_ref_sched_id', db.String)
    semi_annual_bundled_refund = db.Column('semi_an_bundled_refund', db.Numeric(30, 2))

    pdf_url = db.Column(db.String)
    line_number_label = db.Column(db.String)

    # Payee info
    payee_last_name = db.Column('payee_l_nm', db.String)
    payee_first_name = db.Column('payee_f_nm', db.String)
    payee_middle_name = db.Column('payee_m_nm', db.String)
    payee_prefix = db.Column(db.String)
    payee_suffix = db.Column(db.String)
    payee_employer = db.Column('payee_employer', db.String)
    payee_occupation = db.Column('payee_occupation', db.String)

    # Category info
    category_code = db.Column('catg_cd', db.String)
    category_code_full = db.Column('catg_cd_desc', db.String)

    # Conduit info
    # missing in the data but want to check if it exists somewhere
    # conduit_committee_id = db.Column('conduit_cmte_id', db.String)
    conduit_committee_name = db.Column('conduit_cmte_nm', db.String)
    conduit_committee_street1 = db.Column('conduit_cmte_st1', db.String)
    conduit_committee_street2 = db.Column('conduit_cmte_st2', db.String)
    conduit_committee_city = db.Column('conduit_cmte_city', db.String)
    conduit_committee_state = db.Column('conduit_cmte_st', db.String)
    conduit_committee_zip = db.Column('conduit_cmte_zip', db.Integer)

    ref_disp_excess_flg = db.Column('ref_disp_excess_flg', db.String)
    comm_dt = db.Column('comm_dt', db.Date)

    spender_committee_type = db.Column('cmte_tp', db.String(1), index=True)
    spender_committee_org_type = db.Column('org_tp', db.String(1), index=True)
    spender_committee_designation = db.Column('cmte_dsgn', db.String(1), index=True)


class ScheduleBEfile(BaseRawItemized):
    __tablename__ = 'real_efile_sb4'

    file_number = db.Column("repid", db.Integer, index=True, primary_key=True)
    related_line_number = db.Column("rel_lineno", db.Integer, primary_key=True)
    committee_id = db.Column("comid", db.String, doc=docs.COMMITTEE_ID)
    recipient_name = db.Column('lname', db.String)
    # recipient_name_text = db.Column(TSVECTOR)
    # Street address omitted per FEC policy
    # recipient_street_1 = db.Column('recipient_st1', db.String)
    # recipient_street_2 = db.Column('recipient_st2', db.String)
    recipient_city = db.Column('city', db.String)
    recipient_state = db.Column('state', db.String)
    recipient_zip = db.Column('zip', db.String)
    recipient_prefix = db.Column('prefix', db.String)
    recipient_suffix = db.Column('suffix', db.String)
    beneficiary_committee_name = db.Column('ben_comname', db.String)
    disbursement_type = db.Column('dis_code', db.String)
    disbursement_description = db.Column('transdesc', db.String)
    disbursement_date = db.Column('date_dis', db.Date)
    disbursement_amount = db.Column('amount', db.Numeric(30, 2))
    semi_annual_bundled_refund = db.Column('refund', db.Integer)
    candidate_office = db.Column('can_off', db.String)
    candidate_office_district = db.Column('can_dist', db.String)

    filing = db.relationship(
        'EFilings',
        primaryjoin='''and_(
                        ScheduleBEfile.file_number == EFilings.file_number,
                    )''',
        foreign_keys=file_number,
        lazy='joined',
    )

    committee = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
                                ScheduleBEfile.committee_id == CommitteeHistory.committee_id,
                                extract('year', ScheduleBEfile.load_timestamp) +cast(extract('year',
                                ScheduleBEfile.load_timestamp), Integer) % 2 == CommitteeHistory.cycle,
                                )''',
        foreign_keys=committee_id,
        lazy='joined',
    )


class ScheduleC(PdfMixin, BaseItemized):
    __table_args__ = {'schema': 'disclosure'}
    __tablename__ = 'fec_fitem_sched_c'

    committee = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
            foreign(ScheduleC.committee_id) == CommitteeHistory.committee_id,
            ScheduleC.cycle == CommitteeHistory.cycle,
        )''',
        lazy='joined',
    )
    sub_id = db.Column(db.Integer, primary_key=True)
    original_sub_id = db.Column('orig_sub_id', db.Integer)
    incurred_date = db.Column('incurred_dt', db.Date)
    loan_source_prefix = db.Column('loan_src_prefix', db.String)
    loan_source_first_name = db.Column('loan_src_f_nm', db.String)
    loan_source_middle_name = db.Column('loan_src_m_nm', db.String)
    loan_source_last_name = db.Column('loan_src_l_nm', db.String)
    loan_source_suffix = db.Column('loan_src_suffix', db.String)
    loan_source_street_1 = db.Column('loan_src_st1', db.String)
    loan_source_street_2 = db.Column('loan_src_st2', db.String)
    loan_source_city = db.Column('loan_src_city', db.String)
    loan_source_state = db.Column('loan_src_st', db.String)
    loan_source_zip = db.Column('loan_src_zip', db.Integer)
    loan_source_name = db.Column('loan_src_nm', db.String, doc=docs.LOAN_SOURCE)
    loan_source_name_text = db.Column(TSVECTOR)
    entity_type = db.Column('entity_tp', db.String)
    entity_type_full = db.Column('entity_tp_desc', db.String)
    election_type = db.Column('election_tp', db.String)
    fec_election_type_full = db.Column('fec_election_tp_desc', db.String)
    fec_election_type_year = db.Column('fec_election_tp_year', db.String)
    election_type_full = db.Column('election_tp_desc', db.String)
    original_loan_amount = db.Column('orig_loan_amt', db.Float)
    payment_to_date = db.Column('pymt_to_dt', db.Float)
    loan_balance = db.Column('loan_bal', db.Float)
    # terms short for anything?
    due_date_terms = db.Column('due_dt_terms', db.String)
    interest_rate_terms = db.Column(db.String)
    secured_ind = db.Column(db.String)
    schedule_a_line_number = db.Column('sched_a_line_num', db.Integer)
    personally_funded = db.Column('pers_fund_yes_no', db.String)
    memo_code = db.Column('memo_cd', db.String)
    memo_text = db.Column(db.String)
    fec_committee_id = db.Column('fec_cmte_id', db.String)
    candidate_id = db.Column('cand_id', db.String, doc=docs.CANDIDATE_ID)
    candidate_name = db.Column('cand_nm', db.String, doc=docs.CANDIDATE_NAME)
    candidate_name_text = db.Column(TSVECTOR)
    candidate_first_name = db.Column('cand_nm_first', db.String)
    candidate_last_name = db.Column('cand_nm_last', db.String)
    candidate_middle_name = db.Column('cand_m_nm', db.String)
    candidate_prefix = db.Column('cand_prefix', db.String)
    candidate_suffix = db.Column('cand_suffix', db.String)
    candidate_office = db.Column('cand_office', db.String)
    candidate_office_full = db.Column('cand_office_desc', db.String)
    candidate_office_state = db.Column('cand_office_st', db.String)
    candidate_office_state_full = db.Column('cand_office_state_desc', db.String)
    candidate_office_district = db.Column('cand_office_district', db.String, doc=docs.DISTRICT)
    action_code = db.Column('action_cd', db.String)
    action_code_full = db.Column('action_cd_desc', db.String)
    schedule_type = db.Column(db.String)
    schedule_type_full = db.Column('schedule_type_desc', db.String)
    cycle = db.Column('election_cycle', db.Integer)
    load_date = db.Column('pg_date', db.DateTime)

    @property
    def pdf_url(self):
        if self.has_pdf:
            return utils.make_schedule_pdf_url(self.image_number)
        return None


class ScheduleD(PdfMixin, BaseItemized):
    __tablename__ = 'ofec_sched_d_mv'

    sub_id = db.Column(db.Integer, primary_key=True)
    original_sub_id = db.Column('orig_sub_id', db.Integer)
    committee_name = db.Column('cmte_nm', db.String, doc=docs.COMMITTEE_NAME)
    creditor_debtor_id = db.Column('cred_dbtr_id', db.String)
    creditor_debtor_name = db.Column('cred_dbtr_nm', db.String)
    creditor_debtor_last_name = db.Column('cred_dbtr_l_nm', db.String)
    creditor_debtor_first_name = db.Column('cred_dbtr_f_nm', db.String)
    creditor_debtor_middle_name = db.Column('cred_dbtr_m_nm', db.String)
    creditor_debtor_prefix = db.Column('cred_dbtr_prefix', db.String)
    creditor_debtor_suffix = db.Column('cred_dbtr_suffix', db.String)
    creditor_debtor_street1 = db.Column('cred_dbtr_st1', db.String)
    creditor_debtor_street2 = db.Column('cred_dbtr_st2', db.String)
    creditor_debtor_city = db.Column('cred_dbtr_city', db.String)
    creditor_debtor_state = db.Column('cred_dbtr_st', db.String)
    creditor_debtor_name_text = db.Column(TSVECTOR)
    entity_type = db.Column('entity_tp', db.String)
    nature_of_debt = db.Column('nature_debt_purpose', db.String)
    outstanding_balance_beginning_of_period = db.Column('outstg_bal_bop', db.Float)
    outstanding_balance_close_of_period = db.Column('outstg_bal_cop', db.Float)
    amount_incurred_period = db.Column('amt_incurred_per', db.Float)
    payment_period = db.Column('pymt_per', db.Float)
    candidate_id = db.Column('cand_id', db.String, doc=docs.CANDIDATE_ID)
    candidate_name = db.Column('cand_nm', db.String, doc=docs.CANDIDATE_NAME)
    candidate_first_name = db.Column('cand_nm_first', db.String)
    candidate_last_name = db.Column('cand_nm_last', db.String)
    candidate_office = db.Column('cand_office', db.String)
    candidate_office_state = db.Column('cand_office_st', db.String)
    candidate_office_state_full = db.Column('cand_office_st_desc', db.String)
    candidate_office_district = db.Column('cand_office_district', db.String)
    conduit_committee_id = db.Column('conduit_cmte_id', db.String)
    conduit_committee_name = db.Column('conduit_cmte_nm', db.String)
    conduit_committee_street1 = db.Column('conduit_cmte_st1', db.String)
    conduit_committee_street2 = db.Column('conduit_cmte_st2', db.String)
    conduit_committee_city = db.Column('conduit_cmte_city', db.String)
    conduit_committee_state = db.Column('conduit_cmte_st', db.String)
    conduit_committee_zip = db.Column('conduit_cmte_zip', db.Integer)
    action_code = db.Column('action_cd', db.String)
    action_code_full = db.Column('action_cd_desc', db.String)
    schedule_type = db.Column(db.String)
    schedule_type_full = db.Column('schedule_type_desc', db.String)
    election_cycle = db.Column(db.Integer)
    coverage_start_date = db.Column(db.Date, index=True, doc=docs.COVERAGE_START_DATE)
    coverage_end_date = db.Column(db.Date, index=True, doc=docs.COVERAGE_END_DATE)
    report_year = db.Column('rpt_yr', db.Integer, index=True, doc=docs.REPORT_YEAR)
    report_type = db.Column('rpt_tp', db.String, index=True, doc=docs.REPORT_TYPE)

    committee = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
            foreign(ScheduleD.committee_id) == CommitteeHistory.committee_id,
            ScheduleD.election_cycle == CommitteeHistory.cycle,
        )''',
        lazy='joined',
    )

    @property
    def pdf_url(self):
        if self.has_pdf:
            return utils.make_schedule_pdf_url(self.image_number)
        return None


class ScheduleE(PdfMixin, BaseItemized):
    __tablename__ = 'ofec_sched_e_mv'

    sub_id = db.Column(db.String, primary_key=True)
    # Payee info
    payee_prefix = db.Column(db.String)
    payee_name = db.Column('pye_nm', db.String)
    payee_name_text = db.Column(TSVECTOR)
    payee_first_name = db.Column('payee_f_nm', db.String)
    payee_middle_name = db.Column('payee_m_nm', db.String)
    payee_last_name = db.Column('payee_l_nm', db.String)
    payee_suffix = db.Column(db.String)
    payee_street_1 = db.Column('pye_st1', db.String)
    payee_street_2 = db.Column('pye_st2', db.String)
    payee_city = db.Column('pye_city', db.String)
    payee_state = db.Column('pye_st', db.String)
    payee_zip = db.Column('pye_zip', db.String)
    # Primary transaction info
    previous_file_number = db.Column('prev_file_num', db.Integer)
    amendment_indicator = db.Column('amndt_ind', db.String, doc=docs.AMENDMENT_INDICATOR)
    amendment_number = db.Column('amndt_number', db.Integer, doc=docs.AMENDMENT_NUMBER)
    is_notice = db.Column(db.Boolean, index=True)
    expenditure_description = db.Column('exp_desc', db.String)
    expenditure_date = db.Column('exp_dt', db.Date)
    dissemination_date = db.Column('dissem_dt', db.Date)
    most_recent = db.Column('most_recent', db.Boolean, doc=docs.MOST_RECENT)
    filing_date = db.Column('filing_date', db.Date)
    expenditure_amount = db.Column('exp_amt', db.Float)
    office_total_ytd = db.Column('cal_ytd_ofc_sought', db.Float)
    category_code = db.Column('catg_cd', db.String)
    category_code_full = db.Column('catg_cd_desc', db.String)
    support_oppose_indicator = db.Column('s_o_ind', db.String)
    memo_code = db.Column('memo_cd', db.String)
    memo_code_full = db.Column('memo_cd_desc', db.String)
    memo_text = db.Column(db.String)
    # Candidate info
    candidate_id = db.Column('s_o_cand_id', db.String)
    candidate = utils.related_candidate_history('candidate_id', cycle_label='report_year')
    candidate_name = db.Column('s_o_cand_nm', db.String, doc=docs.CANDIDATE_NAME)
    candidate_prefix = db.Column('s_o_cand_prefix', db.String)
    candidate_first_name = db.Column('s_o_cand_nm_first', db.String)
    candidate_middle_name = db.Column('s_o_cand_m_nm', db.String)
    candidate_last_name = db.Column('s_o_cand_nm_last', db.String)
    candidate_suffix = db.Column('s_o_cand_suffix', db.String)
    candidate_office = db.Column('cand_office', db.String, doc=docs.OFFICE)
    candidate_office_state = db.Column('cand_office_st', db.String, doc=docs.STATE_GENERIC)
    candidate_office_district = db.Column('cand_office_district', db.String, doc=docs.DISTRICT)
    candidate_party = db.Column('cand_pty_affiliation', db.String, doc=docs.PARTY)
    # Conduit info
    conduit_committee_id = db.Column('conduit_cmte_id', db.String)
    conduit_committee_name = db.Column('conduit_cmte_nm', db.String)
    conduit_committee_street1 = db.Column('conduit_cmte_st1', db.String)
    conduit_committee_street2 = db.Column('conduit_cmte_st2', db.String)
    conduit_committee_city = db.Column('conduit_cmte_city', db.String)
    conduit_committee_state = db.Column('conduit_cmte_st', db.String)
    conduit_committee_zip = db.Column('conduit_cmte_zip', db.Integer)
    # Transaction meta info
    independent_sign_name = db.Column('indt_sign_nm', db.String)
    independent_sign_date = db.Column('indt_sign_dt', db.Date)
    notary_sign_name = db.Column('notary_sign_nm', db.String)
    notary_sign_date = db.Column('notary_sign_dt', db.Date)
    notary_commission_expiration_date = db.Column('notary_commission_exprtn_dt', db.Date)
    election_type = db.Column('election_tp', db.String, doc=docs.ELECTION_TYPE)
    election_type_full = db.Column('fec_election_tp_desc', db.String, doc=docs.ELECTION_TYPE)
    back_reference_transaction_id = db.Column('back_ref_tran_id', db.String)
    back_reference_schedule_name = db.Column('back_ref_sched_nm', db.String)
    filer_prefix = db.Column(db.String)
    filer_first_name = db.Column('filer_f_nm', db.String)
    filer_middle_name = db.Column('filer_m_nm', db.String)
    filer_last_name = db.Column('filer_l_nm', db.String)
    filer_suffix = db.Column(db.String)
    transaction_id = db.Column('tran_id', db.String)
    original_sub_id = db.Column('orig_sub_id', db.Integer)
    action_code = db.Column('action_cd', db.String)
    action_code_full = db.Column('action_cd_desc', db.String)
    # Auxiliary fields
    schedule_type = db.Column('schedule_type', db.String)
    schedule_type_full = db.Column('schedule_type_desc', db.String)
    pdf_url = db.Column(db.String)
    spender_name_text = db.Column(TSVECTOR)


class ScheduleEEfile(BaseRawItemized):
    __tablename__ = 'real_efile_se_f57_vw'

    filing_form = db.Column('filing_form', db.String)
    is_notice = db.Column(db.Boolean, index=True)
    file_number = db.Column("repid", db.Integer, index=True, primary_key=True)
    related_line_number = db.Column("rel_lineno", db.Integer, primary_key=True)
    committee_id = db.Column("comid", db.String, doc=docs.COMMITTEE_ID)
    # payee info
    payee_prefix = db.Column('prefix', db.String)
    # need to add vectorized column
    # payee_name_text = db.Column(TSVECTOR)
    payee_first_name = db.Column('fname', db.String)
    payee_middle_name = db.Column('mname', db.String)
    payee_last_name = db.Column('lname', db.String)
    payee_suffix = db.Column('suffix', db.String)
    payee_street_1 = db.Column('str1', db.String)
    payee_street_2 = db.Column('str2', db.String)
    payee_city = db.Column('city', db.String)
    payee_state = db.Column('state', db.String)
    payee_zip = db.Column('zip', db.String)
    # pcf == person completing form -> filer?
    filer_first_name = db.Column('pcf_lname', db.String)
    filer_middle_name = db.Column('pcf_mname', db.String)
    filer_last_name = db.Column('pcf_fname', db.String)
    filer_suffix = db.Column('pcf_suffix', db.String)
    filer_prefix = db.Column('pcf_prefix', db.String)
    # Candidate info
    candidate_id = db.Column('so_canid', db.String)
    candidate_name = db.Column('so_can_name', db.String, doc=docs.CANDIDATE_NAME)
    candidate_prefix = db.Column('so_can_prefix', db.String)
    candidate_first_name = db.Column('so_can_fname', db.String)
    candidate_middle_name = db.Column('so_can_mname', db.String)
    candidate_suffix = db.Column('so_can_suffix', db.String)
    candidate_office = db.Column('so_can_off', db.String, doc=docs.OFFICE)
    candidate_office_state = db.Column('so_can_state', db.String, doc=docs.STATE_GENERIC)
    candidate_office_district = db.Column('so_can_dist', db.String, doc=docs.DISTRICT)
    expenditure_description = db.Column('exp_desc', db.String)
    expenditure_date = db.Column('exp_date', db.Date)
    expenditure_amount = db.Column('amount', db.Integer)
    office_total_ytd = db.Column('ytd', db.Float)
    category_code = db.Column('cat_code', db.String)
    support_oppose_indicator = db.Column('supop', db.String, doc=docs.SUPPORT_OPPOSE_INDICATOR)
    notary_sign_date = db.Column('not_date', db.Date)
    dissemination_date = db.Column('dissem_dt', db.Date, doc=docs.DISSEMINATION_DATE)
    cand_fulltxt = db.Column(TSVECTOR, doc=docs.CANDIDATE_FULL_SEARCH)
    candidate_party = db.Column('cand_pty_affiliation', db.String, doc=docs.PARTY)
    most_recent = db.Column('most_recent', db.Boolean, doc=docs.MOST_RECENT)
    filing = db.relationship(
        'EFilings',
        primaryjoin='''and_(
                            ScheduleEEfile.file_number == EFilings.file_number,
                        )''',
        foreign_keys=file_number,
        lazy='joined',
        innerjoin='True',
    )
    committee = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
                            ScheduleEEfile.committee_id == CommitteeHistory.committee_id,
                            extract('year', ScheduleEEfile.load_timestamp) +cast(extract('year',
                            ScheduleEEfile.load_timestamp), Integer) % 2 == CommitteeHistory.cycle,
                        )''',
        foreign_keys=committee_id,
        lazy='joined',
    )

    @hybrid_property
    def payee_name(self):
        name = name_generator(
            self.payee_last_name,
            self.payee_prefix,
            self.payee_first_name,
            self.payee_middle_name,
            self.payee_suffix
        )
        name = (
            name
            if name
            else None
        )
        return name


class ScheduleF(PdfMixin, BaseItemized):
    __table_args__ = {'schema': 'disclosure'}
    __tablename__ = 'fec_fitem_sched_f'

    sub_id = db.Column(db.Integer, primary_key=True)
    original_sub_id = db.Column('orig_sub_id', db.Integer)
    committee_designated_coordinated_expenditure_indicator = db.Column('cmte_desg_coord_exp_ind', db.String)
    committee_name = db.Column('cmte_nm', db.String)
    entity_type = db.Column('entity_tp', db.String)
    entity_type_desc = db.Column('entity_tp_desc', db.String)
    designated_committee_id = db.Column('desg_cmte_id', db.String)
    designated_committee_name = db.Column('desg_cmte_nm', db.String)
    subordinate_committee = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
            foreign(ScheduleF.subordinate_committee_id) == CommitteeHistory.committee_id,
            ScheduleF.report_year + ScheduleF.report_year % 2 == CommitteeHistory.cycle,
        )'''
    )
    subordinate_committee_id = db.Column('subord_cmte_id', db.String)
    """
    These are included here as well if subordinate is not null, but I
    think keeping it as a nested json object is best at least for consistency
    across the api
    subordinate_committee_name = db.Column('subord_cmte_nm', db.String)
    subordinate_committee_street1 = db.Column('subord_cmte_st1', db.String)
    subordinate_committee_street2 = db.Column('subord_cmte_st2', db.String)
    subordinate_committee_city = db.Column('subord_cmte_city', db.String)
    subordinate_committee_state = db.Column('subord_cmte_st', db.String)
    subordinate_committee_zip = db.Column('subord_cmte_zip', db.Integer)
    """
    payee_name = db.Column('pye_nm', db.String)
    payee_last_name = db.Column('payee_l_nm', db.String)
    payee_middle_name = db.Column('payee_m_nm', db.String)
    payee_first_name = db.Column('payee_f_nm', db.String)
    payee_name_text = db.Column(TSVECTOR)
    aggregate_general_election_expenditure = db.Column('aggregate_gen_election_exp', db.String)
    expenditure_type = db.Column('exp_tp', db.String)
    expenditure_type_full = db.Column('exp_tp_desc', db.String)
    expenditure_purpose_full = db.Column('exp_purpose_desc', db.String)
    expenditure_date = db.Column('exp_dt', db.DateTime)
    expenditure_amount = db.Column('exp_amt', db.Integer)
    candidate_id = db.Column('cand_id', db.String, doc=docs.CANDIDATE_ID)
    candidate_name = db.Column('cand_nm', db.String, doc=docs.CANDIDATE_NAME)
    candidate_prefix = db.Column('cand_prefix', db.String)
    candidate_first_name = db.Column('cand_nm_first', db.String)
    candidate_middle_name = db.Column('cand_m_nm', db.String)
    candidate_last_name = db.Column('cand_nm_last', db.String)
    candidate_suffix = db.Column('cand_suffix', db.String)
    candidate_office = db.Column('cand_office', db.String)
    candidate_office_full = db.Column('cand_office_desc', db.String)
    candidate_office_state = db.Column('cand_office_st', db.String)
    candidate_office_state_full = db.Column('cand_office_st_desc', db.String)
    candidate_office_district = db.Column('cand_office_district', db.String)
    conduit_committee_id = db.Column('conduit_cmte_id', db.String)
    conduit_committee_name = db.Column('conduit_cmte_nm', db.String)
    conduit_committee_street1 = db.Column('conduit_cmte_st1', db.String)
    conduit_committee_street2 = db.Column('conduit_cmte_st2', db.String)
    conduit_committee_city = db.Column('conduit_cmte_city', db.String)
    conduit_committee_state = db.Column('conduit_cmte_st', db.String)
    conduit_committee_zip = db.Column('conduit_cmte_zip', db.Integer)
    action_code = db.Column('action_cd', db.String)
    action_code_full = db.Column('action_cd_desc', db.String)
    back_reference_transaction_id = db.Column('back_ref_tran_id', db.String)
    back_reference_schedule_name = db.Column('back_ref_sched_nm', db.String)
    memo_code = db.Column('memo_cd', db.String)
    memo_code_full = db.Column('memo_cd_desc', db.String)
    memo_text = db.Column(db.String)
    unlimited_spending_flag = db.Column('unlimited_spending_flg', db.String)
    unlimited_spending_flag_full = db.Column('unlimited_spending_flg_desc', db.String)
    catolog_code = db.Column('catg_cd', db.String)
    catolog_code_full = db.Column('catg_cd_desc', db.String)
    schedule_type = db.Column(db.String)
    schedule_type_full = db.Column('schedule_type_desc', db.String)
    load_date = db.Column('pg_date', db.DateTime)
    election_cycle = db.Column(db.Integer)

    @property
    def pdf_url(self):
        if self.has_pdf:
            return utils.make_schedule_pdf_url(self.image_number)
        return None


class ScheduleH4(BaseItemized):
    __table_args__ = {'schema': 'disclosure'}
    __tablename__ = 'fec_fitem_sched_h4'

    committee = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
            foreign(ScheduleH4.committee_id) == CommitteeHistory.committee_id,
            ScheduleH4.cycle == CommitteeHistory.cycle,
        )'''
    )

    # Recipient info
    committee_id = db.Column('filer_cmte_id', db.String)  # override from BaseItemized
    entity_type = db.Column('entity_tp', db.String)
    entity_type_desc = db.Column('entity_tp_desc', db.String)
    payee_name = db.Column('pye_nm', db.String)
    payee_street_1 = db.Column('pye_st1', db.String)
    payee_street_2 = db.Column('pye_st2', db.String)
    payee_city = db.Column('pye_city', db.String)
    payee_state = db.Column('pye_st', db.String)
    payee_zip = db.Column('pye_zip', db.String)
    filer_committee_name = db.Column('filer_cmte_nm', db.String)
    # Primary transaction info
    # event_purpose_category_type = db.Column('evt_purpose_category_tp', db.String)
    # event_purpose_category_type_description = db.Column('evt_purpose_category_tp_desc', db.String)
    event_purpose_name = db.Column('evt_purpose_nm', db.String)
    event_purpose_description = db.Column('evt_purpose_desc', db.String)
    event_purpose_category_type = db.Column('evt_purpose_category_tp', db.String)
    event_purpose_category_type_full = db.Column('evt_purpose_category_tp_desc', db.String)
    memo_code = db.Column('memo_cd', db.String)
    memo_code_description = db.Column('memo_cd_desc', db.String)
    memo_text = db.Column('memo_text', db.String)
    event_purpose_date = db.Column('evt_purpose_dt', db.Date)
    disbursement_amount = db.Column('ttl_amt_disb', db.Numeric(30, 2))
    # Related candidate info
    candidate_office = db.Column('cand_office', db.String)
    candidate_office_description = db.Column('cand_office_desc', db.String)
    candidate_office_district = db.Column('cand_office_district', db.String)
    candidate_id = db.Column('cand_id', db.String, doc=docs.CANDIDATE_ID)
    candidate_name = db.Column('cand_nm', db.String, doc=docs.CANDIDATE_NAME)
    candidate_first_name = db.Column('cand_nm_first', db.String)
    candidate_last_name = db.Column('cand_nm_last', db.String)
    candidate_office_state = db.Column('cand_office_st', db.String)
    candidate_office_state_full = db.Column('cand_office_st_desc', db.String)
    # Transaction meta info
    amendment_indicator = db.Column('action_cd', db.String)
    amendment_indicator_desc = db.Column('action_cd_desc', db.String)
    schedule_type = db.Column('schedule_type', db.String)
    schedule_type_full = db.Column('schedule_type_desc', db.String)
    load_date = db.Column('pg_date', db.DateTime)
    sub_id = db.Column(db.Integer, primary_key=True)
    original_sub_id = db.Column('orig_sub_id', db.Integer)
    back_reference_transaction_id = db.Column('back_ref_tran_id', db.String)
    back_reference_schedule_id = db.Column('back_ref_sched_id', db.String)
    # Payee info
    payee_last_name = db.Column('payee_l_nm', db.String)
    payee_first_name = db.Column('payee_f_nm', db.String)
    payee_middle_name = db.Column('payee_m_nm', db.String)
    payee_prefix = db.Column(db.String)
    payee_suffix = db.Column(db.String)
    # Category info
    category_code = db.Column('catg_cd', db.String)
    category_code_full = db.Column('catg_cd_desc', db.String)
    # Conduit info
    conduit_committee_id = db.Column('conduit_cmte_id', db.String)
    conduit_committee_name = db.Column('conduit_cmte_nm', db.String)
    conduit_committee_street1 = db.Column('conduit_cmte_st1', db.String)
    conduit_committee_street2 = db.Column('conduit_cmte_st2', db.String)
    conduit_committee_city = db.Column('conduit_cmte_city', db.String)
    conduit_committee_state = db.Column('conduit_cmte_st', db.String)
    conduit_committee_zip = db.Column('conduit_cmte_zip', db.Integer)
    # TODO: determine place for these:
    federal_share = db.Column('fed_share', db.Numeric(14, 2))
    nonfederal_share = db.Column('nonfed_share', db.Numeric(14, 2))
    administrative_voter_drive_activity_indicator = db.Column('admin_voter_drive_acty_ind', db.String)
    fundraising_activity_indicator = db.Column('fndrsg_acty_ind', db.String)
    exempt_activity_indicator = db.Column('exempt_acty_ind', db.String)
    direct_candidate_support_activity_indicator = db.Column('direct_cand_supp_acty_ind', db.String)
    event_amount_year_to_date = db.Column('evt_amt_ytd', db.Numeric(14, 2))
    additional_description = db.Column('add_desc', db.String)
    administrative_activity_inidcator = db.Column('admin_acty_ind', db.String)
    general_voter_drive_activity_indicator = db.Column('gen_voter_drive_acty_ind', db.String)
    disbursement_type = db.Column('disb_tp', db.String)
    disbursement_type_full = db.Column('disb_tp_desc', db.String)
    published_committee_reference_parity_check = db.Column('pub_comm_ref_pty_chk', db.String)
    filing_form = db.Column('filing_form', db.String)
    report_type = db.Column('rpt_tp', db.String)
    report_year = db.Column('rpt_yr', db.Numeric(4, 0))
    cycle = db.Column('election_cycle', db.Numeric(4, 0))

    @hybrid_property
    def sort_expressions(self):
        return {
            'event_purpose_date': {
                'expression': sa.func.coalesce(
                    self.event_purpose_date,
                    sa.cast('9999-12-31', sa.Date)
                ),
                'field': ma.fields.Date,
                'type': 'date',
                'null_sort': self.event_purpose_date,
            },
        }
