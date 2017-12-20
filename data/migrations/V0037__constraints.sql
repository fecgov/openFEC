SET search_path = aouser, pg_catalog;

--
-- Name: ao ao_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY ao
    ADD CONSTRAINT ao_pkey PRIMARY KEY (ao_id);


--
-- Name: doc_order doc_order_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY doc_order
    ADD CONSTRAINT doc_order_pkey PRIMARY KEY (doc_order_id);


--
-- Name: document document_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY document
    ADD CONSTRAINT document_pkey PRIMARY KEY (document_id);


--
-- Name: entity entity_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY entity
    ADD CONSTRAINT entity_pkey PRIMARY KEY (entity_id);


--
-- Name: entity_type entity_type_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY entity_type
    ADD CONSTRAINT entity_type_pkey PRIMARY KEY (entity_type_id);


--
-- Name: filtertab filtertab_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY filtertab
    ADD CONSTRAINT filtertab_pkey PRIMARY KEY (query_id);


--
-- Name: markuptab markuptab_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY markuptab
    ADD CONSTRAINT markuptab_pkey PRIMARY KEY (id);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_pkey PRIMARY KEY (player_id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);


SET search_path = auditsearch, pg_catalog;

--
-- Name: audit_case_finding audit_case_finding_pkey; Type: CONSTRAINT; Schema: auditsearch; Owner: fec
--

ALTER TABLE ONLY audit_case_finding
    ADD CONSTRAINT audit_case_finding_pkey PRIMARY KEY (audit_finding_pk);


--
-- Name: audit_case audit_case_pkey; Type: CONSTRAINT; Schema: auditsearch; Owner: fec
--

ALTER TABLE ONLY audit_case
    ADD CONSTRAINT audit_case_pkey PRIMARY KEY (audit_case_id);


--
-- Name: finding finding_pkey; Type: CONSTRAINT; Schema: auditsearch; Owner: fec
--

ALTER TABLE ONLY finding
    ADD CONSTRAINT finding_pkey PRIMARY KEY (finding_pk);


--
-- Name: finding_rel finding_rel_pkey; Type: CONSTRAINT; Schema: auditsearch; Owner: fec
--

ALTER TABLE ONLY finding_rel
    ADD CONSTRAINT finding_rel_pkey PRIMARY KEY (rel_pk);


SET search_path = disclosure, pg_catalog;

--
-- Name: cand_cmte_linkage cand_cmte_linkage_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY cand_cmte_linkage
    ADD CONSTRAINT cand_cmte_linkage_pkey PRIMARY KEY (linkage_id);


--
-- Name: cand_inactive cand_inactive_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY cand_inactive
    ADD CONSTRAINT cand_inactive_pkey PRIMARY KEY (cand_id, election_yr);


--
-- Name: cand_valid_fec_yr cand_valid_fec_yr_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY cand_valid_fec_yr
    ADD CONSTRAINT cand_valid_fec_yr_pkey PRIMARY KEY (cand_valid_yr_id);


--
-- Name: candidate_summary candidate_summary_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY candidate_summary
    ADD CONSTRAINT candidate_summary_pkey PRIMARY KEY (cand_id, fec_election_yr);


--
-- Name: cmte_valid_fec_yr cmte_valid_fec_yr_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY cmte_valid_fec_yr
    ADD CONSTRAINT cmte_valid_fec_yr_pkey PRIMARY KEY (valid_fec_yr_id);


--
-- Name: dim_calendar_inf dim_calendar_inf_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY dim_calendar_inf
    ADD CONSTRAINT dim_calendar_inf_pkey PRIMARY KEY (calendar_pk);


--
-- Name: dim_race_inf dim_race_inf_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY dim_race_inf
    ADD CONSTRAINT dim_race_inf_pkey PRIMARY KEY (race_pk);


--
-- Name: f_item_daily f_item_daily_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY f_item_daily
    ADD CONSTRAINT f_item_daily_pkey PRIMARY KEY (sub_id);


--
-- Name: f_item_delete_daily f_item_delete_daily_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY f_item_delete_daily
    ADD CONSTRAINT f_item_delete_daily_pkey PRIMARY KEY (pg_date, table_name, sub_id);


--
-- Name: f_item_receipt_or_exp f_item_receipt_or_exp_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY f_item_receipt_or_exp
    ADD CONSTRAINT f_item_receipt_or_exp_pkey PRIMARY KEY (sub_id);


