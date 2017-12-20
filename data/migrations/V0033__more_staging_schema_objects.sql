SET search_path = staging, pg_catalog;

--
-- Name: operations_log; Type: TABLE; Schema: staging; Owner: fec
--

CREATE TABLE operations_log (
    sub_id numeric(19,0) NOT NULL,
    status_num numeric(3,0),
    cand_cmte_id character varying(9),
    filer_tp character varying(1),
    beg_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    rpt_yr numeric(4,0),
    amndt_ind character varying(1),
    rpt_tp character varying(3),
    scan_dt timestamp without time zone,
    pass_1_entry_dt timestamp without time zone,
    pass_1_entry_id numeric(3,0),
    pass_1_coding_id numeric(3,0),
    pass_1_verified_dt timestamp without time zone,
    pass_1_verified_id numeric(3,0),
    pass_3_coding_dt date,
    pass_3_coding_id numeric(3,0),
    pass_3_num_additions numeric(7,0),
    pass_3_num_changes numeric(7,0),
    pass_3_num_deletes numeric(7,0),
    pass_3_entry_began_dt date,
    pass_3_entry_done_dt date,
    pass_3_entry_id numeric(3,0),
    error_processing_dt timestamp without time zone,
    rad_sent_dt timestamp without time zone,
    error_listing_review_dt timestamp without time zone,
    error_listing_analyst_id character varying(3),
    error_listing_time numeric(7,0),
    basic_review_dt timestamp without time zone,
    basic_review_analyst_id character varying(3),
    basic_review_time numeric(7,0),
    batch_error_listing_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    beginning_coverage_dt timestamp without time zone,
    ending_coverage_dt timestamp without time zone,
    create_dt timestamp without time zone,
    last_change_dt timestamp without time zone,
    batch_num numeric(5,0),
    num_tran numeric(7,0),
    batch_close_dt timestamp without time zone,
    return_dt timestamp without time zone,
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE operations_log OWNER TO fec;

--
-- Name: ref_cand_ici; Type: TABLE; Schema: staging; Owner: fec
--

CREATE TABLE ref_cand_ici (
    cand_ici_cd character varying(1),
    cand_ici_desc character varying(15),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE ref_cand_ici OWNER TO fec;

--
-- Name: ref_cand_office; Type: TABLE; Schema: staging; Owner: fec
--

CREATE TABLE ref_cand_office (
    cand_office_cd character varying(1),
    cand_office_desc character varying(20),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE ref_cand_office OWNER TO fec;

--
-- Name: ref_contribution_limits; Type: TABLE; Schema: staging; Owner: fec
--

CREATE TABLE ref_contribution_limits (
    contrib_limit_id numeric(7,0) NOT NULL,
    donor character varying(40),
    donor_id numeric(2,0),
    cycle numeric(4,0),
    cand_cmte_per_election numeric(8,2),
    ssf_nonconnect_per_yr numeric(8,2),
    nat_pty_per_yr character varying(20),
    st_district_local_pty_per_yr character varying(20),
    overall_bi_limit_cand_pac_pty numeric(8,2),
    overall_bi_limit_cand numeric(8,2),
    overall_bi_limit_pac_pty numeric(8,2),
    sublimit_pacs_st_local_pty numeric(8,2),
    pty_senate_cand_per_election numeric(8,2),
    overall_an_limit_cand_pac_pty numeric(8,2),
    additional_nat_pty_accounts numeric(8,2),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE ref_contribution_limits OWNER TO fec;

--
-- Name: ref_filed_cmte_dsgn; Type: TABLE; Schema: staging; Owner: fec
--

CREATE TABLE ref_filed_cmte_dsgn (
    filed_cmte_dsgn_cd character varying(1),
    filed_cmte_dsgn_desc character varying(90),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE ref_filed_cmte_dsgn OWNER TO fec;

--
-- Name: ref_filed_cmte_tp; Type: TABLE; Schema: staging; Owner: fec
--

CREATE TABLE ref_filed_cmte_tp (
    filed_cmte_tp_cd character varying(1),
    filed_cmte_tp_desc character varying(58),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE ref_filed_cmte_tp OWNER TO fec;

--
-- Name: ref_st; Type: TABLE; Schema: staging; Owner: fec
--

CREATE TABLE ref_st (
    st_desc character varying(40),
    st character varying(2),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE ref_st OWNER TO fec;
