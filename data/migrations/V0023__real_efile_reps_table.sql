SET search_path = real_efile, pg_catalog;

--
-- Name: reps; Type: TABLE; Schema: real_efile; Owner: fec
--

CREATE TABLE reps (
    repid numeric(12,0) NOT NULL,
    form character varying(4),
    comid character varying(9),
    com_name character varying(200),
    filed_date date,
    "timestamp" timestamp without time zone,
    from_date date,
    through_date date,
    md5 character varying(32),
    superceded numeric,
    previd numeric,
    rptcode character varying(4),
    ef character varying(1),
    version character varying(4),
    filed character varying(1),
    rptnum numeric,
    starting numeric,
    ending numeric,
    create_dt timestamp without time zone
);


ALTER TABLE reps OWNER TO fec;