--
-- Name: f_rpt_or_form_sub f_rpt_or_form_sub_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY f_rpt_or_form_sub
    ADD CONSTRAINT f_rpt_or_form_sub_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_f105 fec_fitem_f105_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_f105
    ADD CONSTRAINT fec_fitem_f105_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_f56 fec_fitem_f56_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_f56
    ADD CONSTRAINT fec_fitem_f56_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_f57 fec_fitem_f57_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_f57
    ADD CONSTRAINT fec_fitem_f57_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_f76 fec_fitem_f76_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_f76
    ADD CONSTRAINT fec_fitem_f76_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_f91 fec_fitem_f91_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_f91
    ADD CONSTRAINT fec_fitem_f91_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_f94 fec_fitem_f94_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_f94
    ADD CONSTRAINT fec_fitem_f94_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1975_1976 fec_fitem_sched_a_1975_1976_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1975_1976
    ADD CONSTRAINT fec_fitem_sched_a_1975_1976_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1977_1978 fec_fitem_sched_a_1977_1978_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1977_1978
    ADD CONSTRAINT fec_fitem_sched_a_1977_1978_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1979_1980 fec_fitem_sched_a_1979_1980_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1979_1980
    ADD CONSTRAINT fec_fitem_sched_a_1979_1980_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1981_1982 fec_fitem_sched_a_1981_1982_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1981_1982
    ADD CONSTRAINT fec_fitem_sched_a_1981_1982_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1983_1984 fec_fitem_sched_a_1983_1984_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1983_1984
    ADD CONSTRAINT fec_fitem_sched_a_1983_1984_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1985_1986 fec_fitem_sched_a_1985_1986_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1985_1986
    ADD CONSTRAINT fec_fitem_sched_a_1985_1986_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1987_1988 fec_fitem_sched_a_1987_1988_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1987_1988
    ADD CONSTRAINT fec_fitem_sched_a_1987_1988_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1989_1990 fec_fitem_sched_a_1989_1990_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1989_1990
    ADD CONSTRAINT fec_fitem_sched_a_1989_1990_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1991_1992 fec_fitem_sched_a_1991_1992_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1991_1992
    ADD CONSTRAINT fec_fitem_sched_a_1991_1992_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1993_1994 fec_fitem_sched_a_1993_1994_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1993_1994
    ADD CONSTRAINT fec_fitem_sched_a_1993_1994_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1995_1996 fec_fitem_sched_a_1995_1996_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1995_1996
    ADD CONSTRAINT fec_fitem_sched_a_1995_1996_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1997_1998 fec_fitem_sched_a_1997_1998_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1997_1998
    ADD CONSTRAINT fec_fitem_sched_a_1997_1998_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_1999_2000 fec_fitem_sched_a_1999_2000_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_1999_2000
    ADD CONSTRAINT fec_fitem_sched_a_1999_2000_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_2001_2002 fec_fitem_sched_a_2001_2002_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_2001_2002
    ADD CONSTRAINT fec_fitem_sched_a_2001_2002_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_2003_2004 fec_fitem_sched_a_2003_2004_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_2003_2004
    ADD CONSTRAINT fec_fitem_sched_a_2003_2004_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_2005_2006 fec_fitem_sched_a_2005_2006_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_2005_2006
    ADD CONSTRAINT fec_fitem_sched_a_2005_2006_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_2007_2008 fec_fitem_sched_a_2007_2008_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_2007_2008
    ADD CONSTRAINT fec_fitem_sched_a_2007_2008_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_2009_2010 fec_fitem_sched_a_2009_2010_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_2009_2010
    ADD CONSTRAINT fec_fitem_sched_a_2009_2010_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_2011_2012 fec_fitem_sched_a_2011_2012_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_2011_2012
    ADD CONSTRAINT fec_fitem_sched_a_2011_2012_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_2013_2014 fec_fitem_sched_a_2013_2014_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_2013_2014
    ADD CONSTRAINT fec_fitem_sched_a_2013_2014_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_2015_2016 fec_fitem_sched_a_2015_2016_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_2015_2016
    ADD CONSTRAINT fec_fitem_sched_a_2015_2016_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a_2017_2018 fec_fitem_sched_a_2017_2018_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a_2017_2018
    ADD CONSTRAINT fec_fitem_sched_a_2017_2018_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_a fec_fitem_sched_a_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_a
    ADD CONSTRAINT fec_fitem_sched_a_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1975_1976 fec_fitem_sched_b_1975_1976_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1975_1976
    ADD CONSTRAINT fec_fitem_sched_b_1975_1976_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1977_1978 fec_fitem_sched_b_1977_1978_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1977_1978
    ADD CONSTRAINT fec_fitem_sched_b_1977_1978_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1979_1980 fec_fitem_sched_b_1979_1980_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1979_1980
    ADD CONSTRAINT fec_fitem_sched_b_1979_1980_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1981_1982 fec_fitem_sched_b_1981_1982_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1981_1982
    ADD CONSTRAINT fec_fitem_sched_b_1981_1982_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1983_1984 fec_fitem_sched_b_1983_1984_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1983_1984
    ADD CONSTRAINT fec_fitem_sched_b_1983_1984_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1985_1986 fec_fitem_sched_b_1985_1986_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1985_1986
    ADD CONSTRAINT fec_fitem_sched_b_1985_1986_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1987_1988 fec_fitem_sched_b_1987_1988_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1987_1988
    ADD CONSTRAINT fec_fitem_sched_b_1987_1988_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1989_1990 fec_fitem_sched_b_1989_1990_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1989_1990
    ADD CONSTRAINT fec_fitem_sched_b_1989_1990_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1991_1992 fec_fitem_sched_b_1991_1992_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1991_1992
    ADD CONSTRAINT fec_fitem_sched_b_1991_1992_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1993_1994 fec_fitem_sched_b_1993_1994_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1993_1994
    ADD CONSTRAINT fec_fitem_sched_b_1993_1994_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1995_1996 fec_fitem_sched_b_1995_1996_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1995_1996
    ADD CONSTRAINT fec_fitem_sched_b_1995_1996_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1997_1998 fec_fitem_sched_b_1997_1998_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1997_1998
    ADD CONSTRAINT fec_fitem_sched_b_1997_1998_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_1999_2000 fec_fitem_sched_b_1999_2000_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_1999_2000
    ADD CONSTRAINT fec_fitem_sched_b_1999_2000_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_2001_2002 fec_fitem_sched_b_2001_2002_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_2001_2002
    ADD CONSTRAINT fec_fitem_sched_b_2001_2002_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_2003_2004 fec_fitem_sched_b_2003_2004_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_2003_2004
    ADD CONSTRAINT fec_fitem_sched_b_2003_2004_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_2005_2006 fec_fitem_sched_b_2005_2006_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_2005_2006
    ADD CONSTRAINT fec_fitem_sched_b_2005_2006_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_2007_2008 fec_fitem_sched_b_2007_2008_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_2007_2008
    ADD CONSTRAINT fec_fitem_sched_b_2007_2008_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_2009_2010 fec_fitem_sched_b_2009_2010_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_2009_2010
    ADD CONSTRAINT fec_fitem_sched_b_2009_2010_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_2011_2012 fec_fitem_sched_b_2011_2012_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_2011_2012
    ADD CONSTRAINT fec_fitem_sched_b_2011_2012_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_2013_2014 fec_fitem_sched_b_2013_2014_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_2013_2014
    ADD CONSTRAINT fec_fitem_sched_b_2013_2014_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_2015_2016 fec_fitem_sched_b_2015_2016_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_2015_2016
    ADD CONSTRAINT fec_fitem_sched_b_2015_2016_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b_2017_2018 fec_fitem_sched_b_2017_2018_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b_2017_2018
    ADD CONSTRAINT fec_fitem_sched_b_2017_2018_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_b fec_fitem_sched_b_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_b
    ADD CONSTRAINT fec_fitem_sched_b_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_c1 fec_fitem_sched_c1_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_c1
    ADD CONSTRAINT fec_fitem_sched_c1_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_c2 fec_fitem_sched_c2_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_c2
    ADD CONSTRAINT fec_fitem_sched_c2_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_c fec_fitem_sched_c_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_c
    ADD CONSTRAINT fec_fitem_sched_c_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_d fec_fitem_sched_d_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_d
    ADD CONSTRAINT fec_fitem_sched_d_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_e fec_fitem_sched_e_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_e
    ADD CONSTRAINT fec_fitem_sched_e_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_f fec_fitem_sf_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_f
    ADD CONSTRAINT fec_fitem_sf_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_h1 fec_fitem_sh1_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_h1
    ADD CONSTRAINT fec_fitem_sh1_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_h2 fec_fitem_sh2_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_h2
    ADD CONSTRAINT fec_fitem_sh2_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_h3 fec_fitem_sh3_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_h3
    ADD CONSTRAINT fec_fitem_sh3_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_h4 fec_fitem_sh4_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_h4
    ADD CONSTRAINT fec_fitem_sh4_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_h5 fec_fitem_sh5_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_h5
    ADD CONSTRAINT fec_fitem_sh5_pkey PRIMARY KEY (sub_id);


