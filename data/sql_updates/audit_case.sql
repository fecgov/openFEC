-- View: public.ofec_audit_case_mv

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
    ac.audit_case_id AS audit_case_id,
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
    cand_info.cand_name AS candidate_name
   FROM auditsearch.audit_case ac
     LEFT JOIN cmte_info ON cmte_info.cmte_id::text = ac.cmte_id::text AND cmte_info.fec_election_yr = ac.election_cycle
     LEFT JOIN cand_info ON cand_info.cand_id::text = ac.cand_id::text AND cand_info.fec_election_yr = ac.election_cycle
  ORDER BY ac.election_cycle DESC
WITH DATA;

create unique index on ofec_audit_case_mv_tmp(audit_case_id);

