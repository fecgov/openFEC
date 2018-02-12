SET search_path = public, pg_catalog;

--
-- 1)Name: ofec_audit_case_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--
DROP MATERIALIZED VIEW ofec_audit_case_mv;
CREATE MATERIALIZED VIEW ofec_audit_case_mv AS
WITH 
cmte_info AS (
    SELECT DISTINCT dc.cmte_id,
        dc.cmte_nm,
        dc.fec_election_yr,
        dc.cmte_dsgn,
        dc.cmte_tp,
        b.FILED_CMTE_TP_DESC::text AS cmte_desc
    FROM auditsearch.audit_case aa, disclosure.cmte_valid_fec_yr dc, staging.ref_filed_cmte_tp b
    WHERE btrim(aa.cmte_id) = dc.cmte_id 
      AND aa.election_cycle = dc.fec_election_yr
      AND dc.cmte_tp IN ('H', 'S', 'P', 'X', 'Y', 'Z', 'N', 'Q', 'I', 'O')
      AND dc.cmte_tp = b.filed_cmte_tp_cd
), 
cand_info AS (
    SELECT DISTINCT dc.cand_id,
        dc.cand_name,
        "substring"(dc.cand_name::text, 1,
            CASE
                WHEN strpos(dc.cand_name::text, ','::text) > 0 THEN strpos(dc.cand_name::text, ','::text) - 1
                ELSE strpos(dc.cand_name::text, ','::text)
            END) AS last_name,
        "substring"(dc.cand_name::text, strpos(dc.cand_name::text, ','::text) + 1) AS first_name,
        dc.fec_election_yr
    FROM auditsearch.audit_case aa JOIN disclosure.cand_valid_fec_yr dc
    ON (btrim(aa.cand_id) = dc.cand_id AND aa.election_cycle = dc.fec_election_yr)
),
audit_case_finding_info AS (
    SELECT
        audit_case_finding.audit_case_id::integer AS audit_case_id,
        audit_case_finding.parent_finding_pk::integer AS primary_category_id,
        audit_case_finding.child_finding_pk::integer AS sub_category_id
    FROM auditsearch.audit_case_finding
),
audit_case_init AS (
    SELECT
        '-1'::integer AS primary_category_id,
        '-2'::integer AS sub_category_id,
        ac.audit_case_id::integer AS audit_case_id,
        ac.election_cycle::integer AS cycle,
        ac.cmte_id AS committee_id,
        cmte_info.cmte_nm AS committee_name,
        cmte_info.cmte_dsgn AS committee_designation,
        cmte_info.cmte_tp AS committee_type,
        cmte_info.cmte_desc AS committee_description,
        ac.far_release_date::date AS far_release_date,
        ac.link_to_report,
        ac.audit_id::integer AS audit_id,
        ac.cand_id AS candidate_id,
        coalesce(cand_info.cand_name, 'N/A'::text) AS candidate_name
    FROM auditsearch.audit_case ac
    LEFT JOIN cmte_info ON cmte_info.cmte_id::text = ac.cmte_id::text 
    AND cmte_info.fec_election_yr = ac.election_cycle
    LEFT JOIN cand_info ON cand_info.cand_id::text = ac.cand_id::text 
    AND cand_info.fec_election_yr = ac.election_cycle
),
audit_case_sebset AS (
    SELECT 
        audit_case_finding_info.primary_category_id,
        audit_case_finding_info.sub_category_id,
        audit_case_finding_info.audit_case_id,
        auditsearch.audit_case.election_cycle::integer AS cycle,
        auditsearch.audit_case.cmte_id AS committee_id,
        cmte_info.cmte_nm AS committee_name,
        cmte_info.cmte_dsgn AS committee_designation,
        cmte_info.cmte_tp AS committee_type,
        cmte_info.cmte_desc AS committee_description,
        auditsearch.audit_case.far_release_date::date AS far_release_date,
        auditsearch.audit_case.link_to_report,
        auditsearch.audit_case.audit_id::integer AS audit_id,
        auditsearch.audit_case.cand_id AS candidate_id,
        coalesce(cand_info.cand_name, 'N/A'::text) AS candidate_name
    FROM audit_case_finding_info
    LEFT JOIN auditsearch.audit_case ON (audit_case_finding_info.audit_case_id = auditsearch.audit_case.audit_case_id::integer)
    LEFT JOIN cmte_info ON (cmte_info.cmte_id::text = auditsearch.audit_case.cmte_id::text 
         AND cmte_info.fec_election_yr = auditsearch.audit_case.election_cycle)
    LEFT JOIN cand_info ON (cand_info.cand_id::text = auditsearch.audit_case.cand_id::text 
         AND cand_info.fec_election_yr = auditsearch.audit_case.election_cycle)
),
audit_case_all AS (
    SELECT
        row_number() over () AS idx,
        primary_category_id,
        sub_category_id,
        audit_case_id,
        cycle,
        committee_id,
        committee_name,
        committee_designation,
        committee_type,
        committee_description,
        far_release_date,
        link_to_report,
        audit_id,
        candidate_id,
        candidate_name
    FROM audit_case_init
    UNION ALL
    SELECT
        3000+row_number() over () AS idx,
        primary_category_id,
        sub_category_id,
        audit_case_id,
        cycle,
        committee_id,
        committee_name,
        committee_designation,
        committee_type,
        committee_description,
        far_release_date,
        link_to_report,
        audit_id,
        candidate_id,
        candidate_name
    FROM audit_case_sebset
 )
