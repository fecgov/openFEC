-- Create index for join on electioneering costs
create index on sched_b (link_id);

-- Create queue tables to hold changes to Schedule B
drop table if exists ofec_sched_b_queue_new;
drop table if exists ofec_sched_b_queue_old;
create table ofec_sched_b_queue_new as select * from sched_b limit 0;
create table ofec_sched_b_queue_old as select * from sched_b limit 0;
alter table ofec_sched_b_queue_new add column timestamp timestamp;
alter table ofec_sched_b_queue_old add column timestamp timestamp;
create index on ofec_sched_b_queue_new (sched_b_sk);
create index on ofec_sched_b_queue_old (sched_b_sk);
create index on ofec_sched_b_queue_new (timestamp);
create index on ofec_sched_b_queue_old (timestamp);

-- Create trigger to maintain Schedule B queues
create or replace function ofec_sched_b_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
begin
    if tg_op = 'INSERT' then
        if new.rpt_yr >= start_year then
            delete from ofec_sched_b_queue_new where sched_b_sk = new.sched_b_sk;
            insert into ofec_sched_b_queue_new values (new.*);
        end if;
        return new;
    elsif tg_op = 'UPDATE' then
        if new.rpt_yr >= start_year then
            delete from ofec_sched_b_queue_new where sched_b_sk = new.sched_b_sk;
            delete from ofec_sched_b_queue_old where sched_b_sk = old.sched_b_sk;
            insert into ofec_sched_b_queue_new values (new.*);
            insert into ofec_sched_b_queue_old values (old.*);
        end if;
        return new;
    elsif tg_op = 'DELETE' then
        if old.rpt_yr >= start_year then
            delete from ofec_sched_b_queue_old where sched_b_sk = old.sched_b_sk;
            insert into ofec_sched_b_queue_old values (old.*);
        end if;
        return old;
    end if;
end
$$ language plpgsql;

drop trigger if exists ofec_sched_b_queue_trigger on sched_b;
create trigger ofec_sched_b_queue_trigger before insert or update or delete
    on sched_b for each row execute procedure ofec_sched_b_update_queues(:START_YEAR_AGGREGATE)
;
