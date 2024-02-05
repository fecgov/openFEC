
SET search_path = auditsearch, pg_catalog;

CREATE OR REPLACE VIEW cmte_audit_vw AS
SELECT dc.cmte_id,
    dc.cmte_nm,
    dc.fec_election_yr,
    dc.cmte_dsgn,
    dc.cmte_tp,
    b.FILED_CMTE_TP_DESC::text AS cmte_desc
FROM auditsearch.audit_case aa, disclosure.cmte_valid_fec_yr dc, staging.ref_filed_cmte_tp b
WHERE aa.cmte_id = dc.cmte_id
  AND dc.cmte_tp IN ('H','S', 'P', 'X', 'Y', 'Z', 'N', 'Q', 'I', 'O')
  and dc.cmte_tp = b.filed_cmte_tp_cd
ORDER BY dc.cmte_nm, dc.fec_election_yr;

ALTER TABLE cmte_audit_vw OWNER TO fec;

GRANT ALL ON TABLE cmte_audit_vw TO fec;
GRANT SELECT ON TABLE cmte_audit_vw TO fec_read;
GRANT SELECT ON TABLE cmte_audit_vw TO openfec_read;


GRANT ALL ON TABLE cand_audit_vw TO fec;
GRANT SELECT ON TABLE cand_audit_vw TO fec_read;
GRANT SELECT ON TABLE cand_audit_vw TO openfec_read;

GRANT ALL ON TABLE finding_vw TO fec;
GRANT SELECT ON TABLE finding_vw TO fec_read;
GRANT SELECT ON TABLE finding_vw TO openfec_read;

GRANT ALL ON TABLE finding_rel_vw TO fec;
GRANT SELECT ON TABLE finding_rel_vw TO fec_read;
GRANT SELECT ON TABLE finding_rel_vw TO openfec_read;


SET search_path = public, pg_catalog;


GRANT ALL ON TABLE ofec_audit_case_mv TO fec;
GRANT SELECT ON TABLE ofec_audit_case_mv TO fec_read;
GRANT SELECT ON TABLE ofec_audit_case_mv TO openfec_read;


GRANT ALL ON TABLE ofec_audit_case_category_rel_mv TO fec;
GRANT SELECT ON TABLE ofec_audit_case_category_rel_mv TO fec_read;
GRANT SELECT ON TABLE ofec_audit_case_category_rel_mv TO openfec_read;


GRANT ALL ON TABLE ofec_audit_case_sub_category_rel_mv TO fec;
GRANT SELECT ON TABLE ofec_audit_case_sub_category_rel_mv TO fec_read;
GRANT SELECT ON TABLE ofec_audit_case_sub_category_rel_mv TO openfec_read;


GRANT ALL ON TABLE ofec_committee_fulltext_audit_mv TO fec;
GRANT SELECT ON TABLE ofec_committee_fulltext_audit_mv TO fec_read;
GRANT SELECT ON TABLE ofec_committee_fulltext_audit_mv TO openfec_read;


GRANT ALL ON TABLE ofec_candidate_fulltext_audit_mv TO fec;
GRANT SELECT ON TABLE ofec_candidate_fulltext_audit_mv TO fec_read;
GRANT SELECT ON TABLE ofec_candidate_fulltext_audit_mv TO openfec_read;
