--
-- Name: aouser; Type: ACL; Schema: -; Owner: fec
--

GRANT ALL ON SCHEMA aouser TO PUBLIC;


--
-- Name: auditsearch; Type: ACL; Schema: -; Owner: fec
--

GRANT ALL ON SCHEMA auditsearch TO PUBLIC;


--
-- Name: disclosure; Type: ACL; Schema: -; Owner: fec
--

GRANT ALL ON SCHEMA disclosure TO PUBLIC;


--
-- Name: fecapp; Type: ACL; Schema: -; Owner: fec
--

GRANT ALL ON SCHEMA fecapp TO PUBLIC;


--
-- Name: fecmur; Type: ACL; Schema: -; Owner: fec
--

GRANT ALL ON SCHEMA fecmur TO PUBLIC;


--
-- Name: public; Type: ACL; Schema: -; Owner: fec
--

GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO real_file;


--
-- Name: rad_pri_user; Type: ACL; Schema: -; Owner: fec
--

GRANT ALL ON SCHEMA rad_pri_user TO PUBLIC;


--
-- Name: real_efile; Type: ACL; Schema: -; Owner: fec
--

GRANT ALL ON SCHEMA real_efile TO PUBLIC;
GRANT ALL ON SCHEMA real_efile TO real_file;


--
-- Name: real_pfile; Type: ACL; Schema: -; Owner: fec
--

GRANT ALL ON SCHEMA real_pfile TO PUBLIC;
GRANT ALL ON SCHEMA real_pfile TO real_file;


--
-- Name: rohan; Type: ACL; Schema: -; Owner: fec
--

GRANT ALL ON SCHEMA rohan TO PUBLIC;


--
-- Name: staging; Type: ACL; Schema: -; Owner: fec
--

GRANT ALL ON SCHEMA staging TO PUBLIC;


SET search_path = aouser, pg_catalog;

--
-- Name: ao; Type: ACL; Schema: aouser; Owner: fec
--

GRANT SELECT ON TABLE ao TO fec_read;
GRANT SELECT ON TABLE ao TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ao TO aomur_usr;


--
-- Name: doc_order; Type: ACL; Schema: aouser; Owner: fec
--

GRANT SELECT ON TABLE doc_order TO fec_read;
GRANT SELECT ON TABLE doc_order TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE doc_order TO aomur_usr;


--
-- Name: document; Type: ACL; Schema: aouser; Owner: fec
--

GRANT SELECT ON TABLE document TO fec_read;
GRANT SELECT ON TABLE document TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE document TO aomur_usr;


--
-- Name: entity; Type: ACL; Schema: aouser; Owner: fec
--

GRANT SELECT ON TABLE entity TO fec_read;
GRANT SELECT ON TABLE entity TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE entity TO aomur_usr;


--
-- Name: entity_type; Type: ACL; Schema: aouser; Owner: fec
--

GRANT SELECT ON TABLE entity_type TO fec_read;
GRANT SELECT ON TABLE entity_type TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE entity_type TO aomur_usr;


--
-- Name: filtertab; Type: ACL; Schema: aouser; Owner: fec
--

GRANT SELECT ON TABLE filtertab TO fec_read;
GRANT SELECT ON TABLE filtertab TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE filtertab TO aomur_usr;


--
-- Name: markuptab; Type: ACL; Schema: aouser; Owner: fec
--

GRANT SELECT ON TABLE markuptab TO fec_read;
GRANT SELECT ON TABLE markuptab TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE markuptab TO aomur_usr;


--
-- Name: players; Type: ACL; Schema: aouser; Owner: fec
--

GRANT SELECT ON TABLE players TO fec_read;
GRANT SELECT ON TABLE players TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE players TO aomur_usr;


--
-- Name: role; Type: ACL; Schema: aouser; Owner: fec
--

GRANT SELECT ON TABLE role TO fec_read;
GRANT SELECT ON TABLE role TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE role TO aomur_usr;


SET search_path = auditsearch, pg_catalog;

--
-- Name: audit_case; Type: ACL; Schema: auditsearch; Owner: fec
--

GRANT SELECT ON TABLE audit_case TO fec_read;
GRANT SELECT ON TABLE audit_case TO openfec_read;


--
-- Name: audit_case_finding; Type: ACL; Schema: auditsearch; Owner: fec
--

GRANT SELECT ON TABLE audit_case_finding TO fec_read;
GRANT SELECT ON TABLE audit_case_finding TO openfec_read;


SET search_path = disclosure, pg_catalog;

--
-- Name: cand_valid_fec_yr; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE cand_valid_fec_yr TO fec_read;
GRANT SELECT ON TABLE cand_valid_fec_yr TO openfec_read;


SET search_path = auditsearch, pg_catalog;

--
-- Name: cand_audit_vw; Type: ACL; Schema: auditsearch; Owner: fec
--

GRANT SELECT ON TABLE cand_audit_vw TO fec_read;
GRANT SELECT ON TABLE cand_audit_vw TO openfec_read;


SET search_path = disclosure, pg_catalog;

--
-- Name: cmte_valid_fec_yr; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE cmte_valid_fec_yr TO fec_read;
GRANT SELECT ON TABLE cmte_valid_fec_yr TO openfec_read;


SET search_path = auditsearch, pg_catalog;

--
-- Name: cmte_audit_vw; Type: ACL; Schema: auditsearch; Owner: fec
--

GRANT SELECT ON TABLE cmte_audit_vw TO fec_read;
GRANT SELECT ON TABLE cmte_audit_vw TO openfec_read;


--
-- Name: finding; Type: ACL; Schema: auditsearch; Owner: fec
--

GRANT SELECT ON TABLE finding TO fec_read;
GRANT SELECT ON TABLE finding TO openfec_read;


--
-- Name: finding_rel; Type: ACL; Schema: auditsearch; Owner: fec
--

GRANT SELECT ON TABLE finding_rel TO fec_read;
GRANT SELECT ON TABLE finding_rel TO openfec_read;


SET search_path = disclosure, pg_catalog;

--
-- Name: cand_cmte_linkage; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE cand_cmte_linkage TO fec_read;
GRANT SELECT ON TABLE cand_cmte_linkage TO openfec_read;


--
-- Name: cand_inactive; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE cand_inactive TO fec_read;
GRANT SELECT ON TABLE cand_inactive TO openfec_read;


--
-- Name: candidate_summary; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE candidate_summary TO fec_read;
GRANT SELECT ON TABLE candidate_summary TO openfec_read;


--
-- Name: committee_summary; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE committee_summary TO fec_read;
GRANT SELECT ON TABLE committee_summary TO openfec_read;


--
-- Name: dim_calendar_inf; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE dim_calendar_inf TO fec_read;
GRANT SELECT ON TABLE dim_calendar_inf TO openfec_read;


--
-- Name: dim_race_inf; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE dim_race_inf TO fec_read;
GRANT SELECT ON TABLE dim_race_inf TO openfec_read;


--
-- Name: dsc_sched_a_aggregate_employer; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE dsc_sched_a_aggregate_employer TO fec_read;


--
-- Name: dsc_sched_a_aggregate_occupation; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE dsc_sched_a_aggregate_occupation TO fec_read;


--
-- Name: dsc_sched_a_aggregate_size; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE dsc_sched_a_aggregate_size TO fec_read;


--
-- Name: dsc_sched_a_aggregate_state; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE dsc_sched_a_aggregate_state TO fec_read;


--
-- Name: dsc_sched_a_aggregate_zip; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE dsc_sched_a_aggregate_zip TO fec_read;


--
-- Name: dsc_sched_b_aggregate_purpose; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE dsc_sched_b_aggregate_purpose TO fec_read;


--
-- Name: dsc_sched_b_aggregate_recipient; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE dsc_sched_b_aggregate_recipient TO fec_read;


--
-- Name: dsc_sched_b_aggregate_recipient_id; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE dsc_sched_b_aggregate_recipient_id TO fec_read;


