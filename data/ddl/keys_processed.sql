-- Still experimental effort to set up indexes, including primary keys,
-- on the PROCESSED schema after it is imported from CFDM.  Most of
-- the foreign keys must be set up as NOT VALID, however (not enforced
-- because PROCESSED data quality is too low.

-- ref_cand_ici: nothing
-- ref_cand_status: nothing
SET search_path=processed;
ALTER TABLE ref_cmte_dsgn ADD UNIQUE (cmte_dsgn);
ALTER TABLE form_1 ADD FOREIGN KEY (cmte_dsgn) REFERENCES ref_cmte_dsgn (cmte_dsgn) NOT VALID;  -- no dice
ALTER TABLE ref_cmte_type ADD UNIQUE (cmte_tp);
ALTER TABLE form_1 ADD FOREIGN KEY (cmte_tp) REFERENCES ref_cmte_type (cmte_tp) NOT VALID;  -- no dice
ALTER TABLE form_13 ADD FOREIGN KEY (cmte_tp) REFERENCES ref_cmte_type (cmte_tp) NOT VALID;  -- works! b/c table is empty, ha ha!
ALTER TABLE form_1m ADD FOREIGN KEY (cmte_tp) REFERENCES ref_cmte_type (cmte_tp) NOT VALID;  -- no dice
ALTER TABLE form_4 ADD FOREIGN KEY (cmte_tp) REFERENCES ref_cmte_type (cmte_tp) NOT VALID;  -- no dice
ALTER TABLE ref_election ADD UNIQUE (election_tp);
ALTER TABLE form_11 ADD FOREIGN KEY (election_tp) REFERENCES ref_election (election_tp) NOT VALID;
ALTER TABLE form_12 ADD FOREIGN KEY (election_tp) REFERENCES ref_election (election_tp) NOT VALID;
ALTER TABLE form_5 ADD FOREIGN KEY (election_tp) REFERENCES ref_election (election_tp) NOT VALID;
ALTER TABLE ref_entity_type ADD UNIQUE (entity_tp);
ALTER TABLE form_9 ADD FOREIGN KEY (entity_tp) REFERENCES ref_entity_type (entity_tp) NOT VALID;
ALTER TABLE form_5 ADD FOREIGN KEY (entity_tp) REFERENCES ref_entity_type (entity_tp) NOT VALID;
-- ref_form_type?
-- nothing in ref_office
ALTER TABLE ref_org_type ADD UNIQUE (org_tp);
ALTER TABLE form_1 ADD FOREIGN KEY (org_tp) REFERENCES ref_org_type (org_tp) NOT VALID; -- fail
ALTER TABLE form_1s ADD FOREIGN KEY (org_tp) REFERENCES ref_org_type (org_tp) NOT VALID; -- fail
ALTER TABLE form_7 ADD FOREIGN KEY (org_tp) REFERENCES ref_org_type (org_tp) NOT VALID;
ALTER TABLE ref_party ADD UNIQUE (party_cd);
ALTER TABLE form_2 ADD FOREIGN KEY (party_cd) REFERENCES ref_party (party_cd) NOT VALID; -- fail
ALTER TABLE ref_report_type ADD UNIQUE (rpt_tp);
ALTER TABLE form_9 ADD FOREIGN KEY (rpt_tp) REFERENCES ref_report_type (rpt_tp) NOT VALID;
ALTER TABLE form_13 ADD FOREIGN KEY (rpt_tp) REFERENCES ref_report_type (rpt_tp) NOT VALID;
ALTER TABLE form_3 ADD FOREIGN KEY (rpt_tp) REFERENCES ref_report_type (rpt_tp) NOT VALID;
ALTER TABLE form_3l ADD FOREIGN KEY (rpt_tp) REFERENCES ref_report_type (rpt_tp) NOT VALID;
ALTER TABLE form_3p ADD FOREIGN KEY (rpt_tp) REFERENCES ref_report_type (rpt_tp) NOT VALID;
ALTER TABLE form_3x ADD FOREIGN KEY (rpt_tp) REFERENCES ref_report_type (rpt_tp) NOT VALID;
ALTER TABLE form_4 ADD FOREIGN KEY (rpt_tp) REFERENCES ref_report_type (rpt_tp) NOT VALID;
ALTER TABLE form_5 ADD FOREIGN KEY (rpt_tp) REFERENCES ref_report_type (rpt_tp) NOT VALID;
ALTER TABLE form_7 ADD FOREIGN KEY (rpt_tp) REFERENCES ref_report_type (rpt_tp) NOT VALID;
-- ref_state: nothing
-- ref_transaction_code: nothing


-- mostly failures

 ALTER TABLE cand_status_ici ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id) NOT VALID;
 ALTER TABLE form_3p_line_31s ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id) NOT VALID;
 ALTER TABLE log_dml_errors ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id) NOT VALID;
 ALTER TABLE form_1 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id) NOT VALID;
 ALTER TABLE form_2s ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id) NOT VALID;
 ALTER TABLE form_10 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id) NOT VALID;
 ALTER TABLE form_12 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id) NOT VALID;
 ALTER TABLE form_3 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id) NOT VALID;
 ALTER TABLE form_2 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id) NOT VALID;
 ALTER TABLE form_11 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id) NOT VALID;
 ALTER TABLE form_6 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id) NOT VALID;

 ALTER TABLE form_8 ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_9 ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_99_misc ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE log_dml_errors ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_1 ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_13 ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_1m ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_3l ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_1s ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_3 ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_24 ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_3ps ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_3s ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_3x ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_4 ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;
 ALTER TABLE form_3p ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id) NOT VALID;


