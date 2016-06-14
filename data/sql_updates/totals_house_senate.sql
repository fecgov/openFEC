drop materialized view if exists ofec_totals_house_senate_mv_tmp cascade;
create materialized view ofec_totals_house_senate_mv_tmp as
with last as (
    select distinct on (cmte_id, election_cycle) *
    from fec_vsum_f3
    order by
        cmte_id,
        election_cycle,
        cvg_end_dt desc
)
select
    row_number() over () as idx,
    cmte_id as committee_id,
    election_cycle as cycle,
    min(hs.cvg_start_dt) as coverage_start_date,
    max(hs.cvg_end_dt) as coverage_end_date,
    sum(hs.all_other_loans_per) as all_other_loans,
    sum(hs.cand_contb_per) as candidate_contribution,
    sum(hs.ttl_contb_ref_per) as contribution_refunds,
    sum(hs.ttl_contb_per) as contributions,
    sum(hs.ttl_disb_per) as disbursements,
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
    sum(hs.ttl_receipts_per) as receipts,
    sum(hs.ref_indv_contb_per) as refunded_individual_contributions,
    sum(hs.ref_other_pol_cmte_contb_per) as refunded_other_political_committee_contributions,
    sum(hs.ref_pol_pty_cmte_contb_per) as refunded_political_party_committee_contributions,
    sum(hs.tranf_from_other_auth_cmte_per) as transfers_from_other_authorized_committee,
    sum(hs.tranf_to_other_auth_cmte_per) as transfers_to_other_authorized_committee,
    max(hs.rpt_tp_desc) as last_report_type_full,
    max(last.begin_image_num) as last_beginning_image_number,
    max(greatest(last.coh_cop)) as last_cash_on_hand_end_period,
    max(last.debts_owed_by_cmte) as last_debts_owed_by_committee,
    max(last.rpt_yr) as last_report_year
from
    fec_vsum_f3 hs
    left join last using (cmte_id, election_cycle)
where
    hs.most_recent_filing_flag like 'Y'
    and hs.election_cycle >= :START_YEAR
group by
    cmte_id,
    election_cycle
;

create unique index on ofec_totals_house_senate_mv_tmp(idx);

create index on ofec_totals_house_senate_mv_tmp(cycle, idx);
create index on ofec_totals_house_senate_mv_tmp(committee_id, idx);
