/*
This migration file is for #5739

1) Create ofec_sched_a_aggregate_occupation_mv to include ts_vector column: occupation_text
*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_aggregate_occupation_mv;

CREATE MATERIALIZED VIEW public.ofec_sched_a_aggregate_occupation_mv AS
   SELECT cmte_id,
      cycle::numeric(4,0),
      occupation,
      ROUND(total,2) AS total,
      count,
      idx,
      to_tsvector(parse_fulltext(occupation)) AS occupation_text
   FROM disclosure.dsc_sched_a_aggregate_occupation
WITH DATA;

ALTER TABLE IF EXISTS public.ofec_sched_a_aggregate_occupation_mv
OWNER TO fec;

GRANT ALL ON TABLE public.ofec_sched_a_aggregate_occupation_mv TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_aggregate_occupation_mv TO fec_read;

-- Add indexes
CREATE INDEX idx_ofec_sched_a_aggregate_occupation_mv_cmte_id
   ON public.ofec_sched_a_aggregate_occupation_mv USING btree
    (cmte_id);

CREATE INDEX idx_ofec_sched_a_aggregate_occupation_mv_count
    ON public.ofec_sched_a_aggregate_occupation_mv USING btree
    (count);

CREATE INDEX idx_ofec_sched_a_aggregate_occupation_mv_cycle
    ON public.ofec_sched_a_aggregate_occupation_mv USING btree
    (cycle);

CREATE INDEX idx_ofec_sched_a_aggregate_occupation_mv_cycle_cmte_id
    ON public.ofec_sched_a_aggregate_occupation_mv USING btree
    (cycle, cmte_id);

CREATE INDEX idx_ofec_sched_a_aggregate_occupation_mv_occupation
    ON public.ofec_sched_a_aggregate_occupation_mv USING btree
    (occupation);

CREATE INDEX idx_ofec_sched_a_aggregate_occupation_mv_total
    ON public.ofec_sched_a_aggregate_occupation_mv USING btree
    (total);

CREATE INDEX idx_ofec_sched_a_aggregate_occupation_mv_occupation_text
    ON public.ofec_sched_a_aggregate_occupation_mv USING gin
    (occupation_text);

CREATE UNIQUE INDEX idx_ofec_sched_a_aggregate_occupation_mv_idx
    ON public.ofec_sched_a_aggregate_occupation_mv USING btree
    (idx);
