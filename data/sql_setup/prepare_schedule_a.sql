-- Create table to hold sub_ids of records that fail to process when the
-- Schedule A triggers are run so that they can be tried at a later time.
drop table if exists ofec_sched_a_nightly_retries;
create table ofec_sched_a_nightly_retries (
    sub_id numeric(19,0) not null primary key
);
create index on ofec_sched_a_nightly_retries (sub_id);

-- Remove any queue table remnants as they are no longer needed.
drop table if exists ofec_sched_a_queue_new;
drop table if exists ofec_sched_a_queue_old;


-- Support for processing of schedule A itemized records that need to be
-- retried.
create or replace function retry_processing_schedule_a_records(start_year integer) returns void as $$
declare
    timestamp timestamp = current_timestamp;
    two_year_transaction_period smallint;
    view_row fec_vsum_sched_a_vw%ROWTYPE;
    schedule_a_record record;
begin
    for schedule_a_record in select * from ofec_sched_a_nightly_retries loop
        select into view_row * from fec_vsum_sched_a_vw where sub_id = schedule_a_record.sub_id;

        if FOUND then
            two_year_transaction_period = get_transaction_year(view_row.contb_receipt_dt, view_row.rpt_yr);

            if two_year_transaction_period >= start_year then
                -- TODO:  Figure out how to get this in the right child table
                --        automatically.
                -- TODO:  Add the rest of the required SET component of the ON
                --        CONFLICT clause.
                insert into ofec_sched_a_master values (view_row.*, timestamp, two_year_transaction_period) on conflict (sub_id) do update;
                delete from ofec_sched_a_nightly_retries where sub_id = schedule_a_record.sub_id;
            end if;
        else
            raise notice 'sub_id % still not found', schedule_a_record.sub_id;
        end if;
    end loop;
end
$$ language plpgsql;


-- Create trigger method to monitor Schedule A records for inserts and updates.
-- These happen after a row is inserted/updated so that we can leverage
-- pulling the new record information from the view itself, which contains the
-- data in the structure that our tables expect it to be in.
create or replace function ofec_sched_a_upsert_record() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    timestamp timestamp = current_timestamp;
    two_year_transaction_period smallint;
    view_row fec_vsum_sched_a_vw%ROWTYPE;
begin
    select into view_row * from fec_vsum_sched_a_vw where sub_id = new.sub_id;

    -- Check to see if the resultset returned anything from the view.  If it
    -- did not, skip the processing of the record, otherwise we'll end up with
    -- a record full of NULL values.
    -- "FOUND" is a PL/pgSQL boolean variable set to false initially in any
    -- PL/pgSQL function and reset whenever certain statements are run, e.g.,
    -- a "SELECT INTO..." statement.  For more information, visit here:
    -- https://www.postgresql.org/docs/current/static/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS
    if FOUND then
        two_year_transaction_period = get_transaction_year(new.contb_receipt_dt, view_row.rpt_yr);

        -- TODO:  Do we still want this check?
        if two_year_transaction_period >= start_year then
            -- TODO:  Figure out how to get this in the right child table
            --        automatically.
            -- TODO:  Add the rest of the required SET component of the ON
            --        CONFLICT clause.
            insert into ofec_sched_a_master values (view_row.*, timestamp, two_year_transaction_period) on conflict (sub_id) do update;
        end if;
    else
        -- We weren't able to successfully retrieve a row from the view, so
        -- keep track of this sub_id to try processing it again each night
        -- until we're able to successfully process it.
        insert into ofec_sched_a_nightly_retries values (new.sub_id) on conflict do nothing;
    end if;

    return new;
end
$$ language plpgsql;


-- Create trigger method to remove deleted Schedule A data
create or replace function ofec_sched_a_delete_record() returns trigger as $$
begin
    -- TODO:  Figure out how to get this in the right child table
    --        automatically.
    delete from ofec_sched_a_master where sub_id = old.sub_id;
    return old;
end
$$ language plpgsql;


-- Drop old trigger if it exists
drop trigger if exists ofec_sched_a_queue_trigger on fec_vsum_sched_a_vw;


-- Create new triggers
drop trigger if exists nml_sched_a_after_trigger on disclosure.nml_sched_a;
create trigger nml_sched_a_after_trigger after insert or update
    on disclosure.nml_sched_a for each row execute procedure ofec_sched_a_upsert_record(:START_YEAR_AGGREGATE);

drop trigger if exists nml_sched_a_before_trigger on disclosure.nml_sched_a;
create trigger nml_sched_a_before_trigger before delete
    on disclosure.nml_sched_a for each row execute procedure ofec_sched_a_delete_record(:START_YEAR_AGGREGATE);
