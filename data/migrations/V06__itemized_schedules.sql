-- Drop the old nightly refresh retry table and function if they still exist.
drop table if exists ofec_sched_a_nightly_retries;
drop function if exists retry_processing_schedule_a_records(start_year integer);

-- Drop the old queues if they still exist.
drop table if exists ofec_sched_a_queue_new;
drop table if exists ofec_sched_a_queue_old;


-- Create trigger to maintain Schedule A for inserts and updates
-- These happen after a row is inserted/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_a_insert_update() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    view_row fec_fitem_sched_a_vw%ROWTYPE;
    child_table_name text;
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
            child_table_name = 'ofec_sched_a_' || get_partition_suffix(view_row.election_cycle);
            EXECUTE format('
            INSERT INTO %I
            (
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
                schedule_type,
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
                pg_date,
                pdf_url,
                contributor_name_text,
                contributor_employer_text,
                contributor_occupation_text,
                is_individual,
                clean_contbr_id,
                two_year_transaction_period,
                line_number_label
            )
            VALUES
            (
                $1.cmte_id,
                $1.cmte_nm,
                $1.contbr_id,
                $1.contbr_nm,
                $1.contbr_nm_first,
                $1.contbr_m_nm,
                $1.contbr_nm_last,
                $1.contbr_prefix,
                $1.contbr_suffix,
                $1.contbr_st1,
                $1.contbr_st2,
                $1.contbr_city,
                $1.contbr_st,
                $1.contbr_zip,
                $1.entity_tp,
                $1.entity_tp_desc,
                $1.contbr_employer,
                $1.contbr_occupation,
                $1.election_tp,
                $1.fec_election_tp_desc,
                $1.fec_election_yr,
                $1.election_tp_desc,
                $1.contb_aggregate_ytd,
                $1.contb_receipt_dt,
                $1.contb_receipt_amt,
                $1.receipt_tp,
                $1.receipt_tp_desc,
                $1.receipt_desc,
                $1.memo_cd,
                $1.memo_cd_desc,
                $1.memo_text,
                $1.cand_id,
                $1.cand_nm,
                $1.cand_nm_first,
                $1.cand_m_nm,
                $1.cand_nm_last,
                $1.cand_prefix,
                $1.cand_suffix,
                $1.cand_office,
                $1.cand_office_desc,
                $1.cand_office_st,
                $1.cand_office_st_desc,
                $1.cand_office_district,
                $1.conduit_cmte_id,
                $1.conduit_cmte_nm,
                $1.conduit_cmte_st1,
                $1.conduit_cmte_st2,
                $1.conduit_cmte_city,
                $1.conduit_cmte_st,
                $1.conduit_cmte_zip,
                $1.donor_cmte_nm,
                $1.national_cmte_nonfed_acct,
                $1.increased_limit,
                $1.action_cd,
                $1.action_cd_desc,
                $1.tran_id,
                $1.back_ref_tran_id,
                $1.back_ref_sched_nm,
                $1.schedule_type,
                $1.schedule_type_desc,
                $1.line_num,
                $1.image_num,
                $1.file_num,
                $1.link_id,
                $1.orig_sub_id,
                $1.sub_id,
                $1.filing_form,
                $1.rpt_tp,
                $1.rpt_yr,
                $1.election_cycle,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP,
                image_pdf_url($1.image_num),
                to_tsvector(concat($1.contbr_nm, '' '', $1.contbr_id)),
                to_tsvector($1.contbr_employer),
                to_tsvector($1.contbr_occupation),
                is_individual($1.contb_receipt_amt, $1.receipt_tp, $1.line_num, $1.memo_cd, $1.memo_text),
                clean_repeated($1.contbr_id, $1.cmte_id),
                get_cycle($1.rpt_yr),
                expand_line_number($1.filing_form, $1.line_num)
            )
            ON CONFLICT (sub_id) DO UPDATE
            SET
                cmte_id = $1.cmte_id,
                cmte_nm = $1.cmte_nm,
                contbr_id = $1.contbr_id,
                contbr_nm = $1.contbr_nm,
                contbr_nm_first = $1.contbr_nm_first,
                contbr_m_nm = $1.contbr_m_nm,
                contbr_nm_last = $1.contbr_nm_last,
                contbr_prefix = $1.contbr_prefix,
                contbr_suffix = $1.contbr_suffix,
                contbr_st1 = $1.contbr_st1,
                contbr_st2 = $1.contbr_st2,
                contbr_city = $1.contbr_city,
                contbr_st = $1.contbr_st,
                contbr_zip = $1.contbr_zip,
                entity_tp = $1.entity_tp,
                entity_tp_desc = $1.entity_tp_desc,
                contbr_employer = $1.contbr_employer,
                contbr_occupation = $1.contbr_occupation,
                election_tp = $1.election_tp,
                fec_election_tp_desc = $1.fec_election_tp_desc,
                fec_election_yr = $1.fec_election_yr,
                election_tp_desc = $1.election_tp_desc,
                contb_aggregate_ytd = $1.contb_aggregate_ytd,
                contb_receipt_dt = $1.contb_receipt_dt,
                contb_receipt_amt = $1.contb_receipt_amt,
                receipt_tp = $1.receipt_tp,
                receipt_tp_desc = $1.receipt_tp_desc,
                receipt_desc = $1.receipt_desc,
                memo_cd = $1.memo_cd,
                memo_cd_desc = $1.memo_cd_desc,
                memo_text = $1.memo_text,
                cand_id = $1.cand_id,
                cand_nm = $1.cand_nm,
                cand_nm_first = $1.cand_nm_first,
                cand_m_nm = $1.cand_m_nm,
                cand_nm_last = $1.cand_nm_last,
                cand_prefix = $1.cand_prefix,
                cand_suffix = $1.cand_suffix,
                cand_office = $1.cand_office,
                cand_office_desc = $1.cand_office_desc,
                cand_office_st = $1.cand_office_st,
                cand_office_st_desc = $1.cand_office_st_desc,
                cand_office_district = $1.cand_office_district,
                conduit_cmte_id = $1.conduit_cmte_id,
                conduit_cmte_nm = $1.conduit_cmte_nm,
                conduit_cmte_st1 = $1.conduit_cmte_st1,
                conduit_cmte_st2 = $1.conduit_cmte_st2,
                conduit_cmte_city = $1.conduit_cmte_city,
                conduit_cmte_st = $1.conduit_cmte_st,
                conduit_cmte_zip = $1.conduit_cmte_zip,
                donor_cmte_nm = $1.donor_cmte_nm,
                national_cmte_nonfed_acct = $1.national_cmte_nonfed_acct,
                increased_limit = $1.increased_limit,
                action_cd = $1.action_cd,
                action_cd_desc = $1.action_cd_desc,
                tran_id = $1.tran_id,
                back_ref_tran_id = $1.back_ref_tran_id,
                back_ref_sched_nm = $1.back_ref_sched_nm,
                schedule_type = $1.schedule_type,
                schedule_type_desc = $1.schedule_type_desc,
                line_num = $1.line_num,
                image_num = $1.image_num,
                file_num = $1.file_num,
                link_id = $1.link_id,
                orig_sub_id = $1.orig_sub_id,
                filing_form = $1.filing_form,
                rpt_tp = $1.rpt_tp,
                rpt_yr = $1.rpt_yr,
                election_cycle = $1.election_cycle,
                timestamp = CURRENT_TIMESTAMP,
                pg_date = CURRENT_TIMESTAMP,
                pdf_url = image_pdf_url($1.image_num),
                contributor_name_text = to_tsvector(concat($1.contbr_nm, '' '', $1.contbr_id)),
                contributor_employer_text = to_tsvector($1.contbr_employer),
                contributor_occupation_text = to_tsvector($1.contbr_occupation),
                is_individual = is_individual($1.contb_receipt_amt, $1.receipt_tp, $1.line_num, $1.memo_cd, $1.memo_text),
                clean_contbr_id = clean_repeated($1.contbr_id, $1.cmte_id),
                two_year_transaction_period = get_cycle($1.rpt_yr),
                line_number_label = expand_line_number($1.filing_form, $1.line_num)
            WHERE
                %I.sub_id = $1.sub_id',
                child_table_name, child_table_name) USING view_row;
            PERFORM increment_sched_a_aggregates(view_row);
        end if;
    end if;

    RETURN NULL; -- result is ignored since this is an AFTER trigger
