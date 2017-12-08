SET search_path = staging, pg_catalog;

--
-- Name: ref_pty; Type: TABLE; Schema: staging; Owner: fec
--

CREATE TABLE ref_pty (
    pty_cd character varying(3),
    pty_desc character varying(50),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE ref_pty OWNER TO fec;

--
-- Name: ref_rpt_tp; Type: TABLE; Schema: staging; Owner: fec
--

CREATE TABLE ref_rpt_tp (
    rpt_tp_cd character varying(3),
    rpt_tp_desc character varying(30),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE ref_rpt_tp OWNER TO fec;
