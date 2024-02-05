-- add these index to aid the efile raw data filters
-- Since we change the API use real_efile.sa7 table instead of real_efile_sa7 view
-- dropping the unused view public.real_efile_sa7 view

CREATE INDEX real_efile_sa7_state_idx
  ON real_efile.sa7
  USING btree
  (state);

CREATE INDEX real_efile_sa7_comid_state_idx
  ON real_efile.sa7
  USING btree
  (comid,state);
  
CREATE INDEX ofec_committee_history_mv_tmp_state_idx1
  ON public.ofec_committee_history_mv
  USING btree
  (state);
  
CREATE INDEX ofec_committee_history_mv_tmp_comid_state_idx1
  ON public.ofec_committee_history_mv
  USING btree
  (committee_id,state);  

drop view if exists public.real_efile_sa7;

CREATE OR REPLACE VIEW public.efiling_amendment_chain_vw AS 
 WITH RECURSIVE oldest_filing AS (
         SELECT reps.repid,
            reps.comid,
            reps.previd,
            ARRAY[reps.repid] AS amendment_chain,
            1 AS depth,
            reps.repid AS last
           FROM real_efile.reps
          WHERE reps.previd IS NULL
        UNION
         SELECT se.repid,
            se.comid,
            se.previd,
            (oldest.amendment_chain || se.repid)::numeric(12,0)[] AS "numeric",
            oldest.depth + 1,
            oldest.amendment_chain[1] AS amendment_chain
           FROM oldest_filing oldest,
            real_efile.reps se
          WHERE se.previd = oldest.repid AND se.previd IS NOT NULL
        )
 SELECT oldest_filing.repid,
    oldest_filing.comid,
    oldest_filing.previd,
    oldest_filing.amendment_chain,
    oldest_filing.depth,
    oldest_filing.last,
    last_value(oldest_filing.repid) OVER amendment_group::numeric(12,0) AS most_recent_filing,
    last_value(oldest_filing.amendment_chain) OVER amendment_group::numeric(12,0)[] AS longest_chain
   FROM oldest_filing
  WINDOW amendment_group AS (PARTITION BY oldest_filing.last ORDER BY oldest_filing.depth RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING);

ALTER TABLE public.efiling_amendment_chain_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.efiling_amendment_chain_vw TO fec;
GRANT SELECT ON TABLE public.efiling_amendment_chain_vw TO fec_read;