SELECT
    idx,
    primary_category_id,
    sub_category_id,
    audit_case_id,
    cycle,
    committee_id,
    committee_name,
    committee_designation,
    committee_type,
    committee_description,
    far_release_date,
    link_to_report,
    audit_id,
    candidate_id,
    candidate_name
FROM audit_case_all
ORDER BY cycle DESC, committee_name
WITH DATA;
ALTER TABLE ofec_audit_case_mv OWNER TO fec;

CREATE UNIQUE INDEX ON ofec_audit_case_mv(idx);
CREATE INDEX ON ofec_audit_case_mv(audit_case_id);
CREATE INDEX ON ofec_audit_case_mv(primary_category_id,sub_category_id,audit_case_id);


--
-- 2)Name: ofec_audit_case_category_rel_mv; Type: MATERIALIZED VIEW; Schema: auditsearch; Owner: fec
--

DROP MATERIALIZED VIEW ofec_audit_case_category_rel_mv;
CREATE MATERIALIZED VIEW ofec_audit_case_category_rel_mv AS
SELECT 
    DISTINCT acf.audit_case_id::integer AS audit_case_id,
    acf.parent_finding_pk::integer AS primary_category_id,
    btrim(f.finding) AS primary_category_name
FROM auditsearch.audit_case_finding acf
LEFT JOIN auditsearch.finding f
ON (acf.parent_finding_pk = f.finding_pk)
ORDER BY audit_case_id, primary_category_name
WITH DATA;

ALTER TABLE ofec_audit_case_category_rel_mv OWNER TO fec;

CREATE UNIQUE INDEX ON ofec_audit_case_category_rel_mv(audit_case_id,primary_category_id);


--
-- 3)Name: ofec_audit_case_sub_category_rel_mv; Type: MATERIALIZED VIEW; Schema: auditsearch; Owner: fec
--

DROP MATERIALIZED VIEW ofec_audit_case_sub_category_rel_mv;
CREATE MATERIALIZED VIEW ofec_audit_case_sub_category_rel_mv AS
SELECT 
    acf.audit_case_id::integer AS audit_case_id,
    acf.parent_finding_pk::integer AS primary_category_id,
    btrim(pf.finding) AS primary_category_name,
    acf.child_finding_pk::integer AS sub_category_id,
    btrim(cf.finding) AS sub_category_name
FROM auditsearch.audit_case_finding acf 
LEFT JOIN auditsearch.finding pf ON (acf.parent_finding_pk = pf.finding_pK)
LEFT JOIN auditsearch.finding cf ON (acf.child_finding_pk = cf.finding_pK)
ORDER BY (acf.audit_case_id::integer), primary_category_name, sub_category_name
WITH DATA;

ALTER TABLE ofec_audit_case_sub_category_rel_mv OWNER TO fec;

CREATE UNIQUE INDEX ON ofec_audit_case_sub_category_rel_mv(audit_case_id,primary_category_id,sub_category_id);


