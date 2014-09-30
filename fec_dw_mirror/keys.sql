SELECT 'ALTER TABLE ' || table_name ||
       ' ADD PRIMARY KEY (' || column_name || 
       ');' 
FROM   information_schema.columns
WHERE  table_schema = 'public'
AND    ordinal_position = 1;

 ALTER TABLE dimcandoffice ADD PRIMARY KEY (candoffice_sk);
 ALTER TABLE dimcmte ADD PRIMARY KEY (cmte_sk);
 ALTER TABLE dimcmteproperties ADD PRIMARY KEY (cmteproperties_sk);
 ALTER TABLE dimcand ADD PRIMARY KEY (cand_sk);
 ALTER TABLE dimcandstatusici ADD PRIMARY KEY (candstatusici_sk);
 ALTER TABLE dimcmtetpdsgn ADD PRIMARY KEY (cmte_tpdgn_sk);
 ALTER TABLE dimdates ADD PRIMARY KEY (date_sk);
 ALTER TABLE dimelectiontp ADD PRIMARY KEY (electiontp_sk);
 ALTER TABLE dimlinkages ADD PRIMARY KEY (linkages_sk);
 ALTER TABLE dimoffice ADD PRIMARY KEY (office_sk);
 ALTER TABLE dimparty ADD PRIMARY KEY (party_sk);
 ALTER TABLE dimreporttype ADD PRIMARY KEY (reporttype_sk);
 ALTER TABLE dimyears ADD PRIMARY KEY (year_sk);
 ALTER TABLE facthousesenate_f3 ADD PRIMARY KEY (facthousesenate_f3_sk);
 ALTER TABLE factpacsandparties_f3x ADD PRIMARY KEY (factpacsandparties_f3x_sk);
 ALTER TABLE factpresidential_f3p ADD PRIMARY KEY (factpresidential_f3p_sk);
 ALTER TABLE form_105 ADD PRIMARY KEY (form_105_sk);
 ALTER TABLE form_56 ADD PRIMARY KEY (form_56_sk);
 ALTER TABLE form_57 ADD PRIMARY KEY (form_57_sk);
 ALTER TABLE form_65 ADD PRIMARY KEY (form_65_sk);
 ALTER TABLE form_76 ADD PRIMARY KEY (form_76_sk);
 ALTER TABLE form_82 ADD PRIMARY KEY (form_82_sk);
 ALTER TABLE form_83 ADD PRIMARY KEY (form_83_sk);
 ALTER TABLE form_91 ADD PRIMARY KEY (form_91_sk);
 ALTER TABLE form_94 ADD PRIMARY KEY (form_94_sk);
 ALTER TABLE log_audit_dml ADD PRIMARY KEY (dml_id);
 ALTER TABLE log_audit_module ADD PRIMARY KEY (audit_id);
 ALTER TABLE log_audit_process ADD PRIMARY KEY (run_id);
 ALTER TABLE sched_a ADD PRIMARY KEY (sched_a_sk);
 ALTER TABLE sched_b ADD PRIMARY KEY (sched_b_sk);
 ALTER TABLE sched_c ADD PRIMARY KEY (sched_c_sk);
 ALTER TABLE sched_c1 ADD PRIMARY KEY (sched_c1_sk);
 ALTER TABLE sched_c2 ADD PRIMARY KEY (sched_c2_sk);
 ALTER TABLE sched_d ADD PRIMARY KEY (sched_d_sk);
 ALTER TABLE sched_e ADD PRIMARY KEY (sched_e_sk);
 ALTER TABLE sched_f ADD PRIMARY KEY (sched_f_sk);
 ALTER TABLE sched_h1 ADD PRIMARY KEY (sched_h1_sk);
 ALTER TABLE sched_h2 ADD PRIMARY KEY (sched_h2_sk);
 ALTER TABLE sched_h3 ADD PRIMARY KEY (sched_h3_sk);
 ALTER TABLE sched_h4 ADD PRIMARY KEY (sched_h4_sk);
 ALTER TABLE sched_h5 ADD PRIMARY KEY (sched_h5_sk);
 ALTER TABLE sched_h6 ADD PRIMARY KEY (sched_h6_sk);
 ALTER TABLE sched_i ADD PRIMARY KEY (sched_i_sk);
 ALTER TABLE sched_l ADD PRIMARY KEY (sched_l_sk);
 ALTER TABLE dimcandproperties ADD PRIMARY KEY (candproperties_sk);


CREATE UNIQUE INDEX ON public.dimcand (cand_id);
CREATE UNIQUE INDEX ON public.dimcmte (cmte_id);
ALTER TABLE public.sched_a ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id);
delete from public.sched_b where recipient_cmte_id not in (select cmte_id from dimcmte);  -- DELETE 8347 of 100000 - WHY?
ALTER TABLE public.sched_b ADD FOREIGN KEY (recipient_cmte_id) REFERENCES public.dimcmte (cmte_id);
DELETE FROM public.sched_b WHERE cand_id NOT IN (SELECT cand_id FROM dimcand); -- DELETE 4436 - why?
ALTER TABLE public.sched_b ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.dimcmteproperties ADD FOREIGN KEY (cmte_sk) REFERENCES public.dimcmte (cmte_sk);
ALTER TABLE public.dimcandproperties ADD FOREIGN KEY (cand_sk) REFERENCES public.dimcand (cand_sk);
