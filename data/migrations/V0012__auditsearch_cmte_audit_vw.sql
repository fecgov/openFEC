SET search_path = auditsearch, pg_catalog;

--
-- Name: cmte_audit_vw; Type: VIEW; Schema: auditsearch; Owner: fec
--

CREATE VIEW cmte_audit_vw AS
 SELECT cmte_valid_fec_yr.cmte_id,
    cmte_valid_fec_yr.cmte_nm,
    cmte_valid_fec_yr.fec_election_yr,
    cmte_valid_fec_yr.cmte_dsgn,
    cmte_valid_fec_yr.cmte_tp,
        CASE
            WHEN ((cmte_valid_fec_yr.cmte_tp)::text = 'H'::text) THEN 'Congressional'::text
            WHEN ((cmte_valid_fec_yr.cmte_tp)::text = 'S'::text) THEN 'Congressional'::text
            WHEN ((cmte_valid_fec_yr.cmte_tp)::text = 'P'::text) THEN 'Presidential'::text
            WHEN ((cmte_valid_fec_yr.cmte_tp)::text = 'X'::text) THEN 'Party'::text
            WHEN ((cmte_valid_fec_yr.cmte_tp)::text = 'Y'::text) THEN 'Party'::text
            WHEN ((cmte_valid_fec_yr.cmte_tp)::text = 'Z'::text) THEN 'Party'::text
            WHEN ((cmte_valid_fec_yr.cmte_tp)::text = 'N'::text) THEN 'Pac'::text
            WHEN ((cmte_valid_fec_yr.cmte_tp)::text = 'Q'::text) THEN 'Pac'::text
            WHEN ((cmte_valid_fec_yr.cmte_tp)::text = 'I'::text) THEN 'IndExp'::text
            WHEN ((cmte_valid_fec_yr.cmte_tp)::text = 'O'::text) THEN 'Super Pac'::text
            ELSE NULL::text
        END AS cmte_desc
   FROM disclosure.cmte_valid_fec_yr
  WHERE ((cmte_valid_fec_yr.cmte_tp)::text = ANY ((ARRAY['H'::character varying, 'S'::character varying, 'P'::character varying, 'X'::character varying, 'Y'::character varying, 'Z'::character varying, 'N'::character varying, 'Q'::character varying, 'I'::character varying, 'O'::character varying])::text[]))
  ORDER BY cmte_valid_fec_yr.cmte_nm, cmte_valid_fec_yr.fec_election_yr;


ALTER TABLE cmte_audit_vw OWNER TO fec;

--
-- Name: finding; Type: TABLE; Schema: auditsearch; Owner: fec
--

CREATE TABLE finding (
    finding_pk character varying(130) NOT NULL,
    finding character varying(600),
    tier numeric,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE finding OWNER TO fec;

--
-- Name: finding_rel; Type: TABLE; Schema: auditsearch; Owner: fec
--

CREATE TABLE finding_rel (
    rel_pk character varying(130) NOT NULL,
    parent_finding_pk character varying(130),
    child_finding_pk character varying(130),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE finding_rel OWNER TO fec;
