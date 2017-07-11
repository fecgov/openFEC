-- Create trigger for the master partition table to be created later, once the
-- master partition table is in place.
CREATE OR REPLACE FUNCTION insert_sched_master() RETURNS TRIGGER AS $$
DECLARE
    transaction_period_lower_guard SMALLINT = TG_ARGV[0]::SMALLINT - 1;
    child_table_name TEXT;
BEGIN
    IF new.two_year_transaction_period >= transaction_period_lower_guard THEN
        child_table_name = replace(TG_TABLE_NAME, 'master', get_partition_suffix(new.two_year_transaction_period));
        EXECUTE format('INSERT INTO %I VALUES ($1.*)', child_table_name)
            USING new;
    END IF;

    RETURN NULL;
END
$$ LANGUAGE plpgsql;


-- Creates all of the child tables for an itemized schedule partition.
CREATE OR REPLACE FUNCTION create_itemized_schedule_partition(schedule TEXT, start_year NUMERIC, end_year NUMERIC) RETURNS VOID AS $$
DECLARE
    child_table_name TEXT;
    master_table_name TEXT = format('ofec_sched_%s_master_tmp', schedule);
BEGIN
    FOR cycle IN start_year..end_year BY 2 LOOP
        child_table_name = format('ofec_sched_%s_%s_%s_tmp', schedule, cycle - 1, cycle);
        EXECUTE format('CREATE TABLE %I (
            CHECK ( two_year_transaction_period in (%s, %s) )
        ) INHERITS (%I)', child_table_name, cycle - 1, cycle, master_table_name);

    END LOOP;
END
$$ LANGUAGE plpgsql;


-- Performs the final steps needed to setup all of the child tables for
-- schedule A.
CREATE OR REPLACE FUNCTION finalize_itemized_schedule_a_tables(start_year NUMERIC, end_year NUMERIC) RETURNS VOID AS $$
DECLARE
    child_table_name TEXT;
    child_table_root TEXT;
BEGIN
    FOR cycle in start_year..end_year BY 2 LOOP
        child_table_root = format('ofec_sched_a_%s_%s', cycle - 1, cycle);
        child_table_name = format('ofec_sched_a_%s_%s_tmp', cycle - 1, cycle);

        -- Create indexes.
        EXECUTE format('CREATE UNIQUE INDEX idx_%s_sub_id_tmp ON %I (sub_id)', child_table_root, child_table_name);
        EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY USING INDEX idx_%s_sub_id_tmp', child_table_name, child_table_root);
        EXECUTE format('CREATE INDEX idx_%s_rpt_yr_tmp ON %I (rpt_yr)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_pg_date_tmp ON %I (pg_date)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_entity_tp_tmp ON %I (entity_tp)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_image_num_tmp ON %I (image_num)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_contbr_st_tmp ON %I (contbr_st)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_contbr_city_tmp ON %I (contbr_city)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_is_individual_tmp ON %I (is_individual)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_clean_contbr_id_tmp ON %I (clean_contbr_id)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_two_year_transaction_period_tmp ON %I (two_year_transaction_period)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_sub_id_amount_tmp ON %I (contb_receipt_amt, sub_id)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_sub_id_date_tmp ON %I (contb_receipt_dt, sub_id)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_sub_id_cmte_id_tmp ON %I (cmte_id, sub_id)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_sub_id_cmte_id_amount_tmp ON %I (cmte_id, contb_receipt_amt, sub_id)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_sub_id_cmte_id_date_tmp ON %I (cmte_id, contb_receipt_dt, sub_id)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_contributor_name_text_tmp ON %I USING GIN (contributor_name_text)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_contributor_employer_text_tmp ON %I USING GIN (contributor_employer_text)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_contributor_occupation_text_tmp ON %I USING GIN (contributor_occupation_text)', child_table_root, child_table_name);

        -- Set statistics and analyze the table.
        EXECUTE format('ALTER TABLE %I ALTER COLUMN contbr_st SET STATISTICS 1000', child_table_name);
        EXECUTE format('ANALYZE %I', child_table_name);
    END LOOP;
END
$$ LANGUAGE plpgsql;

