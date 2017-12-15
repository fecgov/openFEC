--1)View: auditsearch.cmte_audit_vw
DROP VIEW if exists auditsearch.cmte_audit_vw cascade;
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


--2)View: auditsearch.cand_audit_vw
DROP VIEW if exists auditsearch.cand_audit_vw cascade;
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


--3)View: auditsearch.finding_vw
DROP VIEW if exists auditsearch.finding_vw cascade;
CREATE OR REPLACE VIEW auditsearch.finding_vw AS
SELECT 
    finding_pk::integer AS primary_category_id,
    btrim(finding::text) AS primary_category_name,
    tier::integer AS tier
FROM auditsearch.finding
WHERE tier::integer=1
ORDER BY (btrim(finding::text));


--4)View: auditsearch.finding_rel_vw
DROP VIEW if exists auditsearch.finding_rel_vw cascade;
CREATE OR REPLACE VIEW auditsearch.finding_rel_vw AS
SELECT 
    fr.parent_finding_pk::integer AS primary_category_id,
    fr.child_finding_pk::integer AS sub_category_id,
    btrim(fs.finding) AS primary_category_name,
    btrim(f.finding) AS sub_category_name
FROM auditsearch.finding_rel fr
LEFT JOIN auditsearch.finding f ON fr.child_finding_pk = f.finding_pk
LEFT JOIN auditsearch.finding fs ON fr.parent_finding_pk = fs.finding_pk
ORDER BY (fr.parent_finding_pk::integer), sub_category_name;
