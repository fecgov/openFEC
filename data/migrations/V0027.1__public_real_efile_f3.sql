SET search_path = public, pg_catalog;

--
-- Name: real_efile_f3; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW real_efile_f3 AS
 SELECT f3.repid,
    f3.comid,
    f3.com_name,
    f3.str1,
    f3.str2,
    f3.city,
    f3.state,
    f3.zip,
    f3.amend_addr,
    f3.rptcode,
    f3.rptpgi,
    f3.els,
    f3.eld,
    f3.el_date,
    f3.el_state,
    f3.act_pri,
    f3.act_gen,
    f3.act_spe,
    f3.act_run,
    f3.from_date,
    f3.through_date,
    f3.lname,
    f3.fname,
    f3.mname,
    f3.prefix,
    f3.suffix,
    f3.sign_date,
    f3.cash_hand,
    f3.canid,
    f3.can_lname,
    f3.can_fname,
    f3.can_mname,
    f3.can_prefix,
    f3.can_suffix,
    f3.f3z1,
    f3.imageno,
    f3.create_dt
   FROM real_efile.f3;


ALTER TABLE real_efile_f3 OWNER TO fec;
