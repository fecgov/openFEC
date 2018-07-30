DROP VIEW IF EXISTS public.ofec_sched_a_agg_state_vw;

CREATE OR REPLACE VIEW public.ofec_sched_a_agg_state_vw AS
select cmte_id,
cycle as CYCLE,
COALESCE (st.st, 'ot') AS STATE,
COALESCE (STATE_FULL, 'Other') AS STATE_FULL,
max(idx) as IDX,
SUM(total) AS TOTAL,
SUM(count) AS COUNT
from disclosure.dsc_sched_a_aggregate_state sa
LEFT OUTER JOIN staging.ref_st st
ON sa.state = st.st
GROUP BY CMTE_ID, CYCLE, st.st, STATE_FULL;

-- grants
ALTER TABLE public.ofec_sched_a_agg_state_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_a_agg_state_vw TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_agg_state_vw TO fec_read;


/*
select cmte_id,
STATE,
STATE_FULL,
total,
count
from public.ofec_sched_a_agg_state_vw
WHERE CYCLE = 2018
AND CMTE_ID = 'C00401224'
ORDER BY STATE_FULL 
*/