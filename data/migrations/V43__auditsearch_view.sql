SET search_path = auditsearch, pg_catalog;
--
-- 1)Name: cmte_audit_vw; Type: VIEW; Schema: auditsearch; Owner: fec
--
CREATE OR REPLACE VIEW cmte_audit_vw AS
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
    FROM audit_case aa JOIN disclosure.cmte_valid_fec_yr dc 
    ON(aa.cmte_id = dc.cmte_id)
WHERE dc.cmte_tp::text = ANY (ARRAY['H'::character varying, 'S'::character varying, 'P'::character varying, 'X'::character varying, 'Y'::character varying, 'Z'::character varying, 'N'::character varying, 'Q'::character varying, 'I'::character varying, 'O'::character varying]::text[])
ORDER BY dc.cmte_nm, dc.fec_election_yr;
ALTER TABLE cmte_audit_vw OWNER TO fec;

--
--2) Name: cand_audit_vw; Type: VIEW; Schema: auditsearch; Owner: fec
--
CREATE OR REPLACE VIEW cand_audit_vw AS
SELECT dc.cand_id,
    dc.cand_name,
    "substring"(dc.cand_name::text, 1,
        CASE
            WHEN strpos(dc.cand_name::text, ','::text) > 0 THEN strpos(dc.cand_name::text, ','::text) - 1
            ELSE strpos(dc.cand_name::text, ','::text)
        END) AS last_name,
    "substring"(dc.cand_name::text, strpos(dc.cand_name::text, ','::text) + 1) AS first_name,
    dc.fec_election_yr
    FROM audit_case aa JOIN disclosure.cand_valid_fec_yr dc
    ON(aa.cand_id = dc.cand_id)
ORDER BY dc.cand_name, dc.fec_election_yr;

ALTER TABLE cand_audit_vw OWNER TO fec;

--
--3) Name: finding_vw; Type: VIEW; Schema: auditsearch; Owner: fec
--
CREATE OR REPLACE VIEW finding_vw AS
SELECT 
    finding_pk::integer AS primary_category_id,
    btrim(finding::text) AS primary_category_name,
    tier::integer AS tier
FROM finding
WHERE tier::integer=1
ORDER BY (btrim(finding::text));

ALTER TABLE finding_vw OWNER TO fec;


--
-- 4)Name: finding_rel_vw; Type: VIEW; Schema: auditsearch; Owner: fec
--
CREATE OR REPLACE VIEW finding_rel_vw AS
SELECT 
    fr.parent_finding_pk::integer AS primary_category_id,
    fr.child_finding_pk::integer AS sub_category_id,
    btrim(fs.finding) AS primary_category_name,
    btrim(f.finding) AS sub_category_name
FROM finding_rel fr
LEFT JOIN finding f ON fr.child_finding_pk = f.finding_pk
LEFT JOIN finding fs ON fr.parent_finding_pk = fs.finding_pk
ORDER BY (fr.parent_finding_pk::integer), sub_category_name;

ALTER TABLE finding_rel_vw OWNER TO fec;