--
-- Name: f_item_daily; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE f_item_daily TO fec_read;
GRANT SELECT ON TABLE f_item_daily TO openfec_read;


--
-- Name: f_item_delete_daily; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE f_item_delete_daily TO fec_read;
GRANT SELECT ON TABLE f_item_delete_daily TO openfec_read;


--
-- Name: f_item_receipt_or_exp; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE f_item_receipt_or_exp TO fec_read;
GRANT SELECT ON TABLE f_item_receipt_or_exp TO openfec_read;


--
-- Name: f_rpt_or_form_sub; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE f_rpt_or_form_sub TO fec_read;
GRANT SELECT ON TABLE f_rpt_or_form_sub TO openfec_read;


--
-- Name: fec_fitem_f105; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_f105 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_f105 TO openfec_read;


--
-- Name: fec_fitem_f56; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_f56 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_f56 TO openfec_read;


--
-- Name: fec_fitem_f57; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_f57 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_f57 TO openfec_read;


--
-- Name: fec_fitem_f76; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_f76 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_f76 TO openfec_read;


--
-- Name: fec_fitem_f91; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_f91 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_f91 TO openfec_read;


--
-- Name: fec_fitem_f94; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_f94 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_f94 TO openfec_read;


--
-- Name: fec_fitem_sched_a; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a TO openfec_read;


--
-- Name: fec_fitem_sched_a_1975_1976; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1975_1976 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1975_1976 TO openfec_read;


--
-- Name: fec_fitem_sched_a_1977_1978; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1977_1978 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1977_1978 TO openfec_read;


--
-- Name: fec_fitem_sched_a_1979_1980; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1979_1980 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1979_1980 TO openfec_read;


--
-- Name: fec_fitem_sched_a_1981_1982; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1981_1982 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1981_1982 TO openfec_read;


--
-- Name: fec_fitem_sched_a_1983_1984; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1983_1984 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1983_1984 TO openfec_read;


--
-- Name: fec_fitem_sched_a_1985_1986; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1985_1986 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1985_1986 TO openfec_read;


--
-- Name: fec_fitem_sched_a_1987_1988; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1987_1988 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1987_1988 TO openfec_read;


--
-- Name: fec_fitem_sched_a_1989_1990; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1989_1990 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1989_1990 TO openfec_read;


--
-- Name: fec_fitem_sched_a_1991_1992; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1991_1992 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1991_1992 TO openfec_read;


--
-- Name: fec_fitem_sched_a_1993_1994; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1993_1994 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1993_1994 TO openfec_read;


--
-- Name: fec_fitem_sched_a_1995_1996; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1995_1996 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1995_1996 TO openfec_read;


--
-- Name: fec_fitem_sched_a_1997_1998; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1997_1998 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1997_1998 TO openfec_read;


--
-- Name: fec_fitem_sched_a_1999_2000; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_1999_2000 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_1999_2000 TO openfec_read;


--
-- Name: fec_fitem_sched_a_2001_2002; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_2001_2002 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_2001_2002 TO openfec_read;


--
-- Name: fec_fitem_sched_a_2003_2004; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_2003_2004 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_2003_2004 TO openfec_read;


--
-- Name: fec_fitem_sched_a_2005_2006; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_2005_2006 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_2005_2006 TO openfec_read;


--
-- Name: fec_fitem_sched_a_2007_2008; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_2007_2008 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_2007_2008 TO openfec_read;


--
-- Name: fec_fitem_sched_a_2009_2010; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_2009_2010 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_2009_2010 TO openfec_read;


--
-- Name: fec_fitem_sched_a_2011_2012; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_2011_2012 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_2011_2012 TO openfec_read;


--
-- Name: fec_fitem_sched_a_2013_2014; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_2013_2014 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_2013_2014 TO openfec_read;


--
-- Name: fec_fitem_sched_a_2015_2016; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_2015_2016 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_2015_2016 TO openfec_read;


--
-- Name: fec_fitem_sched_a_2017_2018; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_2017_2018 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_a_2017_2018 TO openfec_read;


--
-- Name: fec_fitem_sched_b; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b TO openfec_read;


--
-- Name: fec_fitem_sched_b_1975_1976; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1975_1976 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1975_1976 TO openfec_read;


--
-- Name: fec_fitem_sched_b_1977_1978; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1977_1978 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1977_1978 TO openfec_read;


--
-- Name: fec_fitem_sched_b_1979_1980; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1979_1980 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1979_1980 TO openfec_read;


--
-- Name: fec_fitem_sched_b_1981_1982; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1981_1982 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1981_1982 TO openfec_read;


--
-- Name: fec_fitem_sched_b_1983_1984; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1983_1984 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1983_1984 TO openfec_read;


--
-- Name: fec_fitem_sched_b_1985_1986; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1985_1986 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1985_1986 TO openfec_read;


--
-- Name: fec_fitem_sched_b_1987_1988; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1987_1988 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1987_1988 TO openfec_read;


--
-- Name: fec_fitem_sched_b_1989_1990; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1989_1990 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1989_1990 TO openfec_read;


--
-- Name: fec_fitem_sched_b_1991_1992; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1991_1992 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1991_1992 TO openfec_read;


--
-- Name: fec_fitem_sched_b_1993_1994; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1993_1994 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1993_1994 TO openfec_read;


--
-- Name: fec_fitem_sched_b_1995_1996; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1995_1996 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1995_1996 TO openfec_read;


--
-- Name: fec_fitem_sched_b_1997_1998; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1997_1998 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1997_1998 TO openfec_read;


--
-- Name: fec_fitem_sched_b_1999_2000; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_1999_2000 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_1999_2000 TO openfec_read;


--
-- Name: fec_fitem_sched_b_2001_2002; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_2001_2002 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_2001_2002 TO openfec_read;


--
-- Name: fec_fitem_sched_b_2003_2004; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_2003_2004 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_2003_2004 TO openfec_read;


--
-- Name: fec_fitem_sched_b_2005_2006; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_2005_2006 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_2005_2006 TO openfec_read;


--
-- Name: fec_fitem_sched_b_2007_2008; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_2007_2008 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_2007_2008 TO openfec_read;


--
-- Name: fec_fitem_sched_b_2009_2010; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_2009_2010 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_2009_2010 TO openfec_read;


--
-- Name: fec_fitem_sched_b_2011_2012; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_2011_2012 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_2011_2012 TO openfec_read;


--
-- Name: fec_fitem_sched_b_2013_2014; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_2013_2014 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_2013_2014 TO openfec_read;


--
-- Name: fec_fitem_sched_b_2015_2016; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_2015_2016 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_2015_2016 TO openfec_read;


--
-- Name: fec_fitem_sched_b_2017_2018; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_2017_2018 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_b_2017_2018 TO openfec_read;


--
-- Name: fec_fitem_sched_c; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_c TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_c TO openfec_read;


--
-- Name: fec_fitem_sched_c1; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_c1 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_c1 TO openfec_read;


--
-- Name: fec_fitem_sched_c2; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_c2 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_c2 TO openfec_read;


--
-- Name: fec_fitem_sched_d; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_d TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_d TO openfec_read;


--
-- Name: fec_fitem_sched_e; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_e TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_e TO openfec_read;


--
-- Name: fec_fitem_sched_f; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_f TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_f TO openfec_read;


--
-- Name: fec_fitem_sched_h1; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_h1 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_h1 TO openfec_read;


--
-- Name: fec_fitem_sched_h2; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_h2 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_h2 TO openfec_read;


--
-- Name: fec_fitem_sched_h3; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_h3 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_h3 TO openfec_read;


--
-- Name: fec_fitem_sched_h4; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_h4 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_h4 TO openfec_read;


--
-- Name: fec_fitem_sched_h5; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_h5 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_h5 TO openfec_read;