--
-- Name: fec_fitem_sched_h6 fec_fitem_sh6_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY fec_fitem_sched_h6
    ADD CONSTRAINT fec_fitem_sh6_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_105 nml_form_105_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_105
    ADD CONSTRAINT nml_form_105_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_10 nml_form_10_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_10
    ADD CONSTRAINT nml_form_10_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_11 nml_form_11_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_11
    ADD CONSTRAINT nml_form_11_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_12 nml_form_12_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_12
    ADD CONSTRAINT nml_form_12_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_13 nml_form_13_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_13
    ADD CONSTRAINT nml_form_13_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_1 nml_form_1_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_1
    ADD CONSTRAINT nml_form_1_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_1m nml_form_1m_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_1m
    ADD CONSTRAINT nml_form_1m_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_1s nml_form_1s_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_1s
    ADD CONSTRAINT nml_form_1s_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_1z nml_form_1z_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_1z
    ADD CONSTRAINT nml_form_1z_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_24 nml_form_24_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_24
    ADD CONSTRAINT nml_form_24_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_2 nml_form_2_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_2
    ADD CONSTRAINT nml_form_2_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_2s nml_form_2s_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_2s
    ADD CONSTRAINT nml_form_2s_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_2z nml_form_2z_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_2z
    ADD CONSTRAINT nml_form_2z_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_3 nml_form_3_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_3
    ADD CONSTRAINT nml_form_3_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_3l nml_form_3l_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_3l
    ADD CONSTRAINT nml_form_3l_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_3p nml_form_3p_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_3p
    ADD CONSTRAINT nml_form_3p_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_3ps nml_form_3ps_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_3ps
    ADD CONSTRAINT nml_form_3ps_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_3pz nml_form_3pz_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_3pz
    ADD CONSTRAINT nml_form_3pz_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_3s nml_form_3s_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_3s
    ADD CONSTRAINT nml_form_3s_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_3x nml_form_3x_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_3x
    ADD CONSTRAINT nml_form_3x_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_3z nml_form_3z_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_3z
    ADD CONSTRAINT nml_form_3z_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_4 nml_form_4_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_4
    ADD CONSTRAINT nml_form_4_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_56 nml_form_56_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_56
    ADD CONSTRAINT nml_form_56_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_57 nml_form_57_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_57
    ADD CONSTRAINT nml_form_57_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_5 nml_form_5_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_5
    ADD CONSTRAINT nml_form_5_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_65 nml_form_65_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_65
    ADD CONSTRAINT nml_form_65_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_6 nml_form_6_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_6
    ADD CONSTRAINT nml_form_6_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_76 nml_form_76_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_76
    ADD CONSTRAINT nml_form_76_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_7 nml_form_7_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_7
    ADD CONSTRAINT nml_form_7_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_82 nml_form_82_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_82
    ADD CONSTRAINT nml_form_82_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_83 nml_form_83_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_83
    ADD CONSTRAINT nml_form_83_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_8 nml_form_8_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_8
    ADD CONSTRAINT nml_form_8_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_91 nml_form_91_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_91
    ADD CONSTRAINT nml_form_91_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_94 nml_form_94_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_94
    ADD CONSTRAINT nml_form_94_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_99_misc nml_form_99_misc_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_99_misc
    ADD CONSTRAINT nml_form_99_misc_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_9 nml_form_9_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_9
    ADD CONSTRAINT nml_form_9_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_form_rfai nml_form_rfai_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_form_rfai
    ADD CONSTRAINT nml_form_rfai_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_a_daily nml_sched_a_daily_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_a_daily
    ADD CONSTRAINT nml_sched_a_daily_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_a nml_sched_a_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_a
    ADD CONSTRAINT nml_sched_a_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_b_daily nml_sched_b_daily_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_b_daily
    ADD CONSTRAINT nml_sched_b_daily_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_b nml_sched_b_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_b
    ADD CONSTRAINT nml_sched_b_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_c1 nml_sched_c1_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_c1
    ADD CONSTRAINT nml_sched_c1_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_c2 nml_sched_c2_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_c2
    ADD CONSTRAINT nml_sched_c2_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_c nml_sched_c_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_c
    ADD CONSTRAINT nml_sched_c_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_d nml_sched_d_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_d
    ADD CONSTRAINT nml_sched_d_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_e nml_sched_e_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_e
    ADD CONSTRAINT nml_sched_e_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_f nml_sched_f_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_f
    ADD CONSTRAINT nml_sched_f_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_h1 nml_sched_h1_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_h1
    ADD CONSTRAINT nml_sched_h1_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_h2 nml_sched_h2_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_h2
    ADD CONSTRAINT nml_sched_h2_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_h3 nml_sched_h3_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_h3
    ADD CONSTRAINT nml_sched_h3_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_h4 nml_sched_h4_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_h4
    ADD CONSTRAINT nml_sched_h4_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_h5 nml_sched_h5_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_h5
    ADD CONSTRAINT nml_sched_h5_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_h6 nml_sched_h6_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_h6
    ADD CONSTRAINT nml_sched_h6_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_i nml_sched_i_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_i
    ADD CONSTRAINT nml_sched_i_pkey PRIMARY KEY (sub_id);


--
-- Name: nml_sched_l nml_sched_l_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY nml_sched_l
    ADD CONSTRAINT nml_sched_l_pkey PRIMARY KEY (sub_id);


--
-- Name: ref_filing_desc ref_filing_desc_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY ref_filing_desc
    ADD CONSTRAINT ref_filing_desc_pkey PRIMARY KEY (filing_code);


--
-- Name: unverified_cand_cmte unverified_cand_cmte_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY unverified_cand_cmte
    ADD CONSTRAINT unverified_cand_cmte_pkey PRIMARY KEY (cand_cmte_id);


--
-- Name: dsc_sched_a_aggregate_size uq_ofec_sched_a_aggregate_size_cmte_id_cycle_size; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY dsc_sched_a_aggregate_size
    ADD CONSTRAINT uq_ofec_sched_a_aggregate_size_cmte_id_cycle_size UNIQUE (cmte_id, cycle, size);


--
-- Name: dsc_sched_a_aggregate_state uq_ofec_sched_a_aggregate_state_cmte_id_cycle_state; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY dsc_sched_a_aggregate_state
    ADD CONSTRAINT uq_ofec_sched_a_aggregate_state_cmte_id_cycle_state UNIQUE (cmte_id, cycle, state);


--
-- Name: dsc_sched_a_aggregate_zip uq_ofec_sched_a_aggregate_zip_cmte_id_cycle_zip; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY dsc_sched_a_aggregate_zip
    ADD CONSTRAINT uq_ofec_sched_a_aggregate_zip_cmte_id_cycle_zip UNIQUE (cmte_id, cycle, zip);


