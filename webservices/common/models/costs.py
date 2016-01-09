from webservices import utils
from .base import db


class CommunicationCost(db.Model):
    __tablename__ = 'ofec_communication_cost_mv'

    form_76_sk = db.Column(db.Integer, primary_key=True)
    form_type = db.Column('form_tp', db.String, index=True)
    committee_id = db.Column('org_id', db.String, index=True)
    communication_type = db.Column('communication_tp', db.String, index=True)
    communication_type_full = db.Column('communication_tp_desc', db.String)
    communication_type_full = db.Column('communication_class', db.String, index=True)
    communication_date = db.Column('communication_dt', db.Date, index=True)
    support_oppose_indicator = db.Column('s_o_ind', db.String, index=True)
    candidate_id = db.Column('s_o_cand_id', db.String, index=True)
    candidate_name = db.Column('s_o_cand_nm', db.String)
    candidate_prefix = db.Column('s_o_cand_prefix', db.String)
    candidate_first_name = db.Column('s_o_cand_f_nm', db.String)
    candidate_middle_name = db.Column('s_o_cand_m_nm', db.String)
    candidate_last_name = db.Column('s_o_cand_l_nm', db.String)
    candidate_suffix = db.Column('s_o_cand_suffix', db.String)
    candidate_state = db.Column('s_o_cand_office_st', db.String, index=True)
    candidate_district = db.Column('s_o_cand_office_district', db.String, index=True)
    primary_general_indicator = db.Column('s_o_rpt_pgi', db.String, index=True)
    communication_cost = db.Column(db.Numeric(30, 2), index=True)
    amendment_indicator = db.Column('amndt_ind', db.String, index=True)
    tran_id = db.Column(db.String)
    receipt_date = db.Column('receipt_dt', db.Date)
    election_other_full = db.Column('election_other_desc', db.String)
    transaction_type = db.Column('transaction_tp', db.String)
    image_number = db.Column('image_num', db.String, index=True)
    original_sub_id = db.Column('orig_sub_id', db.Integer)
    link_id = db.Column(db.Integer)
    transaction_id = db.Column(db.Integer)
    filing_type = db.Column(db.String)
    load_date = db.Column(db.DateTime)
    update_date = db.Column(db.DateTime)

    committee = utils.related_committee('committee_id')
    candidate = utils.related_candidate('candidate_id')

class Electioneering(db.Model):
    __tablename__ = 'ofec_electioneering_mv'

    idx = db.Column(db.Integer, primary_key=True)
    form_type = db.Column('form_tp', db.String, index=True)
    committee_id = db.Column('cmte_id', db.String, index=True)
    candidate_id = db.Column('cand_id', db.String, index=True)
    candidate_name = db.Column('cand_name', db.String)
    candidate_prefix = db.Column('cand_prefix', db.String)
    candidate_office = db.Column('cand_office', db.String, index=True)
    candidate_state = db.Column('cand_office_st', db.String, index=True)
    ### would be nice to add these back
    # election_type = db.Column('election_tp', db.String, index=True)
    # election_type_full = db.Column('fec_election_tp_desc', db.String)
    ### amendments have already been applied
    # amendment_indicator = db.Column('amndt_ind', db.String, index=True)
    # back_reference_transaction_id = db.Column('back_ref_tran_id', db.String)
    # back_reference_schedule_name = db.Column('back_ref_sched_nm', db.String)
    ### what is the unique identifier for this table?
    # tran_id = db.Column(db.String)
    beginning_image_number = db.Column('f9_begin_image_num', db.String, index=True)
    # ending_image_number = db.Column('end_image_num', db.String)
    # don't know what this is
    # form_slot = db.Column(db.String)
    # need this
    # receipt_date = db.Column('receipt_dt', db.Date, index=True)
    # original_sub_id = db.Column('orig_sub_id', db.Integer)
    # would like this
    # file_number = db.Column('file_num', db.Integer)
    sub_id = db.Column(db.Integer)
    link_id = db.Column(db.Integer)
    # would like this
    # transaction_id = db.Column(db.Integer)
    filing_type = db.Column(db.String, index=True)
    load_date = db.Column(db.DateTime)
    update_date = db.Column(db.DateTime)
    calculated_candidate_share = db.Column('calculated_cand_share', db.String)
    disbursement_amount = db.Column('reported_disb_amt', db.Numeric(30, 2), index=True)
    report_year = db.Column('rpt_yr', db.Integer, index=True)

    committee = utils.related_committee('committee_id')
    candidate = utils.related_candidate('candidate_id')
