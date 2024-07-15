/*
1) This migration file is for #5850
2) Original version
3) Create test_efile schema and test_f1 table
*/

CREATE SCHEMA IF NOT EXISTS test_efile
  AUTHORIZATION fec;

GRANT ALL ON SCHEMA test_efile TO fec;
GRANT ALL ON SCHEMA test_efile TO public;


SET search_path = test_efile, pg_catalog;

-- Name: test_f1; Type: TABLE; Schema: test_efile; Owner: fec
--

CREATE TABLE test_f1 (
    repid numeric NOT NULL,
    comid character varying(9),
    com_name character varying(200),
    com_str1 character varying(34),
    com_str2 character varying(34),
    com_city character varying(30),
    com_state character varying(2),
    com_zip character varying(9),
    sub_date date,
    amend_name character varying(1),
    amend_address character varying(1),
    cmte_type character varying(1),
    canid character varying(9),
    can_lname character varying(90),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    office character varying(1),
    el_state character varying(2),
    district character varying(2),
    party character varying(3),
    party_code character varying(3),
    lrpac5e character varying(1),
    lrpac5f character varying(1),
    lead_pac character varying(1),
    aff_comid character varying(9),
    aff_canid character varying(9),
    ac_name character varying(200),
    aff_fname character varying(20),
    aff_mname character varying(20),
    aff_prefix character varying(10),
    aff_suffix character varying(10),
    acstr1 character varying(34),
    acstr2 character varying(34),
    accity character varying(30),
    acstate character varying(2),
    aczip character varying(9),
    relations character varying(38),
    organ_type character varying(1),
    affrel_code character varying(3),
    c_lname character varying(90),
    c_fname character varying(20),
    c_mname character varying(20),
    c_prefix character varying(10),
    c_suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    title character varying(20),
    phone character varying(10),
    t_lname character varying(90),
    t_fname character varying(20),
    t_mname character varying(20),
    t_prefix character varying(10),
    t_suffix character varying(10),
    tstr1 character varying(34),
    tstr2 character varying(34),
    tcity character varying(30),
    tstate character varying(2),
    tzip character varying(9),
    ttitle character varying(20),
    tphone character varying(10),
    d_lname character varying(90),
    d_fname character varying(20),
    d_mname character varying(20),
    d_prefix character varying(10),
    d_suffix character varying(10),
    dstr1 character varying(34),
    dstr2 character varying(34),
    dcity character varying(30),
    dstate character varying(2),
    dzip character varying(9),
    dtitle character varying(20),
    dphone character varying(10),
    b_lname character varying(200),
    bstr1 character varying(34),
    bstr2 character varying(34),
    bcity character varying(30),
    bstate character varying(2),
    bzip character varying(9),
    bname_2 character varying(200),
    bstr1_2 character varying(34),
    bstr2_2 character varying(34),
    bcity_2 character varying(30),
    bstate_2 character varying(2),
    bzip_2 character varying(9),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    amend_email character varying(1),
    email character varying(90),
    amend_url character varying(1),
    url character varying(90),
    fax character varying(12),
    imageno numeric,
    create_dt timestamp without time zone
);


ALTER TABLE test_f1 OWNER TO fec;
GRANT SELECT ON TABLE test_f1 TO fec_read;
GRANT UPDATE, SELECT, DELETE, INSERT ON TABLE test_f1 TO real_file;

ALTER TABLE ONLY test_f1
    ADD CONSTRAINT real_efile_test_f1_pkey PRIMARY KEY (repid);
