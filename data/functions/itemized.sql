-- Provides the functions that allow us to retry processing itemized schedule
-- records that failed to process correctly upon initial record changes to the
-- underlying disclosure.nml_sched_a and disclosure.nml_sched_b tables.

-- If the record is successfully processed, it will be added to the main
-- nightly refresh queues to be taken care of with all of the other records
-- that were originally processed successfully.  If it is not, meaning it still
-- couldn't be found in the public.fec_fitem_sched_<x>_vw views, the sub_id
-- will remain in the ofec_sched_<x>_nightly_retries table until it is.

-- Convenience function that takes care of all of the processing at once.
create or replace function retry_processing_itemized_records() returns void as $$
begin
    perform retry_processing_schedule_a_records(:START_YEAR_AGGREGATE);
    perform retry_processing_schedule_b_records(:START_YEAR_AGGREGATE);
end
$$ language plpgsql;
