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
	      first_value(pnp.coh_bop) over wnd as cash_on_hand
	  from
        fec_vsum_f3x_vw pnp
        left join last using (cmte_id, election_cycle)
    where
        pnp.most_recent_filing_flag like 'Y'
        and pnp.election_cycle >= :START_YEAR
    WINDOW wnd AS(
    	partition by cmte_id, election_cycle order by pnp.cmte_id, pnp.election_cycle, pnp.cvg_end_dt
    	ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )
), aggregate_filings as (
    SELECT
        row_number()
        OVER ()                                AS idx,
        cmte_id                                AS committee_id,
        election_cycle                         AS cycle,
        min(pnp.cvg_start_dt)                  AS coverage_start_date,
        max(pnp.cvg_end_dt)                    AS coverage_end_date,
        sum(pnp.all_loans_received_per)        AS all_loans_received,
        sum(pnp.shared_fed_actvy_nonfed_per)   AS allocated_federal_election_levin_share,
        sum(pnp.ttl_contb_refund)              AS contribution_refunds,
        sum(pnp.ttl_contb_per)                 AS contributions,
        sum(pnp.coord_exp_by_pty_cmte_per)     AS coordinated_expenditures_by_party_committee,
        sum(pnp.ttl_disb)                      AS disbursements,
        sum(pnp.fed_cand_cmte_contb_per)       AS fed_candidate_committee_contributions,
        sum(pnp.fed_cand_contb_ref_per)        AS fed_candidate_contribution_refunds,
        sum(pnp.ttl_fed_disb_per)              AS fed_disbursements,
        sum(pnp.ttl_fed_elect_actvy_per)       AS fed_election_activity,
        sum(pnp.ttl_fed_op_exp_per)            AS fed_operating_expenditures,
        sum(pnp.ttl_fed_receipts_per)          AS fed_receipts,
        sum(pnp.indt_exp_per)                  AS independent_expenditures,
        sum(pnp.indv_contb_ref_per)            AS refunded_individual_contributions,
        sum(pnp.indv_item_contb_per)           AS individual_itemized_contributions,
        sum(pnp.indv_unitem_contb_per)         AS individual_unitemized_contributions,
        sum(pnp.ttl_indv_contb)                AS individual_contributions,
        sum(pnp.loan_repymts_made_per)         AS loan_repayments_made,
        sum(pnp.loan_repymts_received_per)     AS loan_repayments_received,
        sum(pnp.loans_made_per)                AS loans_made,
        sum(pnp.net_contb_per)                 AS net_contributions,
        sum(pnp.net_op_exp_per)                AS net_operating_expenditures,
        sum(pnp.non_alloc_fed_elect_actvy_per) AS non_allocated_fed_election_activity,
        sum(pnp.ttl_nonfed_tranf_per)          AS total_transfers,
        sum(pnp.ttl_op_exp_per)                AS offsets_to_operating_expenditures,
        sum(pnp.ttl_op_exp_per)                AS operating_expenditures,
        sum(pnp.other_disb_per)                AS other_disbursements,
        sum(pnp.other_fed_op_exp_per)          AS other_fed_operating_expenditures,
        sum(pnp.other_fed_receipts_per)        AS other_fed_receipts,
        sum(pnp.other_pol_cmte_contb_per_i)    AS other_political_committee_contributions,
        sum(pnp.other_pol_cmte_refund)         AS refunded_other_political_committee_contributions,
        sum(pnp.pol_pty_cmte_contb_per_i)      AS political_party_committee_contributions,
        sum(pnp.pol_pty_cmte_refund)           AS refunded_political_party_committee_contributions,
        sum(pnp.ttl_receipts)                  AS receipts,
        sum(pnp.shared_fed_actvy_fed_shr_per)  AS shared_fed_activity,
        sum(pnp.shared_fed_actvy_nonfed_per)   AS shared_fed_activity_nonfed,
        sum(pnp.shared_fed_op_exp_per)         AS shared_fed_operating_expenditures,
        sum(pnp.shared_nonfed_op_exp_per)      AS shared_nonfed_operating_expenditures,
        sum(pnp.tranf_from_affiliated_pty_per) AS transfers_from_affiliated_party,
        sum(pnp.tranf_from_nonfed_acct_per)    AS transfers_from_nonfed_account,
        sum(pnp.tranf_from_nonfed_levin_per)   AS transfers_from_nonfed_levin,
        sum(pnp.tranf_to_affliliated_cmte_per) AS transfers_to_affiliated_committee,
        max(last.rpt_tp_desc)                  AS last_report_type_full,
        max(last.begin_image_num)              AS last_beginning_image_number,
        max(greatest(last.coh_cop))            AS last_cash_on_hand_end_period,
        max(last.debts_owed_by_cmte)           AS last_debts_owed_by_committee,
        max(last.debts_owed_to_cmte)           AS last_debts_owed_to_committee,
        max(last.rpt_yr)                       AS last_report_year
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
	cash_beginning_period.cash_on_hand as cash_on_hand_beginning_period,
  af.transfers_from_nonfed_levin + af.transfers_from_nonfed_account as total_transfers
	from aggregate_filings af
	left join cash_beginning_period using (committee_id, cycle)
;

create unique index on ofec_totals_pacs_parties_mv_tmp(idx);

create index on ofec_totals_pacs_parties_mv_tmp(cycle, idx);
create index on ofec_totals_pacs_parties_mv_tmp(committee_id, idx);