--
-- Name: fec_fitem_sched_h6; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_h6 TO fec_read;
GRANT SELECT ON TABLE fec_fitem_sched_h6 TO openfec_read;


--
-- Name: map_states; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE map_states TO fec_read;
GRANT SELECT ON TABLE map_states TO openfec_read;


--
-- Name: nml_form_1; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_1 TO fec_read;
GRANT SELECT ON TABLE nml_form_1 TO openfec_read;


--
-- Name: nml_form_10; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_10 TO fec_read;
GRANT SELECT ON TABLE nml_form_10 TO openfec_read;


--
-- Name: nml_form_105; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_105 TO fec_read;
GRANT SELECT ON TABLE nml_form_105 TO openfec_read;


--
-- Name: nml_form_11; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_11 TO fec_read;
GRANT SELECT ON TABLE nml_form_11 TO openfec_read;


--
-- Name: nml_form_12; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_12 TO fec_read;
GRANT SELECT ON TABLE nml_form_12 TO openfec_read;


--
-- Name: nml_form_13; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_13 TO fec_read;
GRANT SELECT ON TABLE nml_form_13 TO openfec_read;


--
-- Name: nml_form_1z; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_1z TO fec_read;
GRANT SELECT ON TABLE nml_form_1z TO openfec_read;


--
-- Name: nml_form_1_1z_view; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_1_1z_view TO fec_read;


--
-- Name: nml_form_1m; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_1m TO fec_read;
GRANT SELECT ON TABLE nml_form_1m TO openfec_read;


--
-- Name: nml_form_1s; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_1s TO fec_read;
GRANT SELECT ON TABLE nml_form_1s TO openfec_read;


--
-- Name: nml_form_2; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_2 TO fec_read;
GRANT SELECT ON TABLE nml_form_2 TO openfec_read;


--
-- Name: nml_form_24; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_24 TO fec_read;
GRANT SELECT ON TABLE nml_form_24 TO openfec_read;


--
-- Name: nml_form_2z; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_2z TO fec_read;
GRANT SELECT ON TABLE nml_form_2z TO openfec_read;


--
-- Name: nml_form_2_2z_view; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_2_2z_view TO fec_read;


--
-- Name: nml_form_2s; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_2s TO fec_read;
GRANT SELECT ON TABLE nml_form_2s TO openfec_read;


--
-- Name: nml_form_3; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_3 TO fec_read;
GRANT SELECT ON TABLE nml_form_3 TO openfec_read;


--
-- Name: nml_form_3l; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_3l TO fec_read;
GRANT SELECT ON TABLE nml_form_3l TO openfec_read;


--
-- Name: nml_form_3p; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_3p TO fec_read;
GRANT SELECT ON TABLE nml_form_3p TO openfec_read;


--
-- Name: nml_form_3ps; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_3ps TO fec_read;
GRANT SELECT ON TABLE nml_form_3ps TO openfec_read;


--
-- Name: nml_form_3pz; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_3pz TO fec_read;
GRANT SELECT ON TABLE nml_form_3pz TO openfec_read;


--
-- Name: nml_form_3s; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_3s TO fec_read;
GRANT SELECT ON TABLE nml_form_3s TO openfec_read;


--
-- Name: nml_form_3x; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_3x TO fec_read;
GRANT SELECT ON TABLE nml_form_3x TO openfec_read;


--
-- Name: nml_form_3z; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_3z TO fec_read;
GRANT SELECT ON TABLE nml_form_3z TO openfec_read;


--
-- Name: nml_form_4; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_4 TO fec_read;
GRANT SELECT ON TABLE nml_form_4 TO openfec_read;


--
-- Name: nml_form_5; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_5 TO fec_read;
GRANT SELECT ON TABLE nml_form_5 TO openfec_read;


--
-- Name: nml_form_56; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_56 TO fec_read;
GRANT SELECT ON TABLE nml_form_56 TO openfec_read;


--
-- Name: nml_form_57; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_57 TO fec_read;
GRANT SELECT ON TABLE nml_form_57 TO openfec_read;


--
-- Name: nml_form_6; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_6 TO fec_read;
GRANT SELECT ON TABLE nml_form_6 TO openfec_read;


--
-- Name: nml_form_65; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_65 TO fec_read;
GRANT SELECT ON TABLE nml_form_65 TO openfec_read;


--
-- Name: nml_form_7; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_7 TO fec_read;
GRANT SELECT ON TABLE nml_form_7 TO openfec_read;


--
-- Name: nml_form_76; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_76 TO fec_read;
GRANT SELECT ON TABLE nml_form_76 TO openfec_read;


--
-- Name: nml_form_8; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_8 TO fec_read;
GRANT SELECT ON TABLE nml_form_8 TO openfec_read;


--
-- Name: nml_form_82; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_82 TO fec_read;
GRANT SELECT ON TABLE nml_form_82 TO openfec_read;


--
-- Name: nml_form_83; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_83 TO fec_read;
GRANT SELECT ON TABLE nml_form_83 TO openfec_read;


--
-- Name: nml_form_9; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_9 TO fec_read;
GRANT SELECT ON TABLE nml_form_9 TO openfec_read;


--
-- Name: nml_form_91; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_91 TO fec_read;
GRANT SELECT ON TABLE nml_form_91 TO openfec_read;


--
-- Name: nml_form_94; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_94 TO fec_read;
GRANT SELECT ON TABLE nml_form_94 TO openfec_read;


--
-- Name: nml_form_99_misc; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_99_misc TO fec_read;
GRANT SELECT ON TABLE nml_form_99_misc TO openfec_read;


--
-- Name: nml_form_rfai; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_form_rfai TO fec_read;
GRANT SELECT ON TABLE nml_form_rfai TO openfec_read;


--
-- Name: nml_sched_a; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_a TO fec_read;
GRANT SELECT ON TABLE nml_sched_a TO openfec_read;


--
-- Name: nml_sched_a_daily; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_a_daily TO fec_read;
GRANT SELECT ON TABLE nml_sched_a_daily TO openfec_read;


--
-- Name: nml_sched_b; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_b TO fec_read;
GRANT SELECT ON TABLE nml_sched_b TO openfec_read;


--
-- Name: nml_sched_b_daily; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_b_daily TO fec_read;
GRANT SELECT ON TABLE nml_sched_b_daily TO openfec_read;


--
-- Name: nml_sched_c; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_c TO fec_read;
GRANT SELECT ON TABLE nml_sched_c TO openfec_read;


--
-- Name: nml_sched_c1; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_c1 TO fec_read;
GRANT SELECT ON TABLE nml_sched_c1 TO openfec_read;


--
-- Name: nml_sched_c2; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_c2 TO fec_read;
GRANT SELECT ON TABLE nml_sched_c2 TO openfec_read;


--
-- Name: nml_sched_d; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_d TO fec_read;
GRANT SELECT ON TABLE nml_sched_d TO openfec_read;


--
-- Name: nml_sched_e; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_e TO fec_read;
GRANT SELECT ON TABLE nml_sched_e TO openfec_read;


--
-- Name: nml_sched_f; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_f TO fec_read;
GRANT SELECT ON TABLE nml_sched_f TO openfec_read;


--
-- Name: nml_sched_h1; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_h1 TO fec_read;
GRANT SELECT ON TABLE nml_sched_h1 TO openfec_read;


--
-- Name: nml_sched_h2; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_h2 TO fec_read;
GRANT SELECT ON TABLE nml_sched_h2 TO openfec_read;


--
-- Name: nml_sched_h3; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_h3 TO fec_read;
GRANT SELECT ON TABLE nml_sched_h3 TO openfec_read;


--
-- Name: nml_sched_h4; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_h4 TO fec_read;
GRANT SELECT ON TABLE nml_sched_h4 TO openfec_read;


--
-- Name: nml_sched_h5; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_h5 TO fec_read;
GRANT SELECT ON TABLE nml_sched_h5 TO openfec_read;


