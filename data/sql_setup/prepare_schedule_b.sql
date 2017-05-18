-- Create index for join on electioneering costs
drop index if exists disclosure.nml_sched_b_link_id_idx;
create index nml_sched_b_link_id_idx on disclosure.nml_sched_b (link_id);

-- Create table to hold sub_ids of records that fail during the nightly
-- processing so that they can be tried at a later time.
-- The "action" column denotes what should happen with the record:
--    insert, update, or delete
drop table if exists ofec_sched_b_nightly_retries;
create table ofec_sched_b_nightly_retries (
    sub_id numeric(19,0) not null primary key,
    action varchar(6) not null
);
create index on ofec_sched_b_nightly_retries (sub_id);

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


-- Support for processing of schedule A itemized records that need to be
-- retried.
-- Retry processing schedule A itemized records
create or replace function retry_processing_schedule_b_records(start_year integer) returns void as $$
declare
    timestamp timestamp = current_timestamp;
    two_year_transaction_period smallint;
    view_row fec_vsum_sched_b_vw%ROWTYPE;
    schedule_b_record record;
begin
    for schedule_b_record in select * from ofec_sched_b_nightly_retries loop
        select into view_row * from fec_vsum_sched_b_vw where sub_id = schedule_b_record.sub_id;

        if found then
            two_year_transaction_period = get_transaction_year(view_row.disb_dt, view_row.rpt_yr);

            if two_year_transaction_period >= start_year then
                -- Determine which queue(s) the found record should go into.
                case schedule_b_record.action
                    when 'insert' then
                        delete from ofec_sched_b_queue_new where sub_id = view_row.sub_id;
                        insert into ofec_sched_b_queue_new values (view_row.*, timestamp, two_year_transaction_period);

                        delete from ofec_sched_b_nightly_retries where sub_id = schedule_b_record.sub_id;
                    when 'delete' then
                        delete from ofec_sched_b_queue_old where sub_id = view_row.sub_id;
                        insert into ofec_sched_b_queue_old values (view_row.*, timestamp, two_year_transaction_period);

                        delete from ofec_sched_b_nightly_retries where sub_id = schedule_b_record.sub_id;
                    when 'update' then
                        delete from ofec_sched_b_queue_new where sub_id = view_row.sub_id;
                        delete from ofec_sched_b_queue_old where sub_id = view_row.sub_id;
                        insert into ofec_sched_b_queue_new values (view_row.*, timestamp, two_year_transaction_period);
                        insert into ofec_sched_b_queue_old values (view_row.*, timestamp, two_year_transaction_period);

                        delete from ofec_sched_b_nightly_retries where sub_id = schedule_b_record.sub_id;
                    else
                        raise warning 'Invalid action supplied, record not processed: %', schedule_b_record.action;
                end case;
            end if;
        else
            raise notice 'sub_id % still not found', schedule_b_record.sub_id;
        end if;
    end loop;
end
$$ language plpgsql;


-- Create trigger to maintain Schedule A queues for inserts and updates
-- These happen after a row is inserted/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_b_insert_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    timestamp timestamp = current_timestamp;
    two_year_transaction_period smallint;
    view_row fec_vsum_sched_b_vw%ROWTYPE;
