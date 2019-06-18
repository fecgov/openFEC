
/*
column election_cycle and two_year_transaction_period in public.ofec_sched_b_master tables has exactly the same data
So disclosure.fec_fitem_sched_b does not add the extra column two_year_transaction_period
However, since existing API referencing column two_year_transaction_period a lot, rename election_cycle to two_year_transaction_period
  to mitigate impact to API when switching from using public.ofec_sched_b_master tables to disclosure.fec_fitem_sched_b table

redefine *._text triggers to replace all non-word characters with ' ' for better search specificity.
*/

-- ----------------------------
-- ----------------------------
-- disclosure.fec_fitem_sched_b
-- ----------------------------
-- ----------------------------

DO $$
BEGIN
    EXECUTE format('alter table disclosure.fec_fitem_sched_b rename column election_cycle to two_year_transaction_period');
    EXCEPTION 
             WHEN undefined_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;



/*
redefine tsvector specification for fec_fitem_sched_b_insert
*/

CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_b_insert()
  RETURNS trigger AS
$BODY$
begin
	new.pdf_url := image_pdf_url(new.image_num);
	new.disbursement_description_text := to_tsvector(regexp_replace(new.disb_desc, '[^a-zA-Z0-9]', ' ', 'g'));
	new.recipient_name_text := to_tsvector(concat(regexp_replace(new.recipient_nm, '[^a-zA-Z0-9]', ' ', 'g'), ' ', new.clean_recipient_cmte_id));
	new.disbursement_purpose_category := disbursement_purpose(new.disb_tp, new.disb_desc);
	new.line_number_label := expand_line_number(new.filing_form, new.line_num);
  return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_b_insert()
  OWNER TO fec;

DROP TRIGGER IF EXISTS tri_fec_fitem_sched_b ON disclosure.fec_fitem_sched_b;

CREATE TRIGGER tri_fec_fitem_sched_b
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();


-- ----------------------------
-- ----------------------------
-- disclosure.fec_fitem_sched_f
-- ----------------------------
-- ----------------------------
DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_f ADD COLUMN payee_name_text tsvector');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_f_insert()
  RETURNS trigger AS
$BODY$
begin
	new.payee_name_text := to_tsvector(regexp_replace(new.pye_nm::text, '[^a-zA-Z0-9]', ' ', 'g'));

    	return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_f_insert()
  OWNER TO fec;

DROP TRIGGER IF EXISTS tri_fec_fitem_sched_f ON disclosure.fec_fitem_sched_f;

CREATE TRIGGER tri_fec_fitem_sched_f
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_f
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_f_insert();

/*

update to_tsvector to confirm to new search functionality (omit special characters, replace with whitespace, vectorize)
*/

CREATE OR REPLACE VIEW ofec_rad_analyst_vw AS
    SELECT row_number() OVER () AS idx,
        ra.cmte_id AS committee_id,
        cv.cmte_nm AS committee_name,
        an.anlyst_id AS analyst_id,
        (an.valid_id::numeric) AS analyst_short_id,
        CASE
            WHEN an.branch_id = 1 THEN 'Authorized'
            WHEN an.branch_id = 2 THEN 'Party/Non Party'
            ELSE NULL::text
        END AS rad_branch,
        an.firstname AS first_name,
        an.lastname AS last_name,
        to_tsvector(((regexp_replace(an.firstname, '[^a-zA-Z0-9]', ' ', 'g')::text || ' '::text) || regexp_replace(an.lastname, '[^a-zA-Z0-9]', ' ', 'g')::text)) AS name_txt,
        an.telephone_ext,
        t.anlyst_title_desc AS analyst_title,
        an.email AS analyst_email,
        ra.last_rp_change_dt AS assignment_update_date
    FROM rad_pri_user.rad_anlyst an
    JOIN rad_pri_user.rad_assgn ra
        ON an.anlyst_id = ra.anlyst_id
    JOIN disclosure.cmte_valid_fec_yr cv
        ON ra.cmte_id = cv.cmte_id
    JOIN rad_pri_user.rad_lkp_anlyst_title t
        ON an.anlyst_title_seq = t.anlyst_title_seq
    WHERE an.status_id = 1
        AND an.anlyst_id <> 999
        AND cv.fec_election_yr = get_cycle(date_part('year', current_date)::integer);

