  with last_cycle as (
    select distinct on (v_sum.cmte_id, link.fec_election_yr)
	      v_sum.cmte_id,
        v_sum.rpt_yr as report_year,
        v_sum.coh_cop as cash_on_hand_end_period,
        case when v_sum.cvg_start_dt = 99999999 then null::timestamp
          else cast(cast(v_sum.cvg_start_dt as text) as date) end
        as coverage_start_date,
        cast(cast(v_sum.cvg_end_dt as text) as timestamp) as coverage_end_date,
        v_sum.debts_owed_by_cmte as debts_owed_by_committee,
        v_sum.debts_owed_to_cmte as debts_owed_to_committee,
        of.report_type_full as report_type_full,
        of.beginning_image_number,
        link.cand_id as candidate_id,
        link.fec_election_yr as cycle,
        link.cand_election_yr as election_year
    from disclosure.v_sum_and_det_sum_report v_sum
	  inner join ofec_cand_cmte_linkage_mv link using(cmte_id)
	  left join ofec_filings_mv of on of.sub_id = v_sum.orig_sub_id
	  where
		  (v_sum.form_tp_cd = 'F3P' or v_sum.form_tp_cd = 'F3')
		  and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
	  	and cvg_end_dt != 99999999
		  and link.fec_election_yr = extract (year from cast(cast(v_sum.cvg_end_dt as text) as timestamp))
		order by
			v_sum.cmte_id,
			link.fec_election_yr,
			cvg_end_dt desc),
  ending_totals_per_cycle as (
      select last.cycle,
        last.candidate_id,
        --should use max here?
        max(last.coverage_end_date) as coverage_end_date,
        min(last.coverage_start_date) as coverage_start_date,
        max(last.report_type_full) as last_report_type_full,
        max(last.beginning_image_number) as last_beginning_image_number,
        sum(last.cash_on_hand_end_period) as last_cash_on_hand_end_period,
        sum(last.debts_owed_by_committee) as last_debts_owed_by_committee,
        sum(last.debts_owed_to_committee) as last_debts_owed_to_committee,
        max(last.report_year) as last_report_year
      from last_cycle last
      group by
        last.cycle,
        last.candidate_id
    ),

    -- totals per candidate, per two-year cycle, with firsts and lasts
  cycle_totals as(
    select
        link.cand_id as candidate_id,
        link.fec_election_yr as cycle,
        max(link.fec_election_yr) as election_year,
        --case when max(p.cvg_start_dt) = 99999999 then null::timestamp
        min(cast(cast(p.cvg_start_dt as text) as date)) as coverage_start_date,
        sum(p.cand_cntb) as candidate_contribution,
        sum(p.pol_pty_cmte_contb + p.oth_cmte_ref) as contribution_refunds,
        sum(p.ttl_contb) as contributions,
        sum(p.ttl_disb) as disbursements,
        sum(p.exempt_legal_acctg_disb) as exempt_legal_accounting_disbursement,
        sum(p.fed_funds_per) as federal_funds,
        sum(p.fed_funds_per) > 0 as federal_funds_flag,
        sum(p.fndrsg_disb) as fundraising_disbursements,
        sum(p.indv_ref) as individual_contributions,-- unfortunately, a wrong name in v_sum
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
        sum(p.pty_cmte_contb) as political_party_committee_contributions,
        sum(p.ttl_receipts) as receipts,
        sum(p.indv_ref) as refunded_individual_contributions, -- renamed from "refunds_"
        sum(p.oth_cmte_ref) as refunded_other_political_committee_contributions,
        sum(p.pol_pty_cmte_contb) as refunded_political_party_committee_contributions,
        sum(p.cand_loan_repymnt) as repayments_loans_made_by_candidate,
        sum(p.oth_loan_repymts) as repayments_other_loans,
        sum(p.tranf_from_other_auth_cmte) as transfers_from_affiliated_committee,
        sum(p.tranf_to_other_auth_cmte) as transfers_to_other_authorized_committee,
        sum(p.net_op_exp) as net_operating_expenditures,
        sum(p.net_contb) as net_contributions,
        -- these are added in the event that a candidate has multiple committees
        false as full_election
        --coalesce(min(first.cvg_start_dt), min(last.coverage_start_date)) as coverage_start_date,

        --min(first.cash_on_hand_beginning_of_period) as cash_on_hand_beginning_of_period
    from
        -- starting with candidate will consolidate record in the event that a candidate has multiple committees
        --ofec_cand_cmte_linkage_mv link
        ofec_cand_cmte_linkage_mv link
        inner join disclosure.v_sum_and_det_sum_report p on link.cmte_id = p.cmte_id and link.fec_election_yr = get_cycle(p.rpt_yr)
    where
        link.fec_election_yr >= 1970
        -- this issue with the data is really driving me nuts.  Jeff said he's looking into it,
        -- leaving a reminder here, but this check filters out these 9999... records.
        and p.cvg_start_dt != 99999999
        and (p.form_tp_cd = 'F3P' or p.form_tp_cd = 'F3')
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
    group by
        link.fec_election_yr,
        link.cand_id
    )
    select
      cycle_totals.receipts,
      cycle_totals.disbursements,
      cycle_totals.cycle,
      ending_totals.cycle,
      ending_totals.coverage_end_date,
      cycle_totals.coverage_start_date,
      ending_totals.last_report_type_full,
      ending_totals.last_beginning_image_number,
      ending_totals.last_cash_on_hand_end_period,
      ending_totals.last_debts_owed_by_committee,
      ending_totals.last_debts_owed_to_committee,
      ending_totals.last_report_year
    from cycle_totals cycle_totals
    inner join ending_totals_per_cycle ending_totals
  on ending_totals.cycle = cycle_totals.cycle and ending_totals.candidate_id = cycle_totals.candidate_id
    where cycle_totals.candidate_id = 'P80002801';
  --select receipts, disbursements, cycle, last_cash_on_hand_end_period from cycle_totals where candidate_id = 'P80002801';