--
-- Name: nml_sched_h6; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_h6 TO fec_read;
GRANT SELECT ON TABLE nml_sched_h6 TO openfec_read;


--
-- Name: nml_sched_i; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_i TO fec_read;
GRANT SELECT ON TABLE nml_sched_i TO openfec_read;


--
-- Name: nml_sched_l; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE nml_sched_l TO fec_read;
GRANT SELECT ON TABLE nml_sched_l TO openfec_read;


SET search_path = rad_pri_user, pg_catalog;

--
-- Name: rad_anlyst; Type: ACL; Schema: rad_pri_user; Owner: fec
--

GRANT SELECT ON TABLE rad_anlyst TO fec_read;
GRANT SELECT ON TABLE rad_anlyst TO openfec_read;


--
-- Name: rad_lkp_anlyst_title; Type: ACL; Schema: rad_pri_user; Owner: fec
--

GRANT SELECT ON TABLE rad_lkp_anlyst_title TO fec_read;
GRANT SELECT ON TABLE rad_lkp_anlyst_title TO openfec_read;


SET search_path = disclosure, pg_catalog;

--
-- Name: rad_active_analyst_vw; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE rad_active_analyst_vw TO fec_read;
GRANT SELECT ON TABLE rad_active_analyst_vw TO openfec_read;


SET search_path = rad_pri_user, pg_catalog;

--
-- Name: rad_assgn; Type: ACL; Schema: rad_pri_user; Owner: fec
--

GRANT SELECT ON TABLE rad_assgn TO fec_read;
GRANT SELECT ON TABLE rad_assgn TO openfec_read;


SET search_path = disclosure, pg_catalog;

--
-- Name: rad_cmte_analyst_search_vw; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE rad_cmte_analyst_search_vw TO fec_read;
GRANT SELECT ON TABLE rad_cmte_analyst_search_vw TO openfec_read;


--
-- Name: ref_ai; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE ref_ai TO fec_read;
GRANT SELECT ON TABLE ref_ai TO openfec_read;


--
-- Name: ref_filing_desc; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE ref_filing_desc TO fec_read;
GRANT SELECT ON TABLE ref_filing_desc TO openfec_read;


--
-- Name: unverified_cand_cmte; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE unverified_cand_cmte TO fec_read;
GRANT SELECT ON TABLE unverified_cand_cmte TO openfec_read;


--
-- Name: v_sum_and_det_sum_report; Type: ACL; Schema: disclosure; Owner: fec
--

GRANT SELECT ON TABLE v_sum_and_det_sum_report TO fec_read;
GRANT SELECT ON TABLE v_sum_and_det_sum_report TO openfec_read;


SET search_path = fecapp, pg_catalog;

--
-- Name: cal_category; Type: ACL; Schema: fecapp; Owner: fec
--

GRANT SELECT ON TABLE cal_category TO fec_read;
GRANT SELECT ON TABLE cal_category TO openfec_read;


--
-- Name: cal_category_subcat; Type: ACL; Schema: fecapp; Owner: fec
--

GRANT SELECT ON TABLE cal_category_subcat TO fec_read;
GRANT SELECT ON TABLE cal_category_subcat TO openfec_read;


--
-- Name: cal_event; Type: ACL; Schema: fecapp; Owner: fec
--

GRANT SELECT ON TABLE cal_event TO fec_read;


--
-- Name: cal_event_category; Type: ACL; Schema: fecapp; Owner: fec
--

GRANT SELECT ON TABLE cal_event_category TO fec_read;
GRANT SELECT ON TABLE cal_event_category TO openfec_read;


--
-- Name: cal_event_status; Type: ACL; Schema: fecapp; Owner: fec
--

GRANT SELECT ON TABLE cal_event_status TO fec_read;
GRANT SELECT ON TABLE cal_event_status TO openfec_read;


--
-- Name: trc_election; Type: ACL; Schema: fecapp; Owner: fec
--

GRANT SELECT ON TABLE trc_election TO fec_read;
GRANT SELECT ON TABLE trc_election TO openfec_read;


--
-- Name: trc_election_dates; Type: ACL; Schema: fecapp; Owner: fec
--

GRANT SELECT ON TABLE trc_election_dates TO fec_read;
GRANT SELECT ON TABLE trc_election_dates TO openfec_read;


--
-- Name: trc_election_status; Type: ACL; Schema: fecapp; Owner: fec
--

GRANT SELECT ON TABLE trc_election_status TO fec_read;
GRANT SELECT ON TABLE trc_election_status TO openfec_read;


--
-- Name: trc_election_type; Type: ACL; Schema: fecapp; Owner: fec
--

GRANT SELECT ON TABLE trc_election_type TO fec_read;
GRANT SELECT ON TABLE trc_election_type TO openfec_read;


--
-- Name: trc_report_due_date; Type: ACL; Schema: fecapp; Owner: fec
--

GRANT SELECT ON TABLE trc_report_due_date TO fec_read;
GRANT SELECT ON TABLE trc_report_due_date TO openfec_read;


SET search_path = fecmur, pg_catalog;

--
-- Name: af_case; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE af_case TO fec_read;
GRANT SELECT ON TABLE af_case TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE af_case TO aomur_usr;


--
-- Name: calendar; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE calendar TO fec_read;
GRANT SELECT ON TABLE calendar TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE calendar TO aomur_usr;


--
-- Name: case; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE "case" TO fec_read;
GRANT SELECT ON TABLE "case" TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "case" TO aomur_usr;


--
-- Name: case_subject; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE case_subject TO fec_read;
GRANT SELECT ON TABLE case_subject TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE case_subject TO aomur_usr;


--
-- Name: commission; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE commission TO fec_read;
GRANT SELECT ON TABLE commission TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE commission TO aomur_usr;


--
-- Name: doc_order; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE doc_order TO fec_read;
GRANT SELECT ON TABLE doc_order TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE doc_order TO aomur_usr;


--
-- Name: document; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE document TO fec_read;
GRANT SELECT ON TABLE document TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE document TO aomur_usr;


--
-- Name: document_chg; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE document_chg TO fec_read;
GRANT SELECT ON TABLE document_chg TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE document_chg TO aomur_usr;


--
-- Name: electioncycle; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE electioncycle TO fec_read;
GRANT SELECT ON TABLE electioncycle TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE electioncycle TO aomur_usr;


--
-- Name: entity; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE entity TO fec_read;
GRANT SELECT ON TABLE entity TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE entity TO aomur_usr;


--
-- Name: event; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE event TO fec_read;
GRANT SELECT ON TABLE event TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE event TO aomur_usr;


--
-- Name: milind; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE milind TO fec_read;
GRANT SELECT ON TABLE milind TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE milind TO aomur_usr;


--
-- Name: non_monetary_term; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE non_monetary_term TO fec_read;
GRANT SELECT ON TABLE non_monetary_term TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE non_monetary_term TO aomur_usr;


--
-- Name: players; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE players TO fec_read;
GRANT SELECT ON TABLE players TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE players TO aomur_usr;


--
-- Name: relatedobjects; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE relatedobjects TO fec_read;
GRANT SELECT ON TABLE relatedobjects TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE relatedobjects TO aomur_usr;


--
-- Name: relatedsubject; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE relatedsubject TO fec_read;
GRANT SELECT ON TABLE relatedsubject TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE relatedsubject TO aomur_usr;


--
-- Name: relationtype; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE relationtype TO fec_read;
GRANT SELECT ON TABLE relationtype TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE relationtype TO aomur_usr;


--
-- Name: role; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE role TO fec_read;
GRANT SELECT ON TABLE role TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE role TO aomur_usr;


--
-- Name: settlement; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE settlement TO fec_read;
GRANT SELECT ON TABLE settlement TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE settlement TO aomur_usr;


--
-- Name: stage_order; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE stage_order TO fec_read;
GRANT SELECT ON TABLE stage_order TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE stage_order TO aomur_usr;