end
$$ language plpgsql;


-- Create trigger to maintain Schedule A deletes and updates
-- These happen before a row is removed/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_a_delete_update() returns trigger as $$
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
                IF tg_op = 'DELETE' THEN
                    DELETE FROM ofec_sched_a_master WHERE sub_id = view_row.sub_id;
                END IF;
                PERFORM decrement_sched_a_aggregates(view_row);
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
    on disclosure.nml_sched_a for each row execute procedure ofec_sched_a_insert_update(2007);

drop trigger if exists nml_sched_a_before_trigger on disclosure.nml_sched_a;
create trigger nml_sched_a_before_trigger before delete or update
    on disclosure.nml_sched_a for each row execute procedure ofec_sched_a_delete_update(2007);

drop trigger if exists f_item_sched_a_after_trigger on disclosure.f_item_receipt_or_exp;
create trigger f_item_sched_a_after_trigger after insert or update
    on disclosure.f_item_receipt_or_exp for each row execute procedure ofec_sched_a_insert_update(2007);

drop trigger if exists f_item_sched_a_before_trigger on disclosure.f_item_receipt_or_exp;
create trigger f_item_sched_a_before_trigger before delete or update
    on disclosure.f_item_receipt_or_exp for each row execute procedure ofec_sched_a_delete_update(2007);

