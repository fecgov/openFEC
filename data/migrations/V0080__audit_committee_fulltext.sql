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
      AND dc.cmte_tp IN ('H', 'S', 'P', 'X', 'Y', 'Z', 'N', 'Q', 'I', 'O', 'U', 'V', 'W')
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

GRANT ALL ON TABLE public.ofec_committee_fulltext_audit_mv TO fec;
GRANT SELECT ON TABLE public.ofec_committee_fulltext_audit_mv TO fec_read;