/*
This is for issue #3657
The tables were already created as part of the Java transfer process when it first encountered the incoming data for cycle 2019/2020 so we will not miss any incoming data. 
However, official migration script is need to add these to the version controlled base of the database structure.

*/
-- -----------------------------------------------------
-- finalize_itemized_schedule_a_tables
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION disclosure.finalize_itemized_schedule_a_tables(
    start_year numeric,
    end_year numeric,
    p_use_tmp boolean DEFAULT false,
    p_create_primary_key boolean DEFAULT false)
  RETURNS void AS
$BODY$

DECLARE

    child_table_name TEXT;
    child_index_root TEXT;
    index_name_suffix TEXT default '';

BEGIN


    FOR cycle in start_year..end_year BY 2 LOOP

        child_table_name = format('disclosure.fec_fitem_sched_a_%s_%s', cycle - 1, cycle);
        
    child_index_root = format('idx_sched_a_%s_%s', cycle - 1, cycle);


        IF p_use_tmp THEN

            child_table_name = format('disclosure.fec_fitem_sched_a_%s_%s_tmp', cycle - 1, cycle);

            index_name_suffix = '_tmp';


        END IF;

    -- contb_receipt_amt
        EXECUTE format('CREATE INDEX %s_clean_contbr_id_amt_sub_id %s ON %s USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contbr_city_amt_sub_id %s ON %s USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contbr_st_amt_sub_id %s ON %s USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_image_num_amt_sub_id %s ON %s USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_id_amt_sub_id %s ON %s USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_line_num_amt_sub_id %s ON %s USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contrib_occ_text_amt_sub_id %s ON %s USING gin (contributor_occupation_text, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_dt_amt_sub_id %s ON %s USING btree (contb_receipt_dt, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_two_year_period_amt_sub_id %s ON %s USING btree (two_year_transaction_period, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contrib_emp_text_amt_sub_id %s ON %s USING gin (contributor_employer_text, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contrib_name_text_amt_sub_id %s ON %s USING gin (contributor_name_text, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);

        EXECUTE format('CREATE INDEX %s_cmte_tp_rcpt_amt_sub_id %s ON %s USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
    -- contb_receipt_dt
        EXECUTE format('CREATE INDEX %s_clean_contbr_id_dt_sub_id %s ON %s USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contbr_city_dt_sub_id %s ON %s USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contbr_st_dt_sub_id %s ON %s USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_image_num_dt_sub_id %s ON %s USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_id_dt_sub_id %s ON %s USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_line_num_dt_sub_id %s ON %s USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_amt_dt_sub_id %s ON %s USING btree (contb_receipt_amt, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_two_year_period_dt_sub_id %s ON %s USING btree (two_year_transaction_period, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contrib_occ_text_dt_sub_id %s ON %s USING gin (contributor_occupation_text, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contrib_emp_text_dt_sub_id %s ON %s USING gin (contributor_employer_text, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contrib_name_text_dt_sub_id %s ON %s USING gin (contributor_name_text, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);

        EXECUTE format('CREATE INDEX %s_cmte_tp_colsc_rcpt_dt_sub_id %s ON %s USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
    --
        EXECUTE format('CREATE INDEX %s_contbr_zip %s ON %s USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_entity_tp %s ON %s USING btree (entity_tp COLLATE pg_catalog."default")', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rpt_yr %s ON %s USING btree (rpt_yr)', child_index_root, index_name_suffix, child_table_name);

    IF p_create_primary_key THEN

            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %s_pkey PRIMARY KEY (sub_id)', child_table_name, child_table_name);

        END IF;


        EXECUTE format('ANALYZE %s', child_table_name);

    END LOOP;

END

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.finalize_itemized_schedule_a_tables(numeric, numeric, boolean, boolean)
  OWNER TO fec;
  

-- -----------------------------------------------------
-- finalize_itemized_schedule_b_tables
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION disclosure.finalize_itemized_schedule_b_tables(
    start_year numeric,
    end_year numeric,
    p_use_tmp boolean DEFAULT false,
    p_create_primary_key boolean DEFAULT false)
  RETURNS void AS
$BODY$

DECLARE

    child_table_name TEXT;
    
    child_index_root TEXT;

    index_name_suffix TEXT default '';

BEGIN


    FOR cycle in start_year..end_year BY 2 LOOP

        child_table_name = format('disclosure.fec_fitem_sched_b_%s_%s', cycle - 1, cycle);
        
    child_index_root = format('idx_sched_b_%s_%s', cycle - 1, cycle);


        IF p_use_tmp THEN

            child_table_name = format('disclosure.fec_fitem_sched_b_%s_%s_tmp', cycle - 1, cycle);

            index_name_suffix = '_tmp';


        END IF;


    -- coalesce disb_dt
        EXECUTE format('CREATE INDEX %s_cln_rcpt_cmte_id_colsc_disb_dt_sub_id%s ON %s USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rcpt_st_colsc_disb_dt_sub_id%s ON %s USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rcpt_city_colsc_disb_dt_sub_id%s ON %s USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_id_colsc_disb_dt_sub_id%s ON %s USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_disb_desc_text_colsc_disb_dt_sub_id%s ON %s USING gin (disbursement_description_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_image_num_colsc_disb_dt_sub_id%s ON %s USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rcpt_name_text_colsc_disb_dt_sub_id%s ON %s USING gin (recipient_name_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rpt_yr_colsc_disb_dt_sub_id%s ON %s USING btree (rpt_yr, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_line_num_colsc_disb_dt_sub_id%s ON %s USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_disb_amt_colsc_disb_dt_sub_id%s ON %s USING btree (disb_amt, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_tp_colsc_disb_dt_sub_id%s ON %s USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_colsc_disb_dt_sub_id%s ON %s USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
    -- disb_amt
        EXECUTE format('CREATE INDEX %s_cln_rcpt_cmte_id_disb_amt_sub_id%s ON %s USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rcpt_st_disb_amt_sub_id%s ON %s  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rcpt_city_disb_amt_sub_id%s ON %s USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_id_disb_amt_sub_id%s ON %s USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_disb_desc_text_disb_amt_sub_id%s ON %s USING gin (disbursement_description_text, disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_image_num_disb_amt_sub_id%s ON %s USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rcpt_name_text_disb_amt_sub_id%s ON %s USING gin (recipient_name_text, disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rpt_yr_disb_amt_sub_id%s ON %s USING btree (rpt_yr, disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_line_num_disb_amt_sub_id%s ON %s USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_tp_disb_amt_sub_id%s ON %s USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_disb_amt_sub_id%s ON %s USING btree (disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
    -- disb_dt
        EXECUTE format('CREATE INDEX %s_disb_dt%s ON %s USING btree (disb_dt)', child_index_root, index_name_suffix, child_table_name);



        IF p_create_primary_key THEN

            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %s_pkey PRIMARY KEY (sub_id)', child_table_name, child_table_name);

        END IF;


        EXECUTE format('ANALYZE %s', child_table_name);

    END LOOP;

END

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.finalize_itemized_schedule_b_tables(numeric, numeric, boolean, boolean)
  OWNER TO fec;


-- -----------------------------------------------------
-- create table disclosure.fec_fitem_sched_a_2019_2020
-- -----------------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE disclosure.fec_fitem_sched_a_2019_2020
(
  CONSTRAINT fec_fitem_sched_a_2019_2020_pkey PRIMARY KEY (sub_id),
  CONSTRAINT check_two_year_transaction_period CHECK (two_year_transaction_period = ANY (ARRAY[2019, 2020]::numeric[]))
)
INHERITS (disclosure.fec_fitem_sched_a)
WITH (
  OIDS=FALSE
)');
	EXCEPTION 
             WHEN duplicate_table THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


DO $$
BEGIN
	EXECUTE format('CREATE TRIGGER tri_fec_fitem_sched_a_2019_2020
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_2019_2020
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert()');
	EXCEPTION 
             WHEN duplicate_object THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;



ALTER TABLE disclosure.fec_fitem_sched_a_2019_2020
  OWNER TO fec;
GRANT ALL ON TABLE disclosure.fec_fitem_sched_a_2019_2020 TO fec;
GRANT SELECT ON TABLE disclosure.fec_fitem_sched_a_2019_2020 TO fec_read;
GRANT SELECT ON TABLE disclosure.fec_fitem_sched_a_2019_2020 TO openfec_read;



-- -----------------------------------------------------
-- create table disclosure.fec_fitem_sched_b_2019_2020
-- -----------------------------------------------------
DO $$
BEGIN
    	EXECUTE format('CREATE TABLE disclosure.fec_fitem_sched_b_2019_2020
(
  CONSTRAINT fec_fitem_sched_b_2019_2020_pkey PRIMARY KEY (sub_id),
  CONSTRAINT check_two_year_transaction_period CHECK (two_year_transaction_period = ANY (ARRAY[2019, 2020]::numeric[]))
)
INHERITS (disclosure.fec_fitem_sched_b)
WITH (
  OIDS=FALSE
)');
	EXCEPTION 
             WHEN duplicate_table THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE TRIGGER tri_fec_fitem_sched_b_2019_2020
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_2019_2020
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert()');
	EXCEPTION 
             WHEN duplicate_object THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;



ALTER TABLE disclosure.fec_fitem_sched_b_2019_2020
  OWNER TO fec;
GRANT ALL ON TABLE disclosure.fec_fitem_sched_b_2019_2020 TO fec;
GRANT SELECT ON TABLE disclosure.fec_fitem_sched_b_2019_2020 TO fec_read;
GRANT SELECT ON TABLE disclosure.fec_fitem_sched_b_2019_2020 TO openfec_read;


-- -----------------------------------------------------
-- Add indexes to disclosure.fec_fitem_sched_a_2019_2020 
-- -----------------------------------------------------
DO $$
BEGIN
    EXECUTE format('select disclosure.finalize_itemized_schedule_a_tables (2020, 2020)');


      	EXCEPTION 
             WHEN duplicate_table THEN 
		null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------------------------------------------
-- Add indexes to disclosure.fec_fitem_sched_b_2019_2020
-- -----------------------------------------------------
DO $$
BEGIN
    EXECUTE format('select disclosure.finalize_itemized_schedule_b_tables (2020, 2020)');


        EXCEPTION 
             WHEN duplicate_table THEN 
        null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;