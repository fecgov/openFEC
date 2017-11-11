-- 1) M_View: public.ofec_audit_case_mv
-- DROP MATERIALIZED VIEW public.ofec_audit_case_mv;
DROP MATERIALIZED VIEW if exists ofec_audit_case_mv_tmp cascade;
CREATE MATERIALIZED VIEW ofec_audit_case_mv_tmp AS
WITH cmte_info AS (
    SELECT DISTINCT ON (cmte_audit_vw.cmte_id, cmte_audit_vw.fec_election_yr) cmte_audit_vw.cmte_id,
        cmte_audit_vw.fec_election_yr,
        cmte_audit_vw.cmte_nm,
        cmte_audit_vw.cmte_dsgn,
        cmte_audit_vw.cmte_tp,
        cmte_audit_vw.cmte_desc
    FROM auditsearch.cmte_audit_vw
), cand_info AS (
    SELECT DISTINCT ON (cand_audit_vw.cand_id, cand_audit_vw.fec_election_yr) cand_audit_vw.cand_id,
        cand_audit_vw.fec_election_yr,
        cand_audit_vw.cand_name
    FROM auditsearch.cand_audit_vw
)
SELECT 
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
    coalesce(cand_info.cand_name, 'No authorized candidate'::text) as candidate_name
FROM auditsearch.audit_case ac
    LEFT JOIN cmte_info ON cmte_info.cmte_id::text = ac.cmte_id::text AND cmte_info.fec_election_yr = ac.election_cycle
    LEFT JOIN cand_info ON cand_info.cand_id::text = ac.cand_id::text AND cand_info.fec_election_yr = ac.election_cycle
ORDER BY ac.election_cycle DESC
WITH DATA;

create unique index on ofec_audit_case_mv_tmp(audit_case_id);


-- 2)M_View: public.ofec_audit_case_category_rel_mv
-- DROP MATERIALIZED VIEW public.ofec_audit_case_category_rel_mv;
DROP MATERIALIZED VIEW if exists ofec_audit_case_category_rel_mv_tmp cascade;
CREATE MATERIALIZED VIEW ofec_audit_case_category_rel_mv_tmp AS
SELECT 
    DISTINCT acf.audit_case_id::integer AS audit_case_id,
    acf.parent_finding_pk::integer AS primary_category_id,
    btrim(f.finding) as primary_category_name
FROM auditsearch.audit_case_finding acf 
LEFT JOIN auditsearch.finding f
ON (acf.PARENT_FINDING_PK = f.FINDING_PK) 
ORDER BY audit_case_id, (acf.parent_finding_pk::integer)
WITH DATA;

create unique index on ofec_audit_case_category_rel_mv_tmp(audit_case_id,primary_category_id);


--3)M_View: public.ofec_audit_case_sub_category_rel_mv
-- DROP MATERIALIZED VIEW public.ofec_audit_case_sub_category_rel_mv;
DROP MATERIALIZED VIEW if exists ofec_audit_case_sub_category_rel_mv_tmp cascade;
CREATE MATERIALIZED VIEW ofec_audit_case_sub_category_rel_mv_tmp AS
SELECT acf.audit_case_id::integer AS audit_case_id,
    acf.parent_finding_pk::integer AS primary_category_id,
    acf.child_finding_pk::integer AS sub_category_id,
    btrim(f.finding::text) AS sub_category_name
FROM auditsearch.audit_case_finding acf
LEFT JOIN auditsearch.finding f 
ON acf.child_finding_pk = f.finding_pk
ORDER BY (acf.audit_case_id::integer), (acf.parent_finding_pk::integer), (acf.child_finding_pk::integer)
WITH DATA;

create unique index on ofec_audit_case_sub_category_rel_mv_tmp(audit_case_id,primary_category_id,sub_category_id);


--4)M_View: public.ofec_audit_case_arg_category_mv
-- DROP MATERIALIZED VIEW public.ofec_audit_case_arg_category_mv;
DROP MATERIALIZED VIEW if exists ofec_audit_case_arg_category_mv_tmp cascade;
CREATE MATERIALIZED VIEW ofec_audit_case_arg_category_mv_tmp AS
SELECT
    acf.parent_finding_pk::integer AS primary_category_id,
    acf.child_finding_pk::integer AS sub_category_id,   
    poac.audit_case_id AS audit_case_id,
    poac.cycle AS cycle,
    poac.committee_id,
    poac.committee_name,
    poac.committee_designation,
    poac.committee_type,
    poac.committee_description,
    poac.far_release_date,
    poac.link_to_report,
    poac.audit_id,
    poac.candidate_id,
    poac.candidate_name
