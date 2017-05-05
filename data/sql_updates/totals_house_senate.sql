drop materialized view if exists ofec_totals_house_senate_mv_tmp cascade;
create materialized view ofec_totals_house_senate_mv_tmp as
-- done in two steps to reduce the scope of the join
with last_subset as (
    select distinct on (cmte_id, cycle)
        orig_sub_id,
        cmte_id,
        coh_cop,
        debts_owed_by_cmte,
        debts_owed_to_cmte,
        rpt_yr,
        get_cycle(rpt_yr) as cycle
    from disclosure.v_sum_and_det_sum_report
    where
        get_cycle(rpt_yr) >= :START_YEAR
    order by
        cmte_id,
        cycle,
        to_timestamp(cvg_end_dt) desc
),
last as(
    select
        ls.cmte_id,
        of.beginning_image_number,
        ls.coh_cop,
        ls.debts_owed_by_cmte,
        ls.debts_owed_to_cmte,
        of.report_type_full,
        ls.rpt_yr,
        ls.cycle
    from last_subset ls
    left join ofec_filings_mv_tmp of on ls.orig_sub_id = of.sub_id
),
cash_beginning_period as (
    select distinct on (cmte_id, get_cycle(rpt_yr))
        coh_bop as cash_on_hand,
        cmte_id as committee_id,
        get_cycle(rpt_yr) as cycle
    from disclosure.v_sum_and_det_sum_report
    where
        get_cycle(rpt_yr) >= :START_YEAR
    order by
        cmte_id,
        get_cycle(rpt_yr),
        to_timestamp(cvg_end_dt) asc
)
    select
        max(hs.orig_sub_id) as sub_id,
        hs.cmte_id as committee_id,
        get_cycle(hs.rpt_yr) as cycle,
        min(to_timestamp(hs.cvg_start_dt)) as coverage_start_date,
        max(to_timestamp(hs.cvg_end_dt)) as coverage_end_date,
        sum(hs.OTH_LOANS) as all_other_loans,
        sum(hs.CAND_CNTB) as candidate_contribution,
        sum(hs.ttl_contb_ref) as contribution_refunds,
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
        sum(hs.OTH_CMTE_CONTB) as other_political_committee_contributions,
        sum(hs.OTHER_RECEIPTS) as other_receipts,
        sum(hs.pty_cmte_contb) as political_party_committee_contributions,
        sum(hs.ttl_receipts) as receipts,
        sum(hs.indv_ref) as refunded_individual_contributions,
        sum(hs.oth_cmte_ref) as refunded_other_political_committee_contributions,
        sum(hs.pol_pty_cmte_contb) as refunded_political_party_committee_contributions,
        sum(hs.tranf_from_other_auth_cmte) as transfers_from_other_authorized_committee,
        sum(hs.tranf_to_other_auth_cmte) as transfers_to_other_authorized_committee,
        max(last.report_type_full) as last_report_type_full,
        max(last.beginning_image_number) as last_beginning_image_number,
        min(cash_beginning_period.cash_on_hand) as cash_on_hand_beginning_period,
        max(last.coh_cop) as last_cash_on_hand_end_period,
        max(last.debts_owed_by_cmte) as last_debts_owed_by_committee,
        max(last.debts_owed_to_cmte) as last_debts_owed_to_committee,
        max(last.rpt_yr) as last_report_year
    from
        disclosure.v_sum_and_det_sum_report hs
        inner join last on hs.cmte_id = last.cmte_id and get_cycle(hs.rpt_yr) = last.cycle
        left join cash_beginning_period on
            hs.cmte_id = cash_beginning_period.committee_id and
            get_cycle(hs.rpt_yr) = cash_beginning_period.cycle
    where
        get_cycle(hs.rpt_yr) >= :START_YEAR
    group by
        hs.cmte_id,
        get_cycle(hs.rpt_yr)
;

create unique index on ofec_totals_house_senate_mv_tmp(sub_id);

create index on ofec_totals_house_senate_mv_tmp(cycle, sub_id);
create index on ofec_totals_house_senate_mv_tmp(committee_id, sub_id);
