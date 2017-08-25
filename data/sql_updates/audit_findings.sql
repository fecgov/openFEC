
-- View: auditsearch.findings_vw

-- DROP VIEW auditsearch.findings_vw;

CREATE OR REPLACE VIEW auditsearch.findings_vw AS 
 SELECT f.finding_pk,
    f.finding,
    f.tier,
    fr.rel_pk,
    fr.parent_finding_pk,
    fr.child_finding_pk
   FROM auditsearch.finding f,
    auditsearch.finding_rel fr
  WHERE f.finding_pk::text = fr.child_finding_pk::text
  ORDER BY f.finding;

ALTER TABLE auditsearch.findings_vw
  OWNER TO fec;
GRANT ALL ON TABLE auditsearch.findings_vw TO fec;
GRANT SELECT ON TABLE auditsearch.findings_vw TO openfec_read;
GRANT SELECT ON TABLE auditsearch.findings_vw TO fec_read;
