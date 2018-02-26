SET search_path = public, pg_catalog;

--
-- 1)Name: public.ofec_candidate_flag; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--


ALTER MATERIALIZED VIEW IF EXISTS ofec_candidate_flag
    RENAME TO ofec_candidate_flag_mv;
    
ALTER INDEX IF EXISTS ofec_candidate_flag_tmp_candidate_id_idx1 
	RENAME TO ofec_candidate_flag_candidate_id_idx1;    

ALTER INDEX IF EXISTS ofec_candidate_flag_tmp_federal_funds_flag_idx1 
	RENAME TO ofec_candidate_flag_federal_funds_flag_idx1;    

ALTER INDEX IF EXISTS ofec_candidate_flag_tmp_has_raised_funds_idx1 
	RENAME TO ofec_candidate_flag_has_raised_funds_idx1;    

ALTER INDEX IF EXISTS ofec_candidate_flag_tmp_idx_idx1 
	RENAME TO ofec_candidate_flag_idx_idx1;  