CREATE OR REPLACE FUNCTION increment_sched_a_aggregates(view_row fec_fitem_sched_a_vw) RETURNS VOID AS $$
BEGIN
    IF view_row.contb_receipt_amt IS NOT NULL AND is_individual(view_row.contb_receipt_amt, view_row.receipt_tp, view_row.line_num, view_row.memo_cd, view_row.memo_text, view_row.contbr_id, view_row.cmte_id) THEN
        INSERT INTO ofec_sched_a_aggregate_employer
            (cmte_id, cycle, employer, total, count)
        VALUES
            (view_row.cmte_id, view_row.election_cycle, view_row.contbr_employer, view_row.contb_receipt_amt, 1)
        ON CONFLICT ON CONSTRAINT uq_sched_a_aggregate_employer_cmte_id_cycle_employer DO UPDATE
        SET
            total = ofec_sched_a_aggregate_employer.total + excluded.total,
            count = ofec_sched_a_aggregate_employer.count + excluded.count;
        INSERT INTO ofec_sched_a_aggregate_occupation
            (cmte_id, cycle, occupation, total, count)
        VALUES
            (view_row.cmte_id, view_row.election_cycle, view_row.contbr_occupation, view_row.contb_receipt_amt, 1)
        ON CONFLICT ON CONSTRAINT uq_sched_a_aggregate_occupation_cmte_id_cycle_occupation DO UPDATE
        SET
            total = ofec_sched_a_aggregate_occupation.total + excluded.total,
            count = ofec_sched_a_aggregate_occupation.count + excluded.count;
        INSERT INTO ofec_sched_a_aggregate_state
            (cmte_id, cycle, state, state_full, total, count)
        VALUES
            (view_row.cmte_id, view_row.election_cycle, view_row.contbr_st, expand_state(view_row.contbr_st), view_row.contb_receipt_amt, 1)
        ON CONFLICT ON CONSTRAINT uq_ofec_sched_a_aggregate_state_cmte_id_cycle_state DO UPDATE
        SET
            total = ofec_sched_a_aggregate_state.total + excluded.total,
            count = ofec_sched_a_aggregate_state.count + excluded.count;
        INSERT INTO ofec_sched_a_aggregate_zip
            (cmte_id, cycle, zip, state, state_full, total, count)
        VALUES
            (view_row.cmte_id, view_row.election_cycle, view_row.contbr_zip, view_row.contbr_st, expand_state(view_row.contbr_st), view_row.contb_receipt_amt, 1)
        ON CONFLICT ON CONSTRAINT uq_ofec_sched_a_aggregate_zip_cmte_id_cycle_zip DO UPDATE
        SET
            total = ofec_sched_a_aggregate_zip.total + excluded.total,
            count = ofec_sched_a_aggregate_zip.count + excluded.count;
        INSERT INTO ofec_sched_a_aggregate_size
            (cmte_id, cycle, size, total, count)
        VALUES
            (view_row.cmte_id, view_row.election_cycle, contribution_size(view_row.contb_receipt_amt), view_row.contb_receipt_amt, 1)
        ON CONFLICT ON CONSTRAINT uq_ofec_sched_a_aggregate_size_cmte_id_cycle_size DO UPDATE
        SET
            total = ofec_sched_a_aggregate_size.total + excluded.total,
            count = ofec_sched_a_aggregate_size.count + excluded.count;
    END IF;
END
$$ language plpgsql;

CREATE OR REPLACE FUNCTION decrement_sched_a_aggregates(view_row fec_fitem_sched_a_vw) RETURNS VOID AS $$
BEGIN
    IF view_row.contb_receipt_amt IS NOT NULL AND is_individual(view_row.contb_receipt_amt, view_row.receipt_tp, view_row.line_num, view_row.memo_cd, view_row.memo_text, view_row.contbr_id, view_row.cmte_id) THEN
        UPDATE ofec_sched_a_aggregate_employer
        SET
            total = ofec_sched_a_aggregate_employer.total - view_row.contb_receipt_amt,
            count = ofec_sched_a_aggregate_employer.count - 1
        WHERE
            (cmte_id, cycle, employer) = (view_row.cmte_id, view_row.election_cycle, view_row.contbr_employer);
        UPDATE ofec_sched_a_aggregate_occupation
        SET
            total = ofec_sched_a_aggregate_occupation.total - view_row.contb_receipt_amt,
            count = ofec_sched_a_aggregate_occupation.count - 1
        WHERE
            (cmte_id, cycle, occupation) = (view_row.cmte_id, view_row.election_cycle, view_row.contbr_occupation);
        UPDATE ofec_sched_a_aggregate_state
        SET
            total = ofec_sched_a_aggregate_state.total - view_row.contb_receipt_amt,
            count = ofec_sched_a_aggregate_state.count - 1
        WHERE
            (cmte_id, cycle, state) = (view_row.cmte_id, view_row.election_cycle, view_row.contbr_st);
        UPDATE ofec_sched_a_aggregate_zip
        SET
            total = ofec_sched_a_aggregate_zip.total - view_row.contb_receipt_amt,
            count = ofec_sched_a_aggregate_zip.count - 1
        WHERE
            (cmte_id, cycle, zip) = (view_row.cmte_id, view_row.election_cycle, view_row.contbr_zip);
        UPDATE ofec_sched_a_aggregate_size
        SET
            total = ofec_sched_a_aggregate_size.total - view_row.contb_receipt_amt,
            count = ofec_sched_a_aggregate_size.count - 1
        WHERE
            (cmte_id, cycle, size) = (view_row.cmte_id, view_row.election_cycle, contribution_size(view_row.contb_receipt_amt));
    END IF;
END
$$ language plpgsql;

-- Drop the old trigger functions if they still exist.
drop function if exists ofec_sched_a_insert_update_queues();
drop function if exists ofec_sched_a_delete_update_queues();

-- Creates the partition of schedule A data
DROP TABLE IF EXISTS ofec_sched_a_master_tmp CASCADE;

