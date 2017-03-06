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

-- Create trigger to maintain Schedule A queues for inserts and updates
-- These happen after a row is inserted/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_b_insert_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    timestamp timestamp = current_timestamp;
    two_year_transaction_period_new smallint;
    two_year_transaction_period_old smallint;
    view_row fec_vsum_sched_b_vw%ROWTYPE;
begin
    if tg_op = 'INSERT' then
        select into view_row * from fec_vsum_sched_b_vw where sub_id = new.sub_id;
        two_year_transaction_period_new = get_transaction_year(new.disb_dt, view_row.rpt_yr);

        if two_year_transaction_period_new >= start_year then
            delete from ofec_sched_b_queue_new where sub_id = view_row.sub_id;
            insert into ofec_sched_b_queue_new values (view_row.*, timestamp, two_year_transaction_period_new);
        end if;

        return new;
    elsif tg_op = 'UPDATE' then
        select into view_row * from fec_vsum_sched_b_vw where sub_id = new.sub_id;

        two_year_transaction_period_new = get_transaction_year(new.disb_dt, view_row.rpt_yr);

        if two_year_transaction_period_new >= start_year then
            delete from ofec_sched_b_queue_new where sub_id = view_row.sub_id;
            insert into ofec_sched_b_queue_new values (view_row.*, timestamp, two_year_transaction_period_new);
        end if;

        return new;
    end if;
end
$$ language plpgsql;

-- Create trigger to maintain Schedule A queues deletes and updates
-- These happen before a row is removed/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_b_delete_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    timestamp timestamp = current_timestamp;
    two_year_transaction_period_new smallint;
    two_year_transaction_period_old smallint;
    view_row fec_vsum_sched_b_vw%ROWTYPE;
begin
    if tg_op = 'DELETE' then
    select into view_row * from fec_vsum_sched_b_vw where sub_id = old.sub_id;
        two_year_transaction_period_old = get_transaction_year(view_row.disb_dt, view_row.rpt_yr);

        if two_year_transaction_period_old >= start_year then
            delete from ofec_sched_b_queue_old where sub_id = view_row.sub_id;
            insert into ofec_sched_b_queue_old values (view_row.*, timestamp, two_year_transaction_period_old);
        end if;

        return old;
    elsif tg_op = 'UPDATE' then
        select into view_row * from fec_vsum_sched_b_vw where sub_id = old.sub_id;
        two_year_transaction_period_old = get_transaction_year(old.disb_dt, view_row.rpt_yr);

        if two_year_transaction_period_new >= start_year then
            delete from ofec_sched_b_queue_old where sub_id = view_row.sub_id;
            insert into ofec_sched_b_queue_old values (view_row.*, timestamp, two_year_transaction_period_old);
        end if;

        return new;
    end if;
end
$$ language plpgsql;

-- Drop old trigger if it exists
drop trigger if exists ofec_sched_b_queue_trigger on fec_vsum_sched_b_vw;

drop trigger if exists nml_sched_b_after_trigger on disclosure.nml_sched_b;
create trigger nml_sched_b_after_trigger after insert or update
    on disclosure.nml_sched_b for each row execute procedure ofec_sched_b_insert_update_queues(:START_YEAR_AGGREGATE);

drop trigger if exists nml_sched_b_before_trigger on disclosure.nml_sched_b;
create trigger nml_sched_b_before_trigger before delete or update
    on disclosure.nml_sched_b for each row execute procedure ofec_sched_b_delete_update_queues(:START_YEAR_AGGREGATE);
