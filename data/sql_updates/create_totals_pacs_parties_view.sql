drop materialized view if exists ofec_totals_pacs_parties_mv;
create materialized view ofec_totals_pacs_parties_mv as
select
    row_number() over () as idx,
    cmte_id as committee_id,
    two_yr_period_sk as cycle,
    cmte_tp as committee_type,
    min(start_date.dw_date) as coverage_start_date,
    max(end_date.dw_date) as coverage_end_date,
    sum(all_loans_received_per) as all_loans_received,
    sum(ttl_contb_ref_per_i) as contribution_refunds,
    sum(ttl_contb_per) as contributions,
    sum(coord_exp_by_pty_cmte_per) as coordinated_expenditures_by_party_committee,
    sum(ttl_disb_per) as disbursements,
    sum(fed_cand_cmte_contb_per) as fed_candidate_committee_contributions,
    sum(fed_cand_contb_ref_per) as fed_candidate_contribution_refunds,
    sum(ttl_fed_disb_per) as fed_disbursements,
    sum(ttl_fed_elect_actvy_per) as fed_elect_activity,
    sum(ttl_fed_op_exp_per) as fed_operating_expenditures,
    sum(ttl_fed_receipts_per) as fed_receipts,
    sum(indt_exp_per) as independent_expenditures,
    sum(indv_contb_ref_per) as individual_contribution_refunds,
    sum(indv_item_contb_per) as individual_itemized_contributions,
    sum(indv_unitem_contb_per) as individual_unitemized_contributions,
    sum(loan_repymts_made_per) as loan_repayments_made,
    sum(loan_repymts_received_per) as loan_repayments_received,
    sum(loans_made_per) as loans_made,
    sum(net_contb_per) as net_contributions,
    sum(non_alloc_fed_elect_actvy_per) as non_allocated_fed_election_activity,
    sum(ttl_nonfed_tranf_per) as nonfed_transfers,
    sum(offsets_to_op_exp_per_ii) as offsets_to_operating_expenditures,
    sum(ttl_op_exp_per) as operating_expenditures,
    sum(other_disb_per) as other_disbursements,
    sum(other_fed_op_exp_per) as other_fed_operating_expenditures,
    sum(other_fed_receipts_per) as other_fed_receipts,
    sum(other_pol_cmte_contb_per_i) as other_political_committee_contributions,
    sum(pol_pty_cmte_contb_per_i) as political_party_committee_contributions,
    sum(pol_pty_cmte_contb_per_ii) as political_party_committee_contribution_refunds,
    sum(ttl_receipts_per) as receipts,
    sum(shared_fed_actvy_fed_shr_per) as shared_fed_activity,
    sum(shared_fed_actvy_nonfed_per) as shared_fed_activity_nonfed,
    sum(shared_fed_op_exp_per) as shared_fed_operating_expenditures,
    sum(shared_nonfed_op_exp_per) as shared_nonfed_operating_expenditures,
    sum(tranf_from_affiliated_pty_per) as transfers_from_affiliated_party,
    sum(tranf_from_nonfed_acct_per) as transfers_from_nonfed_account,
    sum(tranf_from_nonfed_levin_per) as transfers_from_nonfed_levin,
    sum(tranf_to_affliliated_cmte_per) as transfers_to_affiliated_committee
from
    dimcmte c
    inner join dimcmtetpdsgn ctd using (cmte_sk)
    inner join factpacsandparties_f3x pnp using (cmte_sk)
    left join dimdates start_date on cvg_start_dt_sk = start_date.date_sk and cvg_start_dt_sk != 1
    left join dimdates end_date on cvg_end_dt_sk = end_date.date_sk and cvg_end_dt_sk != 1
where
    pnp.expire_date is null or pnp.expire_date > date_trunc('day', now())
group by committee_id, cycle, committee_type
;

create unique index on ofec_totals_pacs_parties_mv(idx);

create index on ofec_totals_pacs_parties_mv(cycle);
create index on ofec_totals_pacs_parties_mv(committee_id);
