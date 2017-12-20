SET search_path = real_pfile, pg_catalog;

--
-- Name: f1; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f1 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    chg_name character varying(1),
    name character varying(200),
    chg_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    amend_email character varying(1),
    email character varying(90),
    amend_url character varying(1),
    url character varying(90),
    fax character varying(12),
    sub_date date,
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    com_type character varying(1),
    can_last character varying(30),
    can_first character varying(20),
    can_middle character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_office character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    can_pcode character varying(3),
    can_ptype character varying(3),
    lead_pac character varying(1),
    lrpac5e character varying(1),
    lrpac5f character varying(1),
    aff_name character varying(200),
    aff_fname character varying(20),
    aff_mname character varying(20),
    aff_prefix character varying(10),
    aff_suffix character varying(10),
    aff_str1 character varying(34),
    aff_str2 character varying(34),
    aff_city character varying(30),
    aff_state character varying(2),
    aff_zip character varying(9),
    aff_relat character varying(38),
    aff_orgtyp character varying(1),
    affrel_code character varying(3),
    cus_last character varying(30),
    cus_first character varying(20),
    cus_middle character varying(20),
    cus_prefix character varying(10),
    cus_suffix character varying(10),
    cus_str1 character varying(34),
    cus_str2 character varying(34),
    cus_city character varying(30),
    cus_state character varying(2),
    cus_zip character varying(9),
    cus_title character varying(20),
    cus_phone character varying(10),
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_str1 character varying(34),
    tre_str2 character varying(34),
    tre_city character varying(30),
    tre_state character varying(2),
    tre_zip character varying(9),
    tre_title character varying(20),
    tre_phone character varying(10),
    des_last character varying(30),
    des_first character varying(20),
    des_middle character varying(20),
    des_prefix character varying(10),
    des_suffix character varying(10),
    des_str1 character varying(34),
    des_str2 character varying(34),
    des_city character varying(30),
    des_state character varying(2),
    des_zip character varying(9),
    des_title character varying(20),
    des_phone character varying(10),
    bnk_name character varying(200),
    bnk_str1 character varying(34),
    bnk_str2 character varying(34),
    bnk_city character varying(30),
    bnk_state character varying(2),
    bnk_zip character varying(9),
    bname_2 character varying(200),
    bstr1_2 character varying(34),
    bstr2_2 character varying(34),
    bcity_2 character varying(30),
    bstate_2 character varying(2),
    bzip_2 character varying(9),
    imgno character varying(18),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


ALTER TABLE f1 OWNER TO fec;

--
-- Name: f10; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f10 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    office character varying(1),
    state character varying(2),
    dist character varying(2),
    canid character varying(9),
    com_name character varying(90),
    com_str1 character varying(34),
    com_str2 character varying(34),
    com_city character varying(18),
    com_state character varying(2),
    com_zip character varying(9),
    previous numeric,
    total numeric,
    ctd numeric,
    f6 character varying(1),
    emp character varying(38),
    occ character varying(38),
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f10 OWNER TO fec;

--
-- Name: f105; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f105 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    receipt_date date,
    elc_code character varying(5),
    elc_other character varying(20),
    amount numeric(12,2),
    loan character varying(1),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f105 OWNER TO fec;

--
-- Name: f11; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f11 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    canid character varying(9),
    off character varying(1),
    st character varying(2),
    dist character varying(2),
    name character varying(90),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(18),
    state character varying(2),
    zip character varying(9),
    not_last character varying(30),
    not_first character varying(20),
    not_middle character varying(20),
    not_prefix character varying(10),
    not_suffix character varying(10),
    not_name character varying(90),
    com_comid character varying(9),
    com_str1 character varying(34),
    com_str2 character varying(34),
    com_city character varying(18),
    com_state character varying(2),
    com_zip character varying(9),
    f10_date date,
    amount numeric(12,2),
    elc_code character varying(5),
    elc_other character varying(20),
    type character varying(1),
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    sign_date date,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f11 OWNER TO fec;

