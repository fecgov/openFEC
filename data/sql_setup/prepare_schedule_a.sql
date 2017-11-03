-- Drop the old nightly refresh retry table and function if they still exist.
drop table if exists ofec_sched_a_nightly_retries;
drop function if exists retry_processing_schedule_a_records(start_year integer);

-- Drop the old queues if they still exist.
drop table if exists ofec_sched_a_queue_new;
drop table if exists ofec_sched_a_queue_old;



-- Create new triggers
drop trigger if exists nml_sched_a_after_trigger on disclosure.nml_sched_a;

drop trigger if exists nml_sched_a_before_trigger on disclosure.nml_sched_a;

drop trigger if exists f_item_sched_a_after_trigger on disclosure.f_item_receipt_or_exp;

drop trigger if exists f_item_sched_a_before_trigger on disclosure.f_item_receipt_or_exp;

drop function if exists ofec_sched_a_insert_update();
drop function if exists ofec_sched_a_delete_update();
drop function if exists increment_sched_a_aggregates(view_row fec_fitem_sched_a_vw);
drop function if exists decrement_sched_a_aggregates(view_row fec_fitem_sched_a_vw);


-- Drop the old trigger functions if they still exist.
drop function if exists ofec_sched_a_insert_update_queues();
drop function if exists ofec_sched_a_delete_update_queues();
