-- ---------public.ofec_reports_presidential_mv---------
/*
This is migration is for issue #5160
Add tsvector fulltext column : filer_name_text
Add idx_ofec_reports_presidential_mv_filer_name_text in public.ofec_reports_presidential_mv

-- Previous mv is V0146
*/
-- -----------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS public.ofec_reports_presidential_mv_tmp;
CREATE MATERIALIZED VIEW public.ofec_reports_presidential_mv_tmp AS
  SELECT row_number() OVER () AS idx,
    f3p.cmte_id AS committee_id,
    f3p.rpt_yr + f3p.rpt_yr % 2::numeric AS cycle,
    f3p.cvg_start_dt AS coverage_start_date,
    f3p.cvg_end_dt AS coverage_end_date,
    f3p.begin_image_num AS beginning_image_number,
    f3p.cand_contb_per AS candidate_contribution_period,
    f3p.cand_contb_ytd AS candidate_contribution_ytd,
    f3p.coh_bop AS cash_on_hand_beginning_period,
    f3p.coh_cop AS cash_on_hand_end_period,
    f3p.debts_owed_by_cmte AS debts_owed_by_committee,
    f3p.debts_owed_to_cmte AS debts_owed_to_committee,
    f3p.end_image_num AS end_image_number,
    f3p.exempt_legal_acctg_disb_per AS exempt_legal_accounting_disbursement_period,
    f3p.exempt_legal_acctg_disb_ytd AS exempt_legal_accounting_disbursement_ytd,
    f3p.exp_subject_limits AS expenditure_subject_to_limits,
    f3p.fed_funds_per AS federal_funds_period,
    f3p.fed_funds_ytd AS federal_funds_ytd,
    f3p.fndrsg_disb_per AS fundraising_disbursements_period,
    f3p.fndrsg_disb_ytd AS fundraising_disbursements_ytd,
    f3p.indv_unitem_contb_per AS individual_unitemized_contributions_period,
    f3p.indv_unitem_contb_ytd AS individual_unitemized_contributions_ytd,
    f3p.indv_item_contb_per AS individual_itemized_contributions_period,
    f3p.indv_item_contb_ytd AS individual_itemized_contributions_ytd,
    f3p.indv_contb_per AS total_individual_contributions_period,
    f3p.indv_contb_ytd AS total_individual_contributions_ytd,
    f3p.items_on_hand_liquidated,
    f3p.loans_received_from_cand_per AS loans_received_from_candidate_period,
    f3p.loans_received_from_cand_ytd AS loans_received_from_candidate_ytd,
    f3p.net_contb_sum_page_per AS net_contributions_cycle_to_date,
    f3p.net_op_exp_sum_page_per AS net_operating_expenditures_cycle_to_date,
    f3p.offsets_to_fndrsg_exp_ytd AS offsets_to_fundraising_exp_ytd,
    f3p.offsets_to_fndrsg_exp_per AS offsets_to_fundraising_expenditures_period,
    f3p.offsets_to_fndrsg_exp_ytd AS offsets_to_fundraising_expenditures_ytd,
    f3p.offsets_to_legal_acctg_per AS offsets_to_legal_accounting_period,
    f3p.offsets_to_legal_acctg_ytd AS offsets_to_legal_accounting_ytd,
    f3p.offsets_to_op_exp_per AS offsets_to_operating_expenditures_period,
    f3p.offsets_to_op_exp_ytd AS offsets_to_operating_expenditures_ytd,
    f3p.op_exp_per AS operating_expenditures_period,
    f3p.op_exp_ytd AS operating_expenditures_ytd,
    f3p.other_disb_per AS other_disbursements_period,
    f3p.other_disb_ytd AS other_disbursements_ytd,
    f3p.other_loans_received_per AS other_loans_received_period,
    f3p.other_loans_received_ytd,
    f3p.other_pol_cmte_contb_per AS other_political_committee_contributions_period,
    f3p.other_pol_cmte_contb_ytd AS other_political_committee_contributions_ytd,
    f3p.other_receipts_per AS other_receipts_period,
    f3p.other_receipts_ytd,
    f3p.pol_pty_cmte_contb_per AS political_party_committee_contributions_period,
    f3p.pol_pty_cmte_contb_ytd AS political_party_committee_contributions_ytd,
    f3p.ref_indv_contb_per AS refunded_individual_contributions_period,
    f3p.ref_indv_contb_ytd AS refunded_individual_contributions_ytd,
    f3p.ref_other_pol_cmte_contb_per AS refunded_other_political_committee_contributions_period,
    f3p.ref_other_pol_cmte_contb_ytd AS refunded_other_political_committee_contributions_ytd,
    f3p.ref_pol_pty_cmte_contb_per AS refunded_political_party_committee_contributions_period,
    f3p.ref_pol_pty_cmte_contb_ytd AS refunded_political_party_committee_contributions_ytd,
    f3p.repymts_loans_made_by_cand_per AS repayments_loans_made_by_candidate_period,
    f3p.repymts_loans_made_cand_ytd AS repayments_loans_made_candidate_ytd,
    f3p.repymts_other_loans_per AS repayments_other_loans_period,
    f3p.repymts_other_loans_ytd AS repayments_other_loans_ytd,
    f3p.rpt_yr AS report_year,
    f3p.subttl_sum_page_per AS subtotal_summary_period,
    f3p.ttl_contb_ref_per AS total_contribution_refunds_period,
    f3p.ttl_contb_ref_ytd AS total_contribution_refunds_ytd,
    f3p.ttl_contb_per AS total_contributions_period,
    f3p.ttl_contb_ytd AS total_contributions_ytd,
    f3p.ttl_disb_per AS total_disbursements_period,
    f3p.ttl_disb_ytd AS total_disbursements_ytd,
    f3p.ttl_loan_repymts_made_per AS total_loan_repayments_made_period,
    f3p.ttl_loan_repymts_made_ytd AS total_loan_repayments_made_ytd,
    f3p.ttl_loans_received_per AS total_loans_received_period,
    f3p.ttl_loans_received_ytd AS total_loans_received_ytd,
    f3p.ttl_offsets_to_op_exp_per AS total_offsets_to_operating_expenditures_period,
    f3p.ttl_offsets_to_op_exp_ytd AS total_offsets_to_operating_expenditures_ytd,
    f3p.ttl_per AS total_period,
    f3p.ttl_receipts_per AS total_receipts_period,
    f3p.ttl_receipts_ytd AS total_receipts_ytd,
    f3p.ttl_ytd AS total_ytd,
    f3p.tranf_from_affilated_cmte_per AS transfers_from_affiliated_committee_period,
    f3p.tranf_from_affiliated_cmte_ytd AS transfers_from_affiliated_committee_ytd,
    f3p.tranf_to_other_auth_cmte_per AS transfers_to_other_authorized_committee_period,
    f3p.tranf_to_other_auth_cmte_ytd AS transfers_to_other_authorized_committee_ytd,
    f3p.rpt_tp AS report_type,
    f3p.rpt_tp_desc AS report_type_full,
    CASE
      WHEN vs.orig_sub_id IS NOT NULL THEN 'Y'::text
      ELSE 'N'::text
    END ~~ 'N'::text AS is_amended,
    f3p.receipt_dt AS receipt_date,
    f3p.file_num AS file_number,
    f3p.amndt_ind AS amendment_indicator,
    f3p.amndt_ind_desc AS amendment_indicator_full,
    means_filed(f3p.begin_image_num::text) AS means_filed,
    report_html_url(means_filed(f3p.begin_image_num::text), f3p.cmte_id::text, f3p.file_num::text) AS html_url,
    report_fec_url(f3p.begin_image_num::text, f3p.file_num::integer) AS fec_url,
    amendments.amendment_chain,
    amendments.prev_file_num AS previous_file_number,
    amendments.mst_rct_file_num AS most_recent_file_number,
    is_most_recent(f3p.file_num::integer, amendments.mst_rct_file_num::integer) AS most_recent,
    cmte.cmte_nm AS committee_name,
    to_tsvector(parse_fulltext(cmte.cmte_nm)) as filer_name_text
  FROM disclosure.nml_form_3p f3p
  LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON f3p.sub_id = vs.orig_sub_id
  LEFT JOIN disclosure.cmte_valid_fec_yr cmte ON (f3p.rpt_yr + f3p.rpt_yr % 2::numeric) = cmte.fec_election_yr AND f3p.cmte_id::text = cmte.cmte_id::text
  LEFT JOIN ofec_filings_amendments_all_vw amendments ON f3p.file_num = amendments.file_num
  WHERE f3p.rpt_yr >= 1979::numeric AND f3p.delete_ind IS NULL