--
-- Name: f12; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f12 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    canid character varying(9),
    off character varying(1),
    st character varying(2),
    dist character varying(2),
    name character varying(90),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(18),
    state character varying(2),
    zip character varying(9),
    elc_code character varying(5),
    elc_other character varying(20),
    elc_type character varying(1),
    pcc_date date,
    pcc_amount numeric(12,2),
    pcc_f11date date,
    auth_date date,
    auth_amount numeric(12,2),
    auth_f11date date,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    sign_date date,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f12 OWNER TO fec;

--
-- Name: f13; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f13 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    name character varying(200),
    chg_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    rpt_code character varying(3),
    date_amend date,
    date_from date,
    date_through date,
    accepted numeric,
    refund numeric,
    net numeric,
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imgno character varying(18),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


ALTER TABLE f13 OWNER TO fec;

--
-- Name: f132; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f132 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    receipt_date date,
    received numeric,
    aggregate numeric,
    memo_desc character varying(100),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone,
    memo_code character varying(1)
);


ALTER TABLE f132 OWNER TO fec;

--
-- Name: f133; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f133 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    exp_date date,
    expended numeric,
    memo_desc character varying(100),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f133 OWNER TO fec;

--
-- Name: f1m; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f1m (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    type character varying(1),
    aff_date date,
    aff_name character varying(200),
    aff_comid character varying(9),
    cn1_last character varying(30),
    cn1_first character varying(20),
    cn1_middle character varying(20),
    cn1_prefix character varying(10),
    cn1_suffix character varying(10),
    cn1_office character varying(1),
    cn1_state character varying(2),
    cn1_dist character varying(2),
    cn1_cont date,
    cn2_last character varying(30),
    cn2_first character varying(20),
    cn2_middle character varying(20),
    cn2_prefix character varying(10),
    cn2_suffix character varying(10),
    cn2_office character varying(1),
    cn2_state character varying(2),
    cn2_dist character varying(2),
    cn2_cont date,
    cn3_last character varying(30),
    cn3_first character varying(20),
    cn3_middle character varying(20),
    cn3_prefix character varying(10),
    cn3_suffix character varying(10),
    cn3_office character varying(1),
    cn3_state character varying(2),
    cn3_dist character varying(2),
    cn3_cont date,
    cn4_last character varying(30),
    cn4_first character varying(20),
    cn4_middle character varying(20),
    cn4_prefix character varying(10),
    cn4_suffix character varying(10),
    cn4_office character varying(1),
    cn4_state character varying(2),
    cn4_dist character varying(2),
    cn4_cont date,
    cn5_last character varying(30),
    cn5_first character varying(20),
    cn5_middle character varying(20),
    cn5_prefix character varying(10),
    cn5_suffix character varying(10),
    cn5_office character varying(1),
    cn5_state character varying(2),
    cn5_dist character varying(2),
    cn5_cont date,
    date_51 date,
    date_org date,
    date_com date,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    imgno character varying(18),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


ALTER TABLE f1m OWNER TO fec;

--
-- Name: f1s; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f1s (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    jfrcomname character varying(200),
    jfrcomid character varying(9),
    aff_name character varying(200),
    aff_fname character varying(20),
    aff_mname character varying(20),
    aff_prefix character varying(10),
    aff_suffix character varying(10),
    aff_str1 character varying(34),
    aff_str2 character varying(34),
    aff_city character varying(30),
    aff_state character varying(2),
    aff_zip character varying(9),
    aff_relat character varying(38),
    aff_orgtyp character varying(1),
    affrel_code character varying(3),
    des_last character varying(30),
    des_first character varying(20),
    des_middle character varying(20),
    des_prefix character varying(10),
    des_suffix character varying(10),
    des_str1 character varying(34),
    des_str2 character varying(34),
    des_city character varying(30),
    des_state character varying(2),
    des_zip character varying(9),
    des_title character varying(20),
    des_phone character varying(10),
    bnk_name character varying(200),
    bnk_str1 character varying(34),
    bnk_str2 character varying(34),
    bnk_city character varying(30),
    bnk_state character varying(2),
    bnk_zip character varying(9),
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f1s OWNER TO fec;

--
-- Name: f2; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f2 (
    repid numeric(12,0) NOT NULL,
    canid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    chg_addr character varying(1),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    party character varying(3),
    office character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    pcc_year character varying(4),
    pcc_name character varying(200),
    pcc_str1 character varying(34),
    pcc_str2 character varying(34),
    pcc_city character varying(30),
    pcc_state character varying(2),
    pcc_zip character varying(9),
    aut_name character varying(200),
    aut_str1 character varying(34),
    aut_str2 character varying(34),
    aut_city character varying(30),
    aut_state character varying(2),
    aut_zip character varying(9),
    pri_fund numeric,
    gen_fund numeric,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    imgno character varying(18),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date,
    vp_last_name character(30),
    vp_first_name character(20),
    vp_middle_name character(20),
    vp_prefix character(10),
    vp_suffix character(10)
);


ALTER TABLE f2 OWNER TO fec;

--
-- Name: f24; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f24 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    name character varying(200),
    rpttyp character varying(2),
    orgamd_date date,
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    f24_date date,
    imgno character varying(18),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


ALTER TABLE f24 OWNER TO fec;

--
-- Name: f3; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f3 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    name character varying(200),
    chg_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    elc_state character varying(2),
    elc_dist character varying(2),
    rpt_code character varying(3),
    date_elc date,
    state_elc character varying(2),
    date_from date,
    date_through date,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    cash_open numeric,
    ttl_rcpt numeric,
    sub_ttl numeric,
    ttl_disb numeric,
    cash_close numeric,
    can_last character varying(30),
    can_first character varying(20),
    can_middle character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    canid character varying(9),
    f3z1 character varying(3),
    imgno character varying(18),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


ALTER TABLE f3 OWNER TO fec;

--
-- Name: f3l; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f3l (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    com_name character varying(200),
    amend_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    els character varying(2),
    eld numeric,
    rptcode character varying(3),
    el_date date,
    el_state character varying(2),
    semiperiod character varying(1),
    from_date date,
    through_date date,
    semijun character varying(1),
    semidec character varying(1),
    bundledcont numeric,
    semibuncont numeric,
    lname character varying(38),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imageno numeric(19,0),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


ALTER TABLE f3l OWNER TO fec;

--
-- Name: f3p; Type: TABLE; Schema: real_pfile; Owner: fec
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
    lname character varying(38),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imgno character varying(18),
    end_imgno character varying(18),
    receipt_dt date,
    create_date date
);


ALTER TABLE f3p OWNER TO fec;

--
-- Name: f3ps; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f3ps (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    ge_date date,
    dayafterge_dt date,
    imgno character varying(18)
);


ALTER TABLE f3ps OWNER TO fec;

--
-- Name: f3pz1; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f3pz1 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    pcc_comid character varying(9),
    pcc_com_name character varying(200),
    cvg_start_date date,
    cvg_end_date date,
    auth_comid character varying(9),
    auth_com_name character varying(200),
    coh_bop numeric,
    coh_cop numeric,
    debts_owed_to_cmte numeric,
    debts_owed_by_committee numeric,
    exp_subject_to_limit numeric,
    net_contb numeric,
    net_op_exp numeric,
    federal_funds numeric,
    indv_contb numeric,
    pol_pty_contb numeric,
    other_pol_pty_contb numeric,
    cand_contb numeric,
    ttl_contb numeric,
    tranf_from_other_auth_cmte numeric,
    loans_made_by_cand numeric,
    all_other_loans numeric,
    ttl_loans numeric,
    offsets_to_op_exp numeric,
    offsets_to_fundraising_exp numeric,
    offsets_to_legal_acc_exp numeric,
    ttl_offsets_to_exp numeric,
    other_receipts numeric,
    ttl_receipts numeric,
    op_exp numeric,
    tranf_to_other_auth_cmte numeric,
    fundraising_disb numeric,
    exempt_legal_acc_disb numeric,
    repymts_loans_made_cand numeric,
    other_loan_repymts numeric,
    ttl_loan_repymts numeric,
    ref_indv_contb numeric,
    ref_pol_pty_cmte_contb numeric,
    ref_other_pol_cmte_contb numeric,
    total_contb_refunds numeric,
    other_disb numeric,
    total_disb numeric,
    items_to_be_liquidated numeric,
    imageno numeric,
    create_dt timestamp without time zone
);


ALTER TABLE f3pz1 OWNER TO fec;

--
-- Name: f3pz2; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f3pz2 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    pcc_comid character varying(9),
    pcc_com_name character varying(200),
    cvg_start_date date,
    cvg_end_date date,
    coh_bop numeric,
    coh_cop numeric,
    debts_owed_to_cmte numeric,
    debts_owed_by_committee numeric,
    exp_subject_to_limit numeric,
    net_contb numeric,
    net_op_exp numeric,
    federal_funds numeric,
    indv_contb numeric,
    pol_pty_contb numeric,
    other_pol_pty_contb numeric,
    cand_contb numeric,
    ttl_contb numeric,
    tranf_from_other_auth_cmte numeric,
    loans_made_by_cand numeric,
    all_other_loans numeric,
    ttl_loans numeric,
    offsets_to_op_exp numeric,
    offsets_to_fundraising_exp numeric,
    offsets_to_legal_acc_exp numeric,
    ttl_offsets_to_exp numeric,
    other_receipts numeric,
    ttl_receipts numeric,
    op_exp numeric,
    tranf_to_other_auth_cmte numeric,
    fundraising_disb numeric,
    exempt_legal_acc_disb numeric,
    repymts_loans_made_cand numeric,
    other_loan_repymts numeric,
    ttl_loan_repymts numeric,
    ref_indv_contb numeric,
    ref_pol_pty_cmte_contb numeric,
    ref_other_pol_cmte_contb numeric,
    total_contb_refunds numeric,
    other_disb numeric,
    total_disb numeric,
    items_to_be_liquidated numeric,
    imageno numeric,
    create_dt timestamp without time zone
);