--
-- Name: dsc_sched_b_aggregate_purpose uq_ofec_sched_b_aggregate_purpose_cmte_id_cycle_purpose; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY dsc_sched_b_aggregate_purpose
    ADD CONSTRAINT uq_ofec_sched_b_aggregate_purpose_cmte_id_cycle_purpose UNIQUE (cmte_id, cycle, purpose);


--
-- Name: dsc_sched_b_aggregate_recipient uq_ofec_sched_b_aggregate_recipient_cmte_id_cycle_recipient; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY dsc_sched_b_aggregate_recipient
    ADD CONSTRAINT uq_ofec_sched_b_aggregate_recipient_cmte_id_cycle_recipient UNIQUE (cmte_id, cycle, recipient_nm);


--
-- Name: dsc_sched_a_aggregate_employer uq_sched_a_aggregate_employer_cmte_id_cycle_employer; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY dsc_sched_a_aggregate_employer
    ADD CONSTRAINT uq_sched_a_aggregate_employer_cmte_id_cycle_employer UNIQUE (cmte_id, cycle, employer);


--
-- Name: dsc_sched_a_aggregate_occupation uq_sched_a_aggregate_occupation_cmte_id_cycle_occupation; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY dsc_sched_a_aggregate_occupation
    ADD CONSTRAINT uq_sched_a_aggregate_occupation_cmte_id_cycle_occupation UNIQUE (cmte_id, cycle, occupation);


--
-- Name: dsc_sched_b_aggregate_recipient_id uq_sched_b_agg_recpnt_id_cmte_id_cycle_recipient_cmte_id; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY dsc_sched_b_aggregate_recipient_id
    ADD CONSTRAINT uq_sched_b_agg_recpnt_id_cmte_id_cycle_recipient_cmte_id UNIQUE (cmte_id, cycle, recipient_cmte_id);


--
-- Name: v_sum_and_det_sum_report v_sum_and_det_sum_report_pkey; Type: CONSTRAINT; Schema: disclosure; Owner: fec
--

ALTER TABLE ONLY v_sum_and_det_sum_report
    ADD CONSTRAINT v_sum_and_det_sum_report_pkey PRIMARY KEY (orig_sub_id, form_tp_cd);


SET search_path = fecapp, pg_catalog;

--
-- Name: cal_category cal_category_pkey; Type: CONSTRAINT; Schema: fecapp; Owner: fec
--

ALTER TABLE ONLY cal_category
    ADD CONSTRAINT cal_category_pkey PRIMARY KEY (cal_category_id);


--
-- Name: cal_category_subcat cal_category_subcat_pkey; Type: CONSTRAINT; Schema: fecapp; Owner: fec
--

ALTER TABLE ONLY cal_category_subcat
    ADD CONSTRAINT cal_category_subcat_pkey PRIMARY KEY (cal_category_id, cal_category_id_subcat);


--
-- Name: cal_event_category cal_event_category_pkey; Type: CONSTRAINT; Schema: fecapp; Owner: fec
--

ALTER TABLE ONLY cal_event_category
    ADD CONSTRAINT cal_event_category_pkey PRIMARY KEY (cal_event_id, cal_category_id);


--
-- Name: cal_event cal_event_pkey; Type: CONSTRAINT; Schema: fecapp; Owner: fec
--

ALTER TABLE ONLY cal_event
    ADD CONSTRAINT cal_event_pkey PRIMARY KEY (cal_event_id);


--
-- Name: cal_event_status cal_event_status_pkey; Type: CONSTRAINT; Schema: fecapp; Owner: fec
--

ALTER TABLE ONLY cal_event_status
    ADD CONSTRAINT cal_event_status_pkey PRIMARY KEY (cal_event_status_id);


--
-- Name: trc_election_dates trc_election_dates_pkey; Type: CONSTRAINT; Schema: fecapp; Owner: fec
--

ALTER TABLE ONLY trc_election_dates
    ADD CONSTRAINT trc_election_dates_pkey PRIMARY KEY (trc_election_id);


--
-- Name: trc_election trc_election_id_pkey; Type: CONSTRAINT; Schema: fecapp; Owner: fec
--

ALTER TABLE ONLY trc_election
    ADD CONSTRAINT trc_election_id_pkey PRIMARY KEY (trc_election_id);


--
-- Name: trc_election_status trc_election_status_pkey; Type: CONSTRAINT; Schema: fecapp; Owner: fec
--

ALTER TABLE ONLY trc_election_status
    ADD CONSTRAINT trc_election_status_pkey PRIMARY KEY (trc_election_status_id);


--
-- Name: trc_election_type trc_election_type_pkey; Type: CONSTRAINT; Schema: fecapp; Owner: fec
--

ALTER TABLE ONLY trc_election_type
    ADD CONSTRAINT trc_election_type_pkey PRIMARY KEY (trc_election_type_id);


--
-- Name: trc_report_due_date trc_report_due_date_id_pkey; Type: CONSTRAINT; Schema: fecapp; Owner: fec
--

ALTER TABLE ONLY trc_report_due_date
    ADD CONSTRAINT trc_report_due_date_id_pkey PRIMARY KEY (trc_report_due_date_id);


SET search_path = fecmur, pg_catalog;

--
-- Name: af_case af_case_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY af_case
    ADD CONSTRAINT af_case_pkey PRIMARY KEY (case_id);


--
-- Name: case case_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY "case"
    ADD CONSTRAINT case_pkey PRIMARY KEY (case_id);


--
-- Name: case_subject case_subject_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY case_subject
    ADD CONSTRAINT case_subject_pkey PRIMARY KEY (case_id, subject_id, relatedsubject_id);


--
-- Name: commission commission_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY commission
    ADD CONSTRAINT commission_pkey PRIMARY KEY (commission_id, case_id);


--
-- Name: doc_order doc_order_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY doc_order
    ADD CONSTRAINT doc_order_pkey PRIMARY KEY (doc_order_id);


--
-- Name: document_chg document_chg_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY document_chg
    ADD CONSTRAINT document_chg_pkey PRIMARY KEY (document_id);


--
-- Name: document document_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY document
    ADD CONSTRAINT document_pkey PRIMARY KEY (document_id);


--
-- Name: entity entity_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY entity
    ADD CONSTRAINT entity_pkey PRIMARY KEY (entity_id);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (event_id);


--
-- Name: milind milind_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY milind
    ADD CONSTRAINT milind_pkey PRIMARY KEY (case_id, case_no);


--
-- Name: non_monetary_term non_monetary_term_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY non_monetary_term
    ADD CONSTRAINT non_monetary_term_pkey PRIMARY KEY (term_id);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_pkey PRIMARY KEY (player_id);


--
-- Name: relatedsubject relatedsubject_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY relatedsubject
    ADD CONSTRAINT relatedsubject_pkey PRIMARY KEY (subject_id, relatedsubject_id);


--
-- Name: relationtype relationtype_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY relationtype
    ADD CONSTRAINT relationtype_pkey PRIMARY KEY (relation_id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);


