-- Create trigger for the master partition table to be created later, once the
-- master partition table is in place.
CREATE OR REPLACE FUNCTION insert_sched_master() RETURNS TRIGGER AS $$
DECLARE
    child_table_prefix TEXT = TG_ARGV[0];
    child_table_name TEXT;
BEGIN
    child_table_name = child_table_prefix || get_partition_suffix(new.two_year_transaction_period);
    EXECUTE format('INSERT INTO %I VALUES ($1.*)', child_table_name)
        USING new;

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

        -- Create the child table.
        EXECUTE format('CREATE TABLE %I (
            CHECK ( two_year_transaction_period in (%s, %s) )
        ) INHERITS (%I)', child_table_name, cycle - 1, cycle, master_table_name);

        -- Add additional constraints.
        --EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY (sub_id)', child_table_name);
    END LOOP;
END
$$ LANGUAGE plpgsql;


-- Performs the final steps needed to setup all of the child tables for
-- schedule A.
CREATE OR REPLACE FUNCTION finalize_itemized_schedule_a_tables(start_year NUMERIC, end_year NUMERIC) RETURNS VOID AS $$
DECLARE
    child_table_name TEXT;
BEGIN
    FOR cycle in start_year..end_year BY 2 LOOP
        child_table_name = format('ofec_sched_a_%s_%s_tmp', cycle - 1, cycle);

        -- Create indexes.
        EXECUTE format('CREATE UNIQUE INDEX idx_%s_sub_id_tmp ON %I (sub_id)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY (sub_id) USING INDEX idx_%s_sub_id_tmp', child_table_name, trim(trailing '_tmp' from child_table_name));
        EXECUTE format('CREATE INDEX idx_%s_rpt_yr_tmp ON %I (rpt_yr)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_pg_date_tmp ON %I (pg_date)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_entity_tp_tmp ON %I (entity_tp)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_image_num_tmp ON %I (image_num)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_contbr_st_tmp ON %I (contbr_st)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_contbr_city_tmp ON %I (contbr_city)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_is_individual_tmp ON %I (is_individual)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_clean_contbr_id_tmp ON %I (clean_contbr_id)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_two_year_transaction_period_tmp ON %I (two_year_transaction_period)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_sub_id_amount_tmp ON %I (contb_receipt_amt, sub_id)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_sub_id_date_tmp ON %I (contb_receipt_dt, sub_id)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_sub_id_cmte_id_tmp ON %I (cmte_id, sub_id)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_sub_id_cmte_id_amount_tmp ON %I (cmte_id, contb_receipt_amt, sub_id)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_sub_id_cmte_id_date_tmp ON %I (cmte_id, contb_receipt_dt, sub_id)', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_contributor_name_text_tmp ON %I (contributor_name_text) USING GIN', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_contributor_employer_text_tmp ON %I (contributor_employer_text) USING GIN', trim(trailing '_tmp' from child_table_name), child_table_name);
        EXECUTE format('CREATE INDEX idx_%s_contributor_occupation_text_tmp ON %I (contributor_occupation_text) USING GIN', trim(trailing '_tmp' from child_table_name), child_table_name);

        -- Set statistics and analyze the table.
        EXECUTE format('ALTER TABLE %I ALTER COLUMN contbr_st SET STATISTICS 1000', child_table_name);
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
-- couldn't be found in the public.fec_vsum_sched_a_vw or
-- public.fec_vsum_sched_b_vw views, the sub_id will remain in the
-- ofec_sched_a_nightly_retries/ofec_sched_b_nightly_retries table until it is.

-- Convenience function that takes care of all of the processing at once.
CREATE OR REPLACE FUNCTION retry_processing_itemized_records() RETURNS VOID AS $$
BEGIN
    PERFORM retry_processing_schedule_a_records(:START_YEAR_AGGREGATE);
    PERFORM retry_processing_schedule_b_records(:START_YEAR_AGGREGATE);
END
$$ LANGUAGE plpgsql;