begin
    if tg_op = 'INSERT' then
        select into view_row * from fec_vsum_sched_b_vw where sub_id = new.sub_id;

        -- Check to see if the resultset returned anything from the view.  If
        -- it did not, skip the processing of the record, otherwise we'll end
        -- up with a record full of NULL values.
        -- "FOUND" is a PL/pgSQL boolean variable set to false initially in
        -- any PL/pgSQL function and reset whenever certain statements are
        -- run, e.g., a "SELECT INTO..." statement.  For more information,
        -- visit here:
        -- https://www.postgresql.org/docs/current/static/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS
        if FOUND then
            two_year_transaction_period = get_transaction_year(new.disb_dt, view_row.rpt_yr);

            if two_year_transaction_period >= start_year then
                delete from ofec_sched_b_queue_new where sub_id = view_row.sub_id;
                insert into ofec_sched_b_queue_new values (view_row.*, timestamp, two_year_transaction_period);
            end if;
        else
            -- We weren't able to successfully retrieve a row from the view,
            -- so keep track of this sub_id if we haven't already so we can
            -- try processing it again each night until we're able to
            -- successfully process it.
            raise notice 'sub_id % not found, adding to secondary queue.', new.sub_id;

            delete from ofec_sched_b_nightly_retries where sub_id = new.sub_id;
            insert into ofec_sched_b_nightly_retries values (new.sub_id, 'insert');
        end if;

        return new;
    elsif tg_op = 'UPDATE' then
        select into view_row * from fec_vsum_sched_b_vw where sub_id = new.sub_id;

        if FOUND then
            two_year_transaction_period = get_transaction_year(new.disb_dt, view_row.rpt_yr);

            if two_year_transaction_period >= start_year then
                delete from ofec_sched_b_queue_new where sub_id = view_row.sub_id;
                insert into ofec_sched_b_queue_new values (view_row.*, timestamp, two_year_transaction_period);
            end if;
        else
            -- We weren't able to successfully retrieve a row from the view,
            -- so keep track of this sub_id if we haven't already so we can
            -- try processing it again each night until we're able to
            -- successfully process it.
            raise notice 'sub_id % not found, adding to secondary queue.', new.sub_id;

            delete from ofec_sched_b_nightly_retries where sub_id = new.sub_id;
            insert into ofec_sched_b_nightly_retries values (new.sub_id, 'update');
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
    two_year_transaction_period smallint;
    view_row fec_vsum_sched_b_vw%ROWTYPE;
begin
    if tg_op = 'DELETE' then
        select into view_row * from fec_vsum_sched_b_vw where sub_id = old.sub_id;

        -- Check to see if the resultset returned anything from the view.  If
        -- it did not, skip the processing of the record, otherwise we'll end
        -- up with a record full of NULL values.
        -- "FOUND" is a PL/pgSQL boolean variable set to false initially in
        -- any PL/pgSQL function and reset whenever certain statements are
        -- run, e.g., a "SELECT INTO..." statement.  For more information,
        -- visit here:
        -- https://www.postgresql.org/docs/current/static/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS
        if FOUND then
            two_year_transaction_period = get_transaction_year(view_row.disb_dt, view_row.rpt_yr);

            if two_year_transaction_period >= start_year then
                delete from ofec_sched_b_queue_old where sub_id = view_row.sub_id;
                insert into ofec_sched_b_queue_old values (view_row.*, timestamp, two_year_transaction_period);
            end if;
        else
            -- We weren't able to successfully retrieve a row from the view,
            -- so keep track of this sub_id if we haven't already so we can
            -- try processing it again each night until we're able to
            -- successfully process it.
            raise notice 'sub_id % not found, adding to secondary queue.', old.sub_id;

            delete from ofec_sched_b_nightly_retries where sub_id = old.sub_id;
            insert into ofec_sched_b_nightly_retries values (old.sub_id, 'delete');
        end if;

        return old;
    elsif tg_op = 'UPDATE' then
        select into view_row * from fec_vsum_sched_b_vw where sub_id = old.sub_id;

        if FOUND then
            two_year_transaction_period = get_transaction_year(old.disb_dt, view_row.rpt_yr);

            if two_year_transaction_period >= start_year then
                delete from ofec_sched_b_queue_old where sub_id = view_row.sub_id;
                insert into ofec_sched_b_queue_old values (view_row.*, timestamp, two_year_transaction_period);
            end if;
        else
            -- We weren't able to successfully retrieve a row from the view,
            -- so keep track of this sub_id if we haven't already so we can
            -- try processing it again each night until we're able to
            -- successfully process it.
            raise notice 'sub_id % not found, adding to secondary queue.', old.sub_id;

            delete from ofec_sched_b_nightly_retries where sub_id = old.sub_id;
            insert into ofec_sched_b_nightly_retries values (old.sub_id, 'update');
        end if;

        # We have to return new here because this record is intended to change
        # with an update.
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
