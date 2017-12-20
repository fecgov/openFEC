SET search_path = real_efile, pg_catalog;

--
-- Name: f3x; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f3x (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    amend_addr character varying(1),
    qual character varying(1),
    rptcode character varying(3),
    rptpgi character varying(5),
    el_date date,
    el_state character varying(2),
    from_date date,
    through_date date,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    date_signed date,
    sum_year character varying(4),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f3x OWNER TO fec;

--
-- Name: sa7; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE sa7 (
    repid numeric(12,0) NOT NULL,
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    tran_id character varying(32) NOT NULL,
    br_tran_id character varying(20),
    br_sname character varying(8),
    entity character varying(3),
    name character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    pgo character varying(5),
    pg_des character varying(30),
    date_con date,
    amount numeric(12,2),
    ytd numeric,
    reccode character varying(3),
    transdesc character varying(100),
    limit_ind character varying(1),
    indemp character varying(38),
    indocc character varying(38),
    other_comid character varying(9),
    donor_comname character varying(200),
    other_canid character varying(9),
    can_name character varying(38),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    other_name character varying(200),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    memo_code character varying(1),
    memo_text character varying(100),
    nc_softacct character varying(9),
    amend character varying(1),
    imageno numeric(19,0),
    used character(1),
    create_dt timestamp without time zone,
    contributor_name_text tsvector,
    contributor_employer_text tsvector,
    contributor_occupation_text tsvector
);


ALTER TABLE sa7 OWNER TO fec;

--
-- Name: sb4; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE sb4 (
    repid numeric(12,0) NOT NULL,
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    tran_id character varying(32) NOT NULL,
    br_tran_id character varying(20),
    br_sname character varying(8),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    pgo character varying(5),
    pg_des character varying(20),
    date_dis date,
    amount numeric(12,2),
    sa_ref_amt numeric(12,2),
    dis_code character varying(3),
    transdesc character varying(100),
    cat_code character varying(3),
    refund character varying(1),
    other_comid character varying(9),
    ben_comname character varying(200),
    other_canid character varying(9),
    can_name character varying(38),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    other_name character varying(200),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    memo_code character varying(1),
    memo_text character varying(100),
    nc_softacct character varying(9),
    amend character varying(1),
    imageno numeric(19,0),
    create_dt timestamp without time zone,
    used character(1)
);


ALTER TABLE sb4 OWNER TO fec;

--
-- Name: se; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE se (
    repid numeric(12,0) NOT NULL,
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    transdesc character varying(100),
    t_date date,
    amount numeric(12,2),
    so_canid character varying(9),
    so_can_name character varying(90),
    so_fname character varying(20),
    so_mname character varying(20),
    so_prefix character varying(10),
    so_suffix character varying(10),
    so_can_off character varying(1),
    so_can_state character varying(2),
    so_can_dist character varying(2),
    other_comid character varying(9),
    other_canid character varying(9),
    can_name character varying(90),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    other_name character varying(200),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    "position" character varying(3),
    pcf_lname character varying(90),
    pcf_fname character varying(20),
    pcf_mname character varying(20),
    pcf_prefix character varying(10),
    pcf_suffix character varying(10),
    sign_date date,
    not_date date,
    expire_date date,
    not_lname character varying(90),
    not_fname character varying(20),
    not_mname character varying(20),
    not_prefix character varying(10),
    not_suffix character varying(10),
    amend character varying(1),
    tran_id character varying(32),
    memo_code character varying(1),
    memo_text character varying(100),
    br_tran_id character varying(32),
    br_sname character varying(8),
    item_elect_cd character varying(5),
    item_elect_oth character varying(20),
    cat_code character varying(3),
    trans_code character varying(3),
    ytd numeric(12,2),
    imageno numeric(19,0),
    create_dt timestamp without time zone,
    dissem_dt date
);


ALTER TABLE se OWNER TO fec;

--
-- Name: f57; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f57 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    exp_desc character varying(100),
    exp_date date,
    amount numeric(12,2),
    supop character varying(3),
    other_canid character varying(9),
    other_comid character varying(9),
    so_canid character varying(9),
    so_can_name character varying(90),
    so_can_fname character varying(20),
    so_can_mname character varying(20),
    so_can_prefix character varying(10),
    so_can_suffix character varying(10),
    so_can_off character varying(1),
    so_can_state character varying(2),
    so_can_dist character varying(2),
    can_name character varying(90),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    other_name character varying(90),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    cat_code character varying(3),
    trans_code character varying(3),
    ytd numeric,
    item_elect_cd character varying(5),
    item_elect_oth character varying(20),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f57 OWNER TO fec;

--
-- Name: summary; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE summary (
    repid numeric(12,0) NOT NULL,
    lineno numeric(12,0) NOT NULL,
    cola numeric,
    colb numeric,
    create_dt timestamp without time zone
);


ALTER TABLE summary OWNER TO fec;
