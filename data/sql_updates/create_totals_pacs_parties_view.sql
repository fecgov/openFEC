drop materialized view if exists ofec_totals_pacs_parties_mv_tmp cascade;
create materialized view ofec_totals_pacs_parties_mv_tmp as
with last as (
    select distinct on (cmte_sk, two_yr_period_sk) *
    from factpacsandparties_f3x
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
    sum(pnp.all_loans_received_per) as all_loans_received,
    sum(pnp.shared_fed_actvy_nonfed_per) as allocated_federal_election_levin_share,
    sum(greatest(pnp.ttl_contb_ref_per_i, pnp.ttl_contb_ref_per_ii)) as contribution_refunds,
    sum(pnp.ttl_contb_per) as contributions,
    sum(pnp.coord_exp_by_pty_cmte_per) as coordinated_expenditures_by_party_committee,
    sum(greatest(pnp.ttl_disb_sum_page_per, pnp.ttl_disb_per)) as disbursements,
    sum(pnp.fed_cand_cmte_contb_per) as fed_candidate_committee_contributions,
    sum(pnp.fed_cand_contb_ref_per) as fed_candidate_contribution_refunds,
    sum(pnp.ttl_fed_disb_per) as fed_disbursements,
    sum(pnp.ttl_fed_elect_actvy_per) as fed_election_activity,
    sum(pnp.ttl_fed_op_exp_per) as fed_operating_expenditures,
    sum(pnp.ttl_fed_receipts_per) as fed_receipts,
    sum(pnp.indt_exp_per) as independent_expenditures,
    sum(pnp.indv_contb_ref_per) as refunded_individual_contributions,
    sum(pnp.indv_item_contb_per) as individual_itemized_contributions,
    sum(pnp.indv_unitem_contb_per) as individual_unitemized_contributions,
    sum(pnp.ttl_indv_contb) as individual_contributions,
    sum(pnp.loan_repymts_made_per) as loan_repayments_made,
    sum(pnp.loan_repymts_received_per) as loan_repayments_received,
    sum(pnp.loans_made_per) as loans_made,
    sum(pnp.net_contb_per) as net_contributions,
    sum(pnp.net_op_exp_per) as net_operating_expenditures,
    sum(pnp.non_alloc_fed_elect_actvy_per) as non_allocated_fed_election_activity,
    sum(pnp.ttl_nonfed_tranf_per) as nonfed_transfers,
    sum(greatest(pnp.offsets_to_op_exp_per_i, pnp.offsets_to_op_exp_per_ii)) as offsets_to_operating_expenditures,
    sum(pnp.ttl_op_exp_per) as operating_expenditures,
    sum(pnp.other_disb_per) as other_disbursements,
    sum(pnp.other_fed_op_exp_per) as other_fed_operating_expenditures,
    sum(pnp.other_fed_receipts_per) as other_fed_receipts,
    sum(pnp.other_pol_cmte_contb_per_i) as other_political_committee_contributions,
    sum(pnp.other_pol_cmte_contb_per_ii) as refunded_other_political_committee_contributions,
    sum(pnp.pol_pty_cmte_contb_per_i) as political_party_committee_contributions,
    sum(pnp.pol_pty_cmte_contb_per_ii) as refunded_political_party_committee_contributions,
    sum(greatest(pnp.ttl_receipts_sum_page_per, pnp.ttl_receipts_per)) as receipts,
    sum(pnp.shared_fed_actvy_fed_shr_per) as shared_fed_activity,
    sum(pnp.shared_fed_actvy_nonfed_per) as shared_fed_activity_nonfed,
    sum(pnp.shared_fed_op_exp_per) as shared_fed_operating_expenditures,
    sum(pnp.shared_nonfed_op_exp_per) as shared_nonfed_operating_expenditures,
    sum(pnp.tranf_from_affiliated_pty_per) as transfers_from_affiliated_party,
    sum(pnp.tranf_from_nonfed_acct_per) as transfers_from_nonfed_account,
    sum(pnp.tranf_from_nonfed_levin_per) as transfers_from_nonfed_levin,
    sum(pnp.tranf_to_affliliated_cmte_per) as transfers_to_affiliated_committee,
    max(last.rpt_tp_desc) as last_report_type_full,
    max(last.begin_image_num) as last_beginning_image_number,
    max(last.coh_cop) as last_cash_on_hand_end_period,
    max(last.rpt_yr) as last_report_year
from
    dimcmte c
    inner join factpacsandparties_f3x pnp using (cmte_sk)
    left join dimdates start_date on cvg_start_dt_sk = start_date.date_sk and cvg_start_dt_sk != 1
    left join dimdates end_date on cvg_end_dt_sk = end_date.date_sk and cvg_end_dt_sk != 1
    left join last using (cmte_sk, two_yr_period_sk)
where
    pnp.expire_date is null
    and two_yr_period_sk >= :START_YEAR
group by c.cmte_id, pnp.two_yr_period_sk
;

create unique index on ofec_totals_pacs_parties_mv_tmp(idx);

create index on ofec_totals_pacs_parties_mv_tmp(cycle);
create index on ofec_totals_pacs_parties_mv_tmp(committee_id);
