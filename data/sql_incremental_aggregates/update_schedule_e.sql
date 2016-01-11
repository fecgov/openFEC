create or replace function ofec_sched_e_update() returns void as $$
begin
    -- Drop all queued deletes
    delete from ofec_sched_e
    where sched_e_sk = any(select sched_e_sk from ofec_sched_e_queue_old)
    ;
    -- Insert all queued updates, unless a row with the same key exists in the
    -- delete queue with a later timestamp
    insert into ofec_sched_e (
        select
            new.*,
            coalesce(rpt_tp, '') in ('24', '48') as is_notice,
            to_tsvector(new.pye_nm) as payee_name_text
        from ofec_sched_e_queue_new new
        left join ofec_sched_e_queue_old old on new.sched_e_sk = old.sched_e_sk and old.timestamp > new.timestamp
        where old.sched_e_sk is null
        order by new.sched_e_sk, new.timestamp desc
    );
end
$$ language plpgsql;
