-- --------(1)public.ofec_f3_filed_by_pac_party_vw----------
-- This view includes F3, F3P, F13, and F4 filed by pac and party.
--
-- data from 4 tables: 
-- disclosure.f_rpt_or_form_sub
-- disclosure.v_sum_and_det_sum_report
-- disclosure.cmte_valid_fec_yr
-- staging.ref_rpt_tp
--
-- ---------------------------------------------------------

DROP VIEW IF EXISTS public.ofec_f3_filed_by_pac_party_vw;

CREATE OR REPLACE VIEW ofec_f3_filed_by_pac_party_vw AS
    SELECT r.sub_id,
        r.cvg_start_dt,
        r.cvg_end_dt,
        r.receipt_dt,
        r.rpt_yr + r.rpt_yr % 2::numeric AS cycle,
        r.cand_cmte_id AS committee_id,
        c.cmte_tp,
        CASE
            WHEN r.form_tp::text = 'F3'::text THEN 'Form 3'::text
            WHEN r.form_tp::text = 'F3P'::text THEN 'Form 3P'::text
            WHEN r.form_tp::text = 'F13'::text THEN 'Form 13'::text
            WHEN r.form_tp::text = 'F4'::text THEN 'Form 4'::text
            ELSE NULL::text
        END AS form_tp,
        r.rpt_yr,
        r.rpt_tp,
        ref_rpt_tp.rpt_tp_desc AS report_type_full,
        r.amndt_ind,
        CASE
            WHEN r.amndt_ind::text = 'N'::text THEN 'NEW'::text
            WHEN r.amndt_ind::text = 'A'::text THEN 'AMENDMENT'::text
            ELSE NULL::text
        END AS amendment_indicator_full,
        r.request_tp,
        r.begin_image_num,
        r.end_image_num,
        r.ttl_receipts,
        r.ttl_indt_contb,
        r.ttl_disb,
        r.coh_bop,
        r.coh_cop,
        r.debts_owed_by_cmte,
        r.debts_owed_to_cmte,
        r.file_num,
        r.prev_file_num,
        r.rpt_pgi AS primary_general_indicator,
        CASE
            WHEN vs.orig_sub_id IS NOT NULL THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag,
        c.cmte_nm AS committee_name  
    FROM disclosure.f_rpt_or_form_sub r
    JOIN disclosure.cmte_valid_fec_yr c ON c.cmte_id::text = r.cand_cmte_id::text AND c.fec_election_yr = (r.rpt_yr + r.rpt_yr % 2::numeric)
    LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON r.sub_id = vs.orig_sub_id
    LEFT JOIN staging.ref_rpt_tp ref_rpt_tp ON ref_rpt_tp.rpt_tp_cd::text = r.rpt_tp::text
    WHERE r.rpt_yr >= 1979::numeric 
        AND (c.cmte_tp::text <> ALL (ARRAY['H'::character varying::text, 'S'::character varying::text, 'P'::character varying::text, 'I'::character varying::text])) 
        AND (r.form_tp::text = ANY (ARRAY['F3'::character varying, 'F3P'::character varying, 'F13'::character varying, 'F4'::character varying]::text[]));

ALTER TABLE public.ofec_f3_filed_by_pac_party_vw OWNER TO fec;    
GRANT SELECT ON public.ofec_f3_filed_by_pac_party_vw TO fec_read;



-- --------(2)public.ofec_pac_party_report_vw--------------
-- All financial reports from pac and party
-- data from 3 tables: 
-- disclosure.nml_form_3x
-- disclosure.v_sum_and_det_sum_reportt
-- disclosure.cmte_valid_fec_yr
-- and 1 view:
-- public.ofec_f3_filed_by_pac_party_vw
-- -------------------------------------------------

