
/*
public.ofec_candidate_flag was renamed to public.ofec_candidate_flag_mv in 
migration script V0059 to fit our naming convention for MATERIALIZED VIEWs. 
However, in order to run a time/resource consuming migration script V0060 
the night before the code release to avoid time-out issues during high traffic hour, 
public.ofec_candidate_flag was temporarily added back. 
It should be dropped to finish the work.
*/

DROP MATERIALIZED VIEW IF EXISTS ofec_candidate_flag;
    