ALTER TABLE ofec_rad_analyst_vw OWNER TO fec;
GRANT SELECT ON TABLE ofec_rad_analyst_vw TO fec_read;
GRANT SELECT ON TABLE ofec_rad_analyst_vw TO openfec_read;


/*
update to_tsvector definition for ofec_commite_fulltext_audit_mv
    a) `create or replace ofec_committee_fulltext_audit_mvw` to use new `MV` logic
    b) drop old `MV`
    c) recreate `MV` with new logic
    d) `create or replace ofec_committee_fulltext_audit_mv` -> `select all` from new `MV`
*/


-- a) `create or replace ofec_committee_fulltext_audit_mv` to use new `MV` logic

CREATE OR REPLACE VIEW ofec_committee_fulltext_audit_vw AS
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
        setweight(to_tsvector(regexp_replace(cmte_nm, '[^a-zA-Z0-9]', ' ', 'g')), 'A') ||
        setweight(to_tsvector(regexp_replace(cmte_id, '[^a-zA-Z0-9]', ' ', 'g')), 'B')
    ELSE NULL::tsvector
END AS fulltxt
FROM cmte_info 
ORDER BY cmte_id;


-- b) drop old mv
DROP MATERIALIZED VIEW ofec_committee_fulltext_audit_mv;


-- c) create new mv
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
        setweight(to_tsvector(regexp_replace(cmte_nm, '[^a-zA-Z0-9]', ' ', 'g')), 'A') ||
        setweight(to_tsvector(regexp_replace(cmte_id, '[^a-zA-Z0-9]', ' ', 'g')), 'B')
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

-- d) `create or replace ofec_committee_fulltext_audit_vw` -> `select all` from new `MV`
CREATE OR REPLACE VIEW ofec_committee_fulltext_audit_vw AS SELECT * FROM ofec_committee_fulltext_audit_mv;
ALTER VIEW ofec_committee_fulltext_audit_vw OWNER TO fec;
GRANT SELECT ON ofec_committee_fulltext_audit_vw TO fec_read;


/*
update to_tsvector definition for fec_fitem_sched_a
*/
CREATE OR REPLACE FUNCTION disclosure.ju_fec_fitem_sched_a_insert()
    RETURNS trigger AS
$BODY$
begin
	new.pdf_url := image_pdf_url(new.image_num);
	new.contributor_name_text := to_tsvector(concat(regexp_replace(new.contbr_nm, '[^a-zA-Z0-9]', ' ', 'g'), ' ', regexp_replace(new.clean_contbr_id, '[^a-zA-Z0-9]', ' ', 'g')));
	new.contributor_employer_text := to_tsvector(regexp_replace(new.contbr_employer, '[^a-zA-Z0-9]', ' ', 'g'));
	new.contributor_occupation_text := to_tsvector(regexp_replace(new.contbr_occupation, '[^a-zA-Z0-9]', ' ', 'g'));
	new.is_individual := is_individual(new.contb_receipt_amt, new.receipt_tp, new.line_num, new.memo_cd, new.memo_text);
	new.line_number_label := expand_line_number(new.filing_form, new.line_num);

    return new;
end
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

ALTER FUNCTION disclosure.ju_fec_fitem_sched_a_insert()
OWNER TO fec;


/*
update to_tsvector definition for ofec_candidate_fulltext_audit_mv
*/

/*
update to_tsvector definition for ofec_candidate_fulltext_audit_mv
    a) `create or replace ofec_candidate_fulltext_audit_vw` to use new `MV` logic
    b) drop old `MV`
    c) recreate `MV` with new logic
    d) `create or replace ofec_candidate_fulltext_audit_mv` -> `select all` from new `MV`
*/
-- a) `create or replace ofec_candidate_fulltext_audit_vw` to use new `MV` logic
CREATE OR REPLACE VIEW ofec_candidate_fulltext_audit_vw AS
WITH
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
)
SELECT DISTINCT ON (cand_id, cand_name)
    row_number() over () AS idx,
    cand_id AS id,
    cand_name AS name,
