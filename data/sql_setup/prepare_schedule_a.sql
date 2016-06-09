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
