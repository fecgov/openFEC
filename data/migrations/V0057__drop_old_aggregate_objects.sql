-- delete unused aggregate functions  
-- delete unused aggregate tables
-- 

 
drop function if exists public.ofec_sched_a_update_aggregate_zip();
drop function if exists public.ofec_sched_a_update_aggregate_size();
drop function if exists public.ofec_sched_a_update_aggregate_state();
drop function if exists public.ofec_sched_a_update_aggregate_employer();
drop function if exists public.ofec_sched_a_update_aggregate_occupation();

drop function if exists public.ofec_sched_b_update_aggregate_purpose();
drop function if exists public.ofec_sched_b_update_aggregate_recipient();
drop function if exists public.ofec_sched_b_update_aggregate_recipient_id();

drop function if exists public.update_aggregates();

drop table if exists public.ofec_sched_a_aggregate_employer cascade;
drop table if exists public.ofec_sched_a_aggregate_occupation cascade;
drop table if exists public.ofec_sched_a_aggregate_size cascade;
drop table if exists public.ofec_sched_a_aggregate_state cascade;
drop table if exists public.ofec_sched_a_aggregate_zip cascade;
drop table if exists public.ofec_sched_b_aggregate_purpose cascade;
drop table if exists public.ofec_sched_b_aggregate_recipient cascade;
drop table if exists public.ofec_sched_b_aggregate_recipient_id cascade;
