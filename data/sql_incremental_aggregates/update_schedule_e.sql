create or replace function ofec_sched_e_update() returns void as $$
begin
    -- Drop all queued deletes
    delete from ofec_sched_e
    where sub_id = any(select sub_id from ofec_sched_e_queue_old)
    ;
    -- Insert all queued updates, unless a row with the same key exists in the
    -- delete queue with a later timestamp
    insert into ofec_sched_e (
        select
            new.*,
            image_pdf_url(new.image_num) as pdf_url,
            coalesce(new.rpt_tp, '') in ('24', '48') as is_notice,
            to_tsvector(new.pye_nm) as payee_name_text
        from ofec_sched_e_queue_new new
        left join ofec_sched_e_queue_old old on new.sub_id = old.sub_id and old.timestamp > new.timestamp
        where old.sub_id is null
        order by new.sub_id, new.timestamp desc
    );
end
$$ language plpgsql;