--
-- Name: settlement settlement_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY settlement
    ADD CONSTRAINT settlement_pkey PRIMARY KEY (settlement_id);


--
-- Name: stage_order stage_order_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY stage_order
    ADD CONSTRAINT stage_order_pkey PRIMARY KEY (stage_order_id);


--
-- Name: subject subject_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: fec
--

ALTER TABLE ONLY subject
    ADD CONSTRAINT subject_pkey PRIMARY KEY (subject_id);


SET search_path = public, pg_catalog;

--
-- Name: checkpointtable_lox checkpointtable_lox_pkey; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY checkpointtable_lox
    ADD CONSTRAINT checkpointtable_lox_pkey PRIMARY KEY (group_name, group_key, log_cmplt_csn, log_cmplt_xids_seq);


--
-- Name: checkpointtable checkpointtable_pkey; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY checkpointtable
    ADD CONSTRAINT checkpointtable_pkey PRIMARY KEY (group_name, group_key);


--
-- Name: ofec_sched_a_1977_1978 idx_ofec_sched_a_1977_1978_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_1977_1978
    ADD CONSTRAINT idx_ofec_sched_a_1977_1978_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_1979_1980 idx_ofec_sched_a_1979_1980_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_1979_1980
    ADD CONSTRAINT idx_ofec_sched_a_1979_1980_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_1981_1982 idx_ofec_sched_a_1981_1982_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_1981_1982
    ADD CONSTRAINT idx_ofec_sched_a_1981_1982_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_1983_1984 idx_ofec_sched_a_1983_1984_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_1983_1984
    ADD CONSTRAINT idx_ofec_sched_a_1983_1984_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_1985_1986 idx_ofec_sched_a_1985_1986_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_1985_1986
    ADD CONSTRAINT idx_ofec_sched_a_1985_1986_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_1987_1988 idx_ofec_sched_a_1987_1988_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_1987_1988
    ADD CONSTRAINT idx_ofec_sched_a_1987_1988_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_1989_1990 idx_ofec_sched_a_1989_1990_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_1989_1990
    ADD CONSTRAINT idx_ofec_sched_a_1989_1990_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_1991_1992 idx_ofec_sched_a_1991_1992_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_1991_1992
    ADD CONSTRAINT idx_ofec_sched_a_1991_1992_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_1993_1994 idx_ofec_sched_a_1993_1994_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_1993_1994
    ADD CONSTRAINT idx_ofec_sched_a_1993_1994_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_1995_1996 idx_ofec_sched_a_1995_1996_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_1995_1996
    ADD CONSTRAINT idx_ofec_sched_a_1995_1996_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_1997_1998 idx_ofec_sched_a_1997_1998_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_1997_1998
    ADD CONSTRAINT idx_ofec_sched_a_1997_1998_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_1999_2000 idx_ofec_sched_a_1999_2000_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_1999_2000
    ADD CONSTRAINT idx_ofec_sched_a_1999_2000_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_2001_2002 idx_ofec_sched_a_2001_2002_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_2001_2002
    ADD CONSTRAINT idx_ofec_sched_a_2001_2002_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_2003_2004 idx_ofec_sched_a_2003_2004_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_2003_2004
    ADD CONSTRAINT idx_ofec_sched_a_2003_2004_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_2005_2006 idx_ofec_sched_a_2005_2006_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_2005_2006
    ADD CONSTRAINT idx_ofec_sched_a_2005_2006_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_2007_2008 idx_ofec_sched_a_2007_2008_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_2007_2008
    ADD CONSTRAINT idx_ofec_sched_a_2007_2008_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_2009_2010 idx_ofec_sched_a_2009_2010_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_2009_2010
    ADD CONSTRAINT idx_ofec_sched_a_2009_2010_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_2011_2012 idx_ofec_sched_a_2011_2012_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_2011_2012
    ADD CONSTRAINT idx_ofec_sched_a_2011_2012_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_2013_2014 idx_ofec_sched_a_2013_2014_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_2013_2014
    ADD CONSTRAINT idx_ofec_sched_a_2013_2014_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_2015_2016 idx_ofec_sched_a_2015_2016_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_2015_2016
    ADD CONSTRAINT idx_ofec_sched_a_2015_2016_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_2017_2018 idx_ofec_sched_a_2017_2018_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_2017_2018
    ADD CONSTRAINT idx_ofec_sched_a_2017_2018_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_1977_1978 idx_ofec_sched_b_1977_1978_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_1977_1978
    ADD CONSTRAINT idx_ofec_sched_b_1977_1978_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_1979_1980 idx_ofec_sched_b_1979_1980_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_1979_1980
    ADD CONSTRAINT idx_ofec_sched_b_1979_1980_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_1981_1982 idx_ofec_sched_b_1981_1982_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_1981_1982
    ADD CONSTRAINT idx_ofec_sched_b_1981_1982_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_1983_1984 idx_ofec_sched_b_1983_1984_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_1983_1984
    ADD CONSTRAINT idx_ofec_sched_b_1983_1984_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_1985_1986 idx_ofec_sched_b_1985_1986_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_1985_1986
    ADD CONSTRAINT idx_ofec_sched_b_1985_1986_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_1987_1988 idx_ofec_sched_b_1987_1988_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_1987_1988
    ADD CONSTRAINT idx_ofec_sched_b_1987_1988_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_1989_1990 idx_ofec_sched_b_1989_1990_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_1989_1990
    ADD CONSTRAINT idx_ofec_sched_b_1989_1990_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_1991_1992 idx_ofec_sched_b_1991_1992_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_1991_1992
    ADD CONSTRAINT idx_ofec_sched_b_1991_1992_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_1993_1994 idx_ofec_sched_b_1993_1994_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_1993_1994
    ADD CONSTRAINT idx_ofec_sched_b_1993_1994_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_1995_1996 idx_ofec_sched_b_1995_1996_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_1995_1996
    ADD CONSTRAINT idx_ofec_sched_b_1995_1996_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_1997_1998 idx_ofec_sched_b_1997_1998_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_1997_1998
    ADD CONSTRAINT idx_ofec_sched_b_1997_1998_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_1999_2000 idx_ofec_sched_b_1999_2000_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_1999_2000
    ADD CONSTRAINT idx_ofec_sched_b_1999_2000_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_2001_2002 idx_ofec_sched_b_2001_2002_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_2001_2002
    ADD CONSTRAINT idx_ofec_sched_b_2001_2002_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_2003_2004 idx_ofec_sched_b_2003_2004_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_2003_2004
    ADD CONSTRAINT idx_ofec_sched_b_2003_2004_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_2005_2006 idx_ofec_sched_b_2005_2006_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_2005_2006
    ADD CONSTRAINT idx_ofec_sched_b_2005_2006_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_2007_2008 idx_ofec_sched_b_2007_2008_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_2007_2008
    ADD CONSTRAINT idx_ofec_sched_b_2007_2008_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_2009_2010 idx_ofec_sched_b_2009_2010_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_2009_2010
    ADD CONSTRAINT idx_ofec_sched_b_2009_2010_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_2011_2012 idx_ofec_sched_b_2011_2012_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_2011_2012
    ADD CONSTRAINT idx_ofec_sched_b_2011_2012_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_2013_2014 idx_ofec_sched_b_2013_2014_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_2013_2014
    ADD CONSTRAINT idx_ofec_sched_b_2013_2014_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_2015_2016 idx_ofec_sched_b_2015_2016_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_2015_2016
    ADD CONSTRAINT idx_ofec_sched_b_2015_2016_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_b_2017_2018 idx_ofec_sched_b_2017_2018_sub_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_2017_2018
    ADD CONSTRAINT idx_ofec_sched_b_2017_2018_sub_id PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_aggregate_contributor ofec_sched_a_aggregate_contributor_pkey; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_aggregate_contributor
    ADD CONSTRAINT ofec_sched_a_aggregate_contributor_pkey PRIMARY KEY (idx);


