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
	  left join ofec_cand_cmte_linkage_mv link using(cmte_id)
	  left join ofec_filings_mv of on of.sub_id = v_sum.orig_sub_id
	  where
		  (v_sum.form_tp_cd = 'F3P' or v_sum.form_tp_cd = 'F3')
		  and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
	  	and cvg_end_dt != 99999999
		  and link.fec_election_yr = get_cycle(extract (year from cast(cast(v_sum.cvg_end_dt as text) as timestamp))::int)
		order by
			v_sum.cmte_id,
			link.fec_election_yr,
			cvg_end_dt desc nulls last),
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
        min(cast(cast(p.cvg_start_dt as text) as timestamp)) as coverage_start_date,
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
        left join disclosure.v_sum_and_det_sum_report p on link.cmte_id = p.cmte_id and link.fec_election_yr = get_cycle(p.rpt_yr)
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
    ), cycle_totals_with_ending_aggregates as (
      select
        cycle_totals.*,
        ending_totals.coverage_end_date,
        ending_totals.last_report_type_full,
        ending_totals.last_beginning_image_number,
        ending_totals.last_cash_on_hand_end_period,
        ending_totals.last_debts_owed_by_committee,
        ending_totals.last_debts_owed_to_committee,
        ending_totals.last_report_year
      from cycle_totals cycle_totals
      left join ending_totals_per_cycle ending_totals
      on ending_totals.cycle = cycle_totals.cycle AND ending_totals.candidate_id = cycle_totals.candidate_id
  ), election_totals as (
    select
            totals.candidate_id as candidate_id,
            max(totals.cycle) as cycle,
            max(totals.election_year) as election_year,
            min(totals.coverage_start_date) as coverage_start_date,
            max(totals.coverage_end_date) as coverage_end_date,
            sum(totals.candidate_contribution) as candidate_contribution,
            sum(totals.contribution_refunds) as contribution_refunds,
            sum(totals.contributions) as contributions,
            sum(totals.disbursements) as disbursements,
            sum(totals.exempt_legal_accounting_disbursement) as exempt_legal_accounting_disbursement,
            sum(totals.federal_funds) as federal_funds,
            sum(totals.federal_funds) > 0 as federal_funds_flag,
            sum(totals.fundraising_disbursements) as fundraising_disbursements,
            sum(totals.individual_contributions) as individual_contributions,
            sum(totals.individual_unitemized_contributions) as individual_unitemized_contributions,
            sum(totals.individual_itemized_contributions) as individual_itemized_contributions,
            sum(totals.loans_received) as loans_received,
            sum(totals.loans_received_from_candidate) as loans_received_from_candidate,
            sum(totals.loan_repayments_made) as loan_repayments_made,
            sum(totals.offsets_to_fundraising_expenditures) as offsets_to_fundraising_expenditures,
            sum(totals.offsets_to_legal_accounting) as offsets_to_legal_accounting,
            sum(totals.offsets_to_operating_expenditures) as offsets_to_operating_expenditures,
            sum(totals.total_offsets_to_operating_expenditures) as total_offsets_to_operating_expenditures,
            sum(totals.operating_expenditures) as operating_expenditures,
            sum(totals.other_disbursements) as other_disbursements,
            sum(totals.other_loans_received) as other_loans_received,
            sum(totals.other_political_committee_contributions) as other_political_committee_contributions,
            sum(totals.other_receipts) as other_receipts,
            sum(totals.political_party_committee_contributions) as political_party_committee_contributions,
            sum(totals.receipts) as receipts,
            sum(totals.refunded_individual_contributions) as refunded_individual_contributions,
            sum(totals.refunded_other_political_committee_contributions) as refunded_other_political_committee_contributions,
            sum(totals.refunded_political_party_committee_contributions) as refunded_political_party_committee_contributions,
            sum(totals.repayments_loans_made_by_candidate) as repayments_loans_made_by_candidate,
            sum(totals.repayments_other_loans ) as repayments_other_loans,
            sum(totals.transfers_from_affiliated_committee) as transfers_from_affiliated_committee,
            sum(totals.transfers_to_other_authorized_committee) as transfers_to_other_authorized_committee,
            sum(totals.net_operating_expenditures) as net_operating_expenditures,
            sum(totals.net_contributions) as net_contributions,
            -- these are added in the event that a candidate has multiple committees
            true as full_election
        from
            cycle_totals_with_ending_aggregates totals
            left join ofec_candidate_election_mv election on
                totals.candidate_id = election.candidate_id and
                totals.cycle <= election.cand_election_year and
                totals.cycle > election.prev_election_year
        group by
            totals.candidate_id,
            -- this is where the senate records are combined into 6 year election periods
            election.cand_election_year
  ), election_totals_with_ending_aggregates as (
            select et.*,
                totals.last_cash_on_hand_end_period,
                totals.last_report_type_full,
                totals.last_debts_owed_to_committee,
                totals.last_debts_owed_by_committee,
                totals.last_beginning_image_number,
                totals.last_report_year
                --0.0 as cash_on_hand_beginning_of_period
            from ending_totals_per_cycle totals
            inner join ofec_candidate_election_mv election on
                totals.candidate_id = election.candidate_id and
                totals.cycle = election.cand_election_year
            left join election_totals et on totals.candidate_id = et.candidate_id and totals.cycle = et.cycle
            where totals.cycle > 1970

        )

    select coverage_start_date, coverage_end_date,candidate_id, receipts, disbursements, cycle, full_election, last_cash_on_hand_end_period from cycle_totals_with_ending_aggregates where candidate_id = 'S6MO00305'
    union all
    select coverage_start_date, coverage_end_date, candidate_id, receipts, disbursements, cycle, full_election, last_cash_on_hand_end_period from election_totals_with_ending_aggregates where candidate_id = 'S6MO00305'
  ;