DROP VIEW IF EXISTS public.ofec_pac_party_report_vw;
CREATE OR REPLACE VIEW ofec_pac_party_report_vw AS

    SELECT f3x.cmte_id AS committee_id,
        f3x.rpt_yr + f3x.rpt_yr % 2::numeric AS cycle,
        f3x.cvg_start_dt AS coverage_start_date,
        f3x.cvg_end_dt AS coverage_end_date,
        f3x.all_loans_received_per AS all_loans_received_period,
        f3x.all_loans_received_ytd,
        f3x.shared_fed_actvy_nonfed_per AS allocated_federal_election_levin_share_period,
        f3x.begin_image_num AS beginning_image_number,
        f3x.calendar_yr AS calendar_ytd,
        f3x.coh_begin_calendar_yr AS cash_on_hand_beginning_calendar_ytd,
        f3x.coh_bop AS cash_on_hand_beginning_period,
        f3x.coh_coy AS cash_on_hand_close_ytd,
        f3x.coh_cop AS cash_on_hand_end_period,
        f3x.coord_exp_by_pty_cmte_per AS coordinated_expenditures_by_party_committee_period,
        f3x.coord_exp_by_pty_cmte_ytd AS coordinated_expenditures_by_party_committee_ytd,
        f3x.debts_owed_by_cmte AS debts_owed_by_committee,
        f3x.debts_owed_to_cmte AS debts_owed_to_committee,
        f3x.end_image_num AS end_image_number,
        f3x.fed_cand_cmte_contb_ref_ytd AS fed_candidate_committee_contribution_refunds_ytd,
        f3x.fed_cand_cmte_contb_per AS fed_candidate_committee_contributions_period,
        f3x.fed_cand_cmte_contb_ytd AS fed_candidate_committee_contributions_ytd,
        f3x.fed_cand_contb_ref_per AS fed_candidate_contribution_refunds_period,
        f3x.indt_exp_per AS independent_expenditures_period,
        f3x.indt_exp_ytd AS independent_expenditures_ytd,
        f3x.indv_contb_ref_per AS refunded_individual_contributions_period,
        f3x.indv_contb_ref_ytd AS refunded_individual_contributions_ytd,
        f3x.indv_item_contb_per AS individual_itemized_contributions_period,
        f3x.indv_item_contb_ytd AS individual_itemized_contributions_ytd,
        f3x.indv_unitem_contb_per AS individual_unitemized_contributions_period,
        f3x.indv_unitem_contb_ytd AS individual_unitemized_contributions_ytd,
        f3x.loan_repymts_made_per AS loan_repayments_made_period,
        f3x.loan_repymts_made_ytd AS loan_repayments_made_ytd,
        f3x.loan_repymts_received_per AS loan_repayments_received_period,
        f3x.loan_repymts_received_ytd AS loan_repayments_received_ytd,
        f3x.loans_made_per AS loans_made_period,
        f3x.loans_made_ytd,
        f3x.net_contb_per AS net_contributions_period,
        f3x.net_contb_ytd AS net_contributions_ytd,
        f3x.net_op_exp_per AS net_operating_expenditures_period,
        f3x.net_op_exp_ytd AS net_operating_expenditures_ytd,
        f3x.non_alloc_fed_elect_actvy_per AS non_allocated_fed_election_activity_period,
        f3x.non_alloc_fed_elect_actvy_ytd AS non_allocated_fed_election_activity_ytd,
        f3x.shared_nonfed_op_exp_per AS nonfed_share_allocated_disbursements_period,
        GREATEST(f3x.offsets_to_op_exp_per_i, f3x.offsets_to_op_exp_per_ii) AS offsets_to_operating_expenditures_period,
        f3x.offsets_to_op_exp_ytd_i AS offsets_to_operating_expenditures_ytd,
        f3x.other_disb_per AS other_disbursements_period,
        f3x.other_disb_ytd AS other_disbursements_ytd,
        f3x.other_fed_op_exp_per AS other_fed_operating_expenditures_period,
        f3x.other_fed_op_exp_ytd AS other_fed_operating_expenditures_ytd,
        f3x.other_fed_receipts_per AS other_fed_receipts_period,
        f3x.other_fed_receipts_ytd,
        f3x.other_pol_cmte_contb_per_ii AS refunded_other_political_committee_contributions_period,
        f3x.other_pol_cmte_contb_ytd_ii AS refunded_other_political_committee_contributions_ytd,
        f3x.other_pol_cmte_contb_per_i AS other_political_committee_contributions_period,
        f3x.other_pol_cmte_contb_ytd_i AS other_political_committee_contributions_ytd,
        f3x.pol_pty_cmte_contb_per_ii AS refunded_political_party_committee_contributions_period,
        f3x.pol_pty_cmte_contb_ytd_ii AS refunded_political_party_committee_contributions_ytd,
        f3x.pol_pty_cmte_contb_per_i AS political_party_committee_contributions_period,
        f3x.pol_pty_cmte_contb_ytd_i AS political_party_committee_contributions_ytd,
        f3x.rpt_yr AS report_year,
        f3x.shared_fed_actvy_nonfed_ytd AS shared_fed_activity_nonfed_ytd,
        f3x.shared_fed_actvy_fed_shr_per AS shared_fed_activity_period,
        f3x.shared_fed_actvy_fed_shr_ytd AS shared_fed_activity_ytd,
        f3x.shared_fed_op_exp_per AS shared_fed_operating_expenditures_period,
        f3x.shared_fed_op_exp_ytd AS shared_fed_operating_expenditures_ytd,
        f3x.shared_nonfed_op_exp_per AS shared_nonfed_operating_expenditures_period,
        f3x.shared_nonfed_op_exp_ytd AS shared_nonfed_operating_expenditures_ytd,
        f3x.subttl_sum_page_per AS subtotal_summary_page_period,
        f3x.subttl_sum_ytd AS subtotal_summary_ytd,
        GREATEST(f3x.ttl_contb_ref_per_i, f3x.ttl_contb_ref_per_ii) AS total_contribution_refunds_period,
        f3x.ttl_contb_ref_ytd_i AS total_contribution_refunds_ytd,
        f3x.ttl_contb_per AS total_contributions_period,
        f3x.ttl_contb_ytd AS total_contributions_ytd,
        GREATEST(f3x.ttl_disb_sum_page_per, f3x.ttl_disb_per) AS total_disbursements_period,
        f3x.ttl_disb_ytd AS total_disbursements_ytd,
        f3x.ttl_fed_disb_per AS total_fed_disbursements_period,
        f3x.ttl_fed_disb_ytd AS total_fed_disbursements_ytd,
        f3x.ttl_fed_elect_actvy_per AS total_fed_election_activity_period,
        f3x.ttl_fed_elect_actvy_ytd AS total_fed_election_activity_ytd,
        f3x.ttl_fed_op_exp_per AS total_fed_operating_expenditures_period,
        f3x.ttl_fed_op_exp_ytd AS total_fed_operating_expenditures_ytd,
        f3x.ttl_fed_receipts_per AS total_fed_receipts_period,
        f3x.ttl_fed_receipts_ytd AS total_fed_receipts_ytd,
        f3x.ttl_indv_contb AS total_individual_contributions_period,
        f3x.ttl_indv_contb_ytd AS total_individual_contributions_ytd,
        f3x.ttl_nonfed_tranf_per AS total_nonfed_transfers_period,
        f3x.ttl_nonfed_tranf_ytd AS total_nonfed_transfers_ytd,
        f3x.ttl_op_exp_per AS total_operating_expenditures_period,
        f3x.ttl_op_exp_ytd AS total_operating_expenditures_ytd,
        GREATEST(f3x.ttl_receipts_sum_page_per, f3x.ttl_receipts_per) AS total_receipts_period,
        f3x.ttl_receipts_ytd AS total_receipts_ytd,
        f3x.tranf_from_affiliated_pty_per AS transfers_from_affiliated_party_period,
        f3x.tranf_from_affiliated_pty_ytd AS transfers_from_affiliated_party_ytd,
        f3x.tranf_from_nonfed_acct_per AS transfers_from_nonfed_account_period,
        f3x.tranf_from_nonfed_acct_ytd AS transfers_from_nonfed_account_ytd,
        f3x.tranf_from_nonfed_levin_per AS transfers_from_nonfed_levin_period,
        f3x.tranf_from_nonfed_levin_ytd AS transfers_from_nonfed_levin_ytd,
        f3x.tranf_to_affliliated_cmte_per AS transfers_to_affiliated_committee_period,
        f3x.tranf_to_affilitated_cmte_ytd AS transfers_to_affilitated_committees_ytd,
        'Form 3X'::text AS form_tp,
        f3x.rpt_tp AS report_type,
        f3x.rpt_tp_desc AS report_type_full,
        CASE
            WHEN vs.orig_sub_id IS NOT NULL THEN 'Y'::text
            ELSE 'N'::text
        END ~~ 'N'::text AS is_amended,
        f3x.receipt_dt AS receipt_date,
        f3x.file_num AS file_number,
        f3x.amndt_ind AS amendment_indicator,
        f3x.amndt_ind_desc AS amendment_indicator_full,
        means_filed(f3x.begin_image_num::text) AS means_filed,
        report_html_url(means_filed(f3x.begin_image_num::text), f3x.cmte_id::text, f3x.file_num::text) AS html_url,
        report_fec_url(f3x.begin_image_num::text, f3x.file_num::integer) AS fec_url,
        cmte.cmte_nm AS committee_name
    FROM disclosure.nml_form_3x f3x
    LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON f3x.sub_id = vs.orig_sub_id
    LEFT JOIN disclosure.cmte_valid_fec_yr cmte ON (f3x.rpt_yr + f3x.rpt_yr % 2::numeric) = cmte.fec_election_yr 
        AND f3x.cmte_id::text = cmte.cmte_id::text
    WHERE f3x.rpt_yr >= 1979::numeric AND f3x.delete_ind IS NULL
  
    UNION ALL
    SELECT f3.committee_id,
        f3.cycle,
        f3.cvg_start_dt::text::timestamp without time zone AS cvg_start_dt,
        f3.cvg_end_dt::text::timestamp without time zone AS cvg_end_dt,
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        f3.begin_image_num,
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        f3.coh_bop,
        NULL::numeric AS "numeric",
        f3.coh_cop,
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        f3.debts_owed_by_cmte,
        f3.debts_owed_to_cmte,
        f3.end_image_num,
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        f3.rpt_yr,
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        f3.ttl_disb,
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        f3.ttl_indt_contb,
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        f3.ttl_receipts,
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        NULL::numeric AS "numeric",
        f3.form_tp,
        f3.rpt_tp,
        f3.report_type_full,
        f3.most_recent_filing_flag ~~ 'N'::text AS is_amended,
        f3.receipt_dt::text::timestamp without time zone AS receipt_dt,
        f3.file_num,
        f3.amndt_ind,
        f3.amendment_indicator_full,
        means_filed(f3.begin_image_num::text) AS means_filed,
        report_html_url(means_filed(f3.begin_image_num::text), f3.committee_id::text, f3.file_num::text) AS html_url,
        report_fec_url(f3.begin_image_num::text, f3.file_num::integer) AS fec_url,
        f3.committee_name
    FROM ofec_f3_filed_by_pac_party_vw f3;