CASE
    WHEN cand_name IS NOT NULL THEN
        setweight(to_tsvector(regexp_replace(cand_name, '[^a-zA-Z0-9]', ' ', 'g')), 'A') ||
        setweight(to_tsvector(regexp_replace(cand_id, '[^a-zA-Z0-9]', ' ', 'g')), 'B')
    ELSE NULL::tsvector
END AS fulltxt
FROM cand_info
ORDER BY cand_id;

--    b) drop old `MV`
DROP MATERIALIZED VIEW ofec_candidate_fulltext_audit_mv;

--    c) recreate `MV` with new logic
CREATE MATERIALIZED VIEW ofec_candidate_fulltext_audit_mv AS
WITH
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
)
SELECT DISTINCT ON (cand_id, cand_name)
    row_number() over () AS idx,
    cand_id AS id,
    cand_name AS name,
CASE
    WHEN cand_name IS NOT NULL THEN
        setweight(to_tsvector(regexp_replace(cand_name, '[^a-zA-Z0-9]', ' ', 'g')), 'A') ||
        setweight(to_tsvector(regexp_replace(cand_id, '[^a-zA-Z0-9]', ' ', 'g')), 'B')
    ELSE NULL::tsvector
END AS fulltxt
FROM cand_info
ORDER BY cand_id
WITH DATA;

ALTER TABLE ofec_candidate_fulltext_audit_mv OWNER TO fec;

CREATE UNIQUE INDEX ON ofec_candidate_fulltext_audit_mv(idx);
CREATE INDEX ON ofec_candidate_fulltext_audit_mv using gin(fulltxt);


GRANT ALL ON TABLE ofec_candidate_fulltext_audit_mv TO fec;
GRANT SELECT ON TABLE ofec_candidate_fulltext_audit_mv TO fec_read;

-- d) `create or replace ofec_candidate_fulltext_audit_vw` -> `select all` from new `MV`
CREATE OR REPLACE VIEW ofec_candidate_fulltext_audit_vw AS SELECT * FROM ofec_candidate_fulltext_audit_mv;
ALTER VIEW ofec_candidate_fulltext_audit_vw OWNER TO fec;
GRANT SELECT ON ofec_candidate_fulltext_audit_vw TO fec_read;


/*
update to_tsvector for fec_fitem_sched_c
*/

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_c ADD COLUMN candidate_name_text tsvector');
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_c ADD COLUMN loan_source_name_text tsvector');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_c_insert()
  RETURNS trigger AS
$BODY$
begin
	new.candidate_name_text := to_tsvector(regexp_replace(new.cand_nm::text, '[^a-zA-Z0-9]', ' ', 'g'));
	new.loan_source_name_text := to_tsvector(regexp_replace(new.loan_src_nm::text, '[^a-zA-Z0-9]', ' ', 'g'));

    	return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_c_insert()
  OWNER TO fec;

DROP TRIGGER IF EXISTS tri_fec_fitem_sched_c ON disclosure.fec_fitem_sched_c;

CREATE TRIGGER tri_fec_fitem_sched_c
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_c
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_c_insert();



