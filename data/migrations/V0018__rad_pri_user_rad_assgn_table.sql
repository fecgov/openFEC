SET search_path = rad_pri_user, pg_catalog;

--
-- Name: rad_assgn; Type: TABLE; Schema: rad_pri_user; Owner: fec
--

CREATE TABLE rad_assgn (
    assgn_id numeric(38,0) NOT NULL,
    anlyst_id numeric(38,0),
    cmte_id character varying(9),
    rvw_prrty_id numeric(3,0),
    dte_of_entry timestamp without time zone,
    sugg_rvw_prrty_id numeric(3,0),
    last_rp_change_dt timestamp without time zone,
    last_srp_change_dt timestamp without time zone,
    sugg_rvw_prrty_notes character varying(255),
    prev_rvw_prrty_id numeric(3,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE rad_assgn OWNER TO fec;