--
-- Name: ofec_sched_a_fulltext ofec_sched_a_fulltext_pkey; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_fulltext
    ADD CONSTRAINT ofec_sched_a_fulltext_pkey PRIMARY KEY (sched_a_sk);


--
-- Name: ofec_sched_b_fulltext ofec_sched_b_fulltext_pkey; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_fulltext
    ADD CONSTRAINT ofec_sched_b_fulltext_pkey PRIMARY KEY (sched_b_sk);


--
-- Name: ofec_sched_e ofec_sched_e_sub_id_pkey; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_e
    ADD CONSTRAINT ofec_sched_e_sub_id_pkey PRIMARY KEY (sub_id);


--
-- Name: ofec_sched_a_aggregate_state uq_ofec_sched_a_aggregate_state_cmte_id_cycle_state; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_aggregate_state
    ADD CONSTRAINT uq_ofec_sched_a_aggregate_state_cmte_id_cycle_state UNIQUE (cmte_id, cycle, state);


--
-- Name: ofec_sched_a_aggregate_state_old uq_ofec_sched_a_aggregate_state_cmte_id_cycle_state_old; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_aggregate_state_old
    ADD CONSTRAINT uq_ofec_sched_a_aggregate_state_cmte_id_cycle_state_old UNIQUE (cmte_id, cycle, state);


--
-- Name: ofec_sched_a_aggregate_zip uq_ofec_sched_a_aggregate_zip_cmte_id_cycle_zip; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_aggregate_zip
    ADD CONSTRAINT uq_ofec_sched_a_aggregate_zip_cmte_id_cycle_zip UNIQUE (cmte_id, cycle, zip);


--
-- Name: ofec_sched_b_aggregate_purpose uq_ofec_sched_b_aggregate_purpose_cmte_id_cycle_purpose; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_aggregate_purpose
    ADD CONSTRAINT uq_ofec_sched_b_aggregate_purpose_cmte_id_cycle_purpose UNIQUE (cmte_id, cycle, purpose);


--
-- Name: ofec_sched_b_aggregate_recipient uq_ofec_sched_b_aggregate_recipient_cmte_id_cycle_recipient; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_aggregate_recipient
    ADD CONSTRAINT uq_ofec_sched_b_aggregate_recipient_cmte_id_cycle_recipient UNIQUE (cmte_id, cycle, recipient_nm);


--
-- Name: ofec_sched_a_aggregate_employer uq_sched_a_aggregate_employer_cmte_id_cycle_employer; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_aggregate_employer
    ADD CONSTRAINT uq_sched_a_aggregate_employer_cmte_id_cycle_employer UNIQUE (cmte_id, cycle, employer);


--
-- Name: ofec_sched_a_aggregate_occupation uq_sched_a_aggregate_occupation_cmte_id_cycle_occupation; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_a_aggregate_occupation
    ADD CONSTRAINT uq_sched_a_aggregate_occupation_cmte_id_cycle_occupation UNIQUE (cmte_id, cycle, occupation);


--
-- Name: ofec_sched_b_aggregate_recipient_id uq_sched_b_agg_recpnt_id_cmte_id_cycle_recipient_cmte_id; Type: CONSTRAINT; Schema: public; Owner: fec
--

ALTER TABLE ONLY ofec_sched_b_aggregate_recipient_id
    ADD CONSTRAINT uq_sched_b_agg_recpnt_id_cmte_id_cycle_recipient_cmte_id UNIQUE (cmte_id, cycle, recipient_cmte_id);


SET search_path = rad_pri_user, pg_catalog;

--
-- Name: rad_anlyst rad_anlyst_pkey; Type: CONSTRAINT; Schema: rad_pri_user; Owner: fec
--

ALTER TABLE ONLY rad_anlyst
    ADD CONSTRAINT rad_anlyst_pkey PRIMARY KEY (anlyst_id);


--
-- Name: rad_assgn rad_assgn_pkey; Type: CONSTRAINT; Schema: rad_pri_user; Owner: fec
--

ALTER TABLE ONLY rad_assgn
    ADD CONSTRAINT rad_assgn_pkey PRIMARY KEY (assgn_id);


--
-- Name: rad_lkp_anlyst_title rad_lkp_anlyst_title_pkey; Type: CONSTRAINT; Schema: rad_pri_user; Owner: fec
--

ALTER TABLE ONLY rad_lkp_anlyst_title
    ADD CONSTRAINT rad_lkp_anlyst_title_pkey PRIMARY KEY (anlyst_title_seq);


SET search_path = real_efile, pg_catalog;

--
-- Name: f105 real_efile_f105_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f105
    ADD CONSTRAINT real_efile_f105_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f10 real_efile_f10_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f10
    ADD CONSTRAINT real_efile_f10_pkey PRIMARY KEY (repid);


--
-- Name: f132 real_efile_f132_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f132
    ADD CONSTRAINT real_efile_f132_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f133 real_efile_f133_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f133
    ADD CONSTRAINT real_efile_f133_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f13 real_efile_f13_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f13
    ADD CONSTRAINT real_efile_f13_pkey PRIMARY KEY (repid);


--
-- Name: f1 real_efile_f1_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f1
    ADD CONSTRAINT real_efile_f1_pkey PRIMARY KEY (repid);


--
-- Name: f1m real_efile_f1m_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f1m
    ADD CONSTRAINT real_efile_f1m_pkey PRIMARY KEY (repid);


--
-- Name: f24 real_efile_f24_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f24
    ADD CONSTRAINT real_efile_f24_pkey PRIMARY KEY (repid);


--
-- Name: f2 real_efile_f2_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f2
    ADD CONSTRAINT real_efile_f2_pkey PRIMARY KEY (repid);


