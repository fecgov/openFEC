create or replace function ofec_sched_b_update_fulltext() returns void as $$
begin
    delete from ofec_sched_b_fulltext
    where sched_b_sk = any(select sched_b_sk from ofec_sched_b_queue_old)
    ;
    insert into ofec_sched_b_fulltext (
        select
            sched_b_sk,
            to_tsvector(recipient_nm) as recipient_name_text,
            to_tsvector(disb_desc) as disbursement_description_text
        from ofec_sched_b_queue_new
    )
    ;
end
$$ language plpgsql;
