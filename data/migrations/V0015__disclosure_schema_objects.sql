SET search_path = disclosure, pg_catalog;

--
-- Name: dsc_sched_a_aggregate_employer; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE dsc_sched_a_aggregate_employer (
    cmte_id character varying(9),
    cycle numeric,
    employer character varying(38),
    total numeric,
    count bigint,
    idx integer DEFAULT nextval('public.ofec_sched_a_aggregate_employer_idx_seq1'::regclass) NOT NULL
);


ALTER TABLE dsc_sched_a_aggregate_employer OWNER TO fec;


--
-- Name: dsc_sched_a_aggregate_occupation; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE dsc_sched_a_aggregate_occupation (
    cmte_id character varying(9),
    cycle numeric,
    occupation character varying(38),
    total numeric,
    count bigint,
    idx integer DEFAULT nextval('public.ofec_sched_a_aggregate_occupation_idx_seq1'::regclass) NOT NULL
);


ALTER TABLE dsc_sched_a_aggregate_occupation OWNER TO fec;

--
-- Name: dsc_sched_a_aggregate_size; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE dsc_sched_a_aggregate_size (
    cmte_id character varying(9),
    cycle numeric,
    size integer,
    total numeric,
    count bigint
);


ALTER TABLE dsc_sched_a_aggregate_size OWNER TO fec;

--
-- Name: dsc_sched_a_aggregate_state; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE dsc_sched_a_aggregate_state (
    cmte_id character varying(9),
    cycle numeric,
    state character varying(2),
    state_full text,
    total numeric,
    count bigint,
    idx integer DEFAULT nextval('public.ofec_sched_a_aggregate_state_idx_seq1'::regclass) NOT NULL
);


ALTER TABLE dsc_sched_a_aggregate_state OWNER TO fec;

--
-- Name: dsc_sched_a_aggregate_zip; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE dsc_sched_a_aggregate_zip (
    cmte_id character varying(9),
    cycle numeric,
    zip character varying(9),
    state text,
    state_full text,
    total numeric,
    count bigint,
    idx integer DEFAULT nextval('public.ofec_sched_a_aggregate_zip_idx_seq1'::regclass) NOT NULL
);


ALTER TABLE dsc_sched_a_aggregate_zip OWNER TO fec;

--
-- Name: dsc_sched_b_aggregate_purpose; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE dsc_sched_b_aggregate_purpose (
    cmte_id character varying(9),
    cycle numeric,
    purpose character varying,
    total numeric,
    count bigint,
    idx integer DEFAULT nextval('public.ofec_sched_b_aggregate_purpose_idx_seq1'::regclass) NOT NULL
);


ALTER TABLE dsc_sched_b_aggregate_purpose OWNER TO fec;

--
-- Name: dsc_sched_b_aggregate_recipient; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE dsc_sched_b_aggregate_recipient (
    cmte_id character varying(9),
    cycle numeric,
    recipient_nm character varying(200),
    total numeric,
    count bigint,
    idx integer DEFAULT nextval('public.ofec_sched_b_aggregate_recipient_idx_seq1'::regclass) NOT NULL
);


ALTER TABLE dsc_sched_b_aggregate_recipient OWNER TO fec;

--
-- Name: dsc_sched_b_aggregate_recipient_id; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE dsc_sched_b_aggregate_recipient_id (
    cmte_id character varying(9),
    cycle numeric,
    recipient_cmte_id character varying,
    recipient_nm text,
    total numeric,
    count bigint,
    idx integer DEFAULT nextval('public.ofec_sched_b_aggregate_recipient_id_idx_seq1'::regclass) NOT NULL
);


ALTER TABLE dsc_sched_b_aggregate_recipient_id OWNER TO fec;

--
-- Name: f_item_daily; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE f_item_daily (
    sub_id numeric(19,0) NOT NULL,
    v_sum_link_id numeric(19,0) NOT NULL,
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    rpt_receipt_dt date,
    cmte_id character varying(9),
    image_num character varying(18),
    line_num character varying(12),
    form_tp_cd character varying(8),
    sched_tp_cd character varying(8),
    name character varying(200),
    first_name character varying(38),
    last_name character varying(38),
    street_1 character varying(34),
    street_2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip_code character varying(9),
    employer character varying(38),
    occupation character varying(38),
    transaction_dt numeric(8,0),
    transaction_amt numeric(14,2),
    transaction_pgi character varying(5),
    aggregate_amt numeric(14,2),
    transaction_tp character varying(3),
    purpose character varying(100),
    category character varying(3),
    category_desc character varying(40),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    other_id character varying(9),
    subordinate_cmte character varying(9),
    cand_id character varying(9),
    support_oppose_ind character varying(3),
    conduit_cmte_id character varying(9),
    national_cmte_nonfed_acct character varying(9),
    increased_limit character varying(1),
    unlimited_spending character varying(1),
    refund_or_excess character varying(1),
    communication_dt numeric(8,0),
    loan_dt numeric(8,0),
    loan_amt numeric(14,2),
    loan_interest_rate character varying(15),
    loan_due_dt character varying(15),
    loan_pymt_to_dt numeric(14,2),
    loan_outstanding_balance numeric(14,2),
    sched_a_line_num character varying(3),
    original_loan_date numeric(8,0),
    credit_amt_this_draw numeric(14,2),
    depository_acct_est_dt numeric(8,0),
    depository_acct_auth_dt numeric(8,0),
    debt_outstanding_balance_bop numeric(14,2),
    debt_outstanding_balance_cop numeric(14,2),
    debt_amt_incurred_per numeric(14,2),
    debt_pymt_per numeric(14,2),
    communication_cost numeric(14,2),
    communication_tp character varying(2),
    communication_class character varying(1),
    loan_flag character varying(1),
    account_nm character varying(90),
    event_nm character varying(90),
    event_tp character varying(2),
    event_tp_desc character varying(50),
    federal_share numeric(14,2),
    nonfederal_levin_share numeric(14,2),
    admin_voter_drive_ind character varying(1),
    ratio_cd character varying(1),
    fundraising_ind character varying(1),
    exempt_ind character varying(1),
    direct_candidate_support_ind character varying(1),
    admin_ind character varying(1),
    voter_drive_ind character varying(1),
    pub_comm_ref_pty_chk character varying(1),
    voter_reg_amt numeric(14,2),
    voter_id_amt numeric(14,2),
    gotv_amt numeric(14,2),
    gen_campaign_amt numeric(14,2),
    np_fixed_fed_pct numeric(7,4),
    hsp_min_fed_pct numeric(7,4),
    hsp_est_fed_dir_cand_supp_pct numeric(7,4),
    hsp_est_nonfed_cand_supp_pct numeric(7,4),
    hsp_actl_fed_dir_cand_supp_amt numeric(14,2),
    hsp_actl_nonfed_cand_supp_amt numeric(14,2),
    hsp_actl_fed_dir_cand_supp_pct numeric(7,4),
    ssf_fed_est_dir_cand_supp_pct numeric(7,4),
    ssf_nfed_est_dir_cand_supp_pct numeric(7,4),
    ssf_actl_fed_dir_cand_supp_amt numeric(14,2),
    ssf_actl_nonfed_cand_supp_amt numeric(14,2),
    ssf_actl_fed_dir_cand_supp_pct numeric(7,4),
    president_ind numeric(1,0),
    us_senate_ind numeric(1,0),
    us_congress_ind numeric(1,0),
    subttl_fed numeric(1,0),
    governor_ind numeric(1,0),
    other_st_offices_ind numeric(1,0),
    st_senate_ind numeric(1,0),
    st_rep_ind numeric(1,0),
    local_cand_ind numeric(1,0),
    extra_non_fed_point_ind numeric(1,0),
    subttl_non_fed numeric(2,0),
    ttl_fed_and_nonfed numeric(2,0),
    fed_alloctn numeric(5,0),
    st_loc_pres_only character varying(1),
    st_loc_pres_sen character varying(1),
    st_loc_sen_only character varying(1),
    st_loc_nonpres_nonsen character varying(1),
    flat_min_fed_pct character varying(1),
    fed_pct numeric(5,0),
    non_fed_pct numeric(5,0),
    admin_ratio_chk character varying(1),
    gen_voter_drive_chk character varying(1),
    last_update_dt timestamp without time zone,
    entity_tp character varying(3),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    dissem_dt numeric(8,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE f_item_daily OWNER TO fec;

--
-- Name: f_item_delete_daily; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE f_item_delete_daily (
    table_name character varying(50) NOT NULL,
    sub_id numeric(19,0) NOT NULL,
    pg_date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE f_item_delete_daily OWNER TO fec;

--
-- Name: f_item_receipt_or_exp; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE f_item_receipt_or_exp (
    sub_id numeric(19,0) NOT NULL,
    v_sum_link_id numeric(19,0) NOT NULL,
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    rpt_receipt_dt date,
    cmte_id character varying(9),
    image_num character varying(18),
    line_num character varying(12),
    form_tp_cd character varying(8),
    sched_tp_cd character varying(8),
    name character varying(200),
    first_name character varying(38),
    last_name character varying(38),
    street_1 character varying(34),
    street_2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip_code character varying(9),
    employer character varying(38),
    occupation character varying(38),
    transaction_dt numeric(8,0),
    transaction_amt numeric(14,2),
    transaction_pgi character varying(5),
    aggregate_amt numeric(14,2),
    transaction_tp character varying(3),
    purpose character varying(100),
    category character varying(3),
    category_desc character varying(40),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    other_id character varying(9),
    subordinate_cmte character varying(9),
    cand_id character varying(9),
    support_oppose_ind character varying(3),
    conduit_cmte_id character varying(9),
    national_cmte_nonfed_acct character varying(9),
    increased_limit character varying(1),
    unlimited_spending character varying(1),
    refund_or_excess character varying(1),
    communication_dt numeric(8,0),
    loan_dt numeric(8,0),
    loan_amt numeric(14,2),
    loan_interest_rate character varying(15),
    loan_due_dt character varying(15),
    loan_pymt_to_dt numeric(14,2),
    loan_outstanding_balance numeric(14,2),
    sched_a_line_num character varying(3),
    original_loan_date numeric(8,0),
    credit_amt_this_draw numeric(14,2),
    depository_acct_est_dt numeric(8,0),
    depository_acct_auth_dt numeric(8,0),
    debt_outstanding_balance_bop numeric(14,2),
    debt_outstanding_balance_cop numeric(14,2),
    debt_amt_incurred_per numeric(14,2),
    debt_pymt_per numeric(14,2),
    communication_cost numeric(14,2),
    communication_tp character varying(2),
    communication_class character varying(1),
    loan_flag character varying(1),
    account_nm character varying(90),
    event_nm character varying(90),
    event_tp character varying(2),
    event_tp_desc character varying(50),
    federal_share numeric(14,2),
    nonfederal_levin_share numeric(14,2),
    admin_voter_drive_ind character varying(1),
    ratio_cd character varying(1),
    fundraising_ind character varying(1),
    exempt_ind character varying(1),
    direct_candidate_support_ind character varying(1),
    admin_ind character varying(1),
    voter_drive_ind character varying(1),
    pub_comm_ref_pty_chk character varying(1),
    voter_reg_amt numeric(14,2),
    voter_id_amt numeric(14,2),
    gotv_amt numeric(14,2),
    gen_campaign_amt numeric(14,2),
    np_fixed_fed_pct numeric(7,4),
    hsp_min_fed_pct numeric(7,4),
    hsp_est_fed_dir_cand_supp_pct numeric(7,4),
    hsp_est_nonfed_cand_supp_pct numeric(7,4),
    hsp_actl_fed_dir_cand_supp_amt numeric(14,2),
    hsp_actl_nonfed_cand_supp_amt numeric(14,2),
    hsp_actl_fed_dir_cand_supp_pct numeric(7,4),
    ssf_fed_est_dir_cand_supp_pct numeric(7,4),
    ssf_nfed_est_dir_cand_supp_pct numeric(7,4),
    ssf_actl_fed_dir_cand_supp_amt numeric(14,2),
    ssf_actl_nonfed_cand_supp_amt numeric(14,2),
    ssf_actl_fed_dir_cand_supp_pct numeric(7,4),
    president_ind numeric(1,0),
    us_senate_ind numeric(1,0),
    us_congress_ind numeric(1,0),
    subttl_fed numeric(1,0),
    governor_ind numeric(1,0),
    other_st_offices_ind numeric(1,0),
    st_senate_ind numeric(1,0),
    st_rep_ind numeric(1,0),
    local_cand_ind numeric(1,0),
    extra_non_fed_point_ind numeric(1,0),
    subttl_non_fed numeric(2,0),
    ttl_fed_and_nonfed numeric(2,0),
    fed_alloctn numeric(5,0),
    st_loc_pres_only character varying(1),
    st_loc_pres_sen character varying(1),
    st_loc_sen_only character varying(1),
    st_loc_nonpres_nonsen character varying(1),
    flat_min_fed_pct character varying(1),
    fed_pct numeric(5,0),
    non_fed_pct numeric(5,0),
    admin_ratio_chk character varying(1),
    gen_voter_drive_chk character varying(1),
    last_update_dt timestamp without time zone,
    entity_tp character varying(3),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    dissem_dt numeric(8,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE f_item_receipt_or_exp OWNER TO fec;

--
-- Name: f_rpt_or_form_sub; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE f_rpt_or_form_sub (
    sub_id numeric(19,0) NOT NULL,
    cvg_start_dt numeric(8,0),
    cvg_end_dt numeric(8,0),
    receipt_dt numeric(8,0),
    election_yr numeric(4,0),
    cand_cmte_id character varying(9),
    form_tp character varying(8),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    amndt_ind character varying(1),
    request_tp character varying(3),
    to_from_ind character varying(1),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    pages numeric(8,0),
    ttl_receipts numeric(14,2),
    ttl_indt_contb numeric(14,2),
    net_dons numeric(14,2),
    ttl_disb numeric(14,2),
    ttl_indt_exp numeric(14,2),
    ttl_communication_cost numeric(14,2),
    coh_bop numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    hse_pers_funds_amt numeric(14,2),
    sen_pers_funds_amt numeric(14,2),
    oppos_pers_fund_amt numeric(14,2),
    cand_pk numeric(19,0),
    cmte_pk numeric(19,0),
    tres_nm character varying(38),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    lst_updt_dt timestamp without time zone,
    rpt_pgi character varying(5),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE f_rpt_or_form_sub OWNER TO fec;

--
-- Name: fec_fitem_f105; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_f105 (
    filer_cmte_id character varying(9),
    exp_dt timestamp without time zone,
    election_tp character varying(5),
    election_tp_desc character varying(20),
    fec_election_tp_desc character varying(20),
    exp_amt numeric(14,2),
    loan_chk_flg character varying(1),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_f105 OWNER TO fec;

--
-- Name: fec_fitem_f56; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_f56 (
    filer_cmte_id character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    contbr_nm character varying(200),
    contbr_l_nm character varying(30),
    contbr_f_nm character varying(20),
    contbr_m_nm character varying(20),
    contbr_prefix character varying(10),
    contbr_suffix character varying(10),
    contbr_st1 character varying(34),
    contbr_st2 character varying(34),
    conbtr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    contb_dt timestamp without time zone,
    contb_amt numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_nm character varying(200),
    conduit_st1 character varying(34),
    conduit_st2 character varying(34),
    conduit_city character varying(30),
    conduit_st character varying(2),
    conduit_zip character varying(9),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_f56 OWNER TO fec;

--
-- Name: fec_fitem_f57; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_f57 (
    filer_cmte_id character varying(9),
    pye_nm character varying(200),
    pye_l_nm character varying(30),
    pye_f_nm character varying(20),
    pye_m_nm character varying(20),
    pye_prefix character varying(10),
    pye_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_purpose character varying(100),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    s_o_cand_id character varying(9),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_state_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(20),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    cal_ytd_ofc_sought numeric(14,2),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    link_id numeric(19,0),
    image_num character varying(18),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_f57 OWNER TO fec;

--
-- Name: fec_fitem_f76; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_f76 (
    org_id character varying(9),
    communication_tp character varying(2),
    communication_tp_desc character varying(40),
    communication_class character varying(1),
    communication_class_desc character varying(90),
    communication_dt timestamp without time zone,
    s_o_ind character varying(3),
    s_o_ind_desc character varying(90),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_rpt_pgi character varying(5),
    s_o_rpt_pgi_desc character varying(10),
    communication_cost numeric(14,2),
    election_other_desc character varying(20),
    transaction_tp character varying(3),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_f76 OWNER TO fec;

--
-- Name: fec_fitem_f91; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_f91 (
    filer_cmte_id character varying(9),
    shr_ex_ctl_ind_nm character varying(90),
    shr_ex_ctl_l_nm character varying(30),
    shr_ex_ctl_f_nm character varying(20),
    shr_ex_ctl_m_nm character varying(20),
    shr_ex_ctl_prefix character varying(10),
    shr_ex_ctl_suffix character varying(10),
    shr_ex_ctl_street1 character varying(34),
    shr_ex_ctl_street2 character varying(34),
    shr_ex_ctl_city character varying(30),
    shr_ex_ctl_st character varying(2),
    shr_ex_ctl_st_desc character varying(20),
    shr_ex_ctl_zip character varying(9),
    shr_ex_ctl_employ character varying(38),
    shr_ex_ctl_occup character varying(38),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    begin_image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_f91 OWNER TO fec;

--
-- Name: fec_fitem_f94; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_f94 (
    filer_cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_l_nm character varying(30),
    cand_f_nm character varying(20),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    election_tp character varying(5),
    election_tp_desc character varying(20),
    fec_election_tp_desc character varying(20),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    begin_image_num character varying(18),
    sb_link_id numeric(19,0),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_f94 OWNER TO fec;

--
-- Name: fec_fitem_sched_a; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    contbr_id character varying(9),
    contbr_nm character varying(200),
    contbr_nm_first character varying(38),
    contbr_m_nm character varying(20),
    contbr_nm_last character varying(38),
    contbr_prefix character varying(10),
    contbr_suffix character varying(10),
    contbr_st1 character varying(34),
    contbr_st2 character varying(34),
    contbr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    contb_aggregate_ytd numeric(14,2),
    contb_receipt_dt timestamp without time zone,
    contb_receipt_amt numeric(14,2),
    receipt_tp character varying(3),
    receipt_tp_desc character varying(90),
    receipt_desc character varying(100),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_m_nm character varying(20),
    cand_nm_last character varying(38),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    donor_cmte_nm character varying(200),
    national_cmte_nonfed_acct character varying(9),
    increased_limit character varying(1),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pdf_url text,
    contributor_name_text tsvector,
    contributor_employer_text tsvector,
    contributor_occupation_text tsvector,
    is_individual boolean,
    clean_contbr_id character varying(9),
    pg_date timestamp without time zone DEFAULT now(),
    line_number_label text
);


ALTER TABLE fec_fitem_sched_a OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1975_1976; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1975_1976 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1975, 1976])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1975_1976 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1977_1978; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1977_1978 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1977, 1978])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1977_1978 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1979_1980; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1979_1980 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1979, 1980])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1979_1980 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1981_1982; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1981_1982 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1981, 1982])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1981_1982 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1983_1984; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1983_1984 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1983, 1984])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1983_1984 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1985_1986; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1985_1986 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1985, 1986])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1985_1986 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1987_1988; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1987_1988 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1987, 1988])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1987_1988 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1989_1990; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1989_1990 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1989, 1990])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1989_1990 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1991_1992; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1991_1992 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1991, 1992])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1991_1992 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1993_1994; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1993_1994 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1993, 1994])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1993_1994 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1995_1996; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1995_1996 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1995, 1996])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1995_1996 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1997_1998; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1997_1998 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1997, 1998])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1997_1998 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_1999_2000; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_1999_2000 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1999, 2000])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_1999_2000 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_2001_2002; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_2001_2002 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2001, 2002])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_2001_2002 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_2003_2004; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_2003_2004 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2003, 2004])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_2003_2004 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_2005_2006; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_2005_2006 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2005, 2006])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_2005_2006 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_2007_2008; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_2007_2008 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2007, 2008])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_2007_2008 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_2009_2010; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_2009_2010 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2009, 2010])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_2009_2010 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_2011_2012; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_2011_2012 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2011, 2012])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_2011_2012 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_2013_2014; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_2013_2014 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2013, 2014])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_2013_2014 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_2015_2016; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_2015_2016 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2015, 2016])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_2015_2016 OWNER TO fec;

