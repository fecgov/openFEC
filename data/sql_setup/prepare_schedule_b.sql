-- Create Schedule B table
drop table if exists ofec_sched_b;
create table ofec_sched_b as
select
    *,
    to_tsvector(recipient_nm) as recipient_name_text,
    to_tsvector(disb_desc) as disbursement_description_text,
    disbursement_purpose(disb_tp, disb_desc) as disbursement_purpose_category
from sched_b
where rpt_yr >= :START_YEAR_ITEMIZED
;

alter table ofec_sched_b add primary key (sched_b_sk);

-- Create simple indices on filtered columns
create index on ofec_sched_b (rpt_yr);
create index on ofec_sched_b (image_num);
create index on ofec_sched_b (sched_b_sk);
create index on ofec_sched_b (recipient_st);
create index on ofec_sched_b (recipient_city);
create index on ofec_sched_b (recipient_cmte_id);

-- Create composite indices on sortable columns
create index on ofec_sched_b(disb_dt, sched_b_sk);
create index on ofec_sched_b(disb_amt, sched_b_sk);

-- Create composite indices on `cmte_id`; else filtering by committee can be very slow
create index on ofec_sched_b (cmte_id, sched_b_sk);
create index on ofec_sched_b (cmte_id, disb_dt, sched_b_sk);
create index on ofec_sched_b (cmte_id, disb_amt, sched_b_sk);

-- Create indices on fulltext columns
create index on ofec_sched_b using gin (recipient_name_text);
create index on ofec_sched_b using gin (disbursement_description_text);

-- Create index for join on electioneering costs
create index on sched_b (link_id);

-- Use smaller histogram bins on state column for faster queries on rare states (AS, PR)
alter table ofec_sched_b alter column recipient_st set statistics 1000;

-- Analyze tables
analyze ofec_sched_b;

-- Create queue tables to hold changes to Schedule B
drop table if exists ofec_sched_b_queue_new;
drop table if exists ofec_sched_b_queue_old;
create table ofec_sched_b_queue_new as select * from sched_b limit 0;
create table ofec_sched_b_queue_old as select * from sched_b limit 0;

-- Create trigger to maintain Schedule B queues
create or replace function ofec_sched_b_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
begin
    if tg_op = 'INSERT' then
        if new.rpt_yr >= start_year then
            insert into ofec_sched_b_queue_new
            values (new.*)
            ;
        end if;
        return new;
    elsif tg_op = 'UPDATE' then
        if new.rpt_yr >= start_year then
            insert into ofec_sched_b_queue_new
            values (new.*)
            ;
            insert into ofec_sched_b_queue_old
            values (old.*)
            ;
        end if;
        return new;
    elsif tg_op = 'DELETE' then
        if old.rpt_yr >= start_year then
            insert into ofec_sched_b_queue_old
            values (old.*)
            ;
        end if;
        return old;
    end if;
end
$$ language plpgsql;

drop trigger if exists ofec_sched_b_queue_trigger on sched_b;
create trigger ofec_sched_b_queue_trigger before insert or update or delete
    on sched_b for each row execute procedure ofec_sched_b_update_queues(:START_YEAR_AGGREGATE)
;
