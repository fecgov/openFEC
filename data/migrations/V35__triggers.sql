SET search_path = aouser, pg_catalog;

--
-- Name: document upd_pg_date; Type: TRIGGER; Schema: aouser; Owner: fec
--

CREATE TRIGGER upd_pg_date BEFORE UPDATE ON document FOR EACH ROW EXECUTE PROCEDURE public.upd_pg_date();


--
-- Name: ao upd_pg_date; Type: TRIGGER; Schema: aouser; Owner: fec
--

CREATE TRIGGER upd_pg_date BEFORE UPDATE ON ao FOR EACH ROW EXECUTE PROCEDURE public.upd_pg_date();


SET search_path = disclosure, pg_catalog;

--
-- Name: f_item_receipt_or_exp f_item_sched_a_after_trigger; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER f_item_sched_a_after_trigger AFTER INSERT OR UPDATE ON f_item_receipt_or_exp FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_a_insert_update_queues('2007');


--
-- Name: f_item_receipt_or_exp f_item_sched_a_before_trigger; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER f_item_sched_a_before_trigger BEFORE DELETE OR UPDATE ON f_item_receipt_or_exp FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_a_delete_update_queues('2007');


--
-- Name: f_item_receipt_or_exp f_item_sched_b_after_trigger; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER f_item_sched_b_after_trigger AFTER INSERT OR UPDATE ON f_item_receipt_or_exp FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_b_insert_update_queues('2007');


--
-- Name: f_item_receipt_or_exp f_item_sched_b_before_trigger; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER f_item_sched_b_before_trigger BEFORE DELETE OR UPDATE ON f_item_receipt_or_exp FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_b_delete_update_queues('2007');


--
-- Name: nml_sched_e nml_form_24_trigger; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER nml_form_24_trigger BEFORE INSERT OR DELETE OR UPDATE ON nml_sched_e FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_e_update_notice_queues();


--
-- Name: nml_sched_a nml_sched_a_after_trigger; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER nml_sched_a_after_trigger AFTER INSERT OR UPDATE ON nml_sched_a FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_a_insert_update_queues('2007');


--
-- Name: nml_sched_a nml_sched_a_before_trigger; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER nml_sched_a_before_trigger BEFORE DELETE OR UPDATE ON nml_sched_a FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_a_delete_update_queues('2007');


--
-- Name: nml_sched_b nml_sched_b_after_trigger; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER nml_sched_b_after_trigger AFTER INSERT OR UPDATE ON nml_sched_b FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_b_insert_update_queues('2007');


--
-- Name: nml_sched_b nml_sched_b_before_trigger; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER nml_sched_b_before_trigger BEFORE DELETE OR UPDATE ON nml_sched_b FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_b_delete_update_queues('2007');


--
-- Name: nml_form_57 ofec_f57_trigger; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER ofec_f57_trigger BEFORE INSERT OR DELETE OR UPDATE ON nml_form_57 FOR EACH ROW EXECUTE PROCEDURE public.ofec_f57_update_notice_queues();


--
-- Name: nml_sched_d ofec_sched_d_queue_trigger; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER ofec_sched_d_queue_trigger BEFORE INSERT OR UPDATE ON nml_sched_d FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_d_update();


