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


-- Create master table for Schedule A to be used for partitioning
-- Starts as a temporary table to be renamed later.  This will also drop any
-- child tables associated with it (likely from a failed repartition task).
-- drop table if exists ofec_sched_a_master_tmp cascade;
-- create table ofec_sched_a_master_tmp (
--     cmte_id character varying(9),
--     cmte_nm character varying(200),
--     contbr_id character varying(9),
--     contbr_nm character varying(200),
--     contbr_nm_first character varying(38),
--     contbr_m_nm character varying(20),
--     contbr_nm_last character varying(38),
--     contbr_prefix character varying(10),
--     contbr_suffix character varying(10),
--     contbr_st1 character varying(34),
--     contbr_st2 character varying(34),
--     contbr_city character varying(30),
--     contbr_st character varying(2),
--     contbr_zip character varying(9),
--     entity_tp character varying(3),
--     entity_tp_desc character varying(50),
--     contbr_employer character varying(38),
--     contbr_occupation character varying(38),
--     election_tp character varying(5),
--     fec_election_tp_desc character varying(20),
--     fec_election_yr character varying(4),
--     election_tp_desc character varying(20),
--     contb_aggregate_ytd numeric(14,2),
--     contb_receipt_dt timestamp without time zone,
--     contb_receipt_amt numeric(14,2),
--     receipt_tp character varying(3),
--     receipt_tp_desc character varying(90),
--     receipt_desc character varying(100),
--     memo_cd character varying(1),
--     memo_cd_desc character varying(50),
--     memo_text character varying(100),
--     cand_id character varying(9),
--     cand_nm character varying(90),
--     cand_nm_first character varying(38),
--     cand_m_nm character varying(20),
--     cand_nm_last character varying(38),
--     cand_prefix character varying(10),
--     cand_suffix character varying(10),
--     cand_office character varying(1),
--     cand_office_desc character varying(20),
--     cand_office_st character varying(2),
--     cand_office_st_desc character varying(20),
--     cand_office_district character varying(2),
--     conduit_cmte_id character varying(9),
--     conduit_cmte_nm character varying(200),
--     conduit_cmte_st1 character varying(34),
--     conduit_cmte_st2 character varying(34),
--     conduit_cmte_city character varying(30),
--     conduit_cmte_st character varying(2),
--     conduit_cmte_zip character varying(9),
--     donor_cmte_nm character varying(200),
--     national_cmte_nonfed_acct character varying(9),
--     increased_limit character varying(1),
--     action_cd character varying(1),
--     action_cd_desc character varying(15),
--     tran_id character varying,
--     back_ref_tran_id character varying,
--     back_ref_sched_nm character varying(8),
--     schedule_type character varying(2),
--     schedule_type_desc character varying(90),
--     line_num character varying(12),
--     image_num character varying(18),
--     file_num numeric(7,0),
--     link_id numeric(19,0),
--     orig_sub_id numeric(19,0),
--     sub_id numeric(19,0),
--     filing_form character varying(8),
--     rpt_tp character varying(3),
--     rpt_yr numeric(4,0),
--     election_cycle numeric,
--     "timestamp" timestamp without time zone,
--     pg_date timestamp without time zone,
--     pdf_url text,
--     contributor_name_text tsvector,
--     contributor_employer_text tsvector,
--     contributor_occupation_text tsvector,
--     is_individual boolean,
--     clean_contbr_id character varying,
--     two_year_transaction_period smallint
-- );