CREATE TABLE ofec_sched_a_master_tmp (
    cmte_id                     VARCHAR(9),
    cmte_nm                     VARCHAR(200),
    contbr_id                   VARCHAR(9),
    contbr_nm                   VARCHAR(200),
    contbr_nm_first             VARCHAR(38),
    contbr_m_nm                 VARCHAR(20),
    contbr_nm_last              VARCHAR(38),
    contbr_prefix               VARCHAR(10),
    contbr_suffix               VARCHAR(10),
    contbr_st1                  VARCHAR(34),
    contbr_st2                  VARCHAR(34),
    contbr_city                 VARCHAR(30),
    contbr_st                   VARCHAR(2),
    contbr_zip                  VARCHAR(9),
    entity_tp                   VARCHAR(3),
    entity_tp_desc              VARCHAR(50),
    contbr_employer             VARCHAR(38),
    contbr_occupation           VARCHAR(38),
    election_tp                 VARCHAR(5),
    fec_election_tp_desc        VARCHAR(20),
    fec_election_yr             VARCHAR(4),
    election_tp_desc            VARCHAR(20),
    contb_aggregate_ytd         NUMERIC(14,2),
    contb_receipt_dt            TIMESTAMP,
    contb_receipt_amt           NUMERIC(14,2),
    receipt_tp                  VARCHAR(3),
    receipt_tp_desc             VARCHAR(90),
    receipt_desc                VARCHAR(100),
    memo_cd                     VARCHAR(1),
    memo_cd_desc                VARCHAR(50),
    memo_text                   VARCHAR(100),
    cand_id                     VARCHAR(9),
    cand_nm                     VARCHAR(90),
    cand_nm_first               VARCHAR(38),
    cand_m_nm                   VARCHAR(20),
    cand_nm_last                VARCHAR(38),
    cand_prefix                 VARCHAR(10),
    cand_suffix                 VARCHAR(10),
    cand_office                 VARCHAR(1),
    cand_office_desc            VARCHAR(20),
    cand_office_st              VARCHAR(2),
    cand_office_st_desc         VARCHAR(20),
    cand_office_district        VARCHAR(2),
    conduit_cmte_id             VARCHAR(9),
    conduit_cmte_nm             VARCHAR(200),
    conduit_cmte_st1            VARCHAR(34),
    conduit_cmte_st2            VARCHAR(34),
    conduit_cmte_city           VARCHAR(30),
    conduit_cmte_st             VARCHAR(2),
    conduit_cmte_zip            VARCHAR(9),
    donor_cmte_nm               VARCHAR(200),
    national_cmte_nonfed_acct   VARCHAR(9),
    increased_limit             VARCHAR(1),
    action_cd                   VARCHAR(1),
    action_cd_desc              VARCHAR(15),
    tran_id                     TEXT,
    back_ref_tran_id            TEXT,
    back_ref_sched_nm           VARCHAR(8),
    schedule_type               VARCHAR(2),
    schedule_type_desc          VARCHAR(90),
    line_num                    VARCHAR(12),
    image_num                   VARCHAR(18),
    file_num                    NUMERIC(7,0),
    link_id                     NUMERIC(19,0),
    orig_sub_id                 NUMERIC(19,0),
    sub_id                      NUMERIC(19,0) NOT NULL,
    filing_form                 VARCHAR(8) NOT NULL,
    rpt_tp                      VARCHAR(3),
    rpt_yr                      NUMERIC(4,0),
    election_cycle              NUMERIC(4,0),
    timestamp                   TIMESTAMP,
    pg_date                     TIMESTAMP,
    pdf_url                     TEXT,
    contributor_name_text       TSVECTOR,
    contributor_employer_text   TSVECTOR,
    contributor_occupation_text TSVECTOR,
    is_individual               BOOLEAN,
    clean_contbr_id             VARCHAR(9),
    two_year_transaction_period SMALLINT,
    line_number_label           TEXT
);

-- Create the child tables.
SELECT create_itemized_schedule_partition('a', 1978, 2018);

-- Create the insert trigger so that records go into the proper child table.
DROP TRIGGER IF EXISTS insert_sched_a_trigger_tmp ON ofec_sched_a_master_tmp;
CREATE trigger insert_sched_a_trigger_tmp BEFORE INSERT ON ofec_sched_a_master_tmp FOR EACH ROW EXECUTE PROCEDURE insert_sched_master(1978);

---- Insert the records from the view
INSERT INTO ofec_sched_a_master_tmp
(
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
    schedule_type,
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
    pg_date,
    pdf_url,
    contributor_name_text,
    contributor_employer_text,
    contributor_occupation_text,
    is_individual,
    clean_contbr_id,
    two_year_transaction_period,
    line_number_label
)
SELECT
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
    schedule_type,
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
    CURRENT_TIMESTAMP as timestamp,
    CURRENT_TIMESTAMP as pg_date,
    image_pdf_url(image_num) AS pdf_url,
    to_tsvector(concat(contbr_nm, ' ', contbr_id)) AS contributor_name_text,
    to_tsvector(contbr_employer) AS contributor_employer_text,
    to_tsvector(contbr_occupation) AS contributor_occupation_text,
    is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text) AS is_individual,
    clean_repeated(contbr_id, cmte_id) AS clean_contbr_id,
    get_cycle(rpt_yr) AS two_year_transaction_period,
    expand_line_number(filing_form, line_num) AS line_number_label
FROM fec_fitem_sched_a_vw;

SELECT finalize_itemized_schedule_a_tables(1978, 2018, TRUE, TRUE);
SELECT rename_table_cascade('ofec_sched_a_master');


-- Create index for join on electioneering costs
drop index if exists disclosure.nml_sched_b_link_id_idx;
create index nml_sched_b_link_id_idx on disclosure.nml_sched_b (link_id);

-- Drop the old nightly refresh retry table and function if they still exist.
drop table if exists ofec_sched_b_nightly_retries;
drop function if exists retry_processing_schedule_b_records(start_year integer);

-- Drop the old queues if they still exist.
drop table if exists ofec_sched_b_queue_new;
drop table if exists ofec_sched_b_queue_old;

-- Create trigger to maintain Schedule A for inserts and updates
-- These happen after a row is inserted/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_b_insert_update() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    view_row fec_fitem_sched_b_vw%ROWTYPE;
    child_table_name text;
