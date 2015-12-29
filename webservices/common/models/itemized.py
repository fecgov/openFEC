from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.dialects.postgresql import TSVECTOR

from webservices import utils

from .base import db


class BaseItemized(db.Model):
    __abstract__ = True

    committee_id = db.Column('cmte_id', db.String)
    committee = utils.related_committee_history('committee_id', cycle_label='report_year')
    report_year = db.Column('rpt_yr', db.Integer)
    report_type = db.Column('rpt_tp', db.String)
    form_type = db.Column('form_tp', db.String)
    entity_type = db.Column('entity_tp', db.String)
    image_number = db.Column('image_num', db.String)
    memo_code = db.Column('memo_cd', db.String)
    memo_text = db.Column(db.String)
    filing_type = db.Column(db.String)
    filing_form = db.Column(db.String)
    link_id = db.Column(db.Integer)
    sub_id = db.Column(db.Integer)
    original_sub_id = db.Column('orig_sub_id', db.Integer)
    amendment_indicator = db.Column('amndt_ind', db.String)
    line_number = db.Column('line_num', db.String)
    tran_id = db.Column(db.String)
    transaction_id = db.Column(db.Integer)
    status = db.Column(db.String)
    file_number = db.Column('file_num', db.Integer)

    @hybrid_property
    def memoed_subtotal(self):
        return self.memo_code == 'X'

    @property
    def pdf_url(self):
        return utils.make_image_pdf_url(self.image_number)