/*
update to_tsvector definition for ofec_committee_fulltext_mv
    a) `create or replace ofec_committee_fulltext_vw` to use new `MV` logic
    b) drop old `MV`
    c) recreate `MV` with new logic
    d) `create or replace ofec_committee_fulltext_audit_vw` -> `select all` from new `MV`
*/
-- a) `create or replace ofec_committee_fulltext_vw` to use new `MV` logic
CREATE OR REPLACE VIEW public.ofec_committee_fulltext_vw AS
 WITH pacronyms AS (
         SELECT ofec_pacronyms."ID NUMBER" AS committee_id,
            string_agg(ofec_pacronyms."PACRONYM", ' '::text) AS pacronyms
           FROM public.ofec_pacronyms
          GROUP BY ofec_pacronyms."ID NUMBER"
        ), totals AS (
         SELECT ofec_totals_combined_vw.committee_id,
            sum(ofec_totals_combined_vw.receipts) AS receipts,
            sum(ofec_totals_combined_vw.disbursements) AS disbursements,
            sum(ofec_totals_combined_vw.independent_expenditures) AS independent_expenditures
           FROM public.ofec_totals_combined_vw
          GROUP BY ofec_totals_combined_vw.committee_id
        )
 SELECT DISTINCT ON (committee_id) row_number() OVER () AS idx,
    committee_id AS id,
    cd.name,
        CASE
            WHEN (cd.name IS NOT NULL) THEN ((setweight(to_tsvector(regexp_replace((cd.name)::text, '[^a-zA-Z0-9]', ' ', 'g')), 'A'::"char") || setweight(to_tsvector(COALESCE(regexp_replace(pac.pacronyms, '[^a-zA-Z0-9]', ' ', 'g'), ''::text)), 'A'::"char")) || setweight(to_tsvector(regexp_replace((committee_id)::text, '[^a-zA-Z0-9]', ' ', 'g')), 'B'::"char"))
            ELSE NULL::tsvector
        END AS fulltxt,
    COALESCE(totals.receipts, (0)::numeric) AS receipts,
    COALESCE(totals.disbursements, (0)::numeric) AS disbursements,
    COALESCE(totals.independent_expenditures, (0)::numeric) AS independent_expenditures,
    ((COALESCE(totals.receipts, (0)::numeric) + COALESCE(totals.disbursements, (0)::numeric)) + COALESCE(totals.independent_expenditures, (0)::numeric)) AS total_activity
   FROM ((public.ofec_committee_detail_vw cd
     LEFT JOIN pacronyms pac USING (committee_id))
     LEFT JOIN totals USING (committee_id));

-- b) drop old MV
DROP MATERIALIZED VIEW ofec_committee_fulltext_mv;

-- c) recreate `MV` with new logic
CREATE MATERIALIZED VIEW public.ofec_committee_fulltext_mv AS
 WITH pacronyms AS (
         SELECT ofec_pacronyms."ID NUMBER" AS committee_id,
            string_agg(ofec_pacronyms."PACRONYM", ' '::text) AS pacronyms
           FROM public.ofec_pacronyms
          GROUP BY ofec_pacronyms."ID NUMBER"
        ), totals AS (
         SELECT ofec_totals_combined_vw.committee_id,
            sum(ofec_totals_combined_vw.receipts) AS receipts,
            sum(ofec_totals_combined_vw.disbursements) AS disbursements,
            sum(ofec_totals_combined_vw.independent_expenditures) AS independent_expenditures
           FROM public.ofec_totals_combined_vw
          GROUP BY ofec_totals_combined_vw.committee_id
        )
 SELECT DISTINCT ON (committee_id) row_number() OVER () AS idx,
    committee_id AS id,
    cd.name,
        CASE
            WHEN (cd.name IS NOT NULL) THEN ((setweight(to_tsvector(regexp_replace((cd.name)::text, '[^a-zA-Z0-9]', ' ', 'g')), 'A'::"char") || setweight(to_tsvector(COALESCE(regexp_replace(pac.pacronyms, '[^a-zA-Z0-9]', ' ', 'g'), ''::text)), 'A'::"char")) || setweight(to_tsvector(regexp_replace((committee_id)::text, '[^a-zA-Z0-9]', ' ', 'g')), 'B'::"char"))
            ELSE NULL::tsvector
        END AS fulltxt,
    COALESCE(totals.receipts, (0)::numeric) AS receipts,
    COALESCE(totals.disbursements, (0)::numeric) AS disbursements,
    COALESCE(totals.independent_expenditures, (0)::numeric) AS independent_expenditures,
    ((COALESCE(totals.receipts, (0)::numeric) + COALESCE(totals.disbursements, (0)::numeric)) + COALESCE(totals.independent_expenditures, (0)::numeric)) AS total_activity
   FROM ((public.ofec_committee_detail_vw cd
     LEFT JOIN pacronyms pac USING (committee_id))
     LEFT JOIN totals USING (committee_id))
  WITH DATA;

