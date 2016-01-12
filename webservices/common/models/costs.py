from webservices import utils
from .base import db


class CommunicationCost(db.Model):
    __tablename__ = 'ofec_communication_cost_mv'

    idx = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column('cmte_id', db.String, index=True)
    candidate_id = db.Column('cand_id', db.String, index=True)
    committee_name = db.Column('cmte_nm', db.String)
    candidate_name = db.Column('cand_name', db.String)
    candidate_office_state = db.Column('cand_office_st', db.String, index=True)
    candidate_office_district = db.Column('cand_office_district', db.String, index=True)
    candidate_office = db.Column('cand_office', db.String, index=True)
    candidate_party_affiliation = db.Column('cand_pty_affiliation', db.String, index=True)
    transaction_date = db.Column('_transaction_dt', db.Date, index=True)
    transaction_amount = db.Column('transaction_amt', db.Numeric(30, 2), index=True)
    purpose = db.Column(db.String)
    communication_type = db.Column('communication_tp', db.String, index=True)
    communication_class = db.Column('communication_class', db.String, index=True)
    support_oppose_indicator = db.Column('support_oppose_ind', db.String, index=True)
    image_number = db.Column('image_num', db.String, index=True)
    line_number = db.Column('line_num', db.String, index=True)
    form_type_code = db.Column('form_tp_cd', db.String, index=True)
    schedule_type_code = db.Column('sched_tp_cd', db.String, index=True)
    tran_id = db.Column(db.String)
    sub_id = db.Column(db.Integer)
    file_number = db.Column('file_num', db.Integer)
    report_year = db.Column('rpt_yr', db.Integer, index=True)


class Electioneering(db.Model):
    __tablename__ = 'ofec_electioneering_mv'

    idx = db.Column(db.Integer, primary_key=True)
    form_type = db.Column('form_tp', db.String, index=True)
    committee_id = db.Column('cmte_id', db.String, index=True)
    candidate_id = db.Column('cand_id', db.String, index=True)
    candidate_name = db.Column('cand_name', db.String, index=True)
    candidate_office = db.Column('cand_office', db.String, index=True)
    candidate_district = db.Column('cand_office_district', db.String, index=True)
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
    sb_image_num = db.Column(db.String, index=True)
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
    # is this similar to transaction_id?
    sb_link_id = db.Column(db.String, index=True)
    # transaction_id = db.Column(db.Integer)
    # filing_type = db.Column(db.String, index=True)
    # load_date = db.Column(db.DateTime)
    # update_date = db.Column(db.DateTime)
    number_of_candidates = db.Column(db.String)
    calculated_candidate_share = db.Column('calculated_cand_share', db.String)
    # difference between communication and public distribution dates?
    communicaion_date = db.Column('comm_dt', db.DateTime)
    public_distribion_date = db.Column('pub_distrib_dt', db.DateTime)
    disbursement_date = db.Column('disb_dt', db.DateTime)
    disbursement_amount = db.Column('reported_disb_amt', db.Numeric(30, 2), index=True)
    #TODO: add tsvector field
    purpose_description = db.Column('disb_desc', db.String)
    report_year = db.Column('rpt_yr', db.Integer, index=True)

    committee = utils.related_committee('committee_id')
    candidate = utils.related_candidate('candidate_id')
