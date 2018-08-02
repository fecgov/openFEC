DROP VIEW IF EXISTS public.ofec_sched_a_agg_state_vw;

CREATE OR REPLACE VIEW public.ofec_sched_a_agg_state_vw AS
SELECT 
	cmte_id,
	cycle AS cycle,
	COALESCE(st.st, 'OT') AS state,
	COALESCE(state_full, 'Other') AS state_full,
	MAX(idx) AS idx,
	SUM(total) AS total,
	SUM(count) AS count
FROM disclosure.dsc_sched_a_aggregate_state sa
LEFT OUTER JOIN staging.ref_st st
ON sa.state = st.st
GROUP BY cmte_id, cycle, st.st, state_full;

ALTER TABLE public.ofec_sched_a_agg_state_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_a_agg_state_vw TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_agg_state_vw TO fec_read;
