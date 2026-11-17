/*
This migration file is for issue #6707. 
It creates a new materialized view for IE support oppose totals endpoint
*/
DROP MATERIALIZED VIEW IF EXISTS public.ofec_ie_so_aggregate_mv;

CREATE MATERIALIZED VIEW IF NOT EXISTS public.ofec_ie_so_aggregate_mv AS
WITH records AS (
        SELECT se.cmte_id,
            se.s_o_cand_id AS cand_id,
            COALESCE(c.office, se.s_o_cand_office) AS office,
            COALESCE(c.state, se.s_o_cand_office_st) AS state,
            COALESCE(c.district, se.s_o_cand_office_district) AS district,
            se.election_cycle AS cycle,
            CASE
                WHEN se.exp_tp::text = '24A' THEN 'O'::character varying
                WHEN se.exp_tp::text = '24E' THEN 'S'::character varying
                ELSE 'Other'::character varying(5)
            END AS support_oppose_indicator,
            se.exp_amt
        FROM disclosure.fec_fitem_sched_e se
        LEFT JOIN ofec_candidate_history_mv c ON se.s_o_cand_id = c.candidate_id AND se.election_cycle = c.two_year_period
        WHERE se.memo_cd::text IS DISTINCT FROM 'X'::text
        UNION ALL
        SELECT f57.filer_cmte_id AS cmte_id,
            f57.s_o_cand_id AS cand_id,
            COALESCE(c.office, f57.s_o_cand_office) AS office,
            COALESCE(c.state, f57.s_o_cand_office_st) AS state,
            COALESCE(c.district, f57.s_o_cand_office_district) AS district,
            f57.election_cycle AS cycle,
            CASE
                WHEN f57.exp_tp::text = '24A' THEN 'O'::character varying
                WHEN f57.exp_tp::text = '24E' THEN 'S'::character varying
                ELSE 'Other'::character varying(5)
            END AS support_oppose_indicator,
            f57.exp_amt
        FROM disclosure.fec_fitem_f57 f57
        LEFT JOIN ofec_candidate_history_mv c ON f57.s_o_cand_id = c.candidate_id AND f57.election_cycle = c.two_year_period
        )
SELECT row_number() OVER () AS idx,
    records.cycle::integer AS cycle,
    records.office,
        CASE
            WHEN records.office = 'P' AND records.state IS NULL THEN 'US'
            ELSE records.state
        END AS state,
        CASE
            WHEN records.office IN ('P', 'S') AND records.district IS NULL THEN '00'::character varying
            ELSE records.district
        END AS district,
    records.support_oppose_indicator,
    sum(records.exp_amt) AS total
FROM records
GROUP BY records.cycle, records.office, records.state, records.district, records.support_oppose_indicator
WITH DATA;

ALTER TABLE IF EXISTS public.ofec_ie_so_aggregate_mv OWNER TO fec;

GRANT ALL ON TABLE public.ofec_ie_so_aggregate_mv TO fec;

GRANT SELECT ON TABLE public.ofec_ie_so_aggregate_mv TO fec_read;

CREATE INDEX idx_ofec_ie_so_aggregate_mv_cycle_st_district
ON public.ofec_ie_so_aggregate_mv USING btree (cycle, state , district )
;

CREATE UNIQUE INDEX idx_ofec_ie_so_aggregate_mv_idx
ON public.ofec_ie_so_aggregate_mv USING btree (idx)
;