--
-- Name: f3 real_efile_f3_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f3
    ADD CONSTRAINT real_efile_f3_pkey PRIMARY KEY (repid);


--
-- Name: f3l real_efile_f3l_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f3l
    ADD CONSTRAINT real_efile_f3l_pkey PRIMARY KEY (repid);


--
-- Name: f3p real_efile_f3p_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f3p
    ADD CONSTRAINT real_efile_f3p_pkey PRIMARY KEY (repid);


--
-- Name: f3ps real_efile_f3ps_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f3ps
    ADD CONSTRAINT real_efile_f3ps_pkey PRIMARY KEY (repid);


--
-- Name: f3s real_efile_f3s_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f3s
    ADD CONSTRAINT real_efile_f3s_pkey PRIMARY KEY (repid);


--
-- Name: f3x real_efile_f3x_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f3x
    ADD CONSTRAINT real_efile_f3x_pkey PRIMARY KEY (repid);


--
-- Name: f3z real_efile_f3z_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f3z
    ADD CONSTRAINT real_efile_f3z_pkey PRIMARY KEY (repid, rel_lineno);


--
-- Name: f4 real_efile_f4_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f4
    ADD CONSTRAINT real_efile_f4_pkey PRIMARY KEY (repid);


--
-- Name: f56 real_efile_f56_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f56
    ADD CONSTRAINT real_efile_f56_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f57 real_efile_f57_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f57
    ADD CONSTRAINT real_efile_f57_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f5 real_efile_f5_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f5
    ADD CONSTRAINT real_efile_f5_pkey PRIMARY KEY (repid);


--
-- Name: f65 real_efile_f65_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f65
    ADD CONSTRAINT real_efile_f65_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f6 real_efile_f6_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f6
    ADD CONSTRAINT real_efile_f6_pkey PRIMARY KEY (repid);


--
-- Name: f76 real_efile_f76_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f76
    ADD CONSTRAINT real_efile_f76_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f7 real_efile_f7_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f7
    ADD CONSTRAINT real_efile_f7_pkey PRIMARY KEY (repid);


--
-- Name: f8 real_efile_f8_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f8
    ADD CONSTRAINT real_efile_f8_pkey PRIMARY KEY (repid);


--
-- Name: f8ii real_efile_f8ii_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f8ii
    ADD CONSTRAINT real_efile_f8ii_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f8iii real_efile_f8iii_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f8iii
    ADD CONSTRAINT real_efile_f8iii_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f91 real_efile_f91_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f91
    ADD CONSTRAINT real_efile_f91_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f92 real_efile_f92_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f92
    ADD CONSTRAINT real_efile_f92_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f93 real_efile_f93_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f93
    ADD CONSTRAINT real_efile_f93_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f94 real_efile_f94_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f94
    ADD CONSTRAINT real_efile_f94_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f99 real_efile_f99_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f99
    ADD CONSTRAINT real_efile_f99_pkey PRIMARY KEY (repid);


--
-- Name: f9 real_efile_f9_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY f9
    ADD CONSTRAINT real_efile_f9_pkey PRIMARY KEY (repid);


--
-- Name: guarantors real_efile_guarantors_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY guarantors
    ADD CONSTRAINT real_efile_guarantors_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: h1 real_efile_h1_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY h1
    ADD CONSTRAINT real_efile_h1_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: h2 real_efile_h2_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY h2
    ADD CONSTRAINT real_efile_h2_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: h3 real_efile_h3_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY h3
    ADD CONSTRAINT real_efile_h3_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: h4_2 real_efile_h4_2_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY h4_2
    ADD CONSTRAINT real_efile_h4_2_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: h5 real_efile_h5_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY h5
    ADD CONSTRAINT real_efile_h5_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: h6 real_efile_h6_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY h6
    ADD CONSTRAINT real_efile_h6_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: reps real_efile_reps_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY reps
    ADD CONSTRAINT real_efile_reps_pkey PRIMARY KEY (repid);


--
-- Name: sa7 real_efile_sa7_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY sa7
    ADD CONSTRAINT real_efile_sa7_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sb4 real_efile_sb4_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY sb4
    ADD CONSTRAINT real_efile_sb4_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sc1 real_efile_sc1_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY sc1
    ADD CONSTRAINT real_efile_sc1_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sc real_efile_sc_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY sc
    ADD CONSTRAINT real_efile_sc_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sd real_efile_sd_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY sd
    ADD CONSTRAINT real_efile_sd_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sf real_efile_sf_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY sf
    ADD CONSTRAINT real_efile_sf_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: si real_efile_si_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY si
    ADD CONSTRAINT real_efile_si_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sl real_efile_sl_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY sl
    ADD CONSTRAINT real_efile_sl_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sl_sum real_efile_sl_sum_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY sl_sum
    ADD CONSTRAINT real_efile_sl_sum_pkey PRIMARY KEY (repid, lineno, iid);


--
-- Name: summary real_efile_summary_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY summary
    ADD CONSTRAINT real_efile_summary_pkey PRIMARY KEY (repid, lineno);


--
-- Name: supsum real_efile_supsum_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY supsum
    ADD CONSTRAINT real_efile_supsum_pkey PRIMARY KEY (repid, lineno);


--
-- Name: text real_efile_text_pkey; Type: CONSTRAINT; Schema: real_efile; Owner: fec
--

ALTER TABLE ONLY text
    ADD CONSTRAINT real_efile_text_pkey PRIMARY KEY (repid, tranid);


SET search_path = real_pfile, pg_catalog;

--
-- Name: f105 real_pfile_f105_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f105
    ADD CONSTRAINT real_pfile_f105_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f10 real_pfile_f10_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f10
    ADD CONSTRAINT real_pfile_f10_pkey PRIMARY KEY (repid);


--
-- Name: f11 real_pfile_f11_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f11
    ADD CONSTRAINT real_pfile_f11_pkey PRIMARY KEY (repid);


--
-- Name: f12 real_pfile_f12_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f12
    ADD CONSTRAINT real_pfile_f12_pkey PRIMARY KEY (repid);


--
-- Name: f132 real_pfile_f132_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f132
    ADD CONSTRAINT real_pfile_f132_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f133 real_pfile_f133_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f133
    ADD CONSTRAINT real_pfile_f133_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f13 real_pfile_f13_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f13
    ADD CONSTRAINT real_pfile_f13_pkey PRIMARY KEY (repid);


--
-- Name: f1 real_pfile_f1_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f1
    ADD CONSTRAINT real_pfile_f1_pkey PRIMARY KEY (repid);


--
-- Name: f1m real_pfile_f1m_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f1m
    ADD CONSTRAINT real_pfile_f1m_pkey PRIMARY KEY (repid);


--
-- Name: f24 real_pfile_f24_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f24
    ADD CONSTRAINT real_pfile_f24_pkey PRIMARY KEY (repid);


