create or replace function ofec_sched_a_update_fulltext() returns void as $$
begin
    delete from ofec_sched_a_fulltext
    where sched_a_sk = any(select sched_a_sk from ofec_sched_a_queue_old)
    ;
    insert into ofec_sched_a_fulltext (
        select
            sched_a_sk,
            to_tsvector(contbr_nm) as contributor_name_text,
            to_tsvector(contbr_employer) as contributor_employer_text
        from ofec_sched_a_queue_new
    )
    ;
end
$$ language plpgsql;
