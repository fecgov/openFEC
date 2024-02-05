/*
This is migration is for issue #5220
This is the latest version of ofec_reports_house_senate_mv
Add committee ID to tsvector column and rename column 

-- Previous mv is V0253
*/
-- -----------------------------------------------------

-- --------public.ofec_reports_house_senate_mv--------------
DROP MATERIALIZED VIEW IF EXISTS public.oofec_reports_house_senate_mv_tmp;
CREATE MATERIALIZED VIEW public.ofec_reports_house_senate_mv_tmp AS
  SELECT row_number() OVER () AS idx,
    f3.cmte_id AS committee_id,
    f3.rpt_yr + f3.rpt_yr % 2::numeric AS cycle,
    f3.cvg_start_dt AS coverage_start_date,
    f3.cvg_end_dt AS coverage_end_date,
    f3.agr_amt_pers_contrib_gen AS aggregate_amount_personal_contributions_general,
    f3.agr_amt_contrib_pers_fund_prim AS aggregate_contributions_personal_funds_primary,
    f3.all_other_loans_per AS all_other_loans_period,
    f3.all_other_loans_ytd,
    f3.begin_image_num AS beginning_image_number,
    f3.cand_contb_per AS candidate_contribution_period,
    f3.cand_contb_ytd AS candidate_contribution_ytd,
    f3.coh_bop AS cash_on_hand_beginning_period,
    GREATEST(f3.coh_cop_i, f3.coh_cop_ii) AS cash_on_hand_end_period,
    f3.debts_owed_by_cmte AS debts_owed_by_committee,
    f3.debts_owed_to_cmte AS debts_owed_to_committee,
    f3.end_image_num AS end_image_number,
    f3.grs_rcpt_auth_cmte_gen AS gross_receipt_authorized_committee_general,
    f3.grs_rcpt_auth_cmte_prim AS gross_receipt_authorized_committee_primary,
    f3.grs_rcpt_min_pers_contrib_gen AS gross_receipt_minus_personal_contribution_general,
    f3.grs_rcpt_min_pers_contrib_prim AS gross_receipt_minus_personal_contributions_primary,
    f3.indv_item_contb_per AS individual_itemized_contributions_period,
    f3.indv_unitem_contb_per AS individual_unitemized_contributions_period,
    f3.loan_repymts_cand_loans_per AS loan_repayments_candidate_loans_period,
    f3.loan_repymts_cand_loans_ytd AS loan_repayments_candidate_loans_ytd,
    f3.loan_repymts_other_loans_per AS loan_repayments_other_loans_period,
    f3.loan_repymts_other_loans_ytd AS loan_repayments_other_loans_ytd,
    f3.loans_made_by_cand_per AS loans_made_by_candidate_period,
    f3.loans_made_by_cand_ytd AS loans_made_by_candidate_ytd,
    f3.net_contb_per AS net_contributions_period,
    f3.net_contb_ytd AS net_contributions_ytd,
    f3.net_op_exp_per AS net_operating_expenditures_period,
    f3.net_op_exp_ytd AS net_operating_expenditures_ytd,
    f3.offsets_to_op_exp_per AS offsets_to_operating_expenditures_period,
    f3.offsets_to_op_exp_ytd AS offsets_to_operating_expenditures_ytd,
    f3.op_exp_per AS operating_expenditures_period,
    f3.op_exp_ytd AS operating_expenditures_ytd,
    f3.other_disb_per AS other_disbursements_period,
    f3.other_disb_ytd AS other_disbursements_ytd,
    f3.other_pol_cmte_contb_per AS other_political_committee_contributions_period,
    f3.other_pol_cmte_contb_ytd AS other_political_committee_contributions_ytd,
    f3.other_receipts_per AS other_receipts_period,
    f3.other_receipts_ytd,
    f3.pol_pty_cmte_contb_per AS political_party_committee_contributions_period,
    f3.pol_pty_cmte_contb_ytd AS political_party_committee_contributions_ytd,
    f3.ref_indv_contb_per AS refunded_individual_contributions_period,
    f3.ref_indv_contb_ytd AS refunded_individual_contributions_ytd,
    f3.ref_other_pol_cmte_contb_per AS refunded_other_political_committee_contributions_period,
    f3.ref_other_pol_cmte_contb_ytd AS refunded_other_political_committee_contributions_ytd,
    f3.ref_pol_pty_cmte_contb_per AS refunded_political_party_committee_contributions_period,
    f3.ref_pol_pty_cmte_contb_ytd AS refunded_political_party_committee_contributions_ytd,
    f3.ref_ttl_contb_col_ttl_ytd AS refunds_total_contributions_col_total_ytd,
    f3.subttl_per AS subtotal_period,
    f3.ttl_contb_ref_col_ttl_per AS total_contribution_refunds_col_total_period,
    f3.ttl_contb_ref_per AS total_contribution_refunds_period,
    f3.ttl_contb_ref_ytd AS total_contribution_refunds_ytd,
    f3.ttl_contb_column_ttl_per AS total_contributions_column_total_period,
    f3.ttl_contb_per AS total_contributions_period,
    f3.ttl_contb_ytd AS total_contributions_ytd,
    GREATEST(f3.ttl_disb_per_i, f3.ttl_disb_per_ii) AS total_disbursements_period,
    f3.ttl_disb_ytd AS total_disbursements_ytd,
    f3.ttl_indv_contb_per AS total_individual_contributions_period,
    f3.ttl_indv_contb_ytd AS total_individual_contributions_ytd,
    f3.ttl_indv_item_contb_ytd AS individual_itemized_contributions_ytd,
    f3.ttl_indv_unitem_contb_ytd AS individual_unitemized_contributions_ytd,
    f3.ttl_loan_repymts_per AS total_loan_repayments_made_period,
    f3.ttl_loan_repymts_ytd AS total_loan_repayments_made_ytd,
    f3.ttl_loans_per AS total_loans_received_period,
    f3.ttl_loans_ytd AS total_loans_received_ytd,
    f3.ttl_offsets_to_op_exp_per AS total_offsets_to_operating_expenditures_period,
    f3.ttl_offsets_to_op_exp_ytd AS total_offsets_to_operating_expenditures_ytd,
    f3.ttl_op_exp_per AS total_operating_expenditures_period,
    f3.ttl_op_exp_ytd AS total_operating_expenditures_ytd,
    GREATEST(f3.ttl_receipts_per_i, f3.ttl_receipts_ii) AS total_receipts_period,
    f3.ttl_receipts_ytd AS total_receipts_ytd,
    f3.tranf_from_other_auth_cmte_per AS transfers_from_other_authorized_committee_period,
    f3.tranf_from_other_auth_cmte_ytd AS transfers_from_other_authorized_committee_ytd,
    f3.tranf_to_other_auth_cmte_per AS transfers_to_other_authorized_committee_period,
    f3.tranf_to_other_auth_cmte_ytd AS transfers_to_other_authorized_committee_ytd,
    f3.rpt_tp AS report_type,
    f3.rpt_tp_desc AS report_type_full,
    f3.rpt_yr AS report_year,
    CASE
      WHEN vs.orig_sub_id IS NOT NULL THEN 'Y'::text
      ELSE 'N'::text
    END ~~ 'N'::text AS is_amended,
    f3.receipt_dt AS receipt_date,
    f3.file_num AS file_number,
    f3.amndt_ind AS amendment_indicator,
    f3.amndt_ind_desc AS amendment_indicator_full,
    means_filed(f3.begin_image_num::text) AS means_filed,
    report_html_url(means_filed(f3.begin_image_num::text), f3.cmte_id::text, f3.file_num::text) AS html_url,
    report_fec_url(f3.begin_image_num::text, f3.file_num::integer) AS fec_url,
    amendments.amendment_chain,
    amendments.prev_file_num AS previous_file_number,
    amendments.mst_rct_file_num AS most_recent_file_number,
    is_most_recent(f3.file_num::integer, amendments.mst_rct_file_num::integer) AS most_recent,
    cmte.cmte_nm AS committee_name,
    to_tsvector(parse_fulltext(cmte.cmte_nm||' '||f3.cmte_id)) AS filer_name_text
  FROM disclosure.nml_form_3 f3
  LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON f3.sub_id = vs.orig_sub_id
  LEFT JOIN disclosure.cmte_valid_fec_yr cmte ON (f3.rpt_yr + f3.rpt_yr % 2::numeric) = cmte.fec_election_yr AND f3.cmte_id::text = cmte.cmte_id::text
  LEFT JOIN ofec_filings_amendments_all_vw amendments ON f3.file_num = amendments.file_num
  WHERE f3.rpt_yr >= 1979::numeric AND f3.delete_ind IS NULL