ALTER TABLE f3pz2 OWNER TO fec;

--
-- Name: f3s; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f3s (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    date_ge date,
    date_age date,
    imgno character varying(19),
    create_date timestamp without time zone
);


ALTER TABLE f3s OWNER TO fec;

--
-- Name: f3x; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f3x (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    name character varying(200),
    chg_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    rpt_code character varying(3),
    date_elc date,
    state_elc character varying(2),
    date_from date,
    date_through date,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    qual character varying(1),
    coh_year character varying(4),
    imgno character varying(18),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


ALTER TABLE f3x OWNER TO fec;

--
-- Name: f3z; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f3z (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    totals character varying(1),
    comid character varying(9),
    name character varying(200),
    date_from date,
    date_through date,
    auth character varying(200),
    a numeric,
    b numeric,
    c numeric,
    d numeric,
    e numeric,
    f numeric,
    g numeric,
    h numeric,
    i numeric,
    j numeric,
    k numeric,
    l numeric,
    m numeric,
    n numeric,
    o numeric,
    p numeric,
    q numeric,
    r numeric,
    s numeric,
    t numeric,
    u numeric,
    v numeric,
    w numeric,
    x numeric,
    y numeric,
    z numeric,
    aa numeric,
    bb numeric,
    cc numeric,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f3z OWNER TO fec;

--
-- Name: f3z1; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f3z1 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    pcc_comid character varying(9),
    pcc_com_name character varying(200),
    cvg_start_date date,
    cvg_end_date date,
    auth_comid character varying(9),
    auth_com_name character varying(200),
    net_contb numeric,
    net_op_exp numeric,
    debts_owed_to_cmte numeric,
    debts_owed_by_committee numeric,
    indv_contb numeric,
    pol_pty_contb numeric,
    other_pol_pty_contb numeric,
    cand_contb numeric,
    ttl_contb numeric,
    tranf_from_other_auth_cmte numeric,
    loans_made_by_cand numeric,
    all_other_loans numeric,
    ttl_loans numeric,
    offsets_to_op_exp numeric,
    other_receipts numeric,
    ttl_receipts numeric,
    op_exp numeric,
    tranf_to_other_auth_cmte numeric,
    repymts_loans_made_cand numeric,
    other_loan_repymts numeric,
    ttl_loan_repymts numeric,
    ref_indv_contb numeric,
    ref_pol_pty_cmte_contb numeric,
    ref_other_pol_cmte_contb numeric,
    total_contb_refunds numeric,
    other_disb numeric,
    total_disb numeric,
    coh_bop numeric,
    coh_cop numeric,
    imageno numeric,
    create_dt timestamp without time zone
);


ALTER TABLE f3z1 OWNER TO fec;

--
-- Name: f3z2; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f3z2 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    pcc_comid character varying(9),
    pcc_com_name character varying(200),
    cvg_start_date date,
    cvg_end_date date,
    net_contb numeric,
    net_op_exp numeric,
    debts_owed_to_cmte numeric,
    debts_owed_by_committee numeric,
    indv_contb numeric,
    pol_pty_contb numeric,
    other_pol_pty_contb numeric,
    cand_contb numeric,
    ttl_contb numeric,
    tranf_from_other_auth_cmte numeric,
    loans_made_by_cand numeric,
    all_other_loans numeric,
    ttl_loans numeric,
    offsets_to_op_exp numeric,
    other_receipts numeric,
    ttl_receipts numeric,
    op_exp numeric,
    tranf_to_other_auth_cmte numeric,
    repymts_loans_made_cand numeric,
    other_loan_repymts numeric,
    ttl_loan_repymts numeric,
    ref_indv_contb numeric,
    ref_pol_pty_cmte_contb numeric,
    ref_other_pol_cmte_contb numeric,
    total_contb_refunds numeric,
    other_disb numeric,
    total_disb numeric,
    coh_bop numeric,
    coh_cop numeric,
    imageno numeric,
    create_dt timestamp without time zone
);


