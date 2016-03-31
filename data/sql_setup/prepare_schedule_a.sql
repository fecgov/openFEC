-- Create Schedule A table
drop table if exists ofec_sched_a_tmp;
create table ofec_sched_a_tmp as
select
    *,
    cast(null as timestamp) as timestamp,
    image_pdf_url(image_num) as pdf_url,
    to_tsvector(contbr_nm) || to_tsvector(coalesce(contbr_id, ''))
        as contributor_name_text,
    to_tsvector(contbr_employer) as contributor_employer_text,
    to_tsvector(contbr_occupation) as contributor_occupation_text,
    is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text)
        as is_individual,
    clean_repeated(contbr_id, cmte_id) as clean_contbr_id
from sched_a
where rpt_yr >= :START_YEAR_ITEMIZED
;

alter table ofec_sched_a_tmp add primary key (sched_a_sk);

-- Create simple indices on filtered columns
create index on ofec_sched_a_tmp (rpt_yr);
create index on ofec_sched_a_tmp (entity_tp);
create index on ofec_sched_a_tmp (image_num);
create index on ofec_sched_a_tmp (sched_a_sk);
create index on ofec_sched_a_tmp (contbr_st);
create index on ofec_sched_a_tmp (contbr_city);
create index on ofec_sched_a_tmp (is_individual);
create index on ofec_sched_a_tmp (clean_contbr_id);

-- Create composite indices on sortable columns
create index on ofec_sched_a_tmp (contb_receipt_dt, sched_a_sk);
create index on ofec_sched_a_tmp (contb_receipt_amt, sched_a_sk);
create index on ofec_sched_a_tmp (contb_aggregate_ytd, sched_a_sk);

-- Create composite indices on `cmte_id`; else filtering by committee can be very slow
create index on ofec_sched_a_tmp (cmte_id, sched_a_sk);
create index on ofec_sched_a_tmp (cmte_id, contb_receipt_dt, sched_a_sk);
create index on ofec_sched_a_tmp (cmte_id, contb_receipt_amt, sched_a_sk);
create index on ofec_sched_a_tmp (cmte_id, contb_aggregate_ytd, sched_a_sk);

-- Create indices on filtered fulltext columns
create index on ofec_sched_a_tmp using gin (contributor_name_text);
create index on ofec_sched_a_tmp using gin (contributor_employer_text);
create index on ofec_sched_a_tmp using gin (contributor_occupation_text);

-- Use smaller histogram bins on state column for faster queries on rare states (AS, PR)
alter table ofec_sched_a_tmp alter column contbr_st set statistics 1000;

-- Analyze tables
analyze ofec_sched_a_tmp;

-- Create queue tables to hold changes to Schedule A
drop table if exists ofec_sched_a_queue_new;
drop table if exists ofec_sched_a_queue_old;
create table ofec_sched_a_queue_new as select * from sched_a limit 0;
create table ofec_sched_a_queue_old as select * from sched_a limit 0;
alter table ofec_sched_a_queue_new add column timestamp timestamp;
alter table ofec_sched_a_queue_old add column timestamp timestamp;
create index on ofec_sched_a_queue_new (sched_a_sk);
create index on ofec_sched_a_queue_old (sched_a_sk);
create index on ofec_sched_a_queue_new (timestamp);
create index on ofec_sched_a_queue_old (timestamp);

-- Create trigger to maintain Schedule A queues
create or replace function ofec_sched_a_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    timestamp timestamp = current_timestamp;
begin
    if tg_op = 'INSERT' then
        if new.rpt_yr >= start_year then
            insert into ofec_sched_a_queue_new values (new.*, timestamp);
        end if;
        return new;
    elsif tg_op = 'UPDATE' then
        if new.rpt_yr >= start_year then
            insert into ofec_sched_a_queue_new values (new.*, timestamp);
            insert into ofec_sched_a_queue_old values (old.*, timestamp);
        end if;
        return new;
    elsif tg_op = 'DELETE' then
        if old.rpt_yr >= start_year then
            insert into ofec_sched_a_queue_old values (old.*, timestamp);
        end if;
        return old;
    end if;
end
$$ language plpgsql;

drop trigger if exists ofec_sched_a_queue_trigger on sched_a;
create trigger ofec_sched_a_queue_trigger before insert or update or delete
    on sched_a for each row execute procedure ofec_sched_a_update_queues(:START_YEAR_AGGREGATE)
;

drop table if exists ofec_sched_a;
alter table ofec_sched_a_tmp rename to ofec_sched_a;
