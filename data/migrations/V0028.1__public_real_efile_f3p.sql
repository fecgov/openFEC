SET search_path = public, pg_catalog;

--
-- Name: real_efile_f3p; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW real_efile_f3p AS
 SELECT f3p.repid,
    f3p.comid,
    f3p.c_name,
    f3p.c_str1,
    f3p.c_str2,
    f3p.c_city,
    f3p.c_state,
    f3p.c_zip,
    f3p.amend_addr,
    f3p.rptcode,
    f3p.rptpgi,
    f3p.el_date,
    f3p.el_state,
    f3p.act_pri,
    f3p.act_gen,
    f3p.from_date,
    f3p.through_date,
    f3p.cash,
    f3p.tot_rec,
    f3p.sub,
    f3p.tot_dis,
    f3p.cash_close,
    f3p.debts_to,
    f3p.debts_by,
    f3p.expe,
    f3p.net_con,
    f3p.net_op,
    f3p.lname,
    f3p.fname,
    f3p.mname,
    f3p.prefix,
    f3p.suffix,
    f3p.sign_date,
    f3p.imageno,
    f3p.create_dt
   FROM real_efile.f3p;


ALTER TABLE real_efile_f3p OWNER TO fec;
