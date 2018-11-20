/*
The refactoring of ofec_filings_all_mv is to solve issue #3440: /filings/ count incorrectly counting RFAI's twice
ofec_filings_all_mv was originally composed data from 
  disclosure.f_rpt_or_form_sub
  disclosure.nml_form_rfai
However, disclosure.f_rpt_or_form_sub already has all the RFAI filing information, under FORM_TP = 'FRQ'
So the union all from disclosure.nml_form_rfai is redundent
ofec_filings_all_mv is therefore refactored only take RFAI data from disclosure.f_rpt_or_form_sub,
which in general has more complete/meaning data.  

*/


DROP MATERIALIZED VIEW IF EXISTS public.ofec_filings_all_mv_tmp; 


CREATE MATERIALIZED VIEW public.ofec_filings_all_mv_tmp AS 
select row_number() OVER () AS idx,
cand.candidate_id,
cand.name AS candidate_name,
filing_history.cand_cmte_id AS committee_id,
com.name AS committee_name,
filing_history.sub_id,
filing_history.cvg_start_dt::text::date::timestamp without time zone AS coverage_start_date,
filing_history.cvg_end_dt::text::date::timestamp without time zone AS coverage_end_date,
filing_history.receipt_dt::text::date::timestamp without time zone AS receipt_date,
filing_history.election_yr AS election_year,
filing_history.form_tp AS form_type,
filing_history.rpt_yr AS report_year,
get_cycle(filing_history.rpt_yr) AS cycle,
filing_history.rpt_tp AS report_type,
filing_history.to_from_ind AS document_type,
expand_document(filing_history.to_from_ind::text) AS document_type_full,
filing_history.begin_image_num::bigint AS beginning_image_number,
filing_history.end_image_num AS ending_image_number,
filing_history.pages as pages,
filing_history.ttl_receipts AS total_receipts,
filing_history.ttl_indt_contb AS total_individual_contributions,
filing_history.net_dons AS net_donations,
filing_history.ttl_disb AS total_disbursements,
filing_history.ttl_indt_exp AS total_independent_expenditures,
filing_history.ttl_communication_cost AS total_communication_cost,
filing_history.coh_bop AS cash_on_hand_beginning_period,
filing_history.coh_cop AS cash_on_hand_end_period,
filing_history.debts_owed_by_cmte AS debts_owed_by_committee,
filing_history.debts_owed_to_cmte AS debts_owed_to_committee,
filing_history.hse_pers_funds_amt AS house_personal_funds,
filing_history.sen_pers_funds_amt AS senate_personal_funds,
filing_history.oppos_pers_fund_amt AS opposition_personal_funds,
filing_history.tres_nm AS treasurer_name,
filing_history.file_num AS file_number,
(case WHEN upper(filing_history.form_tp::text) = 'FRQ'::text THEN 0 else filing_history.prev_file_num end) AS previous_file_number,
report.rpt_tp_desc AS report_type_full,
filing_history.rpt_pgi AS primary_general_indicator,
filing_history.request_tp AS request_type,
filing_history.amndt_ind AS amendment_indicator,
filing_history.lst_updt_dt AS update_date,
report_pdf_url_or_null(filing_history.begin_image_num::text, filing_history.rpt_yr, com.committee_type::text, filing_history.form_tp::text) AS pdf_url,
means_filed(filing_history.begin_image_num::text) AS means_filed,
report_html_url(means_filed(filing_history.begin_image_num::text), filing_history.cand_cmte_id::text, filing_history.file_num::text) AS html_url,
report_fec_url(filing_history.begin_image_num::text, filing_history.file_num::integer) AS fec_url,
amendments.amendment_chain,
amendments.mst_rct_file_num AS most_recent_file_number,
is_amended(amendments.mst_rct_file_num::integer, amendments.file_num::integer, filing_history.form_tp::text) AS is_amended,
is_most_recent(amendments.mst_rct_file_num::integer, amendments.file_num::integer, filing_history.form_tp::text) AS most_recent,
CASE
    WHEN upper(filing_history.form_tp::text) = 'FRQ'::text THEN 0
    WHEN upper(filing_history.form_tp::text) = 'F99'::text THEN 0
    ELSE array_length(amendments.amendment_chain, 1) - 1
END AS amendment_version,
cand.state,
cand.office,
cand.district,
cand.party,
cmte_valid_fec_yr.cmte_tp,
get_office_cmte_tp(cand.office, cmte_valid_fec_yr.cmte_tp) AS office_cmte_tp
FROM disclosure.f_rpt_or_form_sub filing_history
LEFT JOIN disclosure.cmte_valid_fec_yr cmte_valid_fec_yr ON filing_history.cand_cmte_id::text = cmte_valid_fec_yr.cmte_id::text AND get_cycle(filing_history.rpt_yr)::numeric = cmte_valid_fec_yr.fec_election_yr
LEFT JOIN ofec_committee_history_vw com ON filing_history.cand_cmte_id::text = com.committee_id::text AND get_cycle(filing_history.rpt_yr)::numeric = com.cycle
LEFT JOIN ofec_candidate_history_vw cand ON filing_history.cand_cmte_id::text = cand.candidate_id::text AND get_cycle(filing_history.rpt_yr)::numeric = cand.two_year_period
LEFT JOIN staging.ref_rpt_tp report ON filing_history.rpt_tp::text = report.rpt_tp_cd::text
LEFT JOIN ofec_filings_amendments_all_vw amendments ON filing_history.file_num = amendments.file_num
WHERE filing_history.rpt_yr >= 1979::numeric AND filing_history.form_tp::text <> 'SL'::text;   
   
