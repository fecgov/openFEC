with last as (
    select distinct on (f3p.cmte_id, f3p.election_cycle) f3p.*, link.cand_id
    from fec_vsum_f3p_vw f3p
    inner join ofec_cand_cmte_linkage_mv link on link.cmte_id = f3p.cmte_id
    where
        substr(link.cand_id, 1, 1) = link.cmte_tp
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
        and election_cycle >= :START_YEAR
    order by
        f3p.cmte_id,
        f3p.election_cycle,
        f3p.cvg_end_dt desc
), aggregate_last as(
    select last.election_cycle as cycle,
        last.cand_id as candidate_id,
        sum(last.net_contb_sum_page_per) as net_contributions,
        sum(last.net_op_exp_sum_page_per) as net_operating_expenditures,
        max(last.rpt_tp_desc) as last_report_type_full,
        max(last.begin_image_num) as last_beginning_image_number,
        sum(last.coh_cop) as last_cash_on_hand_end_period,
        sum(last.debts_owed_by_cmte) as last_debts_owed_by_committee,
        sum(last.debts_owed_to_cmte) as last_debts_owed_to_committee,
        max(last.rpt_yr) as last_report_year
    from last
    group by
        last.election_cycle,
        last.cand_id
),
aggregate_filings as(
    select
        cand_id as candidate_id,
        p.election_cycle as cycle,
        min(p.cvg_start_dt) as coverage_start_date,
        max(p.cvg_end_dt) as coverage_end_date,
        sum(p.cand_contb_per) as candidate_contribution,
        sum(p.ttl_contb_ref_per) as contribution_refunds,
        sum(p.ttl_contb_per) as contributions,
        sum(p.ttl_disb_per) as disbursements,
        sum(p.exempt_legal_acctg_disb_per) as exempt_legal_accounting_disbursement,
        sum(p.fed_funds_per) as federal_funds,
        sum(p.fed_funds_per) > 0 as federal_funds_flag,
        sum(p.fndrsg_disb_per) as fundraising_disbursements,
        sum(p.ttl_indiv_contb_per) as individual_contributions,
        sum(p.indv_unitem_contb_per) as individual_unitemized_contributions,
        sum(p.indv_item_contb_per) as individual_itemized_contributions,
        sum(p.ttl_loans_received_per) as loans_received,
        sum(p.loans_received_from_cand_per) as loans_received_from_candidate,
        sum(p.ttl_loan_repymts_made_per) as loan_repayments_made,
        sum(p.offsets_to_fndrsg_exp_per) as offsets_to_fundraising_expenditures,
        sum(p.offsets_to_legal_acctg_per) as offsets_to_legal_accounting,
        sum(p.offsets_to_op_exp_per) as offsets_to_operating_expenditures,
        sum(p.ttl_offsets_to_op_exp_per) as total_offsets_to_operating_expenditures,
        sum(p.op_exp_per) as operating_expenditures,
        sum(p.other_disb_per) as other_disbursements,
        sum(p.other_loans_received_per) as other_loans_received,
        sum(p.other_pol_cmte_contb_per) as other_political_committee_contributions,
        sum(p.other_receipts_per) as other_receipts,
        sum(p.pol_pty_cmte_contb_per) as political_party_committee_contributions,
        sum(p.ttl_receipts_per) as receipts,
        sum(p.ref_indv_contb_per) as refunded_individual_contributions, -- renamed from "refunds_"
        sum(p.ref_other_pol_cmte_contb_per) as refunded_other_political_committee_contributions,
        sum(p.ref_pol_pty_cmte_contb_per) as refunded_political_party_committee_contributions,
        sum(p.repymts_loans_made_by_cand_per) as repayments_loans_made_by_candidate,
        sum(p.repymts_other_loans_per) as repayments_other_loans,
        sum(p.tranf_from_affilated_cmte_per) as transfers_from_affiliated_committee,
        sum(p.tranf_to_other_auth_cmte_per) as transfers_to_other_authorized_committee,
        sum(p.coh_bop) as cash_on_hand_beginning_of_period,
        sum(p.debts_owed_by_cmte) as debts_owed_by_cmte,
        sum(p.debts_owed_to_cmte) as debts_owed_to_cmte

    from
        ofec_candidate_detail_mv cand_detail
        inner join ofec_cand_cmte_linkage_mv link on link.cand_id = cand_detail.candidate_id
        inner join fec_vsum_f3p_vw p on link.cmte_id = p.cmte_id and link.fec_election_yr = p.election_cycle
    where
        p.most_recent_filing_flag like 'Y'
        and p.election_cycle >= :START_YEAR
        and substr(link.cand_id, 1, 1) = link.cmte_tp
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')

    group by
        p.election_cycle,
        cand_id)

        select af.*,
            aggregate_last.last_cash_on_hand_end_period,
            aggregate_last.net_contributions,
            aggregate_last.net_operating_expenditures,
            aggregate_last.last_report_type_full,
            aggregate_last.last_debts_owed_to_committee,
            aggregate_last.last_debts_owed_by_committee,
            aggregate_last.last_beginning_image_number,
            aggregate_last.last_report_year
        from aggregate_filings af
        inner join aggregate_last
        on aggregate_last.cycle = af.cycle and aggregate_last.candidate_id = af.candidate_id
;