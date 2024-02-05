/*
This migration file is to solve issue #5232
-- Change made in this file
Add one column: committee_name
-- Previous migration file is V0263
*/
-- ------------------------------------------------
-- ofec_reports_ie_only_mv
-- ------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_reports_ie_only_mv_tmp;
CREATE MATERIALIZED VIEW public.ofec_reports_ie_only_mv_tmp AS
-- WITH fec_vsum_f5 AS
SELECT row_number() OVER () AS idx,
f5.indv_org_id AS committee_id,
(f5.rpt_yr + f5.rpt_yr%2) AS cycle,
    f5.cvg_start_dt AS coverage_start_date,
    f5.cvg_end_dt AS coverage_end_date,
    f5.rpt_yr AS report_year,
    f5.ttl_indt_contb AS independent_contributions_period,
    f5.ttl_indt_exp AS independent_expenditures_period,
    f5.filer_sign_dt AS filer_sign_date,
    f5.notary_sign_dt AS notary_sign_date,
    f5.notary_commission_exprtn_dt AS notary_commission_experation_date,
    f5.begin_image_num AS beginning_image_number,
    f5.end_image_num AS end_image_number,
    f5.rpt_tp AS report_type,
    f5.rpt_tp_desc AS report_type_full,
    (CASE WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text ELSE 'N'::text END) ~~ 'N'::text AS is_amended,
    f5.receipt_dt AS receipt_date,
    f5.file_num AS file_number,
    f5.amndt_ind AS amendment_indicator,
    f5.amndt_ind_desc AS amendment_indicator_full,
    means_filed(f5.begin_image_num::text) AS means_filed,
    report_html_url(means_filed(f5.begin_image_num::text), f5.indv_org_id::text, f5.file_num::text) AS html_url,
    report_fec_url(f5.begin_image_num::text, f5.file_num::integer) AS fec_url,
    to_tsvector(parse_fulltext(coalesce(f5.filer_nm,'')||' '||f5.indv_org_id)) as spender_name_text,
    f5.filer_nm AS committee_name
FROM (disclosure.nml_form_5 f5
  LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f5.sub_id = vs.orig_sub_id)))
WHERE ((f5.delete_ind IS NULL) AND ((f5.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])))
AND (f5.rpt_yr + f5.rpt_yr%2) >= 1979::numeric
WITH DATA;

ALTER TABLE public.ofec_reports_ie_only_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_reports_ie_only_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_reports_ie_only_mv_tmp TO fec_read;


CREATE UNIQUE INDEX idx_ofec_reports_ie_only_mv_tmp_idx
  ON public.ofec_reports_ie_only_mv_tmp
  USING btree
  (idx);

CREATE INDEX idx_ofec_reports_ie_only_mv_tmp_begin_image_num_idx
  ON public.ofec_reports_ie_only_mv_tmp
  USING btree
  (beginning_image_number COLLATE pg_catalog."default", idx);

CREATE INDEX idx_ofec_reports_ie_only_mv_tmp_cmte_id_idx
  ON public.ofec_reports_ie_only_mv_tmp
  USING btree
  (committee_id COLLATE pg_catalog."default", idx);

CREATE INDEX idx_ofec_reports_ie_only_mv_tmp_cvg_end_dt_idx
  ON public.ofec_reports_ie_only_mv_tmp
  USING btree
  (coverage_end_date, idx);

CREATE INDEX idx_ofec_reports_ie_only_mv_tmp_cvg_start_dt_idx
  ON public.ofec_reports_ie_only_mv_tmp
  USING btree
  (coverage_start_date, idx);

CREATE INDEX idx_ofec_reports_ie_only_mv_tmp_cycle_idx
  ON public.ofec_reports_ie_only_mv_tmp
  USING btree
  (cycle, idx);

CREATE INDEX idx_ofec_reports_ie_only_mv_tmp_indt_exp_period_idx
  ON public.ofec_reports_ie_only_mv_tmp
  USING btree
  (independent_expenditures_period, idx);