ALTER TABLE public.ofec_filings_all_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_filings_all_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_filings_all_mv_tmp TO fec_read;


CREATE INDEX idx_ofec_filings_all_mv_tmp_committee_id
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (committee_id COLLATE pg_catalog."default");


CREATE INDEX idx_ofec_filings_all_mv_tmp_receipt_date
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (receipt_date);


CREATE UNIQUE INDEX idx_ofec_filings_all_mv_tmp_idx
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (idx);

CREATE INDEX idx_ofec_filings_all_mv_tmp_form_type
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (form_type COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_amend_ind
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (amendment_indicator COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_beg_img_num
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (beginning_image_number);

CREATE INDEX idx_ofec_filings_all_mv_tmp_cand_id
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (candidate_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_cvg_end_dt
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (coverage_end_date);

CREATE INDEX idx_ofec_filings_all_mv_tmp_cvg_start_dt
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (coverage_start_date);

CREATE INDEX idx_ofec_filings_all_mv_tmp_cycle_cmte_id
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (cycle, committee_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_cycle
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (cycle);

CREATE INDEX idx_ofec_filings_all_mv_tmp_district
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (district COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_office_cmte_tp
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (office_cmte_tp COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_office
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (office COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_party
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (party COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_pri_gnrl_ind
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (primary_general_indicator COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_rpt_tp_full
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (report_type_full COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_rpt_tp
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (report_type COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_rpt_yr
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (report_year);

CREATE INDEX idx_ofec_filings_all_mv_tmp_req_tp
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (request_type COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_state
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (state COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_filings_all_mv_tmp_ttl_disb
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (total_disbursements);


CREATE INDEX idx_ofec_filings_all_mv_tmp_ttl_indpndnt_exp
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (total_independent_expenditures);

CREATE INDEX idx_ofec_filings_all_mv_tmp_ttl_rcpt
  ON public.ofec_filings_all_mv_tmp
  USING btree
  (total_receipts);
-- -------------------------------------------------------------------------------
-- public.public.ofec_filings_all_vw depends on public.public.ofec_filings_all_mv.  
-- It is not used by API OR other MV/VW yet.  Just drop and recreated
DROP VIEW public.ofec_filings_all_vw;

-- -------------------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_filings_all_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_filings_all_mv_tmp RENAME TO ofec_filings_all_mv;

-- ------------------------------------
CREATE OR REPLACE VIEW public.ofec_filings_all_vw AS 
SELECT * FROM public.ofec_filings_all_mv;

ALTER TABLE public.ofec_filings_all_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_filings_all_vw TO fec;
GRANT ALL ON TABLE public.ofec_filings_all_vw TO fec_read;

-- ------------------------------------
ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_committee_id RENAME TO idx_ofec_filings_all_mv_committee_id;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_receipt_date RENAME TO idx_ofec_filings_all_mv_receipt_date;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_idx RENAME TO idx_ofec_filings_all_mv_idx;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_form_type RENAME TO idx_ofec_filings_all_mv_form_type;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_amend_ind RENAME TO idx_ofec_filings_all_mv_amend_ind;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_beg_img_num RENAME TO idx_ofec_filings_all_mv_beg_img_num;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_cand_id RENAME TO idx_ofec_filings_all_mv_cand_id; 

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_cvg_end_dt RENAME TO idx_ofec_filings_all_mv_cvg_end_dt;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_cvg_start_dt RENAME TO idx_ofec_filings_all_mv_cvg_start_dt;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_cycle_cmte_id RENAME TO idx_ofec_filings_all_mv_cycle_cmte_id;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_cycle RENAME TO idx_ofec_filings_all_mv_cycle;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_district RENAME TO idx_ofec_filings_all_mv_district;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_office_cmte_tp RENAME TO idx_ofec_filings_all_mv_office_cmte_tp;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_office RENAME TO idx_ofec_filings_all_mv_office;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_party RENAME TO idx_ofec_filings_all_mv_party;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_pri_gnrl_ind RENAME TO idx_ofec_filings_all_mv_pri_gnrl_ind;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_rpt_tp_full RENAME TO idx_ofec_filings_all_mv_rpt_tp_full;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_rpt_tp RENAME TO idx_ofec_filings_all_mv_rpt_tp;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_rpt_yr RENAME TO idx_ofec_filings_all_mv_rpt_yr;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_req_tp RENAME TO idx_ofec_filings_all_mv_req_tp;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_state RENAME TO ∫idx_ofec_filings_all_mv_state;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_ttl_disb RENAME TO idx_ofec_filings_all_mv_ttl_disb;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_ttl_indpndnt_exp RENAME TO idx_ofec_filings_all_mv_ttl_indpndnt_exp;

ALTER INDEX IF EXISTS public.idx_ofec_filings_all_mv_tmp_ttl_rcpt RENAME TO idx_ofec_filings_all_mv_ttl_rcpt; 

