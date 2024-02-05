/*
This migration file solve issue #3970 ScheduleAByStateCandidateView slowness

Originally, this endpoint use a view public.ofec_sched_a_agg_state_vw to sum up all the non-real state as 'OT'
Although views can not have indexes, they will take advantage from the indexes of its base tables. 
However, the original query use a subquery and a view composed of multiple base tables and database optimizer somehow decided not to use the view's base tables' indexes and cause the slowness.
We can choose to re-write the query or create a MV to replace the view.

There are more than one endpoints share the same function in resource file to generate final query, it would be less impact to create a MV to replace the view.
Also for better readability.

Since this is a new MV, flow.py and manage.py had been updated to add the refresh of MV
*/

-- ------------------
-- recreate the view 
-- first edition: the new MV removed one column originally thought unnecessary 
-- 	max(sa.idx) AS idx
-- So view need to be recreate instead of create or replace
--
-- second edition: another endpoint do need to use the idx column.  Add it back.
-- (the model ScheduleAByState inherits from BaseAggregate which inherits from BaseModel which references column idx)
-- since the orginal migration file already run, this view still need to be recreated.
-- ------------------
DROP VIEW IF EXISTS public.ofec_sched_a_agg_state_vw;
CREATE OR REPLACE VIEW public.ofec_sched_a_agg_state_vw AS 
SELECT sa.cmte_id,
    sa.cycle,
    COALESCE(st.st, 'OT'::character varying) AS state,
    COALESCE(sa.state_full, 'Other'::text) AS state_full,
    max(sa.idx) AS idx,
    sum(sa.total) AS total,
    sum(sa.count) AS count
   FROM disclosure.dsc_sched_a_aggregate_state sa
     LEFT JOIN staging.ref_st st ON sa.state::text = st.st::text
  GROUP BY sa.cmte_id, sa.cycle, st.st, sa.state_full;

ALTER TABLE public.ofec_sched_a_agg_state_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_a_agg_state_vw TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_agg_state_vw TO fec_read;

-- ------------------------------------------------
-- ofec_sched_a_agg_state_mv
-- this is a new MATERIALIZED VIEW so there is no need to go through _tmp process
-- ------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_agg_state_mv;

CREATE MATERIALIZED VIEW IF NOT EXISTS public.ofec_sched_a_agg_state_mv AS 
 SELECT sa.cmte_id,
    sa.cycle,
    COALESCE(st.st, 'OT'::character varying) AS state,
    COALESCE(sa.state_full, 'Other'::text) AS state_full,
    max(sa.idx) AS idx,
    sum(sa.total) AS total,
    sum(sa.count) AS count
   FROM disclosure.dsc_sched_a_aggregate_state sa
     LEFT JOIN staging.ref_st st ON sa.state::text = st.st::text
  GROUP BY sa.cmte_id, sa.cycle, st.st, sa.state_full;
  
ALTER TABLE public.ofec_sched_a_agg_state_mv OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_a_agg_state_mv TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_agg_state_mv TO fec_read;

-- indexes
CREATE UNIQUE INDEX idx_ofec_sched_a_agg_state_mv_cmte_id_cycle_state
  ON public.ofec_sched_a_agg_state_mv
  USING btree
  (cmte_id, cycle, state);

ANALYZE public.ofec_sched_a_agg_state_mv;

-- ------------------
-- ------------------
CREATE OR REPLACE VIEW public.ofec_sched_a_agg_state_vw AS 
 SELECT * FROM public.ofec_sched_a_agg_state_mv;

ALTER TABLE public.ofec_sched_a_agg_state_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_a_agg_state_vw TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_agg_state_vw TO fec_read;
