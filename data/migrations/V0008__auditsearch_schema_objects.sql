SET search_path = auditsearch, pg_catalog;

--
-- Name: audit_case; Type: TABLE; Schema: auditsearch; Owner: fec
--

CREATE TABLE audit_case (
    audit_case_id character varying(130) NOT NULL,
    audit_id character varying(10) NOT NULL,
    election_cycle numeric NOT NULL,
    far_release_date timestamp without time zone NOT NULL,
    link_to_report character varying(500),
    cmte_id character varying(130),
    cand_id character varying(130),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE audit_case OWNER TO fec;

--
-- Name: audit_case_finding; Type: TABLE; Schema: auditsearch; Owner: fec
--

CREATE TABLE audit_case_finding (
    audit_finding_pk character varying(130) NOT NULL,
    audit_case_id character varying(130),
    parent_finding_pk character varying(130),
    child_finding_pk character varying(130),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE audit_case_finding OWNER TO fec;
