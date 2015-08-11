drop materialized view if exists ofec_totals_presidential_mv_tmp;
create materialized view ofec_totals_presidential_mv_tmp as
with last as (
    select distinct on (
        cmte_sk,
        two_yr_period_sk
    )
        cmte_sk,
        two_yr_period_sk,
        coh_bop as cash_on_hand_end_period,
        begin_image_num as beginning_image_number,
        rpt_yr as report_year,
        rt.rpt_tp_desc as report_type_full,
        end_date.dw_date as coverage_end_date
    from factpresidential_f3p
    inner join dimreporttype rt using (reporttype_sk)
    left join dimdates end_date on cvg_end_dt_sk = end_date.date_sk and cvg_end_dt_sk != 1
    order by
        cmte_sk,
        two_yr_period_sk,
        coverage_end_date desc
)
select
    row_number() over () as idx,
    cmte_id as committee_id,
    two_yr_period_sk as cycle,
    min(start_date.dw_date) as coverage_start_date,
    max(end_date.dw_date) as coverage_end_date,
    sum(cand_contb_per) as candidate_contribution,
    sum(ttl_contb_ref_per) as contribution_refunds,
    sum(ttl_contb_per) as contributions,
    sum(coalesce(ttl_disb_per, ttl_disb_sum_page_per)) as disbursements,
    sum(exempt_legal_acctg_disb_per) as exempt_legal_accounting_disbursement,
    sum(fed_funds_per) as federal_funds,
    sum(fndrsg_disb_per) as fundraising_disbursements,
    sum(indv_contb_per) as individual_contributions,
    sum(indv_unitem_contb_per) as individual_unitemized_contributions,
    sum(indv_item_contb_per) as individual_itemized_contributions,
    sum(ttl_loans_received_per) as loans_received,
    sum(loans_received_from_cand_per) as loans_received_from_candidate,
    sum(ttl_loan_repymts_made_per) as loan_repayments_made,
    sum(net_contb_sum_page_per) as net_contributions,
    sum(net_op_exp_sum_page_per) as net_operating_expenditures,
    sum(offsets_to_fndrsg_exp_per) as offsets_to_fundraising_expenditures,
    sum(offsets_to_legal_acctg_per) as offsets_to_legal_accounting,
    sum(offsets_to_op_exp_per) as offsets_to_operating_expenditures,
    sum(ttl_offsets_to_op_exp_per) as total_offsets_to_operating_expenditures,
    sum(op_exp_per) as operating_expenditures,
    sum(other_disb_per) as other_disbursements,
    sum(other_loans_received_per) as other_loans_received,
    sum(other_pol_cmte_contb_per) as other_political_committee_contributions,
    sum(other_receipts_per) as other_receipts,
    sum(pol_pty_cmte_contb_per) as political_party_committee_contributions,
    sum(coalesce(ttl_receipts_per, ttl_receipts_sum_page_per)) as receipts,
    sum(ref_indv_contb_per) as refunded_individual_contributions, -- renamed from "refunds_"
    sum(ref_other_pol_cmte_contb_per) as refunded_other_political_committee_contributions,
    sum(ref_pol_pty_cmte_contb_per) as refunded_political_party_committee_contributions,
    sum(repymts_loans_made_by_cand_per) as repayments_loans_made_by_candidate,
    sum(repymts_other_loans_per) as repayments_other_loans,
    sum(tranf_from_affilated_cmte_per) as transfers_from_affiliated_committee,
    sum(tranf_to_other_auth_cmte_per) as transfers_to_other_authorized_committee,
    max(last.report_type_full) as last_report_type_full,
    max(beginning_image_number) as last_beginning_image_number,
    max(last.cash_on_hand_end_period) as last_cash_on_hand_end_period,
    max(report_year) as last_report_year
from
    dimcmte c
    inner join factpresidential_f3p p using (cmte_sk)
    left join dimdates start_date on cvg_start_dt_sk = start_date.date_sk and cvg_start_dt_sk != 1
    left join dimdates end_date on cvg_end_dt_sk = end_date.date_sk and cvg_end_dt_sk != 1
    left join last using (cmte_sk, two_yr_period_sk)
where
    p.expire_date is null
    and two_yr_period_sk >= :START_YEAR
group by c.cmte_id, p.two_yr_period_sk
;

create unique index on ofec_totals_presidential_mv_tmp(idx);

create index on ofec_totals_presidential_mv_tmp(cycle);
create index on ofec_totals_presidential_mv_tmp(committee_id);
