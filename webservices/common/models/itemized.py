from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.dialects.postgresql import TSVECTOR
import sqlalchemy as sa

from webservices import docs, utils

from .base import db
from .reports import PdfMixin


class BaseItemized(db.Model):
    __abstract__ = True

    committee = utils.related_committee_history('committee_id', cycle_label='report_year')
    committee_id = db.Column('cmte_id', db.String, doc=docs.COMMITTEE_ID)
    report_year = db.Column('rpt_yr', db.Integer, doc=docs.REPORT_YEAR)
    report_type = db.Column('rpt_tp', db.String, doc=docs.REPORT_TYPE)
    election_type = db.Column('election_tp', db.String, doc=docs.ELECTION_TYPE)
    election_type_full = db.Column('election_tp_desc', db.String)
    image_number = db.Column('image_num', db.String, doc=docs.IMAGE_NUMBER)
    filing_form = db.Column(db.String)
    link_id = db.Column(db.Integer)
    line_number = db.Column('line_num', db.String)
    transaction_id = db.Column('tran_id', db.String)
    file_number = db.Column('file_num', db.Integer)

    @hybrid_property
    def memoed_subtotal(self):
        return self.memo_code == 'X'


class ScheduleA(BaseItemized):
    __tablename__ = 'ofec_sched_a_master'

    # Contributor info
    entity_type = db.Column('entity_tp', db.String)
    entity_type_desc = db.Column('entity_tp_desc', db.String)
    contributor_prefix = db.Column('contbr_prefix', db.String)
    contributor = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
            foreign(ScheduleA.contributor_id) == CommitteeHistory.committee_id,
            ScheduleA.report_year + ScheduleA.report_year % 2 == CommitteeHistory.cycle,
        )'''
    )
    contributor_name = db.Column('contbr_nm', db.String, doc=docs.CONTRIBUTOR_NAME)
    contributor_name_text = db.Column(TSVECTOR)
    contributor_first_name = db.Column('contbr_nm_first', db.String)
    contributor_middle_name = db.Column('contbr_m_nm', db.String)
    contributor_last_name = db.Column('contbr_nm_last', db.String)
    contributor_suffix = db.Column('contbr_suffix', db.String)
    # Street address omitted per FEC policy
    # contributor_street_1 = db.Column('contbr_st1', db.String)
    # contributor_street_2 = db.Column('contbr_st2', db.String)
    contributor_city = db.Column('contbr_city', db.String, doc=docs.CONTRIBUTOR_CITY)
    contributor_state = db.Column('contbr_st', db.String, doc=docs.CONTRIBUTOR_STATE)
    contributor_zip = db.Column('contbr_zip', db.String, doc=docs.CONTRIBUTOR_ZIP)
    contributor_employer = db.Column('contbr_employer', db.String, doc=docs.CONTRIBUTOR_EMPLOYER)
    contributor_employer_text = db.Column(TSVECTOR)
    contributor_occupation = db.Column('contbr_occupation', db.String, doc=docs.CONTRIBUTOR_OCCUPATION)
    contributor_occupation_text = db.Column(TSVECTOR)
    contributor_id = db.Column('clean_contbr_id', db.String, doc=docs.CONTRIBUTOR_ID)
    contributor_aggregate_ytd = db.Column('contb_aggregate_ytd', db.Numeric(30, 2))
    is_individual = db.Column(db.Boolean, index=True)

    # Primary transaction info
    receipt_type = db.Column('receipt_tp', db.String)
    receipt_type_full = db.Column('receipt_desc', db.String)
    memo_code = db.Column('memo_cd', db.String)
    memo_code_full = db.Column('memo_cd_desc', db.String)
    memo_text = db.Column(db.String)
    contribution_receipt_date = db.Column('contb_receipt_dt', db.Date)
    contribution_receipt_amount = db.Column('contb_receipt_amt', db.Numeric(30, 2))

    # Related candidate info
    candidate_office = db.Column('cand_office', db.String)
    candidate_office_description = db.Column('cand_office_desc', db.String)
    candidate_office_district = db.Column('cand_office_district', db.String)

    # Transaction meta info
    fec_election_type_desc = db.Column('fec_election_tp_desc', db.String)
    fec_election_year = db.Column('fec_election_yr', db.String)
    two_year_transaction_period = db.Column(db.SmallInteger, doc=docs.TWO_YEAR_TRANSACTION_PERIOD)
    amendment_indicator = db.Column('action_cd', db.String)
    amendment_indicator_desc = db.Column('action_cd_desc', db.String)
    schedule_type = db.Column('schedule_type', db.String)
    schedule_type_full = db.Column('schedule_type_desc', db.String)
    increased_limit = db.Column(db.String)
    load_date = db.Column('pg_date', db.DateTime)
    # transaction_id = db.Column('tran_id', db.Integer)
    sub_id = db.Column(db.Integer, primary_key=True)
    original_sub_id = db.Column('orig_sub_id', db.Integer)
    back_reference_transaction_id = db.Column('back_ref_tran_id', db.String)
    back_reference_schedule_name = db.Column('back_ref_sched_nm', db.String)

    pdf_url = db.Column(db.String)



class ScheduleB(BaseItemized):
    __tablename__ = 'ofec_sched_b_master'

    # Recipient info
    entity_type = db.Column('entity_tp', db.String)
    entity_type_desc = db.Column('entity_tp_desc', db.String)
    recipient_committee_id = db.Column('clean_recipient_cmte_id', db.String)
    recipient_committee = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
            foreign(ScheduleB.recipient_committee_id) == CommitteeHistory.committee_id,
            ScheduleB.report_year + ScheduleB.report_year % 2 == CommitteeHistory.cycle,
        )'''
    )
    recipient_name = db.Column('recipient_nm', db.String)
    recipient_name_text = db.Column(TSVECTOR)
    # Street address omitted per FEC policy
    # recipient_street_1 = db.Column('recipient_st1', db.String)
    # recipient_street_2 = db.Column('recipient_st2', db.String)
    recipient_city = db.Column(db.String)
    recipient_state = db.Column('recipient_st', db.String)
    recipient_zip = db.Column(db.String)
    beneficiary_committee_name = db.Column('benef_cmte_nm', db.String)
    national_committee_nonfederal_account = db.Column('national_cmte_nonfed_acct', db.String)

    # Primary transaction info
    disbursement_type = db.Column('disb_tp', db.String)
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

    # Transaction meta info
    election_type = db.Column('election_tp', db.String) # ? election_type looks like it's included in BaseItemized already
    election_type_full = db.Column('election_tp_desc', db.String)
    fec_election_type_desc = db.Column('fec_election_tp_desc', db.String)
    fec_election_year = db.Column('fec_election_tp_year', db.String)
    two_year_transaction_period = db.Column(db.SmallInteger, doc=docs.TWO_YEAR_TRANSACTION_PERIOD)
    amendment_indicator = db.Column('action_cd', db.String)
    amendment_indicator_desc = db.Column('action_cd_desc', db.String)
    schedule_type = db.Column('schedule_type', db.String)
    schedule_type_full = db.Column('schedule_type_desc', db.String)
    load_date = db.Column('pg_date', db.DateTime)
    # transaction_id = db.Column('tran_id', db.Integer)
    sub_id = db.Column(db.Integer, primary_key=True)
    original_sub_id = db.Column('orig_sub_id', db.Integer)
    back_reference_transaction_id = db.Column('back_ref_tran_id', db.String)
    back_reference_schedule_id = db.Column('back_ref_sched_id', db.String)
    semi_annual_bundled_refund = db.Column('semi_an_bundled_refund', db.Numeric(30, 2))

    pdf_url = db.Column(db.String)