CREATE INDEX idx_ofec_reports_ie_only_mv_tmp_is_amended_idx
  ON public.ofec_reports_ie_only_mv_tmp
  USING btree
  (is_amended, idx);

CREATE INDEX idx_ofec_reports_ie_only_mv_tmp_receipt_dt_idx
  ON public.ofec_reports_ie_only_mv_tmp
  USING btree
  (receipt_date, idx);

CREATE INDEX idx_ofec_reports_ie_only_mv_tmp_rpt_tp_idx
  ON public.ofec_reports_ie_only_mv_tmp
  USING btree
  (report_type COLLATE pg_catalog."default", idx);

CREATE INDEX idx_ofec_reports_ie_only_mv_tmp_rpt_yr_idx
  ON public.ofec_reports_ie_only_mv_tmp
  USING btree
  (report_year, idx);

CREATE INDEX IF NOT EXISTS idx_ofec_reports_ie_only_mv_tmp_spender_name_text
  ON public.ofec_reports_ie_only_mv_tmp
  USING gin
  (spender_name_text);


-- point view to the tmp mv
CREATE OR REPLACE VIEW public.ofec_reports_ie_only_vw AS 
 SELECT * FROM ofec_reports_ie_only_mv_tmp;

ALTER TABLE public.ofec_reports_ie_only_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_reports_ie_only_vw TO fec;
GRANT SELECT ON TABLE public.ofec_reports_ie_only_vw TO fec_read;

-- drop old MV
DROP MATERIALIZED VIEW IF EXISTS public.ofec_reports_ie_only_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW public.ofec_reports_ie_only_mv_tmp RENAME TO ofec_reports_ie_only_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_reports_ie_only_mv_tmp_idx RENAME TO idx_ofec_reports_ie_only_mv_idx;

ALTER INDEX IF EXISTS idx_ofec_reports_ie_only_mv_tmp_begin_image_num_idx RENAME TO idx_ofec_reports_ie_only_mv_begin_image_num_idx;

ALTER INDEX IF EXISTS idx_ofec_reports_ie_only_mv_tmp_cmte_id_idx RENAME TO idx_ofec_reports_ie_only_mv_cmte_id_idx;

ALTER INDEX IF EXISTS idx_ofec_reports_ie_only_mv_tmp_cvg_end_dt_idx RENAME TO idx_ofec_reports_ie_only_mv_cvg_end_dt_idx;

ALTER INDEX IF EXISTS idx_ofec_reports_ie_only_mv_tmp_cvg_start_dt_idx RENAME TO idx_ofec_reports_ie_only_mv_cvg_start_dt_idx;

ALTER INDEX IF EXISTS idx_ofec_reports_ie_only_mv_tmp_cycle_idx RENAME TO idx_ofec_reports_ie_only_mv_cycle_idx;

ALTER INDEX IF EXISTS idx_ofec_reports_ie_only_mv_tmp_indt_exp_period_idx RENAME TO idx_ofec_reports_ie_only_mv_indt_exp_period_idx;

ALTER INDEX IF EXISTS idx_ofec_reports_ie_only_mv_tmp_is_amended_idx RENAME TO idx_ofec_reports_ie_only_mv_is_amended_idx;

ALTER INDEX IF EXISTS idx_ofec_reports_ie_only_mv_tmp_receipt_dt_idx RENAME TO idx_ofec_reports_ie_only_mv_receipt_dt_idx;

ALTER INDEX IF EXISTS idx_ofec_reports_ie_only_mv_tmp_rpt_tp_idx RENAME TO idx_ofec_reports_ie_only_mv_rpt_tp_idx;

ALTER INDEX IF EXISTS idx_ofec_reports_ie_only_mv_tmp_rpt_yr_idx RENAME TO idx_ofec_reports_ie_only_mv_rpt_yr_idx;

ALTER INDEX IF EXISTS idx_ofec_reports_ie_only_mv_tmp_spender_name_text RENAME TO idx_ofec_reports_ie_only_mv_spender_name_text;