--
-- Name: subject; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE subject TO fec_read;
GRANT SELECT ON TABLE subject TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE subject TO aomur_usr;


--
-- Name: violations; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE violations TO fec_read;
GRANT SELECT ON TABLE violations TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE violations TO aomur_usr;


--
-- Name: votes; Type: ACL; Schema: fecmur; Owner: fec
--

GRANT SELECT ON TABLE votes TO fec_read;
GRANT SELECT ON TABLE votes TO openfec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE votes TO aomur_usr;


SET search_path = public, pg_catalog;

--
-- Name: checkpointtable; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE checkpointtable TO fec_read;


--
-- Name: checkpointtable_lox; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE checkpointtable_lox TO fec_read;


--
-- Name: checkpointtable_rj; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE checkpointtable_rj TO fec_read;


SET search_path = real_efile, pg_catalog;

--
-- Name: reps; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE reps TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE reps TO real_file;


SET search_path = public, pg_catalog;

--
-- Name: efiling_amendment_chain_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE efiling_amendment_chain_vw TO fec_read;


--
-- Name: electioneering_com_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE electioneering_com_vw TO fec_read;


--
-- Name: entity_disbursements_chart; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE entity_disbursements_chart TO fec_read;


--
-- Name: entity_receipts_chart; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE entity_receipts_chart TO fec_read;


--
-- Name: fec_f24_notice_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_f24_notice_vw TO fec_read;


--
-- Name: fec_f56_notice_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_f56_notice_vw TO fec_read;


--
-- Name: fec_f57_notice_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_f57_notice_vw TO fec_read;


--
-- Name: fec_f5_notice_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_f5_notice_vw TO fec_read;


--
-- Name: fec_f65_notice_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_f65_notice_vw TO fec_read;


--
-- Name: fec_f6_notice_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_f6_notice_vw TO fec_read;


--
-- Name: fec_fitem_f105_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_f105_vw TO fec_read;


--
-- Name: fec_fitem_f56_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_f56_vw TO fec_read;


--
-- Name: fec_fitem_f57_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_f57_vw TO fec_read;


--
-- Name: fec_fitem_f76_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_f76_vw TO fec_read;


--
-- Name: fec_fitem_f91_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_f91_vw TO fec_read;


--
-- Name: fec_fitem_f94_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_f94_vw TO fec_read;


--
-- Name: fec_fitem_sched_a_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_a_vw TO fec_read;


--
-- Name: fec_fitem_sched_b_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_b_vw TO fec_read;


--
-- Name: fec_fitem_sched_c1_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_c1_vw TO fec_read;


--
-- Name: fec_fitem_sched_c2_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_c2_vw TO fec_read;


--
-- Name: fec_fitem_sched_c_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_c_vw TO fec_read;


--
-- Name: fec_fitem_sched_d_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_d_vw TO fec_read;


--
-- Name: fec_fitem_sched_e_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_e_vw TO fec_read;


--
-- Name: fec_fitem_sched_f_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_f_vw TO fec_read;


--
-- Name: fec_fitem_sched_h1_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_h1_vw TO fec_read;


--
-- Name: fec_fitem_sched_h2_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_h2_vw TO fec_read;


--
-- Name: fec_fitem_sched_h3_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_h3_vw TO fec_read;


--
-- Name: fec_fitem_sched_h4_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_h4_vw TO fec_read;


--
-- Name: fec_fitem_sched_h5_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_h5_vw TO fec_read;


--
-- Name: fec_fitem_sched_h6_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_fitem_sched_h6_vw TO fec_read;


--
-- Name: fec_form_10_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_10_vw TO fec_read;


--
-- Name: fec_form_11_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_11_vw TO fec_read;


--
-- Name: fec_form_12_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_12_vw TO fec_read;


--
-- Name: fec_form_13_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_13_vw TO fec_read;


--
-- Name: fec_form_1m_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_1m_vw TO fec_read;


--
-- Name: fec_form_1s_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_1s_vw TO fec_read;


--
-- Name: fec_form_2s_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_2s_vw TO fec_read;


--
-- Name: fec_form_3l_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_3l_vw TO fec_read;


--
-- Name: fec_form_82_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_82_vw TO fec_read;


--
-- Name: fec_form_83_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_83_vw TO fec_read;


--
-- Name: fec_form_8_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_8_vw TO fec_read;


--
-- Name: fec_form_99_misc_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_99_misc_vw TO fec_read;


--
-- Name: fec_form_rfai_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_form_rfai_vw TO fec_read;


--
-- Name: fec_sched_e_notice_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_sched_e_notice_vw TO fec_read;


--
-- Name: fec_vsum_f105_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f105_vw TO fec_read;


--
-- Name: fec_vsum_f1_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f1_vw TO fec_read;


--
-- Name: fec_vsum_f2_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f2_vw TO fec_read;


--
-- Name: fec_vsum_f3_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f3_vw TO fec_read;


--
-- Name: fec_vsum_f3p_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f3p_vw TO fec_read;


--
-- Name: fec_vsum_f3ps_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f3ps_vw TO fec_read;


--
-- Name: fec_vsum_f3s_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f3s_vw TO fec_read;


--
-- Name: fec_vsum_f3x_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f3x_vw TO fec_read;


--
-- Name: fec_vsum_f3z_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f3z_vw TO fec_read;


--
-- Name: fec_vsum_f56_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f56_vw TO fec_read;


--
-- Name: fec_vsum_f57_queue_new; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f57_queue_new TO fec_read;


--
-- Name: fec_vsum_f57_queue_old; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f57_queue_old TO fec_read;


--
-- Name: fec_vsum_f57_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f57_vw TO fec_read;


--
-- Name: fec_vsum_f5_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f5_vw TO fec_read;


--
-- Name: fec_vsum_f76_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f76_vw TO fec_read;


--
-- Name: fec_vsum_f7_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f7_vw TO fec_read;


--
-- Name: fec_vsum_f91_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f91_vw TO fec_read;


--
-- Name: fec_vsum_f94_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f94_vw TO fec_read;


--
-- Name: fec_vsum_f9_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_f9_vw TO fec_read;


--
-- Name: fec_vsum_form_4_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_form_4_vw TO fec_read;


--
-- Name: fec_vsum_sched_a_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_a_vw TO fec_read;


--
-- Name: fec_vsum_sched_b_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_b_vw TO fec_read;


--
-- Name: fec_vsum_sched_c1_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_c1_vw TO fec_read;


--
-- Name: fec_vsum_sched_c2_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_c2_vw TO fec_read;


--
-- Name: fec_vsum_sched_c_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_c_vw TO fec_read;


--
-- Name: fec_vsum_sched_d_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_d_vw TO fec_read;


--
-- Name: fec_vsum_sched_e_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_e_vw TO fec_read;


--
-- Name: fec_vsum_sched_f_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_f_vw TO fec_read;


--
-- Name: fec_vsum_sched_h1_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_h1_vw TO fec_read;


--
-- Name: fec_vsum_sched_h2_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_h2_vw TO fec_read;


--
-- Name: fec_vsum_sched_h3_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_h3_vw TO fec_read;


--
-- Name: fec_vsum_sched_h4_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_h4_vw TO fec_read;


--
-- Name: fec_vsum_sched_h5_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_h5_vw TO fec_read;


--
-- Name: fec_vsum_sched_h6_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_h6_vw TO fec_read;


--
-- Name: fec_vsum_sched_i_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_i_vw TO fec_read;


--
-- Name: fec_vsum_sched_l_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE fec_vsum_sched_l_vw TO fec_read;


--
-- Name: ofec_amendments_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_amendments_mv TO fec_read;


--
-- Name: ofec_cand_cmte_linkage_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_cand_cmte_linkage_mv TO fec_read;


--
-- Name: unverified_filers_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE unverified_filers_vw TO fec_read;


SET search_path = staging, pg_catalog;

--
-- Name: ref_pty; Type: ACL; Schema: staging; Owner: fec
--

