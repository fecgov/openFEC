create or replace function update_aggregates() returns void as $$
begin
    -- Update Schedule A aggregates in place
    perform ofec_sched_a_update_aggregate_zip();
    perform ofec_sched_a_update_aggregate_size();
    perform ofec_sched_a_update_aggregate_state();
    perform ofec_sched_a_update_aggregate_employer();
    perform ofec_sched_a_update_aggregate_occupation();

    -- Update Schedule B aggregates in place
    perform ofec_sched_b_update_aggregate_purpose();
    perform ofec_sched_b_update_aggregate_recipient();
    perform ofec_sched_b_update_aggregate_recipient_id();

    -- Update Schedule E
    perform ofec_sched_e_update();
    delete from ofec_sched_e_queue_new;
    delete from ofec_sched_e_queue_old;

    perform ofec_sched_e_notice_update();
    delete from ofec_nml_24_queue_old;
    --in case of inner join failing, keep this one in queue until related rows
    -- are addded in disclousre.nml_form_24 (not likely to happen)
    delete from ofec_nml_24_queue_new where sub_id in (select sub_id from ofec_sched_e_notice);
end
$$ language plpgsql;
