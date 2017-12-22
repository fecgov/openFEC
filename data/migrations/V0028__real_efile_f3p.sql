SET search_path = real_efile, pg_catalog;

--
-- Name: f3p; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f3p (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    c_name character varying(200),
    c_str1 character varying(34),
    c_str2 character varying(34),
    c_city character varying(30),
    c_state character varying(2),
    c_zip character varying(9),
    amend_addr character varying(1),
    rptcode character varying(3),
    rptpgi character varying(5),
    el_date date,
    el_state character varying(2),
    act_pri character varying(1),
    act_gen character varying(1),
    from_date date,
    through_date date,
    cash numeric,
    tot_rec numeric,
    sub numeric,
    tot_dis numeric,
    cash_close numeric,
    debts_to numeric,
    debts_by numeric,
    expe numeric,
    net_con numeric,
    net_op numeric,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f3p OWNER TO fec;
