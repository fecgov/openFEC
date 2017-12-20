SET search_path = disclosure, pg_catalog;

--
-- Name: cmte_valid_fec_yr; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE cmte_valid_fec_yr (
    valid_fec_yr_id numeric(12,0) NOT NULL,
    cmte_id character varying(9) NOT NULL,
    fec_election_yr numeric(4,0) NOT NULL,
    cmte_tp character varying(1),
    cmte_dsgn character varying(1),
    org_tp character varying(1),
    cmte_filing_freq character varying(1),
    cmte_pty_affiliation character varying(3),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    tres_nm character varying(90),
    connected_org_nm character varying(200),
    cmte_email character varying(90),
    cmte_url character varying(90),
    cmte_qual_start_dt timestamp without time zone,
    cmte_term_request_dt timestamp without time zone,
    cmte_term_dt timestamp without time zone,
    latest_receipt_dt timestamp without time zone,
    filed_cmte_tp_desc character varying(60),
    filed_cmte_dsgn_desc character varying(50),
    org_tp_desc character varying(40),
    cmte_filing_freq_desc character varying(30),
    cmte_pty_affiliation_desc character varying(50),
    user_id_entered numeric(6,0),
    date_entered timestamp without time zone NOT NULL,
    user_id_changed numeric(6,0),
    date_changed timestamp without time zone,
    ref_cmte_pk numeric(19,0),
    ref_lst_updt_dt timestamp without time zone,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE cmte_valid_fec_yr OWNER TO fec;
