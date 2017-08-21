-- Creates materialized view of the most recent report per committee, per cycle
drop materialized view if exists ofec_totals_combined_mv_tmp;
create materialized view ofec_totals_combined_mv_tmp as
-- done in two steps to reduce the scope of the join
 WITH last_subset AS (
         SELECT DISTINCT ON (cmte_id, get_cycle(rpt_yr)) 
		orig_sub_id,
            	cmte_id,
            	coh_cop,
            	debts_owed_by_cmte,
            	debts_owed_to_cmte,
            	net_op_exp,
            	net_contb,
            	rpt_yr,
            	get_cycle(rpt_yr) AS cycle
         FROM disclosure.v_sum_and_det_sum_report
         WHERE get_cycle(rpt_yr) >= :START_YEAR
          -- issue #2601: F5 has both regular and 24/48 notices data included in disclosure.v_sum_and_det_sum_report, need to exclude the 24/48 hours notice data
          and rpt_tp not in ('24','48')
          --
          ORDER BY 
          cmte_id, 
          get_cycle(rpt_yr), 
          to_timestamp(cvg_end_dt) DESC NULLS LAST
        ), 
        last AS (
         SELECT ls.cmte_id,
            -- issue #2601: need this information later in the main query 
            ls.orig_sub_id,
            --
            ls.coh_cop,
            ls.cycle,
            ls.debts_owed_by_cmte,
            ls.debts_owed_to_cmte,
            ls.net_op_exp,
            ls.net_contb,
            ls.rpt_yr,
            of.candidate_id,
            of.beginning_image_number,
            of.coverage_end_date::timestamp,
            of.form_type,
            of.report_type_full,
            of.report_type,
            of.candidate_name,
            of.committee_name
           FROM last_subset ls
             LEFT JOIN ofec_filings_mv of ON ls.orig_sub_id = of.sub_id
        ), 
