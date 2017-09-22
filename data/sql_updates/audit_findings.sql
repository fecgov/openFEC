
drop materialized view if exists ofec_audit_search_mv_tmp;

CREATE MATERIALIZED VIEW ofec_audit_search_mv_tmp AS
 SELECT row_number() OVER () AS idx,
    fvw.parent_finding_pk::integer AS finding_id,
    trim(fvw.tier_one_finding::text) AS finding,
    fvw.child_finding_pk::integer AS issue_id,
    fvw.tier_two_finding AS issue,
    ac.audit_case_id::integer AS audit_case_id,
    ac.audit_id::integer AS audit_id,
    ac.election_cycle::integer AS election_cycle,
    ac.far_release_date::date AS far_release_date,
    ac.link_to_report,
    ac.cmte_id AS committee_id,
    ( SELECT cmte_audit_vw.cmte_nm
           FROM auditsearch.cmte_audit_vw
          WHERE cmte_audit_vw.cmte_id::text = ac.cmte_id::text AND cmte_audit_vw.fec_election_yr = ac.election_cycle LIMIT 1) AS committee_name,
    ( SELECT cmte_audit_vw.cmte_dsgn
           FROM auditsearch.cmte_audit_vw
          WHERE cmte_audit_vw.cmte_id::text = ac.cmte_id::text AND cmte_audit_vw.fec_election_yr = ac.election_cycle LIMIT 1) AS committee_designation,
    ( SELECT cmte_audit_vw.cmte_tp
           FROM auditsearch.cmte_audit_vw
          WHERE cmte_audit_vw.cmte_id::text = ac.cmte_id::text AND cmte_audit_vw.fec_election_yr = ac.election_cycle LIMIT 1) AS committee_type,
    ( SELECT cmte_audit_vw.cmte_desc
           FROM auditsearch.cmte_audit_vw
          WHERE cmte_audit_vw.cmte_id::text = ac.cmte_id::text AND cmte_audit_vw.fec_election_yr = ac.election_cycle LIMIT 1) AS committee_description,
    ac.cand_id AS candidate_id,
    ( SELECT cand_audit_vw.cand_name
           FROM auditsearch.cand_audit_vw
          WHERE cand_audit_vw.cand_id::text = ac.cand_id::text AND cand_audit_vw.fec_election_yr = ac.election_cycle LIMIT 1) AS candidate_name
   FROM auditsearch.findings_vw fvw,
    auditsearch.audit_case_finding acf,
    auditsearch.audit_case ac
  WHERE acf.parent_finding_pk::text = fvw.parent_finding_pk::text AND acf.child_finding_pk::text = fvw.child_finding_pk::text AND acf.audit_case_id::text = ac.audit_case_id::text
  ORDER BY fvw.tier_one_finding, fvw.tier_two_finding
WITH DATA;


-- Index: public.ofec_audit_search_candidate_id
CREATE INDEX ofec_audit_search_candidate_id_tmp
  ON public.ofec_audit_search_mv_tmp
  USING btree
  (candidate_id COLLATE pg_catalog."default");

-- Index: public.ofec_audit_search_committee_id
CREATE INDEX ofec_audit_search_committee_id_tmp
  ON public.ofec_audit_search_mv_tmp
  USING btree
  (committee_id COLLATE pg_catalog."default");

-- Index: public.ofec_audit_search_election_cycle

CREATE INDEX ofec_audit_search_election_cycle_tmp
  ON public.ofec_audit_search_mv_tmp
  USING btree
  (election_cycle);

-- Index: public.ofec_audit_search_finding_id

CREATE INDEX ofec_audit_search_finding_id_tmp
  ON public.ofec_audit_search_mv_tmp
  USING btree
  (finding_id);

-- Index: public.ofec_audit_search_finding_issue_id

CREATE INDEX ofec_audit_search_finding_issue_id_tmp
  ON public.ofec_audit_search_mv_tmp
  USING btree
  (finding_id, issue_id);

-- Index: public.ofec_audit_search_issue_id

CREATE INDEX ofec_audit_search_issue_id_tmp
  ON public.ofec_audit_search_mv_tmp
  USING btree
  (issue_id);

-- Index: public.ofec_audit_search_mv_tmp_idx_idx1

DROP INDEX if exists public.ofec_audit_search_mv_tmp_idx_idx1;

CREATE UNIQUE INDEX ofec_audit_search_mv_tmp_idx_idx1
  ON public.ofec_audit_search_mv_tmp
  USING btree
  (idx);
