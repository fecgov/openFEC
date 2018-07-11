
-- ------------------
-- 	functions and triggers
-- ------------------
DROP TRIGGER IF EXISTS nml_sched_b_after_trigger ON disclosure.nml_sched_b;
DROP TRIGGER IF EXISTS nml_sched_b_before_trigger ON disclosure.nml_sched_b;

DROP TRIGGER IF EXISTS f_item_sched_b_before_trigger ON disclosure.f_item_receipt_or_exp;
DROP TRIGGER IF EXISTS f_item_sched_b_after_trigger ON disclosure.f_item_receipt_or_exp;

-- trigger functions
drop function IF EXISTS public.ofec_sched_b_delete_update_queues();
drop function IF EXISTS public.ofec_sched_b_insert_update_queues();
drop function IF EXISTS public.ofec_sched_b_update_queues();

-- functions
drop function IF EXISTS public.ofec_sched_b_update_fulltext();
drop function IF EXISTS public.ofec_sched_b_update();

drop function IF EXISTS public.drop_old_itemized_schedule_b_indexes(numeric, numeric); 

-- ------------------
-- Function: public.add_partition_cycles(numeric, numeric)
-- ------------------
CREATE OR REPLACE FUNCTION public.add_partition_cycles(
    start_year numeric,
    amount numeric)
  RETURNS void AS
$BODY$

DECLARE

    first_cycle_end_year NUMERIC = get_cycle(start_year);

    last_cycle_end_year NUMERIC = first_cycle_end_year + (amount - 1) * 2;

    master_table_name TEXT;

    child_table_name TEXT;

    schedule TEXT;

BEGIN

    FOR cycle IN first_cycle_end_year..last_cycle_end_year BY 2 LOOP

        FOREACH schedule IN ARRAY ARRAY['a'] LOOP

            master_table_name = format('ofec_sched_%s_master', schedule);

            child_table_name = format('ofec_sched_%s_%s_%s', schedule, cycle - 1, cycle);

            EXECUTE format('CREATE TABLE %I (

                CHECK ( two_year_transaction_period in (%s, %s) )

            ) INHERITS (%I)', child_table_name, cycle - 1, cycle, master_table_name);



        END LOOP;

    END LOOP;

    PERFORM finalize_itemized_schedule_a_tables(first_cycle_end_year, last_cycle_end_year, FALSE, TRUE);
 
END

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.add_partition_cycles(numeric, numeric)
  OWNER TO fec;


DROP FUNCTION IF EXISTS public.finalize_itemized_schedule_b_tables(numeric, numeric, boolean, boolean);

-- ------------------
-- FUNCTION disclosure.finalize_itemized_schedule_b_tables
-- ------------------
CREATE OR REPLACE FUNCTION disclosure.finalize_itemized_schedule_b_tables(
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

        child_table_name = format('fec_fitem_sched_b_%s_%s', cycle - 1, cycle);
        
    child_index_root = format('idx_sched_b_%s_%s', cycle - 1, cycle);


        IF p_use_tmp THEN

            child_table_name = format('fec_fitem_sched_b_%s_%s_tmp', cycle - 1, cycle);

            index_name_suffix = '_tmp';


        END IF;


    -- coalesce disb_dt
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_cln_rcpt_cmte_id_colsc_disb_dt_sub_id%s ON %I USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_rcpt_st_colsc_disb_dt_sub_id%s ON %I USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_rcpt_city_colsc_disb_dt_sub_id%s ON %I USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_cmte_id_colsc_disb_dt_sub_id%s ON %I USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_disb_desc_text_colsc_disb_dt_sub_id%s ON %I USING gin (disbursement_description_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_image_num_colsc_disb_dt_sub_id%s ON %I USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_rcpt_name_text_colsc_disb_dt_sub_id%s ON %I USING gin (recipient_name_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_rpt_yr_colsc_disb_dt_sub_id%s ON %I USING btree (rpt_yr, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_line_num_colsc_disb_dt_sub_id%s ON %I USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_disb_amt_colsc_disb_dt_sub_id%s ON %I USING btree (disb_amt, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_colsc_disb_dt_sub_id%s ON %I USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
    -- disb_amt
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_cln_rcpt_cmte_id_disb_amt_sub_id%s ON %I USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_rcpt_st_disb_amt_sub_id%s ON %I  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_rcpt_city_disb_amt_sub_id%s ON %I USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_cmte_id_disb_amt_sub_id%s ON %I USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_disb_desc_text_disb_amt_sub_id%s ON %I USING gin (disbursement_description_text, disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_image_num_disb_amt_sub_id%s ON %I USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_rcpt_name_text_disb_amt_sub_id%s ON %I USING gin (recipient_name_text, disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_rpt_yr_disb_amt_sub_id%s ON %I USING btree (rpt_yr, disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_line_num_disb_amt_sub_id%s ON %I USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_disb_amt_sub_id%s ON %I USING btree (disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
    -- disb_dt
        EXECUTE format('CREATE INDEX IF NOT EXISTS %s_disb_dt%s ON %I USING btree (disb_dt)', child_index_root, index_name_suffix, child_table_name);



        IF p_create_primary_key THEN

            EXECUTE format('ALTER TABLE %I ADD CONSTRAINT %s_pkey PRIMARY KEY (sub_id)', child_table_name, child_table_name);

        END IF;


        EXECUTE format('ANALYZE %I', child_table_name);

    END LOOP;

END

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.finalize_itemized_schedule_b_tables(numeric, numeric, boolean, boolean)
  OWNER TO fec;

-- ------------------
-- 	tables
-- ------------------
drop table if exists public.ofec_sched_b_queue_new;
drop table if exists public.ofec_sched_b_queue_old;
drop table if exists public.ofec_sched_b_fulltext;
drop table if exists public.ofec_sched_b_1977_1978;
drop table if exists public.ofec_sched_b_1979_1980;
drop table if exists public.ofec_sched_b_1981_1982;
drop table if exists public.ofec_sched_b_1983_1984;
drop table if exists public.ofec_sched_b_1985_1986;
drop table if exists public.ofec_sched_b_1987_1988;
drop table if exists public.ofec_sched_b_1989_1990;
drop table if exists public.ofec_sched_b_1991_1992;
drop table if exists public.ofec_sched_b_1993_1994;
drop table if exists public.ofec_sched_b_1995_1996;
drop table if exists public.ofec_sched_b_1997_1998;
drop table if exists public.ofec_sched_b_1999_2000;
drop table if exists public.ofec_sched_b_2001_2002;
drop table if exists public.ofec_sched_b_2003_2004;
drop table if exists public.ofec_sched_b_2005_2006;
drop table if exists public.ofec_sched_b_2007_2008;
drop table if exists public.ofec_sched_b_2009_2010;
drop table if exists public.ofec_sched_b_2011_2012;
drop table if exists public.ofec_sched_b_2013_2014;
drop table if exists public.ofec_sched_b_2015_2016;
drop table if exists public.ofec_sched_b_2017_2018;
drop table if exists public.ofec_sched_b_master;



