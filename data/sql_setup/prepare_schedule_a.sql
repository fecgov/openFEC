-- Drop the old nightly refresh retry table and function if they still exist.
drop table if exists ofec_sched_a_nightly_retries;
drop function if exists retry_processing_schedule_a_records(start_year integer);

-- Drop the old queues if they still exist.
drop table if exists ofec_sched_a_queue_new;
drop table if exists ofec_sched_a_queue_old;


-- Create queue tables to hold changes to Schedule A
drop table if exists ofec_sched_a_queue_new;
drop table if exists ofec_sched_a_queue_old;
create table ofec_sched_a_queue_new as select * from fec_fitem_sched_a_vw limit 0;
create table ofec_sched_a_queue_old as select * from fec_fitem_sched_a_vw limit 0;
alter table ofec_sched_a_queue_new add column timestamp timestamp;
alter table ofec_sched_a_queue_old add column timestamp timestamp;
alter table ofec_sched_a_queue_new add column two_year_transaction_period smallint;
alter table ofec_sched_a_queue_old add column two_year_transaction_period smallint;
create index on ofec_sched_a_queue_new (sub_id);
create index on ofec_sched_a_queue_old (sub_id);
create index on ofec_sched_a_queue_new (timestamp);
create index on ofec_sched_a_queue_old (timestamp);
create index on ofec_sched_a_queue_new (two_year_transaction_period);
create index on ofec_sched_a_queue_old (two_year_transaction_period);

-- Create trigger to maintain Schedule A queues for inserts and updates
-- These happen after a row is inserted/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_a_insert_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    view_row fec_fitem_sched_a_vw%ROWTYPE;
begin
    select into view_row * from fec_fitem_sched_a_vw where sub_id = new.sub_id;

    -- Check to see if the resultset returned anything from the view.  If
    -- it did not, skip the processing of the record, otherwise we'll end
    -- up with a record full of NULL values.
    -- "FOUND" is a PL/pgSQL boolean variable set to false initially in
    -- any PL/pgSQL function and reset whenever certain statements are
    -- run, e.g., a "SELECT INTO..." statement.  For more information,
    -- visit here:
    -- https://www.postgresql.org/docs/current/static/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS
    if FOUND then
        if view_row.election_cycle >= start_year then
            delete from ofec_sched_a_queue_new where sub_id = view_row.sub_id;
            insert into ofec_sched_a_queue_new values (view_row.*, current_timestamp, view_row.election_cycle);
        end if;
    end if;

    RETURN NULL; -- result is ignored since this is an AFTER trigger
end
$$ language plpgsql;


-- Create trigger to maintain Schedule A queues deletes and updates
-- These happen before a row is removed/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_a_delete_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    view_row fec_fitem_sched_a_vw%ROWTYPE;
begin
        select into view_row * from fec_fitem_sched_a_vw where sub_id = old.sub_id;

        -- Check to see if the resultset returned anything from the view.  If
        -- it did not, skip the processing of the record, otherwise we'll end
        -- up with a record full of NULL values.
        -- "FOUND" is a PL/pgSQL boolean variable set to false initially in
        -- any PL/pgSQL function and reset whenever certain statements are
        -- run, e.g., a "SELECT INTO..." statement.  For more information,
        -- visit here:
        -- https://www.postgresql.org/docs/current/static/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS
        if FOUND then
            if view_row.election_cycle >= start_year then
                delete from ofec_sched_a_queue_old where sub_id = view_row.sub_id;
                insert into ofec_sched_a_queue_old values (view_row.*, current_timestamp, view_row.election_cycle);
            end if;
        end if;

    if tg_op = 'DELETE' then
        return old;
    elsif tg_op = 'UPDATE' then
        -- We have to return new here because this record is intended to change
        -- with an update.
        return new;
    end if;
end
$$ language plpgsql;


-- Create new triggers
drop trigger if exists nml_sched_a_after_trigger on disclosure.nml_sched_a;
create trigger nml_sched_a_after_trigger after insert or update
    on disclosure.nml_sched_a for each row execute procedure ofec_sched_a_insert_update_queues(:START_YEAR_AGGREGATE);

drop trigger if exists nml_sched_a_before_trigger on disclosure.nml_sched_a;
create trigger nml_sched_a_before_trigger before delete or update
    on disclosure.nml_sched_a for each row execute procedure ofec_sched_a_delete_update_queues(:START_YEAR_AGGREGATE);

drop trigger if exists f_item_sched_a_after_trigger on disclosure.f_item_receipt_or_exp;
create trigger f_item_sched_a_after_trigger after insert or update
    on disclosure.f_item_receipt_or_exp for each row execute procedure ofec_sched_a_insert_update_queues(:START_YEAR_AGGREGATE);

drop trigger if exists f_item_sched_a_before_trigger on disclosure.f_item_receipt_or_exp;
create trigger f_item_sched_a_before_trigger before delete or update
    on disclosure.f_item_receipt_or_exp for each row execute procedure ofec_sched_a_delete_update_queues(:START_YEAR_AGGREGATE);
