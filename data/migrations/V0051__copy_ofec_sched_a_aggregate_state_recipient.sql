CREATE MATERIALIZED VIEW ofec_sched_a_aggregate_state_recipient_totals_2_mv AS

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
          WHERE (agg_st.state::text IN ( SELECT fips_state_code
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
          WHERE totals.committee_type::text = ANY (ARRAY['H'::character varying::text, 'S'::character varying::text, 'P'::character varying::text])
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
          WHERE totals.committee_type::text = ANY (ARRAY['N'::character varying::text, 'O'::character varying::text, 'Q'::character varying::text, 'V'::character varying::text, 'W'::character varying::text])
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
   FROM combined
;


ALTER TABLE public.ofec_sched_a_aggregate_state_recipient_totals_2_mv
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_a_aggregate_state_recipient_totals_2_mv TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_aggregate_state_recipient_totals_2_mv TO fec_read;


CREATE INDEX ofec_sched_a_aggregate_state_recip_committee_type_full_2_idx
  ON public.ofec_sched_a_aggregate_state_recipient_totals_2_mv
  USING btree
  (committee_type_full COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_sched_a_aggregate_state_recipient__committee_type_2_idx
  ON public.ofec_sched_a_aggregate_state_recipient_totals_2_mv
  USING btree
  (committee_type COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_sched_a_aggregate_state_recipient_tota_state_full_2_idx
  ON public.ofec_sched_a_aggregate_state_recipient_totals_2_mv
  USING btree
  (state_full COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_sched_a_aggregate_state_recipient_totals_2_mv_count_2_idx
  ON public.ofec_sched_a_aggregate_state_recipient_totals_2_mv
  USING btree
  (count, idx);


CREATE INDEX ofec_sched_a_aggregate_state_recipient_totals_2_mv_cycle_2_idx
  ON public.ofec_sched_a_aggregate_state_recipient_totals_2_mv
  USING btree
  (cycle, idx);


CREATE INDEX ofec_sched_a_aggregate_state_recipient_totals_2_mv_state_2_idx
  ON public.ofec_sched_a_aggregate_state_recipient_totals_2_mv
  USING btree
  (state COLLATE pg_catalog."default", idx);


CREATE UNIQUE INDEX ofec_sched_a_aggregate_state_recipient_totals_2_mv_idx
  ON public.ofec_sched_a_aggregate_state_recipient_totals_2_mv
  USING btree
  (idx);


CREATE INDEX ofec_sched_a_aggregate_state_recipient_totals_2_mv_total_idx
  ON public.ofec_sched_a_aggregate_state_recipient_totals_2_mv
  USING btree
  (total, idx);