ALTER TABLE f3z2 OWNER TO fec;

--
-- Name: f4; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f4 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    type character varying(1),
    description character varying(40),
    rpt_code character varying(3),
    date_from date,
    date_through date,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    coh_year character varying(4),
    imgno character varying(18),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


ALTER TABLE f4 OWNER TO fec;

--
-- Name: f5; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f5 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    chg_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(10),
    qual character varying(1),
    ind_emp character varying(38),
    ind_occ character varying(38),
    rpt_code character varying(3),
    hr_code character varying(2),
    pgi_code character varying(1),
    date_elc date,
    state_elc character varying(2),
    orig_amend_date date,
    date_from date,
    date_through date,
    ttl_cont numeric,
    ttl_expd numeric,
    ind_last character varying(30),
    ind_first character varying(20),
    ind_middle character varying(20),
    ind_prefix character varying(10),
    ind_suffix character varying(10),
    ind_date date,
    imgno character varying(18),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


ALTER TABLE f5 OWNER TO fec;

--
-- Name: f56; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f56 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    fec_comid character varying(9),
    date_recv date,
    amount numeric(12,2),
    ind_emp character varying(38),
    ind_occ character varying(38),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f56 OWNER TO fec;

--
-- Name: f57; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f57 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    date_exp date,
    amount numeric(12,2),
    purp_exp character varying(40),
    cat_code character varying(3),
    so_last character varying(30),
    so_first character varying(20),
    so_middle character varying(20),
    so_prefix character varying(10),
    so_suffix character varying(10),
    so_office character varying(1),
    so_state character varying(2),
    so_dist character varying(2),
    sup_opp character varying(3),
    cal_ytd numeric,
    elc_code character varying(5),
    elc_other character varying(20),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f57 OWNER TO fec;