--
-- Name: fec_fitem_sched_a tri_fec_fitem_sched_a; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a BEFORE INSERT ON fec_fitem_sched_a FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1975_1976 tri_fec_fitem_sched_a_1975_1976; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1975_1976 BEFORE INSERT ON fec_fitem_sched_a_1975_1976 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1977_1978 tri_fec_fitem_sched_a_1977_1978; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1977_1978 BEFORE INSERT ON fec_fitem_sched_a_1977_1978 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1979_1980 tri_fec_fitem_sched_a_1979_1980; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1979_1980 BEFORE INSERT ON fec_fitem_sched_a_1979_1980 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1981_1982 tri_fec_fitem_sched_a_1981_1982; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1981_1982 BEFORE INSERT ON fec_fitem_sched_a_1981_1982 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1983_1984 tri_fec_fitem_sched_a_1983_1984; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1983_1984 BEFORE INSERT ON fec_fitem_sched_a_1983_1984 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1985_1986 tri_fec_fitem_sched_a_1985_1986; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1985_1986 BEFORE INSERT ON fec_fitem_sched_a_1985_1986 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1987_1988 tri_fec_fitem_sched_a_1987_1988; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1987_1988 BEFORE INSERT ON fec_fitem_sched_a_1987_1988 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1989_1990 tri_fec_fitem_sched_a_1989_1990; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1989_1990 BEFORE INSERT ON fec_fitem_sched_a_1989_1990 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1991_1992 tri_fec_fitem_sched_a_1991_1992; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1991_1992 BEFORE INSERT ON fec_fitem_sched_a_1991_1992 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1993_1994 tri_fec_fitem_sched_a_1993_1994; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1993_1994 BEFORE INSERT ON fec_fitem_sched_a_1993_1994 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1995_1996 tri_fec_fitem_sched_a_1995_1996; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1995_1996 BEFORE INSERT ON fec_fitem_sched_a_1995_1996 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1997_1998 tri_fec_fitem_sched_a_1997_1998; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1997_1998 BEFORE INSERT ON fec_fitem_sched_a_1997_1998 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_1999_2000 tri_fec_fitem_sched_a_1999_2000; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_1999_2000 BEFORE INSERT ON fec_fitem_sched_a_1999_2000 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_2001_2002 tri_fec_fitem_sched_a_2001_2002; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_2001_2002 BEFORE INSERT ON fec_fitem_sched_a_2001_2002 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_2003_2004 tri_fec_fitem_sched_a_2003_2004; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_2003_2004 BEFORE INSERT ON fec_fitem_sched_a_2003_2004 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_2005_2006 tri_fec_fitem_sched_a_2005_2006; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_2005_2006 BEFORE INSERT ON fec_fitem_sched_a_2005_2006 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_2007_2008 tri_fec_fitem_sched_a_2007_2008; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_2007_2008 BEFORE INSERT ON fec_fitem_sched_a_2007_2008 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_2009_2010 tri_fec_fitem_sched_a_2009_2010; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_2009_2010 BEFORE INSERT ON fec_fitem_sched_a_2009_2010 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_2011_2012 tri_fec_fitem_sched_a_2011_2012; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_2011_2012 BEFORE INSERT ON fec_fitem_sched_a_2011_2012 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_2013_2014 tri_fec_fitem_sched_a_2013_2014; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_2013_2014 BEFORE INSERT ON fec_fitem_sched_a_2013_2014 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_2015_2016 tri_fec_fitem_sched_a_2015_2016; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_2015_2016 BEFORE INSERT ON fec_fitem_sched_a_2015_2016 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_a_2017_2018 tri_fec_fitem_sched_a_2017_2018; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_a_2017_2018 BEFORE INSERT ON fec_fitem_sched_a_2017_2018 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_a_insert();


