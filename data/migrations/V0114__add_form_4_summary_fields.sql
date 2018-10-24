/*
Add missing fields for Form 4 totals

- 1) Add missing fields to ofec_totals_combined_vw
    a) `create or replace ofec_totals_combined_vw` to use new `MV` logic
    b) drop old `MV`
    c) recreate `MV` with new logic
    d) `create or replace ofec_totals_combined_vw` -> `select all` from new `MV`

- 2) Bring missing fields into ofec_totals_pac_party_vw

    - Add new fields from ofec_totals_combined_vw
    - Add ofec_totals_combined_vw.loans to ofec_totals_pacs_parties_vw
    Name it `loans_and_loan_repayments`
    Maps to Form 4's `subttl_loan_repymts_per` (Line 16)

    - Add ofec_totals_combined_vw.federal_funds to ofec_totals_pacs_parties_vw
    Maps to Form 4's `fed_funds_per` (Line 13)

*/

-- 1) Add missing fields to ofec_totals_combined_vw
-- a) `create or replace ofec_totals_combined_vw` to use new `MV` logic

CREATE OR REPLACE VIEW public.ofec_totals_combined_vw AS
WITH last_subset AS (
         SELECT DISTINCT ON (v_sum_and_det_sum_report.cmte_id, (public.get_cycle(v_sum_and_det_sum_report.rpt_yr))) v_sum_and_det_sum_report.orig_sub_id,
            v_sum_and_det_sum_report.cmte_id,
            v_sum_and_det_sum_report.coh_cop,
            v_sum_and_det_sum_report.debts_owed_by_cmte,
            v_sum_and_det_sum_report.debts_owed_to_cmte,
            v_sum_and_det_sum_report.net_op_exp,
            v_sum_and_det_sum_report.net_contb,
            v_sum_and_det_sum_report.rpt_yr,
            public.get_cycle(v_sum_and_det_sum_report.rpt_yr) AS cycle
           FROM disclosure.v_sum_and_det_sum_report
          WHERE ((public.get_cycle(v_sum_and_det_sum_report.rpt_yr) >= 1979) AND (((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F5'::text) OR (((v_sum_and_det_sum_report.form_tp_cd)::text = 'F5'::text) AND ((v_sum_and_det_sum_report.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])))) AND ((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F6'::text))
          ORDER BY v_sum_and_det_sum_report.cmte_id, (public.get_cycle(v_sum_and_det_sum_report.rpt_yr)), (to_timestamp((v_sum_and_det_sum_report.cvg_end_dt)::double precision)) DESC NULLS LAST
        ), last AS (
         SELECT ls.cmte_id,
            ls.orig_sub_id,
            ls.coh_cop,
            ls.cycle,
            ls.debts_owed_by_cmte,
            ls.debts_owed_to_cmte,
            ls.net_op_exp,
            ls.net_contb,
            ls.rpt_yr,
            of.candidate_id,
            of.beginning_image_number,
            of.coverage_end_date,
            of.form_type,
            of.report_type_full,
            of.report_type,
            of.candidate_name,
            of.committee_name
           FROM (last_subset ls
             LEFT JOIN public.ofec_filings_vw of ON ((ls.orig_sub_id = of.sub_id)))
        ), first AS (
         SELECT DISTINCT ON (v_sum_and_det_sum_report.cmte_id, (public.get_cycle(v_sum_and_det_sum_report.rpt_yr))) v_sum_and_det_sum_report.coh_bop AS cash_on_hand,
            v_sum_and_det_sum_report.cmte_id AS committee_id,
                CASE
                    WHEN (v_sum_and_det_sum_report.cvg_start_dt = (99999999)::numeric) THEN NULL::timestamp without time zone
                    ELSE (((v_sum_and_det_sum_report.cvg_start_dt)::text)::date)::timestamp without time zone
                END AS coverage_start_date,
            public.get_cycle(v_sum_and_det_sum_report.rpt_yr) AS cycle
           FROM disclosure.v_sum_and_det_sum_report
          WHERE ((public.get_cycle(v_sum_and_det_sum_report.rpt_yr) >= 1979) AND (((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F5'::text) OR (((v_sum_and_det_sum_report.form_tp_cd)::text = 'F5'::text) AND ((v_sum_and_det_sum_report.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])))) AND ((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F6'::text))
          ORDER BY v_sum_and_det_sum_report.cmte_id, (public.get_cycle(v_sum_and_det_sum_report.rpt_yr)), (to_timestamp((v_sum_and_det_sum_report.cvg_end_dt)::double precision))
        ), committee_info AS (
         SELECT DISTINCT ON (cmte_valid_fec_yr.cmte_id, cmte_valid_fec_yr.fec_election_yr) cmte_valid_fec_yr.cmte_id,
            cmte_valid_fec_yr.fec_election_yr,
            cmte_valid_fec_yr.cmte_nm,
            cmte_valid_fec_yr.cmte_tp,
            cmte_valid_fec_yr.cmte_dsgn,
            cmte_valid_fec_yr.cmte_pty_affiliation_desc
           FROM disclosure.cmte_valid_fec_yr
        )
 SELECT public.get_cycle(vsd.rpt_yr) AS cycle,
    max((last.candidate_id)::text) AS candidate_id,
    max((last.candidate_name)::text) AS candidate_name,
    max((last.committee_name)::text) AS committee_name,
    max(last.beginning_image_number) AS last_beginning_image_number,
    max(last.coh_cop) AS last_cash_on_hand_end_period,
    max(last.debts_owed_by_cmte) AS last_debts_owed_by_committee,
    max(last.debts_owed_to_cmte) AS last_debts_owed_to_committee,
    max(last.net_contb) AS last_net_contributions,
    max(last.net_op_exp) AS last_net_operating_expenditures,
    max((last.report_type)::text) AS last_report_type,
    max((last.report_type_full)::text) AS last_report_type_full,
    max(last.rpt_yr) AS last_report_year,
    max(last.coverage_end_date) AS coverage_end_date,
    max(vsd.orig_sub_id) AS sub_id,
    min(first.cash_on_hand) AS cash_on_hand_beginning_period,
    min(first.coverage_start_date) AS coverage_start_date,
    sum(vsd.all_loans_received_per) AS all_loans_received,
    sum(vsd.cand_cntb) AS candidate_contribution,
    sum((vsd.cand_loan_repymnt + vsd.oth_loan_repymts)) AS loan_repayments_made,
    sum(vsd.cand_loan_repymnt) AS loan_repayments_candidate_loans,
    sum(vsd.cand_loan) AS loans_made_by_candidate,
    sum(vsd.cand_loan_repymnt) AS repayments_loans_made_by_candidate,
    sum(vsd.cand_loan) AS loans_received_from_candidate,
    sum(vsd.coord_exp_by_pty_cmte_per) AS coordinated_expenditures_by_party_committee,
    sum(vsd.exempt_legal_acctg_disb) AS exempt_legal_accounting_disbursement,
    sum(vsd.fed_cand_cmte_contb_per) AS fed_candidate_committee_contributions,
    sum(vsd.fed_cand_contb_ref_per) AS fed_candidate_contribution_refunds,
    (sum(vsd.fed_funds_per) > (0)::numeric) AS federal_funds_flag,
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
    sum(((vsd.offsets_to_op_exp + vsd.offsets_to_fndrsg) + vsd.offsets_to_legal_acctg)) AS total_offsets_to_operating_expenditures,
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
    max((committee_info.cmte_tp)::text) AS committee_type,
    max(public.expand_committee_type((committee_info.cmte_tp)::text)) AS committee_type_full,
    max((committee_info.cmte_dsgn)::text) AS committee_designation,
    max(public.expand_committee_designation((committee_info.cmte_dsgn)::text)) AS committee_designation_full,
    max((committee_info.cmte_pty_affiliation_desc)::text) AS party_full,
    vsd.cmte_id AS committee_id,
    vsd.form_tp_cd AS form_type,
        CASE
            WHEN (max((last.form_type)::text) = ANY (ARRAY['F3'::text, 'F3P'::text])) THEN NULL::numeric
            ELSE sum(vsd.indt_exp_per)
        END AS independent_expenditures,
    --Needed for Form 4
    sum(vsd.exp_subject_limits_per) AS exp_subject_limits,
    sum(vsd.exp_prior_yrs_subject_lim_per) AS exp_prior_years_subject_limits,
    sum(vsd.ttl_exp_subject_limits) AS total_exp_subject_limits,
    sum(vsd.subttl_ref_reb_ret_per) AS refunds_relating_convention_exp,
    sum(vsd.item_ref_reb_ret_per) AS itemized_refunds_relating_convention_exp,
    sum(vsd.unitem_ref_reb_ret_per) AS unitemized_refunds_relating_convention_exp,
    sum(vsd.subttl_other_ref_reb_ret_per) AS other_refunds,
    sum(vsd.item_other_ref_reb_ret_per) AS itemized_other_refunds,
    sum(vsd.unitem_other_ref_reb_ret_per) AS unitemized_other_refunds,
    sum(vsd.item_other_income_per) AS itemized_other_income,
    sum(vsd.unitem_other_income_per) AS unitemized_other_income,
    sum(vsd.subttl_convn_exp_disb_per) AS convention_exp,
    sum(vsd.item_convn_exp_disb_per) AS itemized_convention_exp,
    sum(vsd.unitem_convn_exp_disb_per) AS unitemized_convention_exp,
    sum(vsd.item_other_disb_per) AS itemized_other_disb,
    sum(vsd.unitem_other_disb_per) AS unitemized_other_disb
   FROM (((disclosure.v_sum_and_det_sum_report vsd
     LEFT JOIN last ON ((((vsd.cmte_id)::text = (last.cmte_id)::text) AND (public.get_cycle(vsd.rpt_yr) = last.cycle))))
     LEFT JOIN first ON ((((vsd.cmte_id)::text = (first.committee_id)::text) AND (public.get_cycle(vsd.rpt_yr) = first.cycle))))
     LEFT JOIN committee_info ON ((((vsd.cmte_id)::text = (committee_info.cmte_id)::text) AND ((public.get_cycle(vsd.rpt_yr))::numeric = committee_info.fec_election_yr))))
  WHERE ((public.get_cycle(vsd.rpt_yr) >= 1979) AND (((vsd.form_tp_cd)::text <> 'F5'::text) OR (((vsd.form_tp_cd)::text = 'F5'::text) AND ((vsd.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])))) AND ((vsd.form_tp_cd)::text <> 'F6'::text))
  GROUP BY vsd.cmte_id, vsd.form_tp_cd, (public.get_cycle(vsd.rpt_yr));

ALTER VIEW ofec_totals_combined_vw OWNER TO fec;
GRANT SELECT ON ofec_totals_combined_vw TO fec_read;

-- b) drop old `MV`

DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_combined_mv;

-- c) recreate `MV` with new logic

CREATE MATERIALIZED VIEW public.ofec_totals_combined_mv AS
WITH last_subset AS (
         SELECT DISTINCT ON (v_sum_and_det_sum_report.cmte_id, (public.get_cycle(v_sum_and_det_sum_report.rpt_yr))) v_sum_and_det_sum_report.orig_sub_id,
            v_sum_and_det_sum_report.cmte_id,
            v_sum_and_det_sum_report.coh_cop,
            v_sum_and_det_sum_report.debts_owed_by_cmte,
            v_sum_and_det_sum_report.debts_owed_to_cmte,
            v_sum_and_det_sum_report.net_op_exp,
            v_sum_and_det_sum_report.net_contb,
            v_sum_and_det_sum_report.rpt_yr,
            public.get_cycle(v_sum_and_det_sum_report.rpt_yr) AS cycle
           FROM disclosure.v_sum_and_det_sum_report
          WHERE ((public.get_cycle(v_sum_and_det_sum_report.rpt_yr) >= 1979) AND (((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F5'::text) OR (((v_sum_and_det_sum_report.form_tp_cd)::text = 'F5'::text) AND ((v_sum_and_det_sum_report.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])))) AND ((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F6'::text))
          ORDER BY v_sum_and_det_sum_report.cmte_id, (public.get_cycle(v_sum_and_det_sum_report.rpt_yr)), (to_timestamp((v_sum_and_det_sum_report.cvg_end_dt)::double precision)) DESC NULLS LAST
        ), last AS (
         SELECT ls.cmte_id,
            ls.orig_sub_id,
            ls.coh_cop,
            ls.cycle,
            ls.debts_owed_by_cmte,
            ls.debts_owed_to_cmte,
            ls.net_op_exp,
            ls.net_contb,
            ls.rpt_yr,
            of.candidate_id,
            of.beginning_image_number,
            of.coverage_end_date,
            of.form_type,
            of.report_type_full,
            of.report_type,
            of.candidate_name,
            of.committee_name
           FROM (last_subset ls
             LEFT JOIN public.ofec_filings_vw of ON ((ls.orig_sub_id = of.sub_id)))
        ), first AS (
         SELECT DISTINCT ON (v_sum_and_det_sum_report.cmte_id, (public.get_cycle(v_sum_and_det_sum_report.rpt_yr))) v_sum_and_det_sum_report.coh_bop AS cash_on_hand,
            v_sum_and_det_sum_report.cmte_id AS committee_id,
                CASE
                    WHEN (v_sum_and_det_sum_report.cvg_start_dt = (99999999)::numeric) THEN NULL::timestamp without time zone
                    ELSE (((v_sum_and_det_sum_report.cvg_start_dt)::text)::date)::timestamp without time zone
                END AS coverage_start_date,
            public.get_cycle(v_sum_and_det_sum_report.rpt_yr) AS cycle
           FROM disclosure.v_sum_and_det_sum_report
          WHERE ((public.get_cycle(v_sum_and_det_sum_report.rpt_yr) >= 1979) AND (((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F5'::text) OR (((v_sum_and_det_sum_report.form_tp_cd)::text = 'F5'::text) AND ((v_sum_and_det_sum_report.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])))) AND ((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F6'::text))
          ORDER BY v_sum_and_det_sum_report.cmte_id, (public.get_cycle(v_sum_and_det_sum_report.rpt_yr)), (to_timestamp((v_sum_and_det_sum_report.cvg_end_dt)::double precision))
        ), committee_info AS (
         SELECT DISTINCT ON (cmte_valid_fec_yr.cmte_id, cmte_valid_fec_yr.fec_election_yr) cmte_valid_fec_yr.cmte_id,
            cmte_valid_fec_yr.fec_election_yr,
            cmte_valid_fec_yr.cmte_nm,
            cmte_valid_fec_yr.cmte_tp,
            cmte_valid_fec_yr.cmte_dsgn,
            cmte_valid_fec_yr.cmte_pty_affiliation_desc
           FROM disclosure.cmte_valid_fec_yr
        )
 SELECT public.get_cycle(vsd.rpt_yr) AS cycle,
    max((last.candidate_id)::text) AS candidate_id,
    max((last.candidate_name)::text) AS candidate_name,
    max((last.committee_name)::text) AS committee_name,
    max(last.beginning_image_number) AS last_beginning_image_number,
    max(last.coh_cop) AS last_cash_on_hand_end_period,
    max(last.debts_owed_by_cmte) AS last_debts_owed_by_committee,
    max(last.debts_owed_to_cmte) AS last_debts_owed_to_committee,
    max(last.net_contb) AS last_net_contributions,
    max(last.net_op_exp) AS last_net_operating_expenditures,
    max((last.report_type)::text) AS last_report_type,
    max((last.report_type_full)::text) AS last_report_type_full,
    max(last.rpt_yr) AS last_report_year,
    max(last.coverage_end_date) AS coverage_end_date,
    max(vsd.orig_sub_id) AS sub_id,
    min(first.cash_on_hand) AS cash_on_hand_beginning_period,
    min(first.coverage_start_date) AS coverage_start_date,
    sum(vsd.all_loans_received_per) AS all_loans_received,
    sum(vsd.cand_cntb) AS candidate_contribution,
    sum((vsd.cand_loan_repymnt + vsd.oth_loan_repymts)) AS loan_repayments_made,
    sum(vsd.cand_loan_repymnt) AS loan_repayments_candidate_loans,
    sum(vsd.cand_loan) AS loans_made_by_candidate,
    sum(vsd.cand_loan_repymnt) AS repayments_loans_made_by_candidate,
    sum(vsd.cand_loan) AS loans_received_from_candidate,
    sum(vsd.coord_exp_by_pty_cmte_per) AS coordinated_expenditures_by_party_committee,
    sum(vsd.exempt_legal_acctg_disb) AS exempt_legal_accounting_disbursement,
    sum(vsd.fed_cand_cmte_contb_per) AS fed_candidate_committee_contributions,
    sum(vsd.fed_cand_contb_ref_per) AS fed_candidate_contribution_refunds,
    (sum(vsd.fed_funds_per) > (0)::numeric) AS federal_funds_flag,
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
    sum(((vsd.offsets_to_op_exp + vsd.offsets_to_fndrsg) + vsd.offsets_to_legal_acctg)) AS total_offsets_to_operating_expenditures,
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
    max((committee_info.cmte_tp)::text) AS committee_type,
    max(public.expand_committee_type((committee_info.cmte_tp)::text)) AS committee_type_full,
    max((committee_info.cmte_dsgn)::text) AS committee_designation,
    max(public.expand_committee_designation((committee_info.cmte_dsgn)::text)) AS committee_designation_full,
    max((committee_info.cmte_pty_affiliation_desc)::text) AS party_full,
    vsd.cmte_id AS committee_id,
    vsd.form_tp_cd AS form_type,
        CASE
            WHEN (max((last.form_type)::text) = ANY (ARRAY['F3'::text, 'F3P'::text])) THEN NULL::numeric
            ELSE sum(vsd.indt_exp_per)
        END AS independent_expenditures,
    --Needed for Form 4
    sum(vsd.exp_subject_limits_per) AS exp_subject_limits,
    sum(vsd.exp_prior_yrs_subject_lim_per) AS exp_prior_years_subject_limits,
    sum(vsd.ttl_exp_subject_limits) AS total_exp_subject_limits,
    sum(vsd.subttl_ref_reb_ret_per) AS refunds_relating_convention_exp,
    sum(vsd.item_ref_reb_ret_per) AS itemized_refunds_relating_convention_exp,
    sum(vsd.unitem_ref_reb_ret_per) AS unitemized_refunds_relating_convention_exp,
    sum(vsd.subttl_other_ref_reb_ret_per) AS other_refunds,
    sum(vsd.item_other_ref_reb_ret_per) AS itemized_other_refunds,
    sum(vsd.unitem_other_ref_reb_ret_per) AS unitemized_other_refunds,
    sum(vsd.item_other_income_per) AS itemized_other_income,
    sum(vsd.unitem_other_income_per) AS unitemized_other_income,
    sum(vsd.subttl_convn_exp_disb_per) AS convention_exp,
    sum(vsd.item_convn_exp_disb_per) AS itemized_convention_exp,
    sum(vsd.unitem_convn_exp_disb_per) AS unitemized_convention_exp,
    sum(vsd.item_other_disb_per) AS itemized_other_disb,
    sum(vsd.unitem_other_disb_per) AS unitemized_other_disb
   FROM (((disclosure.v_sum_and_det_sum_report vsd
     LEFT JOIN last ON ((((vsd.cmte_id)::text = (last.cmte_id)::text) AND (public.get_cycle(vsd.rpt_yr) = last.cycle))))
     LEFT JOIN first ON ((((vsd.cmte_id)::text = (first.committee_id)::text) AND (public.get_cycle(vsd.rpt_yr) = first.cycle))))
     LEFT JOIN committee_info ON ((((vsd.cmte_id)::text = (committee_info.cmte_id)::text) AND ((public.get_cycle(vsd.rpt_yr))::numeric = committee_info.fec_election_yr))))
  WHERE ((public.get_cycle(vsd.rpt_yr) >= 1979) AND (((vsd.form_tp_cd)::text <> 'F5'::text) OR (((vsd.form_tp_cd)::text = 'F5'::text) AND ((vsd.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])))) AND ((vsd.form_tp_cd)::text <> 'F6'::text))
  GROUP BY vsd.cmte_id, vsd.form_tp_cd, (public.get_cycle(vsd.rpt_yr))
  WITH DATA;

--Permissions

ALTER TABLE public.ofec_totals_combined_mv OWNER TO fec;
GRANT SELECT ON ofec_totals_combined_mv TO fec_read;

--Indices

CREATE INDEX ofec_totals_combined_mv_committee_designation_full_sub__idx ON public.ofec_totals_combined_mv USING btree (committee_designation_full, sub_id);

CREATE INDEX ofec_totals_combined_mv_committee_id_sub_id_idx1 ON public.ofec_totals_combined_mv USING btree (committee_id, sub_id);

CREATE INDEX ofec_totals_combined_mv_committee_type_full_sub_id_idx ON public.ofec_totals_combined_mv USING btree (committee_type_full, sub_id);

CREATE INDEX ofec_totals_combined_mv_cycle_sub_id_idx1 ON public.ofec_totals_combined_mv USING btree (cycle, sub_id);

CREATE INDEX ofec_totals_combined_mv_disbursements_sub_id_idx1 ON public.ofec_totals_combined_mv USING btree (disbursements, sub_id);

CREATE INDEX ofec_totals_combined_mv_receipts_sub_id_idx1 ON public.ofec_totals_combined_mv USING btree (receipts, sub_id);

CREATE UNIQUE INDEX ofec_totals_combined_mv_sub_id_idx1 ON public.ofec_totals_combined_mv USING btree (sub_id);

-- d) `create or replace ofec_totals_combined_vw` -> `select all` from new `MV`

CREATE OR REPLACE VIEW ofec_totals_combined_vw AS SELECT * FROM ofec_totals_combined_mv;
ALTER VIEW ofec_totals_combined_vw OWNER TO fec;
GRANT SELECT ON ofec_totals_combined_vw TO fec_read;

--Add missing fields to ofec_totals_pacs_parties_vw

CREATE OR REPLACE VIEW public.ofec_totals_pacs_parties_vw AS
 SELECT oft.sub_id AS idx,
    oft.committee_id,
    oft.committee_name,
    oft.cycle,
    oft.coverage_start_date,
    oft.coverage_end_date,
    oft.all_loans_received,
    oft.allocated_federal_election_levin_share,
    oft.contribution_refunds,
    oft.contributions,
    oft.coordinated_expenditures_by_party_committee,
    oft.disbursements,
    oft.fed_candidate_committee_contributions,
    oft.fed_candidate_contribution_refunds,
    oft.fed_disbursements,
    oft.fed_election_activity,
    oft.fed_receipts,
    oft.independent_expenditures,
    oft.refunded_individual_contributions,
    oft.individual_itemized_contributions,
    oft.individual_unitemized_contributions,
    oft.individual_contributions,
    oft.loan_repayments_other_loans AS loan_repayments_made,
    oft.loan_repayments_other_loans,
    oft.loan_repayments_received,
    oft.loans_made,
    oft.transfers_to_other_authorized_committee,
    oft.net_operating_expenditures,
    oft.non_allocated_fed_election_activity,
    oft.total_transfers,
    oft.offsets_to_operating_expenditures,
    oft.operating_expenditures,
    oft.operating_expenditures AS fed_operating_expenditures,
    oft.other_disbursements,
    oft.other_fed_operating_expenditures,
    oft.other_fed_receipts,
    oft.other_political_committee_contributions,
    oft.refunded_other_political_committee_contributions,
    oft.political_party_committee_contributions,
    oft.refunded_political_party_committee_contributions,
    oft.receipts,
    oft.shared_fed_activity,
    oft.shared_fed_activity_nonfed,
    oft.shared_fed_operating_expenditures,
    oft.shared_nonfed_operating_expenditures,
    oft.transfers_from_affiliated_party,
    oft.transfers_from_nonfed_account,
    oft.transfers_from_nonfed_levin,
    oft.transfers_to_affiliated_committee,
    oft.net_contributions,
    oft.last_report_type_full,
    oft.last_beginning_image_number,
    oft.last_cash_on_hand_end_period,
    oft.cash_on_hand_beginning_period,
    oft.last_debts_owed_by_committee,
    oft.last_debts_owed_to_committee,
    oft.last_report_year,
    oft.committee_type,
    oft.committee_designation,
    oft.committee_type_full,
    oft.committee_designation_full,
    oft.party_full,
    comm_dets.designation,
    --needed for Form 4
    oft.loans AS loans_and_loan_repayments,
    oft.federal_funds,
    oft.exp_subject_limits,
    oft.exp_prior_years_subject_limits,
    oft.total_exp_subject_limits,
    oft.refunds_relating_convention_exp,
    oft.itemized_refunds_relating_convention_exp,
    oft.unitemized_refunds_relating_convention_exp,
    oft.other_refunds,
    oft.itemized_other_refunds,
    oft.unitemized_other_refunds,
    oft.itemized_other_income,
    oft.unitemized_other_income,
    oft.convention_exp,
    oft.itemized_convention_exp,
    oft.unitemized_convention_exp,
    oft.itemized_other_disb,
    oft.unitemized_other_disb
   FROM ofec_totals_combined_vw oft
     JOIN ofec_committee_detail_vw comm_dets USING (committee_id)
  WHERE oft.form_type IN ('F3X', 'F13', 'F4');

ALTER VIEW ofec_totals_pacs_parties_vw OWNER TO fec;
GRANT SELECT ON ofec_totals_pacs_parties_vw TO fec_read;


