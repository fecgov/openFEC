create or replace function ofec_sched_b_update() returns void as $$
begin
    -- Drop all queued deletes
    delete from ofec_sched_b
    where sub_id = any(select sub_id from ofec_sched_b_queue_old)
    ;
    -- Insert all queued updates, unless a row with the same key exists in the
    -- delete queue with a later timestamp
    insert into ofec_sched_b(
        select distinct on(sub_id)
            new.*,
            image_pdf_url(new.image_num) as pdf_url,
            to_tsvector(new.recipient_nm) || to_tsvector(coalesce(clean_repeated(new.recipient_cmte_id, new.cmte_id), ''))
                as recipient_name_text,
            to_tsvector(new.disb_desc) as disbursement_description_text,
            disbursement_purpose(new.disb_tp, new.disb_desc) as disbursement_purpose_category,
            clean_repeated(new.recipient_cmte_id, new.cmte_id) as clean_recipient_cmte_id

        from ofec_sched_b_queue_new new
        left join ofec_sched_b_queue_old old on new.sub_id = old.sub_id and old.timestamp > new.timestamp
        where old.sub_id is null
        order by new.sub_id, new.timestamp desc
    );
end
$$ language plpgsql;
