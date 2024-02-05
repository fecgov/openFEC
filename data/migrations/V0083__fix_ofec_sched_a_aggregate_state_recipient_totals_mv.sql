-- Superceeds Migration #54
-- redefine MATERIALIZED VIEW public.ofec_sched_a_aggregate_state_recipient_totals_mv to join properly to staging.ref_zip_to_district

DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_aggregate_state_recipient_totals_mv_TMP;

CREATE MATERIALIZED VIEW public.ofec_sched_a_aggregate_state_recipient_totals_mv_TMP AS
 WITH grouped_totals AS (
         SELECT sum(agg_st.total) AS total,
            count(agg_st.total) AS count,
            agg_st.cycle,
            agg_st.state,
            agg_st.state_full,
            cd.committee_type,
            cd.committee_type_full
           FROM disclosure.dsc_sched_a_aggregate_state agg_st
             JOIN ofec_committee_detail_mv cd ON agg_st.cmte_id::text = cd.committee_id::text
          WHERE (agg_st.state::text IN (SELECT state_abbrevation
                   FROM staging.ref_zip_to_district))
          GROUP BY agg_st.cycle, agg_st.state, agg_st.state_full, cd.committee_type, cd.committee_type_full
        ), candidate_totals AS (
         SELECT sum(totals.total) AS total,
            sum(totals.count) AS count,
            totals.cycle,
            totals.state,
            totals.state_full,
            'ALL_CANDIDATES'::text AS committee_type,
            'All Candidates'::text AS committee_type_full
           FROM grouped_totals totals
          WHERE totals.committee_type::text = ANY (ARRAY['H'::character varying, 'S'::character varying, 'P'::character varying]::text[])
          GROUP BY totals.cycle, totals.state, totals.state_full
        ), pacs_totals AS (
         SELECT sum(totals.total) AS total,
            sum(totals.count) AS count,
            totals.cycle,
            totals.state,
            totals.state_full,
            'ALL_PACS'::text AS committee_type,
            'All PACs'::text AS committee_type_full
           FROM grouped_totals totals
          WHERE totals.committee_type::text = ANY (ARRAY['N'::character varying, 'O'::character varying, 'Q'::character varying, 'V'::character varying, 'W'::character varying]::text[])
          GROUP BY totals.cycle, totals.state, totals.state_full
        ), overall_total AS (
         SELECT sum(totals.total) AS total,
            sum(totals.count) AS count,
            totals.cycle,
            totals.state,
            totals.state_full,
            'ALL'::text AS committee_type,
            'All'::text AS committee_type_full
           FROM grouped_totals totals
          GROUP BY totals.cycle, totals.state, totals.state_full
        ), combined AS (
         SELECT grouped_totals.total,
            grouped_totals.count,
            grouped_totals.cycle,
            grouped_totals.state,
            grouped_totals.state_full,
            grouped_totals.committee_type,
            grouped_totals.committee_type_full
           FROM grouped_totals
        UNION ALL
         SELECT candidate_totals.total,
            candidate_totals.count,
            candidate_totals.cycle,
            candidate_totals.state,
            candidate_totals.state_full,
            candidate_totals.committee_type,
            candidate_totals.committee_type_full
           FROM candidate_totals
        UNION ALL
         SELECT pacs_totals.total,
            pacs_totals.count,
            pacs_totals.cycle,
            pacs_totals.state,
            pacs_totals.state_full,
            pacs_totals.committee_type,
            pacs_totals.committee_type_full
           FROM pacs_totals
        UNION ALL
         SELECT overall_total.total,
            overall_total.count,
            overall_total.cycle,
            overall_total.state,
            overall_total.state_full,
            overall_total.committee_type,
            overall_total.committee_type_full
           FROM overall_total
  ORDER BY 4, 3, 6
        )
 SELECT row_number() OVER () AS idx,
    combined.total,
    combined.count,
    combined.cycle,
    combined.state,
    combined.state_full,
    combined.committee_type,
    combined.committee_type_full
   FROM combined;

ALTER TABLE public.ofec_sched_a_aggregate_state_recipient_totals_mv_TMP
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_a_aggregate_state_recipient_totals_mv_TMP TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_aggregate_state_recipient_totals_mv_TMP TO fec_read;


CREATE INDEX ofec_sched_a_aggregate_state_recipient_committee_type_idx_TMP
  ON public.ofec_sched_a_aggregate_state_recipient_totals_mv_TMP
  USING btree
  (committee_type COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_sched_a_aggregate_state_recipient_totals_mv_cycle_idx_TMP
  ON public.ofec_sched_a_aggregate_state_recipient_totals_mv_TMP
  USING btree
  (cycle, idx);


CREATE INDEX ofec_sched_a_aggregate_state_recipient_totals_mv_state_idx_TMP
  ON public.ofec_sched_a_aggregate_state_recipient_totals_mv_TMP
  USING btree
  (state COLLATE pg_catalog."default", idx);


CREATE UNIQUE INDEX ofec_sched_a_aggregate_state_recipient_totals_mv_idx_TMP
  ON public.ofec_sched_a_aggregate_state_recipient_totals_mv_TMP
  USING btree
  (idx);


-- ------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_aggregate_state_recipient_totals_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_aggregate_state_recipient_totals_mv_TMP RENAME TO ofec_sched_a_aggregate_state_recipient_totals_mv;

ALTER INDEX ofec_sched_a_aggregate_state_recipient_committee_type_idx_tmp RENAME TO ofec_sched_a_aggregate_state_recipient_committee_type_idx;

ALTER INDEX ofec_sched_a_aggregate_state_recipient_totals_mv_cycle_idx_tmp RENAME TO ofec_sched_a_aggregate_state_recipient_totals_mv_cycle_idx;

ALTER INDEX ofec_sched_a_aggregate_state_recipient_totals_mv_state_idx_tmp RENAME TO ofec_sched_a_aggregate_state_recipient_totals_mv_state_idx;

ALTER INDEX ofec_sched_a_aggregate_state_recipient_totals_mv_idx_tmp RENAME TO ofec_sched_a_aggregate_state_recipient_totals_mv_idx;
