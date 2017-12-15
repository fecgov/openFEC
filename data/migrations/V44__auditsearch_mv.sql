-- 1) M_View: public.ofec_audit_case_mv
DROP MATERIALIZED VIEW if exists ofec_audit_case_mv cascade;
CREATE MATERIALIZED VIEW ofec_audit_case_mv AS
WITH 
cmte_info AS (
    SELECT DISTINCT ON (cmte_audit_vw.cmte_id, cmte_audit_vw.fec_election_yr)          cmte_audit_vw.cmte_id,
        cmte_audit_vw.fec_election_yr,
        cmte_audit_vw.cmte_nm,
        cmte_audit_vw.cmte_dsgn,
        cmte_audit_vw.cmte_tp,
        cmte_audit_vw.cmte_desc
    FROM auditsearch.cmte_audit_vw
), 
cand_info AS (
    SELECT DISTINCT ON (cand_audit_vw.cand_id, cand_audit_vw.fec_election_yr)          cand_audit_vw.cand_id,
        cand_audit_vw.fec_election_yr,
        cand_audit_vw.cand_name
    FROM auditsearch.cand_audit_vw
),
audit_case_finding_info AS (
    SELECT
        audit_case_finding.audit_case_id::integer as audit_case_id,    
        audit_case_finding.parent_finding_pk::integer as primary_category_id,
        audit_case_finding.child_finding_pk::integer as sub_category_id
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
        coalesce(cand_info.cand_name, 'No authorized candidate'::text) AS candidate_name
    FROM auditsearch.audit_case ac
    LEFT JOIN cmte_info ON cmte_info.cmte_id::text = ac.cmte_id::text AND cmte_info.fec_election_yr = ac.election_cycle
    LEFT JOIN cand_info ON cand_info.cand_id::text = ac.cand_id::text AND cand_info.fec_election_yr = ac.election_cycle
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
        coalesce(cand_info.cand_name, 'No authorized candidate'::text) AS candidate_name
    FROM audit_case_finding_info
    LEFT JOIN auditsearch.audit_case ON (audit_case_finding_info.audit_case_id= auditsearch.audit_case.audit_case_id::integer)
    LEFT JOIN cmte_info ON (cmte_info.cmte_id::text = auditsearch.audit_case.cmte_id::text and cmte_info.fec_election_yr = auditsearch.audit_case.election_cycle)
    LEFT JOIN cand_info ON (cand_info.cand_id::text = auditsearch.audit_case.cand_id::text and cand_info.fec_election_yr = auditsearch.audit_case.election_cycle)
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
ORDER BY cycle DESC
WITH DATA;

create unique index on ofec_audit_case_mv(idx);
create index on ofec_audit_case_mv(audit_case_id);
create index on ofec_audit_case_mv(primary_category_id,sub_category_id,audit_case_id);


-- 2)M_View: public.ofec_audit_case_category_rel_mv
DROP MATERIALIZED VIEW if exists ofec_audit_case_category_rel_mv cascade;
CREATE MATERIALIZED VIEW ofec_audit_case_category_rel_mv AS
SELECT 
    DISTINCT acf.audit_case_id::integer AS audit_case_id,
    acf.parent_finding_pk::integer AS primary_category_id,
    btrim(f.finding) as primary_category_name
FROM auditsearch.audit_case_finding acf 
LEFT JOIN auditsearch.finding f
ON (acf.parent_finding_pk = f.finding_pk) 
ORDER BY audit_case_id, primary_category_name
WITH DATA;

create unique index on ofec_audit_case_category_rel_mv(audit_case_id,primary_category_id);


--3)M_View: public.ofec_audit_case_sub_category_rel_mv
DROP MATERIALIZED VIEW if exists ofec_audit_case_sub_category_rel_mv cascade;
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

create unique index on ofec_audit_case_sub_category_rel_mv(audit_case_id,primary_category_id,sub_category_id);


--4)M_View: public.ofec_committee_fulltext_audit_mv
drop materialized view if exists ofec_committee_fulltext_audit_mv;
create materialized view ofec_committee_fulltext_audit_mv as
select distinct on (cmte_id, cmte_nm)
    row_number() over () as idx,
    cmte_id as id,
    cmte_nm as name,
case
    when cmte_nm is not null then
        setweight(to_tsvector(cmte_nm), 'A') ||
        setweight(to_tsvector(cmte_id), 'B')
    else null::tsvector
end as fulltxt
from auditsearch.cmte_audit_vw order by cmte_id;

create unique index on ofec_committee_fulltext_audit_mv(idx);
create index on ofec_committee_fulltext_audit_mv using gin(fulltxt);


--5)M_View: public.ofec_candidate_fulltext_audit_mv
drop materialized view if exists ofec_candidate_fulltext_audit_mv;
create materialized view ofec_candidate_fulltext_audit_mv as
select distinct on (cand_id, cand_name)
    row_number() over () as idx,
    cand_id as id,
    cand_name as name,
case
    when cand_name is not null then
        setweight(to_tsvector(cand_name), 'A') ||
        setweight(to_tsvector(cand_id), 'B')
    else null::tsvector
end as fulltxt
from auditsearch.cand_audit_vw order by cand_id;

create unique index on ofec_candidate_fulltext_audit_mv(idx);
create index on ofec_candidate_fulltext_audit_mvs using gin(fulltxt);