--
-- Name: fec_fitem_sched_a_2017_2018; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_a_2017_2018 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2017, 2018])::numeric[])))
)
INHERITS (fec_fitem_sched_a);


ALTER TABLE fec_fitem_sched_a_2017_2018 OWNER TO fec;

--
-- Name: fec_fitem_sched_b; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b (
    cmte_id character varying(9),
    recipient_cmte_id character varying(9),
    recipient_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    payee_employer character varying(38),
    payee_occupation character varying(38),
    recipient_st1 character varying(34),
    recipient_st2 character varying(34),
    recipient_city character varying(30),
    recipient_st character varying(2),
    recipient_zip character varying(9),
    disb_desc character varying(100),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_tp_year character varying(4),
    election_tp_desc character varying(20),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    disb_dt timestamp without time zone,
    disb_amt numeric(14,2),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    disb_tp character varying(3),
    disb_tp_desc character varying(90),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    national_cmte_nonfed_acct character varying(9),
    ref_disp_excess_flg character varying(1),
    comm_dt timestamp without time zone,
    benef_cmte_nm character varying(200),
    semi_an_bundled_refund numeric(14,2),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_id character varying(8),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pdf_url text,
    recipient_name_text tsvector,
    disbursement_description_text tsvector,
    disbursement_purpose_category character varying,
    clean_recipient_cmte_id character varying(9),
    pg_date timestamp without time zone DEFAULT now(),
    line_number_label text
);


ALTER TABLE fec_fitem_sched_b OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1975_1976; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1975_1976 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1975, 1976])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1975_1976 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1977_1978; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1977_1978 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1977, 1978])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1977_1978 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1979_1980; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1979_1980 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1979, 1980])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1979_1980 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1981_1982; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1981_1982 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1981, 1982])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1981_1982 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1983_1984; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1983_1984 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1983, 1984])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1983_1984 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1985_1986; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1985_1986 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1985, 1986])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1985_1986 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1987_1988; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1987_1988 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1987, 1988])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1987_1988 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1989_1990; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1989_1990 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1989, 1990])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1989_1990 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1991_1992; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1991_1992 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1991, 1992])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1991_1992 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1993_1994; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1993_1994 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1993, 1994])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1993_1994 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1995_1996; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1995_1996 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1995, 1996])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1995_1996 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1997_1998; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1997_1998 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1997, 1998])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1997_1998 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_1999_2000; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_1999_2000 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[1999, 2000])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_1999_2000 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_2001_2002; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_2001_2002 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2001, 2002])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_2001_2002 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_2003_2004; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_2003_2004 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2003, 2004])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_2003_2004 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_2005_2006; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_2005_2006 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2005, 2006])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_2005_2006 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_2007_2008; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_2007_2008 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2007, 2008])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_2007_2008 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_2009_2010; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_2009_2010 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2009, 2010])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_2009_2010 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_2011_2012; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_2011_2012 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2011, 2012])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_2011_2012 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_2013_2014; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_2013_2014 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2013, 2014])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_2013_2014 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_2015_2016; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_2015_2016 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2015, 2016])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_2015_2016 OWNER TO fec;

--
-- Name: fec_fitem_sched_b_2017_2018; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_b_2017_2018 (
    CONSTRAINT check_election_cycle CHECK ((election_cycle = ANY ((ARRAY[2017, 2018])::numeric[])))
)
INHERITS (fec_fitem_sched_b);


ALTER TABLE fec_fitem_sched_b_2017_2018 OWNER TO fec;