--
-- Name: f6; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f6 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    orgamd_date date,
    name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    can_office character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    sign_date date,
    imgno character varying(18),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


ALTER TABLE f6 OWNER TO fec;

--
-- Name: f65; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f65 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    ind_emp character varying(38),
    ind_occ character varying(38),
    date_cont date,
    amount numeric(12,2),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f65 OWNER TO fec;

--
-- Name: f7; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f7 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    org_type character varying(1),
    rpt_code character varying(3),
    date_elc date,
    state_elc character varying(2),
    date_from date,
    date_through date,
    ttl_cost numeric,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_title character varying(20),
    tre_date date,
    imgno character varying(18),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


ALTER TABLE f7 OWNER TO fec;

--
-- Name: f76; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f76 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    exp_type character varying(2),
    description character varying(40),
    class character varying(1),
    exp_date date,
    sup_opp character varying(3),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    office character varying(1),
    state character varying(2),
    dist character varying(2),
    pgi character varying(5),
    cost numeric,
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f76 OWNER TO fec;

--
-- Name: f8; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f8 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    name character varying(90),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(18),
    state character varying(2),
    zip character varying(9),
    l1 numeric,
    l1a date,
    l2 numeric,
    l3 numeric,
    l4 numeric,
    l5 numeric,
    l6 numeric,
    l7 numeric,
    l8 numeric,
    l9 numeric,
    l10 numeric,
    l11 character varying(1),
    l11d date,
    l12 character varying(1),
    l12d character varying(300),
    l13 character varying(1),
    l13d character varying(100),
    l14 character varying(1),
    l15 character varying(1),
    l15d character varying(100),
    suff character varying(1),
    suff_des character varying(100),
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f8 OWNER TO fec;

