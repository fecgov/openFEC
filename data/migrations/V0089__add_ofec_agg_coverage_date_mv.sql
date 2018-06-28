-- create ofec_agg_coverage_date_mv to get latest coverage_end_date of processed P3


DROP MATERIALIZED VIEW IF EXISTS public.ofec_agg_coverage_date_mv;

CREATE MATERIALIZED VIEW public.ofec_agg_coverage_date_mv AS

  SELECT row_number() OVER () AS idx,
         f.cmte_id AS cand_cmte_id,
         f.rpt_yr + f.rpt_yr % 2::numeric AS fec_election_yr,
         max(f.cvg_end_dt) AS cvg_end_date
   FROM   disclosure.v_sum_and_det_sum_report f
  WHERE f.orig_sub_id IN ( SELECT o.sub_id
                             FROM staging.operations_log o
                            WHERE o.pass_3_entry_done_dt IS NOT NULL) 
    AND f.form_tp_cd::text ~~ 'F3%'::text
  GROUP BY f.cmte_id, (f.rpt_yr + f.rpt_yr % 2::numeric)
  WITH DATA;

 

ALTER TABLE public.ofec_agg_coverage_date_mv OWNER TO fec;

GRANT ALL ON TABLE public.ofec_agg_coverage_date_mv TO fec;

GRANT SELECT ON TABLE public.ofec_agg_coverage_date_mv TO fec_read;
 

CREATE INDEX IF NOT EXISTS ofec_agg_coverage_date_mv_idx ON public.ofec_agg_coverage_date_mv
   USING btree
  (cand_cmte_id COLLATE pg_catalog."default", fec_election_yr);
