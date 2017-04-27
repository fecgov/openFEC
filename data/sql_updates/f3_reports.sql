drop materialized view if exists ofec_f3_reports_mw_tmp;
create or replace materialized view ofec_f3_reports_mw_tmp as
select
    vs.cmte_id as committee_id,
    vs.cvg_start_dt as coverage_start_date,
    vs.cvg_end_dtas as coverage_end_date,
    vs.rpt_yr as report_year,
    vs.ttl_contb as total_contributions_period,
    vs.ttl_contb_ref as total_contribution_refunds_period,
    vs.net_contb as net_contributions_period,
    vs.op_exp_per as total_operating_expenditures_period,
    vs.offsets_to_op_exp as total_offsets_to_operating_expenditures_period,
    vs.net_op_exp as net_operating_expenditures_period,
    vs.coh_cop as cash_on_hand_end_period,
    vs.debts_owed_to_cmte as debts_owed_to_committee,
    vs.debts_owed_by_cmte as debts_owed_by_committee,
    vs.indv_item_contb as individual_itemized_contributions_period,
    vs.indv_unitem_contb as individual_unitemized_contributions_period,
    vs.indv_contb as total_individual_contributions_period,
    vs.pty_cmte_contb as refunded_political_party_committee_contributions_period,
    vs.OTH_CMTE_CONTB as other_political_committee_contributions_period,
    vs.CAND_CNTB as candidate_contribution_period,
    vs.TTL_CONTB as total_contributions_period,
    vs.tranf_from_other_auth_cmte as transfers_from_other_authorized_committee_period,
    vs.CAND_LOAN as loans_made_by_candidate_period,
    vs.OTH_LOANS as all_other_loans_period,
    vs.TTL_LOANS as total_loans_received_period,
    vs.offsets_to_op_exp as offsets_to_operating_expenditures_period,
    vs.OTHER_RECEIPTS as other_receipts_period,
    vs.ttl_receipts as total_receipts_period,
    vs.OP_EXP_PER as operating_expenditures_period,
    vs.tranf_to_other_auth_cmte as transfers_to_other_authorized_committee_period,
    vs.cand_loan_repymnt as loan_repayments_candidate_loans_period,
    vs.OTH_LOAN_REPYMTS as loan_repayments_other_loans_period,
    vs.ttl_loan_repymts as total_loan_repayments_made_period,
    vs.indv_ref as refunded_individual_contributions_period,
    vs.pol_pty_cmte_contb as refunded_political_party_committee_contributions_period, -- the vs column name is unfortunate but that's the way it goes
    vs.oth_cmte_ref as refunded_other_political_committee_contributions_period,
    vs.ttl_contb_ref as total_contribution_refunds_period,
    vs.other_disb_per as other_disbursements_period,
    vs.ttl_disb as total_disbursements_period,
    vs.coh_bop as cash_on_hand_beginning_period,
    vs.orig_sub_id as sub_id
from disclosure.v_sum_and_det_sum_report vs
where
    election_cycle >= :START_YEAR
;


create unique index on ofec_f3_reports_mw_tmp(sub_id);

create index on ofec_f3_reports_mw_tmp(cycle, sub_id);
create index on ofec_f3_reports_mw_tmp(report_type, sub_id);
create index on ofec_f3_reports_mw_tmp(report_year, sub_id);
create index on ofec_f3_reports_mw_tmp(committee_id, sub_id);
create index on ofec_f3_reports_mw_tmp(coverage_end_date, sub_id);
create index on ofec_f3_reports_mw_tmp(coverage_start_date, sub_id);
create index on ofec_f3_reports_mw_tmp(beginning_image_number, sub_id);
create index on ofec_f3_reports_mw_tmp(is_amended, sub_id);
create index on ofec_f3_reports_mw_tmp(total_receipts_period, sub_id);
create index on ofec_f3_reports_mw_tmp(total_disbursements_period, sub_id);
create index on ofec_f3_reports_mw_tmp(receipt_date, sub_id);