GRANT SELECT ON TABLE ref_pty TO fec_read;
GRANT SELECT ON TABLE ref_pty TO openfec_read;


SET search_path = public, pg_catalog;

--
-- Name: ofec_candidate_history_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_candidate_history_mv TO fec_read;


--
-- Name: ofec_candidate_detail_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_candidate_detail_mv TO fec_read;


--
-- Name: ofec_candidate_election_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_candidate_election_mv TO fec_read;


--
-- Name: ofec_committee_history_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_committee_history_mv TO fec_read;


--
-- Name: ofec_house_senate_paper_amendments_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_house_senate_paper_amendments_mv TO fec_read;


--
-- Name: ofec_pac_party_paper_amendments_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_pac_party_paper_amendments_mv TO fec_read;


--
-- Name: ofec_presidential_paper_amendments_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_presidential_paper_amendments_mv TO fec_read;


--
-- Name: ofec_filings_amendments_all_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_filings_amendments_all_mv TO fec_read;


SET search_path = staging, pg_catalog;

--
-- Name: ref_rpt_tp; Type: ACL; Schema: staging; Owner: fec
--

GRANT SELECT ON TABLE ref_rpt_tp TO fec_read;
GRANT SELECT ON TABLE ref_rpt_tp TO openfec_read;


SET search_path = public, pg_catalog;

--
-- Name: ofec_filings_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_filings_mv TO fec_read;


--
-- Name: ofec_totals_combined_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_totals_combined_mv TO fec_read;


--
-- Name: ofec_totals_house_senate_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_totals_house_senate_mv TO fec_read;


--
-- Name: ofec_totals_presidential_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_totals_presidential_mv TO fec_read;


--
-- Name: ofec_candidate_totals_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_candidate_totals_mv TO fec_read;


--
-- Name: ofec_candidate_flag; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_candidate_flag TO fec_read;


--
-- Name: ofec_nicknames; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_nicknames TO fec_read;


--
-- Name: ofec_candidate_fulltext_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_candidate_fulltext_mv TO fec_read;


--
-- Name: ofec_candidate_history_latest_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_candidate_history_latest_mv TO fec_read;


--
-- Name: ofec_committee_detail_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_committee_detail_mv TO fec_read;


--
-- Name: ofec_pacronyms; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_pacronyms TO fec_read;


--
-- Name: ofec_committee_fulltext_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_committee_fulltext_mv TO fec_read;


--
-- Name: ofec_committee_totals; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_committee_totals TO fec_read;


--
-- Name: ofec_communication_cost_aggregate_candidate_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_communication_cost_aggregate_candidate_mv TO fec_read;


--
-- Name: ofec_communication_cost_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_communication_cost_mv TO fec_read;


--
-- Name: ofec_election_dates; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_election_dates TO fec_read;


--
-- Name: ofec_election_result_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_election_result_mv TO fec_read;


--
-- Name: ofec_electioneering_aggregate_candidate_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_electioneering_aggregate_candidate_mv TO fec_read;


--
-- Name: ofec_electioneering_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_electioneering_mv TO fec_read;


--
-- Name: ofec_totals_pacs_parties_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_totals_pacs_parties_mv TO fec_read;


--
-- Name: ofec_totals_pacs_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_totals_pacs_mv TO fec_read;


--
-- Name: ofec_totals_parties_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_totals_parties_mv TO fec_read;


--
-- Name: ofec_f57_queue_new; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_f57_queue_new TO fec_read;


--
-- Name: ofec_f57_queue_old; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_f57_queue_old TO fec_read;


--
-- Name: ofec_house_senate_electronic_amendments_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_house_senate_electronic_amendments_mv TO fec_read;


--
-- Name: ofec_nml_24_queue_new; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_nml_24_queue_new TO fec_read;


--
-- Name: ofec_nml_24_queue_old; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_nml_24_queue_old TO fec_read;


--
-- Name: ofec_pac_party_electronic_amendments_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_pac_party_electronic_amendments_mv TO fec_read;


--
-- Name: ofec_presidential_electronic_amendments_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_presidential_electronic_amendments_mv TO fec_read;


--
-- Name: ofec_rad_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_rad_mv TO fec_read;


--
-- Name: ofec_reports_house_senate_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_reports_house_senate_mv TO fec_read;


--
-- Name: ofec_reports_ie_only_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_reports_ie_only_mv TO fec_read;


--
-- Name: ofec_reports_pacs_parties_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_reports_pacs_parties_mv TO fec_read;


--
-- Name: ofec_reports_presidential_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_reports_presidential_mv TO fec_read;


--
-- Name: ofec_sched_a_master; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_master TO fec_read;


--
-- Name: ofec_sched_a_1977_1978; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_1977_1978 TO fec_read;


--
-- Name: ofec_sched_a_1979_1980; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_1979_1980 TO fec_read;


--
-- Name: ofec_sched_a_1981_1982; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_1981_1982 TO fec_read;


--
-- Name: ofec_sched_a_1983_1984; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_1983_1984 TO fec_read;


--
-- Name: ofec_sched_a_1985_1986; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_1985_1986 TO fec_read;


--
-- Name: ofec_sched_a_1987_1988; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_1987_1988 TO fec_read;


--
-- Name: ofec_sched_a_1989_1990; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_1989_1990 TO fec_read;


--
-- Name: ofec_sched_a_1991_1992; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_1991_1992 TO fec_read;


--
-- Name: ofec_sched_a_1993_1994; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_1993_1994 TO fec_read;


--
-- Name: ofec_sched_a_1995_1996; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_1995_1996 TO fec_read;


--
-- Name: ofec_sched_a_1997_1998; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_1997_1998 TO fec_read;


--
-- Name: ofec_sched_a_1999_2000; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_1999_2000 TO fec_read;


--
-- Name: ofec_sched_a_2001_2002; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_2001_2002 TO fec_read;


--
-- Name: ofec_sched_a_2003_2004; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_2003_2004 TO fec_read;


--
-- Name: ofec_sched_a_2005_2006; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_2005_2006 TO fec_read;


--
-- Name: ofec_sched_a_2007_2008; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_2007_2008 TO fec_read;


--
-- Name: ofec_sched_a_2009_2010; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_2009_2010 TO fec_read;


--
-- Name: ofec_sched_a_2011_2012; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_2011_2012 TO fec_read;


--
-- Name: ofec_sched_a_2013_2014; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_2013_2014 TO fec_read;


--
-- Name: ofec_sched_a_2015_2016; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_2015_2016 TO fec_read;


--
-- Name: ofec_sched_a_2017_2018; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_2017_2018 TO fec_read;


--
-- Name: ofec_sched_a_aggregate_contributor; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_aggregate_contributor TO fec_read;


--
-- Name: ofec_sched_a_aggregate_contributor_type; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_aggregate_contributor_type TO fec_read;


--
-- Name: ofec_sched_a_aggregate_employer; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_aggregate_employer TO fec_read;


--
-- Name: ofec_sched_a_aggregate_occupation; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_aggregate_occupation TO fec_read;


--
-- Name: ofec_sched_a_aggregate_size; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_aggregate_size TO fec_read;


--
-- Name: ofec_sched_a_aggregate_size_merged; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_aggregate_size_merged TO fec_read;


--
-- Name: ofec_sched_a_aggregate_size_merged_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_aggregate_size_merged_mv TO fec_read;


--
-- Name: ofec_sched_a_aggregate_state; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_aggregate_state TO fec_read;


--
-- Name: ofec_sched_a_aggregate_state_old; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_aggregate_state_old TO fec_read;


--
-- Name: ofec_sched_a_aggregate_state_recipient_totals; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_aggregate_state_recipient_totals TO fec_read;


--
-- Name: ofec_sched_a_aggregate_zip; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_aggregate_zip TO fec_read;


--
-- Name: ofec_sched_a_fulltext; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_fulltext TO fec_read;


