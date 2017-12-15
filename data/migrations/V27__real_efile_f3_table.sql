SET search_path = real_efile, pg_catalog;

--
-- Name: f3; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f3 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    amend_addr character varying(1),
    rptcode character varying(3),
    rptpgi character varying(5),
    els character varying(2),
    eld numeric,
    el_date date,
    el_state character varying(2),
    act_pri character varying(1),
    act_gen character varying(1),
    act_spe character varying(1),
    act_run character varying(1),
    from_date date,
    through_date date,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    cash_hand numeric,
    canid character varying(9),
    can_lname character varying(90),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    f3z1 character varying(3),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f3 OWNER TO fec;
