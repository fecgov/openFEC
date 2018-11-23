/*
Issue #3431
The following 3 tables had been replaced by
dsc_sched_b_aggregate_purpose
dsc_sched_b_aggregate_recipient
dsc_sched_b_aggregate_recipient_id

dsc_sched_b_aggregate_purpose_new
dsc_sched_b_aggregate_recipient_new
dsc_sched_b_aggregate_recipient_id_new

with updated business logic and new and renamed columns

The process had been completed with completion of issue #3390 in Sprint 7.5

So these tables (and related process) are dropped by issue #3459
*/

-- ------------------
-- 	drop tables
-- ------------------
drop table if exists disclosure.dsc_sched_b_aggregate_purpose;
drop table if exists disclosure.dsc_sched_b_aggregate_recipient;
drop table if exists disclosure.dsc_sched_b_aggregate_recipient_id;
