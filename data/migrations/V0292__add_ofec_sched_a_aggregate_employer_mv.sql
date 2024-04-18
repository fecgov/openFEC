/*
This migration file is for #5739

1) Create ofec_sched_a_aggregate_employer_mv to include ts_vector column:employer_text
*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_aggregate_employer_mv;

CREATE MATERIALIZED VIEW public.ofec_sched_a_aggregate_employer_mv AS
    SELECT cmte_id,
        cycle::numeric(4,0),
        employer,
        ROUND(total,2) AS total,
        count,
        idx,
        to_tsvector(parse_fulltext(employer)) AS employer_text
    FROM disclosure.dsc_sched_a_aggregate_employer
WITH DATA;

ALTER TABLE IF EXISTS public.ofec_sched_a_aggregate_employer_mv
OWNER TO fec;

GRANT ALL ON TABLE public.ofec_sched_a_aggregate_employer_mv TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_aggregate_employer_mv TO fec_read;

-- Add indexes
CREATE INDEX idx_ofec_sched_a_aggregate_employer_mv_employer
    ON public.ofec_sched_a_aggregate_employer_mv USING btree
    (employer);

CREATE INDEX idx_ofec_sched_a_aggregate_employer_mv_employer_text
    ON public.ofec_sched_a_aggregate_employer_mv USING gin
    (employer_text);

CREATE INDEX idx_ofec_sched_a_aggregate_employer_mv_cmte_id
    ON public.ofec_sched_a_aggregate_employer_mv USING btree
    (cmte_id);

CREATE INDEX idx_ofec_sched_a_aggregate_employer_mv_count
    ON public.ofec_sched_a_aggregate_employer_mv USING btree
    (count);

CREATE INDEX idx_ofec_sched_a_aggregate_employer_mv_cycle
    ON public.ofec_sched_a_aggregate_employer_mv USING btree
    (cycle);

CREATE INDEX idx_ofec_sched_a_aggregate_employer_mv_cycle_cmte_id
    ON public.ofec_sched_a_aggregate_employer_mv USING btree
    (cycle, cmte_id);

CREATE INDEX idx_ofec_sched_a_aggregate_employer_mv_total
    ON public.ofec_sched_a_aggregate_employer_mv USING btree
    (total);

CREATE UNIQUE INDEX idx_ofec_sched_a_aggregate_employer_mv_idx
    ON public.ofec_sched_a_aggregate_employer_mv USING btree
    (idx);
