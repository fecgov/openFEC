-- Create index for join on electioneering costs
drop index if exists disclosure.nml_sched_b_link_id_idx;
create index nml_sched_b_link_id_idx on disclosure.nml_sched_b (link_id);

-- Drop the old nightly refresh retry table and function if they still exist.
drop table if exists ofec_sched_b_nightly_retries;
drop function if exists retry_processing_schedule_b_records(start_year integer);

-- Drop the old queues if they still exist.
drop table if exists ofec_sched_b_queue_new;
drop table if exists ofec_sched_b_queue_old;


-- Create new triggers
drop trigger if exists nml_sched_b_after_trigger on disclosure.nml_sched_b;

drop trigger if exists nml_sched_b_before_trigger on disclosure.nml_sched_b;

drop trigger if exists f_item_sched_b_after_trigger on disclosure.f_item_receipt_or_exp;

drop trigger if exists f_item_sched_b_before_trigger on disclosure.f_item_receipt_or_exp;

drop function if exists ofec_sched_b_insert_update();
drop function if exists ofec_sched_b_delete_update();
drop function if exists increment_sched_b_aggregates(view_row fec_fitem_sched_b_vw);
drop function if exists decrement_sched_b_aggregates(view_row fec_fitem_sched_b_vw);

-- Drop the old trigger functions if they still exist.
drop function if exists ofec_sched_b_insert_update_queues();
drop function if exists ofec_sched_b_delete_update_queues();
