-- Drop old retry itemized processing function if it still exists.
DROP FUNCTION IF EXISTS retry_processing_itemized_records();

-- Drop older finalize functions if they still exist.
DROP FUNCTION IF EXISTS finalize_itemized_schedule_a_tables(NUMERIC, NUMERIC, BOOLEAN);
DROP FUNCTION IF EXISTS finalize_itemized_schedule_b_tables(NUMERIC, NUMERIC, BOOLEAN);

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


CREATE OR REPLACE FUNCTION add_partition_cycles(start_year NUMERIC, amount NUMERIC) RETURNS VOID AS $$
DECLARE
    first_cycle_end_year NUMERIC = get_cycle(start_year);
    last_cycle_end_year NUMERIC = first_cycle_end_year + (amount - 1) * 2;
    master_table_name TEXT;
    child_table_name TEXT;
    schedule TEXT;
BEGIN
    FOR cycle IN first_cycle_end_year..last_cycle_end_year BY 2 LOOP
        FOREACH schedule IN ARRAY ARRAY['a', 'b'] LOOP
            master_table_name = format('ofec_sched_%s_master', schedule);
            child_table_name = format('ofec_sched_%s_%s_%s', schedule, cycle - 1, cycle);
            EXECUTE format('CREATE TABLE %I (
                CHECK ( two_year_transaction_period in (%s, %s) )
            ) INHERITS (%I)', child_table_name, cycle - 1, cycle, master_table_name);

        END LOOP;
    END LOOP;
    PERFORM finalize_itemized_schedule_a_tables(first_cycle_end_year, last_cycle_end_year, FALSE, TRUE);
    PERFORM finalize_itemized_schedule_b_tables(first_cycle_end_year, last_cycle_end_year, FALSE, TRUE);
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


-- Removes old index definitions from the itemized schedule A partition.
CREATE OR REPLACE FUNCTION drop_old_itemized_schedule_a_indexes(start_year NUMERIC, end_year NUMERIC) RETURNS VOID AS $$
DECLARE
    child_table_root TEXT;
BEGIN
    FOR cycle in start_year..end_year BY 2 LOOP
        child_table_root = format('ofec_sched_a_%s_%s', cycle - 1, cycle);

        -- Remove old indexes.
        EXECUTE format('DROP INDEX IF EXISTS idx_%s_contributor_employer_text', child_table_root);
        EXECUTE format('DROP INDEX IF EXISTS idx_%s_contributor_name_text', child_table_root);
        EXECUTE format('DROP INDEX IF EXISTS idx_%s_contributor_occupation_text', child_table_root);
    END LOOP;
END
$$ LANGUAGE plpgsql;


-- Removes old index definitions from the itemized schedule B partition.
CREATE OR REPLACE FUNCTION drop_old_itemized_schedule_b_indexes(start_year NUMERIC, end_year NUMERIC) RETURNS VOID AS $$
DECLARE
    child_table_root TEXT;
BEGIN
    FOR cycle in start_year..end_year BY 2 LOOP
        child_table_root = format('ofec_sched_a_%s_%s', cycle - 1, cycle);

        -- Remove old indexes.
        EXECUTE format('DROP INDEX IF EXISTS idx_%s_recipient_name_text', child_table_root);
        EXECUTE format('DROP INDEX IF EXISTS idx_%s_disbursement_description_text', child_table_root);
    END LOOP;
END
$$ LANGUAGE plpgsql;


-- Performs the final steps needed to setup all of the child tables for
-- schedule A.
CREATE OR REPLACE FUNCTION finalize_itemized_schedule_a_tables(start_year NUMERIC, end_year NUMERIC, p_use_tmp BOOLEAN, p_create_primary_key BOOLEAN) RETURNS VOID AS $$
DECLARE
    child_table_root TEXT;
    child_table_name TEXT;
    index_name_suffix TEXT;
