SET search_path = disclosure, pg_catalog;

--
-- Name: cand_cmte_linkage; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE cand_cmte_linkage (
    linkage_id numeric(12,0) NOT NULL,
    cand_id character varying(9) NOT NULL,
    cand_election_yr numeric(4,0) NOT NULL,
    fec_election_yr numeric(4,0) NOT NULL,
    cmte_id character varying(9),
    cmte_tp character varying(1),
    cmte_dsgn character varying(1),
    linkage_type character varying(1),
    user_id_entered numeric(12,0),
    date_entered timestamp without time zone,
    user_id_changed numeric(12,0),
    date_changed timestamp without time zone,
    cmte_count_cand_yr numeric(2,0),
    efile_paper_ind character varying(1),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE cand_cmte_linkage OWNER TO fec;

--
-- Name: cand_inactive; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE cand_inactive (
    cand_id character varying(9) NOT NULL,
    election_yr numeric(4,0) NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE cand_inactive OWNER TO fec;

--
-- Name: candidate_summary; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE candidate_summary (
    fec_election_yr numeric(4,0) NOT NULL,
    cand_election_yr numeric(4,0) NOT NULL,
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office character varying(1),
    cand_office_district character varying(2),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_id character varying(9) NOT NULL,
    cand_nm character varying(90),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_state character varying(2),
    cand_zip character varying(9),
    cand_ici_desc character varying(15),
    indv_item_contb numeric,
    indv_unitem_contb numeric,
    indv_contb numeric,
    oth_cmte_contb numeric,
    pty_cmte_contb numeric,
    cand_contb numeric,
    ttl_contb numeric,
    tranf_from_other_auth_cmte numeric,
    cand_loan numeric,
    oth_loans numeric,
    ttl_loans numeric,
    offsets_to_op_exp numeric,
    offsets_to_fndrsg numeric,
    offsets_to_legal_acctg numeric,
    other_receipts numeric,
    ttl_receipts numeric,
    op_exp_per numeric,
    exempt_legal_acctg_disb numeric,
    fndrsg_disb numeric,
    tranf_to_other_auth_cmte numeric,
    cand_loan_repymnt numeric,
    oth_loan_repymts numeric,
    ttl_loan_repymts numeric,
    indv_ref numeric,
    pty_cmte_ref numeric,
    oth_cmte_ref numeric,
    ttl_contb_ref numeric,
    other_disb_per numeric,
    ttl_disb numeric,
    net_contb numeric,
    net_op_exp numeric,
    coh_bop numeric,
    coh_cop numeric,
    debts_owed_by_cmte numeric,
    debts_owed_to_cmte numeric,
    cvg_start_dt character varying(10),
    cvg_end_dt character varying(10),
    efile_paper_ind character varying(1),
    cmte_count_cand_yr numeric(2,0),
    update_dt timestamp without time zone,
    activity character varying(1),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE candidate_summary OWNER TO fec;

--
-- Name: committee_summary; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE committee_summary (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_tp character varying(1),
    cmte_dsgn character varying(1),
    cmte_filing_freq character varying(1),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    tres_nm character varying(90),
    cand_id character varying(9),
    fec_election_yr character varying(32),
    indv_contb numeric,
    pty_cmte_contb numeric,
    oth_cmte_contb numeric,
    ttl_contb numeric,
    tranf_from_other_auth_cmte numeric,
    offsets_to_op_exp numeric,
    other_receipts numeric,
    ttl_receipts numeric,
    tranf_to_other_auth_cmte numeric,
    oth_loan_repymts numeric,
    indv_ref numeric,
    pol_pty_cmte_ref numeric,
    ttl_contb_ref numeric,
    other_disb numeric,
    ttl_disb numeric,
    net_contb numeric,
    net_op_exp numeric,
    coh_bop numeric,
    cvg_start_dt numeric,
    coh_cop numeric,
    cvg_end_dt numeric,
    debts_owed_by_cmte numeric,
    debts_owed_to_cmte numeric,
    indv_item_contb numeric,
    indv_unitem_contb numeric,
    oth_loans numeric,
    tranf_from_nonfed_acct numeric,
    tranf_from_nonfed_levin numeric,
    ttl_nonfed_tranf numeric,
    loan_repymts_received numeric,
    offsets_to_fndrsg numeric,
    offsets_to_legal_acctg numeric,
    fed_cand_contb_ref numeric,
    ttl_fed_receipts numeric,
    shared_fed_op_exp numeric,
    shared_nonfed_op_exp numeric,
    other_fed_op_exp numeric,
    ttl_op_exp numeric,
    fed_cand_cmte_contb numeric,
    indt_exp numeric,
    coord_exp_by_pty_cmte numeric,
    loans_made numeric,
    shared_fed_actvy_fed_shr numeric,
    shared_fed_actvy_nonfed numeric,
    non_alloc_fed_elect_actvy numeric,
    ttl_fed_elect_actvy numeric,
    ttl_fed_disb numeric,
    cand_cntb numeric,
    cand_loan numeric,
    ttl_loans numeric,
    op_exp numeric,
    cand_loan_repymnt numeric,
    ttl_loan_repymts numeric,
    oth_cmte_ref numeric,
    ttl_offsets_to_op_exp numeric,
    exempt_legal_acctg_disb numeric,
    fndrsg_disb numeric,
    item_ref_reb_ret numeric,
    subttl_ref_reb_ret numeric,
    unitem_ref_reb_ret numeric,
    item_other_ref_reb_ret numeric,
    unitem_other_ref_reb_ret numeric,
    subttl_other_ref_reb_ret numeric,
    item_other_income numeric,
    unitem_other_income numeric,
    exp_prior_yrs_subject_lim numeric,
    exp_subject_limits numeric,
    fed_funds numeric,
    item_convn_exp_disb numeric,
    item_other_disb numeric,
    subttl_convn_exp_disb numeric,
    ttl_exp_subject_limits numeric,
    unitem_convn_exp_disb numeric,
    unitem_other_disb numeric,
    ttl_communication_cost numeric,
    coh_boy numeric,
    coh_coy numeric,
    update_dt timestamp without time zone,
    org_tp character varying(1),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE committee_summary OWNER TO fec;

--
-- Name: dim_calendar_inf; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE dim_calendar_inf (
    calendar_pk numeric(8,0) NOT NULL,
    calendar_dt timestamp without time zone,
    calendar_mth_cd numeric(2,0),
    calendar_mth_cd_desc character varying(9),
    calendar_qtr_cd character varying(2),
    calendar_qtr_cd_desc character varying(5),
    calendar_yr numeric(4,0),
    fec_election_year numeric(4,0),
    calendar_mth_id numeric(6,0),
    calendar_mth_id_desc character varying(15),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE dim_calendar_inf OWNER TO fec;

--
-- Name: dim_race_inf; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE dim_race_inf (
    race_pk numeric(12,0) NOT NULL,
    office character varying(1),
    office_desc character varying(20),
    state character varying(2),
    state_desc character varying(20),
    district character varying(2),
    election_yr numeric(4,0),
    open_seat_flg character varying(1),
    create_date timestamp without time zone,
    election_type_id character varying(2),
    cycle_start_dt timestamp without time zone,
    cycle_end_dt timestamp without time zone,
    election_dt timestamp without time zone,
    senate_class numeric(1,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE dim_race_inf OWNER TO fec;
