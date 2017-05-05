drop materialized view if exists ofec_totals_pacs_parties_mv_tmp cascade;
create materialized view ofec_totals_pacs_parties_mv_tmp as
with last as (
    select distinct on (cmte_id, election_cycle) *
    from fec_vsum_f3x_vw
    order by
        cmte_id,
        election_cycle,
        cvg_end_dt desc
), cash_beginning_period as (
	select distinct on (cmte_id, election_cycle)
	      cmte_id                           as committee_id,
	      election_cycle                    as cycle,
	      coh_bop as cash_on_hand
	from
        fec_vsum_f3x_vw
    where
        most_recent_filing_flag like 'Y'
        and election_cycle >= :START_YEAR
    order by
        cmte_id,
        election_cycle,
        cvg_end_dt asc
), aggregate_filings as (
     SELECT
         orig_sub_id as sub_id,
         cmte_id as committee_id,
         get_cycle(pnp.rpt_yr) as cycle,
         min(to_timestamp(pnp.cvg_start_dt)) as coverage_start_date,
         max(to_timestamp(pnp.cvg_end_dt)) as coverage_end_date,
         sum(pnp.all_loans_received_per) as all_loans_received,
         sum(pnp.shared_fed_actvy_nonfed_per) as allocated_federal_election_levin_share,
         sum(pnp.ttl_contb_ref) as contribution_refunds,
         sum(pnp.ttl_contb) as contributions,
         sum(pnp.coord_exp_by_pty_cmte_per) as coordinated_expenditures_by_party_committee,
         sum(pnp.ttl_disb) as disbursements,
         sum(pnp.fed_cand_cmte_contb_per) as fed_candidate_committee_contributions,
         sum(pnp.fed_cand_contb_ref_per) as fed_candidate_contribution_refunds,
         -- not sure about this one i think it might be fed_funds_per
         --sum(pnp.ttl_fed_disb_per) as fed_disbursements,
         sum(pnp.ttl_fed_elect_actvy_per) as fed_election_activity,
         sum(pnp.ttl_fed_op_exp_per) as fed_operating_expenditures,
         sum(pnp.ttl_fed_receipts_per) as fed_receipts,
         sum(pnp.indt_exp_per) as independent_expenditures,
         sum(pnp.indv_ref) as refunded_individual_contributions,
         sum(pnp.indv_item_contb) as individual_itemized_contributions,
         sum(pnp.indv_unitem_contb) as individual_unitemized_contributions,
         sum(pnp.indv_contb) as individual_contributions,
         sum(pnp.oth_loan_repymts) as loan_repayments_made,
         sum(pnp.loan_repymts_received_per) as loan_repayments_received,
         sum(pnp.loans_made_per) as loans_made,
         -- sum nets?
         sum(pnp.net_op_exp) as net_operating_expenditures,
         sum(pnp.non_alloc_fed_elect_actvy_per) as non_allocated_fed_election_activity,
         sum(pnp.ttl_nonfed_tranf_per) as total_transfers,
         sum(pnp.offsets_to_op_exp + pnp.offsets_to_fndrsg + pnp.offsets_to_legal_acctg) as offsets_to_operating_expenditures,
         sum(pnp.op_exp_per) as operating_expenditures,
         sum(pnp.other_disb_per) as other_disbursements,
         sum(pnp.other_fed_op_exp_per) as other_fed_operating_expenditures,
         sum(pnp.other_receipts) as other_fed_receipts,
         sum(pnp.oth_cmte_contb) as other_political_committee_contributions,
         sum(pnp.oth_cmte_ref) as refunded_other_political_committee_contributions,
         sum(pnp.pty_cmte_contb) as political_party_committee_contributions,
         sum(pnp.pol_pty_cmte_contb) as refunded_political_party_committee_contributions,
         sum(pnp.ttl_receipts) as receipts,
         sum(pnp.shared_fed_actvy_fed_shr_per) as shared_fed_activity,
         sum(pnp.shared_fed_actvy_nonfed_per) as shared_fed_activity_nonfed,
         sum(pnp.shared_fed_op_exp_per) as shared_fed_operating_expenditures,
         sum(pnp.shared_nonfed_op_exp_per) as shared_nonfed_operating_expenditures,
         sum(pnp.tranf_from_other_auth_cmte) as transfers_from_affiliated_party,
         sum(pnp.tranf_from_nonfed_acct_per) as transfers_from_nonfed_account,
         sum(pnp.tranf_from_nonfed_levin_per) as transfers_from_nonfed_levin,
         sum(pnp.tranf_to_other_auth_cmte) as transfers_to_affiliated_committee,
         sum(last.net_contb) as net_contributions,
         max(last.rpt_tp_desc) as last_report_type_full,
         max(last.begin_image_num) as last_beginning_image_number,
         max(greatest(last.coh_cop)) as last_cash_on_hand_end_period,
         max(last.coh_bop) as last_cash_on_hand_beginning_period,
         max(last.debts_owed_by_cmte) as last_debts_owed_by_committee,
         max(last.debts_owed_to_cmte) as last_debts_owed_to_committee,
         max(last.rpt_yr) as last_report_year
    FROM
        fec_vsum_f3x_vw pnp
        INNER JOIN last USING (cmte_id, election_cycle)
    WHERE
        pnp.most_recent_filing_flag LIKE 'Y'
        AND election_cycle >= :START_YEAR
    GROUP BY
        cmte_id,
        pnp.election_cycle
)select af.*,
	cash_beginning_period.cash_on_hand as cash_on_hand_beginning_period
	from aggregate_filings af
	left join cash_beginning_period using (committee_id, cycle)
;

create unique index on ofec_totals_pacs_parties_mv_tmp(sub_id);

create index on ofec_totals_pacs_parties_mv_tmp(cycle, sub_id);
create index on ofec_totals_pacs_parties_mv_tmp(committee_id, sub_id );
