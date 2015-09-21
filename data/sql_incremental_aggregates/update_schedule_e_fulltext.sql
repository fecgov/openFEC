create or replace function ofec_sched_e_update() returns void as $$
begin
    delete from ofec_sched_e
    where sched_e_sk = any(select sched_e_sk from ofec_sched_e_queue_old)
    ;
    insert into ofec_sched_e (
        select
            *,
            to_tsvector(pye_nm) as payee_name_text
        from ofec_sched_e_queue_new
    );
end
$$ language plpgsql;
