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
audit_case_1 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 1
    ORDER BY cycle DESC, committee_name
),
audit_case_2 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 2
    ORDER BY cycle DESC, committee_name
),
audit_case_3 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 3
    ORDER BY cycle DESC, committee_name
),
audit_case_4 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 4
    ORDER BY cycle DESC, committee_name
),
audit_case_5 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 5
    ORDER BY cycle DESC, committee_name
),
audit_case_6 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 6
    ORDER BY cycle DESC, committee_name
),
audit_case_7 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 7
    ORDER BY cycle DESC, committee_name
),
audit_case_8 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 8
    ORDER BY cycle DESC, committee_name
),
audit_case_9 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 9
    ORDER BY cycle DESC, committee_name
),
audit_case_13 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 13
    ORDER BY cycle DESC, committee_name
),
audit_case_14 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 14
    ORDER BY cycle DESC, committee_name
),
audit_case_15 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 15
    ORDER BY cycle DESC, committee_name
),
audit_case_16 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 16
    ORDER BY cycle DESC, committee_name
),
audit_case_17 AS (
    SELECT DISTINCT
        audit_case_finding_info.primary_category_id,
        '-2'::integer AS sub_category_id,
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
    WHERE primary_category_id = 17
    ORDER BY cycle DESC, committee_name
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
    UNION ALL
    SELECT         
        10000+row_number() over () AS idx,
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
    FROM audit_case_1
    UNION ALL
    SELECT         
        10500+row_number() over () AS idx,
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
    FROM audit_case_2
    UNION ALL
    SELECT         
        11000+row_number() over () AS idx,
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
    FROM audit_case_3
    UNION ALL
    SELECT         
        13000+row_number() over () AS idx,
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
    FROM audit_case_4
    UNION ALL
    SELECT         
        13500+row_number() over () AS idx,
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
    FROM audit_case_5
    UNION ALL
    SELECT         
        14000+row_number() over () AS idx,
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
    FROM audit_case_6
    UNION ALL
    SELECT         
        15000+row_number() over () AS idx,
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
    FROM audit_case_7
    UNION ALL
    SELECT         
        16000+row_number() over () AS idx,
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
    FROM audit_case_8
    UNION ALL
    SELECT         
        16500+row_number() over () AS idx,
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
    FROM audit_case_9
    UNION ALL
    SELECT         
        17000+row_number() over () AS idx,
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
    FROM audit_case_13
    UNION ALL
    SELECT         
        17500+row_number() over () AS idx,
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
    FROM audit_case_14
    UNION ALL
    SELECT         
        18000+row_number() over () AS idx,
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
    FROM audit_case_15
    UNION ALL
    SELECT         
        18500+row_number() over () AS idx,
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
    FROM audit_case_16
    UNION ALL
    SELECT         
        19000+row_number() over () AS idx,
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
    FROM audit_case_17
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
GRANT ALL ON TABLE ofec_audit_case_mv TO fec;
GRANT SELECT ON TABLE ofec_audit_case_mv TO fec_read;
