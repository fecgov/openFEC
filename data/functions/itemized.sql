-- Provides the functions that allow us to retry processing itemized schedule
-- records that failed to process correctly upon initial record changes to the
-- underlying disclosure.nml_sched_a and disclosure.nml_sched_b tables.

-- If the record is successfully processed, it will be added to the main
-- nightly refresh queues to be taken care of with all of the other records
-- that were originally processed successfully.  If it is not, meaning it still
-- couldn't be found in the public.fec_vsum_sched_a_vw or
-- public.fec_vsum_sched_b_vw views, the sub_id will remain in the
-- ofec_sched_a_nightly_retries/ofec_sched_b_nightly_retries table until it is.

-- Convenience function that takes care of all of the processing at once.
CREATE OR REPLACE FUNCTION retry_processing_itemized_records() RETURNS VOID AS $$
BEGIN
    PERFORM retry_processing_schedule_a_records(:START_YEAR_AGGREGATE);
    PERFORM retry_processing_schedule_b_records(:START_YEAR_AGGREGATE);
END
$$ LANGUAGE plpgsql;
