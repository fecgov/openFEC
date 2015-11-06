create or replace function ofec_sched_b_update() returns void as $$
begin
    delete from ofec_sched_b
    where sched_b_sk = any(select sched_b_sk from ofec_sched_b_queue_old)
    ;
    insert into ofec_sched_b(
        select
            *,
            to_tsvector(recipient_nm) as recipient_name_text,
            to_tsvector(disb_desc) as disbursement_description_text,
            disbursement_purpose(disb_tp, disb_desc) as disbursement_purpose_category,
            clean_repeated(recipient_cmte_id, cmte_id) as clean_recipient_cmte_id
        from ofec_sched_b_queue_new
    );
end
$$ language plpgsql;
