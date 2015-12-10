drop materialized view if exists ofec_totals_presidential_mv_tmp cascade;
create materialized view ofec_totals_presidential_mv_tmp as
with last as (
    select distinct on (cmte_sk, two_yr_period_sk) *
    from factpresidential_f3p
    inner join dimreporttype rt using (reporttype_sk)
    left join dimdates end_date on cvg_end_dt_sk = end_date.date_sk and cvg_end_dt_sk != 1
    order by
        cmte_sk,
        two_yr_period_sk,
        dw_date desc
)
select
    row_number() over () as idx,
    cmte_id as committee_id,
    two_yr_period_sk as cycle,
    min(start_date.dw_date) as coverage_start_date,
    max(end_date.dw_date) as coverage_end_date,
    sum(p.cand_contb_per) as candidate_contribution,
    sum(p.ttl_contb_ref_per) as contribution_refunds,
    sum(p.ttl_contb_per) as contributions,
    sum(greatest(p.ttl_disb_per, p.ttl_disb_sum_page_per)) as disbursements,
    sum(p.exempt_legal_acctg_disb_per) as exempt_legal_accounting_disbursement,
    sum(p.fed_funds_per) as federal_funds,
    sum(p.fndrsg_disb_per) as fundraising_disbursements,
    sum(p.indv_contb_per) as individual_contributions,
    sum(p.indv_unitem_contb_per) as individual_unitemized_contributions,
    sum(p.indv_item_contb_per) as individual_itemized_contributions,
    sum(p.ttl_loans_received_per) as loans_received,
    sum(p.loans_received_from_cand_per) as loans_received_from_candidate,
    sum(p.ttl_loan_repymts_made_per) as loan_repayments_made,
    sum(p.offsets_to_fndrsg_exp_per) as offsets_to_fundraising_expenditures,
    sum(p.offsets_to_legal_acctg_per) as offsets_to_legal_accounting,
    sum(p.offsets_to_op_exp_per) as offsets_to_operating_expenditures,
    sum(p.ttl_offsets_to_op_exp_per) as total_offsets_to_operating_expenditures,
    sum(p.op_exp_per) as operating_expenditures,
    sum(p.other_disb_per) as other_disbursements,
    sum(p.other_loans_received_per) as other_loans_received,
    sum(p.other_pol_cmte_contb_per) as other_political_committee_contributions,
    sum(p.other_receipts_per) as other_receipts,
    sum(p.pol_pty_cmte_contb_per) as political_party_committee_contributions,
    sum(greatest(p.ttl_receipts_per, p.ttl_receipts_sum_page_per)) as receipts,
    sum(p.ref_indv_contb_per) as refunded_individual_contributions, -- renamed from "refunds_"
    sum(p.ref_other_pol_cmte_contb_per) as refunded_other_political_committee_contributions,
    sum(p.ref_pol_pty_cmte_contb_per) as refunded_political_party_committee_contributions,
    sum(p.repymts_loans_made_by_cand_per) as repayments_loans_made_by_candidate,
    sum(p.repymts_other_loans_per) as repayments_other_loans,
    sum(p.tranf_from_affilated_cmte_per) as transfers_from_affiliated_committee,
    sum(p.tranf_to_other_auth_cmte_per) as transfers_to_other_authorized_committee,
    max(last.net_contb_sum_page_per) as net_contributions,
    max(last.net_op_exp_sum_page_per) as net_operating_expenditures,
    max(last.rpt_tp_desc) as last_report_type_full,
    max(last.begin_image_num) as last_beginning_image_number,
    max(last.coh_cop) as last_cash_on_hand_end_period,
    max(last.debts_owed_by_cmte) as last_debts_owed_by_committee,
    max(last.rpt_yr) as last_report_year
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