begin
    select into view_row * from fec_fitem_sched_b_vw where sub_id = new.sub_id;

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
            child_table_name = 'ofec_sched_b_' || get_partition_suffix(view_row.election_cycle);
            EXECUTE format('
            INSERT INTO %I
            (
                cmte_id,
                recipient_cmte_id,
                recipient_nm,
                payee_l_nm,
                payee_f_nm,
                payee_m_nm,
                payee_prefix,
                payee_suffix,
                payee_employer,
                payee_occupation,
                recipient_st1,
                recipient_st2,
                recipient_city,
                recipient_st,
                recipient_zip,
                disb_desc,
                catg_cd,
                catg_cd_desc,
                entity_tp,
                entity_tp_desc,
                election_tp,
                fec_election_tp_desc,
                fec_election_tp_year,
                election_tp_desc,
                cand_id,
                cand_nm,
                cand_nm_first,
                cand_nm_last,
                cand_m_nm,
                cand_prefix,
                cand_suffix,
                cand_office,
                cand_office_desc,
                cand_office_st,
                cand_office_st_desc,
                cand_office_district,
                disb_dt,
                disb_amt,
                memo_cd,
                memo_cd_desc,
                memo_text,
                disb_tp,
                disb_tp_desc,
                conduit_cmte_nm,
                conduit_cmte_st1,
                conduit_cmte_st2,
                conduit_cmte_city,
                conduit_cmte_st,
                conduit_cmte_zip,
                national_cmte_nonfed_acct,
                ref_disp_excess_flg,
                comm_dt,
                benef_cmte_nm,
                semi_an_bundled_refund,
                action_cd,
                action_cd_desc,
                tran_id,
                back_ref_tran_id,
                back_ref_sched_id,
                schedule_type,
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
                pg_date,
                pdf_url,
                recipient_name_text,
                disbursement_description_text,
                disbursement_purpose_category,
                clean_recipient_cmte_id,
                two_year_transaction_period,
                line_number_label
            )
            SELECT
                $1.cmte_id,
                $1.recipient_cmte_id,
                $1.recipient_nm,
                $1.payee_l_nm,
                $1.payee_f_nm,
                $1.payee_m_nm,
                $1.payee_prefix,
                $1.payee_suffix,
                $1.payee_employer,
                $1.payee_occupation,
                $1.recipient_st1,
                $1.recipient_st2,
                $1.recipient_city,
                $1.recipient_st,
                $1.recipient_zip,
                $1.disb_desc,
                $1.catg_cd,
                $1.catg_cd_desc,
                $1.entity_tp,
                $1.entity_tp_desc,
                $1.election_tp,
                $1.fec_election_tp_desc,
                $1.fec_election_tp_year,
                $1.election_tp_desc,
                $1.cand_id,
                $1.cand_nm,
                $1.cand_nm_first,
                $1.cand_nm_last,
                $1.cand_m_nm,
                $1.cand_prefix,
                $1.cand_suffix,
                $1.cand_office,
                $1.cand_office_desc,
                $1.cand_office_st,
                $1.cand_office_st_desc,
                $1.cand_office_district,
                $1.disb_dt,
                $1.disb_amt,
                $1.memo_cd,
                $1.memo_cd_desc,
                $1.memo_text,
                $1.disb_tp,
                $1.disb_tp_desc,
                $1.conduit_cmte_nm,
                $1.conduit_cmte_st1,
                $1.conduit_cmte_st2,
                $1.conduit_cmte_city,
                $1.conduit_cmte_st,
                $1.conduit_cmte_zip,
                $1.national_cmte_nonfed_acct,
                $1.ref_disp_excess_flg,
                $1.comm_dt,
                $1.benef_cmte_nm,
                $1.semi_an_bundled_refund,
                $1.action_cd,
                $1.action_cd_desc,
                $1.tran_id,
                $1.back_ref_tran_id,
                $1.back_ref_sched_id,
                $1.schedule_type,
                $1.schedule_type_desc,
                $1.line_num,
                $1.image_num,
                $1.file_num,
                $1.link_id,
                $1.orig_sub_id,
                $1.sub_id,
                $1.filing_form,
                $1.rpt_tp,
                $1.rpt_yr,
                $1.election_cycle,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP,
                image_pdf_url($1.image_num),
                to_tsvector(concat($1.recipient_nm, '' '', $1.recipient_cmte_id)),
                to_tsvector($1.disb_desc),
                disbursement_purpose($1.disb_tp, $1.disb_desc),
                clean_repeated($1.recipient_cmte_id, $1.cmte_id),
                get_cycle($1.rpt_yr),
                expand_line_number($1.filing_form, $1.line_num)
            ON CONFLICT (sub_id) DO UPDATE
            SET
                cmte_id = $1.cmte_id,
                recipient_cmte_id = $1.recipient_cmte_id,
                recipient_nm = $1.recipient_nm,
                payee_l_nm = $1.payee_l_nm,
                payee_f_nm = $1.payee_f_nm,
                payee_m_nm = $1.payee_m_nm,
                payee_prefix = $1.payee_prefix,
                payee_suffix = $1.payee_suffix,
                payee_employer = $1.payee_employer,
                payee_occupation = $1.payee_occupation,
                recipient_st1 = $1.recipient_st1,
                recipient_st2 = $1.recipient_st2,
                recipient_city = $1.recipient_city,
                recipient_st = $1.recipient_st,
                recipient_zip = $1.recipient_zip,
                disb_desc = $1.disb_desc,
                catg_cd = $1.catg_cd,
                catg_cd_desc = $1.catg_cd_desc,
                entity_tp = $1.entity_tp,
                entity_tp_desc = $1.entity_tp_desc,
                election_tp = $1.election_tp,
                fec_election_tp_desc = $1.fec_election_tp_desc,
                fec_election_tp_year = $1.fec_election_tp_year,
                election_tp_desc = $1.election_tp_desc,
                cand_id = $1.cand_id,
                cand_nm = $1.cand_nm,
                cand_nm_first = $1.cand_nm_first,
                cand_nm_last = $1.cand_nm_last,
                cand_m_nm = $1.cand_m_nm,
                cand_prefix = $1.cand_prefix,
                cand_suffix = $1.cand_suffix,
                cand_office = $1.cand_office,
                cand_office_desc = $1.cand_office_desc,
                cand_office_st = $1.cand_office_st,
                cand_office_st_desc = $1.cand_office_st_desc,
                cand_office_district = $1.cand_office_district,
                disb_dt = $1.disb_dt,
                disb_amt = $1.disb_amt,
                memo_cd = $1.memo_cd,
                memo_cd_desc = $1.memo_cd_desc,
                memo_text = $1.memo_text,
                disb_tp = $1.disb_tp,
                disb_tp_desc = $1.disb_tp_desc,
                conduit_cmte_nm = $1.conduit_cmte_nm,
                conduit_cmte_st1 = $1.conduit_cmte_st1,
                conduit_cmte_st2 = $1.conduit_cmte_st2,
                conduit_cmte_city = $1.conduit_cmte_city,
                conduit_cmte_st = $1.conduit_cmte_st,
                conduit_cmte_zip = $1.conduit_cmte_zip,
                national_cmte_nonfed_acct = $1.national_cmte_nonfed_acct,
                ref_disp_excess_flg = $1.ref_disp_excess_flg,
                comm_dt = $1.comm_dt,
                benef_cmte_nm = $1.benef_cmte_nm,
                semi_an_bundled_refund = $1.semi_an_bundled_refund,
                action_cd = $1.action_cd,
                action_cd_desc = $1.action_cd_desc,
                tran_id = $1.tran_id,
                back_ref_tran_id = $1.back_ref_tran_id,
                back_ref_sched_id = $1.back_ref_sched_id,
                schedule_type = $1.schedule_type,
                schedule_type_desc = $1.schedule_type_desc,
                line_num = $1.line_num,
                image_num = $1.image_num,
                file_num = $1.file_num,
                link_id = $1.link_id,
                orig_sub_id = $1.orig_sub_id,
                filing_form = $1.filing_form,
                rpt_tp = $1.rpt_tp,
                rpt_yr = $1.rpt_yr,
                election_cycle = $1.election_cycle,
                timestamp = CURRENT_TIMESTAMP,
                pg_date = CURRENT_TIMESTAMP,
                pdf_url = image_pdf_url($1.image_num),
                recipient_name_text = to_tsvector(concat($1.recipient_nm, '' '', $1.recipient_cmte_id)),
                disbursement_description_text = to_tsvector($1.disb_desc),
                disbursement_purpose_category = disbursement_purpose($1.disb_tp, $1.disb_desc),
                clean_recipient_cmte_id = clean_repeated($1.recipient_cmte_id, $1.cmte_id),
                two_year_transaction_period = get_cycle($1.rpt_yr),
                line_number_label = expand_line_number($1.filing_form, $1.line_num)
            WHERE
                %I.sub_id = $1.sub_id',
                child_table_name, child_table_name) USING view_row;
            PERFORM increment_sched_b_aggregates(view_row);
        end if;
    end if;

    RETURN NULL; -- result is ignored since this is an AFTER trigger