ALTER TABLE public.ofec_committee_fulltext_mv OWNER TO fec;

CREATE INDEX ofec_committee_fulltext_mv_disbursements_idx1 ON public.ofec_committee_fulltext_mv USING btree (disbursements);
CREATE INDEX ofec_committee_fulltext_mv_fulltxt_idx1 ON public.ofec_committee_fulltext_mv USING gin (fulltxt);
CREATE UNIQUE INDEX ofec_committee_fulltext_mv_idx_idx1 ON public.ofec_committee_fulltext_mv USING btree (idx);
CREATE INDEX ofec_committee_fulltext_mv_independent_expenditures_idx1 ON public.ofec_committee_fulltext_mv USING btree (independent_expenditures);
CREATE INDEX ofec_committee_fulltext_mv_receipts_idx1 ON public.ofec_committee_fulltext_mv USING btree (receipts);
CREATE INDEX ofec_committee_fulltext_mv_total_activity_idx1 ON public.ofec_committee_fulltext_mv USING btree (total_activity);

GRANT ALL ON TABLE ofec_committee_fulltext_mv TO fec;
GRANT SELECT ON TABLE ofec_committee_fulltext_mv TO fec_read;

-- d) `create or replace ofec_committee_fulltext_mv` -> `select all` from new `MV`
CREATE OR REPLACE VIEW ofec_committee_fulltext_vw AS SELECT * FROM ofec_committee_fulltext_mv;
ALTER VIEW ofec_committee_fulltext_vw OWNER TO fec;
GRANT SELECT ON ofec_committee_fulltext_vw TO fec_read;


/*
update to_tsvector definition for ofec_candidate_fulltext_mv
    a) `create or replace ofec_candidate_fulltext_vw` to use new `MV` logic
    b) drop old `MV`
    c) recreate `MV` with new logic
    d) `create or replace ofec_candidate_fulltext_audit_vw` -> `select all` from new `MV`
*/

-- a) `create or replace ofec_candidate_fulltext_vw` to use new `MV` logic
CREATE OR REPLACE VIEW public.ofec_candidate_fulltext_vw AS
 WITH nicknames AS (
         SELECT ofec_nicknames.candidate_id,
            string_agg(ofec_nicknames.nickname, ' '::text) AS nicknames
           FROM public.ofec_nicknames
          GROUP BY ofec_nicknames.candidate_id
        ), totals AS (
         SELECT link.cand_id AS candidate_id,
            sum(totals_1.receipts) AS receipts,
            sum(totals_1.disbursements) AS disbursements
           FROM (disclosure.cand_cmte_linkage link
             JOIN public.ofec_totals_combined_vw totals_1 ON ((((link.cmte_id)::text = (totals_1.committee_id)::text) AND (link.fec_election_yr = (totals_1.cycle)::numeric))))
          WHERE (((link.cmte_dsgn)::text = ANY (ARRAY[('P'::character varying)::text, ('A'::character varying)::text])) AND ((substr((link.cand_id)::text, 1, 1) = (link.cmte_tp)::text) OR ((link.cmte_tp)::text <> ALL (ARRAY[('P'::character varying)::text, ('S'::character varying)::text, ('H'::character varying)::text]))))
          GROUP BY link.cand_id
        )
 SELECT DISTINCT ON (candidate_id) row_number() OVER () AS idx,
    candidate_id AS id,
    ofec_candidate_detail_vw.name,
    ofec_candidate_detail_vw.office AS office_sought,
        CASE
            WHEN (ofec_candidate_detail_vw.name IS NOT NULL) THEN ((setweight(to_tsvector(regexp_replace((ofec_candidate_detail_vw.name)::text, '[^a-zA-Z0-9]', ' ', 'g')), 'A'::"char") || setweight(to_tsvector(COALESCE(regexp_replace(nicknames.nicknames, '[^a-zA-Z0-9]', ' ', 'g'), ''::text)), 'A'::"char")) || setweight(to_tsvector(regexp_replace((candidate_id)::text, '[^a-zA-Z0-9]', ' ', 'g')), 'B'::"char"))
            ELSE NULL::tsvector
        END AS fulltxt,
    COALESCE(totals.receipts, (0)::numeric) AS receipts,
    COALESCE(totals.disbursements, (0)::numeric) AS disbursements,
    (COALESCE(totals.receipts, (0)::numeric) + COALESCE(totals.disbursements, (0)::numeric)) AS total_activity
   FROM ((public.ofec_candidate_detail_vw
     LEFT JOIN nicknames USING (candidate_id))
     LEFT JOIN totals USING (candidate_id));

