SET search_path = auditsearch, pg_catalog;

--
-- Name: cand_audit_vw; Type: VIEW; Schema: auditsearch; Owner: fec
--

CREATE VIEW cand_audit_vw AS
 SELECT cand_valid_fec_yr.cand_id,
    cand_valid_fec_yr.cand_name,
    "substring"((cand_valid_fec_yr.cand_name)::text, 1,
        CASE
            WHEN (strpos((cand_valid_fec_yr.cand_name)::text, ','::text) > 0) THEN (strpos((cand_valid_fec_yr.cand_name)::text, ','::text) - 1)
            ELSE strpos((cand_valid_fec_yr.cand_name)::text, ','::text)
        END) AS last_name,
    "substring"((cand_valid_fec_yr.cand_name)::text, (strpos((cand_valid_fec_yr.cand_name)::text, ','::text) + 1)) AS first_name,
    cand_valid_fec_yr.fec_election_yr
   FROM disclosure.cand_valid_fec_yr
  ORDER BY cand_valid_fec_yr.cand_name, cand_valid_fec_yr.fec_election_yr;


ALTER TABLE cand_audit_vw OWNER TO fec;