end
$$ language plpgsql;


-- Create trigger to maintain Schedule A deletes and updates
-- These happen before a row is removed/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_b_delete_update() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    view_row fec_fitem_sched_b_vw%ROWTYPE;
begin
    select into view_row * from fec_fitem_sched_b_vw where sub_id = old.sub_id;

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
            IF tg_op = 'DELETE' THEN
                DELETE FROM ofec_sched_b_master WHERE sub_id = view_row.sub_id;
            END IF;
            PERFORM decrement_sched_b_aggregates(view_row);
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
drop trigger if exists nml_sched_b_after_trigger on disclosure.nml_sched_b;
create trigger nml_sched_b_after_trigger after insert or update
    on disclosure.nml_sched_b for each row execute procedure ofec_sched_b_insert_update(2007);

drop trigger if exists nml_sched_b_before_trigger on disclosure.nml_sched_b;
create trigger nml_sched_b_before_trigger before delete or update
    on disclosure.nml_sched_b for each row execute procedure ofec_sched_b_delete_update(2007);

drop trigger if exists f_item_sched_b_after_trigger on disclosure.f_item_receipt_or_exp;
create trigger f_item_sched_b_after_trigger after insert or update
    on disclosure.f_item_receipt_or_exp for each row execute procedure ofec_sched_b_insert_update(2007);

drop trigger if exists f_item_sched_b_before_trigger on disclosure.f_item_receipt_or_exp;
create trigger f_item_sched_b_before_trigger before delete or update
    on disclosure.f_item_receipt_or_exp for each row execute procedure ofec_sched_b_delete_update(2007);

CREATE OR REPLACE FUNCTION increment_sched_b_aggregates(view_row fec_fitem_sched_b_vw) RETURNS VOID AS $$
BEGIN
    IF view_row.disb_amt IS NOT NULL AND (view_row.memo_cd != 'X' OR view_row.memo_cd IS NULL) THEN
        INSERT INTO ofec_sched_b_aggregate_purpose
            (cmte_id, cycle, purpose, total, count)
        VALUES
            (view_row.cmte_id, view_row.election_cycle, disbursement_purpose(view_row.disb_tp, view_row.disb_desc), view_row.disb_amt, 1)
        ON CONFLICT ON CONSTRAINT uq_ofec_sched_b_aggregate_purpose_cmte_id_cycle_purpose DO UPDATE
        SET
            total = ofec_sched_b_aggregate_purpose.total + excluded.total,
            count = ofec_sched_b_aggregate_purpose.count + excluded.count;
        INSERT INTO ofec_sched_b_aggregate_recipient
            (cmte_id, cycle, recipient_nm, total, count)
        VALUES
            (view_row.cmte_id, view_row.election_cycle, view_row.recipient_nm, view_row.disb_amt, 1)
        ON CONFLICT ON CONSTRAINT uq_ofec_sched_b_aggregate_recipient_cmte_id_cycle_recipient DO UPDATE
        SET
            total = ofec_sched_b_aggregate_recipient.total + excluded.total,
            count = ofec_sched_b_aggregate_recipient.count + excluded.count;
        INSERT INTO ofec_sched_b_aggregate_recipient_id
            (cmte_id, cycle, recipient_cmte_id, recipient_nm, total, count)
        VALUES
            (view_row.cmte_id, view_row.election_cycle, clean_repeated(view_row.recipient_cmte_id, view_row.cmte_id), view_row.recipient_nm, view_row.disb_amt, 1)
        ON CONFLICT ON CONSTRAINT uq_sched_b_agg_recpnt_id_cmte_id_cycle_recipient_cmte_id DO UPDATE
        SET
            total = ofec_sched_b_aggregate_recipient_id.total + excluded.total,
            count = ofec_sched_b_aggregate_recipient_id.count + excluded.count;
    END IF;
