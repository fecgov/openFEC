SET search_path = real_efile, pg_catalog;

-- Name: f1; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f1 (
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


ALTER TABLE f1 OWNER TO fec;

--
-- Name: f10; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f10 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    canid character varying(9),
    off character varying(1),
    state character varying(2),
    dist character varying(2),
    com_name character varying(200),
    com_str1 character varying(34),
    com_str2 character varying(34),
    com_city character varying(30),
    com_state character varying(2),
    com_zip character varying(9),
    previous numeric,
    total numeric,
    ctd numeric,
    s_lname character varying(90),
    s_fname character varying(20),
    s_mname character varying(20),
    s_prefix character varying(10),
    s_suffix character varying(10),
    sign_date date,
    f6 character varying(1),
    can_emp character varying(90),
    can_occ character varying(90),
    imageno character varying(22),
    create_dt timestamp without time zone
);


ALTER TABLE f10 OWNER TO fec;

--
-- Name: f105; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f105 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    exp_date date,
    item_elect_cd character varying(5),
    item_elect_oth character varying(20),
    amount numeric(12,2),
    loan character varying(1),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    imageno character varying(22),
    create_dt timestamp without time zone
);


ALTER TABLE f105 OWNER TO fec;

--
-- Name: f13; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f13 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    chgadd character varying(1),
    rptcode character varying(3),
    amend_date date,
    frm_date date,
    thr_date date,
    accepted numeric,
    refund numeric,
    net numeric,
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    f13_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f13 OWNER TO fec;

--
-- Name: f132; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f132 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    org character varying(200),
    last_nm character varying(30),
    first_nm character varying(20),
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
    memo_code character varying(1),
    memo_text character varying(100),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    br_tran_id character varying(32),
    br_sname character varying(8),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f132 OWNER TO fec;

--
-- Name: f133; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f133 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    org character varying(200),
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
    ref_date date,
    expended numeric,
    memo_code character varying(1),
    memo_text character varying(100),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    br_tran_id character varying(32),
    br_sname character varying(8),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f133 OWNER TO fec;