--
-- Name: f2 real_pfile_f2_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f2
    ADD CONSTRAINT real_pfile_f2_pkey PRIMARY KEY (repid);


--
-- Name: f3 real_pfile_f3_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f3
    ADD CONSTRAINT real_pfile_f3_pkey PRIMARY KEY (repid);


--
-- Name: f3l real_pfile_f3l_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f3l
    ADD CONSTRAINT real_pfile_f3l_pkey PRIMARY KEY (repid);


--
-- Name: f3p real_pfile_f3p_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f3p
    ADD CONSTRAINT real_pfile_f3p_pkey PRIMARY KEY (repid);


--
-- Name: f3ps real_pfile_f3ps_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f3ps
    ADD CONSTRAINT real_pfile_f3ps_pkey PRIMARY KEY (repid);


--
-- Name: f3s real_pfile_f3s_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f3s
    ADD CONSTRAINT real_pfile_f3s_pkey PRIMARY KEY (repid);


--
-- Name: f3x real_pfile_f3x_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f3x
    ADD CONSTRAINT real_pfile_f3x_pkey PRIMARY KEY (repid);


--
-- Name: f3z real_pfile_f3z_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f3z
    ADD CONSTRAINT real_pfile_f3z_pkey PRIMARY KEY (repid);


--
-- Name: f4 real_pfile_f4_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f4
    ADD CONSTRAINT real_pfile_f4_pkey PRIMARY KEY (repid);


--
-- Name: f56 real_pfile_f56_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f56
    ADD CONSTRAINT real_pfile_f56_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f57 real_pfile_f57_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f57
    ADD CONSTRAINT real_pfile_f57_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f5 real_pfile_f5_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f5
    ADD CONSTRAINT real_pfile_f5_pkey PRIMARY KEY (repid);


--
-- Name: f65 real_pfile_f65_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f65
    ADD CONSTRAINT real_pfile_f65_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f6 real_pfile_f6_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f6
    ADD CONSTRAINT real_pfile_f6_pkey PRIMARY KEY (repid);


--
-- Name: f76 real_pfile_f76_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f76
    ADD CONSTRAINT real_pfile_f76_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f7 real_pfile_f7_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f7
    ADD CONSTRAINT real_pfile_f7_pkey PRIMARY KEY (repid);


--
-- Name: f8 real_pfile_f8_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f8
    ADD CONSTRAINT real_pfile_f8_pkey PRIMARY KEY (repid);


--
-- Name: f8ii real_pfile_f8ii_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f8ii
    ADD CONSTRAINT real_pfile_f8ii_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f8iii real_pfile_f8iii_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f8iii
    ADD CONSTRAINT real_pfile_f8iii_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f91 real_pfile_f91_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f91
    ADD CONSTRAINT real_pfile_f91_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f92 real_pfile_f92_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f92
    ADD CONSTRAINT real_pfile_f92_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f93 real_pfile_f93_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f93
    ADD CONSTRAINT real_pfile_f93_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f94 real_pfile_f94_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f94
    ADD CONSTRAINT real_pfile_f94_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: f9 real_pfile_f9_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY f9
    ADD CONSTRAINT real_pfile_f9_pkey PRIMARY KEY (repid);


--
-- Name: h1 real_pfile_h1_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY h1
    ADD CONSTRAINT real_pfile_h1_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: h2 real_pfile_h2_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY h2
    ADD CONSTRAINT real_pfile_h2_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: h3 real_pfile_h3_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY h3
    ADD CONSTRAINT real_pfile_h3_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: h4 real_pfile_h4_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY h4
    ADD CONSTRAINT real_pfile_h4_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: h5 real_pfile_h5_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY h5
    ADD CONSTRAINT real_pfile_h5_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: h6 real_pfile_h6_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY h6
    ADD CONSTRAINT real_pfile_h6_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: reps real_pfile_reps_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY reps
    ADD CONSTRAINT real_pfile_reps_pkey PRIMARY KEY (repid);


--
-- Name: sa real_pfile_sa_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY sa
    ADD CONSTRAINT real_pfile_sa_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sb real_pfile_sb_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY sb
    ADD CONSTRAINT real_pfile_sb_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sc1 real_pfile_sc1_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY sc1
    ADD CONSTRAINT real_pfile_sc1_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sc2 real_pfile_sc2_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY sc2
    ADD CONSTRAINT real_pfile_sc2_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sc real_pfile_sc_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY sc
    ADD CONSTRAINT real_pfile_sc_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sd real_pfile_sd_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY sd
    ADD CONSTRAINT real_pfile_sd_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: se real_pfile_se_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY se
    ADD CONSTRAINT real_pfile_se_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sf real_pfile_sf_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY sf
    ADD CONSTRAINT real_pfile_sf_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: sl real_pfile_sl_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY sl
    ADD CONSTRAINT real_pfile_sl_pkey PRIMARY KEY (repid, tran_id);


--
-- Name: summary_sup real_pfile_summary_sup_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY summary_sup
    ADD CONSTRAINT real_pfile_summary_sup_pkey PRIMARY KEY (repid, lineno);


--
-- Name: supsum real_pfile_supsum_pkey; Type: CONSTRAINT; Schema: real_pfile; Owner: fec
--

ALTER TABLE ONLY supsum
    ADD CONSTRAINT real_pfile_supsum_pkey PRIMARY KEY (repid, lineno);


SET search_path = rohan, pg_catalog;

--
-- Name: rj_row_count rj_row_count_pk; Type: CONSTRAINT; Schema: rohan; Owner: fec
--

ALTER TABLE ONLY rj_row_count
    ADD CONSTRAINT rj_row_count_pk PRIMARY KEY (row_id);


--
-- Name: rj_user rj_user_pkey; Type: CONSTRAINT; Schema: rohan; Owner: fec
--

ALTER TABLE ONLY rj_user
    ADD CONSTRAINT rj_user_pkey PRIMARY KEY (uid);


--
-- Name: rj_user rj_user_username_key; Type: CONSTRAINT; Schema: rohan; Owner: fec
--

ALTER TABLE ONLY rj_user
    ADD CONSTRAINT rj_user_username_key UNIQUE (username);


SET search_path = staging, pg_catalog;

--
-- Name: operations_log operations_log_pkey; Type: CONSTRAINT; Schema: staging; Owner: fec
--

ALTER TABLE ONLY operations_log
    ADD CONSTRAINT operations_log_pkey PRIMARY KEY (sub_id);


--
-- Name: ref_contribution_limits ref_contribution_limits_pkey; Type: CONSTRAINT; Schema: staging; Owner: fec
--

ALTER TABLE ONLY ref_contribution_limits
    ADD CONSTRAINT ref_contribution_limits_pkey PRIMARY KEY (contrib_limit_id);