--
-- Name: ofec_sched_a_queue_new; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_queue_new TO fec_read;


--
-- Name: ofec_sched_a_queue_old; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_a_queue_old TO fec_read;


--
-- Name: ofec_sched_b_master; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_master TO fec_read;


--
-- Name: ofec_sched_b_1977_1978; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_1977_1978 TO fec_read;


--
-- Name: ofec_sched_b_1979_1980; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_1979_1980 TO fec_read;


--
-- Name: ofec_sched_b_1981_1982; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_1981_1982 TO fec_read;


--
-- Name: ofec_sched_b_1983_1984; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_1983_1984 TO fec_read;


--
-- Name: ofec_sched_b_1985_1986; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_1985_1986 TO fec_read;


--
-- Name: ofec_sched_b_1987_1988; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_1987_1988 TO fec_read;


--
-- Name: ofec_sched_b_1989_1990; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_1989_1990 TO fec_read;


--
-- Name: ofec_sched_b_1991_1992; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_1991_1992 TO fec_read;


--
-- Name: ofec_sched_b_1993_1994; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_1993_1994 TO fec_read;


--
-- Name: ofec_sched_b_1995_1996; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_1995_1996 TO fec_read;


--
-- Name: ofec_sched_b_1997_1998; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_1997_1998 TO fec_read;


--
-- Name: ofec_sched_b_1999_2000; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_1999_2000 TO fec_read;


--
-- Name: ofec_sched_b_2001_2002; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_2001_2002 TO fec_read;


--
-- Name: ofec_sched_b_2003_2004; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_2003_2004 TO fec_read;


--
-- Name: ofec_sched_b_2005_2006; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_2005_2006 TO fec_read;


--
-- Name: ofec_sched_b_2007_2008; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_2007_2008 TO fec_read;


--
-- Name: ofec_sched_b_2009_2010; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_2009_2010 TO fec_read;


--
-- Name: ofec_sched_b_2011_2012; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_2011_2012 TO fec_read;


--
-- Name: ofec_sched_b_2013_2014; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_2013_2014 TO fec_read;


--
-- Name: ofec_sched_b_2015_2016; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_2015_2016 TO fec_read;


--
-- Name: ofec_sched_b_2017_2018; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_2017_2018 TO fec_read;


--
-- Name: ofec_sched_b_aggregate_purpose; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_aggregate_purpose TO fec_read;


--
-- Name: ofec_sched_b_aggregate_recipient; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_aggregate_recipient TO fec_read;


--
-- Name: ofec_sched_b_aggregate_recipient_id; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_aggregate_recipient_id TO fec_read;


--
-- Name: ofec_sched_b_fulltext; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_fulltext TO fec_read;


--
-- Name: ofec_sched_b_queue_new; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_queue_new TO fec_read;


--
-- Name: ofec_sched_b_queue_old; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_b_queue_old TO fec_read;


--
-- Name: ofec_sched_c_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_c_mv TO fec_read;


--
-- Name: ofec_sched_e; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_e TO fec_read;


--
-- Name: ofec_sched_e_aggregate_candidate_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_e_aggregate_candidate_mv TO fec_read;


--
-- Name: ofec_sched_e_queue_new; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_e_queue_new TO fec_read;


--
-- Name: ofec_sched_e_queue_old; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_e_queue_old TO fec_read;


--
-- Name: ofec_sched_f_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_sched_f_mv TO fec_read;


--
-- Name: ofec_totals_candidate_committees_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_totals_candidate_committees_mv TO fec_read;


--
-- Name: ofec_totals_ie_only_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_totals_ie_only_mv TO fec_read;


--
-- Name: ofec_two_year_periods; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_two_year_periods TO fec_read;


--
-- Name: pacronyms; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE pacronyms TO fec_read;


SET search_path = real_efile, pg_catalog;

--
-- Name: f3; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f3 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3 TO real_file;


SET search_path = public, pg_catalog;

--
-- Name: real_efile_f3; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE real_efile_f3 TO fec_read;


SET search_path = real_efile, pg_catalog;

--
-- Name: f3p; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f3p TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3p TO real_file;


SET search_path = public, pg_catalog;

--
-- Name: real_efile_f3p; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE real_efile_f3p TO fec_read;


SET search_path = real_efile, pg_catalog;

--
-- Name: f3x; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f3x TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3x TO real_file;


SET search_path = public, pg_catalog;

--
-- Name: real_efile_f3x; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE real_efile_f3x TO fec_read;


--
-- Name: real_efile_reps; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE real_efile_reps TO fec_read;


SET search_path = real_efile, pg_catalog;

--
-- Name: sa7; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE sa7 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sa7 TO real_file;


SET search_path = public, pg_catalog;

--
-- Name: real_efile_sa7; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE real_efile_sa7 TO fec_read;


SET search_path = real_efile, pg_catalog;

--
-- Name: sb4; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE sb4 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sb4 TO real_file;


SET search_path = public, pg_catalog;

--
-- Name: real_efile_sb4; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE real_efile_sb4 TO fec_read;


SET search_path = real_efile, pg_catalog;

--
-- Name: se; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE se TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE se TO real_file;


SET search_path = public, pg_catalog;

--
-- Name: real_efile_schedule_e_reports; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE real_efile_schedule_e_reports TO fec_read;


--
-- Name: real_efile_se; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE real_efile_se TO fec_read;


SET search_path = real_efile, pg_catalog;

--
-- Name: f57; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f57 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f57 TO real_file;


SET search_path = public, pg_catalog;

--
-- Name: real_efile_se_f57_vw; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE real_efile_se_f57_vw TO fec_read;


SET search_path = real_efile, pg_catalog;

--
-- Name: summary; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE summary TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE summary TO real_file;


SET search_path = public, pg_catalog;

--
-- Name: real_efile_summary; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE real_efile_summary TO fec_read;


SET search_path = real_efile, pg_catalog;

--
-- Name: f1; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f1 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f1 TO real_file;


--
-- Name: f10; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f10 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f10 TO real_file;


--
-- Name: f105; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f105 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f105 TO real_file;


--
-- Name: f13; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f13 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f13 TO real_file;


--
-- Name: f132; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f132 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f132 TO real_file;


--
-- Name: f133; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f133 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f133 TO real_file;


--
-- Name: f1m; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f1m TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f1m TO real_file;


--
-- Name: f1s; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f1s TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f1s TO real_file;


--
-- Name: f2; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f2 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f2 TO real_file;


--
-- Name: f24; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f24 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f24 TO real_file;


--
-- Name: f2s; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f2s TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f2s TO real_file;


--
-- Name: f3l; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f3l TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3l TO real_file;


--
-- Name: f3ps; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f3ps TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3ps TO real_file;


--
-- Name: f3s; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f3s TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3s TO real_file;


--
-- Name: f3z; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f3z TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3z TO real_file;


--
-- Name: f3z1; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3z1 TO real_file;


--
-- Name: f3z2; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3z2 TO real_file;


--
-- Name: f4; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f4 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f4 TO real_file;


--
-- Name: f5; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f5 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f5 TO real_file;


--
-- Name: f56; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f56 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f56 TO real_file;


--
-- Name: f6; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f6 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f6 TO real_file;


--
-- Name: f65; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f65 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f65 TO real_file;


--
-- Name: f7; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f7 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f7 TO real_file;


--
-- Name: f76; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f76 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f76 TO real_file;


--
-- Name: f8; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f8 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f8 TO real_file;


--
-- Name: f8ii; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f8ii TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f8ii TO real_file;


--
-- Name: f8iii; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f8iii TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f8iii TO real_file;


--
-- Name: f9; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f9 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f9 TO real_file;


--
-- Name: f91; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f91 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f91 TO real_file;


--
-- Name: f92; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f92 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f92 TO real_file;


--
-- Name: f93; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f93 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f93 TO real_file;


--
-- Name: f94; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f94 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f94 TO real_file;