-- Creates materialized view of the earliest report as amended per committee, per cycle
/* -- issue #2601: this subquery is not referred in later query, can be removed       
        first_subset AS (
         SELECT DISTINCT ON (cmte_id, get_cycle(rpt_yr)) coh_bop AS cash_on_hand,
            to_timestamp(cvg_start_dt) AS coverage_start_date,
            cmte_id AS committee_id,
            get_cycle(rpt_yr) AS cycle
           FROM disclosure.v_sum_and_det_sum_report
          WHERE get_cycle(rpt_yr) >= :START_YEAR
          -- issue #2601: F5 has both regular and 24/48 notices data included in disclosure.v_sum_and_det_sum_report, need to exclude the 24/48 hours notice data
          and rpt_tp not in ('24','48')
          --
          ORDER BY 
          cmte_id, 
          get_cycle(rpt_yr), 
          to_timestamp(cvg_end_dt) asc
        ), 
*/
        first AS (
         SELECT DISTINCT ON (cmte_id, get_cycle(rpt_yr)) 
         coh_bop AS cash_on_hand,
            cmte_id AS committee_id,
                CASE
                    WHEN cvg_start_dt = 99999999 THEN NULL::timestamp
                    ELSE cast(cast(cvg_start_dt as text) as date)
                END AS coverage_start_date,
            get_cycle(rpt_yr) AS cycle
           FROM disclosure.v_sum_and_det_sum_report
          WHERE get_cycle(rpt_yr) >= :START_YEAR
          -- issue #2601: F5 has both regular and 24/48 notices data included in disclosure.v_sum_and_det_sum_report, need to exclude the 24/48 hours notice data
          and rpt_tp not in ('24','48')
          --
          ORDER BY 
          cmte_id, 
          get_cycle(rpt_yr), 
          to_timestamp(cvg_end_dt) asc
        )
 SELECT get_cycle(vsd.rpt_yr) AS cycle,
    max(last.candidate_id) AS candidate_id,
    max(last.candidate_name) AS candidate_name,
    max(last.committee_name) AS committee_name,
    max(last.beginning_image_number) AS last_beginning_image_number,
    max(last.coh_cop) AS last_cash_on_hand_end_period,
    max(last.debts_owed_by_cmte) AS last_debts_owed_by_committee,
    max(last.debts_owed_to_cmte) AS last_debts_owed_to_committee,
    max(last.net_contb) AS last_net_contributions,
    max(last.net_op_exp) AS last_net_operating_expenditures,
    max(last.report_type) AS last_report_type,
    max(last.report_type_full) AS last_report_type_full,
    max(last.rpt_yr) AS last_report_year,
    max(last.coverage_end_date) AS coverage_end_date,
    -- issue #2601: should not use max(vsd.orig_sub_id), sub_id's format is not mmddyyyy, so max will not work all the time.  Need to get it from subquery "last"
    max(last.orig_sub_id) AS sub_id,
    --
    min(first.cash_on_hand) AS cash_on_hand_beginning_period,
    min(first.coverage_start_date) AS coverage_start_date,
    sum(vsd.all_loans_received_per) AS all_loans_received,
    sum(vsd.cand_cntb) AS candidate_contribution,
    sum(vsd.cand_loan_repymnt + vsd.oth_loan_repymts) AS loan_repayments_made,
    sum(vsd.cand_loan_repymnt) AS loan_repayments_candidate_loans,
    sum(vsd.cand_loan) AS loans_made_by_candidate,
    sum(vsd.cand_loan_repymnt) AS repayments_loans_made_by_candidate,
    sum(vsd.cand_loan) AS loans_received_from_candidate,
    sum(vsd.coord_exp_by_pty_cmte_per) AS coordinated_expenditures_by_party_committee,
    sum(vsd.exempt_legal_acctg_disb) AS exempt_legal_accounting_disbursement,
    sum(vsd.fed_cand_cmte_contb_per) AS fed_candidate_committee_contributions,
    sum(vsd.fed_cand_contb_ref_per) AS fed_candidate_contribution_refunds,
    sum(vsd.fed_funds_per) > 0::numeric AS federal_funds_flag,
    sum(vsd.fed_funds_per) AS fed_disbursements,
    sum(vsd.fed_funds_per) AS federal_funds,
    sum(vsd.fndrsg_disb) AS fundraising_disbursements,
    sum(vsd.indv_contb) AS individual_contributions,
    sum(vsd.indv_item_contb) AS individual_itemized_contributions,
    sum(vsd.indv_ref) AS refunded_individual_contributions,
    sum(vsd.indv_unitem_contb) AS individual_unitemized_contributions,
    sum(vsd.loan_repymts_received_per) AS loan_repayments_received,
    sum(vsd.loans_made_per) AS loans_made,
    sum(vsd.net_contb) AS net_contributions,
    sum(vsd.net_op_exp) AS net_operating_expenditures,
    sum(vsd.non_alloc_fed_elect_actvy_per) AS non_allocated_fed_election_activity,
    sum(vsd.offsets_to_fndrsg) AS offsets_to_fundraising_expenditures,
    sum(vsd.offsets_to_legal_acctg) AS offsets_to_legal_accounting,
    sum(vsd.offsets_to_op_exp + vsd.offsets_to_fndrsg + vsd.offsets_to_legal_acctg) AS total_offsets_to_operating_expenditures,
    sum(vsd.offsets_to_op_exp) AS offsets_to_operating_expenditures,
    sum(vsd.op_exp_per) AS operating_expenditures,
    sum(vsd.oth_cmte_contb) AS other_political_committee_contributions,
    sum(vsd.oth_cmte_ref) AS refunded_other_political_committee_contributions,
    sum(vsd.oth_loan_repymts) AS loan_repayments_other_loans,
    sum(vsd.oth_loan_repymts) AS repayments_other_loans,
    sum(vsd.oth_loans) AS all_other_loans,
    sum(vsd.oth_loans) AS other_loans_received,
    sum(vsd.other_disb_per) AS other_disbursements,
    sum(vsd.other_fed_op_exp_per) AS other_fed_operating_expenditures,
    sum(vsd.other_receipts) AS other_fed_receipts,
    sum(vsd.other_receipts) AS other_receipts,
    sum(vsd.pol_pty_cmte_contb) AS refunded_political_party_committee_contributions,
    sum(vsd.pty_cmte_contb) AS political_party_committee_contributions,
    sum(vsd.shared_fed_actvy_fed_shr_per) AS shared_fed_activity,
    sum(vsd.shared_fed_actvy_nonfed_per) AS allocated_federal_election_levin_share,
    sum(vsd.shared_fed_actvy_nonfed_per) AS shared_fed_activity_nonfed,
    sum(vsd.shared_fed_op_exp_per) AS shared_fed_operating_expenditures,
    sum(vsd.shared_nonfed_op_exp_per) AS shared_nonfed_operating_expenditures,
    sum(vsd.tranf_from_nonfed_acct_per) AS transfers_from_nonfed_account,
    sum(vsd.tranf_from_nonfed_levin_per) AS transfers_from_nonfed_levin,
    sum(vsd.tranf_from_other_auth_cmte) AS transfers_from_affiliated_committee,
    sum(vsd.tranf_from_other_auth_cmte) AS transfers_from_affiliated_party,
    sum(vsd.tranf_from_other_auth_cmte) AS transfers_from_other_authorized_committee,
    sum(vsd.tranf_to_other_auth_cmte) AS transfers_to_affiliated_committee,
    sum(vsd.tranf_to_other_auth_cmte) AS transfers_to_other_authorized_committee,
    sum(vsd.ttl_contb_ref) AS contribution_refunds,
    sum(vsd.ttl_contb) AS contributions,
    sum(vsd.ttl_disb) AS disbursements,
    sum(vsd.ttl_fed_elect_actvy_per) AS fed_election_activity,
    sum(vsd.ttl_fed_receipts_per) AS fed_receipts,
    sum(vsd.ttl_loan_repymts) AS loan_repayments,
    sum(vsd.ttl_loans) AS loans_received,
    sum(vsd.ttl_loans) AS loans,
    sum(vsd.ttl_nonfed_tranf_per) AS total_transfers,
    sum(vsd.ttl_receipts) AS receipts,
    vsd.cmte_id AS committee_id,
    vsd.form_tp_cd AS form_type,
        CASE
            WHEN max(last.form_type) = ANY (ARRAY['F3', 'F3P']) THEN NULL::numeric
            ELSE sum(vsd.indt_exp_per)
        END AS independent_expenditures
   FROM disclosure.v_sum_and_det_sum_report vsd
     LEFT JOIN last ON vsd.cmte_id = last.cmte_id AND get_cycle(vsd.rpt_yr) = last.cycle
     LEFT JOIN first ON vsd.cmte_id = first.committee_id AND get_cycle(vsd.rpt_yr) = first.cycle
  WHERE get_cycle(vsd.rpt_yr) >= :START_YEAR
  -- issue #2601: F5 has both regular and 24/48 notices data included in disclosure.v_sum_and_det_sum_report, need to exclude the 24/48 hours notice data
  and vsd.rpt_tp not in ('24','48')
  --
  GROUP BY 
  vsd.cmte_id, 
  vsd.form_tp_cd, 
  get_cycle(vsd.rpt_yr);


create unique index on ofec_totals_combined_mv_tmp (sub_id);

create index on ofec_totals_combined_mv_tmp (committee_id, sub_id);
create index on ofec_totals_combined_mv_tmp (cycle, sub_id);
create index on ofec_totals_combined_mv_tmp (receipts, sub_id);
create index on ofec_totals_combined_mv_tmp (disbursements, sub_id);
