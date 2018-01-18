-- redefine MATERIALIZED VIEW public.ofec_sched_a_aggregate_size_merged_mv to use disclosure.dsc_sched_a_aggregate_size instead of public ofec_sched_a_aggregate_size

REFRESH MATERIALIZED VIEW public.ofec_candidate_history_mv;
REFRESH MATERIALIZED VIEW public.ofec_committee_history_mv;
REFRESH MATERIALIZED VIEW public.ofec_pac_party_paper_amendments_mv;
REFRESH MATERIALIZED VIEW public.ofec_house_senate_paper_amendments_mv;
REFRESH MATERIALIZED VIEW public.ofec_presidential_paper_amendments_mv;
REFRESH MATERIALIZED VIEW public.ofec_amendments_mv;
REFRESH MATERIALIZED VIEW public.ofec_filings_amendments_all_mv;
REFRESH MATERIALIZED VIEW public.ofec_filings_mv;
REFRESH MATERIALIZED VIEW public.ofec_totals_combined_mv;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_aggregate_size_merged_mv_TMP;

CREATE MATERIALIZED VIEW public.ofec_sched_a_aggregate_size_merged_mv_TMP AS 
 WITH grouped AS (
          SELECT ofec_totals_combined_mv.committee_id AS cmte_id,
            ofec_totals_combined_mv.cycle,
            0 AS size,
            ofec_totals_combined_mv.individual_unitemized_contributions AS total,
            0 AS count
           FROM ofec_totals_combined_mv
          WHERE ofec_totals_combined_mv.cycle >= 2007
        UNION ALL
         SELECT sched_a_aggregate_size.cmte_id,
            sched_a_aggregate_size.cycle,
            sched_a_aggregate_size.size,
            sched_a_aggregate_size.total,
            sched_a_aggregate_size.count
           FROM disclosure.dsc_sched_a_aggregate_size sched_a_aggregate_size
        )
 SELECT row_number() OVER () AS idx,
    grouped.cmte_id,
    grouped.cycle,
    grouped.size,
    sum(grouped.total) AS total,
        CASE
            WHEN grouped.size = 0 THEN NULL::numeric
            ELSE sum(grouped.count)
        END AS count
   FROM grouped
  GROUP BY grouped.cmte_id, grouped.cycle, grouped.size
WITH DATA;

ALTER TABLE public.ofec_sched_a_aggregate_size_merged_mv_TMP
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_a_aggregate_size_merged_mv_TMP TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_aggregate_size_merged_mv_TMP TO fec_read;


CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_cmte_id_idx_TMP
  ON public.ofec_sched_a_aggregate_size_merged_mv_TMP
  USING btree
  (cmte_id COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_count_idx_TMP
  ON public.ofec_sched_a_aggregate_size_merged_mv_TMP
  USING btree
  (count, idx);


CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_cycle_cmte_id_TMP
  ON public.ofec_sched_a_aggregate_size_merged_mv_TMP
  USING btree
  (cycle, cmte_id COLLATE pg_catalog."default");


CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_cycle_idx_TMP
  ON public.ofec_sched_a_aggregate_size_merged_mv_TMP
  USING btree
  (cycle, idx);


CREATE UNIQUE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_idx_TMP
  ON public.ofec_sched_a_aggregate_size_merged_mv_TMP
  USING btree
  (idx);


CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_size_idx_TMP
  ON public.ofec_sched_a_aggregate_size_merged_mv_TMP
  USING btree
  (size, idx);


CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_total_idx_TMP
  ON public.ofec_sched_a_aggregate_size_merged_mv_TMP
  USING btree
  (total, idx);


-- ------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_aggregate_size_merged_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_aggregate_size_merged_mv_TMP RENAME TO ofec_sched_a_aggregate_size_merged_mv;

--SELECT public.rename_indexes ('ofec_sched_a_aggregate_size_merged_mv');

ALTER INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_total_idx_tmp RENAME TO ofec_sched_a_aggregate_size_merged_mv_total_idx;

ALTER INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_size_idx_tmp RENAME TO ofec_sched_a_aggregate_size_merged_mv_size_idx;

ALTER INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_idx_tmp RENAME TO ofec_sched_a_aggregate_size_merged_mv_idx;

ALTER INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_cycle_idx_tmp RENAME TO ofec_sched_a_aggregate_size_merged_mv_cycle_idx;

ALTER INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_cycle_cmte_id_tmp RENAME TO ofec_sched_a_aggregate_size_merged_mv_cycle_cmte_id;

ALTER INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_count_idx_tmp RENAME TO ofec_sched_a_aggregate_size_merged_mv_count_idx;

ALTER INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_cmte_id_idx_tmp RENAME TO ofec_sched_a_aggregate_size_merged_mv_cmte_id_idx;

