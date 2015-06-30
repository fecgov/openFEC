create or replace function update_aggregates() returns void as $$
begin
    -- Update aggregates in place
    perform ofec_sched_a_update_aggregate_zip();
    perform ofec_sched_a_update_aggregate_state();
    perform ofec_sched_a_update_aggregate_size();

    -- Update full-text tables in place
    perform ofec_sched_a_update_fulltext();
    perform ofec_sched_b_update_fulltext();

    -- Clear queue tables
    delete from ofec_sched_a_queue_new;
    delete from ofec_sched_a_queue_old;
end
$$ language plpgsql;