-- b) drop old 'MV'
DROP MATERIALIZED VIEW ofec_candidate_fulltext_mv;

-- c) create 'MV' with new logic
CREATE MATERIALIZED VIEW public.ofec_candidate_fulltext_mv AS
 WITH nicknames AS (
         SELECT ofec_nicknames.candidate_id,
            string_agg(ofec_nicknames.nickname, ' '::text) AS nicknames
           FROM public.ofec_nicknames
          GROUP BY ofec_nicknames.candidate_id
        ), totals AS (
         SELECT link.cand_id AS candidate_id,
            sum(totals_1.receipts) AS receipts,
            sum(totals_1.disbursements) AS disbursements
           FROM (disclosure.cand_cmte_linkage link
             JOIN public.ofec_totals_combined_vw totals_1 ON ((((link.cmte_id)::text = (totals_1.committee_id)::text) AND (link.fec_election_yr = (totals_1.cycle)::numeric))))
          WHERE (((link.cmte_dsgn)::text = ANY (ARRAY[('P'::character varying)::text, ('A'::character varying)::text])) AND ((substr((link.cand_id)::text, 1, 1) = (link.cmte_tp)::text) OR ((link.cmte_tp)::text <> ALL (ARRAY[('P'::character varying)::text, ('S'::character varying)::text, ('H'::character varying)::text]))))
          GROUP BY link.cand_id
        )
 SELECT DISTINCT ON (candidate_id) row_number() OVER () AS idx,
    candidate_id AS id,
    ofec_candidate_detail_vw.name,
    ofec_candidate_detail_vw.office AS office_sought,
        CASE
            WHEN (ofec_candidate_detail_vw.name IS NOT NULL) THEN ((setweight(to_tsvector((ofec_candidate_detail_vw.name)::text), 'A'::"char") || setweight(to_tsvector(COALESCE(nicknames.nicknames, ''::text)), 'A'::"char")) || setweight(to_tsvector((candidate_id)::text), 'B'::"char"))
            ELSE NULL::tsvector
        END AS fulltxt,
    COALESCE(totals.receipts, (0)::numeric) AS receipts,
    COALESCE(totals.disbursements, (0)::numeric) AS disbursements,
    (COALESCE(totals.receipts, (0)::numeric) + COALESCE(totals.disbursements, (0)::numeric)) AS total_activity
   FROM ((public.ofec_candidate_detail_vw
     LEFT JOIN nicknames USING (candidate_id))
     LEFT JOIN totals USING (candidate_id))
  WITH DATA;

ALTER TABLE public.ofec_candidate_fulltext_mv OWNER TO fec;

CREATE INDEX ofec_candidate_fulltext_mv_disbursements_idx1 ON public.ofec_candidate_fulltext_mv USING btree (disbursements);
CREATE INDEX ofec_candidate_fulltext_mv_fulltxt_idx1 ON public.ofec_candidate_fulltext_mv USING gin (fulltxt);
CREATE UNIQUE INDEX ofec_candidate_fulltext_mv_idx_idx1 ON public.ofec_candidate_fulltext_mv USING btree (idx);
CREATE INDEX ofec_candidate_fulltext_mv_receipts_idx1 ON public.ofec_candidate_fulltext_mv USING btree (receipts);
CREATE INDEX ofec_candidate_fulltext_mv_total_activity_idx1 ON public.ofec_candidate_fulltext_mv USING btree (total_activity);