--
-- Name: f1m; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f1m (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    com_name character varying(200),
    com_str1 character varying(34),
    com_str2 character varying(34),
    com_city character varying(30),
    com_state character varying(2),
    com_zip character varying(9),
    ctype character varying(1),
    aff_date date,
    aff_comid character varying(9),
    aff_name character varying(200),
    can1_id character varying(9),
    can1_lname character varying(90),
    can1_fname character varying(20),
    can1_mname character varying(20),
    can1_prefix character varying(10),
    can1_suffix character varying(10),
    can1_office character varying(1),
    can1_el_state character varying(2),
    can1_district character varying(2),
    can1_con date,
    can2_id character varying(9),
    can2_lname character varying(90),
    can2_fname character varying(20),
    can2_mname character varying(20),
    can2_prefix character varying(10),
    can2_suffix character varying(10),
    can2_office character varying(1),
    can2_el_state character varying(2),
    can2_district character varying(2),
    can2_con date,
    can3_id character varying(9),
    can3_lname character varying(90),
    can3_fname character varying(20),
    can3_mname character varying(20),
    can3_prefix character varying(10),
    can3_suffix character varying(10),
    can3_office character varying(1),
    can3_el_state character varying(2),
    can3_district character varying(2),
    can3_con date,
    can4_id character varying(9),
    can4_con date,
    can4_lname character varying(90),
    can4_fname character varying(20),
    can4_mname character varying(20),
    can4_prefix character varying(10),
    can4_suffix character varying(10),
    can4_office character varying(1),
    can4_el_state character varying(2),
    can4_district character varying(2),
    can5_id character varying(9),
    can5_lname character varying(90),
    can5_fname character varying(20),
    can5_mname character varying(20),
    can5_prefix character varying(10),
    can5_suffix character varying(10),
    can5_office character varying(1),
    can5_el_state character varying(2),
    can5_district character varying(2),
    can5_con date,
    date_51 date,
    orig_date date,
    metreq_date date,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f1m OWNER TO fec;

--
-- Name: f1s; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f1s (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    jfrcomname character varying(200),
    jfrcomid character varying(9),
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
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f1s OWNER TO fec;

--
-- Name: f2; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f2 (
    repid numeric(12,0) NOT NULL,
    canid character varying(9),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    amend_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    pty character varying(3),
    office character varying(1),
    el_state character varying(2),
    district numeric,
    el_year character varying(4),
    comid character varying(9),
    c_name character varying(200),
    c_str1 character varying(34),
    c_str2 character varying(34),
    c_city character varying(30),
    c_state character varying(2),
    c_zip character varying(9),
    acomid character varying(9),
    ac_name character varying(200),
    ac_str1 character varying(34),
    ac_str2 character varying(34),
    ac_city character varying(30),
    ac_state character varying(2),
    ac_zip character varying(9),
    sign_date date,
    per_fund numeric,
    gen_fund numeric,
    can_lname character varying(30),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    imageno numeric(19,0),
    create_dt timestamp without time zone,
    vp_last_name character(30),
    vp_first_name character(20),
    vp_middle_name character(20),
    vp_prefix character(10),
    vp_suffix character(10)
);


ALTER TABLE f2 OWNER TO fec;

--
-- Name: f24; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f24 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    orgamd_date date,
    name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(10),
    lname character varying(38),
    fname character varying(20),
    mname character varying(10),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    rpttype character varying(3),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f24 OWNER TO fec;

--
-- Name: f2s; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f2s (
    repid numeric(12,0) NOT NULL,
    canid character varying(9),
    acomid character varying(9),
    ac_name character varying(200),
    ac_str1 character varying(34),
    ac_str2 character varying(34),
    ac_city character varying(30),
    ac_state character varying(2),
    ac_zip character varying(9),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f2s OWNER TO fec;

--
-- Name: f3l; Type: TABLE; Schema: real_efile; Owner: fec
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
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f3l OWNER TO fec;

--
-- Name: f3ps; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f3ps (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    ge_date date,
    dayafterge_dt date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f3ps OWNER TO fec;

--
-- Name: f3pz1; Type: TABLE; Schema: real_efile; Owner: fec
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
-- Name: f3pz2; Type: TABLE; Schema: real_efile; Owner: fec
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
-- Name: f3s; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f3s (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    ge_date date,
    dayafterge_dt date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f3s OWNER TO fec;

--
-- Name: f3z; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f3z (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0) NOT NULL,
    total character varying(1),
    comid character varying(9),
    acomid character varying(9),
    pccname character varying(200),
    acom_name character varying(200),
    from_date date,
    through_date date,
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
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f3z OWNER TO fec;

--
-- Name: f3z1; Type: TABLE; Schema: real_efile; Owner: fec
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
-- Name: f3z2; Type: TABLE; Schema: real_efile; Owner: fec
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
-- Name: f4; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f4 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    con_type character varying(1),
    description character varying(40),
    rptcode character varying(3),
    from_date date,
    through_date date,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    year character varying(4),
    sign_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f4 OWNER TO fec;

--
-- Name: f5; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f5 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    entity character varying(3),
    com_name character varying(200),
    com_fname character varying(20),
    com_mname character varying(20),
    com_prefix character varying(10),
    com_suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(10),
    amend_addr character varying(1),
    qual character varying(1),
    indemp character varying(38),
    indocc character varying(38),
    rptcode character varying(3),
    rptpgi character varying(5),
    el_date date,
    el_state character varying(2),
    orig_amend_date date,
    from_date date,
    through_date date,
    total_con numeric,
    total_expe character varying(22),
    pcf_lname character varying(38),
    pcf_fname character varying(20),
    pcf_mname character varying(20),
    pcf_prefix character varying(10),
    pcf_suffix character varying(10),
    sign_date date,
    not_date date,
    expire_date date,
    lname character varying(38),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    h_code numeric,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f5 OWNER TO fec;

--
-- Name: f56; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f56 (
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
    indemp character varying(38),
    indocc character varying(38),
    con_date date,
    amount numeric(12,2),
    other_comid character varying(9),
    other_canid character varying(9),
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
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f56 OWNER TO fec;

--
-- Name: f6; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f6 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    orgamd_date date,
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    canid character varying(9),
    lname character varying(38),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    office character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    sign_lname character varying(30),
    sign_fname character varying(20),
    sign_mname character varying(20),
    sign_prefix character varying(10),
    sign_suffix character varying(10),
    sign_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f6 OWNER TO fec;

--
-- Name: f65; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f65 (
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
    indemp character varying(38),
    indocc character varying(38),
    con_date date,
    amount numeric(12,2),
    other_canid character varying(9),
    other_comid character varying(9),
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
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f65 OWNER TO fec;

--
-- Name: f7; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f7 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    org_type character varying(1),
    rptcode character varying(3),
    el_date date,
    el_state character varying(2),
    from_date date,
    through_date date,
    tot_cost numeric,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    title character varying(21),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f7 OWNER TO fec;

--
-- Name: f76; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f76 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    comm_type character varying(2),
    description character varying(40),
    comm_class character varying(1),
    comm_date date,
    supop character varying(3),
    other_canid character varying(9),
    can_name character varying(90),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    rptpgi character varying(5),
    elec_desc character varying(20),
    comm_cost numeric,
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f76 OWNER TO fec;

--
-- Name: f8; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f8 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
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
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imageno character varying(22),
    create_dt timestamp without time zone
);


ALTER TABLE f8 OWNER TO fec;

--
-- Name: f8ii; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f8ii (
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
    a_lname character varying(90),
    a_fname character varying(20),
    a_mname character varying(20),
    a_prefix character varying(10),
    a_suffix character varying(10),
    creditor_type character varying(3),
    inc_date date,
    amount_owed numeric(12,2),
    amount_off numeric(12,2),
    adesc character varying(100),
    bdesc character varying(100),
    cdesc character varying(100),
    dyn character varying(1),
    ddesc character varying(100),
    eyn character varying(1),
    edesc character varying(100),
    credit_comid character varying(9),
    credit_canid character varying(9),
    credit_lname character varying(30),
    credit_fname character varying(20),
    credit_mname character varying(20),
    credit_prefix character varying(10),
    credit_suffix character varying(10),
    credit_off character varying(1),
    credit_state character varying(2),
    credit_dist character varying(2),
    sign_date date,
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    imageno character varying(22),
    create_dt timestamp without time zone
);


ALTER TABLE f8ii OWNER TO fec;

--
-- Name: f8iii; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f8iii (
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
    creditor_type character varying(3),
    yesno character varying(1),
    inc_date date,
    amount_owed numeric(12,2),
    amount_exp numeric(12,2),
    credit_comid character varying(9),
    credit_canid character varying(9),
    credit_lname character varying(30),
    credit_fname character varying(20),
    credit_mname character varying(20),
    credit_prefix character varying(10),
    credit_suffix character varying(10),
    credit_off character varying(1),
    credit_state character varying(2),
    credit_dist character varying(2),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    imageno character varying(22),
    create_dt timestamp without time zone
);


ALTER TABLE f8iii OWNER TO fec;

--
-- Name: f9; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f9 (
    repid numeric(12,0) NOT NULL,
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
    addr_chg character varying(1),
    empl character varying(38),
    occup character varying(38),
    from_date date,
    through_date date,
    public_dist date,
    title character varying(40),
    qual_np character varying(1),
    filer_code character varying(3),
    filercd_desc character varying(20),
    segreg_bnk character varying(1),
    c_lname character varying(90),
    c_fname character varying(20),
    c_mname character varying(20),
    c_prefix character varying(10),
    c_suffix character varying(10),
    c_str1 character varying(34),
    c_str2 character varying(34),
    c_city character varying(30),
    c_state character varying(2),
    c_zip character varying(9),
    c_empl character varying(38),
    c_occup character varying(38),
    total numeric,
    disburs numeric,
    s_lname character varying(90),
    s_fname character varying(20),
    s_mname character varying(20),
    s_prefix character varying(10),
    s_suffix character varying(10),
    sign_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f9 OWNER TO fec;

--
-- Name: f91; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f91 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    empl character varying(38),
    occup character varying(38),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f91 OWNER TO fec;

--
-- Name: f92; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f92 (
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
    item_elect_cd character varying(5),
    item_elect_oth character varying(20),
    indemp character varying(38),
    indocc character varying(38),
    ytd numeric,
    receipt_date date,
    amount numeric(12,2),
    trans_code character varying(3),
    trans_desc character varying(40),
    other_id character varying(9),
    canid character varying(9),
    can_name character varying(90),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    con_name character varying(200),
    con_str1 character varying(34),
    con_str2 character varying(34),
    con_city character varying(30),
    con_state character varying(2),
    con_zip character varying(9),
    memo_code character varying(1),
    memo_text character varying(100),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    br_tran_id character varying(32),
    br_sname character varying(8),
    nc_softacct character varying(9),
    limit_ind character varying(1),
    con_orgname character varying(200),
    con_lname character varying(30),
    con_fname character varying(20),
    con_mname character varying(20),
    con_prefix character varying(10),
    con_suffix character varying(10),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f92 OWNER TO fec;

--
-- Name: f93; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f93 (
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
    trans_code character varying(3),
    trans_desc character varying(100),
    item_elect_cd character varying(5),
    item_elect_oth character varying(20),
    exp_date date,
    amount numeric(12,2),
    employer character varying(38),
    occupation character varying(38),
    other_id character varying(9),
    canid character varying(9),
    can_name character varying(90),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    con_name character varying(200),
    con_str1 character varying(34),
    con_str2 character varying(34),
    con_city character varying(30),
    con_state character varying(2),
    con_zip character varying(9),
    memo_code character varying(1),
    memo_text character varying(100),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    br_tran_id character varying(32),
    br_sname character varying(8),
    nc_softacct character varying(9),
    refund character varying(1),
    cat_code character varying(3),
    com_date date,
    rec_orgname character varying(200),
    rec_lname character varying(30),
    rec_fname character varying(20),
    rec_mname character varying(20),
    rec_prefix character varying(10),
    rec_suffix character varying(10),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f93 OWNER TO fec;

--
-- Name: f94; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f94 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    canid character varying(9),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    off character varying(1),
    state character varying(2),
    dist character varying(2),
    item_elect_cd character varying(5),
    item_elect_oth character varying(20),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    br_tran_id character varying(32),
    br_sname character varying(8),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f94 OWNER TO fec;

--
-- Name: f99; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE f99 (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    text_code character varying(3),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE f99 OWNER TO fec;

--
-- Name: guarantors; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE guarantors (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    line_num character varying(8),
    tran_id character varying(32) NOT NULL,
    refid character varying(32),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    indemp character varying(38),
    indocc character varying(38),
    amt_guar numeric(12,2),
    amend character varying(1),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE guarantors OWNER TO fec;

--
-- Name: h1; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE h1 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    nat_rate numeric,
    hs_min numeric,
    hs_persupport numeric,
    hs_pernonfed numeric,
    hs_actsupport numeric,
    hs_actnonfed numeric,
    hs_actperfed numeric,
    est_persupport numeric,
    est_pernonfed numeric,
    act_support numeric,
    act_nonfed numeric,
    act_perfed numeric,
    pres character varying(1),
    sen character varying(1),
    hse character varying(1),
    subtotal character varying(1),
    gov character varying(1),
    other_sw character varying(1),
    state_sen character varying(1),
    state_rep character varying(1),
    local character varying(1),
    extra character varying(1),
    sub character varying(2),
    total character varying(2),
    fed_per numeric,
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    memo_code character varying(1),
    memo_text character varying(100),
    slp_pres character varying(1),
    slp_pres_sen character varying(1),
    slp_sen character varying(1),
    slp_non character varying(1),
    min_fedper character varying(1),
    federal numeric,
    non_federal numeric,
    admin_ratio character varying(1),
    gen_vd_ratio character varying(1),
    pub_crp_ratio character varying(1),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE h1 OWNER TO fec;

--
-- Name: h2; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE h2 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    event character varying(90),
    fundraising character varying(1),
    exempt character varying(1),
    direct character varying(1),
    ratio_code character varying(1),
    fed_per numeric,
    nonfed_per numeric,
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    memo_code character varying(1),
    memo_text character varying(100),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE h2 OWNER TO fec;

--
-- Name: h3; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE h3 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    refid character varying(32),
    account character varying(90),
    event character varying(90),
    event_type character varying(2),
    rec_date date,
    amount numeric(12,2),
    tot_amount numeric(12,2),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    memo_code character varying(1),
    memo_text character varying(100),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE h3 OWNER TO fec;

--
-- Name: h4_2; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE h4_2 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    tran_id character varying(32) NOT NULL,
    br_tran_id character varying(32),
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
    exp_desc character varying(100),
    event_date date,
    amount numeric(12,2),
    fed_share numeric(12,2),
    nonfed_share numeric(12,2),
    event_ytd numeric(12,2),
    trans_code character varying(3),
    purpose character varying(100),
    cat_code character varying(3),
    admin character varying(1),
    fundraising character varying(1),
    exempt character varying(1),
    gen_vote character varying(1),
    voter_drive character varying(1),
    support character varying(1),
    activity_pc character varying(1),
    memo_code character varying(1),
    memo_text character varying(100),
    amend character varying(1),
    imageno numeric(19,0),
    create_dt timestamp without time zone,
    can_name character varying(90),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    event_num character varying(10),
    other_canid character varying(9),
    other_comid character varying(9),
    other_name character varying(200),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    used character varying(1),
    upr_tran_id character varying(32)
);


ALTER TABLE h4_2 OWNER TO fec;

--
-- Name: h5; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE h5 (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    receipt_date date,
    reg numeric,
    id numeric,
    gotv numeric,
    camp numeric,
    total numeric,
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE h5 OWNER TO fec;

--
-- Name: h6; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE h6 (
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
    cat_code character varying(3),
    trans_code character varying(3),
    trans_desc character varying(100),
    exp_date date,
    total numeric,
    federal numeric,
    levin numeric,
    reg character varying(1),
    id character varying(1),
    gotv character varying(1),
    camp character varying(1),
    ytd numeric,
    exp_desc character varying(100),
    other_id character varying(9),
    canid character varying(9),
    can_lname character varying(90),
    can_fname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    con_comid character varying(9),
    con_name character varying(200),
    con_str1 character varying(34),
    con_str2 character varying(34),
    con_city character varying(30),
    con_state character varying(2),
    con_zip character varying(9),
    memo_code character varying(1),
    memo_text character varying(100),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    br_tran_id character varying(32),
    br_sname character varying(8),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE h6 OWNER TO fec;

--
-- Name: i_sum; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE i_sum (
    repid numeric(12,0),
    iid numeric,
    lineno numeric(12,0),
    cola numeric,
    colb numeric,
    create_dt timestamp without time zone
);


ALTER TABLE i_sum OWNER TO fec;

--
-- Name: issues; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE issues (
    repid bigint,
    message character(3000)
);


ALTER TABLE issues OWNER TO fec;

--
-- Name: sc; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE sc (
    repid numeric(12,0) NOT NULL,
    line_num character varying(8),
    rel_lineno numeric(12,0),
    refid character varying(32),
    entity character varying(3),
    comid character varying(9),
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
    code character varying(5),
    code_des character varying(20),
    orig_amt numeric(12,2),
    ptd numeric,
    balance numeric,
    date_inc date,
    date_due character varying(15),
    int_rate character varying(15),
    secured character varying(1),
    pers_funds character varying(1),
    other_comid character varying(9),
    other_canid character varying(9),
    can_name character varying(90),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    memo_cd character varying(1),
    memo_txt character varying(100),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    rec_lineno character varying(8),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE sc OWNER TO fec;

--
-- Name: sc1; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE sc1 (
    repid numeric(12,0) NOT NULL,
    line_num character varying(8),
    rel_lineno numeric(12,0),
    tran_id character varying(32) NOT NULL,
    refid character varying(32),
    comid character varying(9),
    entity character varying(3),
    lender character varying(90),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    amount numeric(12,2),
    int_rate character varying(15),
    date_inc date,
    date_due character varying(15),
    restruct character varying(1),
    orig_date date,
    b1_credit numeric,
    balance numeric,
    others character varying(1),
    collateral character varying(1),
    coll_des character varying(100),
    coll_val numeric,
    perf_int character varying(1),
    future_inc character varying(1),
    fi_desc character varying(100),
    est_val numeric,
    account_date date,
    name_acc character varying(90),
    str1_acc character varying(34),
    str2_acc character varying(34),
    city_acc character varying(30),
    state_acc character varying(2),
    zip_acc character varying(9),
    a_date date,
    basis_desc character varying(100),
    t_lname character varying(90),
    t_fname character varying(20),
    t_mname character varying(20),
    t_prefix character varying(10),
    t_suffix character varying(10),
    signed_date date,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    auth_title character varying(20),
    auth_date date,
    amend character varying(1),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE sc1 OWNER TO fec;

--
-- Name: sd; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE sd (
    repid numeric(12,0) NOT NULL,
    line_num character varying(8),
    comid character varying(9),
    rel_lineno numeric(12,0),
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
    nature character varying(100),
    beg_balance numeric,
    incurred numeric,
    payment numeric,
    balance numeric,
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
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE sd OWNER TO fec;

--
-- Name: sf; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE sf (
    repid numeric(12,0) NOT NULL,
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    cord_exp character varying(1),
    des_comid character varying(9),
    des_com_name character varying(200),
    sub_comid character varying(9),
    sub_com_name character varying(200),
    sub_str1 character varying(34),
    sub_str2 character varying(34),
    sub_city character varying(30),
    sub_state character varying(2),
    sub_zip character varying(9),
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
    canid character varying(9),
    can_name character varying(90),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    agg_amount numeric(12,2),
    transdesc character varying(100),
    t_date date,
    amount numeric(12,2),
    other_comid character varying(9),
    other_name character varying(200),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    memo_code character varying(1),
    memo_text character varying(100),
    br_tran_id character varying(32),
    br_sname character varying(8),
    unlimit character varying(1),
    cat_code character varying(3),
    trans_code character varying(3),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE sf OWNER TO fec;

--
-- Name: si; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE si (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    bankid character varying(16),
    account_name character varying(200),
    from_date date,
    to_date date,
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    acct_num character varying(9),
    imageno character varying(22),
    create_dt timestamp without time zone
);


ALTER TABLE si OWNER TO fec;

--
-- Name: sl; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE sl (
    repid numeric(12,0) NOT NULL,
    rel_lineno numeric(12,0),
    comid character varying(9),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    rec_id character varying(9),
    from_date date,
    through_date date,
    ending numeric,
    amend character varying(1),
    tran_id character varying(32) NOT NULL,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE sl OWNER TO fec;

--
-- Name: sl_sum; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE sl_sum (
    repid numeric(12,0) NOT NULL,
    iid numeric NOT NULL,
    lineno numeric(12,0) NOT NULL,
    cola numeric,
    colb numeric,
    create_dt timestamp without time zone
);


ALTER TABLE sl_sum OWNER TO fec;

--
-- Name: supsum; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE supsum (
    repid numeric(12,0) NOT NULL,
    lineno numeric(12,0) NOT NULL,
    colbs numeric,
    create_dt timestamp without time zone
);


ALTER TABLE supsum OWNER TO fec;

--
-- Name: text; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE text (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    tranid character varying(32) NOT NULL,
    rec_type character varying(8),
    br_tran_id character varying(32),
    text_id character varying(40),
    amend character varying(1),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


ALTER TABLE text OWNER TO fec;
