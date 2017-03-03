-- Create index for join on electioneering costs
drop index if exists disclosure.nml_sched_b_link_id_idx;
create index nml_sched_b_link_id_idx on disclosure.nml_sched_b (link_id);

-- Create queue tables to hold changes to Schedule B
drop table if exists ofec_sched_b_queue_new;
drop table if exists ofec_sched_b_queue_old;
create table ofec_sched_b_queue_new as select * from fec_vsum_sched_b_vw limit 0;
create table ofec_sched_b_queue_old as select * from fec_vsum_sched_b_vw limit 0;
alter table ofec_sched_b_queue_new add column timestamp timestamp;
alter table ofec_sched_b_queue_old add column timestamp timestamp;
alter table ofec_sched_b_queue_new add column two_year_transaction_period smallint;
alter table ofec_sched_b_queue_old add column two_year_transaction_period smallint;
create index on ofec_sched_b_queue_new (sub_id);
create index on ofec_sched_b_queue_old (sub_id);
create index on ofec_sched_b_queue_new (timestamp);
create index on ofec_sched_b_queue_old (timestamp);
create index on ofec_sched_b_queue_new (two_year_transaction_period);
create index on ofec_sched_b_queue_old (two_year_transaction_period);

drop table if exists ofec_nml_sched_b_queue_new;
drop table if exists ofec_nml_sched_b_queue_old;

create table ofec_nml_sched_b_queue_new as select * from disclosure.nml_sched_b limit 0;
create table ofec_nml_sched_b_queue_old as select * from disclosure.nml_sched_b limit 0;

-- Create trigger to maintain Schedule B queues
create or replace function ofec_sched_b_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    timestamp timestamp = current_timestamp;
    two_year_transaction_period_new smallint;
    two_year_transaction_period_old smallint;
begin
    if tg_op = 'INSERT' then
        two_year_transaction_period_new = get_transaction_year(new.disb_dt, new.rpt_yr);

        if two_year_transaction_period_new >= start_year then
            delete from ofec_sched_b_queue_new where sub_id = new.sub_id;
            insert into ofec_sched_b_queue_new values (new.*, timestamp, two_year_transaction_period_new);
        end if;

        return new;
    elsif tg_op = 'UPDATE' then
        two_year_transaction_period_new = get_transaction_year(new.disb_dt, new.rpt_yr);
        two_year_transaction_period_old = get_transaction_year(old.disb_dt, old.rpt_yr);

        if two_year_transaction_period_new >= start_year then
            delete from ofec_sched_b_queue_new where sub_id = new.sub_id;
            delete from ofec_sched_b_queue_old where sub_id = old.sub_id;
            insert into ofec_sched_b_queue_new values (new.*, timestamp, two_year_transaction_period_new);
            insert into ofec_sched_b_queue_old values (old.*, timestamp, two_year_transaction_period_old);
        end if;

        return new;
    elsif tg_op = 'DELETE' then
        two_year_transaction_period_old = get_transaction_year(old.disb_dt, old.rpt_yr);

        if two_year_transaction_period_old >= start_year then
            delete from ofec_sched_b_queue_old where sub_id = old.sub_id;
            insert into ofec_sched_b_queue_old values (old.*, timestamp, two_year_transaction_period_old);
        end if;

        return old;
    end if;
end
$$ language plpgsql;

-- Create trigger to help test the schedule B source data
create or replace function ofec_sched_b_update_source_queues() returns trigger as $$
begin

    if tg_op = 'INSERT' then
        delete from ofec_nml_sched_b_queue_new where sub_id = new.sub_id;
        insert into ofec_nml_sched_b_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from ofec_nml_sched_b_queue_new where sub_id = new.sub_id;
        delete from ofec_nml_sched_b_queue_old where sub_id = old.sub_id;
        insert into ofec_nml_sched_b_queue_new values (new.*);
        insert into ofec_nml_sched_b_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from ofec_nml_sched_b_queue_old where sub_id = old.sub_id;
        insert into ofec_nml_sched_b_queue_old values (old.*);
        return old;
    end if;
end
$$ language plpgsql;

drop trigger if exists ofec_sched_b_queue_trigger on fec_vsum_sched_b_vw;
create trigger ofec_sched_b_queue_trigger instead of insert or update or delete
    on fec_vsum_sched_b_vw for each row execute procedure ofec_sched_b_update_queues(:START_YEAR_AGGREGATE);

drop trigger if exists nml_sched_b_trigger on disclosure.nml_sched_b;
create trigger nml_sched_b_trigger before insert or update or delete
    on disclosure.nml_sched_b for each row execute procedure ofec_sched_b_update_source_queues();
