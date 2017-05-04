-- Missing these. We had them in the other

-- political_party_committee_contributions_period
-- offsets_to_operating_expenditures_period
-- aggregate_amount_personal_contributions_general
-- aggregate_contributions_personal_funds_primary
-- gross_receipt_authorized_committee_general
-- gross_receipt_authorized_committee_primary
-- gross_receipt_minus_personal_contribution_general
-- gross_receipt_minus_personal_contributions_primary
-- total_contribution_refunds_col_total_period
-- total_contributions_column_total_period
-- total_operating_expenditures_period


drop materialized view if exists ofec_reports_f3_mv_tmp;
create materialized view ofec_reports_f3_mv_tmp as
select
    get_cycle(rpt_yr) as cycle,
    file_num as file_number,
    cmte_id as committee_id,
    to_timestamp(cvg_start_dt) as coverage_start_date,
    to_timestamp(cvg_end_dt) as coverage_end_date,
    receipt_dt as receipt_date,
    rpt_yr as report_year,
    ttl_contb as total_contributions_period,
    net_contb as net_contributions_period,
    op_exp_per as offsets_to_operating_expenditures_period,
    offsets_to_op_exp as total_offsets_to_operating_expenditures_period,
    net_op_exp as net_operating_expenditures_period,
    coh_cop as cash_on_hand_end_period,
    debts_owed_to_cmte as debts_owed_to_committee,
    debts_owed_by_cmte as debts_owed_by_committee,
    indv_item_contb as individual_itemized_contributions_period,
    indv_unitem_contb as individual_unitemized_contributions_period,
    indv_contb as total_individual_contributions_period,
    oth_cmte_contb as other_political_committee_contributions_period,
    cand_cntb as candidate_contribution_period,
    tranf_from_other_auth_cmte as transfers_from_other_authorized_committee_period,
    cand_loan as loans_made_by_candidate_period,
    oth_loans as all_other_loans_period,
    ttl_loans as total_loans_received_period,
    other_receipts as other_receipts_period,
    ttl_receipts as total_receipts_period,
    op_exp_per as operating_expenditures_period,
    tranf_to_other_auth_cmte as transfers_to_other_authorized_committee_period,
    cand_loan_repymnt as loan_repayments_candidate_loans_period,
    oth_loan_repymts as loan_repayments_other_loans_period,
    ttl_loan_repymts as total_loan_repayments_made_period,
    indv_ref as refunded_individual_contributions_period,
    pty_cmte_contb as political_party_committee_contributions_period,
    pol_pty_cmte_contb as refunded_political_party_committee_contributions_period,
    oth_cmte_ref as refunded_other_political_committee_contributions_period,
    ttl_contb_ref as total_contribution_refunds_period,
    other_disb_per as other_disbursements_period,
    ttl_disb as total_disbursements_period,
    coh_bop as cash_on_hand_beginning_period,
    rpt_tp as report_type,
    orig_sub_id as sub_id,
    of.report_type_full,
    of.beginning_image_number,
    of.ending_image_number,
    report_fec_url(of.beginning_image_number::text, file_num::integer) as fec_url,
    means_filed(of.beginning_image_number::text) as means_filed
from disclosure.v_sum_and_det_sum_report
    left join ofec_filings_mv_tmp of on disclosure.v_sum_and_det_sum_report.orig_sub_id = of.sub_id
where
    get_cycle(rpt_yr) >= :START_YEAR
;


create unique index on ofec_reports_f3_mv_tmp(sub_id);

create index on ofec_reports_f3_mv_tmp(cycle, sub_id);
create index on ofec_reports_f3_mv_tmp(report_type, sub_id);
create index on ofec_reports_f3_mv_tmp(report_year, sub_id);
create index on ofec_reports_f3_mv_tmp(committee_id, sub_id);
create index on ofec_reports_f3_mv_tmp(coverage_end_date, sub_id);
create index on ofec_reports_f3_mv_tmp(coverage_start_date, sub_id);
create index on ofec_reports_f3_mv_tmp(beginning_image_number, sub_id);
create index on ofec_reports_f3_mv_tmp(total_receipts_period, sub_id);
create index on ofec_reports_f3_mv_tmp(total_disbursements_period, sub_id);
create index on ofec_reports_f3_mv_tmp(receipt_date, sub_id);
