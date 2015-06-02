drop view if exists ofec_reports_house_senate_vw;
drop materialized view if exists ofec_reports_house_senate_mv_tmp;
create materialized view ofec_reports_house_senate_mv_tmp as
select
    row_number() over () as idx,
    facthousesenate_f3_sk as report_key,
    cmte_id as committee_id,
    two_yr_period_sk as cycle,
    start_date.dw_date as coverage_start_date,
    end_date.dw_date as coverage_end_date,
    agr_amt_pers_contrib_gen as aggregate_amount_personal_contributions_general,
    agr_amt_contrib_pers_fund_prim as aggregate_contributions_personal_funds_primary,
    all_other_loans_per as all_other_loans_period,
    all_other_loans_ytd as all_other_loans_ytd,
    begin_image_num as beginning_image_number,
    cand_contb_per as candidate_contribution_period,
    cand_contb_ytd as candidate_contribution_ytd,
    coh_bop as cash_on_hand_beginning_period,
    coalesce(coh_cop_i, coh_cop_ii) as cash_on_hand_end_period,
    debts_owed_by_cmte as debts_owed_by_committee,
    debts_owed_to_cmte as debts_owed_to_committee,
    end_image_num as end_image_number,
    grs_rcpt_auth_cmte_gen as gross_receipt_authorized_committee_general,
    grs_rcpt_auth_cmte_prim as gross_receipt_authorized_committee_primary,
    grs_rcpt_min_pers_contrib_gen as gross_receipt_minus_personal_contribution_general,
    grs_rcpt_min_pers_contrib_prim as gross_receipt_minus_personal_contributions_primary,
    indv_item_contb_per as individual_itemized_contributions_period,
    indv_unitem_contb_per as individual_unitemized_contributions_period,
    loan_repymts_cand_loans_per as loan_repayments_candidate_loans_period,
    loan_repymts_cand_loans_ytd as loan_repayments_candidate_loans_ytd,
    loan_repymts_other_loans_per as loan_repayments_other_loans_period,
    loan_repymts_other_loans_ytd as loan_repayments_other_loans_ytd,
    loans_made_by_cand_per as loans_made_by_candidate_period,
    loans_made_by_cand_ytd as loans_made_by_candidate_ytd,
    net_contb_per as net_contributions_period,
    net_contb_ytd as net_contributions_ytd,
    net_op_exp_per as net_operating_expenditures_period,
    net_op_exp_ytd as net_operating_expenditures_ytd,
    offsets_to_op_exp_per as offsets_to_operating_expenditures_period,
    offsets_to_op_exp_ytd as offsets_to_operating_expenditures_ytd,
    op_exp_per as operating_expenditures_period,
    op_exp_ytd as operating_expenditures_ytd,
    other_disb_per as other_disbursements_period,
    other_disb_ytd as other_disbursements_ytd,
    other_pol_cmte_contb_per as other_political_committee_contributions_period,
    other_pol_cmte_contb_ytd as other_political_committee_contributions_ytd,
    other_receipts_per as other_receipts_period,
    other_receipts_ytd as other_receipts_ytd,
    pol_pty_cmte_contb_per as political_party_committee_contributions_period,
    pol_pty_cmte_contb_ytd as political_party_committee_contributions_ytd,
    ref_indv_contb_per as refunded_individual_contributions_period,
    ref_indv_contb_ytd as refunded_individual_contributions_ytd,
    ref_other_pol_cmte_contb_per as refunded_other_political_committee_contributions_period,
    ref_other_pol_cmte_contb_ytd as refunded_other_political_committee_contributions_ytd,
    ref_pol_pty_cmte_contb_per as refunded_political_party_committee_contributions_period,
    ref_pol_pty_cmte_contb_ytd as refunded_political_party_committee_contributions_ytd,
    ref_ttl_contb_col_ttl_ytd as refunds_total_contributions_col_total_ytd,
    rpt_yr as report_ytd,
    subttl_per as subtotal_period,
    ttl_contb_ref_col_ttl_per as total_contribution_refunds_col_total_period,
    ttl_contb_ref_per as total_contribution_refunds_period,
    ttl_contb_ref_ytd as total_contribution_refunds_ytd,
    ttl_contb_column_ttl_per as total_contributions_column_total_period,
    ttl_contb_per as total_contributions_period,
    ttl_contb_ytd as total_contributions_ytd,
    coalesce(ttl_disb_per_i, ttl_disb_per_ii) as total_disbursements_period,
    ttl_disb_ytd as total_disbursements_ytd,
    ttl_indv_contb_per as total_individual_contributions_period,
    ttl_indv_contb_ytd as total_individual_contributions_ytd,
    ttl_indv_item_contb_ytd as total_individual_itemized_contributions_ytd,
    ttl_indv_unitem_contb_ytd as total_individual_unitemized_contributions_ytd,
    ttl_loan_repymts_per as total_loan_repayments_period,
    ttl_loan_repymts_ytd as total_loan_repayments_ytd,
    ttl_loans_per as total_loans_period,
    ttl_loans_ytd as total_loans_ytd,
    ttl_offsets_to_op_exp_per as total_offsets_to_operating_expenditures_period,
    ttl_offsets_to_op_exp_ytd as total_offsets_to_operating_expenditures_ytd,
    ttl_op_exp_per as total_operating_expenditures_period,
    ttl_op_exp_ytd as total_operating_expenditures_ytd,
    coalesce(ttl_receipts_per_i, ttl_receipts_ii) as total_receipts_period,
    ttl_receipts_ytd as total_receipts_ytd,
    tranf_from_other_auth_cmte_per as transfers_from_other_authorized_committee_period,
    tranf_from_other_auth_cmte_ytd as transfers_from_other_authorized_committee_ytd,
    tranf_to_other_auth_cmte_per as transfers_to_other_authorized_committee_period,
    tranf_to_other_auth_cmte_ytd as transfers_to_other_authorized_committee_ytd,
    rpt_tp as report_type,
    rpt_tp_desc as report_type_full,
    rpt_yr as report_year,
    f3.expire_date as expire_date,
    f3.load_date as load_date
from
    dimcmte c
    inner join facthousesenate_f3 f3 using (cmte_sk)
    inner join dimreporttype rt using (reporttype_sk)
    left join dimdates start_date on cvg_start_dt_sk = start_date.date_sk and cvg_start_dt_sk != 1
    left join dimdates end_date on cvg_end_dt_sk = end_date.date_sk and cvg_end_dt_sk != 1
where
    two_yr_period_sk >= :START_YEAR
    and f3.expire_date is null
;

create unique index on ofec_reports_house_senate_mv_tmp(idx);

create index on ofec_reports_house_senate_mv_tmp(cycle);
create index on ofec_reports_house_senate_mv_tmp(committee_id);
create index on ofec_reports_house_senate_mv_tmp(report_type);