--
-- Name: fec_fitem_sched_c; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_c (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    loan_src_l_nm character varying(30),
    loan_src_f_nm character varying(20),
    loan_src_m_nm character varying(20),
    loan_src_prefix character varying(10),
    loan_src_suffix character varying(10),
    loan_src_nm character varying(200),
    loan_src_st1 character varying(34),
    loan_src_st2 character varying(34),
    loan_src_city character varying(30),
    loan_src_st character varying(2),
    loan_src_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_tp_year character varying(4),
    election_tp_desc character varying(20),
    orig_loan_amt numeric(14,2),
    pymt_to_dt numeric(14,2),
    loan_bal numeric(14,2),
    incurred_dt timestamp without time zone,
    due_dt_terms character varying(15),
    interest_rate_terms character varying(15),
    secured_ind character varying(1),
    sched_a_line_num character varying(3),
    pers_fund_yes_no character varying(1),
    memo_cd character varying(1),
    memo_text character varying(100),
    fec_cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_state_desc character varying(20),
    cand_office_district character varying(2),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_sched_c OWNER TO fec;

--
-- Name: fec_fitem_sched_c1; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_c1 (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    entity_tp_desc character varying(50),
    loan_src_nm character varying(200),
    loan_src_st1 character varying(34),
    loan_src_st2 character varying(34),
    loan_src_city character varying(30),
    loan_src_st character varying(2),
    loan_src_zip character varying(9),
    entity_tp character varying(3),
    loan_amt numeric(14,2),
    interest_rate_pct character varying(15),
    incurred_dt timestamp without time zone,
    due_dt character varying(15),
    loan_restructured_flg character varying(1),
    orig_loan_dt timestamp without time zone,
    credit_amt_this_draw numeric(14,2),
    ttl_bal numeric(14,2),
    other_liable_pty_flg character varying(1),
    collateral_flg character varying(1),
    collateral_desc character varying(100),
    collateral_value numeric(14,2),
    perfected_interest_flg character varying(1),
    future_income_flg character varying(1),
    future_income_desc character varying(100),
    future_income_est_value numeric(14,2),
    depository_acct_est_dt timestamp without time zone,
    acct_loc_nm character varying(90),
    acct_loc_st1 character varying(34),
    acct_loc_st2 character varying(34),
    acct_loc_city character varying(30),
    acct_loc_st character varying(2),
    acct_loc_zip character varying(9),
    depository_acct_auth_dt timestamp without time zone,
    loan_basis_desc character varying(100),
    tres_sign_nm character varying(90),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    tres_sign_dt timestamp without time zone,
    auth_sign_nm character varying(90),
    auth_sign_l_nm character varying(30),
    auth_sign_f_nm character varying(20),
    auth_sign_m_nm character varying(20),
    auth_sign_prefix character varying(10),
    auth_sign_suffix character varying(10),
    auth_rep_title character varying(20),
    auth_sign_dt timestamp without time zone,
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_sched_c1 OWNER TO fec;

--
-- Name: fec_fitem_sched_c2; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_c2 (
    cmte_id character varying(9),
    back_ref_tran_id character varying(32),
    guar_endr_nm character varying(90),
    guar_endr_l_nm character varying(30),
    guar_endr_f_nm character varying(20),
    guar_endr_m_nm character varying(20),
    guar_endr_prefix character varying(10),
    guar_endr_suffix character varying(10),
    guar_endr_st1 character varying(34),
    guar_endr_st2 character varying(34),
    guar_endr_city character varying(30),
    guar_endr_st character varying(2),
    guar_endr_zip character varying(9),
    guar_endr_employer character varying(38),
    guar_endr_occupation character varying(38),
    amt_guaranteed_outstg numeric(14,2),
    receipt_dt timestamp without time zone,
    action_cd character varying(1),
    action_cd_desc character varying(15),
    file_num numeric(7,0),
    tran_id character varying(32),
    schedule_type character(3),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_sched_c2 OWNER TO fec;

--
-- Name: fec_fitem_sched_d; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_d (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cred_dbtr_id character varying(9),
    cred_dbtr_nm character varying(200),
    cred_dbtr_l_nm character varying(30),
    cred_dbtr_f_nm character varying(20),
    cred_dbtr_m_nm character varying(20),
    cred_dbtr_prefix character varying(10),
    cred_dbtr_suffix character varying(10),
    cred_dbtr_st1 character varying(34),
    cred_dbtr_st2 character varying(34),
    cred_dbtr_city character varying(30),
    cred_dbtr_st character varying(2),
    cred_dbtr_zip character varying(9),
    entity_tp character varying(3),
    nature_debt_purpose character varying(100),
    outstg_bal_bop numeric(14,2),
    amt_incurred_per numeric(14,2),
    pymt_per numeric(14,2),
    outstg_bal_cop numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_sched_d OWNER TO fec;

--
-- Name: fec_fitem_sched_e; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_e (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    pye_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    exp_desc character varying(100),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_nm_first character varying(38),
    s_o_cand_nm_last character varying(38),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    cal_ytd_ofc_sought numeric(14,2),
    dissem_dt timestamp without time zone,
    exp_amt numeric(14,2),
    exp_dt timestamp without time zone,
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    indt_sign_nm character varying(90),
    indt_sign_dt timestamp without time zone,
    notary_sign_nm character varying(90),
    notary_sign_dt timestamp without time zone,
    notary_commission_exprtn_dt timestamp without time zone,
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pdf_url text,
    payee_name_text tsvector,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_sched_e OWNER TO fec;

--
-- Name: fec_fitem_sched_f; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_f (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_desg_coord_exp_ind character varying(1),
    desg_cmte_id character varying(9),
    desg_cmte_nm character varying(200),
    subord_cmte_id character varying(9),
    subord_cmte_nm character varying(200),
    subord_cmte_st1 character varying(34),
    subord_cmte_st2 character varying(34),
    subord_cmte_city character varying(30),
    subord_cmte_st character varying(2),
    subord_cmte_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    pye_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    aggregate_gen_election_exp numeric(14,2),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    exp_purpose_desc character varying(100),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    unlimited_spending_flg character varying(1),
    unlimited_spending_flg_desc character varying(40),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_sched_f OWNER TO fec;

--
-- Name: fec_fitem_sched_h1; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_h1 (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    np_fixed_fed_pct numeric(7,4),
    hsp_min_fed_pct numeric(7,4),
    hsp_est_fed_dir_cand_supp_pct numeric(7,4),
    hsp_est_nonfed_cand_supp_pct numeric(7,4),
    hsp_actl_fed_dir_cand_supp_amt numeric(14,2),
    hsp_actl_nonfed_cand_supp_amt numeric(14,2),
    hsp_actl_fed_dir_cand_supp_pct numeric(7,4),
    ssf_fed_est_dir_cand_supp_pct numeric(7,4),
    ssf_nfed_est_dir_cand_supp_pct numeric(7,4),
    ssf_actl_fed_dir_cand_supp_amt numeric(14,2),
    ssf_actl_nonfed_cand_supp_amt numeric(14,2),
    ssf_actl_fed_dir_cand_supp_pct numeric(7,4),
    president_ind numeric(1,0),
    us_senate_ind numeric(1,0),
    us_congress_ind numeric(1,0),
    subttl_fed numeric(1,0),
    governor_ind numeric(1,0),
    other_st_offices_ind numeric(1,0),
    st_senate_ind numeric(1,0),
    st_rep_ind numeric(1,0),
    local_cand_ind numeric(1,0),
    extra_non_fed_point_ind numeric(1,0),
    subttl_non_fed numeric(2,0),
    ttl_fed_and_nonfed numeric(2,0),
    fed_alloctn numeric(5,0),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    st_loc_pres_only character varying(1),
    st_loc_pres_sen character varying(1),
    st_loc_sen_only character varying(1),
    st_loc_nonpres_nonsen character varying(1),
    flat_min_fed_pct character varying(1),
    fed_pct numeric(5,0),
    non_fed_pct numeric(5,0),
    admin_ratio_chk character varying(1),
    gen_voter_drive_chk character varying(1),
    pub_comm_ref_pty_chk character varying(1),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_sched_h1 OWNER TO fec;

--
-- Name: fec_fitem_sched_h2; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_h2 (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    evt_activity_nm character varying(90),
    fndsg_acty_flg character varying(1),
    exempt_acty_flg character varying(1),
    direct_cand_support_acty_flg character varying(1),
    ratio_cd character varying(1),
    ratio_cd_desc character varying(30),
    fed_pct_amt numeric(7,4),
    nonfed_pct_amt numeric(7,4),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_sched_h2 OWNER TO fec;

--
-- Name: fec_fitem_sched_h3; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_h3 (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    acct_nm character varying(90),
    evt_nm character varying(90),
    evt_tp character varying(2),
    event_tp_desc character varying(50),
    tranf_dt timestamp without time zone,
    tranf_amt numeric(14,2),
    ttl_tranf_amt numeric(14,2),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_sched_h3 OWNER TO fec;

--
-- Name: fec_fitem_sched_h4; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_h4 (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    entity_tp character varying(3),
    entity_tp_desc character varying(30),
    pye_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    evt_purpose_nm character varying(100),
    evt_purpose_desc character varying(38),
    evt_purpose_dt timestamp without time zone,
    ttl_amt_disb numeric(14,2),
    evt_purpose_category_tp character varying(3),
    evt_purpose_category_tp_desc character varying(30),
    fed_share numeric(14,2),
    nonfed_share numeric(14,2),
    admin_voter_drive_acty_ind character varying(1),
    fndrsg_acty_ind character varying(1),
    exempt_acty_ind character varying(1),
    direct_cand_supp_acty_ind character varying(1),
    evt_amt_ytd numeric(14,2),
    add_desc character varying(100),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    admin_acty_ind character varying(1),
    gen_voter_drive_acty_ind character varying(1),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    disb_tp character varying(3),
    disb_tp_desc character varying(90),
    pub_comm_ref_pty_chk character varying(1),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_id character varying(8),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_sched_h4 OWNER TO fec;

--
-- Name: fec_fitem_sched_h5; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_h5 (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    acct_nm character varying(90),
    tranf_dt timestamp without time zone,
    ttl_tranf_amt_voter_reg numeric(14,2),
    ttl_tranf_voter_id numeric(14,2),
    ttl_tranf_gotv numeric(14,2),
    ttl_tranf_gen_campgn_actvy numeric(14,2),
    ttl_tranf_amt numeric(14,2),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_sched_h5 OWNER TO fec;

--
-- Name: fec_fitem_sched_h6; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE fec_fitem_sched_h6 (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(90),
    entity_tp character varying(3),
    pye_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_st_desc character varying(20),
    pye_zip character varying(9),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    disb_purpose character varying(3),
    disb_purpose_cat character varying(100),
    disb_dt timestamp without time zone,
    ttl_amt_disb numeric(14,2),
    fed_share numeric(14,2),
    levin_share numeric(14,2),
    voter_reg_yn_flg character varying(1),
    voter_reg_yn_flg_desc character varying(40),
    voter_id_yn_flg character varying(1),
    voter_id_yn_flg_desc character varying(40),
    gotv_yn_flg character varying(1),
    gotv_yn_flg_desc character varying(40),
    gen_campgn_yn_flg character varying(1),
    gen_campgn_yn_flg_desc character varying(40),
    evt_amt_ytd numeric(14,2),
    add_desc character varying(100),
    fec_committee_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_office character varying(1),
    cand_office_st_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_district numeric(2,0),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_st_desc character varying(20),
    conduit_cmte_zip character varying(9),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_id character varying(8),
    schedule_type character varying(8),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE fec_fitem_sched_h6 OWNER TO fec;

--
-- Name: map_states; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE map_states (
    st_desc character varying(40),
    st character varying(2),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE map_states OWNER TO fec;

--
-- Name: nml_form_1; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_1 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    submit_dt timestamp without time zone,
    cmte_nm_chg_flg character varying(1),
    cmte_addr_chg_flg character varying(1),
    filed_cmte_tp character varying(1),
    filed_cmte_tp_desc character varying(58),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_pty_tp character varying(3),
    cand_pty_tp_desc character varying(90),
    affiliated_cmte_id character varying(9),
    affiliated_cmte_nm character varying(200),
    affiliated_cmte_st1 character varying(34),
    affiliated_cmte_st2 character varying(34),
    affiliated_cmte_city character varying(30),
    affiliated_cmte_st character varying(2),
    affiliated_cmte_zip character varying(9),
    cmte_rltshp character varying(38),
    org_tp character varying(1),
    org_tp_desc character varying(90),
    cust_rec_nm character varying(90),
    cust_rec_st1 character varying(34),
    cust_rec_st2 character varying(34),
    cust_rec_city character varying(30),
    cust_rec_st character varying(2),
    cust_rec_zip character varying(9),
    cust_rec_title character varying(20),
    cust_rec_ph_num character varying(10),
    tres_nm character varying(90),
    tres_st1 character varying(34),
    tres_st2 character varying(34),
    tres_city character varying(30),
    tres_st character varying(2),
    tres_zip character varying(9),
    tres_title character varying(20),
    tres_ph_num character varying(10),
    designated_agent_nm character varying(90),
    designated_agent_st1 character varying(34),
    designated_agent_st2 character varying(34),
    designated_agent_city character varying(30),
    designated_agent_st character varying(2),
    designated_agent_zip character varying(9),
    designated_agent_title character varying(20),
    designated_agent_ph_num character varying(10),
    bank_depository_nm character varying(200),
    bank_depository_st1 character varying(34),
    bank_depository_st2 character varying(34),
    bank_depository_city character varying(30),
    bank_depository_st character varying(2),
    bank_depository_zip character varying(9),
    sec_bank_depository_nm character varying(200),
    sec_bank_depository_st1 character varying(34),
    sec_bank_depository_st2 character varying(34),
    sec_bank_depository_city character varying(30),
    sec_bank_depository_st character varying(2),
    sec_bank_depository_zip character varying(10),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    cmte_email character varying(90),
    cmte_web_url character varying(90),
    receipt_dt timestamp without time zone,
    filed_cmte_dsgn character varying(1),
    filed_cmte_dsgn_desc character varying(90),
    cmte_dsgn_desc character varying(20),
    cmte_class_desc character varying(20),
    cmte_tp_desc character varying(23),
    cmte_subtp_desc character varying(35),
    jntfndrsg_cmte_flg character varying(1),
    filing_freq character varying(1),
    filing_freq_desc character varying(27),
    qual_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    cmte_fax character varying(12),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    leadership_pac character varying(1),
    affiliated_relationship_cd character varying(3),
    efiling_cmte_tp character varying(1),
    cmte_email_chg_flg character varying(1),
    cmte_url_chg_flg character varying(1),
    lobbyist_registrant_pac character varying(1),
    affiliated_cand_id character varying(9),
    affiliated_cand_l_nm character varying(30),
    affiliated_cand_f_nm character varying(20),
    affiliated_cand_m_nm character varying(20),
    affiliated_cand_prefix character varying(10),
    affiliated_cand_suffix character varying(10),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cust_rec_l_nm character varying(30),
    cust_rec_f_nm character varying(20),
    cust_rec_m_nm character varying(20),
    cust_rec_prefix character varying(10),
    cust_rec_suffix character varying(10),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    designated_agent_l_nm character varying(30),
    designated_agent_f_nm character varying(20),
    designated_agent_m_nm character varying(20),
    designated_agent_prefix character varying(10),
    designated_agent_suffix character varying(10),
    f3l_filing_freq character varying(1),
    tres_nm_rlp_flg character varying(1),
    cand_pty_affiliation_rlp_flg character varying(1),
    filed_cmte_dsgn_rlp_flg character varying(1),
    filing_freq_rlp_flg character varying(1),
    org_tp_rlp_flg character varying(1),
    cmte_city_rlp_flg character varying(1),
    cmte_zip_rlp_flg character varying(1),
    cmte_st_rlp_flg character varying(1),
    cmte_st1_st2_rlp_flg character varying(1),
    cmte_nm_rlp_flg character varying(1),
    filed_cmte_tp_rlp_flg character varying(1),
    cmte_email_rlp_flg character varying(1),
    cmte_web_url_rlp_flg character varying(1),
    sign_l_nm character varying(30),
    sign_f_nm character varying(20),
    sign_m_nm character varying(20),
    sign_prefix character varying(10),
    sign_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_1 OWNER TO fec;

--
-- Name: nml_form_10; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_10 (
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    cand_nm character varying(38),
    cand_id character varying(9),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    cmte_nm character varying(90),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(18),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    prev_exp_agg numeric(14,2),
    exp_ttl_this_rpt numeric(14,2),
    exp_ttl_cycl_to_dt numeric(14,2),
    cand_sign_nm character varying(38),
    can_sign_dt timestamp without time zone,
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp_desc character varying(90),
    cand_office_desc character varying(20),
    cand_office_st_desc character varying(20),
    cmte_st_desc character varying(20),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    receipt_dt timestamp without time zone,
    amndt_ind_desc character varying(20),
    amndt_ind character varying(1),
    form_6_chk character varying(1),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    rpt_yr numeric(4,0),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_10 OWNER TO fec;

--
-- Name: nml_form_105; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_105 (
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    exp_dt timestamp without time zone,
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    exp_amt numeric(14,2),
    loan_chk_flg character varying(1),
    amndt_ind character varying(1),
    tran_id character varying(32),
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    receipt_dt timestamp without time zone,
    form_tp_desc character varying(90),
    election_tp_desc character varying(20),
    amndt_ind_desc character varying(15),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_105 OWNER TO fec;

--
-- Name: nml_form_11; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_11 (
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    cand_nm character varying(38),
    cand_id character varying(9),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    cmte_nm character varying(90),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(18),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    oppos_cand_nm character varying(38),
    oppos_cmte_nm character varying(90),
    oppos_cmte_id character varying(9),
    oppos_cmte_st1 character varying(34),
    oppos_cmte_st2 character varying(34),
    oppos_cmte_city character varying(18),
    oppos_cmte_st character varying(2),
    oppos_cmte_zip character varying(9),
    form_10_recpt_dt timestamp without time zone,
    oppos_pers_fund_amt numeric(14,2),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    reg_special_elect_tp character varying(1),
    cand_tres_sign_nm character varying(38),
    cand_tres_sign_dt timestamp without time zone,
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    receipt_dt timestamp without time zone,
    form_tp_desc character varying(90),
    cand_office_desc character varying(20),
    cand_office_st_desc character varying(20),
    cmte_st_desc character varying(20),
    oppos_cmte_st_desc character varying(20),
    election_tp_desc character varying(20),
    reg_special_elect_tp_desc character varying(20),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    cand_last_name character varying(30),
    cand_first_name character varying(20),
    cand_middle_name character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    oppos_cand_last_name character varying(30),
    oppos_cand_first_name character varying(20),
    oppos_cand_middle_name character varying(20),
    oppos_cand_prefix character varying(10),
    oppos_cand_suffix character varying(10),
    cand_tres_last_name character varying(30),
    cand_tres_first_name character varying(20),
    cand_tres_middle_name character varying(20),
    cand_tres_prefix character varying(10),
    cand_tres_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_11 OWNER TO fec;

--
-- Name: nml_form_12; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_12 (
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    cand_nm character varying(38),
    cand_id character varying(9),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    cmte_nm character varying(90),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(18),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    reg_special_elect_tp character varying(1),
    reg_special_elect_tp_desc character varying(20),
    hse_date_reached_100 timestamp without time zone,
    hse_pers_funds_amt numeric(14,2),
    hse_form_11_prev_dt timestamp without time zone,
    sen_date_reached_110 timestamp without time zone,
    sen_pers_funds_amt numeric(14,2),
    sen_form_11_prev_dt timestamp without time zone,
    cand_tres_sign_nm character varying(38),
    cand_tres_sign_dt timestamp without time zone,
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp_desc character varying(90),
    cand_office_desc character varying(20),
    cand_office_st_desc character varying(20),
    cmte_st_desc character varying(20),
    image_tp character varying(10),
    receipt_dt timestamp without time zone,
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    cand_last_name character varying(30),
    cand_first_name character varying(20),
    cand_middle_name character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_tres_last_name character varying(30),
    cand_tres_first_name character varying(20),
    cand_tres_middle_name character varying(20),
    cand_tres_prefix character varying(10),
    cand_tres_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_12 OWNER TO fec;

--
-- Name: nml_form_13; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_13 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    amndt_ind character varying(1),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    cmte_tp character varying(1),
    cmte_tp_desc character varying(40),
    rpt_tp character varying(3),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    ttl_dons_accepted numeric(14,2),
    ttl_dons_refunded numeric(14,2),
    net_dons numeric(14,2),
    desig_officer_last_nm character varying(30),
    desig_officer_first_nm character varying(20),
    desig_officer_middle_nm character varying(20),
    desig_officer_prefix character varying(10),
    desig_officer_suffix character varying(10),
    designated_officer_nm character varying(90),
    receipt_dt timestamp without time zone,
    signature_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_13 OWNER TO fec;

--
-- Name: nml_form_1z; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_1z (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    submit_dt timestamp without time zone,
    cmte_nm_chg_flg character varying(1),
    cmte_addr_chg_flg character varying(1),
    filed_cmte_tp character varying(1),
    filed_cmte_tp_desc character varying(58),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_pty_tp character varying(3),
    cand_pty_tp_desc character varying(90),
    affiliated_cmte_id character varying(9),
    affiliated_cmte_nm character varying(200),
    affiliated_cmte_st1 character varying(34),
    affiliated_cmte_st2 character varying(34),
    affiliated_cmte_city character varying(30),
    affiliated_cmte_st character varying(2),
    affiliated_cmte_zip character varying(9),
    cmte_rltshp character varying(38),
    org_tp character varying(1),
    org_tp_desc character varying(90),
    cust_rec_nm character varying(90),
    cust_rec_st1 character varying(34),
    cust_rec_st2 character varying(34),
    cust_rec_city character varying(30),
    cust_rec_st character varying(2),
    cust_rec_zip character varying(9),
    cust_rec_title character varying(20),
    cust_rec_ph_num character varying(10),
    tres_nm character varying(90),
    tres_st1 character varying(34),
    tres_st2 character varying(34),
    tres_city character varying(30),
    tres_st character varying(2),
    tres_zip character varying(9),
    tres_title character varying(20),
    tres_ph_num character varying(10),
    designated_agent_nm character varying(90),
    designated_agent_st1 character varying(34),
    designated_agent_st2 character varying(34),
    designated_agent_city character varying(30),
    designated_agent_st character varying(2),
    designated_agent_zip character varying(9),
    designated_agent_title character varying(20),
    designated_agent_ph_num character varying(10),
    bank_depository_nm character varying(200),
    bank_depository_st1 character varying(34),
    bank_depository_st2 character varying(34),
    bank_depository_city character varying(30),
    bank_depository_st character varying(2),
    bank_depository_zip character varying(9),
    sec_bank_depository_nm character varying(200),
    sec_bank_depository_st1 character varying(34),
    sec_bank_depository_st2 character varying(34),
    sec_bank_depository_city character varying(30),
    sec_bank_depository_st character varying(2),
    sec_bank_depository_zip character varying(10),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    cmte_email character varying(90),
    cmte_web_url character varying(90),
    receipt_dt timestamp without time zone,
    filed_cmte_dsgn character varying(1),
    filed_cmte_dsgn_desc character varying(90),
    cmte_dsgn_desc character varying(20),
    cmte_class_desc character varying(20),
    cmte_tp_desc character varying(23),
    cmte_subtp_desc character varying(35),
    jntfndrsg_cmte_flg character varying(1),
    filing_freq character varying(1),
    filing_freq_desc character varying(27),
    qual_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    cmte_fax character varying(12),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    leadership_pac character varying(1),
    affiliated_relationship_cd character varying(3),
    efiling_cmte_tp character varying(1),
    cmte_email_chg_flg character varying(1),
    cmte_url_chg_flg character varying(1),
    lobbyist_registrant_pac character varying(1),
    affiliated_cand_id character varying(9),
    affiliated_cand_l_nm character varying(30),
    affiliated_cand_f_nm character varying(20),
    affiliated_cand_m_nm character varying(20),
    affiliated_cand_prefix character varying(10),
    affiliated_cand_suffix character varying(10),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cust_rec_l_nm character varying(30),
    cust_rec_f_nm character varying(20),
    cust_rec_m_nm character varying(20),
    cust_rec_prefix character varying(10),
    cust_rec_suffix character varying(10),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    designated_agent_l_nm character varying(30),
    designated_agent_f_nm character varying(20),
    designated_agent_m_nm character varying(20),
    designated_agent_prefix character varying(10),
    designated_agent_suffix character varying(10),
    f3l_filing_freq character varying(1),
    tres_nm_rlp_flg character varying(1),
    cand_pty_affiliation_rlp_flg character varying(1),
    filed_cmte_dsgn_rlp_flg character varying(1),
    filing_freq_rlp_flg character varying(1),
    org_tp_rlp_flg character varying(1),
    cmte_city_rlp_flg character varying(1),
    cmte_zip_rlp_flg character varying(1),
    cmte_st_rlp_flg character varying(1),
    cmte_st1_st2_rlp_flg character varying(1),
    cmte_nm_rlp_flg character varying(1),
    filed_cmte_tp_rlp_flg character varying(1),
    cmte_email_rlp_flg character varying(1),
    cmte_web_url_rlp_flg character varying(1),
    sign_l_nm character varying(30),
    sign_f_nm character varying(20),
    sign_m_nm character varying(20),
    sign_prefix character varying(10),
    sign_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_1z OWNER TO fec;

--
-- Name: nml_form_1_1z_view; Type: VIEW; Schema: disclosure; Owner: fec
--

CREATE VIEW nml_form_1_1z_view AS
 SELECT a.sub_id,
    a.begin_image_num,
    a.end_image_num,
    a.form_tp,
    a.form_tp_desc,
    a.amndt_ind,
    a.amndt_ind_desc,
    a.cmte_id,
    a.cmte_nm,
    a.cmte_st1,
    a.cmte_st2,
    a.cmte_city,
    a.cmte_st,
    a.cmte_zip,
    a.submit_dt,
    a.cmte_nm_chg_flg,
    a.cmte_addr_chg_flg,
    a.filed_cmte_tp,
    a.filed_cmte_tp_desc,
    a.cand_id,
    a.cand_nm,
    a.cand_nm_first,
    a.cand_nm_last,
    a.cand_office,
    a.cand_office_desc,
    a.cand_office_st,
    a.cand_office_st_desc,
    a.cand_office_district,
    a.cand_pty_affiliation,
    a.cand_pty_affiliation_desc,
    a.cand_pty_tp,
    a.cand_pty_tp_desc,
    a.affiliated_cmte_id,
    a.affiliated_cmte_nm,
    a.affiliated_cmte_st1,
    a.affiliated_cmte_st2,
    a.affiliated_cmte_city,
    a.affiliated_cmte_st,
    a.affiliated_cmte_zip,
    a.cmte_rltshp,
    a.org_tp,
    a.org_tp_desc,
    a.cust_rec_nm,
    a.cust_rec_st1,
    a.cust_rec_st2,
    a.cust_rec_city,
    a.cust_rec_st,
    a.cust_rec_zip,
    a.cust_rec_title,
    a.cust_rec_ph_num,
    a.tres_nm,
    a.tres_st1,
    a.tres_st2,
    a.tres_city,
    a.tres_st,
    a.tres_zip,
    a.tres_title,
    a.tres_ph_num,
    a.designated_agent_nm,
    a.designated_agent_st1,
    a.designated_agent_st2,
    a.designated_agent_city,
    a.designated_agent_st,
    a.designated_agent_zip,
    a.designated_agent_title,
    a.designated_agent_ph_num,
    a.bank_depository_nm,
    a.bank_depository_st1,
    a.bank_depository_st2,
    a.bank_depository_city,
    a.bank_depository_st,
    a.bank_depository_zip,
    a.sec_bank_depository_nm,
    a.sec_bank_depository_st1,
    a.sec_bank_depository_st2,
    a.sec_bank_depository_city,
    a.sec_bank_depository_st,
    a.sec_bank_depository_zip,
    a.tres_sign_nm,
    a.tres_sign_dt,
    a.cmte_email,
    a.cmte_web_url,
    a.receipt_dt,
    a.filed_cmte_dsgn,
    a.filed_cmte_dsgn_desc,
    a.cmte_dsgn_desc,
    a.cmte_class_desc,
    a.cmte_tp_desc,
    a.cmte_subtp_desc,
    a.jntfndrsg_cmte_flg,
    a.filing_freq,
    a.filing_freq_desc,
    a.qual_dt,
    a.image_tp,
    a.load_status,
    a.last_update_dt,
    a.delete_ind,
    a.leadership_pac,
    a.lobbyist_registrant_pac,
    a.f3l_filing_freq
   FROM nml_form_1 a
UNION
 SELECT z.sub_id,
    z.begin_image_num,
    z.end_image_num,
    z.form_tp,
    z.form_tp_desc,
    z.amndt_ind,
    z.amndt_ind_desc,
    z.cmte_id,
    z.cmte_nm,
    z.cmte_st1,
    z.cmte_st2,
    z.cmte_city,
    z.cmte_st,
    z.cmte_zip,
    z.submit_dt,
    z.cmte_nm_chg_flg,
    z.cmte_addr_chg_flg,
    z.filed_cmte_tp,
    z.filed_cmte_tp_desc,
    z.cand_id,
    z.cand_nm,
    z.cand_nm_first,
    z.cand_nm_last,
    z.cand_office,
    z.cand_office_desc,
    z.cand_office_st,
    z.cand_office_st_desc,
    z.cand_office_district,
    z.cand_pty_affiliation,
    z.cand_pty_affiliation_desc,
    z.cand_pty_tp,
    z.cand_pty_tp_desc,
    z.affiliated_cmte_id,
    z.affiliated_cmte_nm,
    z.affiliated_cmte_st1,
    z.affiliated_cmte_st2,
    z.affiliated_cmte_city,
    z.affiliated_cmte_st,
    z.affiliated_cmte_zip,
    z.cmte_rltshp,
    z.org_tp,
    z.org_tp_desc,
    z.cust_rec_nm,
    z.cust_rec_st1,
    z.cust_rec_st2,
    z.cust_rec_city,
    z.cust_rec_st,
    z.cust_rec_zip,
    z.cust_rec_title,
    z.cust_rec_ph_num,
    z.tres_nm,
    z.tres_st1,
    z.tres_st2,
    z.tres_city,
    z.tres_st,
    z.tres_zip,
    z.tres_title,
    z.tres_ph_num,
    z.designated_agent_nm,
    z.designated_agent_st1,
    z.designated_agent_st2,
    z.designated_agent_city,
    z.designated_agent_st,
    z.designated_agent_zip,
    z.designated_agent_title,
    z.designated_agent_ph_num,
    z.bank_depository_nm,
    z.bank_depository_st1,
    z.bank_depository_st2,
    z.bank_depository_city,
    z.bank_depository_st,
    z.bank_depository_zip,
    z.sec_bank_depository_nm,
    z.sec_bank_depository_st1,
    z.sec_bank_depository_st2,
    z.sec_bank_depository_city,
    z.sec_bank_depository_st,
    z.sec_bank_depository_zip,
    z.tres_sign_nm,
    z.tres_sign_dt,
    z.cmte_email,
    z.cmte_web_url,
    z.receipt_dt,
    z.filed_cmte_dsgn,
    z.filed_cmte_dsgn_desc,
    z.cmte_dsgn_desc,
    z.cmte_class_desc,
    z.cmte_tp_desc,
    z.cmte_subtp_desc,
    z.jntfndrsg_cmte_flg,
    z.filing_freq,
    z.filing_freq_desc,
    z.qual_dt,
    z.image_tp,
    z.load_status,
    z.last_update_dt,
    z.delete_ind,
    z.leadership_pac,
    z.lobbyist_registrant_pac,
    z.f3l_filing_freq
   FROM nml_form_1z z;


ALTER TABLE nml_form_1_1z_view OWNER TO fec;

--
-- Name: nml_form_1m; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_1m (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_tp character varying(1),
    cmte_tp_desc character varying(58),
    affiliation_dt timestamp without time zone,
    affiliated_cmte_id character varying(9),
    affiliated_cmte_nm character varying(200),
    fst_cand_id character varying(9),
    fst_cand_nm character varying(90),
    fst_cand_office character varying(1),
    fst_cand_office_desc character varying(20),
    fst_cand_office_st character varying(2),
    fst_cand_office_st_desc character varying(20),
    fst_cand_office_district character varying(2),
    fst_cand_contb_dt timestamp without time zone,
    sec_cand_id character varying(9),
    sec_cand_nm character varying(90),
    sec_cand_office character varying(1),
    sec_cand_office_desc character varying(20),
    sec_cand_office_st character varying(2),
    sec_cand_office_st_desc character varying(20),
    sec_cand_office_district character varying(2),
    sec_cand_contb_dt timestamp without time zone,
    trd_cand_id character varying(9),
    trd_cand_nm character varying(90),
    trd_cand_office character varying(1),
    trd_cand_office_desc character varying(20),
    trd_cand_office_st character varying(2),
    trd_cand_office_st_desc character varying(20),
    trd_cand_office_district character varying(2),
    trd_cand_contb_dt timestamp without time zone,
    frth_cand_id character varying(9),
    frth_cand_nm character varying(90),
    frth_cand_office character varying(1),
    frth_cand_office_desc character varying(20),
    frth_cand_office_st character varying(2),
    frth_cand_office_st_desc character varying(20),
    frth_cand_office_district character varying(2),
    frth_cand_contb_dt timestamp without time zone,
    fith_cand_id character varying(9),
    fith_cand_nm character varying(90),
    fith_cand_office character varying(1),
    fith_cand_office_desc character varying(20),
    fith_cand_office_st character varying(2),
    fith_cand_office_st_desc character varying(20),
    fith_cand_office_district character varying(2),
    fith_cand_contb_dt timestamp without time zone,
    fiftyfirst_cand_contbr_dt timestamp without time zone,
    orig_registration_dt timestamp without time zone,
    qual_dt timestamp without time zone,
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    fst_cand_l_nm character varying(30),
    fst_cand_f_nm character varying(20),
    fst_cand_m_nm character varying(20),
    fst_cand_prefix character varying(10),
    fst_cand_suffix character varying(10),
    sec_cand_l_nm character varying(30),
    sec_cand_f_nm character varying(20),
    sec_cand_m_nm character varying(20),
    sec_cand_prefix character varying(10),
    sec_cand_suffix character varying(10),
    trd_cand_l_nm character varying(30),
    trd_cand_f_nm character varying(20),
    trd_cand_m_nm character varying(20),
    trd_cand_prefix character varying(10),
    trd_cand_suffix character varying(10),
    frth_cand_l_nm character varying(30),
    frth_cand_f_nm character varying(20),
    frth_cand_m_nm character varying(20),
    frth_cand_prefix character varying(10),
    frth_cand_suffix character varying(10),
    fith_cand_l_nm character varying(30),
    fith_cand_f_nm character varying(20),
    fith_cand_m_nm character varying(20),
    fith_cand_prefix character varying(10),
    fith_cand_suffix character varying(10),
    tres_sign_l_nm character varying(30),
    tres_sign_f_nm character varying(20),
    tres_sign_m_nm character varying(20),
    tres_sign_prefix character varying(10),
    tres_sign_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_1m OWNER TO fec;

--
-- Name: nml_form_1s; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_1s (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cmte_id character varying(9),
    affiliated_cmte_id character varying(9),
    affiliated_cmte_nm character varying(200),
    affiliated_cmte_st1 character varying(34),
    affiliated_cmte_st2 character varying(34),
    affiliated_cmte_city character varying(30),
    affiliated_cmte_st character varying(2),
    affiliated_cmte_zip character varying(9),
    cmte_rltshp character varying(38),
    org_tp character varying(1),
    org_tp_desc character varying(90),
    designated_agent_nm character varying(90),
    designated_agent_st1 character varying(34),
    designated_agent_st2 character varying(34),
    designated_agent_city character varying(30),
    designated_agent_st character varying(2),
    designated_agent_zip character varying(9),
    designated_agent_title character varying(20),
    designated_agent_ph_num character varying(10),
    bank_depository_nm character varying(200),
    bank_depository_st1 character varying(34),
    bank_depository_st2 character varying(34),
    bank_depository_city character varying(30),
    bank_depository_st character varying(2),
    bank_depository_zip character varying(9),
    receipt_dt timestamp without time zone,
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    image_tp character varying(10),
    joint_cmte_nm character varying(200),
    joint_cmte_id character varying(9),
    affiliated_relationship_cd character varying(3),
    affiliated_cand_id character varying(9),
    affiliated_cand_l_nm character varying(30),
    affiliated_cand_f_nm character varying(20),
    affiliated_cand_m_nm character varying(20),
    affiliated_cand_prefix character varying(10),
    affiliated_cand_suffix character varying(10),
    designated_agent_l_nm character varying(30),
    designated_agent_f_nm character varying(20),
    designated_agent_m_nm character varying(20),
    designated_agent_prefix character varying(10),
    designated_agent_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_1s OWNER TO fec;

--
-- Name: nml_form_2; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_2 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_st character varying(2),
    cand_zip character varying(9),
    addr_chg_flg character varying(1),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    election_yr numeric(4,0),
    pcc_cmte_id character varying(9),
    pcc_cmte_nm character varying(200),
    pcc_cmte_st1 character varying(34),
    pcc_cmte_st2 character varying(34),
    pcc_cmte_city character varying(30),
    pcc_cmte_st character varying(2),
    pcc_cmte_zip character varying(9),
    addl_auth_cmte_id character varying(9),
    addl_auth_cmte_nm character varying(200),
    addl_auth_cmte_st1 character varying(34),
    addl_auth_cmte_st2 character varying(34),
    addl_auth_cmte_city character varying(30),
    addl_auth_cmte_st character varying(2),
    addl_auth_cmte_zip character varying(9),
    cand_sign_nm character varying(90),
    cand_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    party_cd character varying(1),
    party_cd_desc character varying(33),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cand_ici character varying(1),
    cand_ici_desc character varying(15),
    cand_status character varying(1),
    cand_status_desc character varying(40),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    prim_pers_funds_decl numeric(14,2),
    gen_pers_funds_decl numeric(14,2),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_sign_l_nm character varying(30),
    cand_sign_f_nm character varying(20),
    cand_sign_m_nm character varying(20),
    cand_sign_prefix character varying(10),
    cand_sign_suffix character varying(10),
    vice_pres_nm character varying(90),
    vice_pres_l_nm character varying(30),
    vice_pres_f_nm character varying(20),
    vice_pres_m_nm character varying(20),
    vice_pres_prefix character varying(10),
    vice_pres_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_2 OWNER TO fec;

--
-- Name: nml_form_24; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_24 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    amndt_ind character varying(1),
    orig_amndt_dt timestamp without time zone,
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_24 OWNER TO fec;

--
-- Name: nml_form_2z; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_2z (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_st character varying(2),
    cand_zip character varying(9),
    addr_chg_flg character varying(1),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    election_yr numeric(4,0),
    pcc_cmte_id character varying(9),
    pcc_cmte_nm character varying(200),
    pcc_cmte_st1 character varying(34),
    pcc_cmte_st2 character varying(34),
    pcc_cmte_city character varying(30),
    pcc_cmte_st character varying(2),
    pcc_cmte_zip character varying(9),
    addl_auth_cmte_id character varying(9),
    addl_auth_cmte_nm character varying(200),
    addl_auth_cmte_st1 character varying(34),
    addl_auth_cmte_st2 character varying(34),
    addl_auth_cmte_city character varying(30),
    addl_auth_cmte_st character varying(2),
    addl_auth_cmte_zip character varying(9),
    cand_sign_nm character varying(90),
    cand_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    party_cd character varying(1),
    party_cd_desc character varying(33),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cand_ici character varying(1),
    cand_ici_desc character varying(15),
    cand_status character varying(1),
    cand_status_desc character varying(40),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_sign_l_nm character varying(30),
    cand_sign_f_nm character varying(20),
    cand_sign_m_nm character varying(20),
    cand_sign_prefix character varying(10),
    cand_sign_suffix character varying(10),
    vice_pres_nm character varying(90),
    vice_pres_l_nm character varying(30),
    vice_pres_f_nm character varying(20),
    vice_pres_m_nm character varying(20),
    vice_pres_prefix character varying(10),
    vice_pres_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_2z OWNER TO fec;

--
-- Name: nml_form_2_2z_view; Type: VIEW; Schema: disclosure; Owner: fec
--

CREATE VIEW nml_form_2_2z_view AS
 SELECT a.sub_id,
    a.begin_image_num,
    a.end_image_num,
    a.form_tp,
    a.form_tp_desc,
    a.cand_id,
    a.cand_nm,
    a.cand_nm_first,
    a.cand_nm_last,
    a.cand_st1,
    a.cand_st2,
    a.cand_city,
    a.cand_st,
    a.cand_zip,
    a.addr_chg_flg,
    a.cand_pty_affiliation,
    a.cand_pty_affiliation_desc,
    a.cand_office,
    a.cand_office_desc,
    a.cand_office_st,
    a.cand_office_st_desc,
    a.cand_office_district,
    a.election_yr,
    a.pcc_cmte_id,
    a.pcc_cmte_nm,
    a.pcc_cmte_st1,
    a.pcc_cmte_st2,
    a.pcc_cmte_city,
    a.pcc_cmte_st,
    a.pcc_cmte_zip,
    a.addl_auth_cmte_id,
    a.addl_auth_cmte_nm,
    a.addl_auth_cmte_st1,
    a.addl_auth_cmte_st2,
    a.addl_auth_cmte_city,
    a.addl_auth_cmte_st,
    a.addl_auth_cmte_zip,
    a.cand_sign_nm,
    a.cand_sign_dt,
    a.receipt_dt,
    a.party_cd,
    a.party_cd_desc,
    COALESCE(a.amndt_ind, 'A'::character varying) AS amndt_ind,
    a.amndt_ind_desc,
    a.cand_ici,
    a.cand_ici_desc,
    a.cand_status,
    a.cand_status_desc,
    a.image_tp,
    a.load_status,
    a.last_update_dt,
    a.delete_ind
   FROM nml_form_2 a
  WHERE (a.delete_ind IS NULL)
UNION
 SELECT a.sub_id,
    a.begin_image_num,
    a.end_image_num,
    a.form_tp,
    a.form_tp_desc,
    a.cand_id,
    a.cand_nm,
    a.cand_nm_first,
    a.cand_nm_last,
    a.cand_st1,
    a.cand_st2,
    a.cand_city,
    a.cand_st,
    a.cand_zip,
    a.addr_chg_flg,
    a.cand_pty_affiliation,
    a.cand_pty_affiliation_desc,
    a.cand_office,
    a.cand_office_desc,
    a.cand_office_st,
    a.cand_office_st_desc,
    a.cand_office_district,
    a.election_yr,
    a.pcc_cmte_id,
    a.pcc_cmte_nm,
    a.pcc_cmte_st1,
    a.pcc_cmte_st2,
    a.pcc_cmte_city,
    a.pcc_cmte_st,
    a.pcc_cmte_zip,
    a.addl_auth_cmte_id,
    a.addl_auth_cmte_nm,
    a.addl_auth_cmte_st1,
    a.addl_auth_cmte_st2,
    a.addl_auth_cmte_city,
    a.addl_auth_cmte_st,
    a.addl_auth_cmte_zip,
    a.cand_sign_nm,
    a.cand_sign_dt,
    a.receipt_dt,
    a.party_cd,
    a.party_cd_desc,
    COALESCE(a.amndt_ind, 'A'::character varying) AS amndt_ind,
    a.amndt_ind_desc,
    a.cand_ici,
    a.cand_ici_desc,
    a.cand_status,
    a.cand_status_desc,
    a.image_tp,
    a.load_status,
    a.last_update_dt,
    a.delete_ind
   FROM nml_form_2z a
  WHERE (a.delete_ind IS NULL)
  ORDER BY 6, 51;


ALTER TABLE nml_form_2_2z_view OWNER TO fec;

--
-- Name: nml_form_2_bk; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_2_bk (
    sub_id numeric(19,0),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_st character varying(2),
    cand_zip character varying(9),
    addr_chg_flg character varying(1),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    election_yr numeric(4,0),
    pcc_cmte_id character varying(9),
    pcc_cmte_nm character varying(200),
    pcc_cmte_st1 character varying(34),
    pcc_cmte_st2 character varying(34),
    pcc_cmte_city character varying(30),
    pcc_cmte_st character varying(2),
    pcc_cmte_zip character varying(9),
    addl_auth_cmte_id character varying(9),
    addl_auth_cmte_nm character varying(200),
    addl_auth_cmte_st1 character varying(34),
    addl_auth_cmte_st2 character varying(34),
    addl_auth_cmte_city character varying(30),
    addl_auth_cmte_st character varying(2),
    addl_auth_cmte_zip character varying(9),
    cand_sign_nm character varying(90),
    cand_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    party_cd character varying(1),
    party_cd_desc character varying(33),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cand_ici character varying(1),
    cand_ici_desc character varying(15),
    cand_status character varying(1),
    cand_status_desc character varying(40),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    prim_pers_funds_decl numeric(14,2),
    gen_pers_funds_decl numeric(14,2),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_sign_l_nm character varying(30),
    cand_sign_f_nm character varying(20),
    cand_sign_m_nm character varying(20),
    cand_sign_prefix character varying(10),
    cand_sign_suffix character varying(10),
    pg_date timestamp without time zone
);


ALTER TABLE nml_form_2_bk OWNER TO fec;

--
-- Name: nml_form_2s; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_2s (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    begin_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cand_id character varying(9),
    auth_cmte_id character varying(9),
    auth_cmte_nm character varying(200),
    auth_cmte_st1 character varying(34),
    auth_cmte_st2 character varying(34),
    auth_cmte_city character varying(30),
    auth_cmte_st character varying(2),
    auth_cmte_zip character varying(9),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    delete_ind numeric(1,0),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    image_tp character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_2s OWNER TO fec;

--
-- Name: nml_form_2z_bk; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_2z_bk (
    sub_id numeric(19,0),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_st character varying(2),
    cand_zip character varying(9),
    addr_chg_flg character varying(1),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    election_yr numeric(4,0),
    pcc_cmte_id character varying(9),
    pcc_cmte_nm character varying(200),
    pcc_cmte_st1 character varying(34),
    pcc_cmte_st2 character varying(34),
    pcc_cmte_city character varying(30),
    pcc_cmte_st character varying(2),
    pcc_cmte_zip character varying(9),
    addl_auth_cmte_id character varying(9),
    addl_auth_cmte_nm character varying(200),
    addl_auth_cmte_st1 character varying(34),
    addl_auth_cmte_st2 character varying(34),
    addl_auth_cmte_city character varying(30),
    addl_auth_cmte_st character varying(2),
    addl_auth_cmte_zip character varying(9),
    cand_sign_nm character varying(90),
    cand_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    party_cd character varying(1),
    party_cd_desc character varying(33),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cand_ici character varying(1),
    cand_ici_desc character varying(15),
    cand_status character varying(1),
    cand_status_desc character varying(40),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_sign_l_nm character varying(30),
    cand_sign_f_nm character varying(20),
    cand_sign_m_nm character varying(20),
    cand_sign_prefix character varying(10),
    cand_sign_suffix character varying(10),
    pg_date timestamp without time zone
);


ALTER TABLE nml_form_2z_bk OWNER TO fec;

--
-- Name: nml_form_3; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_3 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    cmte_election_st character varying(2),
    cmte_election_st_desc character varying(20),
    cmte_election_district character varying(2),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(5),
    rpt_pgi_desc character varying(10),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    primary_election character varying(1),
    general_election character varying(1),
    special_election character varying(1),
    runoff_election character varying(1),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    ttl_contb_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    net_contb_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    net_op_exp_per numeric(14,2),
    coh_cop_i numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    ttl_indv_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_column_ttl_per numeric(14,2),
    tranf_from_other_auth_cmte_per numeric(14,2),
    loans_made_by_cand_per numeric(14,2),
    all_other_loans_per numeric(14,2),
    ttl_loans_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    ttl_receipts_per_i numeric(14,2),
    op_exp_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    loan_repymts_cand_loans_per numeric(14,2),
    loan_repymts_other_loans_per numeric(14,2),
    ttl_loan_repymts_per numeric(14,2),
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    ttl_contb_ref_col_ttl_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per_i numeric(14,2),
    coh_bop numeric(14,2),
    ttl_receipts_ii numeric(14,2),
    subttl_per numeric(14,2),
    ttl_disb_per_ii numeric(14,2),
    coh_cop_ii numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd numeric(14,2),
    net_contb_ytd numeric(14,2),
    ttl_op_exp_ytd numeric(14,2),
    ttl_offsets_to_op_exp_ytd numeric(14,2),
    net_op_exp_ytd numeric(14,2),
    ttl_indv_item_contb_ytd numeric(14,2),
    ttl_indv_unitem_contb_ytd numeric(14,2),
    ttl_indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd numeric(14,2),
    other_pol_cmte_contb_ytd numeric(14,2),
    cand_contb_ytd numeric(14,2),
    ttl_contb_col_ttl_ytd numeric(14,2),
    tranf_from_other_auth_cmte_ytd numeric(14,2),
    loans_made_by_cand_ytd numeric(14,2),
    all_other_loans_ytd numeric(14,2),
    ttl_loans_ytd numeric(14,2),
    offsets_to_op_exp_ytd numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    op_exp_ytd numeric(14,2),
    tranf_to_other_auth_cmte_ytd numeric(14,2),
    loan_repymts_cand_loans_ytd numeric(14,2),
    loan_repymts_other_loans_ytd numeric(14,2),
    ttl_loan_repymts_ytd numeric(14,2),
    ref_indv_contb_ytd numeric(14,2),
    ref_pol_pty_cmte_contb_ytd numeric(14,2),
    ref_other_pol_cmte_contb_ytd numeric(14,2),
    ref_ttl_contb_col_ttl_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    grs_rcpt_auth_cmte_prim numeric(14,2),
    agr_amt_contrib_pers_fund_prim numeric(14,2),
    grs_rcpt_min_pers_contrib_prim numeric(14,2),
    grs_rcpt_auth_cmte_gen numeric(14,2),
    agr_amt_pers_contrib_gen numeric(14,2),
    grs_rcpt_min_pers_contrib_gen numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    f3z1_rpt_tp character varying(3),
    f3z1_rpt_tp_desc character varying(30),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_3 OWNER TO fec;

--
-- Name: nml_form_3l; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_3l (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    cmte_election_st character varying(2),
    cmte_election_st_desc character varying(20),
    cmte_election_district character varying(2),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(5),
    rpt_pgi_desc character varying(10),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    semi_an_per_5c_5d character varying(1),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    semi_an_jan_jun_6b character varying(1),
    semi_an_jul_dec_6b character varying(1),
    qtr_mon_bundled_contb numeric(14,2),
    semi_an_bundled_contb numeric(14,2),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    tres_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_3l OWNER TO fec;

--
-- Name: nml_form_3p; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_3p (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    addr_chg_flg character varying(1),
    activity_primary character varying(1),
    activity_general character varying(1),
    term_rpt_flag character varying(1),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(5),
    rpt_pgi_desc character varying(10),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    indv_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    op_exp_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    fndrsg_disb_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    alabama_per numeric(14,2),
    alaska_per numeric(14,2),
    arizona_per numeric(14,2),
    arkansas_per numeric(14,2),
    california_per numeric(14,2),
    colorado_per numeric(14,2),
    connecticut_per numeric(14,2),
    delaware_per numeric(14,2),
    district_columbia_per numeric(14,2),
    florida_per numeric(14,2),
    georgia_per numeric(14,2),
    hawaii_per numeric(14,2),
    idaho_per numeric(14,2),
    illinois_per numeric(14,2),
    indiana_per numeric(14,2),
    iowa_per numeric(14,2),
    kansas_per numeric(14,2),
    kentucky_per numeric(14,2),
    louisiana_per numeric(14,2),
    maine_per numeric(14,2),
    maryland_per numeric(14,2),
    massachusetts_per numeric(14,2),
    michigan_per numeric(14,2),
    minnesota_per numeric(14,2),
    mississippi_per numeric(14,2),
    missouri_per numeric(14,2),
    montana_per numeric(14,2),
    nebraska_per numeric(14,2),
    nevada_per numeric(14,2),
    new_hampshire_per numeric(14,2),
    new_jersey_per numeric(14,2),
    new_mexico_per numeric(14,2),
    new_york_per numeric(14,2),
    north_carolina_per numeric(14,2),
    north_dakota_per numeric(14,2),
    ohio_per numeric(14,2),
    oklahoma_per numeric(14,2),
    oregon_per numeric(14,2),
    pennsylvania_per numeric(14,2),
    rhode_island_per numeric(14,2),
    south_carolina_per numeric(14,2),
    south_dakota_per numeric(14,2),
    tennessee_per numeric(14,2),
    texas_per numeric(14,2),
    utah_per numeric(14,2),
    vermont_per numeric(14,2),
    virginia_per numeric(14,2),
    washington_per numeric(14,2),
    west_virginia_per numeric(14,2),
    wisconsin_per numeric(14,2),
    wyoming_per numeric(14,2),
    puerto_rico_per numeric(14,2),
    guam_per numeric(14,2),
    virgin_islands_per numeric(14,2),
    ttl_per numeric(14,2),
    fed_funds_ytd numeric(14,2),
    indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd numeric(14,2),
    other_pol_cmte_contb_ytd numeric(14,2),
    cand_contb_ytd numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    tranf_from_affiliated_cmte_ytd numeric(14,2),
    loans_received_from_cand_ytd numeric(14,2),
    other_loans_received_ytd numeric(14,2),
    ttl_loans_received_ytd numeric(14,2),
    offsets_to_op_exp_ytd numeric(14,2),
    offsets_to_fndrsg_exp_ytd numeric(14,2),
    offsets_to_legal_acctg_ytd numeric(14,2),
    ttl_offsets_to_op_exp_ytd numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    op_exp_ytd numeric(14,2),
    tranf_to_other_auth_cmte_ytd numeric(14,2),
    fndrsg_disb_ytd numeric(14,2),
    exempt_legal_acctg_disb_ytd numeric(14,2),
    repymts_loans_made_cand_ytd numeric(14,2),
    repymts_other_loans_ytd numeric(14,2),
    ttl_loan_repymts_made_ytd numeric(14,2),
    ref_indv_contb_ytd numeric(14,2),
    ref_pol_pty_cmte_contb_ytd numeric(14,2),
    ref_other_pol_cmte_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    alabama_ytd numeric(14,2),
    alaska_ytd numeric(14,2),
    arizona_ytd numeric(14,2),
    arkansas_ytd numeric(14,2),
    california_ytd numeric(14,2),
    colorado_ytd numeric(14,2),
    connecticut_ytd numeric(14,2),
    delaware_ytd numeric(14,2),
    district_columbia_ytd numeric(14,2),
    florida_ytd numeric(14,2),
    georgia_ytd numeric(14,2),
    hawaii_ytd numeric(14,2),
    idaho_ytd numeric(14,2),
    illinois_ytd numeric(14,2),
    indiana_ytd numeric(14,2),
    iowa_ytd numeric(14,2),
    kansas_ytd numeric(14,2),
    kentucky_ytd numeric(14,2),
    louisiana_ytd numeric(14,2),
    maine_ytd numeric(14,2),
    maryland_ytd numeric(14,2),
    massachusetts_ytd numeric(14,2),
    michigan_ytd numeric(14,2),
    minnesota_ytd numeric(14,2),
    mississippi_ytd numeric(14,2),
    missouri_ytd numeric(14,2),
    montana_ytd numeric(14,2),
    nebraska_ytd numeric(14,2),
    nevada_ytd numeric(14,2),
    new_hampshire_ytd numeric(14,2),
    new_jersey_ytd numeric(14,2),
    new_mexico_ytd numeric(14,2),
    new_york_ytd numeric(14,2),
    north_carolina_ytd numeric(14,2),
    north_dakota_ytd numeric(14,2),
    ohio_ytd numeric(14,2),
    oklahoma_ytd numeric(14,2),
    oregon_ytd numeric(14,2),
    pennsylvania_ytd numeric(14,2),
    rhode_island_ytd numeric(14,2),
    south_carolina_ytd numeric(14,2),
    south_dakota_ytd numeric(14,2),
    tennessee_ytd numeric(14,2),
    texas_ytd numeric(14,2),
    utah_ytd numeric(14,2),
    vermont_ytd numeric(14,2),
    virginia_ytd numeric(14,2),
    washington_ytd numeric(14,2),
    west_virginia_ytd numeric(14,2),
    wisconsin_ytd numeric(14,2),
    wyoming_ytd numeric(14,2),
    puerto_rico_ytd numeric(14,2),
    guam_ytd numeric(14,2),
    virgin_islands_ytd numeric(14,2),
    ttl_ytd numeric(14,2),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    rpt_yr numeric(4,0),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    indv_item_contb_ytd numeric(14,2),
    indv_unitem_contb_ytd numeric(14,2),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_3p OWNER TO fec;

--
-- Name: nml_form_3ps; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_3ps (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    alabama numeric(14,2),
    alaska numeric(14,2),
    arizona numeric(14,2),
    arkansas numeric(14,2),
    california numeric(14,2),
    colorado numeric(14,2),
    connecticut numeric(14,2),
    delaware numeric(14,2),
    district_columbia numeric(14,2),
    florida numeric(14,2),
    georgia numeric(14,2),
    hawaii numeric(14,2),
    idaho numeric(14,2),
    illinois numeric(14,2),
    indiana numeric(14,2),
    iowa numeric(14,2),
    kansas numeric(14,2),
    kentucky numeric(14,2),
    louisiana numeric(14,2),
    maine numeric(14,2),
    maryland numeric(14,2),
    massachusetts numeric(14,2),
    michigan numeric(14,2),
    minnesota numeric(14,2),
    mississippi numeric(14,2),
    missouri numeric(14,2),
    montana numeric(14,2),
    nebraska numeric(14,2),
    nevada numeric(14,2),
    new_hampshire numeric(14,2),
    new_jersey numeric(14,2),
    new_mexico numeric(14,2),
    new_york numeric(14,2),
    north_carolina numeric(14,2),
    north_dakota numeric(14,2),
    ohio numeric(14,2),
    oklahoma numeric(14,2),
    oregon numeric(14,2),
    pennsylvania numeric(14,2),
    rhode_island numeric(14,2),
    south_carolina numeric(14,2),
    south_dakota numeric(14,2),
    tennessee numeric(14,2),
    texas numeric(14,2),
    utah numeric(14,2),
    vermont numeric(14,2),
    virginia numeric(14,2),
    washington numeric(14,2),
    west_virginia numeric(14,2),
    wisconsin numeric(14,2),
    wyoming numeric(14,2),
    puerto_rico numeric(14,2),
    guam numeric(14,2),
    virgin_islands numeric(14,2),
    ttl numeric(14,2),
    election_dt timestamp without time zone,
    day_after_election_dt timestamp without time zone,
    net_contb numeric(14,2),
    net_exp numeric(14,2),
    fed_funds numeric(14,2),
    indv_contb numeric(14,2),
    pol_pty_cmte_contb numeric(14,2),
    pac_contb numeric(14,2),
    cand_contb numeric(14,2),
    ttl_contb numeric(14,2),
    tranf_from_affiliated_cmte numeric(14,2),
    loans_received_from_cand numeric(14,2),
    other_loans_received numeric(14,2),
    ttl_loans numeric(14,2),
    op_exp numeric(14,2),
    fndrsg_exp numeric(14,2),
    legal_and_acctg_exp numeric(14,2),
    ttl_offsets_to_op_exp numeric(14,2),
    other_receipts numeric(14,2),
    ttl_receipts numeric(14,2),
    op_exp2 numeric(14,2),
    tranf_to_other_auth_cmte numeric(14,2),
    fndrsg_disb numeric(14,2),
    exempt_legal_and_acctg_disb numeric(14,2),
    loan_repymts_made_by_cand numeric(14,2),
    other_repymts numeric(14,2),
    ttl_loan_repymts_made numeric(14,2),
    ref_indv_contb numeric(14,2),
    ref_pol_pty_contb numeric(14,2),
    ref_other_pol_cmte_contb numeric(14,2),
    ttl_contb_ref numeric(14,2),
    other_disb numeric(14,2),
    ttl_disb numeric(14,2),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    indv_item_contb numeric(14,2),
    indv_unitem_contb numeric(14,2),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_3ps OWNER TO fec;

--
-- Name: nml_form_3pz; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_3pz (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    pcc_id character varying(9),
    pcc_nm character varying(200),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    auth_cmte_id character varying(9),
    auth_cmte_nm character varying(200),
    coh_bop numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    indv_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    op_exp_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    fndrsg_disb_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    load_status numeric(1,0),
    delete_ind numeric(1,0),
    image_tp character varying(10),
    file_num numeric(7,0),
    receipt_dt timestamp without time zone,
    last_update_dt timestamp without time zone,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_3pz OWNER TO fec;

--
-- Name: nml_form_3s; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_3s (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    ttl_contb numeric(14,2),
    ttl_contb_ref numeric(14,2),
    net_contb numeric(14,2),
    ttl_op_exp numeric(14,2),
    ttl_offsets_to_op_exp numeric(14,2),
    net_op_exp numeric(14,2),
    indv_item_contb numeric(14,2),
    indv_unitem_contb numeric(14,2),
    ttl_indv_contb numeric(14,2),
    pol_pty_cmte_contb numeric(14,2),
    other_pol_cmte_contb numeric(14,2),
    cand_contb numeric(14,2),
    ttl_contb_column_ttl numeric(14,2),
    tranf_from_other_auth_cmte numeric(14,2),
    loans_made_by_cand numeric(14,2),
    all_other_loans numeric(14,2),
    ttl_loans numeric(14,2),
    offsets_to_op_exp numeric(14,2),
    other_receipts numeric(14,2),
    ttl_receipts numeric(14,2),
    op_exp numeric(14,2),
    tranf_to_other_auth_cmte numeric(14,2),
    loan_repymts_cand_loans numeric(14,2),
    loan_repymts_other_loans numeric(14,2),
    ttl_loan_repymts numeric(14,2),
    ref_indv_contb numeric(14,2),
    ref_pol_pty_cmte_contb numeric(14,2),
    ref_other_pol_cmte_contb numeric(14,2),
    ttl_contb_ref_col_ttl numeric(14,2),
    other_disb numeric(14,2),
    ttl_disb numeric(14,2),
    election_dt timestamp without time zone,
    day_after_election_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_3s OWNER TO fec;

--
-- Name: nml_form_3x; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_3x (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    qual_cmte_flg character varying(1),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(5),
    rpt_pgi_desc character varying(10),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    ttl_indv_contb numeric(14,2),
    pol_pty_cmte_contb_per_i numeric(14,2),
    other_pol_cmte_contb_per_i numeric(14,2),
    ttl_contb_col_ttl_per numeric(14,2),
    tranf_from_affiliated_pty_per numeric(14,2),
    all_loans_received_per numeric(14,2),
    loan_repymts_received_per numeric(14,2),
    offsets_to_op_exp_per_i numeric(14,2),
    fed_cand_contb_ref_per numeric(14,2),
    other_fed_receipts_per numeric(14,2),
    tranf_from_nonfed_acct_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    ttl_fed_receipts_per numeric(14,2),
    shared_fed_op_exp_per numeric(14,2),
    shared_nonfed_op_exp_per numeric(14,2),
    other_fed_op_exp_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    tranf_to_affliliated_cmte_per numeric(14,2),
    fed_cand_cmte_contb_per numeric(14,2),
    indt_exp_per numeric(14,2),
    coord_exp_by_pty_cmte_per numeric(14,2),
    loan_repymts_made_per numeric(14,2),
    loans_made_per numeric(14,2),
    indv_contb_ref_per numeric(14,2),
    pol_pty_cmte_contb_per_ii numeric(14,2),
    other_pol_cmte_contb_per_ii numeric(14,2),
    ttl_contb_ref_per_i numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    ttl_fed_disb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    ttl_contb_ref_per_ii numeric(14,2),
    net_contb_per numeric(14,2),
    ttl_fed_op_exp_per numeric(14,2),
    offsets_to_op_exp_per_ii numeric(14,2),
    net_op_exp_per numeric(14,2),
    coh_begin_calendar_yr numeric(14,2),
    calendar_yr numeric(4,0),
    ttl_receipts_sum_page_ytd numeric(14,2),
    subttl_sum_ytd numeric(14,2),
    ttl_disb_sum_page_ytd numeric(14,2),
    coh_coy numeric(14,2),
    indv_item_contb_ytd numeric(14,2),
    indv_unitem_contb_ytd numeric(14,2),
    ttl_indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd_i numeric(14,2),
    other_pol_cmte_contb_ytd_i numeric(14,2),
    ttl_contb_col_ttl_ytd numeric(14,2),
    tranf_from_affiliated_pty_ytd numeric(14,2),
    all_loans_received_ytd numeric(14,2),
    loan_repymts_received_ytd numeric(14,2),
    offsets_to_op_exp_ytd_i numeric(14,2),
    fed_cand_cmte_contb_ytd numeric(14,2),
    other_fed_receipts_ytd numeric(14,2),
    tranf_from_nonfed_acct_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    ttl_fed_receipts_ytd numeric(14,2),
    shared_fed_op_exp_ytd numeric(14,2),
    shared_nonfed_op_exp_ytd numeric(14,2),
    other_fed_op_exp_ytd numeric(14,2),
    ttl_op_exp_ytd numeric(14,2),
    tranf_to_affilitated_cmte_ytd numeric(14,2),
    fed_cand_cmte_contb_ref_ytd numeric(14,2),
    indt_exp_ytd numeric(14,2),
    coord_exp_by_pty_cmte_ytd numeric(14,2),
    loan_repymts_made_ytd numeric(14,2),
    loans_made_ytd numeric(14,2),
    indv_contb_ref_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd_ii numeric(14,2),
    other_pol_cmte_contb_ytd_ii numeric(14,2),
    ttl_contb_ref_ytd_i numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    ttl_fed_disb_ytd numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd_ii numeric(14,2),
    net_contb_ytd numeric(14,2),
    ttl_fed_op_exp_ytd numeric(14,2),
    offsets_to_op_exp_ytd_ii numeric(14,2),
    net_op_exp_ytd numeric(14,2),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    multicand_flg character varying(1),
    receipt_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    tranf_from_nonfed_levin_per numeric(14,2),
    ttl_nonfed_tranf_per numeric(14,2),
    shared_fed_actvy_fed_shr_per numeric(14,2),
    shared_fed_actvy_nonfed_per numeric(14,2),
    non_alloc_fed_elect_actvy_per numeric(14,2),
    ttl_fed_elect_actvy_per numeric(14,2),
    tranf_from_nonfed_levin_ytd numeric(14,2),
    ttl_nonfed_tranf_ytd numeric(14,2),
    shared_fed_actvy_fed_shr_ytd numeric(14,2),
    shared_fed_actvy_nonfed_ytd numeric(14,2),
    non_alloc_fed_elect_actvy_ytd numeric(14,2),
    ttl_fed_elect_actvy_ytd numeric(14,2),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_3x OWNER TO fec;

--
-- Name: nml_form_3z; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_3z (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    pcc_id character varying(9),
    pcc_nm character varying(200),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    auth_cmte_id character varying(9),
    auth_cmte_nm character varying(200),
    indv_contb numeric(14,2),
    pol_pty_contb numeric(14,2),
    other_pol_cmte_contb numeric(14,2),
    cand_contb numeric(14,2),
    ttl_contb numeric(14,2),
    tranf_from_other_auth_cmte numeric(14,2),
    loans_made_by_cand numeric(14,2),
    all_other_loans numeric(14,2),
    ttl_loans numeric(14,2),
    offsets_to_op_exp numeric(14,2),
    other_receipts numeric(14,2),
    ttl_receipts numeric(14,2),
    op_exp numeric(14,2),
    tranf_to_other_auth_cmte numeric(14,2),
    repymts_loans_made_cand numeric(14,2),
    repymts_all_other_loans numeric(14,2),
    ttl_loan_repymts numeric(14,2),
    ref_indv_contb numeric(14,2),
    ref_pol_pty_cmte_contb numeric(14,2),
    ref_other_pol_cmte_contb numeric(14,2),
    ttl_contb_ref numeric(14,2),
    other_disb numeric(14,2),
    ttl_disb numeric(14,2),
    coh_bop numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    net_contb numeric(14,2),
    net_op_exp numeric(14,2),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_3z OWNER TO fec;

--
-- Name: nml_form_4; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_4 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_tp character varying(1),
    cmte_tp_desc character varying(58),
    cmte_desc character varying(40),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte_per numeric(14,2),
    debts_owed_by_cmte_per numeric(14,2),
    convn_exp_per numeric(14,2),
    ref_reb_ret_convn_exp_per numeric(14,2),
    exp_subject_limits_per numeric(14,2),
    exp_prior_yrs_subject_lim_per numeric(14,2),
    ttl_exp_subject_limits numeric(14,2),
    fed_funds_per numeric(14,2),
    item_convn_exp_contb_per numeric(14,2),
    unitem_convn_exp_contb_per numeric(14,2),
    subttl_convn_exp_contb_per numeric(14,2),
    tranf_from_affiliated_cmte_per numeric(14,2),
    loans_received_per numeric(14,2),
    loan_repymts_received_per numeric(14,2),
    subttl_loan_repymts_per numeric(14,2),
    item_ref_reb_ret_per numeric(14,2),
    unitem_ref_reb_ret_per numeric(14,2),
    subttl_ref_reb_ret_per numeric(14,2),
    item_other_ref_reb_ret_per numeric(14,2),
    unitem_other_ref_reb_ret_per numeric(14,2),
    subttl_other_ref_reb_ret_per numeric(14,2),
    item_other_income_per numeric(14,2),
    unitem_other_income_per numeric(14,2),
    subttl_other_income_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    item_convn_exp_disb_per numeric(14,2),
    unitem_convn_exp_disb_per numeric(14,2),
    subttl_convn_exp_disb_per numeric(14,2),
    tranf_to_affiliated_cmte_per numeric(14,2),
    loans_made_per numeric(14,2),
    loan_repymts_made_per numeric(14,2),
    subttl_loan_repymts_disb_per numeric(14,2),
    item_other_disb_per numeric(14,2),
    unitem_other_disb_per numeric(14,2),
    subttl_other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    coh_begin_calendar_yr numeric(14,2),
    calendar_yr numeric(4,0),
    ttl_receipts_sum_page_ytd numeric(14,2),
    subttl_sum_page_ytd numeric(14,2),
    ttl_disb_sum_page_ytd numeric(14,2),
    coh_coy numeric(14,2),
    convn_exp_ytd numeric(14,2),
    ref_reb_ret_convn_exp_ytd numeric(14,2),
    exp_subject_limits_ytd numeric(14,2),
    exp_prior_yrs_subject_lim_ytd numeric(14,2),
    ttl_exp_subject_limits_ytd numeric(14,2),
    fed_funds_ytd numeric(14,2),
    subttl_convn_exp_contb_ytd numeric(14,2),
    tranf_from_affiliated_cmte_ytd numeric(14,2),
    subttl_loan_repymts_ytd numeric(14,2),
    subttl_ref_reb_ret_deposit_ytd numeric(14,0),
    subttl_other_ref_reb_ret_ytd numeric(14,2),
    subttl_other_income_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    subttl_convn_exp_disb_ytd numeric(14,2),
    tranf_to_affiliated_cmte_ytd numeric(14,2),
    subttl_loan_repymts_disb_ytd numeric(14,2),
    subttl_other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    rpt_yr numeric(4,0),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_4 OWNER TO fec;

--
-- Name: nml_form_5; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_5 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    indv_org_id character varying(9),
    indv_org_nm character varying(200),
    indv_org_st1 character varying(34),
    indv_org_st2 character varying(34),
    indv_org_city character varying(30),
    indv_org_st character varying(2),
    indv_org_zip character varying(9),
    addr_chg_flg character varying(1),
    qual_nonprofit_corp_ind character varying(1),
    indv_org_employer character varying(38),
    indv_org_occupation character varying(38),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(5),
    rpt_pgi_desc character varying(10),
    election_tp character varying(2),
    election_tp_desc character varying(50),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    ttl_indt_contb numeric(14,2),
    ttl_indt_exp numeric(14,2),
    filer_nm character varying(90),
    filer_sign_nm character varying(90),
    filer_sign_dt timestamp without time zone,
    notary_sign_dt timestamp without time zone,
    notary_commission_exprtn_dt timestamp without time zone,
    notary_nm character varying(38),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    entity_tp character varying(3),
    indv_l_nm character varying(30),
    indv_f_nm character varying(20),
    indv_m_nm character varying(20),
    indv_prefix character varying(10),
    indv_suffix character varying(10),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    orig_amndt_dt timestamp without time zone,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_5 OWNER TO fec;

--
-- Name: nml_form_56; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_56 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    filer_cmte_id character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    contbr_nm character varying(200),
    contbr_st1 character varying(34),
    contbr_st2 character varying(34),
    conbtr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    contb_dt timestamp without time zone,
    contb_amt numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_nm character varying(200),
    conduit_st1 character varying(34),
    conduit_st2 character varying(34),
    conduit_city character varying(30),
    conduit_st character varying(2),
    conduit_zip character varying(9),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    contbr_l_nm character varying(30),
    contbr_f_nm character varying(20),
    contbr_m_nm character varying(20),
    contbr_prefix character varying(10),
    contbr_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_56 OWNER TO fec;

--
-- Name: nml_form_57; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_57 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    filer_cmte_id character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_purpose character varying(100),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(20),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_state_desc character varying(20),
    s_o_cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    receipt_dt timestamp without time zone,
    tran_id character varying(32),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    catg_cd character varying(3),
    exp_tp character varying(3),
    cal_ytd_ofc_sought numeric(14,2),
    catg_cd_desc character varying(40),
    exp_tp_desc character varying(90),
    file_num numeric(7,0),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    orig_sub_id numeric(19,0),
    pye_l_nm character varying(30),
    pye_f_nm character varying(20),
    pye_m_nm character varying(20),
    pye_prefix character varying(10),
    pye_suffix character varying(10),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_57 OWNER TO fec;

--
-- Name: nml_form_6; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_6 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    filer_cmte_st1 character varying(34),
    filer_cmte_st2 character varying(34),
    filer_cmte_city character varying(30),
    filer_cmte_st character varying(2),
    filer_cmte_zip character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    signer_last_name character varying(30),
    signer_first_name character varying(20),
    signer_middle_name character varying(20),
    signer_prefix character varying(10),
    signer_suffix character varying(10),
    amndt_ind character varying(1),
    orig_amndt_dt timestamp without time zone,
    cand_l_nm character varying(30),
    cand_f_nm character varying(20),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_6 OWNER TO fec;

--
-- Name: nml_form_65; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_65 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    filer_cmte_id character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    contbr_lender_nm character varying(200),
    contbr_lender_st1 character varying(34),
    contbr_lender_st2 character varying(34),
    contbr_lender_city character varying(30),
    contbr_lender_st character varying(2),
    contbr_lender_zip character varying(9),
    contbr_lender_employer character varying(38),
    contbr_lender_occupation character varying(38),
    contb_dt timestamp without time zone,
    contb_amt numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    contbr_l_nm character varying(30),
    contbr_f_nm character varying(20),
    contbr_m_nm character varying(20),
    contbr_prefix character varying(10),
    contbr_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_65 OWNER TO fec;

--
-- Name: nml_form_7; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_7 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    org_id character varying(9),
    org_nm character varying(200),
    org_st1 character varying(34),
    org_st2 character varying(34),
    org_city character varying(30),
    org_st character varying(2),
    org_zip character varying(9),
    org_tp character varying(1),
    org_tp_desc character varying(90),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(90),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    ttl_communication_cost numeric(14,2),
    filer_sign_nm character varying(90),
    filer_sign_dt timestamp without time zone,
    filer_title character varying(20),
    receipt_dt timestamp without time zone,
    rpt_pgi character varying(1),
    rpt_pgi_desc character varying(10),
    amdnt_ind character varying(1),
    amndt_ind_desc character varying(15),
    rpt_yr numeric(4,0),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_7 OWNER TO fec;

--
-- Name: nml_form_76; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_76 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    org_id character varying(9),
    communication_tp character varying(2),
    communication_tp_desc character varying(40),
    communication_class character varying(1),
    communication_class_desc character varying(90),
    communication_dt timestamp without time zone,
    s_o_ind character varying(3),
    s_o_ind_desc character varying(90),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_rpt_pgi character varying(5),
    s_o_rpt_pgi_desc character varying(10),
    communication_cost numeric(14,2),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    file_num numeric(7,0),
    election_other_desc character varying(20),
    orig_sub_id numeric(19,0),
    transaction_tp character varying(3),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_76 OWNER TO fec;

--
-- Name: nml_form_8; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_8 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    coh numeric(14,2),
    calender_yr timestamp without time zone,
    ttl_liquidated_assets numeric(14,2),
    ttl_assets numeric(14,2),
    ytd_reciepts numeric(14,2),
    ytd_disb numeric(14,2),
    ttl_amt_debts_owed numeric(14,2),
    ttl_num_cred_owed numeric(8,0),
    ttl_num_cred_part2 numeric(8,0),
    ttl_amt_debts_owed_part2 numeric(14,2),
    ttl_amt_paid_cred numeric(14,2),
    term_flg character varying(1),
    term_dt_desc character varying(15),
    addl_auth_cmte_flg character varying(1),
    add_auth_cmte_desc character varying(300),
    sufficient_amt_to_pay_ttl_flg character varying(1),
    sufficient_amt_to_pay_desc character varying(100),
    prev_debt_settlement_plan_flg character varying(1),
    residual_funds_flg character varying(1),
    residual_funds_desc character varying(100),
    remaining_amt_flg character varying(1),
    remaining_amt_desc character varying(100),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_8 OWNER TO fec;

--
-- Name: nml_form_82; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_82 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cred_tp character varying(3),
    cred_tp_desc character varying(50),
    cred_nm character varying(200),
    cred_st1 character varying(34),
    cred_st2 character varying(34),
    cred_city character varying(30),
    cred_st character varying(2),
    cred_zip character varying(9),
    incurred_dt timestamp without time zone,
    amt_owed_cred numeric(14,2),
    amt_offered_settle numeric(14,2),
    terms_initial_extention_desc character varying(100),
    debt_repymt_efforts_desc character varying(100),
    steps_obtain_funds_desc character varying(100),
    similar_effort_flg character varying(1),
    similar_effort_desc character varying(100),
    terms_settlement_flg character varying(1),
    terms_of_settlement_desc character varying(100),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    add_cmte_id character varying(9),
    creditor_sign_nm character varying(90),
    creditor_sign_dt timestamp without time zone,
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    entity_tp character varying(3),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_82 OWNER TO fec;

--
-- Name: nml_form_83; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_83 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cred_tp character varying(3),
    cred_tp_desc character varying(50),
    cred_nm character varying(200),
    cred_st1 character varying(34),
    cred_st2 character varying(34),
    cred_city character varying(30),
    cred_st character varying(2),
    cred_zip character varying(9),
    disputed_debt_flg character varying(1),
    incurred_dt timestamp without time zone,
    amt_owed_cred numeric(14,2),
    amt_offered_settle numeric(14,2),
    add_cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    entity_tp character varying(3),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_83 OWNER TO fec;

--
-- Name: nml_form_9; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_9 (
    form_tp character varying(8),
    cmte_id character varying(9),
    ind_org_corp_nm character varying(200),
    ind_org_corp_st1 character varying(34),
    ind_org_corp_st2 character varying(34),
    ind_org_corp_city character varying(30),
    ind_org_corp_st character varying(2),
    ind_org_corp_zip character varying(9),
    addr_chg_flg character varying(1),
    ind_org_corp_emp character varying(38),
    ind_org_corp_occup character varying(38),
    beg_cvg_dt timestamp without time zone,
    end_cvg_dt timestamp without time zone,
    pub_distrib_dt timestamp without time zone,
    qual_nonprofit_flg character varying(18),
    segr_bank_acct_flg character varying(1),
    ind_custod_nm character varying(90),
    ind_custod_st1 character varying(34),
    ind_custod_st2 character varying(34),
    ind_custod_city character varying(30),
    ind_custod_st character varying(2),
    ind_custod_zip character varying(9),
    ind_custod_emp character varying(38),
    ind_custod_occup character varying(38),
    ttl_dons_this_stmt numeric(14,2),
    ttl_disb_this_stmt numeric(14,2),
    filer_sign_nm character varying(90),
    filer_sign_dt timestamp without time zone,
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp_desc character varying(90),
    ind_org_corp_st_desc character varying(20),
    addr_chg_flg_desc character varying(20),
    qual_nonprofit_flg_desc character varying(40),
    segr_bank_acct_flg_desc character varying(30),
    ind_custod_st_desc character varying(20),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    amndt_ind character varying(1),
    comm_title character varying(40),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    rpt_tp character varying(3),
    entity_tp character varying(3),
    filer_cd character varying(3),
    filer_cd_desc character varying(20),
    indv_l_nm character varying(30),
    indv_f_nm character varying(20),
    indv_m_nm character varying(20),
    indv_prefix character varying(10),
    indv_suffix character varying(10),
    cust_l_nm character varying(30),
    cust_f_nm character varying(20),
    cust_m_nm character varying(20),
    cust_prefix character varying(10),
    cust_suffix character varying(10),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_9 OWNER TO fec;

--
-- Name: nml_form_91; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_91 (
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    shr_ex_ctl_ind_nm character varying(90),
    shr_ex_ctl_street1 character varying(34),
    shr_ex_ctl_street2 character varying(34),
    shr_ex_ctl_city character varying(30),
    shr_ex_ctl_st character varying(2),
    shr_ex_ctl_zip character varying(9),
    shr_ex_ctl_employ character varying(38),
    shr_ex_ctl_occup character varying(38),
    amndt_ind character varying(1),
    tran_id character varying(32),
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp_desc character varying(90),
    shr_ex_ctl_st_desc character varying(20),
    amndt_ind_desc character varying(15),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    receipt_dt timestamp without time zone,
    link_id numeric(19,0),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    shr_ex_ctl_l_nm character varying(30),
    shr_ex_ctl_f_nm character varying(20),
    shr_ex_ctl_m_nm character varying(20),
    shr_ex_ctl_prefix character varying(10),
    shr_ex_ctl_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_91 OWNER TO fec;

--
-- Name: nml_form_94; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_94 (
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    amndt_ind character varying(1),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp_desc character varying(90),
    cand_office_desc character varying(20),
    cand_office_st_desc character varying(20),
    election_tp_desc character varying(20),
    amndt_ind_desc character varying(15),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    receipt_dt timestamp without time zone,
    link_id numeric(19,0),
    file_num numeric(7,0),
    sb_link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    cand_l_nm character varying(30),
    cand_f_nm character varying(20),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_94 OWNER TO fec;

--
-- Name: nml_form_99_misc; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_99_misc (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    text_field character varying(4000),
    to_from_ind character varying(1),
    to_from_ind_desc character varying(90),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    text_cd character varying(3),
    text_cd_desc character varying(40),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_99_misc OWNER TO fec;

--
-- Name: nml_form_rfai; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_form_rfai (
    sub_id numeric(19,0) NOT NULL,
    id character varying(9),
    request_tp character varying(3),
    request_tp_desc character varying(65),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rfai_dt timestamp without time zone,
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    analyst_id character varying(3),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    chg_del_id numeric(19,0),
    file_num numeric(7,0),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    rpt_yr numeric(4,0),
    response_due_dt timestamp without time zone,
    response_dt timestamp without time zone,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_form_rfai OWNER TO fec;

--
-- Name: nml_sched_a; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_a (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    contbr_id character varying(9),
    contbr_nm character varying(200),
    contbr_nm_first character varying(38),
    contbr_nm_last character varying(38),
    contbr_st1 character varying(34),
    contbr_st2 character varying(34),
    contbr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    contb_aggregate_ytd numeric(14,2),
    contb_receipt_dt timestamp without time zone,
    contb_receipt_amt numeric(14,2),
    receipt_tp character varying(3),
    receipt_tp_desc character varying(90),
    receipt_desc character varying(100),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    national_cmte_nonfed_acct character varying(9),
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(3),
    rpt_pgi_desc character varying(10),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    increased_limit character varying(1),
    file_num numeric(7,0),
    donor_cmte_nm character varying(200),
    orig_sub_id numeric(19,0),
    contbr_m_nm character varying(20),
    contbr_prefix character varying(10),
    contbr_suffix character varying(10),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_a OWNER TO fec;

--
-- Name: nml_sched_a_daily; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_a_daily (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    contbr_id character varying(9),
    contbr_nm character varying(200),
    contbr_nm_first character varying(38),
    contbr_nm_last character varying(38),
    contbr_st1 character varying(34),
    contbr_st2 character varying(34),
    contbr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    contb_aggregate_ytd numeric(14,2),
    contb_receipt_dt timestamp without time zone,
    contb_receipt_amt numeric(14,2),
    receipt_tp character varying(3),
    receipt_tp_desc character varying(90),
    receipt_desc character varying(100),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    national_cmte_nonfed_acct character varying(9),
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(3),
    rpt_pgi_desc character varying(10),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    increased_limit character varying(1),
    file_num numeric(7,0),
    donor_cmte_nm character varying(200),
    orig_sub_id numeric(19,0),
    contbr_m_nm character varying(20),
    contbr_prefix character varying(10),
    contbr_suffix character varying(10),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_a_daily OWNER TO fec;

--
-- Name: nml_sched_b; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_b (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    recipient_cmte_id character varying(9),
    recipient_nm character varying(200),
    recipient_st1 character varying(34),
    recipient_st2 character varying(34),
    recipient_city character varying(30),
    recipient_st character varying(2),
    recipient_zip character varying(9),
    disb_tp character varying(3),
    disb_tp_desc character varying(90),
    disb_desc character varying(100),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_tp_year character varying(4),
    election_tp_desc character varying(20),
    disb_dt timestamp without time zone,
    disb_amt numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    memo_cd character varying(1),
    memo_text character varying(100),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_id character varying(8),
    national_cmte_nonfed_acct character varying(9),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    record_num character varying(10),
    rpt_pgi character varying(3),
    rpt_pgi_desc character varying(10),
    receipt_dt timestamp without time zone,
    memo_cd_desc character varying(50),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    ref_disp_excess_flg character varying(1),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    comm_dt timestamp without time zone,
    file_num numeric(7,0),
    payee_employer character varying(38),
    payee_occupation character varying(38),
    benef_cmte_nm character varying(200),
    orig_sub_id numeric(19,0),
    semi_an_bundled_refund numeric(14,2),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_b OWNER TO fec;

--
-- Name: nml_sched_b_daily; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_b_daily (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    recipient_cmte_id character varying(9),
    recipient_nm character varying(200),
    recipient_st1 character varying(34),
    recipient_st2 character varying(34),
    recipient_city character varying(30),
    recipient_st character varying(2),
    recipient_zip character varying(9),
    disb_tp character varying(3),
    disb_tp_desc character varying(90),
    disb_desc character varying(100),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_tp_year character varying(4),
    election_tp_desc character varying(20),
    disb_dt timestamp without time zone,
    disb_amt numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    memo_cd character varying(1),
    memo_text character varying(100),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_id character varying(8),
    national_cmte_nonfed_acct character varying(9),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    record_num character varying(10),
    rpt_pgi character varying(3),
    rpt_pgi_desc character varying(10),
    receipt_dt timestamp without time zone,
    memo_cd_desc character varying(50),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    ref_disp_excess_flg character varying(1),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    comm_dt timestamp without time zone,
    file_num numeric(7,0),
    payee_employer character varying(38),
    payee_occupation character varying(38),
    benef_cmte_nm character varying(200),
    orig_sub_id numeric(19,0),
    semi_an_bundled_refund numeric(14,2),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_b_daily OWNER TO fec;

--
-- Name: nml_sched_c; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_c (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    cmte_nm character varying(200),
    loan_src_nm character varying(200),
    loan_src_st1 character varying(34),
    loan_src_st2 character varying(34),
    loan_src_city character varying(30),
    loan_src_st character varying(2),
    loan_src_zip character varying(9),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_tp_year character varying(4),
    election_tp_desc character varying(20),
    orig_loan_amt numeric(14,2),
    pymt_to_dt numeric(14,2),
    loan_bal numeric(14,2),
    incurred_dt timestamp without time zone,
    due_dt_terms character varying(15),
    interest_rate_terms character varying(15),
    secured_ind character varying(1),
    fec_cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_state_desc character varying(20),
    cand_office_district character varying(2),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    receipt_dt timestamp without time zone,
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    sched_a_line_num character varying(3),
    file_num numeric(7,0),
    pers_fund_yes_no character varying(1),
    memo_cd character varying(1),
    memo_text character varying(100),
    orig_sub_id numeric(19,0),
    loan_src_l_nm character varying(30),
    loan_src_f_nm character varying(20),
    loan_src_m_nm character varying(20),
    loan_src_prefix character varying(10),
    loan_src_suffix character varying(10),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_c OWNER TO fec;

--
-- Name: nml_sched_c1; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_c1 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    back_ref_tran_id character varying(32),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    loan_src_nm character varying(200),
    loan_src_st1 character varying(34),
    loan_src_st2 character varying(34),
    loan_src_city character varying(30),
    loan_src_st character varying(2),
    loan_src_zip character varying(9),
    loan_amt numeric(14,2),
    interest_rate_pct character varying(15),
    incurred_dt timestamp without time zone,
    due_dt character varying(15),
    loan_restructured_flg character varying(1),
    orig_loan_dt timestamp without time zone,
    credit_amt_this_draw numeric(14,2),
    ttl_bal numeric(14,2),
    other_liable_pty_flg character varying(1),
    collateral_flg character varying(1),
    collateral_desc character varying(100),
    collateral_value numeric(14,2),
    perfected_interest_flg character varying(1),
    future_income_flg character varying(1),
    future_income_desc character varying(100),
    future_income_est_value numeric(14,2),
    depository_acct_est_dt timestamp without time zone,
    acct_loc_nm character varying(90),
    acct_loc_st1 character varying(34),
    acct_loc_st2 character varying(34),
    acct_loc_city character varying(30),
    acct_loc_st character varying(2),
    acct_loc_zip character varying(9),
    depository_acct_auth_dt timestamp without time zone,
    loan_basis_desc character varying(100),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    auth_sign_nm character varying(90),
    auth_rep_title character varying(20),
    auth_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    file_num numeric(7,0),
    tran_id character varying(32),
    orig_sub_id numeric(19,0),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    auth_sign_l_nm character varying(30),
    auth_sign_f_nm character varying(20),
    auth_sign_m_nm character varying(20),
    auth_sign_prefix character varying(10),
    auth_sign_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_c1 OWNER TO fec;

--
-- Name: nml_sched_c2; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_c2 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    back_ref_tran_id character varying(32),
    guar_endr_nm character varying(90),
    guar_endr_st1 character varying(34),
    guar_endr_st2 character varying(34),
    guar_endr_city character varying(30),
    guar_endr_st character varying(2),
    guar_endr_zip character varying(9),
    guar_endr_employer character varying(38),
    guar_endr_occupation character varying(38),
    amt_guaranteed_outstg numeric(14,2),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    file_num numeric(7,0),
    tran_id character varying(32),
    orig_sub_id numeric(19,0),
    guar_endr_l_nm character varying(30),
    guar_endr_f_nm character varying(20),
    guar_endr_m_nm character varying(20),
    guar_endr_prefix character varying(10),
    guar_endr_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_c2 OWNER TO fec;

--
-- Name: nml_sched_d; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_d (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    cred_dbtr_id character varying(9),
    cred_dbtr_nm character varying(200),
    cred_dbtr_st1 character varying(34),
    cred_dbtr_st2 character varying(34),
    cred_dbtr_city character varying(30),
    cred_dbtr_st character varying(2),
    cred_dbtr_zip character varying(9),
    nature_debt_purpose character varying(100),
    outstg_bal_bop numeric(14,2),
    amt_incurred_per numeric(14,2),
    pymt_per numeric(14,2),
    outstg_bal_cop numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    receipt_dt timestamp without time zone,
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    cred_dbtr_l_nm character varying(30),
    cred_dbtr_f_nm character varying(20),
    cred_dbtr_m_nm character varying(20),
    cred_dbtr_prefix character varying(10),
    cred_dbtr_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now(),
    creditor_debtor_name_text tsvector
);


ALTER TABLE nml_sched_d OWNER TO fec;

--
-- Name: nml_sched_e; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_e (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    exp_desc character varying(100),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(50),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_nm_first character varying(38),
    s_o_cand_nm_last character varying(38),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    indt_sign_nm character varying(90),
    indt_sign_dt timestamp without time zone,
    notary_sign_nm character varying(90),
    notary_sign_dt timestamp without time zone,
    notary_commission_exprtn_dt timestamp without time zone,
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    receipt_dt timestamp without time zone,
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(1),
    rpt_pgi_desc character varying(10),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    catg_cd character varying(3),
    cal_ytd_ofc_sought numeric(14,2),
    catg_cd_desc character varying(40),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    s_0_cand_m_nm character varying(20),
    s_0_cand_prefix character varying(10),
    s_0_cand_suffix character varying(10),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    dissem_dt timestamp without time zone,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_e OWNER TO fec;

--
-- Name: nml_sched_f; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_f (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_desg_coord_exp_ind character varying(1),
    desg_cmte_id character varying(9),
    desg_cmte_nm character varying(200),
    subord_cmte_id character varying(9),
    subord_cmte_nm character varying(200),
    subord_cmte_st1 character varying(34),
    subord_cmte_st2 character varying(34),
    subord_cmte_city character varying(30),
    subord_cmte_st character varying(2),
    subord_cmte_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    aggregate_gen_election_exp numeric(14,2),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    exp_purpose_desc character varying(100),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    receipt_dt timestamp without time zone,
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(1),
    rpt_pgi_desc character varying(10),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    unlimited_spending_flg character varying(1),
    catg_cd character varying(3),
    unlimited_spending_flg_desc character varying(40),
    catg_cd_desc character varying(40),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_f OWNER TO fec;

--
-- Name: nml_sched_h1; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_h1 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    np_fixed_fed_pct numeric(7,4),
    hsp_min_fed_pct numeric(7,4),
    hsp_est_fed_dir_cand_supp_pct numeric(7,4),
    hsp_est_nonfed_cand_supp_pct numeric(7,4),
    hsp_actl_fed_dir_cand_supp_amt numeric(14,2),
    hsp_actl_nonfed_cand_supp_amt numeric(14,2),
    hsp_actl_fed_dir_cand_supp_pct numeric(7,4),
    ssf_fed_est_dir_cand_supp_pct numeric(7,4),
    ssf_nfed_est_dir_cand_supp_pct numeric(7,4),
    ssf_actl_fed_dir_cand_supp_amt numeric(14,2),
    ssf_actl_nonfed_cand_supp_amt numeric(14,2),
    ssf_actl_fed_dir_cand_supp_pct numeric(7,4),
    president_ind numeric(1,0),
    us_senate_ind numeric(1,0),
    us_congress_ind numeric(1,0),
    subttl_fed numeric(1,0),
    governor_ind numeric(1,0),
    other_st_offices_ind numeric(1,0),
    st_senate_ind numeric(1,0),
    st_rep_ind numeric(1,0),
    local_cand_ind numeric(1,0),
    extra_non_fed_point_ind numeric(1,0),
    subttl_non_fed numeric(2,0),
    ttl_fed_and_nonfed numeric(2,0),
    fed_alloctn numeric(5,0),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    record_num character varying(10),
    receipt_dt timestamp without time zone,
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    st_loc_pres_only character varying(1),
    st_loc_pres_sen character varying(1),
    st_loc_sen_only character varying(1),
    st_loc_nonpres_nonsen character varying(1),
    flat_min_fed_pct character varying(1),
    fed_pct numeric(5,0),
    non_fed_pct numeric(5,0),
    admin_ratio_chk character varying(1),
    gen_voter_drive_chk character varying(1),
    pub_comm_ref_pty_chk character varying(1),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_h1 OWNER TO fec;

--
-- Name: nml_sched_h2; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_h2 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    evt_activity_nm character varying(90),
    fndsg_acty_flg character varying(1),
    exempt_acty_flg character varying(1),
    direct_cand_support_acty_flg character varying(1),
    ratio_cd character varying(1),
    ratio_cd_desc character varying(30),
    fed_pct_amt numeric(7,4),
    nonfed_pct_amt numeric(7,4),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    record_num character varying(10),
    receipt_dt timestamp without time zone,
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_h2 OWNER TO fec;

--
-- Name: nml_sched_h3; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_h3 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    back_ref_tran_id character varying(32),
    acct_nm character varying(90),
    evt_nm character varying(90),
    evt_tp character varying(2),
    event_tp_desc character varying(50),
    tranf_dt timestamp without time zone,
    tranf_amt numeric(14,2),
    ttl_tranf_amt numeric(14,2),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_h3 OWNER TO fec;

--
-- Name: nml_sched_h4; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_h4 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    entity_tp character varying(3),
    entity_tp_desc character varying(30),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    evt_purpose_nm character varying(100),
    evt_purpose_desc character varying(38),
    evt_purpose_dt timestamp without time zone,
    ttl_amt_disb numeric(14,2),
    evt_purpose_category_tp character varying(3),
    evt_purpose_category_tp_desc character varying(30),
    fed_share numeric(14,2),
    nonfed_share numeric(14,2),
    admin_voter_drive_acty_ind character varying(1),
    fndrsg_acty_ind character varying(1),
    exempt_acty_ind character varying(1),
    direct_cand_supp_acty_ind character varying(1),
    evt_amt_ytd numeric(14,2),
    add_desc character varying(100),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    back_ref_tran_id character varying(32),
    back_ref_sched_id character varying(8),
    record_num character varying(10),
    receipt_dt timestamp without time zone,
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    admin_acty_ind character varying(1),
    gen_voter_drive_acty_ind character varying(1),
    catg_cd character varying(3),
    disb_tp character varying(3),
    catg_cd_desc character varying(40),
    disb_tp_desc character varying(90),
    pub_comm_ref_pty_chk character varying(1),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_h4 OWNER TO fec;

--
-- Name: nml_sched_h5; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_h5 (
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    acct_nm character varying(90),
    tranf_dt timestamp without time zone,
    ttl_tranf_amt_voter_reg numeric(14,2),
    ttl_tranf_voter_id numeric(14,2),
    ttl_tranf_gotv numeric(14,2),
    ttl_tranf_gen_campgn_actvy numeric(14,2),
    ttl_tranf_amt numeric(14,2),
    amndt_ind character varying(1),
    tran_id character varying(32),
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp_desc character varying(90),
    filer_cmte_nm character varying(200),
    amndt_ind_desc character varying(15),
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_h5 OWNER TO fec;

--
-- Name: nml_sched_h6; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_h6 (
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    entity_tp character varying(3),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    catg_cd character varying(3),
    disb_purpose character varying(3),
    disb_purpose_cat character varying(100),
    disb_dt timestamp without time zone,
    ttl_amt_disb numeric(14,2),
    fed_share numeric(14,2),
    levin_share numeric(14,2),
    voter_reg_yn_flg character varying(1),
    voter_id_yn_flg character varying(1),
    gotv_yn_flg character varying(1),
    gen_campgn_yn_flg character varying(1),
    evt_amt_ytd numeric(14,2),
    add_desc character varying(100),
    fec_committee_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district numeric(2,0),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    amndt_ind character varying(1),
    tran_id character varying(32),
    memo_cd character varying(1),
    memo_text character varying(100),
    back_ref_tran_id character varying(32),
    back_ref_sched_id character varying(8),
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    filer_cmte_nm character varying(90),
    amndt_ind_desc character varying(15),
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    pye_st_desc character varying(20),
    catg_cd_desc character varying(40),
    voter_reg_yn_flg_desc character varying(40),
    voter_id_yn_flg_desc character varying(40),
    gotv_yn_flg_desc character varying(40),
    gen_campgn_yn_flg_desc character varying(40),
    cand_office_st_desc character varying(20),
    conduit_cmte_st_desc character varying(20),
    memo_cd_desc character varying(50),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_h6 OWNER TO fec;

--
-- Name: nml_sched_i; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_i (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(90),
    acct_num character varying(16),
    acct_nm character varying(90),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    ttl_receipts_per numeric(14,2),
    tranf_to_fed_alloctn_per numeric(14,2),
    tranf_to_st_local_pty_per numeric(14,2),
    direct_st_local_cand_supp_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    coh_bop numeric(14,2),
    receipts_per numeric(14,2),
    subttl_per numeric(14,2),
    disb_per numeric(14,2),
    coh_cop numeric(14,2),
    ttl_reciepts_ytd numeric(14,2),
    tranf_to_fed_alloctn_ytd numeric(14,2),
    tranf_to_st_local_pty_ytd numeric(14,2),
    direct_st_local_cand_supp_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    coh_boy numeric(14,2),
    receipts_ytd numeric(14,2),
    subttl_ytd numeric(14,2),
    disb_ytd numeric(14,2),
    coh_coy numeric(14,2),
    amndt_ind character varying(32),
    amndt_ind_desc character varying(15),
    other_acct_num character varying(9),
    tran_id character varying(32),
    receipt_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    rpt_pgi character varying(1),
    rpt_pgi_desc character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_i OWNER TO fec;

--
-- Name: nml_sched_l; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE nml_sched_l (
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    acct_nm character varying(90),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    item_receipts_per_pers numeric(14,2),
    unitem_receipts_per_pers numeric(14,2),
    ttl_receipts_per_pers numeric(14,2),
    other_receipts_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    voter_reg_amt_per numeric(14,2),
    voter_id_amt_per numeric(14,2),
    gotv_amt_per numeric(14,2),
    generic_campaign_amt_per numeric(14,2),
    ttl_disb_sub_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    coh_bop numeric(14,2),
    receipts_per numeric(14,2),
    subttl_per numeric(14,2),
    disb_per numeric(14,2),
    item_receipts_ytd_pers numeric(14,2),
    unitem_receipts_ytd_pers numeric(14,2),
    ttl_reciepts_ytd_pers numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    voter_reg_amt_ytd numeric(14,2),
    voter_id_amt_ytd numeric(14,2),
    gotv_amt_ytd numeric(14,2),
    generic_campaign_amt_ytd numeric(14,2),
    ttl_disb_ytd_sub numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    coh_boy numeric(14,2),
    receipts_ytd numeric(14,2),
    subttl_ytd numeric(14,2),
    disb_ytd numeric(14,2),
    coh_coy numeric(14,2),
    tran_id character varying(32),
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    filer_cmte_nm character varying(90),
    amndt_ind_desc character varying(15),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    other_acct_num character varying(9),
    rpt_yr numeric(4,0),
    file_num numeric(7,0),
    coh_cop numeric(14,2),
    orig_sub_id numeric(19,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE nml_sched_l OWNER TO fec;