-- d) `create or replace ofec_candidate_fulltext_audit_mv` -> `select all` from new `MV`
CREATE OR REPLACE VIEW ofec_candidate_fulltext_vw AS SELECT * FROM ofec_candidate_fulltext_mv;
ALTER VIEW ofec_candidate_fulltext_vw OWNER TO fec;
GRANT SELECT ON ofec_candidate_fulltext_vw TO fec_read;




/*
update to_tsvector definition for ofec_electioneering_mv
    a) `create or replace ofec_electioneering_vw` to use new `MV` logic
    b) drop old `MV`
    c) recreate `MV` with new logic
    d) `create or replace ofec_candidate_fulltext_audit_vw` -> `select all` from new `MV`
*/
--  a) `create or replace ofec_electioneering_vw` to use new `MV` logic
CREATE OR REPLACE VIEW ofec_electioneering_vw AS
 SELECT row_number() OVER () AS idx,
    electioneering_com_vw.cand_id,
    electioneering_com_vw.cand_name,
    electioneering_com_vw.cand_office,
    electioneering_com_vw.cand_office_st,
    electioneering_com_vw.cand_office_district,
    electioneering_com_vw.cmte_id,
    electioneering_com_vw.cmte_nm,
    electioneering_com_vw.sb_image_num,
    electioneering_com_vw.payee_nm,
    electioneering_com_vw.payee_st1,
    electioneering_com_vw.payee_city,
    electioneering_com_vw.payee_st,
    electioneering_com_vw.disb_desc,
    electioneering_com_vw.disb_dt,
    electioneering_com_vw.comm_dt,
    electioneering_com_vw.pub_distrib_dt,
    electioneering_com_vw.reported_disb_amt,
    electioneering_com_vw.number_of_candidates,
    electioneering_com_vw.calculated_cand_share,
    electioneering_com_vw.sub_id,
    electioneering_com_vw.link_id,
    electioneering_com_vw.rpt_yr,
    electioneering_com_vw.sb_link_id,
    electioneering_com_vw.f9_begin_image_num,
    electioneering_com_vw.receipt_dt,
    electioneering_com_vw.election_tp,
    electioneering_com_vw.file_num,
    electioneering_com_vw.amndt_ind,
    image_pdf_url((electioneering_com_vw.sb_image_num)::text) AS pdf_url,
    to_tsvector(regexp_replace((electioneering_com_vw.disb_desc)::text, '[^a-zA-Z0-9]', ' ', 'g')) AS purpose_description_text
   FROM electioneering_com_vw
  WHERE (electioneering_com_vw.rpt_yr >= (1979)::numeric);

-- b) drop old 'MV'
DROP MATERIALIZED VIEW ofec_electioneering_mv;

-- c) recreate `MV` with new logic
CREATE MATERIALIZED VIEW ofec_electioneering_mv AS
 SELECT row_number() OVER () AS idx,
    electioneering_com_vw.cand_id,
    electioneering_com_vw.cand_name,
    electioneering_com_vw.cand_office,
    electioneering_com_vw.cand_office_st,
    electioneering_com_vw.cand_office_district,
    electioneering_com_vw.cmte_id,
    electioneering_com_vw.cmte_nm,
    electioneering_com_vw.sb_image_num,
    electioneering_com_vw.payee_nm,
    electioneering_com_vw.payee_st1,
    electioneering_com_vw.payee_city,
    electioneering_com_vw.payee_st,
    electioneering_com_vw.disb_desc,
    electioneering_com_vw.disb_dt,
    electioneering_com_vw.comm_dt,
    electioneering_com_vw.pub_distrib_dt,
    electioneering_com_vw.reported_disb_amt,
    electioneering_com_vw.number_of_candidates,
    electioneering_com_vw.calculated_cand_share,
    electioneering_com_vw.sub_id,
    electioneering_com_vw.link_id,
    electioneering_com_vw.rpt_yr,
    electioneering_com_vw.sb_link_id,
    electioneering_com_vw.f9_begin_image_num,
    electioneering_com_vw.receipt_dt,
    electioneering_com_vw.election_tp,
    electioneering_com_vw.file_num,
    electioneering_com_vw.amndt_ind,
    image_pdf_url((electioneering_com_vw.sb_image_num)::text) AS pdf_url,
    to_tsvector(regexp_replace((electioneering_com_vw.disb_desc)::text, '[^a-zA-Z0-9]', ' ', 'g')) AS purpose_description_text
   FROM electioneering_com_vw
  WHERE (electioneering_com_vw.rpt_yr >= (1979)::numeric)
 WITH DATA;

