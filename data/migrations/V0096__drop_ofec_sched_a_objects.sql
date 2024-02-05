
-- ------------------
-- 	functions and triggers
-- ------------------
DROP TRIGGER IF EXISTS nml_sched_a_after_trigger ON disclosure.nml_sched_a;
DROP TRIGGER IF EXISTS nml_sched_a_before_trigger ON disclosure.nml_sched_a;

DROP TRIGGER IF EXISTS f_item_sched_a_before_trigger ON disclosure.f_item_receipt_or_exp;
DROP TRIGGER IF EXISTS f_item_sched_a_after_trigger ON disclosure.f_item_receipt_or_exp;

DROP TRIGGER IF EXISTS insert_sched_a_trigger_tmp ON public.ofec_sched_a_master;

-- trigger functions
drop function IF EXISTS public.ofec_sched_a_delete_update_queues();
drop function IF EXISTS public.ofec_sched_a_insert_update_queues();
drop function IF EXISTS public.ofec_sched_a_update_queues();
drop function IF EXISTS public.insert_sched_master();

-- functions
drop function IF EXISTS public.add_partition_cycles(numeric, numeric);
drop function IF EXISTS public.create_itemized_schedule_partition(text, numeric, numeric);
drop function IF EXISTS public.get_projected_weekly_itemized_total(text);

drop function IF EXISTS public.drop_old_itemized_schedule_a_indexes(numeric, numeric);
drop function IF EXISTS public.ofec_sched_a_update();
drop function IF EXISTS public.ofec_sched_a_update_fulltext();

drop function IF EXISTS public.ofec_sched_a_update_aggregate_contributor();
drop function IF EXISTS public.ofec_sched_a_update_aggregate_contributor_type();

drop function IF EXISTS public.finalize_itemized_schedule_a_tables(numeric, numeric, boolean, boolean);

-- Originally extension pg_trgm had been created with schema "public"
-- Need to be with schema pg_catalog 
-- otherwise the execution of disclosure.finalize_itemized_schedule_a_tables will have error

-- migrator does not have permission to make the following change
-- alter extension pg_trgm set schema pg_catalog;

-- ------------------
-- FUNCTION disclosure.finalize_itemized_schedule_a_tables
-- ------------------
CREATE OR REPLACE FUNCTION disclosure.finalize_itemized_schedule_a_tables(
    start_year numeric,
    end_year numeric,
    p_use_tmp boolean default false,
    p_create_primary_key boolean default false)
  RETURNS void AS
$BODY$

DECLARE

    child_table_name TEXT;
    child_index_root TEXT;
    index_name_suffix TEXT default '';

BEGIN

    SET search_path = disclosure, pg_catalog;


    FOR cycle in start_year..end_year BY 2 LOOP

        child_table_name = format('fec_fitem_sched_a_%s_%s', cycle - 1, cycle);
        
    child_index_root = format('idx_sched_a_%s_%s', cycle - 1, cycle);


        IF p_use_tmp THEN

            child_table_name = format('fec_fitem_sched_a_%s_%s_tmp', cycle - 1, cycle);

            index_name_suffix = '_tmp';


        END IF;

    -- contb_receipt_amt
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_clean_contbr_id_amt_sub_id %s ON %I USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_contbr_city_amt_sub_id %s ON %I USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_contbr_st_amt_sub_id %s ON %I USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_image_num_amt_sub_id %s ON %I USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_cmte_id_amt_sub_id %s ON %I USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_line_num_amt_sub_id %s ON %I USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_contrib_occ_text_amt_sub_id %s ON %I USING gin (contributor_occupation_text, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_dt_amt_sub_id %s ON %I USING btree (contb_receipt_dt, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_two_year_period_amt_sub_id %s ON %I USING btree (two_year_transaction_period, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_contrib_emp_text_amt_sub_id %s ON %I USING gin (contributor_employer_text, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_contrib_name_text_amt_sub_id %s ON %I USING gin (contributor_name_text, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
    -- contb_receipt_dt
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_clean_contbr_id_dt_sub_id %s ON %I USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_contbr_city_dt_sub_id %s ON %I USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_contbr_st_dt_sub_id %s ON %I USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_image_num_dt_sub_id %s ON %I USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_cmte_id_dt_sub_id %s ON %I USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_line_num_dt_sub_id %s ON %I USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_amt_dt_sub_id %s ON %I USING btree (contb_receipt_amt, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_two_year_period_dt_sub_id %s ON %I USING btree (two_year_transaction_period, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_contrib_occ_text_dt_sub_id %s ON %I USING gin (contributor_occupation_text, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_contrib_emp_text_dt_sub_id %s ON %I USING gin (contributor_employer_text, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_contrib_name_text_dt_sub_id %s ON %I USING gin (contributor_name_text, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
    --
        --EXECUTE format('CREATE INDEX IF NOT EXISTS %s_contbr_zip %s ON %I USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_entity_tp %s ON %I USING btree (entity_tp COLLATE pg_catalog."default")', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_rpt_yr %s ON %I USING btree (rpt_yr)', child_index_root, index_name_suffix, child_table_name);

    IF p_create_primary_key THEN

            EXECUTE format('ALTER TABLE %I ADD CONSTRAINT %s_pkey PRIMARY KEY (sub_id)', child_table_name, child_table_name);

        END IF;


        EXECUTE format('ANALYZE %I', child_table_name);

    END LOOP;

END

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.finalize_itemized_schedule_a_tables(numeric, numeric, boolean, boolean)
  OWNER TO fec;

-- ------------------
-- 	tables
-- ------------------
drop table if exists public.ofec_sched_a_queue_new;
drop table if exists public.ofec_sched_a_queue_old;
drop table if exists public.ofec_sched_a_fulltext;
drop table if exists public.ofec_sched_a_1977_1978;
drop table if exists public.ofec_sched_a_1979_1980;
drop table if exists public.ofec_sched_a_1981_1982;
drop table if exists public.ofec_sched_a_1983_1984;
drop table if exists public.ofec_sched_a_1985_1986;
drop table if exists public.ofec_sched_a_1987_1988;
drop table if exists public.ofec_sched_a_1989_1990;
drop table if exists public.ofec_sched_a_1991_1992;
drop table if exists public.ofec_sched_a_1993_1994;
drop table if exists public.ofec_sched_a_1995_1996;
drop table if exists public.ofec_sched_a_1997_1998;
drop table if exists public.ofec_sched_a_1999_2000;
drop table if exists public.ofec_sched_a_2001_2002;
drop table if exists public.ofec_sched_a_2003_2004;
drop table if exists public.ofec_sched_a_2005_2006;
drop table if exists public.ofec_sched_a_2007_2008;
drop table if exists public.ofec_sched_a_2009_2010;
drop table if exists public.ofec_sched_a_2011_2012;
drop table if exists public.ofec_sched_a_2013_2014;
drop table if exists public.ofec_sched_a_2015_2016;
drop table if exists public.ofec_sched_a_2017_2018;
drop table if exists public.ofec_sched_a_master;
