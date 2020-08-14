from sqlalchemy.dialects.postgresql import TSVECTOR

from .base import db
from webservices import docs


class CommunicationCost(db.Model):
    __tablename__ = 'ofec_communication_cost_mv'

    sub_id = db.Column(db.Integer, primary_key=True)
    original_sub_id = db.Column('orig_sub_id', db.Integer, index=True)
    candidate_id = db.Column('cand_id', db.String, index=True)
    committee_id = db.Column('cmte_id', db.String, index=True)
    committee_name = db.Column(db.String)
    pdf_url = db.Column(db.String)
    candidate_name = db.Column('s_o_cand_nm', db.String)
    candidate_last_name = db.Column('s_o_cand_l_nm', db.String)
    candidate_middle_name = db.Column('s_o_cand_m_nm', db.String)
    candidate_first_name = db.Column('s_o_cand_f_nm', db.String)
    candidate_office_state = db.Column('s_o_cand_office_st', db.String, index=True)
    state_full = db.Column('s_o_cand_office_st_desc', db.String)
    candidate_office_district = db.Column('s_o_cand_office_district', db.String, index=True)
    candidate_office = db.Column('s_o_cand_office', db.String, index=True)
    candidate_office_full = db.Column('s_o_cand_office_desc', db.String)
    transaction_date = db.Column('communication_dt', db.Date, index=True)
    transaction_amount = db.Column('communication_cost', db.Numeric(30, 2), index=True)
    transaction_type = db.Column('transaction_tp', db.String)
    communication_type = db.Column('communication_tp', db.String, index=True)
    communication_type_full = db.Column('communication_tp_desc', db.String)
    communication_class = db.Column('communication_class', db.String, index=True)
    purpose = db.Column('communication_class_desc', db.String, index=True)
    support_oppose_indicator = db.Column('s_o_ind', db.String, index=True)

    # new columns added from ware house transition
    action_code = db.Column('action_cd', db.String)
    action_code_full = db.Column('action_cd_desc', db.String)
    primary_general_indicator = db.Column('s_o_rpt_pgi', db.String)
    primary_general_indicator_description = db.Column('s_o_rpt_pgi_desc', db.String)
    report_type = db.Column('rpt_tp', db.String)
    report_year = db.Column('rpt_yr', db.Integer)
    cycle = db.Column('election_cycle', db.Integer, index=True)

    form_type_code = db.Column('filing_form', db.String, index=True)
    schedule_type = db.Column(db.String, index=True)
    schedule_type_full = db.Column('schedule_type_desc', db.String)
    tran_id = db.Column(db.String)
    file_number = db.Column('file_num', db.Integer)
    image_number = db.Column('image_num', db.String, index=True)


class CommunicationCostOffset(db.Model):
    __tablename__ = 'ofec_communication_cost_mv'
    __table_args__ = {'extend_existing': True} 

    sub_id = db.Column(db.Integer, primary_key=True)
    original_sub_id = db.Column('orig_sub_id', db.Integer, index=True)
    candidate_id = db.Column('cand_id', db.String, index=True)
    committee_id = db.Column('cmte_id', db.String, index=True)
    committee_name = db.Column(db.String)
    pdf_url = db.Column(db.String)
    candidate_name = db.Column('s_o_cand_nm', db.String)
    candidate_last_name = db.Column('s_o_cand_l_nm', db.String)
    candidate_middle_name = db.Column('s_o_cand_m_nm', db.String)
    candidate_first_name = db.Column('s_o_cand_f_nm', db.String)
    candidate_office_state = db.Column('s_o_cand_office_st', db.String, index=True)
    state_full = db.Column('s_o_cand_office_st_desc', db.String)
    candidate_office_district = db.Column('s_o_cand_office_district', db.String, index=True)
    candidate_office = db.Column('s_o_cand_office', db.String, index=True)
    candidate_office_full = db.Column('s_o_cand_office_desc', db.String)
    transaction_date = db.Column('communication_dt', db.Date, index=True)
    transaction_amount = db.Column('communication_cost', db.Numeric(30, 2), index=True)
    transaction_type = db.Column('transaction_tp', db.String)
    communication_type = db.Column('communication_tp', db.String, index=True)
    communication_type_full = db.Column('communication_tp_desc', db.String)
    communication_class = db.Column('communication_class', db.String, index=True)
    purpose = db.Column('communication_class_desc', db.String, index=True)
    support_oppose_indicator = db.Column('s_o_ind', db.String, index=True)

    # new columns added from ware house transition
    action_code = db.Column('action_cd', db.String)
    action_code_full = db.Column('action_cd_desc', db.String)
    primary_general_indicator = db.Column('s_o_rpt_pgi', db.String)
    primary_general_indicator_description = db.Column('s_o_rpt_pgi_desc', db.String)
    report_type = db.Column('rpt_tp', db.String)
    report_year = db.Column('rpt_yr', db.Integer)
    cycle = db.Column('election_cycle', db.Integer, index=True)

    form_type_code = db.Column('filing_form', db.String, index=True)
    schedule_type = db.Column(db.String, index=True)
    schedule_type_full = db.Column('schedule_type_desc', db.String)
    tran_id = db.Column(db.String)
    file_number = db.Column('file_num', db.Integer)
    image_number = db.Column('image_num', db.String, index=True)
    
class Electioneering(db.Model):
    __tablename__ = 'ofec_electioneering_mv'

    idx = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column('cmte_id', db.String, index=True)
    committee_name = db.Column('cmte_nm', db.String)
    candidate_id = db.Column('cand_id', db.String, index=True)
    candidate_name = db.Column('cand_name', db.String)
    candidate_office = db.Column('cand_office', db.String, index=True)
    candidate_district = db.Column('cand_office_district', db.String, index=True)
    candidate_state = db.Column('cand_office_st', db.String, index=True)
    beginning_image_number = db.Column('f9_begin_image_num', db.String, index=True)
    sb_image_num = db.Column(db.String, index=True)
    sub_id = db.Column(db.Integer, doc=docs.EC_SUB_ID)
    link_id = db.Column(db.Integer)
    sb_link_id = db.Column(db.String)
    number_of_candidates = db.Column(db.Numeric)
    calculated_candidate_share = db.Column('calculated_cand_share', db.Numeric(30, 2),
        doc=docs.CALCULATED_CANDIDATE_SHARE)
    communication_date = db.Column('comm_dt', db.Date, doc=docs.COMMUNICATION_DT)
    public_distribution_date = db.Column('pub_distrib_dt', db.Date,
        doc=docs.PUBLIC_DISTRIBUTION_DT)
    disbursement_date = db.Column('disb_dt', db.Date, index=True,
        doc=docs.DISBURSEMENT_DT)
    disbursement_amount = db.Column('reported_disb_amt', db.Numeric(30, 2), index=True)
    purpose_description = db.Column('disb_desc', db.String)
    report_year = db.Column('rpt_yr', db.Integer, index=True)
    file_number = db.Column('file_num', db.Integer)
    amendment_indicator = db.Column('amndt_ind', db.String)
    receipt_date = db.Column('receipt_dt', db.Date)
    election_type_raw = db.Column('election_tp', db.String)
    pdf_url = db.Column(db.String)
    purpose_description_text = db.Column(TSVECTOR)
    payee_name = db.Column('payee_nm', db.String, doc=docs.PAYEE_NAME)
    payee_state = db.Column('payee_st', db.String)

    @property
    def election_type(self):
        return self.election_type_raw[:1]