--
-- Name: fec_fitem_sched_b tri_fec_fitem_sched_b; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b BEFORE INSERT ON fec_fitem_sched_b FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1975_1976 tri_fec_fitem_sched_b_1975_1976; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1975_1976 BEFORE INSERT ON fec_fitem_sched_b_1975_1976 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1977_1978 tri_fec_fitem_sched_b_1977_1978; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1977_1978 BEFORE INSERT ON fec_fitem_sched_b_1977_1978 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1979_1980 tri_fec_fitem_sched_b_1979_1980; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1979_1980 BEFORE INSERT ON fec_fitem_sched_b_1979_1980 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1981_1982 tri_fec_fitem_sched_b_1981_1982; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1981_1982 BEFORE INSERT ON fec_fitem_sched_b_1981_1982 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1983_1984 tri_fec_fitem_sched_b_1983_1984; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1983_1984 BEFORE INSERT ON fec_fitem_sched_b_1983_1984 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1985_1986 tri_fec_fitem_sched_b_1985_1986; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1985_1986 BEFORE INSERT ON fec_fitem_sched_b_1985_1986 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1987_1988 tri_fec_fitem_sched_b_1987_1988; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1987_1988 BEFORE INSERT ON fec_fitem_sched_b_1987_1988 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1989_1990 tri_fec_fitem_sched_b_1989_1990; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1989_1990 BEFORE INSERT ON fec_fitem_sched_b_1989_1990 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1991_1992 tri_fec_fitem_sched_b_1991_1992; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1991_1992 BEFORE INSERT ON fec_fitem_sched_b_1991_1992 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1993_1994 tri_fec_fitem_sched_b_1993_1994; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1993_1994 BEFORE INSERT ON fec_fitem_sched_b_1993_1994 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1995_1996 tri_fec_fitem_sched_b_1995_1996; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1995_1996 BEFORE INSERT ON fec_fitem_sched_b_1995_1996 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1997_1998 tri_fec_fitem_sched_b_1997_1998; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1997_1998 BEFORE INSERT ON fec_fitem_sched_b_1997_1998 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_1999_2000 tri_fec_fitem_sched_b_1999_2000; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_1999_2000 BEFORE INSERT ON fec_fitem_sched_b_1999_2000 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_2001_2002 tri_fec_fitem_sched_b_2001_2002; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_2001_2002 BEFORE INSERT ON fec_fitem_sched_b_2001_2002 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_2003_2004 tri_fec_fitem_sched_b_2003_2004; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_2003_2004 BEFORE INSERT ON fec_fitem_sched_b_2003_2004 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_2005_2006 tri_fec_fitem_sched_b_2005_2006; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_2005_2006 BEFORE INSERT ON fec_fitem_sched_b_2005_2006 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_2007_2008 tri_fec_fitem_sched_b_2007_2008; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_2007_2008 BEFORE INSERT ON fec_fitem_sched_b_2007_2008 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_2009_2010 tri_fec_fitem_sched_b_2009_2010; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_2009_2010 BEFORE INSERT ON fec_fitem_sched_b_2009_2010 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_2011_2012 tri_fec_fitem_sched_b_2011_2012; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_2011_2012 BEFORE INSERT ON fec_fitem_sched_b_2011_2012 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_2013_2014 tri_fec_fitem_sched_b_2013_2014; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_2013_2014 BEFORE INSERT ON fec_fitem_sched_b_2013_2014 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_2015_2016 tri_fec_fitem_sched_b_2015_2016; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_2015_2016 BEFORE INSERT ON fec_fitem_sched_b_2015_2016 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_b_2017_2018 tri_fec_fitem_sched_b_2017_2018; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_b_2017_2018 BEFORE INSERT ON fec_fitem_sched_b_2017_2018 FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_b_insert();


--
-- Name: fec_fitem_sched_e tri_fec_fitem_sched_e; Type: TRIGGER; Schema: disclosure; Owner: fec
--

CREATE TRIGGER tri_fec_fitem_sched_e BEFORE INSERT ON fec_fitem_sched_e FOR EACH ROW EXECUTE PROCEDURE fec_fitem_sched_e_insert();


SET search_path = public, pg_catalog;

--
-- Name: ofec_sched_a_master insert_sched_a_trigger_tmp; Type: TRIGGER; Schema: public; Owner: fec
--

CREATE TRIGGER insert_sched_a_trigger_tmp BEFORE INSERT ON ofec_sched_a_master FOR EACH ROW EXECUTE PROCEDURE insert_sched_master('1978');


--
-- Name: ofec_sched_b_master insert_sched_b_trigger_tmp; Type: TRIGGER; Schema: public; Owner: fec
--

CREATE TRIGGER insert_sched_b_trigger_tmp BEFORE INSERT ON ofec_sched_b_master FOR EACH ROW EXECUTE PROCEDURE insert_sched_master('1978');