WITH DATA;

ALTER TABLE public.ofec_reports_presidential_mv_tmp
    OWNER TO fec;

GRANT ALL ON TABLE public.ofec_reports_presidential_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_reports_presidential_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_reports_presidential_mv_tmp_idx
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (idx);

CREATE INDEX idx_ofec_reports_presidential_mv_tmp_tot_disb_period_idx
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (total_disbursements_period, idx);

CREATE INDEX idx_ofec_reports_presidential_mv_tmp_beg_image_num_idx
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (beginning_image_number COLLATE pg_catalog."default", idx);

CREATE INDEX idx_ofec_reports_presidential_mv_tmp_cmte_id_idx
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (committee_id COLLATE pg_catalog."default", idx);

CREATE INDEX idx_ofec_reports_presidential_mv_tmp_cvg_end_date_idx
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (coverage_end_date, idx);

CREATE INDEX idx_ofec_reports_presidential_mv_tmp_cvg_start_date_idx
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (coverage_start_date, idx);

CREATE INDEX idx_ofec_reports_presidential_mv_tmp_cyc_cmte_id
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (cycle, committee_id COLLATE pg_catalog."default");
 
CREATE INDEX idx_ofec_reports_presidential_mv_tmp_cyc_idx
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (cycle, idx);

CREATE INDEX idx_ofec_reports_presidential_mv_tmp_is_amen_idx
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (is_amended, idx);