FROM auditsearch.audit_case_finding acf
JOIN public.ofec_audit_case_mv_tmp poac
ON(acf.audit_case_id::integer = poac.audit_case_id)
ORDER BY cycle DESC
WITH DATA;

create unique index on ofec_audit_case_arg_category_mv_tmp(primary_category_id,sub_category_id,audit_case_id);


--5)View: auditsearch.cmte_audit_vw
--DROP VIEW auditsearch.cmte_audit_vw;
CREATE OR REPLACE VIEW auditsearch.cmte_audit_vw AS
SELECT dc.cmte_id,
    dc.cmte_nm,
    dc.fec_election_yr,
    dc.cmte_dsgn,
    dc.cmte_tp,
        CASE
            WHEN dc.cmte_tp::text = 'H'::text THEN 'Congressional'::text
            WHEN dc.cmte_tp::text = 'S'::text THEN 'Congressional'::text
            WHEN dc.cmte_tp::text = 'P'::text THEN 'Presidential'::text
            WHEN dc.cmte_tp::text = 'X'::text THEN 'Party'::text
            WHEN dc.cmte_tp::text = 'Y'::text THEN 'Party'::text
            WHEN dc.cmte_tp::text = 'Z'::text THEN 'Party'::text
            WHEN dc.cmte_tp::text = 'N'::text THEN 'Pac'::text
            WHEN dc.cmte_tp::text = 'Q'::text THEN 'Pac'::text
            WHEN dc.cmte_tp::text = 'I'::text THEN 'IndExp'::text
            WHEN dc.cmte_tp::text = 'O'::text THEN 'Super Pac'::text
            ELSE NULL::text
        END AS cmte_desc
    FROM auditsearch.audit_case aa JOIN disclosure.cmte_valid_fec_yr dc 
    ON(aa.cmte_id = dc.cmte_id)
WHERE dc.cmte_tp::text = ANY (ARRAY['H'::character varying, 'S'::character varying, 'P'::character varying, 'X'::character varying, 'Y'::character varying, 'Z'::character varying, 'N'::character varying, 'Q'::character varying, 'I'::character varying, 'O'::character varying]::text[])
ORDER BY dc.cmte_nm, dc.fec_election_yr;


--6)View: auditsearch.cand_audit_vw
--DROP VIEW auditsearch.cand_audit_vw;
CREATE OR REPLACE VIEW auditsearch.cand_audit_vw AS
SELECT dc.cand_id,
    dc.cand_name,
    "substring"(dc.cand_name::text, 1,
        CASE
            WHEN strpos(dc.cand_name::text, ','::text) > 0 THEN strpos(dc.cand_name::text, ','::text) - 1
            ELSE strpos(dc.cand_name::text, ','::text)
        END) AS last_name,
    "substring"(dc.cand_name::text, strpos(dc.cand_name::text, ','::text) + 1) AS first_name,
    dc.fec_election_yr
   FROM auditsearch.audit_case aa JOIN disclosure.cand_valid_fec_yr dc
   ON(aa.cand_id = dc.cand_id)
ORDER BY dc.cand_name, dc.fec_election_yr;


--7)View: auditsearch.finding_vw
--DROP VIEW auditsearch.finding_vw;
CREATE OR REPLACE VIEW auditsearch.finding_vw AS
SELECT 
    finding_pk::integer AS primary_category_id,
    btrim(finding::text) AS primary_category_name,
    tier::integer AS tier
FROM auditsearch.finding
WHERE tier::integer=1
ORDER BY (btrim(finding::text));


--8)View: auditsearch.finding_rel_vw
--DROP VIEW auditsearch.finding_rel_vw;
CREATE OR REPLACE VIEW auditsearch.finding_rel_vw AS
SELECT 
    fr.parent_finding_pk::integer AS primary_category_id,
    fr.child_finding_pk::integer AS sub_category_id,
    btrim(fs.finding) AS primary_category_name,
    btrim(f.finding) AS sub_category_name
FROM auditsearch.finding_rel fr
LEFT JOIN auditsearch.finding f ON fr.child_finding_pk = f.finding_pk
LEFT JOIN auditsearch.finding fs ON fr.parent_finding_pk = fs.finding_pk
ORDER BY (fr.parent_finding_pk::integer), (fr.child_finding_pk::integer);


