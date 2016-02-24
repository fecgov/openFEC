create or replace function ofec_sched_a_update() returns void as $$
begin
    -- Drop all queued deletes
    delete from ofec_sched_a
    where sched_a_sk = any(select sched_a_sk from ofec_sched_a_queue_old)
    ;
    -- Insert all queued updates, unless a row with the same key exists in the
    -- delete queue with a later timestamp
    insert into ofec_sched_a(
        select distinct on (sched_a_sk)
            new.*,
            to_tsvector(new.contbr_nm) || to_tsvector(coalesce(new.contbr_id, ''))
                as contributor_name_text,
            to_tsvector(new.contbr_employer) as contributor_employer_text,
            to_tsvector(new.contbr_occupation) as contributor_occupation_text,
            is_individual(new.contb_receipt_amt, new.receipt_tp, new.line_num, new.memo_cd, new.memo_text)
                as is_individual,
            clean_repeated(new.contbr_id, new.cmte_id) as clean_contbr_id
        from ofec_sched_a_queue_new new
        left join ofec_sched_a_queue_old old on new.sched_a_sk = old.sched_a_sk and old.timestamp > new.timestamp
        where old.sched_a_sk is null
        order by new.sched_a_sk, new.timestamp desc
    );
end
$$ language plpgsql;
