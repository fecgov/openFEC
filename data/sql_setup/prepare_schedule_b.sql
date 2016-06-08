-- Create Schedule B table
drop table if exists ofec_sched_b_tmp;
create table ofec_sched_b_tmp as
select
    *,
    cast(null as timestamp) as timestamp,
    image_pdf_url(image_num) as pdf_url,
    to_tsvector(recipient_nm) || to_tsvector(coalesce(clean_repeated(recipient_cmte_id, cmte_id), ''))
        as recipient_name_text,
    to_tsvector(disb_desc) as disbursement_description_text,
    disbursement_purpose(disb_tp, disb_desc) as disbursement_purpose_category,
    clean_repeated(recipient_cmte_id, cmte_id) as clean_recipient_cmte_id
from fec_vsum_sched_b
where rpt_yr >= :START_YEAR_ITEMIZED
;

alter table ofec_sched_b_tmp add primary key (sub_id);

-- Create simple indices on filtered columns
create index on ofec_sched_b_tmp (rpt_yr);
create index on ofec_sched_b_tmp (image_num);
create index on ofec_sched_b_tmp (sub_id);
create index on ofec_sched_b_tmp (recipient_st);
create index on ofec_sched_b_tmp (recipient_city);
create index on ofec_sched_b_tmp (clean_recipient_cmte_id);
create index on ofec_sched_b_tmp (disbursement_purpose_category);

-- Create composite indices on sortable columns
create index on ofec_sched_b_tmp (disb_dt, sub_id);
create index on ofec_sched_b_tmp (disb_amt, sub_id);

-- Create composite indices on `cmte_id`; else filtering by committee can be very slow
create index on ofec_sched_b_tmp (cmte_id, sub_id);
create index on ofec_sched_b_tmp (cmte_id, disb_dt, sub_id);
create index on ofec_sched_b_tmp (cmte_id, disb_amt, sub_id);

-- Create indices on fulltext columns
create index on ofec_sched_b_tmp using gin (recipient_name_text);
create index on ofec_sched_b_tmp using gin (disbursement_description_text);

-- Create index for join on electioneering costs
create index on fec_vsum_sched_b (link_id);

-- Use smaller histogram bins on state column for faster queries on rare states (AS, PR)
alter table ofec_sched_b_tmp alter column recipient_st set statistics 1000;

-- Analyze tables
analyze ofec_sched_b_tmp;

-- Create queue tables to hold changes to Schedule B
drop table if exists ofec_sched_b_queue_new;
drop table if exists ofec_sched_b_queue_old;
create table ofec_sched_b_queue_new as select * from fec_vsum_sched_b limit 0;
create table ofec_sched_b_queue_old as select * from fec_vsum_sched_b limit 0;
alter table ofec_sched_b_queue_new add column timestamp timestamp;
alter table ofec_sched_b_queue_old add column timestamp timestamp;
create index on ofec_sched_b_queue_new (sub_id);
create index on ofec_sched_b_queue_old (sub_id);
create index on ofec_sched_b_queue_new (timestamp);
create index on ofec_sched_b_queue_old (timestamp);

-- Create trigger to maintain Schedule B queues
create or replace function ofec_sched_b_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
begin
    if tg_op = 'INSERT' then
        if new.rpt_yr >= start_year then
            delete from ofec_sched_b_queue_new where sub_id = new.sub_id;
            insert into ofec_sched_b_queue_new values (new.*);
        end if;
        return new;
    elsif tg_op = 'UPDATE' then
        if new.rpt_yr >= start_year then
            delete from ofec_sched_b_queue_new where sub_id = new.sub_id;
            delete from ofec_sched_b_queue_old where sub_id = old.sub_id;
            insert into ofec_sched_b_queue_new values (new.*);
            insert into ofec_sched_b_queue_old values (old.*);
        end if;
        return new;
    elsif tg_op = 'DELETE' then
        if old.rpt_yr >= start_year then
            delete from ofec_sched_b_queue_old where sub_id = old.sub_id;
            insert into ofec_sched_b_queue_old values (old.*);
        end if;
        return old;
    end if;
end
$$ language plpgsql;

drop trigger if exists ofec_sched_b_queue_trigger on fec_vsum_sched_b;
create trigger ofec_sched_b_queue_trigger before insert or update or delete
    on fec_vsum_sched_b for each row execute procedure ofec_sched_b_update_queues(:START_YEAR_AGGREGATE)
;

drop table if exists ofec_sched_b;
alter table ofec_sched_b_tmp rename to ofec_sched_b;