WITH DATA;

ALTER TABLE public.ofec_reports_house_senate_mv_tmp
    OWNER TO fec;

GRANT ALL ON TABLE public.ofec_reports_house_senate_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_reports_house_senate_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_reports_house_senate_mv_tmp_idx
    ON public.ofec_reports_house_senate_mv_tmp
    USING btree
    (idx);
    
CREATE INDEX idx_ofec_reports_house_senate_mv_tmp_tot_disb_period_id_idx
    ON public.ofec_reports_house_senate_mv_tmp
    USING btree
    (total_disbursements_period, idx);
    
CREATE INDEX idx_ofec_reports_house_senate_mv_tmp_beg_image_num_idx
    ON public.ofec_reports_house_senate_mv_tmp
    USING btree
    (beginning_image_number COLLATE pg_catalog."default", idx);
    
CREATE INDEX idx_ofec_reports_house_senate_mv_tmp_cmte_id_idx
    ON public.ofec_reports_house_senate_mv_tmp
    USING btree
    (committee_id COLLATE pg_catalog."default", idx);
    
CREATE INDEX idx_ofec_reports_house_senate_mv_tmp_cvg_end_date_idx
    ON public.ofec_reports_house_senate_mv_tmp
    USING btree
    (coverage_end_date, idx);
    
