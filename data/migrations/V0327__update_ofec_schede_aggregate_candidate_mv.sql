/* This is for issue #6733. In this script, exp_tp is used to decide support_oppose_indicator
*/

------create mv_tmp--------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_e_aggregate_candidate_mv_tmp; 


CREATE MATERIALIZED VIEW public.ofec_sched_e_aggregate_candidate_mv_tmp AS
 WITH records AS (
          SELECT se.cmte_id, 
            se.s_o_cand_id AS cand_id,
            CASE
              WHEN se.exp_tp = '24A' THEN 'O'
              WHEN se.exp_tp = '24E' THEN 'S'
              ELSE 'Other'::character varying
            END AS support_oppose_indicator,
            se.election_cycle AS cycle,
            se.exp_amt
          FROM disclosure.fec_fitem_sched_e se
          WHERE se.memo_cd::text <> 'X'::text OR se.memo_cd IS NULL
          UNION ALL
          SELECT f57.filer_cmte_id AS cmte_id,
            f57.s_o_cand_id AS cand_id,
            CASE
              WHEN f57.exp_tp = '24A' THEN 'O'
              WHEN f57.exp_tp = '24E' THEN 'S'
              ELSE 'Other'::character varying
            END AS support_oppose_indicator,
            f57.election_cycle AS cycle,
            f57.exp_amt
          FROM disclosure.fec_fitem_f57 f57
  )
SELECT row_number() OVER () AS idx,
      records.cmte_id,
      records.cand_id,
      records.support_oppose_indicator,
      records.cycle,
      sum(records.exp_amt) AS total,
      count(records.exp_amt) AS count
FROM records
WHERE records.exp_amt IS NOT NULL
GROUP BY  records.cmte_id, records.cand_id, records.support_oppose_indicator,records.cycle
WITH DATA;

ALTER TABLE public.ofec_sched_e_aggregate_candidate_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_e_aggregate_candidate_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_sched_e_aggregate_candidate_mv_tmp TO fec_read;

-- -----------------------
-- Add Indexes
-- -----------------------
CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_tmp_s_o_indicator
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (support_oppose_indicator COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_tmp_cand_id
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (cand_id COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_tmp_cmte_id
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (cmte_id COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_tmp_count
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (count);

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_tmp_cycle_cand_id
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (cycle, cand_id COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_tmp_cycle_cmte_id
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (cycle, cmte_id COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_tmp_cycle
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (cycle);

CREATE UNIQUE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_tmp_idx
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (idx);

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_tmp_total
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (total);
    
-- ------------------------------------
-- public.ofec_sched_e_aggregate_candidate_vw is not referenced by API nor other MV for now
-- So can directly drop it first
DROP VIEW IF EXISTS public.ofec_sched_e_aggregate_candidate_vw;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_e_aggregate_candidate_mv;
 
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_sched_e_aggregate_candidate_mv_tmp RENAME TO ofec_sched_e_aggregate_candidate_mv;

-- ------------------------------------
CREATE OR REPLACE VIEW public.ofec_sched_e_aggregate_candidate_vw AS 
SELECT * FROM public.ofec_sched_e_aggregate_candidate_mv;

ALTER TABLE public.ofec_sched_e_aggregate_candidate_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_e_aggregate_candidate_vw TO fec;
GRANT ALL ON TABLE public.ofec_sched_e_aggregate_candidate_vw TO fec_read;
