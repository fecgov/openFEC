create or replace function ofec_sched_a_update() returns void as $$
begin
    delete from ofec_sched_a
    where sched_a_sk = any(select sched_a_sk from ofec_sched_a_queue_old)
    ;
    insert into ofec_sched_a(
        select
            *,
            to_tsvector(contbr_nm) as contributor_name_text,
            to_tsvector(contbr_employer) as contributor_employer_text,
            to_tsvector(contbr_occupation) as contributor_occupation_text,
            is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text)
                as is_individual
        from ofec_sched_a_queue_new
    );
end
$$ language plpgsql;