ALTER TABLE public.ofec_pac_party_report_vw OWNER TO fec;    
GRANT SELECT ON public.ofec_pac_party_report_vw TO fec_read;



-- --------(3)public.ofec_reports_pac_party_mv--------------
-- All reports filed by pac and party, Mostly F3X, and wrongly filed F3, F3P, F13, F4.
-- data from 2 views: 
-- public.ofec_pac_party_report_vw
-- public.ofec_filings_amendments_all_vw
-- 
-- --------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS public.ofec_reports_pac_party_mv_tmp;
CREATE MATERIALIZED VIEW public.ofec_reports_pac_party_mv_tmp AS
    SELECT row_number() OVER () AS idx,
        rpt.committee_id,
        rpt.cycle,
        rpt.coverage_start_date,
        rpt.coverage_end_date,
        rpt.all_loans_received_period,
        rpt.all_loans_received_ytd,
        rpt.allocated_federal_election_levin_share_period,
        rpt.beginning_image_number,
        rpt.calendar_ytd,
        rpt.cash_on_hand_beginning_calendar_ytd,
        rpt.cash_on_hand_beginning_period,
        rpt.cash_on_hand_close_ytd,
        rpt.cash_on_hand_end_period,
        rpt.coordinated_expenditures_by_party_committee_period,
        rpt.coordinated_expenditures_by_party_committee_ytd,
        rpt.debts_owed_by_committee,
        rpt.debts_owed_to_committee,
        rpt.end_image_number,
        rpt.fed_candidate_committee_contribution_refunds_ytd,
        rpt.fed_candidate_committee_contributions_period,
        rpt.fed_candidate_committee_contributions_ytd,
        rpt.fed_candidate_contribution_refunds_period,
        rpt.independent_expenditures_period,
        rpt.independent_expenditures_ytd,
        rpt.refunded_individual_contributions_period,
        rpt.refunded_individual_contributions_ytd,
        rpt.individual_itemized_contributions_period,
        rpt.individual_itemized_contributions_ytd,
        rpt.individual_unitemized_contributions_period,
        rpt.individual_unitemized_contributions_ytd,
        rpt.loan_repayments_made_period,
        rpt.loan_repayments_made_ytd,
        rpt.loan_repayments_received_period,
        rpt.loan_repayments_received_ytd,
        rpt.loans_made_period,
        rpt.loans_made_ytd,
        rpt.net_contributions_period,
        rpt.net_contributions_ytd,
        rpt.net_operating_expenditures_period,
        rpt.net_operating_expenditures_ytd,
        rpt.non_allocated_fed_election_activity_period,
        rpt.non_allocated_fed_election_activity_ytd,
        rpt.nonfed_share_allocated_disbursements_period,
        rpt.offsets_to_operating_expenditures_period,
        rpt.offsets_to_operating_expenditures_ytd,
        rpt.other_disbursements_period,
        rpt.other_disbursements_ytd,
        rpt.other_fed_operating_expenditures_period,
        rpt.other_fed_operating_expenditures_ytd,
        rpt.other_fed_receipts_period,
        rpt.other_fed_receipts_ytd,
        rpt.refunded_other_political_committee_contributions_period,
        rpt.refunded_other_political_committee_contributions_ytd,
        rpt.other_political_committee_contributions_period,
        rpt.other_political_committee_contributions_ytd,
        rpt.refunded_political_party_committee_contributions_period,
        rpt.refunded_political_party_committee_contributions_ytd,
        rpt.political_party_committee_contributions_period,
        rpt.political_party_committee_contributions_ytd,
        rpt.report_year,
        rpt.shared_fed_activity_nonfed_ytd,
        rpt.shared_fed_activity_period,
        rpt.shared_fed_activity_ytd,
        rpt.shared_fed_operating_expenditures_period,
        rpt.shared_fed_operating_expenditures_ytd,
        rpt.shared_nonfed_operating_expenditures_period,
        rpt.shared_nonfed_operating_expenditures_ytd,
        rpt.subtotal_summary_page_period,
        rpt.subtotal_summary_ytd,
        rpt.total_contribution_refunds_period,
        rpt.total_contribution_refunds_ytd,
        rpt.total_contributions_period,
        rpt.total_contributions_ytd,
        rpt.total_disbursements_period,
        rpt.total_disbursements_ytd,
        rpt.total_fed_disbursements_period,
        rpt.total_fed_disbursements_ytd,
        rpt.total_fed_election_activity_period,
        rpt.total_fed_election_activity_ytd,
        rpt.total_fed_operating_expenditures_period,
        rpt.total_fed_operating_expenditures_ytd,
        rpt.total_fed_receipts_period,
        rpt.total_fed_receipts_ytd,
        rpt.total_individual_contributions_period,
        rpt.total_individual_contributions_ytd,
        rpt.total_nonfed_transfers_period,
        rpt.total_nonfed_transfers_ytd,
        rpt.total_operating_expenditures_period,
        rpt.total_operating_expenditures_ytd,
        rpt.total_receipts_period,
        rpt.total_receipts_ytd,
        rpt.transfers_from_affiliated_party_period,
        rpt.transfers_from_affiliated_party_ytd,
        rpt.transfers_from_nonfed_account_period,
        rpt.transfers_from_nonfed_account_ytd,
        rpt.transfers_from_nonfed_levin_period,
        rpt.transfers_from_nonfed_levin_ytd,
        rpt.transfers_to_affiliated_committee_period,
        rpt.transfers_to_affilitated_committees_ytd,
        rpt.form_tp,
        rpt.report_type,
        rpt.report_type_full,
        rpt.is_amended,
        rpt.receipt_date,
        rpt.file_number,
        rpt.amendment_indicator,
        rpt.amendment_indicator_full,
        rpt.means_filed,
        rpt.html_url,
        rpt.fec_url,
        amendments.amendment_chain,
        amendments.prev_file_num AS previous_file_number,
        amendments.mst_rct_file_num AS most_recent_file_number,
        is_most_recent(rpt.file_number::integer, amendments.mst_rct_file_num::integer) AS most_recent,
        rpt.committee_name
    FROM ofec_pac_party_report_vw rpt
    LEFT JOIN ofec_filings_amendments_all_vw amendments ON rpt.file_number = amendments.file_num
