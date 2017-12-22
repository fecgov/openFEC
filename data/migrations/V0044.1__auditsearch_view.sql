SET search_path = auditsearch, pg_catalog;

--
-- 1)Name: cmte_audit_vw; Type: VIEW; Schema: auditsearch; Owner: fec
--

CREATE OR REPLACE VIEW cmte_audit_vw AS
SELECT dc.cmte_id,
    dc.cmte_nm,
    dc.fec_election_yr,
    dc.cmte_dsgn,
    dc.cmte_tp,
    (
        SELECT DISTINCT FILED_CMTE_TP_DESC::text
        FROM STAGING.REF_FILED_CMTE_TP
        WHERE FILED_CMTE_TP_CD = dc.cmte_tp
    ) AS cmte_desc
FROM auditsearch.audit_case aa, disclosure.cmte_valid_fec_yr dc
WHERE aa.cmte_id = dc.cmte_id
    AND dc.cmte_tp IN ('H', 'S', 'P', 'X', 'Y', 'Z', 'N', 'Q', 'I', 'O')
ORDER BY dc.cmte_nm, dc.fec_election_yr;

SELECT dc.cmte_id,
    dc.cmte_nm,
    dc.fec_election_yr,
    dc.cmte_dsgn,
    dc.cmte_tp,
    b.FILED_CMTE_TP_DESC::text AS cmte_desc
FROM audit_case aa, disclosure.cmte_valid_fec_yr dc, STAGING.REF_FILED_CMTE_TP b
WHERE aa.cmte_id = dc.cmte_id
    AND dc.cmte_tp IN ('H','S', 'P', 'X', 'Y', 'Z', 'N', 'Q', 'I', 'O')
    AND dc.cmte_tp = B.FILED_CMTE_TP_CD
ORDER BY dc.cmte_nm, dc.fec_election_yr;

ALTER TABLE cmte_audit_vw OWNER TO fec;

GRANT ALL ON TABLE cmte_audit_vw TO fec;
GRANT SELECT ON TABLE cmte_audit_vw TO fec_read;
GRANT SELECT ON TABLE cmte_audit_vw TO openfec_read;

--
--2) Name: cand_audit_vw; Type: VIEW; Schema: auditsearch; Owner: fec
--

CREATE OR REPLACE VIEW cand_audit_vw AS
SELECT dc.cand_id,
    dc.cand_name,
    "substring"(dc.cand_name::text, 1,
        CASE
            WHEN strpos(dc.cand_name::text, ','::text) > 0 THEN strpos(dc.cand_name::text, ','::text) - 1
            ELSE strpos(dc.cand_name::text, ','::text)
        END) AS last_name,
    "substring"(dc.cand_name::text, strpos(dc.cand_name::text, ','::text) + 1) AS first_name,
    dc.fec_election_yr
    FROM audit_case aa JOIN disclosure.cand_valid_fec_yr dc
    ON(aa.cand_id = dc.cand_id)
ORDER BY dc.cand_name, dc.fec_election_yr;

ALTER TABLE cand_audit_vw OWNER TO fec;

GRANT ALL ON TABLE cand_audit_vw TO fec;
GRANT SELECT ON TABLE cand_audit_vw TO fec_read;
GRANT SELECT ON TABLE cand_audit_vw TO openfec_read;

--
--3) Name: finding_vw; Type: VIEW; Schema: auditsearch; Owner: fec
--

CREATE OR REPLACE VIEW finding_vw AS
SELECT
    finding_pk::integer AS primary_category_id,
    btrim(finding::text) AS primary_category_name,
    tier::integer AS tier
FROM finding
WHERE tier::integer=1
ORDER BY (btrim(finding::text));

ALTER TABLE finding_vw OWNER TO fec;

GRANT ALL ON TABLE finding_vw TO fec;
GRANT SELECT ON TABLE finding_vw TO fec_read;
GRANT SELECT ON TABLE finding_vw TO openfec_read;


--
-- 4)Name: finding_rel_vw; Type: VIEW; Schema: auditsearch; Owner: fec
--

CREATE OR REPLACE VIEW finding_rel_vw AS
SELECT
    fr.parent_finding_pk::integer AS primary_category_id,
    fr.child_finding_pk::integer AS sub_category_id,
    btrim(fs.finding) AS primary_category_name,
    btrim(f.finding) AS sub_category_name
FROM finding_rel fr
LEFT JOIN finding f ON fr.child_finding_pk = f.finding_pk
LEFT JOIN finding fs ON fr.parent_finding_pk = fs.finding_pk
ORDER BY (fr.parent_finding_pk::integer), sub_category_name;

ALTER TABLE finding_rel_vw OWNER TO fec;

GRANT ALL ON TABLE finding_rel_vw TO fec;
GRANT SELECT ON TABLE finding_rel_vw TO fec_read;
GRANT SELECT ON TABLE finding_rel_vw TO openfec_read;