SELECT 'ALTER TABLE ' || nspname || '.' || relname || ' DROP CONSTRAINT ' || conname || ' ;'
 FROM pg_constraint
 INNER JOIN pg_class ON conrelid=pg_class.oid
 INNER JOIN pg_namespace ON pg_namespace.oid=pg_class.relnamespace
 WHERE nspname = 'processed'
 AND   contype = 'f'
 ORDER BY CASE WHEN contype='f' THEN 0 ELSE 1 END,contype,nspname,relname,conname;


  ALTER TABLE processed.form_1 DROP CONSTRAINT form_1_cmte_id_fkey ;
 ALTER TABLE processed.form_10 DROP CONSTRAINT form_10_cand_id_fkey ;
 ALTER TABLE processed.form_11 DROP CONSTRAINT form_11_cand_id_fkey ;
 ALTER TABLE processed.form_11 DROP CONSTRAINT form_11_election_tp_fkey ;
 ALTER TABLE processed.form_12 DROP CONSTRAINT form_12_cand_id_fkey ;
 ALTER TABLE processed.form_12 DROP CONSTRAINT form_12_election_tp_fkey ;
 ALTER TABLE processed.form_13 DROP CONSTRAINT form_13_cmte_id_fkey ;
 ALTER TABLE processed.form_13 DROP CONSTRAINT form_13_cmte_tp_fkey ;
 ALTER TABLE processed.form_13 DROP CONSTRAINT form_13_rpt_tp_fkey ;
 ALTER TABLE processed.form_1m DROP CONSTRAINT form_1m_cmte_id_fkey ;
 ALTER TABLE processed.form_1s DROP CONSTRAINT form_1s_cmte_id_fkey ;
 ALTER TABLE processed.form_2 DROP CONSTRAINT form_2_cand_id_fkey ;
 ALTER TABLE processed.form_24 DROP CONSTRAINT form_24_cmte_id_fkey ;
 ALTER TABLE processed.form_2s DROP CONSTRAINT form_2s_cand_id_fkey ;
 ALTER TABLE processed.form_3l DROP CONSTRAINT form_3l_cmte_id_fkey ;
 ALTER TABLE processed.form_3l DROP CONSTRAINT form_3l_rpt_tp_fkey ;
 ALTER TABLE processed.form_3p_line_31s DROP CONSTRAINT form_3p_line_31s_cand_id_fkey ;
 ALTER TABLE processed.form_3ps DROP CONSTRAINT form_3ps_cmte_id_fkey ;
 ALTER TABLE processed.form_4 DROP CONSTRAINT form_4_cmte_id_fkey ;
 ALTER TABLE processed.form_4 DROP CONSTRAINT form_4_rpt_tp_fkey ;
 ALTER TABLE processed.form_5 DROP CONSTRAINT form_5_election_tp_fkey ;
 ALTER TABLE processed.form_5 DROP CONSTRAINT form_5_entity_tp_fkey ;
 ALTER TABLE processed.form_5 DROP CONSTRAINT form_5_rpt_tp_fkey ;
 ALTER TABLE processed.form_7 DROP CONSTRAINT form_7_org_tp_fkey ;
 ALTER TABLE processed.form_7 DROP CONSTRAINT form_7_rpt_tp_fkey ;
 ALTER TABLE processed.form_8 DROP CONSTRAINT form_8_cmte_id_fkey ;
 ALTER TABLE processed.form_9 DROP CONSTRAINT form_9_cmte_id_fkey ;
 ALTER TABLE processed.form_9 DROP CONSTRAINT form_9_entity_tp_fkey ;
 ALTER TABLE processed.form_9 DROP CONSTRAINT form_9_rpt_tp_fkey ;
 ALTER TABLE processed.log_dml_errors DROP CONSTRAINT log_dml_errors_cand_id_fkey ;
 ALTER TABLE processed.log_dml_errors DROP CONSTRAINT log_dml_errors_cmte_id_fkey ;
