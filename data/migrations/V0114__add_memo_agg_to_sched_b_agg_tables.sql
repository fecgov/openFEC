--==================================================================
--	disclosure.dsc_sched_b_aggregate_purpose
--==================================================================
DO $$
BEGIN
    EXECUTE format('CREATE SEQUENCE public.ofec_sched_b_aggregate_purpose_new_idx_seq1 INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;');

    EXECUTE format('CREATE TABLE disclosure.dsc_sched_b_aggregate_purpose_new
	(
	  cmte_id character varying(9),
	  cycle numeric,
	  purpose character varying,
	  non_memo_total numeric,
	  non_memo_count bigint,
	  memo_total numeric,
	  memo_count bigint,
	  idx integer NOT NULL DEFAULT nextval(''ofec_sched_b_aggregate_purpose_new_idx_seq1''::regclass),
	  CONSTRAINT uq_dsc_sched_b_agg_purpose_new_cmte_id_cycle_purpose_new UNIQUE (cmte_id, cycle, purpose)
	)
	WITH (
	  OIDS=FALSE
	);');
	
	
    EXECUTE format('CREATE INDEX dsc_sched_b_agg_purpose_new_cmte_id
	  ON disclosure.dsc_sched_b_aggregate_purpose_new
	  USING btree
	  (cmte_id COLLATE pg_catalog."default");');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_purpose_new_cycle
	  ON disclosure.dsc_sched_b_aggregate_purpose_new
	  USING btree
	  (cycle);');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_purpose_new_cycle_cmte_id
	  ON disclosure.dsc_sched_b_aggregate_purpose_new
	  USING btree
	  (cycle, cmte_id COLLATE pg_catalog."default");');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_purpose_new_purpose_new
	  ON disclosure.dsc_sched_b_aggregate_purpose_new
	  USING btree
	  (purpose COLLATE pg_catalog."default");');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_purpose_new_non_memo_count
	  ON disclosure.dsc_sched_b_aggregate_purpose_new
	  USING btree
	  (non_memo_count);');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_purpose_new_non_memo_total
	  ON disclosure.dsc_sched_b_aggregate_purpose_new
	  USING btree
	  (non_memo_total);');
  
  
    EXCEPTION 
             WHEN duplicate_table THEN 
		null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ALTER TABLE IF EXISTS public.ofec_sched_b_aggregate_purpose_new_idx_seq1 OWNER TO fec;

ALTER TABLE disclosure.dsc_sched_b_aggregate_purpose_new OWNER TO fec;
GRANT ALL ON TABLE disclosure.dsc_sched_b_aggregate_purpose_new TO fec;
GRANT SELECT ON TABLE disclosure.dsc_sched_b_aggregate_purpose_new TO fec_read;




--==================================================================
--	disclosure.dsc_sched_b_aggregate_recipient
--==================================================================
DO $$
BEGIN
    EXECUTE format('CREATE SEQUENCE public.ofec_sched_b_aggregate_recipient_new_idx_seq1 INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;');
    
    EXECUTE format('CREATE TABLE disclosure.dsc_sched_b_aggregate_recipient_new
	(
	  cmte_id character varying(9),
	  cycle numeric,
	  recipient_nm character varying(200),
	  non_memo_total numeric,
	  non_memo_count bigint,
	  memo_total numeric,
	  memo_count bigint,
	  idx integer NOT NULL DEFAULT nextval(''ofec_sched_b_aggregate_recipient_new_idx_seq1''::regclass),
	  CONSTRAINT uq_dsc_sched_b_agg_recpnt_new_cmte_id_cycle_recpnt_new UNIQUE (cmte_id, cycle, recipient_nm)
	)
	WITH (
	  OIDS=FALSE
	);');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_recpnt_new_cmte_id
	  ON disclosure.dsc_sched_b_aggregate_recipient_new
	  USING btree
	  (cmte_id COLLATE pg_catalog."default");');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_recpnt_new_cycle
	  ON disclosure.dsc_sched_b_aggregate_recipient_new
	  USING btree
	  (cycle);');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_recpnt_new_cycle_cmte_id
	  ON disclosure.dsc_sched_b_aggregate_recipient_new
	  USING btree
	  (cycle, cmte_id COLLATE pg_catalog."default");');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_recpnt_new_recpnt_nm
	  ON disclosure.dsc_sched_b_aggregate_recipient_new
	  USING btree
	  (recipient_nm COLLATE pg_catalog."default");');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_recpnt_new_non_memo_count
	  ON disclosure.dsc_sched_b_aggregate_recipient_new
	  USING btree
	  (non_memo_count);');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_recpnt_new_non_memo_total
	  ON disclosure.dsc_sched_b_aggregate_recipient_new
	  USING btree
	  (non_memo_total);');

    EXCEPTION 
             WHEN duplicate_table THEN 
		null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE IF EXISTS public.ofec_sched_b_aggregate_recipient_new_idx_seq1 OWNER TO fec;

ALTER TABLE disclosure.dsc_sched_b_aggregate_recipient_new OWNER TO fec;
GRANT ALL ON TABLE disclosure.dsc_sched_b_aggregate_recipient_new TO fec;
GRANT SELECT ON TABLE disclosure.dsc_sched_b_aggregate_recipient_new TO fec_read;


--==================================================================
--	disclosure.dsc_sched_b_aggregate_recipient_id
--==================================================================
DO $$
BEGIN
    EXECUTE format('CREATE SEQUENCE public.ofec_sched_b_aggregate_recipient_id_new_idx_seq1 INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;');

    EXECUTE format('CREATE TABLE disclosure.dsc_sched_b_aggregate_recipient_id_new
	(
	  cmte_id character varying(9),
	  cycle numeric,
	  recipient_cmte_id character varying,
	  recipient_nm text,
	  non_memo_total numeric,
	  non_memo_count bigint,
	  memo_total numeric,
	  memo_count bigint,
	  idx integer NOT NULL DEFAULT nextval(''ofec_sched_b_aggregate_recipient_id_new_idx_seq1''::regclass),
	  CONSTRAINT uq_sched_b_agg_recpnt_id_cmte_id_cycle_recpnt_cmte_id UNIQUE (cmte_id, cycle, recipient_cmte_id)
	)
	WITH (
	  OIDS=FALSE
	);');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_recpnt_id_new_cmte_id
	  ON disclosure.dsc_sched_b_aggregate_recipient_id_new
	  USING btree
	  (cmte_id COLLATE pg_catalog."default");');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_recpnt_id_new_cycle
	  ON disclosure.dsc_sched_b_aggregate_recipient_id_new
	  USING btree
	  (cycle);');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_recpnt_id_new_cycle_cmte_id
	  ON disclosure.dsc_sched_b_aggregate_recipient_id_new
	  USING btree
	  (cycle, cmte_id COLLATE pg_catalog."default");');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_recpnt_id_new_recpnt_cmte_id
	  ON disclosure.dsc_sched_b_aggregate_recipient_id_new
	  USING btree
	  (recipient_cmte_id COLLATE pg_catalog."default");');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_recpnt_id_new_non_memo_count
	  ON disclosure.dsc_sched_b_aggregate_recipient_id_new
	  USING btree
	  (non_memo_count);');

    EXECUTE format('CREATE INDEX dsc_sched_b_agg_recpnt_id_new_non_memo_total
	  ON disclosure.dsc_sched_b_aggregate_recipient_id_new
	  USING btree
	  (non_memo_total);');

    EXCEPTION 
             WHEN duplicate_table THEN 
		null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ALTER TABLE IF EXISTS public.ofec_sched_b_aggregate_recipient_id_new_idx_seq1 OWNER TO fec;

ALTER TABLE disclosure.dsc_sched_b_aggregate_recipient_id_new OWNER TO fec;
GRANT ALL ON TABLE disclosure.dsc_sched_b_aggregate_recipient_id_new TO fec;
GRANT SELECT ON TABLE disclosure.dsc_sched_b_aggregate_recipient_id_new TO fec_read;

--==================================================================