class ScheduleC(PdfMixin,BaseItemized):
    __tablename__ = 'fec_vsum_sched_c'
    sub_id = db.Column(db.Integer, primary_key=True)
    original_sub_id = db.Column('orig_sub_id', db.Integer)
    incurred_date = db.Column('incurred_dt', db.DateTime)
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
    loan_source_name = db.Column('loan_src_nm', db.String)
    entity_type = db.Column('entity_tp', db.String)
    entity_type_full = db.Column('entity_tp_desc', db.String)
    election_type = db.Column('election_tp', db.String)
    fec_election_type_full = db.Column('fec_election_tp_desc', db.String)
    fec_election_type_year = db.Column('fec_election_tp_year', db.String)
    election_type_full = db.Column('election_tp_desc', db.String)
    original_loan_amount = db.Column('orig_loan_amt', db.Float)
    payment_to_date = db.Column('pymt_to_dt', db.Float)
    loan_balance = db.Column('loan_bal', db.Float)
    #terms short for anything?
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

    @property
    def pdf_url(self):
        if self.has_pdf:
            return utils.make_schedule_pdf_url(self.image_number)
        return None


class ScheduleE(BaseItemized):
    __tablename__ = 'ofec_sched_e'

    sched_e_sk = db.Column(db.Integer, primary_key=True)

    # Committe info
    committee_name = db.Column('cmte_nm', db.String, doc=docs.COMMITTEE_ID)

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
    is_notice = db.Column(db.Boolean, index=True)
    expenditure_description = db.Column('exp_desc', db.String)
    expenditure_date = db.Column('exp_dt', db.Date)
    dissemination_date = db.Column('dissem_dt', db.Date)
    expenditure_amount = db.Column('exp_amt', db.Float)
    office_total_ytd = db.Column('cal_ytd_ofc_sought', db.Float)
    category_code = db.Column('catg_cd', db.String)
    category_code_full = db.Column('catg_cd_desc', db.String)
    support_oppose_indicator = db.Column('s_o_ind', db.String)

    # Candidate info
    candidate_id = db.Column('s_o_cand_id', db.String)
    candidate = utils.related_candidate_history('candidate_id', cycle_label='report_year')
    candidate_prefix = db.Column('s_0_cand_prefix', db.String)
    candidate_name = db.Column('s_o_cand_nm', db.String, doc=docs.CANDIDATE_NAME)
    candidate_first_name = db.Column('s_0_cand_f_nm', db.String)
    candidate_middle_name = db.Column('s_0_cand_m_nm', db.String)
    candidate_last_name = db.Column('s_0_cand_l_nm', db.String)
    candidate_suffix = db.Column('s_0_cand_suffix', db.String)
    candidate_office = db.Column('s_o_cand_office', db.String, doc=docs.OFFICE)
    cand_office_state = db.Column('s_o_cand_office_st', db.String, doc=docs.STATE_GENERIC)
    cand_office_district = db.Column('s_o_cand_office_district', db.String, doc=docs.DISTRICT)
    election_type = db.Column('election_tp', db.String, doc=docs.ELECTION_TYPE)
    election_type_full = db.Column('fec_election_tp_desc', db.String, doc=docs.ELECTION_TYPE)

    # Transaction meta info
    # transaction_id = db.Column('tran_id', db.Integer)
    independent_sign_name = db.Column('indt_sign_nm', db.String)
    independent_sign_date = db.Column('indt_sign_dt', db.Date)
    notary_sign_name = db.Column('notary_sign_nm', db.String)
    notary_sign_date = db.Column('notary_sign_dt', db.Date)
    notary_commission_expiration_date = db.Column('notary_commission_exprtn_dt', db.Date)
    back_reference_transaction_id = db.Column('back_ref_tran_id', db.String)
    back_reference_schedule_name = db.Column('back_ref_sched_nm', db.String)
    record_number = db.Column('record_num', db.Integer)
    report_primary_general = db.Column('rpt_pgi', db.String)
    filer_prefix = db.Column(db.String)
    filer_first_name = db.Column('filer_f_nm', db.String)
    filer_middle_name = db.Column('filer_m_nm', db.String)
    filer_last_name = db.Column('filer_l_nm', db.String)
    filer_suffix = db.Column(db.String)
    receipt_date = db.Column('receipt_dt', db.Date)
    load_date = db.Column(db.DateTime, doc=docs.LOAD_DATE)
    update_date = db.Column(db.DateTime, doc=docs.UPDATE_DATE)

    pdf_url = db.Column(db.String)