class ScheduleA(BaseItemized):
    __tablename__ = 'ofec_sched_a_master'

    sched_a_sk = db.Column(db.Integer, primary_key=True)
    is_individual = db.Column(db.Boolean, index=True)
    contributor_id = db.Column('clean_contbr_id', db.String)
    contributor = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
            foreign(ScheduleA.contributor_id) == CommitteeHistory.committee_id,
            ScheduleA.report_year + ScheduleA.report_year % 2 == CommitteeHistory.cycle,
        )'''
    )
    contributor_name = db.Column('contbr_nm', db.String)
    contributor_prefix = db.Column('contbr_prefix', db.String)
    contributor_first_name = db.Column('contbr_f_nm', db.String)
    contributor_middle_name = db.Column('contbr_m_nm', db.String)
    contributor_last_name = db.Column('contbr_l_nm', db.String)
    contributor_suffix = db.Column('contbr_suffix', db.String)
    # Street address omitted per FEC policy
    # contributor_street_1 = db.Column('contbr_st1', db.String)
    # contributor_street_2 = db.Column('contbr_st2', db.String)
    contributor_city = db.Column('contbr_city', db.String)
    contributor_state = db.Column('contbr_st', db.String)
    contributor_zip = db.Column('contbr_zip', db.String)
    contributor_employer = db.Column('contbr_employer', db.String)
    contributor_occupation = db.Column('contbr_occupation', db.String)
    contributor_aggregate_ytd = db.Column('contb_aggregate_ytd', db.Numeric(30, 2))
    contribution_receipt_date = db.Column('contb_receipt_dt', db.Date)
    contribution_receipt_amount = db.Column('contb_receipt_amt', db.Numeric(30, 2))
    receipt_type = db.Column('receipt_tp', db.String)
    receipt_type_full = db.Column('receipt_desc', db.String)
    election_type = db.Column('election_tp', db.String)
    election_type_full = db.Column('election_tp_desc', db.String)
    back_reference_transaction_id = db.Column('back_ref_tran_id', db.String)
    back_reference_schedule_name = db.Column('back_ref_sched_nm', db.String)
    national_committee_nonfederal_account = db.Column('national_cmte_nonfed_acct', db.String)
    record_number = db.Column('record_num', db.Integer)
    report_primary_general = db.Column('rpt_pgi', db.String)
    form_type_full = db.Column('form_tp_cd', db.String)
    receipt_date = db.Column('receipt_dt', db.Date)
    increased_limit = db.Column(db.String)
    load_date = db.Column(db.DateTime)
    update_date = db.Column(db.DateTime)

    # Auxiliary fields
    contributor_name_text = db.Column(TSVECTOR)
    contributor_employer_text = db.Column(TSVECTOR)
    contributor_occupation_text = db.Column(TSVECTOR)


class ScheduleB(BaseItemized):
    __tablename__ = 'ofec_sched_b_master'

    sched_b_sk = db.Column(db.Integer, primary_key=True)
    recipient_committee_id = db.Column('clean_recipient_cmte_id', db.String)
    recipient_committee = db.relationship(
        'CommitteeHistory',
        primaryjoin='''and_(
            foreign(ScheduleB.recipient_committee_id) == CommitteeHistory.committee_id,
            ScheduleB.report_year + ScheduleB.report_year % 2 == CommitteeHistory.cycle,
        )'''
    )
    recipient_name = db.Column('recipient_nm', db.String)
    # Street address omitted per FEC policy
    # recipient_street_1 = db.Column('recipient_st1', db.String)
    # recipient_street_2 = db.Column('recipient_st2', db.String)
    recipient_city = db.Column(db.String)
    recipient_state = db.Column('recipient_st', db.String)
    recipient_zip = db.Column(db.String)
    disbursement_type = db.Column('disb_tp', db.String)
    disbursement_description = db.Column('disb_desc', db.String)
    disbursement_date = db.Column('disb_dt', db.Date)
    disbursement_amount = db.Column('disb_amt', db.Numeric(30, 2))
    back_reference_transaction_id = db.Column('back_ref_tran_id', db.String)
    back_reference_schedule_id = db.Column('back_ref_sched_id', db.String)
    national_committee_nonfederal_account = db.Column('national_cmte_nonfed_acct', db.String)
    election_type = db.Column('election_tp', db.String)
    election_type_full = db.Column('election_tp_desc', db.String)
    record_number = db.Column('record_num', db.Integer)
    report_primary_general = db.Column('rpt_pgi', db.String)
    receipt_date = db.Column('receipt_dt', db.Date)
    beneficiary_committee_name = db.Column('benef_cmte_nm', db.String)
    semi_annual_bundled_refund = db.Column('semi_an_bundled_refund', db.Numeric(30, 2))
    load_date = db.Column(db.DateTime)
    update_date = db.Column(db.DateTime)

    # Auxiliary fields
    recipient_name_text = db.Column(TSVECTOR)
    disbursement_description_text = db.Column(TSVECTOR)
    disbursement_purpose_category = db.String()


class ScheduleE(BaseItemized):
    __tablename__ = 'ofec_sched_e'

    sched_e_sk = db.Column(db.Integer, primary_key=True)

    committee_name = db.Column('cmte_nm', db.String)
    payee_name = db.Column('pye_nm', db.String)
    payee_street_1 = db.Column('pye_st1', db.String)
    payee_street_2 = db.Column('pye_st2', db.String)
    payee_city = db.Column('pye_city', db.String)
    payee_state = db.Column('pye_st', db.String)
    payee_zip = db.Column('pye_zip', db.String)
    payee_prefix = db.Column(db.String)
    payee_first_name = db.Column('payee_f_nm', db.String)
    payee_middle_name = db.Column('payee_m_nm', db.String)
    payee_last_name = db.Column('payee_l_nm', db.String)
    payee_suffix = db.Column(db.String)
    expenditure_description = db.Column('exp_desc', db.String)
    expenditure_date = db.Column('exp_dt', db.Date)
    expenditure_amount = db.Column('exp_amt', db.Float)
    support_oppose_indicator = db.Column('s_o_ind', db.String)
    candidate_id = db.Column('s_o_cand_id', db.String)
    candidate = utils.related_candidate_history('candidate_id', cycle_label='report_year')
    candidate_name = db.Column('s_o_cand_nm', db.String)
    candidate_prefix = db.Column('s_0_cand_prefix', db.String)
    candidate_first_name = db.Column('s_0_cand_f_nm', db.String)
    candidate_middle_name = db.Column('s_0_cand_m_nm', db.String)
    candidate_last_name = db.Column('s_0_cand_l_nm', db.String)
    candidate_suffix = db.Column('s_0_cand_suffix', db.String)
    candidate_office = db.Column('s_o_cand_office', db.String)
    cand_office_state = db.Column('s_o_cand_office_st', db.String)
    cand_office_district = db.Column('s_o_cand_office_district', db.String)
    election_type = db.Column('election_tp', db.String)
    election_type_full = db.Column('fec_election_tp_desc', db.String)
    independent_sign_name = db.Column('indt_sign_nm', db.String)
    independent_sign_date = db.Column('indt_sign_dt', db.Date)
    notary_sign_name = db.Column('notary_sign_nm', db.String)
    notary_sign_date = db.Column('notary_sign_dt', db.Date)
    notary_commission_expiration_date = db.Column('notary_commission_exprtn_dt', db.Date)
    back_reference_transaction_id = db.Column('back_ref_tran_id', db.String)
    back_reference_schedule_name = db.Column('back_ref_sched_nm', db.String)
    receipt_date = db.Column('receipt_dt', db.Date)
    record_number = db.Column('record_num', db.Integer)
    report_primary_general = db.Column('rpt_pgi', db.String)
    office_total_ytd = db.Column('cal_ytd_ofc_sought', db.Float)
    category_code = db.Column('catg_cd', db.String)
    category_code_full = db.Column('catg_cd_desc', db.String)
    filer_prefix = db.Column(db.String)
    filer_first_name = db.Column('filer_f_nm', db.String)
    filer_middle_name = db.Column('filer_m_nm', db.String)
    filer_last_name = db.Column('filer_l_nm', db.String)
    filer_suffix = db.Column(db.String)
    dissemination_date = db.Column('dissem_dt', db.Date)
    load_date = db.Column(db.DateTime)
    update_date = db.Column(db.DateTime)

    # Auxiliary fields
    payee_name_text = db.Column(TSVECTOR)
