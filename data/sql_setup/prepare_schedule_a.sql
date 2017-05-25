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
                insert into ofec_sched_a_master (
                    cmte_id,
                    cmte_nm,
                    contbr_id,
                    contbr_nm,
                    contbr_nm_first,
                    contbr_m_nm,
                    contbr_nm_last,
                    contbr_prefix,
                    contbr_suffix,
                    contbr_st1,
                    contbr_st2,
                    contbr_city,
                    contbr_st,
                    contbr_zip,
                    entity_tp,
                    entity_tp_desc,
                    contbr_employer,
                    contbr_occupation,
                    election_tp,
                    fec_election_tp_desc,
                    fec_election_yr,
                    election_tp_desc,
                    contb_aggregate_ytd,
                    contb_receipt_dt,
                    contb_receipt_amt,
                    receipt_tp,
                    receipt_tp_desc,
                    receipt_desc,
                    memo_cd,
                    memo_cd_desc,
                    memo_text,
                    cand_id,
                    cand_nm,
                    cand_nm_first,
                    cand_m_nm,
                    cand_nm_last,
                    cand_prefix,
                    cand_suffix,
                    cand_office,
                    cand_office_desc,
                    cand_office_st,
                    cand_office_st_desc,
                    cand_office_district,
                    conduit_cmte_id,
                    conduit_cmte_nm,
                    conduit_cmte_st1,
                    conduit_cmte_st2,
                    conduit_cmte_city,
                    conduit_cmte_st,
                    conduit_cmte_zip,
                    donor_cmte_nm,
                    national_cmte_nonfed_acct,
                    increased_limit,
                    action_cd,
                    action_cd_desc,
                    tran_id,
                    back_ref_tran_id,
                    back_ref_sched_nm,
                    schedule_type_desc,
                    line_num,
                    image_num,
                    file_num,
                    link_id,
                    orig_sub_id,
                    sub_id,
                    filing_form,
                    rpt_tp,
                    rpt_yr,
                    election_cycle,
                    timestamp,
                    two_year_transaction_period,
                    schedule_type,
                    pg_date,
                    pdf_url,
                    contributor_name_text,
                    contributor_employer_text,
                    contributor_occupation_text,
                    is_individual,
                    clean_contbr_id
                )
                values (
                    view_row.cmte_id,
                    view_row.cmte_nm,
                    view_row.contbr_id,
                    view_row.contbr_nm,
                    view_row.contbr_nm_first,
                    view_row.contbr_m_nm,
                    view_row.contbr_nm_last,
                    view_row.contbr_prefix,
                    view_row.contbr_suffix,
                    view_row.contbr_st1,
                    view_row.contbr_st2,
                    view_row.contbr_city,
                    view_row.contbr_st,
                    view_row.contbr_zip,
                    view_row.entity_tp,
                    view_row.entity_tp_desc,
                    view_row.contbr_employer,
                    view_row.contbr_occupation,
                    view_row.election_tp,
                    view_row.fec_election_tp_desc,
                    view_row.fec_election_yr,
                    view_row.election_tp_desc,
                    view_row.contb_aggregate_ytd,
                    view_row.contb_receipt_dt,
                    view_row.contb_receipt_amt,
                    view_row.receipt_tp,
                    view_row.receipt_tp_desc,
                    view_row.receipt_desc,
                    view_row.memo_cd,
                    view_row.memo_cd_desc,
                    view_row.memo_text,
                    view_row.cand_id,
                    view_row.cand_nm,
                    view_row.cand_nm_first,
                    view_row.cand_m_nm,
                    view_row.cand_nm_last,
                    view_row.cand_prefix,
                    view_row.cand_suffix,
                    view_row.cand_office,
                    view_row.cand_office_desc,
                    view_row.cand_office_st,
                    view_row.cand_office_st_desc,
                    view_row.cand_office_district,
                    view_row.conduit_cmte_id,
                    view_row.conduit_cmte_nm,
                    view_row.conduit_cmte_st1,
                    view_row.conduit_cmte_st2,
                    view_row.conduit_cmte_city,
                    view_row.conduit_cmte_st,
                    view_row.conduit_cmte_zip,
                    view_row.donor_cmte_nm,
                    view_row.national_cmte_nonfed_acct,
                    view_row.increased_limit,
                    view_row.action_cd,
                    view_row.action_cd_desc,
                    view_row.tran_id,
                    view_row.back_ref_tran_id,
                    view_row.back_ref_sched_nm,
                    view_row.schedule_type_desc,
                    view_row.line_num,
                    view_row.image_num,
                    view_row.file_num,
                    view_row.link_id,
                    view_row.orig_sub_id,
                    view_row.sub_id,
                    view_row.filing_form,
                    view_row.rpt_tp,
                    view_row.rpt_yr,
                    view_row.election_cycle,
                    view_row.timestamp,
                    view_row.two_year_transaction_period,
                    cast(view_row.schedule_type as varchar(2)),
                    cast(current_timestamp as datetime),
                    image_pdf_url(view_row.image_num),
                    to_tsvector(concat(
                        view_row.contbr_nm,
                        ' ',
                        view_row.contbr_id
                    ),
                    to_tsvector(view_row.contbr_employer),
                    to_tsvector(view_row.contbr_occupation),
                    is_individual(
                        view_row.contb_receipt_amt,
                        view_row.receipt_tp,
                        view_row.line_num,
                        view_row.memo_cd,
                        view_row.memo_text
                    ),
                    clean_repeated(view_row.contbr_id, view_row.cmte_id)
                ) on conflict (sub_id) do update
                    set cmte_id = excluded.cmte_id,
                    set cmte_nm = excluded.cmte_nm,
                    set contbr_id = excluded.contbr_id,
                    set contbr_nm = excluded.contbr_nm,
                    set contbr_nm_first = excluded.contbr_nm_first,
                    set contbr_m_nm = excluded.contbr_m_nm,
                    set contbr_nm_last = excluded.contbr_nm_last,
                    set contbr_prefix = excluded.contbr_prefix,
                    set contbr_suffix = excluded.contbr_suffix,
                    set contbr_st1 = excluded.contbr_st1,
                    set contbr_st2 = excluded.contbr_st2,
                    set contbr_city = excluded.contbr_city,
                    set contbr_st = excluded.contbr_st,
                    set contbr_zip = excluded.contbr_zip,
                    set entity_tp = excluded.entity_tp,
                    set entity_tp_desc = excluded.entity_tp_desc,
                    set contbr_employer = excluded.contbr_employer,
                    set contbr_occupation = excluded.contbr_occupation,
                    set election_tp = excluded.election_tp,
                    set fec_election_tp_desc = excluded.fec_election_tp_desc,
                    set fec_election_yr = excluded.fec_election_yr,
                    set election_tp_desc = excluded.election_tp_desc,
                    set contb_aggregate_ytd = excluded.contb_aggregate_ytd,
                    set contb_receipt_dt = excluded.contb_receipt_dt,
                    set contb_receipt_amt = excluded.contb_receipt_amt,
                    set receipt_tp = excluded.receipt_tp,
                    set receipt_tp_desc = excluded.receipt_tp_desc,
                    set receipt_desc = excluded.receipt_desc,
                    set memo_cd = excluded.memo_cd,
                    set memo_cd_desc = excluded.memo_cd_desc,
                    set memo_text = excluded.memo_text,
                    set cand_id = excluded.cand_id,
                    set cand_nm = excluded.cand_nm,
                    set cand_nm_first = excluded.cand_nm_first,
                    set cand_m_nm = excluded.cand_m_nm,
                    set cand_nm_last = excluded.cand_nm_last,
                    set cand_prefix = excluded.cand_prefix,
                    set cand_suffix = excluded.cand_suffix,
                    set cand_office = excluded.cand_office,
                    set cand_office_desc = excluded.cand_office_desc,
                    set cand_office_st = excluded.cand_office_st,
                    set cand_office_st_desc = excluded.cand_office_st_desc,
                    set cand_office_district = excluded.cand_office_district,
                    set conduit_cmte_id = excluded.conduit_cmte_id,
                    set conduit_cmte_nm = excluded.conduit_cmte_nm,
                    set conduit_cmte_st1 = excluded.conduit_cmte_st1,
                    set conduit_cmte_st2 = excluded.conduit_cmte_st2,
                    set conduit_cmte_city = excluded.conduit_cmte_city,
                    set conduit_cmte_st = excluded.conduit_cmte_st,
                    set conduit_cmte_zip = excluded.conduit_cmte_zip,
                    set donor_cmte_nm = excluded.donor_cmte_nm,
                    set national_cmte_nonfed_acct = excluded.national_cmte_nonfed_acct,
                    set increased_limit = excluded.increased_limit,
                    set action_cd = excluded.action_cd,
                    set action_cd_desc = excluded.action_cd_desc,
                    set tran_id = excluded.tran_id,
                    set back_ref_tran_id = excluded.back_ref_tran_id,
                    set back_ref_sched_nm = excluded.back_ref_sched_nm,
                    set schedule_type_desc = excluded.schedule_type_desc,
                    set line_num = excluded.line_num,
                    set image_num = excluded.image_num,
                    set file_num = excluded.file_num,
                    set link_id = excluded.link_id,
                    set orig_sub_id = excluded.orig_sub_id,
                    set sub_id = excluded.sub_id,
                    set filing_form = excluded.filing_form,
                    set rpt_tp = excluded.rpt_tp,
                    set rpt_yr = excluded.rpt_yr,
                    set election_cycle = excluded.election_cycle,
                    set timestamp = excluded.timestamp,
                    set two_year_transaction_period = excluded.two_year_transaction_period,
                    set schedule_type = cast(excluded.schedule_type as varchar(2)),
                    set pg_date = cast(current_timestamp as datetime),
                    set pdf_url = image_pdf_url(excluded.image_num),
                    set contributor_name_text = to_tsvector(concat(
                        excluded.contbr_nm,
                        ' ',
                        excluded.contbr_id
                    )),
                    set contributor_employer_text = to_tsvector(excluded.contbr_employer),
                    set contributor_occupation_text = to_tsvector(excluded.contbr_occupation),
                    set is_individual = is_individual(
                        excluded.contb_receipt_amt,
                        excluded.receipt_tp,
                        excluded.line_num,
                        excluded.memo_cd,
                        excluded.memo_text
                    ),
                    set clean_contbr_id = clean_repeated(excluded.contbr_id, excluded.cmte_id);

                -- Remove the found record from the nightly retry queue.
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
        two_year_transaction_period = get_transaction_year(view_row.contb_receipt_dt, view_row.rpt_yr);

        if two_year_transaction_period >= start_year then
            -- TODO:  Figure out how to get this in the right child table
            --        automatically.
            insert into ofec_sched_a_master (
                cmte_id,
                cmte_nm,
                contbr_id,
                contbr_nm,
                contbr_nm_first,
                contbr_m_nm,
                contbr_nm_last,
                contbr_prefix,
                contbr_suffix,
                contbr_st1,
                contbr_st2,
                contbr_city,
                contbr_st,
                contbr_zip,
                entity_tp,
                entity_tp_desc,
                contbr_employer,
                contbr_occupation,
                election_tp,
                fec_election_tp_desc,
                fec_election_yr,
                election_tp_desc,
                contb_aggregate_ytd,
                contb_receipt_dt,
                contb_receipt_amt,
                receipt_tp,
                receipt_tp_desc,
                receipt_desc,
                memo_cd,
                memo_cd_desc,
                memo_text,
                cand_id,
                cand_nm,
                cand_nm_first,
                cand_m_nm,
                cand_nm_last,
                cand_prefix,
                cand_suffix,
                cand_office,
                cand_office_desc,
                cand_office_st,
                cand_office_st_desc,
                cand_office_district,
                conduit_cmte_id,
                conduit_cmte_nm,
                conduit_cmte_st1,
                conduit_cmte_st2,
                conduit_cmte_city,
                conduit_cmte_st,
                conduit_cmte_zip,
                donor_cmte_nm,
                national_cmte_nonfed_acct,
                increased_limit,
                action_cd,
                action_cd_desc,
                tran_id,
                back_ref_tran_id,
                back_ref_sched_nm,
                schedule_type_desc,
                line_num,
                image_num,
                file_num,
                link_id,
                orig_sub_id,
                sub_id,
                filing_form,
                rpt_tp,
                rpt_yr,
                election_cycle,
                timestamp,
                two_year_transaction_period,
                schedule_type,
                pg_date,
                pdf_url,
                contributor_name_text,
                contributor_employer_text,
                contributor_occupation_text,
                is_individual,
                clean_contbr_id
            )
            values (
                view_row.cmte_id,
                view_row.cmte_nm,
                view_row.contbr_id,
                view_row.contbr_nm,
                view_row.contbr_nm_first,
                view_row.contbr_m_nm,
                view_row.contbr_nm_last,
                view_row.contbr_prefix,
                view_row.contbr_suffix,
                view_row.contbr_st1,
                view_row.contbr_st2,
                view_row.contbr_city,
                view_row.contbr_st,
                view_row.contbr_zip,
                view_row.entity_tp,
                view_row.entity_tp_desc,
                view_row.contbr_employer,
                view_row.contbr_occupation,
                view_row.election_tp,
                view_row.fec_election_tp_desc,
                view_row.fec_election_yr,
                view_row.election_tp_desc,
                view_row.contb_aggregate_ytd,
                view_row.contb_receipt_dt,
                view_row.contb_receipt_amt,
                view_row.receipt_tp,
                view_row.receipt_tp_desc,
                view_row.receipt_desc,
                view_row.memo_cd,
                view_row.memo_cd_desc,
                view_row.memo_text,
                view_row.cand_id,
                view_row.cand_nm,
                view_row.cand_nm_first,
                view_row.cand_m_nm,
                view_row.cand_nm_last,
                view_row.cand_prefix,
                view_row.cand_suffix,
                view_row.cand_office,
                view_row.cand_office_desc,
                view_row.cand_office_st,
                view_row.cand_office_st_desc,
                view_row.cand_office_district,
                view_row.conduit_cmte_id,
                view_row.conduit_cmte_nm,
                view_row.conduit_cmte_st1,
                view_row.conduit_cmte_st2,
                view_row.conduit_cmte_city,
                view_row.conduit_cmte_st,
                view_row.conduit_cmte_zip,
                view_row.donor_cmte_nm,
                view_row.national_cmte_nonfed_acct,
                view_row.increased_limit,
                view_row.action_cd,
                view_row.action_cd_desc,
                view_row.tran_id,
                view_row.back_ref_tran_id,
                view_row.back_ref_sched_nm,
                view_row.schedule_type_desc,
                view_row.line_num,
                view_row.image_num,
                view_row.file_num,
                view_row.link_id,
                view_row.orig_sub_id,
                view_row.sub_id,
                view_row.filing_form,
                view_row.rpt_tp,
                view_row.rpt_yr,
                view_row.election_cycle,
                view_row.timestamp,
                view_row.two_year_transaction_period,
                cast(view_row.schedule_type as varchar(2)),
                cast(current_timestamp as datetime),
                image_pdf_url(view_row.image_num),
                to_tsvector(concat(
                    view_row.contbr_nm,
                    ' ',
                    view_row.contbr_id
                )),
                to_tsvector(view_row.contbr_employer),
                to_tsvector(view_row.contbr_occupation),
                is_individual(
                    view_row.contb_receipt_amt,
                    view_row.receipt_tp,
                    view_row.line_num,
                    view_row.memo_cd,
                    view_row.memo_text
                ),
                clean_repeated(view_row.contbr_id, view_row.cmte_id)
            ) on conflict (sub_id) do update
                set cmte_id = excluded.cmte_id,
                set cmte_nm = excluded.cmte_nm,
                set contbr_id = excluded.contbr_id,
                set contbr_nm = excluded.contbr_nm,
                set contbr_nm_first = excluded.contbr_nm_first,
                set contbr_m_nm = excluded.contbr_m_nm,
                set contbr_nm_last = excluded.contbr_nm_last,
                set contbr_prefix = excluded.contbr_prefix,
                set contbr_suffix = excluded.contbr_suffix,
                set contbr_st1 = excluded.contbr_st1,
                set contbr_st2 = excluded.contbr_st2,
                set contbr_city = excluded.contbr_city,
                set contbr_st = excluded.contbr_st,
                set contbr_zip = excluded.contbr_zip,
                set entity_tp = excluded.entity_tp,
                set entity_tp_desc = excluded.entity_tp_desc,
                set contbr_employer = excluded.contbr_employer,
                set contbr_occupation = excluded.contbr_occupation,
                set election_tp = excluded.election_tp,
                set fec_election_tp_desc = excluded.fec_election_tp_desc,
                set fec_election_yr = excluded.fec_election_yr,
                set election_tp_desc = excluded.election_tp_desc,
                set contb_aggregate_ytd = excluded.contb_aggregate_ytd,
                set contb_receipt_dt = excluded.contb_receipt_dt,
                set contb_receipt_amt = excluded.contb_receipt_amt,
                set receipt_tp = excluded.receipt_tp,
                set receipt_tp_desc = excluded.receipt_tp_desc,
                set receipt_desc = excluded.receipt_desc,
                set memo_cd = excluded.memo_cd,
                set memo_cd_desc = excluded.memo_cd_desc,
                set memo_text = excluded.memo_text,
                set cand_id = excluded.cand_id,
                set cand_nm = excluded.cand_nm,
                set cand_nm_first = excluded.cand_nm_first,
                set cand_m_nm = excluded.cand_m_nm,
                set cand_nm_last = excluded.cand_nm_last,
                set cand_prefix = excluded.cand_prefix,
                set cand_suffix = excluded.cand_suffix,
                set cand_office = excluded.cand_office,
                set cand_office_desc = excluded.cand_office_desc,
                set cand_office_st = excluded.cand_office_st,
                set cand_office_st_desc = excluded.cand_office_st_desc,
                set cand_office_district = excluded.cand_office_district,
                set conduit_cmte_id = excluded.conduit_cmte_id,
                set conduit_cmte_nm = excluded.conduit_cmte_nm,
                set conduit_cmte_st1 = excluded.conduit_cmte_st1,
                set conduit_cmte_st2 = excluded.conduit_cmte_st2,
                set conduit_cmte_city = excluded.conduit_cmte_city,
                set conduit_cmte_st = excluded.conduit_cmte_st,
                set conduit_cmte_zip = excluded.conduit_cmte_zip,
                set donor_cmte_nm = excluded.donor_cmte_nm,
                set national_cmte_nonfed_acct = excluded.national_cmte_nonfed_acct,
                set increased_limit = excluded.increased_limit,
                set action_cd = excluded.action_cd,
                set action_cd_desc = excluded.action_cd_desc,
                set tran_id = excluded.tran_id,
                set back_ref_tran_id = excluded.back_ref_tran_id,
                set back_ref_sched_nm = excluded.back_ref_sched_nm,
                set schedule_type_desc = excluded.schedule_type_desc,
                set line_num = excluded.line_num,
                set image_num = excluded.image_num,
                set file_num = excluded.file_num,
                set link_id = excluded.link_id,
                set orig_sub_id = excluded.orig_sub_id,
                set sub_id = excluded.sub_id,
                set filing_form = excluded.filing_form,
                set rpt_tp = excluded.rpt_tp,
                set rpt_yr = excluded.rpt_yr,
                set election_cycle = excluded.election_cycle,
                set timestamp = excluded.timestamp,
                set two_year_transaction_period = excluded.two_year_transaction_period,
                set schedule_type = cast(excluded.schedule_type as varchar(2)),
                set pg_date = cast(current_timestamp as datetime),
                set pdf_url = image_pdf_url(excluded.image_num),
                set contributor_name_text = to_tsvector(concat(
                    excluded.contbr_nm,
                    ' ',
                    excluded.contbr_id
                )),
                set contributor_employer_text = to_tsvector(excluded.contbr_employer),
                set contributor_occupation_text = to_tsvector(excluded.contbr_occupation),
                set is_individual = is_individual(
                    excluded.contb_receipt_amt,
                    excluded.receipt_tp,
                    excluded.line_num,
                    excluded.memo_cd,
                    excluded.memo_text
                ),
                set clean_contbr_id = clean_repeated(excluded.contbr_id, excluded.cmte_id);
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
