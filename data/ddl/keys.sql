-- SELECT 'ALTER TABLE ' || table_name ||
--       ' ADD PRIMARY KEY (' || column_name || 
--       ');' 
-- FROM   information_schema.columns
-- WHERE  table_schema = 'public'
-- AND    ordinal_position = 1;

-- dimcand looks like rows should expire and then be linked together
-- by cand_id.  but in fact cand_id is unique.
-- and in fact expire date is always null


 ALTER TABLE dimcandoffice ADD PRIMARY KEY (candoffice_sk);
 ALTER TABLE dimcmte ADD PRIMARY KEY (cmte_sk);
 CREATE UNIQUE INDEX dimcmte_cmte_id_key ON dimcmte (cmte_id);
 ALTER TABLE dimcmteproperties ADD PRIMARY KEY (cmteproperties_sk);
 ALTER TABLE dimcand ADD PRIMARY KEY (cand_sk);
 CREATE UNIQUE INDEX dimcand_cand_id_key ON dimcand (cand_id);
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

-- orig_sub_id is a foreign key, but to what?
-- cand_id
ALTER TABLE public.dimcmteproperties ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.dimlinkages ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.form_56 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.form_65 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.form_82 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.form_83 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.form_94 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.sched_c ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.sched_d ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.sched_f ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.sched_h4 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.sched_h6 ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);

ALTER TABLE public.form_57 ADD FOREIGN KEY (s_o_cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.form_76 ADD FOREIGN KEY (s_o_cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.sched_e ADD FOREIGN KEY (s_o_cand_id) REFERENCES public.dimcand (cand_id);

ALTER TABLE public.form_105 ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.form_56 ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.form_57 ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.form_65 ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.form_91 ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.form_94 ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_h1 ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_h2 ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_h3 ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_h4 ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_h5 ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_h6 ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_i ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_l ADD FOREIGN KEY (filer_cmte_id) REFERENCES public.dimcmte (cmte_id);

ALTER TABLE public.form_82 ADD FOREIGN KEY (add_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.form_83 ADD FOREIGN KEY (add_cmte_id) REFERENCES public.dimcmte (cmte_id);

ALTER TABLE public.dimcmteproperties ADD FOREIGN KEY (cmte_sk) REFERENCES public.dimcmte (cmte_sk);
ALTER TABLE public.dimcmtetpdsgn ADD FOREIGN KEY (cmte_sk) REFERENCES public.dimcmte (cmte_sk);
ALTER TABLE public.dimlinkages ADD FOREIGN KEY (cmte_sk) REFERENCES public.dimcmte (cmte_sk);
ALTER TABLE public.facthousesenate_f3 ADD FOREIGN KEY (cmte_sk) REFERENCES public.dimcmte (cmte_sk);
ALTER TABLE public.factpacsandparties_f3x ADD FOREIGN KEY (cmte_sk) REFERENCES public.dimcmte (cmte_sk);
ALTER TABLE public.factpresidential_f3p ADD FOREIGN KEY (cmte_sk) REFERENCES public.dimcmte (cmte_sk);
	
ALTER TABLE public.form_82 ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.form_83 ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id);

ALTER TABLE public.sched_c ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_c1 ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_c2 ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_d ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_e ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_f ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id);

ALTER TABLE public.form_56 ADD FOREIGN KEY (conduit_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.form_57 ADD FOREIGN KEY (conduit_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.form_65 ADD FOREIGN KEY (conduit_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_d ADD FOREIGN KEY (conduit_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_e ADD FOREIGN KEY (conduit_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_f ADD FOREIGN KEY (conduit_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_h4 ADD FOREIGN KEY (conduit_cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_h6 ADD FOREIGN KEY (conduit_cmte_id) REFERENCES public.dimcmte (cmte_id);

ALTER TABLE public.dimcandoffice ADD FOREIGN KEY (cand_sk) REFERENCES public.dimcand (cand_sk);
ALTER TABLE public.dimcandproperties ADD FOREIGN KEY (cand_sk) REFERENCES public.dimcand (cand_sk);
ALTER TABLE public.dimcandstatusici ADD FOREIGN KEY (cand_sk) REFERENCES public.dimcand (cand_sk);
ALTER TABLE public.dimlinkages ADD FOREIGN KEY (cand_sk) REFERENCES public.dimcand (cand_sk);

ALTER TABLE public.dimcandoffice ADD FOREIGN KEY (office_sk) REFERENCES public.dimoffice (office_sk);

ALTER TABLE public.dimcandoffice ADD FOREIGN KEY (party_sk) REFERENCES public.dimparty (party_sk);

ALTER TABLE public.facthousesenate_f3 ADD FOREIGN KEY (electiontp_sk) REFERENCES public.dimelectiontp (electiontp_sk);
ALTER TABLE public.factpacsandparties_f3x ADD FOREIGN KEY (electiontp_sk) REFERENCES public.dimelectiontp (electiontp_sk);
ALTER TABLE public.factpresidential_f3p ADD FOREIGN KEY (electiontp_sk) REFERENCES public.dimelectiontp (electiontp_sk);

ALTER TABLE public.factpresidential_f3p ADD FOREIGN KEY (reporttype_sk) REFERENCES public.dimreporttype (reporttype_sk);
ALTER TABLE public.factpacsandparties_f3x ADD FOREIGN KEY (reporttype_sk) REFERENCES public.dimreporttype (reporttype_sk);

 ALTER TABLE sched_a ADD PRIMARY KEY (sched_a_sk);
 ALTER TABLE sched_b ADD PRIMARY KEY (sched_b_sk);
 ALTER TABLE public.sched_a ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.sched_b ADD FOREIGN KEY (cand_id) REFERENCES public.dimcand (cand_id);
ALTER TABLE public.sched_a ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_b ADD FOREIGN KEY (cmte_id) REFERENCES public.dimcmte (cmte_id);
ALTER TABLE public.sched_a ADD FOREIGN KEY (conduit_cmte_id) REFERENCES public.dimcmte (cmte_id);

CREATE INDEX ON public.sched_a(conduit_cmte_id);
CREATE INDEX ON public.sched_h4(conduit_cmte_id);
CREATE INDEX ON public.factpacsandparties_f3x(cmte_sk);
CREATE INDEX ON public.factpacsandparties_f3x(electiontp_sk);
CREATE INDEX ON public.factpacsandparties_f3x(reporttype_sk);
CREATE INDEX ON public.facthousesenate_f3(cmte_sk);
CREATE INDEX ON public.facthousesenate_f3(electiontp_sk);
CREATE INDEX ON public.sched_d(conduit_cmte_id);
CREATE INDEX ON public.dimcmteproperties(cmte_sk);
CREATE INDEX ON public.sched_h3(filer_cmte_id);
CREATE INDEX ON public.dimcandoffice(office_sk);
CREATE INDEX ON public.dimcandoffice(party_sk);

