drop materialized view if exists ofec_totals_presidential_mv_tmp cascade;
create materialized view ofec_totals_presidential_mv_tmp as
-- done in two steps to reduce the scope of the join
with last_subset as (
    select distinct on (cmte_id, cycle)
        orig_sub_id,
        cmte_id,
        coh_cop,
        debts_owed_by_cmte,
        debts_owed_to_cmte,
        net_contb,
        net_op_exp,
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
        ls.orig_sub_id,
        ls.cmte_id,
        ls.coh_cop,
        ls.debts_owed_by_cmte,
        ls.debts_owed_to_cmte,
        ls.net_contb,
        ls.net_op_exp,
        ls.rpt_yr,
        ls.cycle,
        of.beginning_image_number,
        of.report_type_full
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
        max(p.orig_sub_id) as sub_id,
        p.cmte_id as committee_id,
        get_cycle(p.rpt_yr)  as cycle,
        min(to_timestamp(p.cvg_start_dt)) as coverage_start_date,
        max(to_timestamp(p.cvg_end_dt)) as coverage_end_date,
        sum(p.cand_cntb) as candidate_contribution,
        sum(p.pol_pty_cmte_contb + p.oth_cmte_ref) as contribution_refunds,
        sum(p.ttl_contb) as contributions,
        sum(p.ttl_disb) as disbursements,
        sum(p.exempt_legal_acctg_disb) as exempt_legal_accounting_disbursement,
        sum(p.fed_funds_per) as federal_funds,
        sum(p.fed_funds_per) > 0 as federal_funds_flag,
        sum(p.fndrsg_disb) as fundraising_disbursements,
        sum(p.indv_ref) as individual_contributions,
        sum(p.indv_unitem_contb) as individual_unitemized_contributions,
        sum(p.indv_item_contb) as individual_itemized_contributions,
        sum(p.ttl_loans) as loans_received,
        sum(p.cand_loan) as loans_received_from_candidate,
        sum(p.cand_loan_repymnt + p.oth_loan_repymts) as loan_repayments_made,
        sum(p.offsets_to_fndrsg) as offsets_to_fundraising_expenditures,
        sum(p.offsets_to_legal_acctg) as offsets_to_legal_accounting,
        sum(p.offsets_to_op_exp) as offsets_to_operating_expenditures,
        sum(p.offsets_to_op_exp + p.offsets_to_fndrsg + p.offsets_to_legal_acctg) as total_offsets_to_operating_expenditures,
        sum(p.op_exp_per) as operating_expenditures,
        sum(p.other_disb_per) as other_disbursements,
        sum(p.oth_loans) as other_loans_received,
        sum(p.oth_cmte_contb) as other_political_committee_contributions,
        sum(p.other_receipts) as other_receipts,
        sum(p.pol_pty_cmte_contb) as political_party_committee_contributions,
        sum(p.ttl_receipts) as receipts,
        sum(p.indv_ref) as refunded_individual_contributions,
        sum(p.oth_cmte_ref) as refunded_other_political_committee_contributions,
        sum(p.pol_pty_cmte_contb) as refunded_political_party_committee_contributions,
        sum(p.cand_loan_repymnt) as repayments_loans_made_by_candidate,
        sum(p.oth_loan_repymts) as repayments_other_loans,
        sum(p.tranf_from_other_auth_cmte) as transfers_from_affiliated_committee,
        sum(p.tranf_to_other_auth_cmte) as transfers_to_other_authorized_committee,
        sum(p.coh_bop) as cash_on_hand_beginning_of_period,
        sum(p.debts_owed_by_cmte) as debts_owed_by_cmte,
        sum(p.debts_owed_to_cmte) as debts_owed_to_cmte,
        max(last.net_contb) as net_contributions,
        max(last.net_op_exp) as net_operating_expenditures,
        max(last.report_type_full) as last_report_type_full,
        max(last.beginning_image_number) as last_beginning_image_number,
        min(cash_beginning_period.cash_on_hand) as cash_on_hand_beginning_period,
        max(last.coh_cop) as last_cash_on_hand_end_period,
        max(last.debts_owed_by_cmte) as last_debts_owed_by_committee,
        max(last.debts_owed_to_cmte) as last_debts_owed_to_committee,
        max(last.rpt_yr) as last_report_year
    from
        disclosure.v_sum_and_det_sum_report p
        inner join last on p.cmte_id = last.cmte_id and get_cycle(p.rpt_yr) = last.cycle
        left join cash_beginning_period on
            p.cmte_id = cash_beginning_period.committee_id and
            get_cycle(p.rpt_yr) = cash_beginning_period.cycle
    where
        get_cycle(p.rpt_yr) >= :START_YEAR
    group by
        p.cmte_id,
        get_cycle(p.rpt_yr)
;

create unique index on ofec_totals_presidential_mv_tmp(sub_id);

create index on ofec_totals_presidential_mv_tmp(cycle, sub_id);
create index on ofec_totals_presidential_mv_tmp(committee_id, sub_id);
