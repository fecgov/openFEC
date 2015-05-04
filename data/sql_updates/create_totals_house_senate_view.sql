drop materialized view if exists ofec_totals_house_senate_mv_tmp;
create materialized view ofec_totals_house_senate_mv_tmp as
select
    row_number() over () as idx,
    cmte_id as committee_id,
    two_yr_period_sk as cycle,
    cmte_tp as committee_type,
    min(start_date.dw_date) as coverage_start_date,
    max(end_date.dw_date) as coverage_end_date,
    sum(all_other_loans_per) as all_other_loans,
    sum(cand_contb_per) as candidate_contribution,
    sum(ttl_contb_ref_per) as contribution_refunds,
    sum(ttl_contb_per) as contributions,
    sum(ttl_disb_per_ii) as disbursements,
    sum(ttl_indv_contb_per) as individual_contributions,
    sum(indv_item_contb_per) as individual_itemized_contributions,
    sum(indv_unitem_contb_per) as individual_unitemized_contributions,
    sum(ttl_loan_repymts_per) as loan_repayments,
    sum(loan_repymts_cand_loans_per) as loan_repayments_candidate_loans,
    sum(loan_repymts_other_loans_per) as loan_repayments_other_loans,
    sum(ttl_loans_per) as loans,
    sum(loans_made_by_cand_per) as loans_made_by_candidate,
    sum(offsets_to_op_exp_per) as offsets_to_operating_expenditures,
    sum(ttl_op_exp_per) as operating_expenditures,
    sum(other_disb_per) as other_disbursements,
    sum(other_pol_cmte_contb_per) as other_political_committee_contributions,
    sum(other_receipts_per) as other_receipts,
    sum(pol_pty_cmte_contb_per) as political_party_committee_contributions,
    sum(ttl_receipts_per_i) as receipts,
    sum(ref_indv_contb_per) as refunded_individual_contributions,
    sum(ref_other_pol_cmte_contb_per) as refunded_other_political_committee_contributions,
    sum(ref_pol_pty_cmte_contb_per) as refunded_political_party_committee_contributions,
    sum(tranf_from_other_auth_cmte_per) as transfers_from_other_authorized_committee,
    sum(tranf_to_other_auth_cmte_per) as transfers_to_other_authorized_committee
from
    dimcmte c
    inner join dimcmtetpdsgn ctd using (cmte_sk)
    inner join facthousesenate_f3 hs using (cmte_sk)
    left join dimdates start_date on cvg_start_dt_sk = start_date.date_sk and cvg_start_dt_sk != 1
    left join dimdates end_date on cvg_end_dt_sk = end_date.date_sk and cvg_end_dt_sk != 1
where
    hs.expire_date is null or hs.expire_date > date_trunc('day', now())
group by committee_id, cycle, committee_type
;

create unique index on ofec_totals_house_senate_mv_tmp(idx);

create index on ofec_totals_house_senate_mv_tmp(cycle);
create index on ofec_totals_house_senate_mv_tmp(committee_id);
