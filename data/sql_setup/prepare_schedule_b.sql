-- Create index for join on electioneering costs
drop index if exists disclosure.nml_sched_b_link_id_idx;
create index nml_sched_b_link_id_idx on disclosure.nml_sched_b (link_id);

-- Create table to hold sub_ids of records that fail to process when the
-- Schedule B triggers are run so that they can be tried at a later time.
drop table if exists ofec_sched_b_nightly_retries;
create table ofec_sched_b_nightly_retries (
    sub_id numeric(19,0) not null primary key
);
create index on ofec_sched_b_nightly_retries (sub_id);


-- Remove any queue table remnants as they are no longer needed.
drop table if exists ofec_sched_b_queue_new;
drop table if exists ofec_sched_b_queue_old;


-- Support for processing of schedule B itemized records that need to be
-- retried.
-- Retry processing schedule B itemized records
create or replace function retry_processing_schedule_b_records(start_year integer) returns void as $$
declare
    timestamp timestamp = current_timestamp;
    two_year_transaction_period smallint;
    view_row fec_vsum_sched_b_vw%ROWTYPE;
    schedule_b_record record;
begin
    for schedule_b_record in select * from ofec_sched_b_nightly_retries loop
        select into view_row * from fec_vsum_sched_b_vw where sub_id = schedule_b_record.sub_id;

        if FOUND then
            two_year_transaction_period = get_transaction_year(view_row.contb_receipt_dt, view_row.rpt_yr);

            if two_year_transaction_period >= start_year then
                -- TODO:  Figure out how to get this in the right child table
                --        automatically.
                -- TODO:  Add the rest of the required SET component of the ON
                --        CONFLICT clause.
                insert into ofec_sched_b_master values (view_row.*, timestamp, two_year_transaction_period) on conflict (sub_id) do update;
                delete from ofec_sched_b_nightly_retries where sub_id = schedule_b_record.sub_id;
            end if;
        else
            raise notice 'sub_id % still not found', schedule_b_record.sub_id;
        end if;
    end loop;
end
$$ language plpgsql;


-- Create trigger method to monitor Schedule B records for inserts and updates.
-- These happen after a row is inserted/updated so that we can leverage
-- pulling the new record information from the view itself, which contains the
-- data in the structure that our tables expect it to be in.
create or replace function ofec_sched_b_upsert_record() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    timestamp timestamp = current_timestamp;
    two_year_transaction_period smallint;
    view_row fec_vsum_sched_b_vw%ROWTYPE;
begin
    select into view_row * from fec_vsum_sched_b_vw where sub_id = new.sub_id;

    -- Check to see if the resultset returned anything from the view.  If it
    -- did not, skip the processing of the record, otherwise we'll end up with
    -- a record full of NULL values.
    -- "FOUND" is a PL/pgSQL boolean variable set to false initially in any
    -- PL/pgSQL function and reset whenever certain statements are run, e.g.,
    -- a "SELECT INTO..." statement.  For more information, visit here:
    -- https://www.postgresql.org/docs/current/static/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS
    if FOUND then
        two_year_transaction_period = get_transaction_year(view_row.disb_dt, view_row.rpt_yr);

        -- TODO:  Do we still want this check?
        if two_year_transaction_period >= start_year then
            -- TODO:  Figure out how to get this in the right child table
            --        automatically.
            -- TODO:  Add the rest of the required SET component of the ON
            --        CONFLICT clause.
            insert into ofec_sched_b_master values (view_row.*, timestamp, two_year_transaction_period) on conflict (sub_id) do update;
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
create or replace function ofec_sched_b_delete_record() returns trigger as $$
begin
    delete from ofec_sched_b_master where sub_id = old.sub_id;
    return old;
end
$$ language plpgsql;


-- Drop old trigger if it exists
drop trigger if exists ofec_sched_b_queue_trigger on fec_vsum_sched_b_vw;


-- Create new triggers
drop trigger if exists nml_sched_b_after_trigger on disclosure.nml_sched_b;
create trigger nml_sched_b_after_trigger after insert or update
    on disclosure.nml_sched_b for each row execute procedure ofec_sched_b_upsert_record(:START_YEAR_AGGREGATE);

drop trigger if exists nml_sched_b_before_trigger on disclosure.nml_sched_b;
create trigger nml_sched_b_before_trigger before delete or update
    on disclosure.nml_sched_b for each row execute procedure ofec_sched_b_delete_record(:START_YEAR_AGGREGATE);


-- Create master table for Schedule B to be used for partitioning
-- Starts as a temporary table to be renamed later.  This will also drop any
-- child tables associated with it (likely from a failed repartition task).
-- drop table if exists ofec_sched_b_master_tmp cascade;
-- create table ofec_sched_b_master_tmp (
--     cmte_id character varying(9),
--     recipient_cmte_id character varying(9),
--     recipient_nm character varying(200),
--     payee_l_nm character varying(30),
--     payee_f_nm character varying(20),
--     payee_m_nm character varying(20),
--     payee_prefix character varying(10),
--     payee_suffix character varying(10),
--     payee_employer character varying(38),
--     payee_occupation character varying(38),
--     recipient_st1 character varying(34),
--     recipient_st2 character varying(34),
--     recipient_city character varying(30),
--     recipient_st character varying(2),
--     recipient_zip character varying(9),
--     disb_desc character varying(100),
--     catg_cd character varying(3),
--     catg_cd_desc character varying(40),
--     entity_tp character varying(3),
--     entity_tp_desc character varying(50),
--     election_tp character varying(5),
--     fec_election_tp_desc character varying(20),
--     fec_election_tp_year character varying(4),
--     election_tp_desc character varying(20),
--     cand_id character varying(9),
--     cand_nm character varying(90),
--     cand_nm_first character varying(38),
--     cand_nm_last character varying(38),
--     cand_m_nm character varying(20),
--     cand_prefix character varying(10),
--     cand_suffix character varying(10),
--     cand_office character varying(1),
--     cand_office_desc character varying(20),
--     cand_office_st character varying(2),
--     cand_office_st_desc character varying(20),
--     cand_office_district character varying(2),
--     disb_dt timestamp without time zone,
--     disb_amt numeric(14,2),
--     memo_cd character varying(1),
--     memo_cd_desc character varying(50),
--     memo_text character varying(100),
--     disb_tp character varying(3),
--     disb_tp_desc character varying(90),
--     conduit_cmte_nm character varying(200),
--     conduit_cmte_st1 character varying(34),
--     conduit_cmte_st2 character varying(34),
--     conduit_cmte_city character varying(30),
--     conduit_cmte_st character varying(2),
--     conduit_cmte_zip character varying(9),
--     national_cmte_nonfed_acct character varying(9),
--     ref_disp_excess_flg character varying(1),
--     comm_dt timestamp without time zone,
--     benef_cmte_nm character varying(200),
--     semi_an_bundled_refund numeric(14,2),
--     action_cd character varying(1),
--     action_cd_desc character varying(15),
--     tran_id character varying,
--     back_ref_tran_id character varying,
--     back_ref_sched_id character varying,
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
--     recipient_name_text tsvector,
--     disbursement_description_text tsvector,
--     disbursement_purpose_category character varying,
--     clean_recipient_cmte_id character varying,
--     two_year_transaction_period smallint
-- );