CREATE INDEX idx_ofec_reports_house_senate_mv_tmp_cvg_start_date_idx
    ON public.ofec_reports_house_senate_mv_tmp
    USING btree
    (coverage_start_date, idx);
    
CREATE INDEX idx_ofec_reports_house_senate_mv_tmp_cyc_idx
    ON public.ofec_reports_house_senate_mv_tmp
    USING btree
    (cycle, idx);
    
CREATE INDEX idx_ofec_reports_house_senate_mv_tmp_is_amen_idx
    ON public.ofec_reports_house_senate_mv_tmp
    USING btree
    (is_amended, idx);
    
CREATE INDEX idx_ofec_reports_house_senate_mv_tmp_rcpt_date_idx
    ON public.ofec_reports_house_senate_mv_tmp
    USING btree
    (receipt_date, idx);
    
CREATE INDEX idx_ofec_reports_house_senate_mv_tmp_rpt_type_idx
    ON public.ofec_reports_house_senate_mv_tmp
    USING btree
    (report_type COLLATE pg_catalog."default", idx);
    
CREATE INDEX idx_ofec_reports_house_senate_mv_tmp_rpt_year_idx
    ON public.ofec_reports_house_senate_mv_tmp
    USING btree
    (report_year, idx);
    
CREATE INDEX idx_ofec_reports_house_senate_mv_tmp_tot_rcpt_period_idx
    ON public.ofec_reports_house_senate_mv_tmp
    USING btree
    (total_receipts_period, idx);

CREATE INDEX idx_ofec_reports_house_senate_mv_tmp_filer_name_text
    ON public.ofec_reports_house_senate_mv_tmp
    USING gin (filer_name_text);

-- ------------
-- point the view to the _mv_tmp    
-- ------------
CREATE OR REPLACE VIEW public.ofec_reports_house_senate_vw AS 
  SELECT * FROM public.ofec_reports_house_senate_mv_tmp;


-- drop old MV:ofec_reports_house_senate_mv
DROP MATERIALIZED VIEW IF EXISTS public.ofec_reports_house_senate_mv;


-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_reports_house_senate_mv_tmp 
  RENAME TO ofec_reports_house_senate_mv;


-- rename all indexes

ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_idx RENAME TO idx_ofec_reports_house_senate_mv_idx;
    
ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_tot_disb_period_id_idx RENAME TO idx_ofec_reports_house_senate_mv_tot_disb_period_id_idx;
    
ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_beg_image_num_idx RENAME TO idx_ofec_reports_house_senate_mv_beg_image_num_idx;
    
ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_cmte_id_idx RENAME TO idx_ofec_reports_house_senate_mv_cmte_id_idx;
    
ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_cvg_end_date_idx RENAME TO idx_ofec_reports_house_senate_mv_cvg_end_date_idx;
    
ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_cvg_start_date_idx RENAME TO idx_ofec_reports_house_senate_mv_cvg_start_date_idx;
    
ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_cyc_idx RENAME TO idx_ofec_reports_house_senate_mv_cyc_idx;
    
ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_is_amen_idx RENAME TO idx_ofec_reports_house_senate_mv_is_amen_idx;
    
ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_rcpt_date_idx RENAME TO idx_ofec_reports_house_senate_mv_rcpt_date_idx;
    
ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_rpt_type_idx RENAME TO idx_ofec_reports_house_senate_mv_rpt_type_idx;
    
ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_rpt_year_idx RENAME TO idx_ofec_reports_house_senate_mv_rpt_year_idx;
    
ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_tot_rcpt_period_idx RENAME TO idx_ofec_reports_house_senate_mv_tot_rcpt_period_idx;

ALTER INDEX public.idx_ofec_reports_house_senate_mv_tmp_filer_name_text RENAME TO idx_ofec_reports_house_senate_mv_filer_name_text;