WITH DATA;

ALTER TABLE public.ofec_reports_pac_party_mv_tmp
    OWNER TO fec;

GRANT ALL ON TABLE public.ofec_reports_pac_party_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_reports_pac_party_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_reports_pac_party_mv_tmp_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_beg_image_num_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (beginning_image_number COLLATE pg_catalog."default", idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_cmte_id_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (committee_id COLLATE pg_catalog."default", idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_cvg_end_date_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (coverage_end_date, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_cvg_start_date_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (coverage_start_date, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_cyc_cmte_id
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (cycle, committee_id COLLATE pg_catalog."default");
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_cyc_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (cycle, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_ie_period_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (independent_expenditures_period, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_is_amen_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (is_amended, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_rcpt_date_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (receipt_date, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_rpt_type_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (report_type COLLATE pg_catalog."default", idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_rpt_year_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (report_year, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_tot_disb_period_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (total_disbursements_period, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_tot_rcpt_period_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (total_receipts_period, idx);


-- ---------------
CREATE OR REPLACE VIEW public.ofec_reports_pac_party_vw AS 
  SELECT * FROM public.ofec_reports_pac_party_mv_tmp;
-- ---------------


-- drop old MV:ofec_reports_pac_party_mv
DROP MATERIALIZED VIEW IF EXISTS public.ofec_reports_pac_party_mv;


-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_reports_pac_party_mv_tmp 
  RENAME TO ofec_reports_pac_party_mv;


-- rename all indexes
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_idx RENAME TO idx_ofec_reports_pac_party_mv_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_beg_image_num_idx RENAME TO idx_ofec_reports_pac_party_mv_beg_image_num_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_cmte_id_idx RENAME TO idx_ofec_reports_pac_party_mv_cmte_id_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_cvg_end_date_idx RENAME TO idx_ofec_reports_pac_party_mv_cvg_end_date_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_cvg_start_date_idx RENAME TO idx_ofec_reports_pac_party_mv_cvg_start_date_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_cyc_cmte_id RENAME TO idx_ofec_reports_pac_party_mv_cyc_cmte_id;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_cyc_idx RENAME TO idx_ofec_reports_pac_party_mv_cyc_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_ie_period_idx RENAME TO idx_ofec_reports_pac_party_mv_ie_period_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_is_amen_idx RENAME TO idx_ofec_reports_pac_party_mv_is_amen_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_rcpt_date_idx RENAME TO idx_ofec_reports_pac_party_mv_rcpt_date_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_rpt_type_idx RENAME TO idx_ofec_reports_pac_party_mv_rpt_type_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_rpt_year_idx RENAME TO idx_ofec_reports_pac_party_mv_rpt_year_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_tot_disb_period_idx RENAME TO idx_ofec_reports_pac_party_mv_tot_disb_period_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_tot_rcpt_period_idx RENAME TO idx_ofec_reports_pac_party_mv_tot_rcpt_period_idx;

