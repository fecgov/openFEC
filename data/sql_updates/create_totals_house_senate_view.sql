drop materialized view if exists ofec_totals_house_senate_mv_tmp;
create materialized view ofec_totals_house_senate_mv_tmp as
with last as (
    select distinct on (cmte_sk, two_yr_period_sk) *
    from facthousesenate_f3
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
    sum(hs.all_other_loans_per) as all_other_loans,
    sum(hs.cand_contb_per) as candidate_contribution,
    sum(hs.ttl_contb_ref_per) as contribution_refunds,
    sum(hs.ttl_contb_per) as contributions,
    sum(greatest(hs.ttl_disb_per_i, hs.ttl_disb_per_ii)) as disbursements,
    sum(hs.ttl_indv_contb_per) as individual_contributions,
    sum(hs.indv_item_contb_per) as individual_itemized_contributions,
    sum(hs.indv_unitem_contb_per) as individual_unitemized_contributions,
    sum(hs.ttl_loan_repymts_per) as loan_repayments,
    sum(hs.loan_repymts_cand_loans_per) as loan_repayments_candidate_loans,
    sum(hs.loan_repymts_other_loans_per) as loan_repayments_other_loans,
    sum(hs.ttl_loans_per) as loans,
    sum(hs.loans_made_by_cand_per) as loans_made_by_candidate,
    sum(hs.net_contb_per) as net_contributions,
    sum(hs.net_op_exp_per) as net_operating_expenditures,
    sum(hs.offsets_to_op_exp_per) as offsets_to_operating_expenditures,
    sum(hs.ttl_op_exp_per) as operating_expenditures,
    sum(hs.other_disb_per) as other_disbursements,
    sum(hs.other_pol_cmte_contb_per) as other_political_committee_contributions,
    sum(hs.other_receipts_per) as other_receipts,
    sum(hs.pol_pty_cmte_contb_per) as political_party_committee_contributions,
    sum(greatest(hs.ttl_receipts_per_i, hs.ttl_receipts_ii)) as receipts,
    sum(hs.ref_indv_contb_per) as refunded_individual_contributions,
    sum(hs.ref_other_pol_cmte_contb_per) as refunded_other_political_committee_contributions,
    sum(hs.ref_pol_pty_cmte_contb_per) as refunded_political_party_committee_contributions,
    sum(hs.tranf_from_other_auth_cmte_per) as transfers_from_other_authorized_committee,
    sum(hs.tranf_to_other_auth_cmte_per) as transfers_to_other_authorized_committee,
    max(last.rpt_tp_desc) as last_report_type_full,
    max(last.begin_image_num) as last_beginning_image_number,
    max(greatest(last.coh_cop_i, last.coh_cop_ii)) as last_cash_on_hand_end_period,
    max(last.rpt_yr) as last_report_year
from
    dimcmte c
    inner join facthousesenate_f3 hs using (cmte_sk)
    left join dimdates start_date on cvg_start_dt_sk = start_date.date_sk and cvg_start_dt_sk != 1
    left join dimdates end_date on cvg_end_dt_sk = end_date.date_sk and cvg_end_dt_sk != 1
    left join last using (cmte_sk, two_yr_period_sk)
where
    hs.expire_date is null
    and two_yr_period_sk >= :START_YEAR
group by c.cmte_id, hs.two_yr_period_sk
;

create unique index on ofec_totals_house_senate_mv_tmp(idx);

create index on ofec_totals_house_senate_mv_tmp(cycle, idx);
create index on ofec_totals_house_senate_mv_tmp(committee_id, idx);