--
-- Name: f8ii; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f8ii (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(90),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(18),
    state character varying(2),
    zip character varying(9),
    date_inc date,
    amt_owed numeric(12,2),
    amt_offrd numeric(12,2),
    cred_code character varying(3),
    a_desc character varying(100),
    b_desc character varying(100),
    c_desc character varying(100),
    d_yn character varying(1),
    d_desc character varying(100),
    e_yn character varying(1),
    e_desc character varying(100),
    cred_last character varying(30),
    cred_first character varying(20),
    cred_middle character varying(20),
    cred_prefix character varying(10),
    cred_suffix character varying(10),
    cred_date date,
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f8ii OWNER TO fec;

--
-- Name: f8iii; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f8iii (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(90),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    cred_code character varying(3),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(18),
    state character varying(2),
    zip character varying(9),
    yes_no character varying(1),
    amt_owed numeric(12,2),
    amt_pay numeric(12,2),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f8iii OWNER TO fec;

--
-- Name: f9; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f9 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    chg_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    empl character varying(38),
    occup character varying(38),
    date_from date,
    date_through date,
    date_public date,
    title character varying(40),
    qual character varying(1),
    filer_code character varying(3),
    filercd_desc character varying(20),
    bnk_acc character varying(1),
    cus_last character varying(30),
    cus_first character varying(20),
    cus_middle character varying(20),
    cus_prefix character varying(10),
    cus_suffix character varying(10),
    cus_str1 character varying(34),
    cus_str2 character varying(34),
    cus_city character varying(30),
    cus_state character varying(2),
    cus_zip character varying(9),
    cus_emp character varying(38),
    cus_occ character varying(38),
    ttl_dona numeric,
    ttl_disb numeric,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    imgno character varying(18),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


ALTER TABLE f9 OWNER TO fec;

--
-- Name: f91; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f91 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    empl character varying(38),
    occup character varying(38),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f91 OWNER TO fec;

--
-- Name: f92; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f92 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    date_recv date,
    amount numeric(12,2),
    memo_desc character varying(100),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f92 OWNER TO fec;

--
-- Name: f93; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f93 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    date_disb date,
    amount numeric(12,2),
    date_comm date,
    purp_disb character varying(40),
    memo_desc character varying(100),
    sch_id character varying(1),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f93 OWNER TO fec;

--
-- Name: f94; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE f94 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    office character varying(1),
    state character varying(2),
    dist character varying(2),
    elc_code character varying(5),
    elc_other character varying(20),
    back_ref character varying(20),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE f94 OWNER TO fec;

--
-- Name: h1; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE h1 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    pres character varying(1),
    pres_sen character varying(1),
    sen character varying(1),
    non_pres_sen character varying(1),
    minimum character varying(1),
    federal numeric,
    non_federal numeric,
    administrative character varying(1),
    generic character varying(1),
    public_comm character varying(1),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE h1 OWNER TO fec;

--
-- Name: h2; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE h2 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(90),
    fundraising character varying(1),
    direct character varying(1),
    ratio character varying(1),
    federal numeric,
    non_federal numeric,
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE h2 OWNER TO fec;

--
-- Name: h3; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE h3 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(90),
    receipt_date date,
    ttl_amount numeric(12,2),
    event_type character varying(2),
    amount numeric(12,2),
    event character varying(90),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE h3 OWNER TO fec;

--
-- Name: h4; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE h4 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    purpose character varying(40),
    identifier character varying(100),
    cat_code character varying(3),
    administrative character varying(1),
    fundraising character varying(1),
    exempt character varying(1),
    generic character varying(1),
    support character varying(1),
    public_comm character varying(1),
    ytd numeric,
    exp_date date,
    federal numeric,
    non_federal numeric,
    amount numeric(12,2),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone,
    memo_code character varying(1),
    memo_desc character varying(100)
);


ALTER TABLE h4 OWNER TO fec;

--
-- Name: h5; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE h5 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(90),
    receipt_date date,
    amount numeric(12,2),
    registration numeric,
    id numeric,
    gotv numeric,
    generic numeric,
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE h5 OWNER TO fec;

--
-- Name: h6; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE h6 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    purpose character varying(40),
    cat_code character varying(3),
    registration character varying(1),
    gotv character varying(1),
    id character varying(1),
    generic character varying(1),
    ytd numeric,
    exp_date date,
    federal numeric,
    levin numeric,
    amount numeric(12,2),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone,
    memo_code character varying(1),
    memo_desc character varying(100)
);