--
-- 4)Name: ofec_committee_fulltext_audit_mv; Type: MATERIALIZED VIEW; Schema: auditsearch; Owner: fec
--
DROP MATERIALIZED VIEW ofec_committee_fulltext_audit_mv;
CREATE MATERIALIZED VIEW ofec_committee_fulltext_audit_mv AS
WITH
cmte_info AS (
    SELECT DISTINCT dc.cmte_id,
        dc.cmte_nm,
        dc.fec_election_yr,
        dc.cmte_dsgn,
        dc.cmte_tp,
        b.FILED_CMTE_TP_DESC::text AS cmte_desc
    FROM auditsearch.audit_case aa, disclosure.cmte_valid_fec_yr dc, staging.ref_filed_cmte_tp b
    WHERE btrim(aa.cmte_id) = dc.cmte_id 
      AND aa.election_cycle = dc.fec_election_yr
      AND dc.cmte_tp IN ('H', 'S', 'P', 'X', 'Y', 'Z', 'N', 'Q', 'I', 'O')
      AND dc.cmte_tp = b.filed_cmte_tp_cd
)
SELECT DISTINCT ON (cmte_id, cmte_nm)
    row_number() over () AS idx,
    cmte_id AS id,
    cmte_nm AS name,
CASE
    WHEN cmte_nm IS NOT NULL THEN
        setweight(to_tsvector(cmte_nm), 'A') ||
        setweight(to_tsvector(cmte_id), 'B')
    ELSE NULL::tsvector
END AS fulltxt
FROM cmte_info 
ORDER BY cmte_id
WITH DATA;

ALTER TABLE ofec_committee_fulltext_audit_mv OWNER TO fec;

CREATE UNIQUE INDEX ON ofec_committee_fulltext_audit_mv(idx);
CREATE INDEX ON ofec_committee_fulltext_audit_mv using gin(fulltxt);


--
-- 5)Name: ofec_candidate_fulltext_audit_mv; Type: MATERIALIZED VIEW; Schema: auditsearch; Owner: fec
--
DROP MATERIALIZED VIEW ofec_candidate_fulltext_audit_mv;
CREATE MATERIALIZED VIEW ofec_candidate_fulltext_audit_mv AS
WITH
cand_info AS (
    SELECT DISTINCT dc.cand_id,
        dc.cand_name,
        "substring"(dc.cand_name::text, 1,
            CASE
                WHEN strpos(dc.cand_name::text, ','::text) > 0 THEN strpos(dc.cand_name::text, ','::text) - 1
                ELSE strpos(dc.cand_name::text, ','::text)
            END) AS last_name,
        "substring"(dc.cand_name::text, strpos(dc.cand_name::text, ','::text) + 1) AS first_name,
        dc.fec_election_yr
    FROM auditsearch.audit_case aa JOIN disclosure.cand_valid_fec_yr dc
    ON (btrim(aa.cand_id) = dc.cand_id AND aa.election_cycle = dc.fec_election_yr)
)
SELECT DISTINCT ON (cand_id, cand_name)
    row_number() over () AS idx,
    cand_id AS id,
    cand_name AS name,
CASE
    WHEN cand_name IS NOT NULL THEN
        setweight(to_tsvector(cand_name), 'A') ||
        setweight(to_tsvector(cand_id), 'B')
    ELSE NULL::tsvector
END AS fulltxt
FROM cand_info
ORDER BY cand_id
WITH DATA;

ALTER TABLE ofec_candidate_fulltext_audit_mv OWNER TO fec;

CREATE UNIQUE INDEX ON ofec_candidate_fulltext_audit_mv(idx);
CREATE INDEX ON ofec_candidate_fulltext_audit_mv using gin(fulltxt);


GRANT ALL ON TABLE ofec_audit_case_mv TO fec;
GRANT SELECT ON TABLE ofec_audit_case_mv TO fec_read;


GRANT ALL ON TABLE ofec_audit_case_category_rel_mv TO fec;
GRANT SELECT ON TABLE ofec_audit_case_category_rel_mv TO fec_read;


GRANT ALL ON TABLE ofec_audit_case_sub_category_rel_mv TO fec;
GRANT SELECT ON TABLE ofec_audit_case_sub_category_rel_mv TO fec_read;


GRANT ALL ON TABLE ofec_committee_fulltext_audit_mv TO fec;
GRANT SELECT ON TABLE ofec_committee_fulltext_audit_mv TO fec_read;


GRANT ALL ON TABLE ofec_candidate_fulltext_audit_mv TO fec;
GRANT SELECT ON TABLE ofec_candidate_fulltext_audit_mv TO fec_read;

DROP VIEW auditsearch.cmte_audit_vw;
DROP VIEW auditsearch.cand_audit_vw;
