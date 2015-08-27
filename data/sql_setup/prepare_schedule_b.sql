-- Create simple indices on filtered columns
create index on sched_b (rpt_yr) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b (image_num) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b (sched_b_sk) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b (recipient_st) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b (recipient_city) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b (recipient_cmte_id) where rpt_yr >= :START_YEAR_ITEMIZED;

-- Create composite indices on sortable columns
create index on sched_b(disb_dt, sched_b_sk) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b(disb_amt, sched_b_sk) where rpt_yr >= :START_YEAR_ITEMIZED;

-- Create composite indices on `cmte_id`; else filtering by committee can be very slow
-- TODO(jmcarp) Find a better solution
create index on sched_b (cmte_id, sched_b_sk) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b (cmte_id, disb_dt, sched_b_sk) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b (cmte_id, disb_amt, sched_b_sk) where rpt_yr >= :START_YEAR_ITEMIZED;

-- Create index for join on electioneering costs
create index on sched_b (link_id) where rpt_yr >= 2002;

-- Use smaller histogram bins on state column for faster queries on rare states (AS, PR)
alter table sched_b alter column recipient_st set statistics 1000;

-- Create Schedule B fulltext table
drop table if exists ofec_sched_b_fulltext;
create table ofec_sched_b_fulltext as
select
    sched_b_sk,
    to_tsvector(recipient_nm) as recipient_name_text,
    to_tsvector(disb_desc) as disbursement_description_text
from sched_b
where rpt_yr >= :START_YEAR_ITEMIZED
;

-- Create indices on filtered fulltext columns
alter table ofec_sched_b_fulltext add primary key (sched_b_sk);
create index on ofec_sched_b_fulltext using gin (recipient_name_text);
create index on ofec_sched_b_fulltext using gin (disbursement_description_text);

-- Analyze tables
analyze sched_b;
analyze ofec_sched_b_fulltext;

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
    on sched_b for each row execute procedure ofec_sched_b_update_queues(:START_YEAR_ITEMIZED)
;
