-- ----------------------------
-- This migration file address Issue #3089: Switching API to the fecp-driven sched_c, sched_e, sched_f, sched_d related tables
-- ----------------------------

-- ----------------------------
-- ----------------------------
-- disclosure.fec_fitem_sched_e
-- ----------------------------
-- ----------------------------
/*
mv public.ofec_sched_e_mv base on the FECP-driven tables had been created for ticket that add cmpte_tp, cand_id 
it had been used instead of ofec_sched_e table ever since.  

ofec_sched_e will be dropped in ticket #3100
*/

/*
public.ofec_sched_e_aggregate_candidate_mv:

fec_fitem_sched_e_vw <=> disclosure.fec_fitem_sched_e 
fec_fitem_f57_vw <=> disclosure.fec_fitem_f57

There is already election_cycle column in these tables (and views too) = (records.rpt_yr + records.rpt_yr % 2::numeric).  No need to calculate again

in original MV definition:
WHERE records.exp_amt IS NOT NULL AND (records.rpt_tp::text <> ALL (ARRAY['24'::character varying, '48'::character varying]::text[])) AND (records.memo_cd::text <> 'X'::text OR records.memo_cd IS NULL)

There is no rpt_tp '24', '48' in these two tables (f_itme tables sched_tp_cd = 'SE' does not include rpt_tp '24', '48'; disclosure.fec_fitem_f57 exclude data with rpt_tp '24', '48' while loading.
and disclosure.fec_fitem_f57 does not have memo_cd column

the un-necessary join of fec_fitem_f57_vw f57 JOIN fec_vsum_f5_vw cause problem.
fec_fitem_f57_vw () already has rpt_yr information from f_item table, no need to join to fec_vsum_f5_vw to get this information
*/
-- ----------------------------
-- ----------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_e_aggregate_candidate_mv_tmp; 


CREATE MATERIALIZED VIEW public.ofec_sched_e_aggregate_candidate_mv_tmp AS
 WITH records AS (
         SELECT se.cmte_id,
            se.s_o_cand_id AS cand_id,
            se.s_o_ind AS support_oppose_indicator,
            se.election_cycle as cycle,
            se.exp_amt
           FROM disclosure.fec_fitem_sched_e se
           WHERE (memo_cd::text <> 'X'::text OR memo_cd IS NULL)
        UNION ALL
         SELECT f57.filer_cmte_id AS cmte_id,
            f57.s_o_cand_id AS cand_id,
            f57.s_o_ind AS support_oppose_indicator,
            f57.election_cycle as cycle,
            f57.exp_amt
           FROM disclosure.fec_fitem_f57 f57
        )
 SELECT row_number() OVER () AS idx,
    records.cmte_id,
    records.cand_id,
    records.support_oppose_indicator,
    records.cycle,
    sum(records.exp_amt) AS total,
    count(records.exp_amt) AS count
   FROM records
  WHERE records.exp_amt IS NOT NULL  
  GROUP BY records.cmte_id, records.cand_id, records.support_oppose_indicator, records.cycle
WITH DATA;

ALTER TABLE public.ofec_sched_e_aggregate_candidate_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_e_aggregate_candidate_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_sched_e_aggregate_candidate_mv_tmp TO fec_read;