--
-- Name: f99; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE f99 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f99 TO real_file;


--
-- Name: guarantors; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE guarantors TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE guarantors TO real_file;


--
-- Name: h1; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE h1 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h1 TO real_file;


--
-- Name: h2; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE h2 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h2 TO real_file;


--
-- Name: h3; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE h3 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h3 TO real_file;


--
-- Name: h4_2; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE h4_2 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h4_2 TO real_file;


--
-- Name: h5; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE h5 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h5 TO real_file;


--
-- Name: h6; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE h6 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h6 TO real_file;


--
-- Name: i_sum; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE i_sum TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE i_sum TO real_file;


--
-- Name: issues; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE issues TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE issues TO real_file;


--
-- Name: sc; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE sc TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sc TO real_file;


--
-- Name: sc1; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE sc1 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sc1 TO real_file;


--
-- Name: sd; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE sd TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sd TO real_file;


--
-- Name: sf; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE sf TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sf TO real_file;


--
-- Name: si; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE si TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE si TO real_file;


--
-- Name: sl; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE sl TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sl TO real_file;


--
-- Name: sl_sum; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE sl_sum TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sl_sum TO real_file;


--
-- Name: supsum; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE supsum TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE supsum TO real_file;


--
-- Name: text; Type: ACL; Schema: real_efile; Owner: fec
--

GRANT SELECT ON TABLE text TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE text TO real_file;


SET search_path = real_pfile, pg_catalog;

--
-- Name: f1; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f1 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f1 TO real_file;


--
-- Name: f10; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f10 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f10 TO real_file;


--
-- Name: f105; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f105 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f105 TO real_file;


--
-- Name: f11; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f11 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f11 TO real_file;


--
-- Name: f12; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f12 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f12 TO real_file;


--
-- Name: f13; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f13 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f13 TO real_file;


--
-- Name: f132; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f132 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f132 TO real_file;


--
-- Name: f133; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f133 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f133 TO real_file;


--
-- Name: f1m; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f1m TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f1m TO real_file;


--
-- Name: f1s; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f1s TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f1s TO real_file;


--
-- Name: f2; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f2 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f2 TO real_file;


--
-- Name: f24; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f24 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f24 TO real_file;


--
-- Name: f3; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f3 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3 TO real_file;


--
-- Name: f3l; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f3l TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3l TO real_file;


--
-- Name: f3p; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f3p TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3p TO real_file;


--
-- Name: f3ps; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f3ps TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3ps TO real_file;


--
-- Name: f3s; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f3s TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3s TO real_file;


--
-- Name: f3x; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f3x TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3x TO real_file;


--
-- Name: f3z; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f3z TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f3z TO real_file;


--
-- Name: f4; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f4 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f4 TO real_file;


--
-- Name: f5; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f5 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f5 TO real_file;


--
-- Name: f56; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f56 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f56 TO real_file;


--
-- Name: f57; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f57 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f57 TO real_file;


--
-- Name: f6; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f6 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f6 TO real_file;


--
-- Name: f65; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f65 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f65 TO real_file;


--
-- Name: f7; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f7 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f7 TO real_file;


--
-- Name: f76; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f76 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f76 TO real_file;


--
-- Name: f8; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f8 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f8 TO real_file;


--
-- Name: f8ii; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f8ii TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f8ii TO real_file;


--
-- Name: f8iii; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f8iii TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f8iii TO real_file;


--
-- Name: f9; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f9 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f9 TO real_file;


--
-- Name: f91; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f91 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f91 TO real_file;


--
-- Name: f92; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f92 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f92 TO real_file;


--
-- Name: f93; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f93 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f93 TO real_file;


--
-- Name: f94; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE f94 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE f94 TO real_file;


--
-- Name: h1; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE h1 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h1 TO real_file;


--
-- Name: h2; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE h2 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h2 TO real_file;


--
-- Name: h3; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE h3 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h3 TO real_file;


--
-- Name: h4; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE h4 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h4 TO real_file;


--
-- Name: h5; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE h5 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h5 TO real_file;


--
-- Name: h6; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE h6 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h6 TO real_file;


--
-- Name: reps; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE reps TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE reps TO real_file;


--
-- Name: sa; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE sa TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sa TO real_file;


--
-- Name: sb; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE sb TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sb TO real_file;


--
-- Name: sc; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE sc TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sc TO real_file;


--
-- Name: sc1; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE sc1 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sc1 TO real_file;


--
-- Name: sc2; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE sc2 TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sc2 TO real_file;


--
-- Name: sd; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE sd TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sd TO real_file;


--
-- Name: se; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE se TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE se TO real_file;


--
-- Name: sf; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE sf TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sf TO real_file;


--
-- Name: sl; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE sl TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sl TO real_file;


--
-- Name: summary; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE summary TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE summary TO real_file;


--
-- Name: summary_sup; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE summary_sup TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE summary_sup TO real_file;


--
-- Name: supsum; Type: ACL; Schema: real_pfile; Owner: fec
--

GRANT SELECT ON TABLE supsum TO fec_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE supsum TO real_file;


SET search_path = rohan, pg_catalog;

--
-- Name: auth_user_id_seq; Type: ACL; Schema: rohan; Owner: fec
--

GRANT ALL ON SEQUENCE auth_user_id_seq TO fec_read;


--
-- Name: row_count_seq; Type: ACL; Schema: rohan; Owner: fec
--

GRANT ALL ON SEQUENCE row_count_seq TO fec_read;


--
-- Name: rj_row_count; Type: ACL; Schema: rohan; Owner: fec
--

GRANT ALL ON TABLE rj_row_count TO fec_read;


--
-- Name: rj_user; Type: ACL; Schema: rohan; Owner: fec
--

GRANT ALL ON TABLE rj_user TO fec_read;


SET search_path = staging, pg_catalog;

--
-- Name: operations_log; Type: ACL; Schema: staging; Owner: fec
--

GRANT SELECT ON TABLE operations_log TO fec_read;
GRANT SELECT ON TABLE operations_log TO openfec_read;


--
-- Name: ref_cand_ici; Type: ACL; Schema: staging; Owner: fec
--

GRANT SELECT ON TABLE ref_cand_ici TO fec_read;
GRANT SELECT ON TABLE ref_cand_ici TO openfec_read;


--
-- Name: ref_cand_office; Type: ACL; Schema: staging; Owner: fec
--

GRANT SELECT ON TABLE ref_cand_office TO fec_read;
GRANT SELECT ON TABLE ref_cand_office TO openfec_read;


--
-- Name: ref_contribution_limits; Type: ACL; Schema: staging; Owner: fec
--

GRANT SELECT ON TABLE ref_contribution_limits TO fec_read;
GRANT SELECT ON TABLE ref_contribution_limits TO openfec_read;


--
-- Name: ref_filed_cmte_dsgn; Type: ACL; Schema: staging; Owner: fec
--

GRANT SELECT ON TABLE ref_filed_cmte_dsgn TO fec_read;
GRANT SELECT ON TABLE ref_filed_cmte_dsgn TO openfec_read;


--
-- Name: ref_filed_cmte_tp; Type: ACL; Schema: staging; Owner: fec
--

GRANT SELECT ON TABLE ref_filed_cmte_tp TO fec_read;
GRANT SELECT ON TABLE ref_filed_cmte_tp TO openfec_read;


--
-- Name: ref_st; Type: ACL; Schema: staging; Owner: fec
--

GRANT SELECT ON TABLE ref_st TO fec_read;
GRANT SELECT ON TABLE ref_st TO openfec_read;


SET search_path = public, pg_catalog;

--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: fec
--

ALTER DEFAULT PRIVILEGES FOR ROLE fec IN SCHEMA public REVOKE ALL ON TABLES  FROM fec;
ALTER DEFAULT PRIVILEGES FOR ROLE fec IN SCHEMA public GRANT SELECT ON TABLES  TO fec_read;


--
-- PostgreSQL database dump complete
--

