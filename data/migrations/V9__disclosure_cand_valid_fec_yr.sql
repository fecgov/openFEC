SET search_path = disclosure, pg_catalog;

--
-- Name: cand_valid_fec_yr; Type: TABLE; Schema: disclosure; Owner: fec
--

CREATE TABLE cand_valid_fec_yr (
    cand_valid_yr_id numeric(12,0) NOT NULL,
    cand_id character varying(9),
    fec_election_yr numeric(4,0),
    cand_election_yr numeric(4,0),
    cand_status character varying(1),
    cand_ici character varying(1),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    cand_pty_affiliation character varying(3),
    cand_name character varying(90),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_state character varying(2),
    cand_zip character varying(9),
    race_pk numeric,
    lst_updt_dt timestamp without time zone,
    latest_receipt_dt timestamp without time zone,
    user_id_entered numeric(6,0),
    date_entered timestamp without time zone NOT NULL,
    user_id_changed numeric(6,0),
    date_changed timestamp without time zone,
    ref_cand_pk numeric(19,0),
    ref_lst_updt_dt timestamp without time zone,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE cand_valid_fec_yr OWNER TO fec;
