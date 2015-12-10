create or replace function ofec_sched_b_update() returns void as $$
begin
    delete from ofec_sched_b
    where sched_b_sk = any(select sched_b_sk from ofec_sched_b_queue_old)
    ;
    insert into ofec_sched_b(
        select distinct on(sched_b_sk)
            new.*,
            to_tsvector(new.recipient_nm) as recipient_name_text,
            to_tsvector(new.disb_desc) as disbursement_description_text,
            disbursement_purpose(new.disb_tp, new.disb_desc) as disbursement_purpose_category,
            clean_repeated(new.recipient_cmte_id, new.cmte_id) as clean_recipient_cmte_id
        from ofec_sched_b_queue_new new
        left join ofec_sched_b_queue_old old on new.sched_b_sk = old.sched_b_sk and old.timestamp > new.timestamp
        where old.sched_b_sk is null
        order by new.sched_b_sk, new.timestamp desc
    );
end
$$ language plpgsql;