END
$$ language plpgsql;

CREATE OR REPLACE FUNCTION decrement_sched_b_aggregates(view_row fec_fitem_sched_b_vw) RETURNS VOID AS $$
BEGIN
    IF view_row.disb_amt IS NOT NULL AND (view_row.memo_cd != 'X' OR view_row.memo_cd IS NULL) THEN
        UPDATE ofec_sched_b_aggregate_purpose
        SET
            total = ofec_sched_b_aggregate_purpose.total - view_row.disb_amt,
            count = ofec_sched_b_aggregate_purpose.count - 1
        WHERE
            (cmte_id, cycle, purpose) = (view_row.cmte_id, view_row.election_cycle, disbursement_purpose(view_row.disb_tp, view_row.disb_desc));
        UPDATE ofec_sched_b_aggregate_recipient
        SET
            total = ofec_sched_b_aggregate_recipient.total - view_row.disb_amt,
            count = ofec_sched_b_aggregate_recipient.count - 1
        WHERE
            (cmte_id, cycle, recipient_nm) = (view_row.cmte_id, view_row.election_cycle, view_row.recipient_nm);
        UPDATE ofec_sched_b_aggregate_recipient_id
        SET
            total = ofec_sched_b_aggregate_recipient_id.total - view_row.disb_amt,
            count = ofec_sched_b_aggregate_recipient_id.count - 1
        WHERE
            (cmte_id, cycle, recipient_cmte_id) = (view_row.cmte_id, view_row.election_cycle, clean_repeated(view_row.recipient_cmte_id, view_row.cmte_id));
    END IF;
END
$$ language plpgsql;

-- Drop the old trigger functions if they still exist.
drop function if exists ofec_sched_b_insert_update_queues();
drop function if exists ofec_sched_b_delete_update_queues();


-- Creates the partition of schedule B data,
DROP TABLE IF EXISTS ofec_sched_b_master_tmp CASCADE;

CREATE TABLE ofec_sched_b_master_tmp (
    cmte_id                       VARCHAR(9),
    recipient_cmte_id             VARCHAR(9),
    recipient_nm                  VARCHAR(200),
    payee_l_nm                    VARCHAR(30),
    payee_f_nm                    VARCHAR(20),
    payee_m_nm                    VARCHAR(20),
    payee_prefix                  VARCHAR(10),
    payee_suffix                  VARCHAR(10),
    payee_employer                VARCHAR(38),
    payee_occupation              VARCHAR(38),
    recipient_st1                 VARCHAR(34),
    recipient_st2                 VARCHAR(34),
    recipient_city                VARCHAR(30),
    recipient_st                  VARCHAR(2),
    recipient_zip                 VARCHAR(9),
    disb_desc                     VARCHAR(100),
    catg_cd                       VARCHAR(3),
    catg_cd_desc                  VARCHAR(40),
    entity_tp                     VARCHAR(3),
    entity_tp_desc                VARCHAR(50),
    election_tp                   VARCHAR(5),
    fec_election_tp_desc          VARCHAR(20),
    fec_election_tp_year          VARCHAR(4),
    election_tp_desc              VARCHAR(20),
    cand_id                       VARCHAR(9),
    cand_nm                       VARCHAR(90),
    cand_nm_first                 VARCHAR(38),
    cand_nm_last                  VARCHAR(38),
    cand_m_nm                     VARCHAR(20),
    cand_prefix                   VARCHAR(10),
    cand_suffix                   VARCHAR(10),
    cand_office                   VARCHAR(1),
    cand_office_desc              VARCHAR(20),
    cand_office_st                VARCHAR(2),
    cand_office_st_desc           VARCHAR(20),
    cand_office_district          VARCHAR(2),
    disb_dt                       TIMESTAMP,
    disb_amt                      NUMERIC(14,2),
    memo_cd                       VARCHAR(1),
    memo_cd_desc                  VARCHAR(50),
    memo_text                     VARCHAR(100),
    disb_tp                       VARCHAR(3),
    disb_tp_desc                  VARCHAR(90),
    conduit_cmte_nm               VARCHAR(200),
    conduit_cmte_st1              VARCHAR(34),
    conduit_cmte_st2              VARCHAR(34),
    conduit_cmte_city             VARCHAR(30),
    conduit_cmte_st               VARCHAR(2),
    conduit_cmte_zip              VARCHAR(9),
    national_cmte_nonfed_acct     VARCHAR(9),
    ref_disp_excess_flg           VARCHAR(1),
    comm_dt                       TIMESTAMP,
    benef_cmte_nm                 VARCHAR(200),
    semi_an_bundled_refund        NUMERIC(14,2),
    action_cd                     VARCHAR(1),
    action_cd_desc                VARCHAR(15),
    tran_id                       TEXT,
    back_ref_tran_id              TEXT,
    back_ref_sched_id             TEXT,
    schedule_type                 VARCHAR(2),
    schedule_type_desc            VARCHAR(90),
    line_num                      VARCHAR(12),
    image_num                     VARCHAR(18),
    file_num                      NUMERIC(7,0),
    link_id                       NUMERIC(19,0),
    orig_sub_id                   NUMERIC(19,0),
    sub_id                        NUMERIC(19,0) NOT NULL,
    filing_form                   VARCHAR(8) NOT NULL,
    rpt_tp                        VARCHAR(3),
    rpt_yr                        NUMERIC(4,0),
    election_cycle                NUMERIC(4,0),
    timestamp                     TIMESTAMP,
    pg_date                       TIMESTAMP,
    pdf_url                       TEXT,
    recipient_name_text           TSVECTOR,
    disbursement_description_text TSVECTOR,
    disbursement_purpose_category TEXT,
    clean_recipient_cmte_id       VARCHAR(9),
    two_year_transaction_period   SMALLINT,
    line_number_label             TEXT
);