-- -----------------------
-- Add Indexes
-- Name of these indexes has errors (with tmp in the middle), this script also rename these indexes.  
-- Since these index name are different from the original MV and there is no need to add _tmp and renamed it later.
-- -----------------------
CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_s_o_indicator
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (support_oppose_indicator COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_cand_id
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (cand_id COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_cmte_id
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (cmte_id COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_count
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (count);

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_cycle_cand_id
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (cycle, cand_id COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_cycle_cmte_id
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (cycle, cmte_id COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_cycle
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (cycle);

CREATE UNIQUE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_idx
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (idx);

CREATE INDEX IF NOT EXISTS idx_ofec_sched_e_agg_cand_mv_total
  ON public.ofec_sched_e_aggregate_candidate_mv_tmp
  USING btree
  (total);
    
-- ------------------------------------
-- public.ofec_sched_e_aggregate_candidate_vw is not referenced by API nor other MV for now
-- So can directly drop it first
DROP VIEW IF EXISTS public.ofec_sched_e_aggregate_candidate_vw;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_e_aggregate_candidate_mv;
 
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_sched_e_aggregate_candidate_mv_tmp RENAME TO ofec_sched_e_aggregate_candidate_mv;

-- ------------------------------------
CREATE OR REPLACE VIEW public.ofec_sched_e_aggregate_candidate_vw AS 
SELECT * FROM public.ofec_sched_e_aggregate_candidate_mv;

ALTER TABLE public.ofec_sched_e_aggregate_candidate_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_e_aggregate_candidate_vw TO fec;
GRANT ALL ON TABLE public.ofec_sched_e_aggregate_candidate_vw TO fec_read;

-- ------------------------------------
  
-- ----------------------------
-- ----------------------------
-- disclosure.fec_fitem_sched_f
-- ----------------------------
-- ----------------------------
DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_f ADD COLUMN payee_name_text tsvector');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_f_insert()
  RETURNS trigger AS
$BODY$
begin
	new.payee_name_text := to_tsvector(new.pye_nm::text);

    	return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_f_insert()
  OWNER TO fec;

DROP TRIGGER IF EXISTS tri_fec_fitem_sched_f ON disclosure.fec_fitem_sched_f;

CREATE TRIGGER tri_fec_fitem_sched_f
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_f
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_f_insert();
  
/*

UPDATE disclosure.fec_fitem_sched_f SET payee_name_text = to_tsvector(pye_nm);

*/

-- -------------
-- Add indexes
-- -------------
DO $$
BEGIN

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_f_cand_id_sub_id
  ON disclosure.fec_fitem_sched_f
  USING btree
  (cand_id COLLATE pg_catalog."default", sub_id);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_f_cmte_id_sub_id
  ON disclosure.fec_fitem_sched_f
  USING btree
  (cmte_id COLLATE pg_catalog."default", sub_id);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_f_cycle_sub_id
  ON disclosure.fec_fitem_sched_f
  USING btree
  (election_cycle, sub_id);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_f_exp_amt_sub_id
  ON disclosure.fec_fitem_sched_f
  USING btree
  (exp_amt, sub_id);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_f_exp_dt_sub_id
  ON disclosure.fec_fitem_sched_f
  USING btree
  (exp_dt, sub_id);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_f_image_num_sub_id
  ON disclosure.fec_fitem_sched_f
  USING btree
  (image_num COLLATE pg_catalog."default", sub_id);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_f_payee_name_text
  ON disclosure.fec_fitem_sched_f
  USING gin
  (payee_name_text);');
  
  EXCEPTION 
    WHEN duplicate_table THEN 
      null;
    WHEN others THEN 
      RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- ----------------------------
-- ----------------------------
-- disclosure.fec_fitem_sched_c
-- ----------------------------
-- ----------------------------

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_c ADD COLUMN candidate_name_text tsvector');
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_c ADD COLUMN loan_source_name_text tsvector');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_c_insert()
  RETURNS trigger AS
$BODY$
begin
	new.candidate_name_text := to_tsvector(new.cand_nm::text);
	new.loan_source_name_text := to_tsvector(new.loan_src_nm::text);

    	return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_c_insert()
  OWNER TO fec;

DROP TRIGGER IF EXISTS tri_fec_fitem_sched_c ON disclosure.fec_fitem_sched_c;

CREATE TRIGGER tri_fec_fitem_sched_c
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_c
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_c_insert();

/*

UPDATE disclosure.fec_fitem_sched_c 
SET candidate_name_text = to_tsvector(cand_nm), 
loan_source_name_text = to_tsvector(loan_src_nm);

*/


-- ------------
-- Add indexes
-- ------------
DO $$
BEGIN

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_cand_nm
  ON disclosure.fec_fitem_sched_c
  USING btree
  (cand_nm COLLATE pg_catalog."default");');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_candidate_name_text
  ON disclosure.fec_fitem_sched_c
  USING gin
  (candidate_name_text);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_cmte_id
  ON disclosure.fec_fitem_sched_c
  USING btree
  (cmte_id COLLATE pg_catalog."default");');

  -- election_cycle column exists, no need to calculate from get_cycle(rpt_yr)
  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_get_election_cycle
  ON disclosure.fec_fitem_sched_c
  USING btree
  (election_cycle);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_image_num
  ON disclosure.fec_fitem_sched_c
  USING btree
  (image_num COLLATE pg_catalog."default");');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_incurred_dt
  ON disclosure.fec_fitem_sched_c
  USING btree
  (incurred_dt);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_incurred_dt_sub_id
  ON disclosure.fec_fitem_sched_c
  USING btree
  (incurred_dt, sub_id);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_loan_source_name_text
  ON disclosure.fec_fitem_sched_c
  USING gin
  (loan_source_name_text);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_orig_loan_amt
  ON disclosure.fec_fitem_sched_c
  USING btree
  (orig_loan_amt);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_orig_loan_amt_sub_id
  ON disclosure.fec_fitem_sched_c
  USING btree
  (orig_loan_amt, sub_id);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_pymt_to_dt
  ON disclosure.fec_fitem_sched_c
  USING btree
  (pymt_to_dt);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_pymt_to_dt_sub_id
  ON disclosure.fec_fitem_sched_c
  USING btree
  (pymt_to_dt, sub_id);');

  EXECUTE format('CREATE INDEX idx_fec_fitem_sched_c_rpt_yr
  ON disclosure.fec_fitem_sched_c
  USING btree
  (rpt_yr);');
  
  EXCEPTION 
    WHEN duplicate_table THEN 
      null;
    WHEN others THEN 
      RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

  
-- ----------------------------
-- ----------------------------
-- disclosure.fec_fitem_sched_d
-- ----------------------------
-- ----------------------------
DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_d ADD COLUMN creditor_debtor_name_text tsvector');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_d_insert()
  RETURNS trigger AS
$BODY$
begin
	new.creditor_debtor_name_text := to_tsvector(new.cred_dbtr_nm);

    	return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_d_insert()
  OWNER TO fec;

DROP TRIGGER IF EXISTS tri_fec_fitem_sched_d ON disclosure.fec_fitem_sched_d;

CREATE TRIGGER tri_fec_fitem_sched_d
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_d
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_d_insert();
  
/*

UPDATE disclosure.fec_fitem_sched_d SET creditor_debtor_name_text = to_tsvector(cred_dbtr_nm);

*/


  
