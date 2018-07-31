-- update ofec_agg_coverage_date_mv logic to take amendment situation into consideration
DROP MATERIALIZED VIEW IF EXISTS public.ofec_agg_coverage_date_mv_tmp;

CREATE MATERIALIZED VIEW IF NOT EXISTS public.ofec_agg_coverage_date_mv_tmp AS
WITH OPERATIONS_LOG AS
(
SELECT sub_id, max(pass_3_entry_done_dt) over (partition by cand_cmte_id, rpt_yr, rpt_tp) max_pass_3_dt
FROM staging.operations_log
)
SELECT row_number() OVER () AS idx,
f.cmte_id AS cand_cmte_id,
f.rpt_yr + f.rpt_yr % 2::numeric AS fec_election_yr,
max(f.cvg_end_dt)::text::date AS coverage_end_date
FROM disclosure.v_sum_and_det_sum_report f
WHERE f.orig_sub_id IN
(
SELECT SUB_ID FROM OPERATIONS_LOG 
WHERE max_pass_3_dt IS NOT NULL
)
AND f.form_tp_cd::text ~~ 'F3%'::text
GROUP BY f.cmte_id, (f.rpt_yr + f.rpt_yr % 2::numeric)
WITH DATA;

 
-- grants
ALTER TABLE public.ofec_agg_coverage_date_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_agg_coverage_date_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_agg_coverage_date_mv_tmp TO fec_read;
 

CREATE INDEX IF NOT EXISTS idx_ofec_agg_cvg_dt_mv_cmte_id_fec_elec_yr_tmp 
ON public.ofec_agg_coverage_date_mv_tmp
  USING btree
  (cand_cmte_id COLLATE pg_catalog."default", fec_election_yr);

CREATE UNIQUE INDEX IF NOT EXISTS idx_ofec_agg_cvg_dt_mv_idx_tmp 
ON public.ofec_agg_coverage_date_mv_tmp
  USING btree
  (idx);

-- -------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_agg_coverage_date_mv;

ALTER MATERIALIZED VIEW IF EXISTS ofec_agg_coverage_date_mv_tmp RENAME TO ofec_agg_coverage_date_mv;

ALTER INDEX idx_ofec_agg_cvg_dt_mv_cmte_id_fec_elec_yr_tmp RENAME TO idx_ofec_agg_cvg_dt_mv_cmte_id_fec_elec_yr;

ALTER INDEX idx_ofec_agg_cvg_dt_mv_idx_tmp RENAME TO idx_ofec_agg_cvg_dt_mv_idx;
