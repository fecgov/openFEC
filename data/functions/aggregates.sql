create or replace function update_aggregates() returns void as $$
begin
    -- Update Schedule B aggregates in place
    perform ofec_sched_b_update_aggregate_purpose();
    perform ofec_sched_b_update_aggregate_recipient();
    perform ofec_sched_b_update_aggregate_recipient_id();
end
$$ language plpgsql;
