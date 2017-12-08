SET search_path = rad_pri_user, pg_catalog;

--
-- Name: rad_anlyst; Type: TABLE; Schema: rad_pri_user; Owner: fec
--

CREATE TABLE rad_anlyst (
    anlyst_id numeric(38,0) NOT NULL,
    valid_id character varying(3),
    firstname character varying(255),
    middlename character varying(255),
    lastname character varying(255),
    username character varying(255),
    email character varying(255),
    role_id numeric(3,0),
    branch_id numeric(3,0),
    status_id numeric(3,0),
    create_dt timestamp without time zone,
    last_upd_dt timestamp without time zone,
    grade_id numeric(3,0),
    mntr_val numeric(6,3),
    spcl_prjct_val numeric(6,3),
    wf_notification_email character varying(255),
    telephone_ext numeric(4,0),
    anlyst_title_seq numeric(19,0),
    create_id numeric(38,0),
    update_id numeric(38,0),
    both_branches character varying(1),
    appr_priv character(1),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE rad_anlyst OWNER TO fec;

--
-- Name: rad_lkp_anlyst_title; Type: TABLE; Schema: rad_pri_user; Owner: fec
--

CREATE TABLE rad_lkp_anlyst_title (
    anlyst_title_seq numeric(19,0) NOT NULL,
    anlyst_title_desc character varying(255) NOT NULL,
    created_id numeric(38,0) NOT NULL,
    created_dt timestamp without time zone,
    updated_id numeric(38,0) NOT NULL,
    updated__dt timestamp without time zone NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE rad_lkp_anlyst_title OWNER TO fec;