ALTER TABLE h6 OWNER TO fec;

--
-- Name: reps; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE reps (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    form character varying(4),
    name character varying(200),
    md5 character varying(32),
    date_filed date,
    "timestamp" date,
    date_from date,
    date_through date,
    rptcode character varying(4),
    version character varying(7),
    batch numeric,
    received date,
    starting numeric,
    receipt_dt date,
    create_date timestamp without time zone
);


ALTER TABLE reps OWNER TO fec;

--
-- Name: sa; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE sa (
    repid numeric(12,0) NOT NULL,
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    receipt_date date,
    fec_com character varying(9),
    ind_emp character varying(38),
    ind_occ character varying(38),
    elc_code character varying(5),
    elc_other character varying(20),
    ytd numeric,
    amount numeric(12,2),
    memo_desc character varying(100),
    limit_ind character varying(1),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone,
    memo_code character varying(1)
);


ALTER TABLE sa OWNER TO fec;

--
-- Name: sb; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE sb (
    repid numeric(12,0) NOT NULL,
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    disb_date date,
    purp_disb character varying(40),
    ben_comname character varying(200),
    can_last character varying(30),
    can_first character varying(20),
    can_middle character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    cat_code character varying(3),
    can_office character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    elc_code character varying(5),
    elc_other character varying(20),
    amount numeric(12,2),
    sa_ref_amt numeric(12,2),
    memo_desc character varying(100),
    refund character varying(1),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone,
    memo_code character varying(1)
);


ALTER TABLE sb OWNER TO fec;

--
-- Name: sc; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE sc (
    repid numeric(12,0) NOT NULL,
    line_num character varying(8),
    rel_lineno numeric(12,0),
    rcpt_lineno character varying(8),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    election character varying(5),
    elc_desc character varying(20),
    amount numeric(12,2),
    ptd numeric,
    balance numeric,
    date_inc date,
    date_due character varying(15),
    pct_rate character varying(15),
    secured character varying(1),
    pers_funds character varying(1),
    memo_desc character varying(100),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone,
    memo_code character varying(1)
);


ALTER TABLE sc OWNER TO fec;

