SET search_path = disclosure, pg_catalog;

--
-- Name: rad_cmte_analyst_search_vw; Type: VIEW; Schema: disclosure; Owner: fec
--

CREATE VIEW rad_cmte_analyst_search_vw AS
 SELECT ra.cmte_id,
    cv.cmte_nm,
    an.anlyst_id,
        CASE
            WHEN (an.branch_id = (1)::numeric) THEN 'Authorized'::text
            WHEN (an.branch_id = (2)::numeric) THEN 'Party/Non Pary'::text
            ELSE NULL::text
        END AS rad_branch,
    an.firstname,
    an.lastname,
    an.telephone_ext,
    an.valid_id AS anlyst_short_id,
    t.anlyst_title_desc AS anlyst_title,
    an.email AS anlyst_email
   FROM rad_pri_user.rad_anlyst an,
    rad_pri_user.rad_assgn ra,
    cmte_valid_fec_yr cv,
    rad_pri_user.rad_lkp_anlyst_title t
  WHERE ((an.status_id = (1)::numeric) AND (an.anlyst_id <> (999)::numeric) AND (cv.fec_election_yr = (((date_part('year'::text, now()))::integer + ((date_part('year'::text, now()))::integer % 2)))::numeric) AND (an.anlyst_id = ra.anlyst_id) AND ((ra.cmte_id)::text = (cv.cmte_id)::text) AND (an.anlyst_title_seq = t.anlyst_title_seq));


ALTER TABLE rad_cmte_analyst_search_vw OWNER TO fec;

--
-- Name: ref_ai; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE ref_ai (
    ai character varying(1),
    ai_order numeric(1,0),
    v_sum_sort_order numeric(1,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE ref_ai OWNER TO fec;

--
-- Name: ref_filing_desc; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE ref_filing_desc (
    filing_code character varying(10) NOT NULL,
    filing_code_desc character varying(90),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE ref_filing_desc OWNER TO fec;

--
-- Name: unverified_cand_cmte; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE unverified_cand_cmte (
    cand_cmte_id character varying(9) NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE unverified_cand_cmte OWNER TO fec;

--
-- Name: v_sum_and_det_sum_report; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE v_sum_and_det_sum_report (
    cvg_start_dt numeric(8,0),
    cmte_pk numeric(19,0),
    cvg_end_dt numeric(8,0),
    ttl_receipts numeric(14,2),
    tranf_from_other_auth_cmte numeric(14,2),
    indv_contb numeric(14,2),
    oth_cmte_contb numeric(14,2),
    oth_loans numeric(14,2),
    ttl_disb numeric(14,2),
    tranf_to_other_auth_cmte numeric(14,2),
    indv_ref numeric(14,2),
    oth_cmte_ref numeric(14,2),
    oth_loan_repymts numeric(14,2),
    coh_bop numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    cand_loan numeric(14,2),
    cand_loan_repymnt numeric(14,2),
    indv_unitem_contb numeric(14,2),
    pty_cmte_contb numeric(14,2),
    cand_cntb numeric(14,2),
    ttl_contb numeric(14,2),
    ttl_loans numeric(14,2),
    offsets_to_op_exp numeric(14,2),
    other_receipts numeric(14,2),
    pol_pty_cmte_contb numeric(14,2),
    ttl_contb_ref numeric(14,2),
    ttl_loan_repymts numeric(14,2),
    op_exp_per numeric(14,2),
    other_disb_per numeric(14,2),
    net_contb numeric(14,2),
    net_op_exp numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    all_loans_received_per numeric(14,2),
    fed_cand_contb_ref_per numeric(14,2),
    tranf_from_nonfed_acct_per numeric(14,2),
    tranf_from_nonfed_levin_per numeric(14,2),
    ttl_nonfed_tranf_per numeric(14,2),
    ttl_fed_receipts_per numeric(14,2),
    shared_fed_op_exp_per numeric(14,2),
    shared_nonfed_op_exp_per numeric(14,2),
    other_fed_op_exp_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    fed_cand_cmte_contb_per numeric(14,2),
    indt_exp_per numeric(14,2),
    coord_exp_by_pty_cmte_per numeric(14,2),
    loans_made_per numeric(14,2),
    shared_fed_actvy_fed_shr_per numeric(14,2),
    shared_fed_actvy_nonfed_per numeric(14,2),
    non_alloc_fed_elect_actvy_per numeric(14,2),
    ttl_fed_elect_actvy_per numeric(14,2),
    offsets_to_fndrsg numeric(14,2),
    offsets_to_legal_acctg numeric(14,2),
    ttl_offsets_to_op_exp numeric(14,2),
    fndrsg_disb numeric(14,2),
    exempt_legal_acctg_disb numeric(14,2),
    cmte_id character varying(9),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    receipt_dt timestamp without time zone,
    orig_sub_id numeric(19,0) NOT NULL,
    election_st character varying(2),
    rpt_pgi character varying(5),
    form_tp_cd character varying(8) NOT NULL,
    fed_funds_per numeric(14,2),
    item_ref_reb_ret_per numeric(14,2),
    unitem_ref_reb_ret_per numeric(14,2),
    subttl_ref_reb_ret_per numeric(14,2),
    item_other_ref_reb_ret_per numeric(14,2),
    unitem_other_ref_reb_ret_per numeric(14,2),
    subttl_other_ref_reb_ret_per numeric(14,2),
    item_other_income_per numeric(14,2),
    unitem_other_income_per numeric(14,2),
    item_convn_exp_disb_per numeric(14,2),
    unitem_convn_exp_disb_per numeric(14,2),
    subttl_convn_exp_disb_per numeric(14,2),
    tranf_to_st_local_pty_per numeric(14,2),
    direct_st_local_cand_supp_per numeric(14,2),
    voter_reg_amt_per numeric(14,2),
    voter_id_amt_per numeric(14,2),
    gotv_amt_per numeric(14,2),
    generic_campaign_amt_per numeric(14,2),
    tranf_to_fed_alloctn_per numeric(14,2),
    item_other_disb_per numeric(14,2),
    unitem_other_disb_per numeric(14,2),
    ttl_fed_disb_per numeric(14,2),
    coh_boy numeric(14,2),
    coh_coy numeric(14,2),
    exp_subject_limits_per numeric(14,2),
    exp_prior_yrs_subject_lim_per numeric(14,2),
    ttl_exp_subject_limits numeric(14,2),
    ttl_communication_cost numeric(14,2),
    oppos_pers_fund_amt numeric(14,2),
    hse_pers_funds_amt numeric(14,2),
    sen_pers_funds_amt numeric(14,2),
    loan_repymts_received_per numeric(14,2),
    file_num numeric(7,0),
    indv_item_contb numeric(14,2),
    last_update_date timestamp without time zone,
    prev_sub_id numeric(19,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE v_sum_and_det_sum_report OWNER TO fec;