CREATE INDEX idx_ofec_reports_presidential_mv_tmp_rcpt_date_idx
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (receipt_date, idx);

CREATE INDEX idx_ofec_reports_presidential_mv_tmp_rpt_type_idx
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (report_type COLLATE pg_catalog."default", idx);

CREATE INDEX idx_ofec_reports_presidential_mv_tmp_rpt_year_idx
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (report_year, idx);
    
CREATE INDEX idx_ofec_reports_presidential_mv_tmp_tot_rcpt_period_idx
    ON public.ofec_reports_presidential_mv_tmp
    USING btree
    (total_receipts_period, idx);
    
CREATE INDEX idx_ofec_reports_presidential_mv_tmp_filer_name_text
    ON public.ofec_reports_presidential_mv_tmp
    USING gin
    (filer_name_text);

-- ---------------
CREATE OR REPLACE VIEW public.ofec_reports_presidential_vw AS 
  SELECT * FROM public.ofec_reports_presidential_mv_tmp;
-- ---------------


-- drop old MV:ofec_reports_presidential_mv
DROP MATERIALIZED VIEW IF EXISTS public.ofec_reports_presidential_mv;


-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_reports_presidential_mv_tmp 
  RENAME TO ofec_reports_presidential_mv;


-- rename all indexes
ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_idx RENAME TO idx_ofec_reports_presidential_mv_idx;

ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_tot_disb_period_idx RENAME TO idx_ofec_reports_presidential_mv_tot_disb_period_idx;

ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_beg_image_num_idx RENAME TO idx_ofec_reports_presidential_mv_beg_image_num_idx;

ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_cmte_id_idx RENAME TO idx_ofec_reports_presidential_mv_cmte_id_idx;

ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_cvg_end_date_idx RENAME TO idx_ofec_reports_presidential_mv_cvg_end_date_idx;

ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_cvg_start_date_idx RENAME TO idx_ofec_reports_presidential_mv_cvg_start_date_idx;

ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_cyc_cmte_id RENAME TO idx_ofec_reports_presidential_mv_cyc_cmte_id;
 
ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_cyc_idx RENAME TO idx_ofec_reports_presidential_mv_cyc_idx;

ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_is_amen_idx RENAME TO idx_ofec_reports_presidential_mv_is_amen_idx;

ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_rcpt_date_idx RENAME TO idx_ofec_reports_presidential_mv_rcpt_date_idx;

ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_rpt_type_idx RENAME TO idx_ofec_reports_presidential_mv_rpt_type_idx;

ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_rpt_year_idx RENAME TO idx_ofec_reports_presidential_mv_rpt_year_idx;
    
ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_tot_rcpt_period_idx RENAME TO idx_ofec_reports_presidential_mv_tot_rcpt_period_idx;

ALTER INDEX public.idx_ofec_reports_presidential_mv_tmp_filer_name_text RENAME TO idx_ofec_reports_presidential_mv_filer_name_text;
