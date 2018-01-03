SET search_path = public, pg_catalog;

--
-- Name: checkpointtable; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE checkpointtable (
    group_name character varying(8) NOT NULL,
    group_key bigint NOT NULL,
    seqno integer,
    rba bigint NOT NULL,
    audit_ts character varying(29),
    create_ts timestamp without time zone NOT NULL,
    last_update_ts timestamp without time zone NOT NULL,
    current_dir character varying(255) NOT NULL,
    log_bsn character varying(128),
    log_csn character varying(128),
    log_xid character varying(128),
    log_cmplt_csn character varying(128),
    log_cmplt_xids character varying(2000),
    version integer
);


ALTER TABLE checkpointtable OWNER TO fec;

--
-- Name: checkpointtable_lox; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE checkpointtable_lox (
    group_name character varying(8) NOT NULL,
    group_key bigint NOT NULL,
    log_cmplt_csn character varying(128) NOT NULL,
    log_cmplt_xids_seq integer NOT NULL,
    log_cmplt_xids character varying(2000) NOT NULL
);


ALTER TABLE checkpointtable_lox OWNER TO fec;

--
-- Name: checkpointtable_rj; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE checkpointtable_rj (
    group_name character varying(8),
    group_key bigint,
    seqno integer,
    rba bigint,
    audit_ts character varying(29),
    create_ts timestamp without time zone,
    last_update_ts timestamp without time zone,
    current_dir character varying(255),
    log_bsn character varying(128),
    log_csn character varying(128),
    log_xid character varying(128),
    log_cmplt_csn character varying(128),
    log_cmplt_xids character varying(2000),
    version integer
);


ALTER TABLE checkpointtable_rj OWNER TO fec;