ALTER TABLE ofec_electioneering_mv OWNER TO fec;

CREATE INDEX ofec_electioneering_mv_tmp_calculated_cand_share_idx ON ofec_electioneering_mv USING btree (calculated_cand_share);
CREATE INDEX ofec_electioneering_mv_tmp_cand_id_idx ON ofec_electioneering_mv USING btree (cand_id);
CREATE INDEX ofec_electioneering_mv_tmp_cand_office_district_idx ON ofec_electioneering_mv USING btree (cand_office_district);
CREATE INDEX ofec_electioneering_mv_tmp_cand_office_idx ON ofec_electioneering_mv USING btree (cand_office);
CREATE INDEX ofec_electioneering_mv_tmp_cand_office_st_idx ON ofec_electioneering_mv USING btree (cand_office_st);
CREATE INDEX ofec_electioneering_mv_tmp_cmte_id_idx ON ofec_electioneering_mv USING btree (cmte_id);
CREATE INDEX ofec_electioneering_mv_tmp_disb_dt_idx1 ON ofec_electioneering_mv USING btree (disb_dt);
CREATE INDEX ofec_electioneering_mv_tmp_f9_begin_image_num_idx ON ofec_electioneering_mv USING btree (f9_begin_image_num);
CREATE UNIQUE INDEX ofec_electioneering_mv_tmp_idx_idx ON ofec_electioneering_mv USING btree (idx);
CREATE INDEX ofec_electioneering_mv_tmp_purpose_description_text_idx1 ON ofec_electioneering_mv USING gin (purpose_description_text);
CREATE INDEX ofec_electioneering_mv_tmp_reported_disb_amt_idx ON ofec_electioneering_mv USING btree (reported_disb_amt);
CREATE INDEX ofec_electioneering_mv_tmp_rpt_yr_idx ON ofec_electioneering_mv USING btree (rpt_yr);
CREATE INDEX ofec_electioneering_mv_tmp_sb_image_num_idx ON ofec_electioneering_mv USING btree (sb_image_num);

-- d) `create or replace ofec_candidate_fulltext_audit_mv` -> `select all` from new `MV`
CREATE OR REPLACE VIEW ofec_electioneering_vw AS SELECT * FROM ofec_electioneering_mv;
ALTER VIEW ofec_electioneering_vw OWNER TO fec;
GRANT SELECT ON TABLE ofec_electioneering_mv TO fec_read;

/*
update to_tsvector for ofec_dates_vw
*/

create or replace view ofec_dates_vw as
 (
    -- most data comes from cal_event and is imported as is, it does not have state filtering.
    select distinct on (category_name, event_name, description, location, start_date, end_date)
        cal_event_id,
        category_name::text as category,
        event_name::text as summary,
        describe_cal_event(category_name::text, event_name::text, description::text) as description,
        null::text[] as states,
        location::text,
        start_date,
        end_date,
        use_time = 'N' as all_day,
        url,
        to_tsvector(regexp_replace(event_name, '[^a-zA-Z0-9]', ' ', 'g')) as summary_text,
        to_tsvector(regexp_replace(describe_cal_event(category_name::text, event_name::text, description::text), '[^a-zA-Z0-9]', ' ', 'g')) as description_text,
        cal_category_id as calendar_category_id
    from fecapp.cal_event
    join fecapp.cal_event_category using (cal_event_id)
    join fecapp.cal_category using (cal_category_id)
    where
        -- the status of 3 narrows down the events to those that a published
        cal_event_status_id = 3 and
        active = 'Y'
);

ALTER TABLE ofec_dates_vw OWNER TO fec;
