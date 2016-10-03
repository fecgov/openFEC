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

    perform ofec_sched_e_update_from_f57();
    delete from fec_vsum_f57_queue_new;
    delete from fec_vsum_f57_queue_old;

    perform ofec_sched_e_notice_update_from_f24();
    delete from ofec_nml_24_queue_old;
    delete from ofec_nml_24_queue_new where sub_id in (select sub_id from ofec_sched_e);

    --after some sched_e discussion, best to do the deletes this way, ensure no records
    --are cleared until they are ready to be (with the drawback that some records will sit
    --in the queues for a day

    perform ofec_sched_e_f57_notice_update();
    delete from ofec_f57_queue_old;
    delete from ofec_f57_queue_new where sub_id in (select sub_id from ofec_sched_e);
    delete from ofec_f57_queue_new where sub_id in (select new.sub_id from ofec_f57_queue_new new, disclosure.nml_form_5 f5
        where new.link_id = f5.sub_id and (f5.rpt_tp <> '48' or f5.rpt_tp <> '24'));
    delete from ofec_f57_queue_old where sub_id in (select new.sub_id from ofec_f57_queue_new new, disclosure.nml_form_5 f5
        where new.link_id = f5.sub_id and (f5.rpt_tp <> '48' or f5.rpt_tp <> '24'));

end
$$ language plpgsql;