-- Performs the final steps needed to setup all of the child tables for
-- schedule B.
CREATE OR REPLACE FUNCTION finalize_itemized_schedule_b_tables(start_year NUMERIC, end_year NUMERIC) RETURNS VOID AS $$
DECLARE
    child_table_name TEXT;
    child_table_root TEXT;
BEGIN
    FOR cycle in start_year..end_year BY 2 LOOP
        child_table_root = format('ofec_sched_b_%s_%s', cycle - 1, cycle);
        child_table_name = format('ofec_sched_b_%s_%s_tmp', cycle - 1, cycle);

        -- Create indexes.
        EXECUTE format('CREATE UNIQUE INDEX idx_%s_sub_id_tmp ON %I (sub_id)', child_table_root, child_table_name);
        EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY USING INDEX idx_%s_sub_id_tmp', child_table_name, child_table_root);
        EXECUTE format('CREATE INDEX idx_%s_clean_recipient_cmte_id_tmp ON %I (clean_recipient_cmte_id)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_cmte_id_sub_id_tmp ON %I (cmte_id, sub_id)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_cmte_id_disb_amt_sub_id_tmp ON %I (cmte_id, disb_amt, sub_id)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_cmte_id_disb_dt_sub_id_tmp ON %I (cmte_id, disb_dt, sub_id)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_image_num_tmp ON %I (image_num)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_pg_date_tmp ON %I (pg_date)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_recipient_city_tmp ON %I (recipient_city)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_recipient_st_tmp ON %I (recipient_st)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_rpt_yr_tmp ON %I (rpt_yr)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_sub_id_amount_tmp ON %I (disb_amt, sub_id)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_sub_id_date_tmp ON %I (disb_dt, sub_id)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_two_year_transaction_period_tmp ON %I (two_year_transaction_period)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_recipient_name_text_tmp ON %I USING GIN (recipient_name_text)', child_table_root, child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_disbursement_description_text_tmp ON %I USING GIN (disbursement_description_text)', child_table_root, child_table_name);

        -- Set statistics and analyze the table.
        EXECUTE format('ALTER TABLE %I ALTER COLUMN recipient_st SET STATISTICS 1000', child_table_name);
        EXECUTE format('ANALYZE %I', child_table_name);
    END LOOP;
END
$$ LANGUAGE plpgsql;

-- Provides the functions that allow us to retry processing itemized schedule
-- records that failed to process correctly upon initial record changes to the
-- underlying disclosure.nml_sched_a and disclosure.nml_sched_b tables.

-- If the record is successfully processed, it will be added to the main
-- nightly refresh queues to be taken care of with all of the other records
-- that were originally processed successfully.  If it is not, meaning it still
-- couldn't be found in the public.fec_fitem_sched_<x>_vw views, the sub_id
-- will remain in the ofec_sched_<x>_nightly_retries table until it is.

-- Convenience function that takes care of all of the processing at once.
create or replace function retry_processing_itemized_records() returns void as $$
begin
    perform retry_processing_schedule_a_records(:START_YEAR_AGGREGATE);
    perform retry_processing_schedule_b_records(:START_YEAR_AGGREGATE);
end
$$ language plpgsql;

CREATE OR REPLACE FUNCTION rename_table_cascade(table_name TEXT) RETURNS VOID AS $$
DECLARE
    child_tmp_table_name TEXT;
    child_tables_cursor CURSOR (parent TEXT) FOR
        SELECT c.oid::pg_catalog.regclass AS name
        FROM pg_catalog.pg_class c, pg_catalog.pg_inherits i
        WHERE c.oid=i.inhrelid
            AND i.inhparent = (SELECT oid from pg_catalog.pg_class rc where relname = parent);
BEGIN
    EXECUTE format('DROP TABLE IF EXISTS %I CASCADE', table_name);
    EXECUTE format('ALTER TABLE %1$I_tmp RENAME TO %1$I', table_name);

    FOR child_tmp_table IN child_tables_cursor(table_name) LOOP
        child_tmp_table_name = child_tmp_table.name;
        EXECUTE format('ALTER TABLE %1$I RENAME TO %2$I', child_tmp_table_name, regexp_replace(child_tmp_table_name, '_tmp$', ''));
    END LOOP;
END
$$ LANGUAGE plpgsql;