BEGIN
    FOR cycle in start_year..end_year BY 2 LOOP
        child_table_root = format('ofec_sched_a_%s_%s', cycle - 1, cycle);
        IF p_use_tmp THEN
            child_table_name = format('ofec_sched_a_%s_%s_tmp', cycle - 1, cycle);
            index_name_suffix = '_tmp';
        ELSE
            child_table_name = format('ofec_sched_a_%s_%s', cycle - 1, cycle);
            index_name_suffix = '';
        END IF;

        -- Create indexes.
        -- Note:  The multi-column GIN indexes require the btree_gin extension
        --        https://www.postgresql.org/docs/current/static/btree-gin.html
        --        This is installed but not enabled in RDS by default, it must
        --        be turned on with this: CREATE EXTENSION btree_gin;

        -- Indexes used for search
           -- for sorting by receipt date
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_image_num_dt%s ON %I (image_num, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contbr_st_dt%s ON %I (contbr_st, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contbr_city_dt%s ON %I (contbr_city, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contbr_zip_dt%s ON %I (contbr_zip, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_is_individual_dt%s ON %I (is_individual, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_clean_contbr_id_dt%s ON %I (clean_contbr_id, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_amount_dt%s ON %I (contb_receipt_amt, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_cmte_id_dt%s ON %I (cmte_id, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_line_num_dt%s ON %I (line_num, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_two_year_transaction_period_dt%s ON %I (two_year_transaction_period, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);

        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contrib_name_text_dt%s ON %I USING GIN (contributor_name_text, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contrib_emp_text_dt%s ON %I USING GIN (contributor_employer_text, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contrib_occ_text_dt%s ON %I USING GIN (contributor_occupation_text, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);

          -- for sorting by transaction amount
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_image_num_amt%s ON %I (image_num, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contbr_st_amt%s ON %I (contbr_st, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contbr_city_amt%s ON %I (contbr_city, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contbr_zip_amt%s ON %I (contbr_zip, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_is_individual_amt%s ON %I (is_individual, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_clean_contbr_id_amt%s ON %I (clean_contbr_id, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_date_amt%s ON %I (contb_receipt_dt, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_cmte_id_amt%s ON %I (cmte_id, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_line_num_amt%s ON %I (line_num, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_two_year_transaction_period_amt%s ON %I (two_year_transaction_period, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);

        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contrib_name_text_amt%s ON %I USING GIN (contributor_name_text, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contrib_emp_text_amt%s ON %I USING GIN (contributor_employer_text, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contrib_occ_text_amt%s ON %I USING GIN (contributor_occupation_text, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);

        -- Other indexes
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_rpt_yr%s ON %I (rpt_yr)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_pg_date%s ON %I (pg_date)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_entity_tp%s ON %I (entity_tp)', child_table_root, index_name_suffix, child_table_name);

        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_amount%s ON %I (contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_cmte_id_amount%s ON %I (cmte_id, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_cmte_id_date%s ON %I (cmte_id, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE UNIQUE INDEX IF NOT EXISTS idx_%s_sub_id%s ON %I (sub_id)', child_table_root, index_name_suffix, child_table_name);

        -- Create the primary key if needed
        IF p_create_primary_key THEN
            EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY USING INDEX idx_%s_sub_id%s', child_table_name, child_table_root, index_name_suffix);
        END IF;

        -- Set statistics and analyze the table.
        EXECUTE format('ALTER TABLE %I ALTER COLUMN contbr_st SET STATISTICS 1000', child_table_name);
        EXECUTE format('ANALYZE %I', child_table_name);
    END LOOP;
END
$$ LANGUAGE plpgsql;

-- Performs the final steps needed to setup all of the child tables for
-- schedule B.
CREATE OR REPLACE FUNCTION finalize_itemized_schedule_b_tables(start_year NUMERIC, end_year NUMERIC, p_use_tmp BOOLEAN, p_create_primary_key BOOLEAN) RETURNS VOID AS $$
DECLARE
    child_table_root TEXT;
    child_table_name TEXT;
    index_name_suffix TEXT;
BEGIN
    FOR cycle in start_year..end_year BY 2 LOOP
        child_table_root = format('ofec_sched_b_%s_%s', cycle - 1, cycle);
        IF p_use_tmp THEN
            child_table_name = format('ofec_sched_b_%s_%s_tmp', cycle - 1, cycle);
            index_name_suffix = '_tmp';
        ELSE
            child_table_name = format('ofec_sched_b_%s_%s', cycle - 1, cycle);
            index_name_suffix = '';
        END IF;

        -- Create indexes.
        -- Note:  The multi-column GIN indexes require the btree_gin extension
        --        https://www.postgresql.org/docs/current/static/btree-gin.html
        --        This is installed but not enabled in RDS by default, it must
        --        be turned on with this: CREATE EXTENSION btree_gin;

        -- Indexes for searching
          -- for sorting by date
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_image_num_dt%s ON %I (image_num, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_clean_recipient_cmte_id_dt%s ON %I (clean_recipient_cmte_id, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_recipient_city_dt%s ON %I (recipient_city, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_recipient_st_dt%s ON %I (recipient_st, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_rpt_yr_dt%s ON %I (rpt_yr, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_two_year_transaction_period_dt%s ON %I (two_year_transaction_period, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_line_num_dt%s ON %I (line_num, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_amount_dt%s ON %I (disb_amt, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_cmte_id_dt%s ON %I (cmte_id, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);

        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_recip_name_text_dt%s ON %I USING GIN (recipient_name_text, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_disb_desc_text_dt%s ON %I USING GIN (disbursement_description_text, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);

          -- for sorting by amount
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_image_num_amt%s ON %I (image_num, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_clean_recipient_cmte_id_amt%s ON %I (clean_recipient_cmte_id, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_recipient_city_amt%s ON %I (recipient_city, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_recipient_st_amt%s ON %I (recipient_st, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_rpt_yr_amt%s ON %I (rpt_yr, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_two_year_transaction_period_amt%s ON %I (two_year_transaction_period, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_line_num_amt%s ON %I (line_num, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_date_amt%s ON %I (disb_dt, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_cmte_id_amt%s ON %I (cmte_id, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);

        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_recip_name_text_amt%s ON %I USING GIN (recipient_name_text, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_disb_desc_text_amt%s ON %I USING GIN (disbursement_description_text, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);

        -- Other indexes
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_cmte_id_disb_amt_sub_id%s ON %I (cmte_id, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_cmte_id_disb_dt_sub_id%s ON %I (cmte_id, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_pg_date%s ON %I (pg_date)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE UNIQUE INDEX IF NOT EXISTS idx_%s_sub_id%s ON %I (sub_id)', child_table_root, index_name_suffix, child_table_name);

        -- Create the primary key if needed
        IF p_create_primary_key THEN
            EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY USING INDEX idx_%s_sub_id%s', child_table_name, child_table_root, index_name_suffix);
        END IF;

        -- Set statistics and analyze the table.
        EXECUTE format('ALTER TABLE %I ALTER COLUMN recipient_st SET STATISTICS 1000', child_table_name);
        EXECUTE format('ANALYZE %I', child_table_name);
    END LOOP;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rename_table_cascade(table_name TEXT) RETURNS VOID AS $$
DECLARE
    child_tmp_table_name TEXT;
    child_table_name TEXT;
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
        child_table_name =  regexp_replace(child_tmp_table_name, '_tmp$', '');
        EXECUTE format('ALTER TABLE %1$I RENAME TO %2$I', child_tmp_table_name, child_table_name);
        PERFORM rename_indexes(child_table_name);
    END LOOP;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rename_indexes(p_table_name TEXT) RETURNS VOID AS $$
DECLARE
    indexes_cursor CURSOR FOR
        SELECT indexname AS name
        FROM pg_indexes
        WHERE tablename = p_table_name;
BEGIN

    FOR index_name IN indexes_cursor LOOP
        EXECUTE format('ALTER INDEX %1$I RENAME TO %2$I', index_name.name, regexp_replace(index_name.name, '_tmp$', ''));
    END LOOP;
END
$$ LANGUAGE plpgsql;