-- Create the child tables.
SELECT create_itemized_schedule_partition('b', 1978, 2018);

-- Create the insert trigger so that records go into the proper child table.
DROP TRIGGER IF EXISTS insert_sched_b_trigger_tmp ON ofec_sched_b_master_tmp;
CREATE trigger insert_sched_b_trigger_tmp BEFORE INSERT ON ofec_sched_b_master_tmp FOR EACH ROW EXECUTE PROCEDURE insert_sched_master(1978);

---- Insert the records from the view
INSERT INTO ofec_sched_b_master_tmp (
    cmte_id,
    recipient_cmte_id,
    recipient_nm,
    payee_l_nm,
    payee_f_nm,
    payee_m_nm,
    payee_prefix,
    payee_suffix,
    payee_employer,
    payee_occupation,
    recipient_st1,
    recipient_st2,
    recipient_city,
    recipient_st,
    recipient_zip,
    disb_desc,
    catg_cd,
    catg_cd_desc,
    entity_tp,
    entity_tp_desc,
    election_tp,
    fec_election_tp_desc,
    fec_election_tp_year,
    election_tp_desc,
    cand_id,
    cand_nm,
    cand_nm_first,
    cand_nm_last,
    cand_m_nm,
    cand_prefix,
    cand_suffix,
    cand_office,
    cand_office_desc,
    cand_office_st,
    cand_office_st_desc,
    cand_office_district,
    disb_dt,
    disb_amt,
    memo_cd,
    memo_cd_desc,
    memo_text,
    disb_tp,
    disb_tp_desc,
    conduit_cmte_nm,
    conduit_cmte_st1,
    conduit_cmte_st2,
    conduit_cmte_city,
    conduit_cmte_st,
    conduit_cmte_zip,
    national_cmte_nonfed_acct,
    ref_disp_excess_flg,
    comm_dt,
    benef_cmte_nm,
    semi_an_bundled_refund,
    action_cd,
    action_cd_desc,
    tran_id,
    back_ref_tran_id,
    back_ref_sched_id,
    schedule_type,
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
    pg_date,
    pdf_url,
    recipient_name_text,
    disbursement_description_text,
    disbursement_purpose_category,
    clean_recipient_cmte_id,
    two_year_transaction_period,
    line_number_label
)
SELECT
    cmte_id,
    recipient_cmte_id,
    recipient_nm,
    payee_l_nm,
    payee_f_nm,
    payee_m_nm,
    payee_prefix,
    payee_suffix,
    payee_employer,
    payee_occupation,
    recipient_st1,
    recipient_st2,
    recipient_city,
    recipient_st,
    recipient_zip,
    disb_desc,
    catg_cd,
    catg_cd_desc,
    entity_tp,
    entity_tp_desc,
    election_tp,
    fec_election_tp_desc,
    fec_election_tp_year,
    election_tp_desc,
    cand_id,
    cand_nm,
    cand_nm_first,
    cand_nm_last,
    cand_m_nm,
    cand_prefix,
    cand_suffix,
    cand_office,
    cand_office_desc,
    cand_office_st,
    cand_office_st_desc,
    cand_office_district,
    disb_dt,
    disb_amt,
    memo_cd,
    memo_cd_desc,
    memo_text,
    disb_tp,
    disb_tp_desc,
    conduit_cmte_nm,
    conduit_cmte_st1,
    conduit_cmte_st2,
    conduit_cmte_city,
    conduit_cmte_st,
    conduit_cmte_zip,
    national_cmte_nonfed_acct,
    ref_disp_excess_flg,
    comm_dt,
    benef_cmte_nm,
    semi_an_bundled_refund,
    action_cd,
    action_cd_desc,
    tran_id,
    back_ref_tran_id,
    back_ref_sched_id,
    schedule_type,
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
    CURRENT_TIMESTAMP as timestamp,
    CURRENT_TIMESTAMP as pg_date,
    image_pdf_url(image_num) AS pdf_url,
    to_tsvector(concat(recipient_nm, ' ', recipient_cmte_id)) AS recipient_name_text,
    to_tsvector(disb_desc) AS disbursement_description_text,
    disbursement_purpose(disb_tp, disb_desc) AS disbursement_purpose_category,
    clean_repeated(recipient_cmte_id, cmte_id) AS clean_recipient_cmte_id,
    get_cycle(rpt_yr) AS two_year_transaction_period,
    expand_line_number(filing_form, line_num) AS line_number_label
FROM fec_fitem_sched_b_vw;

SELECT finalize_itemized_schedule_b_tables(1978, 2018, TRUE, TRUE);
SELECT rename_table_cascade('ofec_sched_b_master');
