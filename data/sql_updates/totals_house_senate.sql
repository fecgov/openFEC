#TO DO DERRIVE ELECTION CYCLE
drop materialized view if exists ofec_totals_house_senate_mv_tmp cascade;
create materialized view ofec_totals_house_senate_mv_tmp as
with last as (
    select distinct on (cmte_id, election_cycle) *
    from disclosure.v_sum_and_det_sum_report
    order by
        cmte_id,
        election_cycle,
        cvg_end_dt desc
), cash_beginning_period as (
    select distinct on (cmte_id, election_cycle)
        coh_bop as cash_on_hand,
        cmte_id as committee_id,
	     election_cycle as cycle
    from disclosure.v_sum_and_det_sum_report hs
    where election_cycle >= :START_YEAR
        and hs.most_recent_filing_flag like 'Y'
    order by
        cmte_id,
        election_cycle,
        cvg_end_dt asc
), aggregate_filings as(
    select
        row_number() over () as idx,
        cmte_id as committee_id,
        election_cycle as cycle,
        min(hs.cvg_start_dt) as coverage_start_date,
        max(hs.cvg_end_dt) as coverage_end_date,
        sum(hs.OTH_LOANS) as all_other_loans,
        sum(hs.cand_contb_per) as candidate_contribution,
        sum(hs.CAND_CNTB) as contribution_refunds,
        sum(hs.TTL_CONTB) as contributions,
        sum(hs.ttl_disb) as disbursements,
        sum(hs.indv_contb) as individual_contributions,
        sum(hs.indv_item_contb) as individual_itemized_contributions,
        sum(hs.indv_unitem_contb) as individual_unitemized_contributions,
        sum(hs.ttl_loan_repymts) as loan_repayments,
        sum(hs.cand_loan_repymnt) as loan_repayments_candidate_loans,
        sum(hs.OTH_LOAN_REPYMTS) as loan_repayments_other_loans,
        sum(hs.TTL_LOANS) as loans,
        sum(hs.CAND_LOAN) as loans_made_by_candidate,
        sum(hs.net_contb) as net_contributions,
        sum(hs.net_op_exp) as net_operating_expenditures,
        sum(hs.offsets_to_op_exp) as offsets_to_operating_expenditures,
        sum(hs.op_exp_per) as operating_expenditures,
        sum(hs.other_disb_per) as other_disbursements,
        sum(hs.other_pol_cmte_contb_per) as other_political_committee_contributions,
        sum(hs.OTH_CMTE_CONTB) as other_receipts,
        sum(hs.pty_cmte_contb) as political_party_committee_contributions,
        sum(hs.ttl_receipts) as receipts,
        sum(hs.indv_ref) as refunded_individual_contributions,
        sum(hs.oth_cmte_ref) as refunded_other_political_committee_contributions,
        sum(hs.pol_pty_cmte_contb) as refunded_political_party_committee_contributions,
        sum(hs.tranf_from_other_auth_cmte) as transfers_from_other_authorized_committee,
        sum(hs.tranf_to_other_auth_cmte) as transfers_to_other_authorized_committee,
        -- not available in this view
        -- max(hs.rpt_tp_desc) as last_report_type_full,
        -- max(last.begin_image_num) as last_beginning_image_number,
        max(greatest(last.coh_cop)) as last_cash_on_hand_end_period,
        max(last.debts_owed_by_cmte) as last_debts_owed_by_committee,
        max(last.debts_owed_to_cmte) as last_debts_owed_to_committee,
        max(last.rpt_yr) as last_report_year
    from
        disclosure.v_sum_and_det_sum_report hs
        inner join last using (cmte_id, election_cycle)
    where
        hs.most_recent_filing_flag like 'Y'
        and hs.election_cycle >= :START_YEAR
    group by
        cmte_id,
        election_cycle)
select af.*,
	cash_beginning_period.cash_on_hand as cash_on_hand_beginning_period
	from aggregate_filings af
	left join cash_beginning_period using (committee_id, cycle)
;

create unique index on ofec_totals_house_senate_mv_tmp(idx);

create index on ofec_totals_house_senate_mv_tmp(cycle, idx);
create index on ofec_totals_house_senate_mv_tmp(committee_id, idx);
