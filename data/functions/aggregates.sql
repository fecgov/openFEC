create or replace function update_aggregates() returns void as $$
begin
    -- Update Schedule A aggregates in place
    perform ofec_sched_a_update_aggregate_zip();
    perform ofec_sched_a_update_aggregate_size();
    perform ofec_sched_a_update_aggregate_state();
    perform ofec_sched_a_update_aggregate_employer();
    perform ofec_sched_a_update_aggregate_occupation();
    perform ofec_sched_a_update_aggregate_contributor();
    perform ofec_sched_a_update_aggregate_contributor_type();

    -- Update Schedule B aggregates in place
    perform ofec_sched_b_update_aggregate_purpose();
    perform ofec_sched_b_update_aggregate_recipient();
    perform ofec_sched_b_update_aggregate_recipient_id();

    -- Update full-text tables in place
    perform ofec_sched_a_update();
    perform ofec_sched_b_update();
    perform ofec_sched_e_update();

    -- Clear queue tables
    delete from ofec_sched_a_queue_new;
    delete from ofec_sched_a_queue_old;
    delete from ofec_sched_b_queue_new;
    delete from ofec_sched_b_queue_old;
end
$$ language plpgsql;
