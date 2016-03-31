from sqlalchemy.dialects.postgresql import TSVECTOR

from .base import db


class CommunicationCost(db.Model):
    __tablename__ = 'ofec_communication_cost_mv'

    idx = db.Column(db.Integer, primary_key=True)
    committee_id = db.Column('cmte_id', db.String, index=True)
    candidate_id = db.Column('cand_id', db.String, index=True)
    committee_name = db.Column('cmte_nm', db.String)
    candidate_name = db.Column('cand_name', db.String)
    candidate_office_state = db.Column('cand_office_st', db.String, index=True)
    state_full = db.Column('st_desc', db.String)
    candidate_office_district = db.Column('cand_office_district', db.String, index=True)
    candidate_office = db.Column('cand_office', db.String, index=True)
    candidate_party_affiliation = db.Column('cand_pty_affiliation', db.String, index=True)
    party_full = db.Column('pty_desc', db.String)
    transaction_date = db.Column('transaction_dt', db.Date, index=True)
    transaction_amount = db.Column('transaction_amt', db.Numeric(30, 2), index=True)
    transaction_type = db.Column('transaction_tp', db.String)
    receipt_date = db.Column('f7_receipt_dt', db.String)
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
    pdf_url = db.Column(db.String)

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
    sub_id = db.Column(db.Integer, doc="The identifier for each electioneering record")
    link_id = db.Column(db.Integer)
    sb_link_id = db.Column(db.String)
    number_of_candidates = db.Column(db.Numeric)
    calculated_candidate_share = db.Column('calculated_cand_share', db.Numeric(30, 2), doc="If an electioneering cost targets several candidates, the total cost is divided by the number of candidates. If it only mentions one candidate the full cost of the communication is listed.")
    communication_date = db.Column('comm_dt', db.Date, doc='It is the airing, broadcast, cablecast or other dissemination of the communication')
    public_distribution_date = db.Column('pub_distrib_dt', db.Date, doc='The pubic distribution date is the date that triggers disclosure of the electioneering communication (date reported on page 1 of Form 9)')
    disbursement_date = db.Column('disb_dt', db.Date, index=True, doc='Disbursement date includes actual disbursements and execution of contracts creating an obligation to make disbursements (SB date of disbursement)')
    disbursement_amount = db.Column('reported_disb_amt', db.Numeric(30, 2), index=True)
    purpose_description = db.Column('disb_desc', db.String)
    report_year = db.Column('rpt_yr', db.Integer, index=True)
    file_number = db.Column('file_num', db.Integer)
    amendment_indicator = db.Column('amndt_ind', db.String)
    receipt_date = db.Column('receipt_dt', db.Date)
    election_type_raw = db.Column('election_tp', db.String)
    pdf_url = db.Column(db.String)

    purpose_description_text = db.Column(TSVECTOR)

    @property
    def election_type(self):
        return self.election_type_raw[:1]