--
-- Name: sc1; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE sc1 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    amount numeric(12,2),
    pct_rate character varying(15),
    date_inc date,
    date_due character varying(15),
    restruct character varying(1),
    date_orig date,
    credit numeric,
    balance numeric,
    liable character varying(1),
    collateral character varying(1),
    coll_desc character varying(100),
    coll_amt numeric(12,2),
    perfected character varying(1),
    future character varying(1),
    futr_desc character varying(100),
    estimated numeric,
    date_est date,
    acc_name character varying(200),
    acc_str1 character varying(34),
    acc_str2 character varying(34),
    acc_city character varying(30),
    acc_state character varying(2),
    acc_zip character varying(9),
    acc_desc character varying(100),
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    ath_last character varying(30),
    ath_first character varying(20),
    ath_middle character varying(20),
    ath_prefix character varying(10),
    ath_suffix character varying(10),
    ath_title character varying(20),
    ath_date date,
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone,
    dep_acc_ath_date date
);


ALTER TABLE sc1 OWNER TO fec;

--
-- Name: sc2; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE sc2 (
    repid numeric(12,0) NOT NULL,
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    ind_emp character varying(38),
    ind_occ character varying(38),
    amount numeric(12,2),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE sc2 OWNER TO fec;

--
-- Name: sd; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE sd (
    repid numeric(12,0) NOT NULL,
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    nature character varying(40),
    beginning numeric,
    incurred numeric,
    payment numeric,
    closing numeric,
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE sd OWNER TO fec;

--
-- Name: se; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE se (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    exp_date date,
    amount numeric(12,2),
    disse_date date,
    purpose character varying(40),
    cat_code character varying(3),
    so_last character varying(30),
    so_first character varying(20),
    so_middle character varying(20),
    so_prefix character varying(10),
    so_suffix character varying(10),
    so_office character varying(1),
    so_state character varying(2),
    so_dist character varying(2),
    sup_opp character varying(3),
    cal_ytd numeric,
    elc_code character varying(5),
    elc_other character varying(20),
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone,
    memo_code character varying(1),
    memo_desc character varying(100)
);


ALTER TABLE se OWNER TO fec;

--
-- Name: sf; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE sf (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    hr_notice character varying(1),
    designated character varying(1),
    name_des character varying(200),
    name_sub character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    pay_name character varying(200),
    pay_last character varying(30),
    pay_first character varying(20),
    pay_middle character varying(20),
    pay_prefix character varying(10),
    pay_suffix character varying(10),
    pay_str1 character varying(34),
    pay_str2 character varying(34),
    pay_city character varying(30),
    pay_state character varying(2),
    pay_zip character varying(9),
    purpose character varying(40),
    cat_code character varying(3),
    exp_date date,
    can_last character varying(30),
    can_first character varying(20),
    can_middle character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_office character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    aggregate numeric,
    amount numeric(12,2),
    unlimited character varying(1),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone,
    memo_code character varying(1),
    memo_desc character varying(100)
);


ALTER TABLE sf OWNER TO fec;

--
-- Name: sl; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE sl (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(90),
    tran_id character varying(32) NOT NULL,
    imgno character varying(18),
    create_date timestamp without time zone
);


ALTER TABLE sl OWNER TO fec;

--
-- Name: summary; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE summary (
    repid numeric(12,0) NOT NULL,
    lineno numeric(12,0) NOT NULL,
    cola numeric,
    colb numeric,
    create_date timestamp without time zone
);


ALTER TABLE summary OWNER TO fec;

--
-- Name: summary_sup; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE summary_sup (
    repid numeric(12,0) NOT NULL,
    lineno numeric(12,0) NOT NULL,
    colc numeric,
    create_date timestamp without time zone
);


ALTER TABLE summary_sup OWNER TO fec;

--
-- Name: supsum; Type: TABLE; Schema: real_pfile; Owner: fec
--

CREATE TABLE supsum (
    repid numeric(12,0) NOT NULL,
    lineno numeric(12,0) NOT NULL,
    colbs numeric
);


ALTER TABLE supsum OWNER TO fec;
