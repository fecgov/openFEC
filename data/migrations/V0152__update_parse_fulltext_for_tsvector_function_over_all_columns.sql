/*
redefine *._text triggers to replace all non-word characters with ' ' for better search specificity.
*/

-- ----------------------------
-- ----------------------------
-- disclosure.fec_fitem_sched_b
-- ----------------------------
-- ----------------------------



CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_b_insert()
  RETURNS trigger AS
$BODY$
begin
	new.pdf_url := image_pdf_url(new.image_num);
	new.disbursement_description_text := to_tsvector(parse_fulltext(new.disb_desc));
	new.recipient_name_text := to_tsvector(concat(parse_fulltext(new.recipient_nm), ' ', new.clean_recipient_cmte_id));
	new.disbursement_purpose_category := disbursement_purpose(new.disb_tp, new.disb_desc);
	new.line_number_label := expand_line_number(new.filing_form, new.line_num);
  return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_b_insert()
  OWNER TO fec;


-- ----------------------------
-- ----------------------------
-- disclosure.fec_fitem_sched_d
-- ----------------------------
-- ----------------------------


CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_d_insert()
  RETURNS trigger AS
$BODY$
begin
	new.creditor_debtor_name_text := to_tsvector(parse_fulltext(new.cred_dbtr_nm));

    	return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_d_insert()
  OWNER TO fec;


-- ----------------------------
-- ----------------------------
-- disclosure.fec_fitem_sched_f
-- ----------------------------
-- ----------------------------


CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_f_insert()
  RETURNS trigger AS
$BODY$
begin
	new.payee_name_text := to_tsvector(parse_fulltext(new.pye_nm::text));

    	return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_f_insert()
  OWNER TO fec;


-- ----------------------------
-- ----------------------------
-- ofec_rad_analyst_vw
-- ----------------------------
-- ----------------------------

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
        to_tsvector(((parse_fulltext(an.firstname)::text || ' '::text) || parse_fulltext(an.lastname)::text)) AS name_txt,
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
        setweight(to_tsvector(parse_fulltext(cmte_nm)), 'A') ||
        setweight(to_tsvector(parse_fulltext(cmte_id)), 'B')
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
        setweight(to_tsvector(parse_fulltext(cmte_nm)), 'A') ||
        setweight(to_tsvector(parse_fulltext(cmte_id)), 'B')
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
CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_a_insert()
    RETURNS trigger AS
$BODY$
begin
	new.pdf_url := image_pdf_url(new.image_num);
	new.contributor_name_text := to_tsvector(concat(parse_fulltext(new.contbr_nm), ' ', new.clean_contbr_id));
	new.contributor_employer_text := to_tsvector(parse_fulltext(new.contbr_employer));
	new.contributor_occupation_text := to_tsvector(parse_fulltext(new.contbr_occupation));
	new.is_individual := is_individual(new.contb_receipt_amt, new.receipt_tp, new.line_num, new.memo_cd, new.memo_text);
	new.line_number_label := expand_line_number(new.filing_form, new.line_num);

    return new;
end
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

ALTER FUNCTION disclosure.fec_fitem_sched_a_insert()
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
        setweight(to_tsvector(parse_fulltext(cand_name)), 'A') ||
        setweight(to_tsvector(parse_fulltext(cand_id)), 'B')
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
        setweight(to_tsvector(parse_fulltext(cand_name)), 'A') ||
        setweight(to_tsvector(parse_fulltext(cand_id)), 'B')
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



CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_c_insert()
  RETURNS trigger AS
$BODY$
begin
	new.candidate_name_text := to_tsvector(parse_fulltext(new.cand_nm::text));
	new.loan_source_name_text := to_tsvector(parse_fulltext(new.loan_src_nm::text));

    	return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_c_insert()
  OWNER TO fec;


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
            WHEN (cd.name IS NOT NULL) THEN ((setweight(to_tsvector(parse_fulltext((cd.name)::text)), 'A'::"char") || setweight(to_tsvector(COALESCE(parse_fulltext(pac.pacronyms), ''::text)), 'A'::"char")) || setweight(to_tsvector(parse_fulltext((committee_id)::text)), 'B'::"char"))
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
            WHEN (cd.name IS NOT NULL) THEN ((setweight(to_tsvector(parse_fulltext((cd.name)::text)), 'A'::"char") || setweight(to_tsvector(COALESCE(parse_fulltext(pac.pacronyms), ''::text)), 'A'::"char")) || setweight(to_tsvector(parse_fulltext((committee_id)::text)), 'B'::"char"))
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
            WHEN (ofec_candidate_detail_vw.name IS NOT NULL) THEN ((setweight(to_tsvector(parse_fulltext((ofec_candidate_detail_vw.name)::text)), 'A'::"char") || setweight(to_tsvector(COALESCE(parse_fulltext(nicknames.nicknames), ''::text)), 'A'::"char")) || setweight(to_tsvector(parse_fulltext((candidate_id)::text)), 'B'::"char"))
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
            WHEN (ofec_candidate_detail_vw.name IS NOT NULL) THEN ((setweight(to_tsvector(parse_fulltext((ofec_candidate_detail_vw.name)::text)), 'A'::"char") || setweight(to_tsvector(COALESCE(parse_fulltext(nicknames.nicknames), ''::text)), 'A'::"char")) || setweight(to_tsvector(parse_fulltext((candidate_id)::text)), 'B'::"char"))
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
GRANT ALL ON TABLE ofec_candidate_fulltext_mv TO fec;
GRANT SELECT ON TABLE ofec_candidate_fulltext_mv TO fec_read;

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
    to_tsvector(parse_fulltext((electioneering_com_vw.disb_desc)::text)) AS purpose_description_text
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
    to_tsvector(parse_fulltext((electioneering_com_vw.disb_desc)::text)) AS purpose_description_text
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
        to_tsvector(parse_fulltext(event_name)) as summary_text,
        to_tsvector(parse_fulltext(describe_cal_event(category_name::text, event_name::text, description::text))) as description_text,
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




/*
update to_tsvector definition for ofec_sched_e_mv
according to notes below (from V0120__update_ofec_sched_e_mv_s_o_ind_handling.sql
ofec_sched_e_vw is not used by API.
*/
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_e_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_sched_e_mv_tmp AS
WITH SE AS
(SELECT
fe.cmte_id,
fe.cmte_nm,
fe.pye_nm,
fe.payee_l_nm,
fe.payee_f_nm,
fe.payee_m_nm,
fe.payee_prefix,
fe.payee_suffix,
fe.pye_st1,
fe.pye_st2,
fe.pye_city,
fe.pye_st,
fe.pye_zip,
fe.entity_tp,
fe.entity_tp_desc,
fe.exp_desc,
fe.catg_cd,
fe.catg_cd_desc,
fe.s_o_cand_id,
fe.s_o_cand_nm,
fe.s_o_cand_nm_first,
fe.s_o_cand_nm_last,
fe.s_o_cand_m_nm,
fe.s_o_cand_prefix,
fe.s_o_cand_suffix,
fe.s_o_cand_office,
fe.s_o_cand_office_desc,
fe.s_o_cand_office_st,
fe.s_o_cand_office_st_desc,
fe.s_o_cand_office_district,
fe.s_o_ind,
fe.s_o_ind_desc,
fe.election_tp,
fe.fec_election_tp_desc,
fe.cal_ytd_ofc_sought,
fe.dissem_dt,
fe.exp_amt,
coalesce(fe.exp_dt, fe.dissem_dt) as exp_dt,
fe.exp_tp,
fe.exp_tp_desc,
fe.memo_cd,
fe.memo_cd_desc,
fe.memo_text,
fe.conduit_cmte_id,
fe.conduit_cmte_nm,
fe.conduit_cmte_st1,
fe.conduit_cmte_st2,
fe.conduit_cmte_city,
fe.conduit_cmte_st,
fe.conduit_cmte_zip,
fe.indt_sign_nm,
fe.indt_sign_dt,
fe.notary_sign_nm,
fe.notary_sign_dt,
fe.notary_commission_exprtn_dt,
fe.filer_l_nm,
fe.filer_f_nm,
fe.filer_m_nm,
fe.filer_prefix,
fe.filer_suffix,
fe.action_cd,
fe.action_cd_desc,
fe.tran_id,
fe.back_ref_tran_id,
fe.back_ref_sched_nm,
fe.schedule_type,
fe.schedule_type_desc,
fe.line_num,
fe.image_num,
fe.file_num,
fe.link_id,
fe.orig_sub_id,
fe.sub_id,
fe.filing_form,
fe.rpt_tp,
fe.rpt_yr,
fe.election_cycle,
fe.pdf_url,
coalesce(fe.rpt_tp, '') in ('24', '48') as is_notice,
fe.payee_name_text,
fr.amndt_ind,
fr.prev_file_num
FROM disclosure.fec_fitem_sched_e fe
JOIN disclosure.f_rpt_or_form_sub fr
ON fe.link_id = fr.sub_id
-- -----------------
UNION
-- public.fec_sched_e_notice_vw
-- -----------------
SELECT 
se.cmte_id,
se.cmte_nm,
se.pye_nm,
se.payee_l_nm,
se.payee_f_nm,
se.payee_m_nm,
se.payee_prefix,
se.payee_suffix,
se.pye_st1,
se.pye_st2,
se.pye_city,
se.pye_st,
se.pye_zip,
se.entity_tp,
se.entity_tp_desc,
se.exp_desc,
se.catg_cd,
se.catg_cd_desc,
se.s_o_cand_id,
se.s_o_cand_nm,
se.s_o_cand_nm_first,
se.s_o_cand_nm_last,
se.s_0_cand_m_nm AS s_o_cand_m_nm,
se.s_0_cand_prefix AS s_o_cand_prefix,
se.s_0_cand_suffix AS s_o_cand_suffix,
se.s_o_cand_office,
se.s_o_cand_office_desc,
se.s_o_cand_office_st,
se.s_o_cand_office_st_desc,
se.s_o_cand_office_district,
se.s_o_ind,
se.s_o_ind_desc,
se.election_tp,
se.fec_election_tp_desc,
se.cal_ytd_ofc_sought,
se.dissem_dt,
se.exp_amt,
coalesce(se.exp_dt, se.dissem_dt) as exp_dt,
se.exp_tp,
se.exp_tp_desc,
se.memo_cd,
se.memo_cd_desc,
se.memo_text,
se.conduit_cmte_id,
se.conduit_cmte_nm,
se.conduit_cmte_st1,
se.conduit_cmte_st2,
se.conduit_cmte_city,
se.conduit_cmte_st,
se.conduit_cmte_zip,
se.indt_sign_nm,
se.indt_sign_dt,
se.notary_sign_nm,
se.notary_sign_dt,
se.notary_commission_exprtn_dt,
se.filer_l_nm,
se.filer_f_nm,
se.filer_m_nm,
se.filer_prefix,
se.filer_suffix,
se.amndt_ind AS action_cd,
se.amndt_ind_desc AS action_cd_desc,
CASE
    WHEN "substring"(se.sub_id::character varying::text, 1, 1) = '4'::text THEN se.tran_id
    ELSE NULL::character varying
END AS tran_id,
CASE
    WHEN "substring"(se.sub_id::character varying::text, 1, 1) = '4'::text THEN se.back_ref_tran_id
    ELSE NULL::character varying
END AS back_ref_tran_id,
CASE
    WHEN "substring"(se.sub_id::character varying::text, 1, 1) = '4'::text THEN se.back_ref_sched_nm
    ELSE NULL::character varying
END AS back_ref_sched_nm,
'SE' AS schedule_type,
se.form_tp_desc AS schedule_type_desc,
se.line_num,
se.image_num,
se.file_num,
se.link_id,
se.orig_sub_id,
se.sub_id,
'F24' AS filing_form,
f24.rpt_tp,
f24.rpt_yr,
f24.rpt_yr + mod(f24.rpt_yr, 2::numeric) AS election_cycle,
image_pdf_url(se.image_num) as pdf_url,
coalesce(f24.rpt_tp, '') in ('24', '48') as is_notice,
to_tsvector(parse_fulltext(se.pye_nm)) as payee_name_text,
f24.amndt_ind,
f24.prev_file_num
FROM disclosure.nml_sched_e se
JOIN disclosure.nml_form_24 f24
ON se.link_id = f24.sub_id 
WHERE f24.delete_ind IS NULL 
    AND se.delete_ind IS NULL 
    AND se.amndt_ind::text <> 'D'::text
-- -----------------
UNION
-- Add in records for the Form 5 filings
-- -----------------
SELECT 
ff57.filer_cmte_id, 
null AS cmte_nm,
ff57.pye_nm, 
ff57.pye_l_nm, 
ff57.pye_f_nm, 
ff57.pye_m_nm, 
ff57.pye_prefix, 
ff57.pye_suffix, 
ff57.pye_st1, 
ff57.pye_st2, 
ff57.pye_city, 
ff57.pye_st,
ff57.pye_zip, 
ff57.entity_tp, 
ff57.entity_tp_desc, 
ff57.exp_tp_desc, 
ff57.catg_cd, 
ff57.catg_cd_desc, 
ff57.s_o_cand_id, 
ff57.s_o_cand_nm, 
ff57.s_o_cand_f_nm,
ff57.s_o_cand_l_nm, 
ff57.s_o_cand_m_nm, 
ff57.s_o_cand_prefix, 
ff57.s_o_cand_suffix, 
ff57.s_o_cand_office, 
ff57.s_o_cand_office_desc,
ff57.s_o_cand_office_st, 
ff57.s_o_cand_office_state_desc, 
ff57.s_o_cand_office_district, 
ff57.s_o_ind, 
ff57.s_o_ind_desc, 
ff57.election_tp,
ff57.fec_election_tp_desc, 
ff57.cal_ytd_ofc_sought, 
null AS dissem_dt,
ff57.exp_amt, 
ff57.exp_dt, 
ff57.exp_tp, 
ff57.exp_tp_desc, 
null AS memo_cd,
null AS memo_cd_desc,
null AS memo_text,
ff57.conduit_cmte_id, 
ff57.conduit_cmte_nm,
ff57.conduit_cmte_st1, 
ff57.conduit_cmte_st2, 
ff57.conduit_cmte_city, 
ff57.conduit_cmte_st, 
ff57.conduit_cmte_zip, 
null AS indt_sign_nm,
null AS indt_sign_dt,
null AS notary_sign_nm,
null AS notary_sign_dt,
null AS notary_commission_exprtn_dt,
null AS filer_l_nm,
null AS filer_f_nm,
null AS filer_m_nm,
null AS filer_prefix,
null AS filer_suffix,
ff57.action_cd, 
ff57.action_cd_desc,
ff57.tran_id, 
null AS back_ref_tran_id,
null AS back_ref_sched_nm,
ff57.schedule_type, 
ff57.schedule_type_desc, 
null AS line_num,
ff57.image_num, 
ff57.file_num, 
ff57.link_id, 
ff57.orig_sub_id, 
ff57.sub_id, 
ff57.filing_form,
ff57.rpt_tp, 
ff57.rpt_yr, 
ff57.election_cycle, 
image_pdf_url(ff57.image_num) as pdf_url,
coalesce(ff57.rpt_tp, '') in ('24', '48') AS is_notice, 
to_tsvector(parse_fulltext(ff57.pye_nm)),
fr.amndt_ind,
fr.prev_file_num
FROM disclosure.fec_fitem_f57 ff57
JOIN disclosure.f_rpt_or_form_sub fr 
ON ff57.link_id = fr.sub_id
-- -----------------
UNION
-- public.fec_f57_notice_vw
-- -----------------
SELECT 
f57.filer_cmte_id, 
null AS cmte_nm,
f57.pye_nm, 
f57.pye_l_nm, 
f57.pye_f_nm, 
f57.pye_m_nm, 
f57.pye_prefix, 
f57.pye_suffix, 
f57.pye_st1, 
f57.pye_st2, 
f57.pye_city, 
f57.pye_st,
f57.pye_zip, 
f57.entity_tp, 
f57.entity_tp_desc, 
f57.exp_tp_desc, 
f57.catg_cd, 
f57.catg_cd_desc, 
f57.s_o_cand_id, 
f57.s_o_cand_nm, 
f57.s_o_cand_f_nm,
f57.s_o_cand_l_nm, 
f57.s_o_cand_m_nm, 
f57.s_o_cand_prefix, 
f57.s_o_cand_suffix, 
f57.s_o_cand_office, 
f57.s_o_cand_office_desc,
f57.s_o_cand_office_st, 
f57.s_o_cand_office_state_desc, 
f57.s_o_cand_office_district, 
f57.s_o_ind, 
f57.s_o_ind_desc, 
f57.election_tp,
f57.fec_election_tp_desc, 
f57.cal_ytd_ofc_sought, 
null AS dissem_dt,
f57.exp_amt, 
f57.exp_dt, 
f57.exp_tp, 
f57.exp_tp_desc, 
null AS memo_cd,
null AS memo_cd_desc,
null AS memo_text,
f57.conduit_cmte_id, 
f57.conduit_cmte_nm,
f57.conduit_cmte_st1, 
f57.conduit_cmte_st2, 
f57.conduit_cmte_city, 
f57.conduit_cmte_st, 
f57.conduit_cmte_zip, 
null AS indt_sign_nm,
null AS indt_sign_dt,
null AS notary_sign_nm,
null AS notary_sign_dt,
null AS notary_commission_exprtn_dt,
null AS filer_l_nm,
null AS filer_f_nm,
null AS filer_m_nm,
null AS filer_prefix,
null AS filer_suffix,
f57.amndt_ind,
f57.amndt_ind_desc,
CASE
    WHEN "substring"(f57.sub_id::character varying::text, 1, 1) = '4'::text THEN f57.tran_id
    ELSE NULL::character varying
END AS tran_id, 
null AS back_ref_tran_id,
null AS back_ref_sched_nm,
'SE-F57' AS schedule_type, 
f57.form_tp_desc AS schedule_type_desc, 
null AS line_num,
f57.image_num, 
f57.file_num, 
f57.link_id, 
f57.orig_sub_id, 
f57.sub_id,
'F5' AS filing_form, 
f5.rpt_tp, 
f5.rpt_yr, 
f5.rpt_yr + mod(f5.rpt_yr, 2::numeric) AS election_cycle, 
image_pdf_url(f57.image_num) as pdf_url,
coalesce(f5.rpt_tp, '') in ('24', '48') AS is_notice, 
to_tsvector(parse_fulltext(f57.pye_nm)),
f5.amndt_ind AS amendment_indicator,
f5.prev_file_num AS previous_file_num
FROM disclosure.nml_form_57 f57
JOIN disclosure.nml_form_5 f5
ON f57.link_id = f5.sub_id 
WHERE (f5.rpt_tp::text = ANY (ARRAY['24'::character varying::text, '48'::character varying::text])) 
    AND f57.amndt_ind::text <> 'D'::text 
    AND f57.delete_ind IS NULL 
    AND f5.delete_ind IS NULL
)
SELECT 
SE.cmte_id,
SE.cmte_nm,
pye_nm,
payee_l_nm,
payee_f_nm,
payee_m_nm,
payee_prefix,
payee_suffix,
pye_st1,
pye_st2,
pye_city,
pye_st,
pye_zip,
entity_tp,
entity_tp_desc,
exp_desc,
catg_cd,
catg_cd_desc,
s_o_cand_id,
s_o_cand_nm,
s_o_cand_nm_first,
s_o_cand_nm_last,
s_o_cand_m_nm,
s_o_cand_prefix,
s_o_cand_suffix,
s_o_cand_office_desc,
s_o_cand_office_st_desc,
CASE when se.s_o_ind in ('O', 'S') then se.s_o_ind else NULL::character varying END AS s_o_ind,
s_o_ind_desc,
election_tp,
fec_election_tp_desc,
cal_ytd_ofc_sought,
dissem_dt,
exp_amt,
exp_dt,
exp_tp,
exp_tp_desc,
memo_cd,
memo_cd_desc,
memo_text,
conduit_cmte_id,
conduit_cmte_nm,
conduit_cmte_st1,
conduit_cmte_st2,
conduit_cmte_city,
conduit_cmte_st,
conduit_cmte_zip,
indt_sign_nm,
indt_sign_dt,
notary_sign_nm,
notary_sign_dt,
notary_commission_exprtn_dt,
filer_l_nm,
filer_f_nm,
filer_m_nm,
filer_prefix,
filer_suffix,
action_cd,
action_cd_desc,
tran_id,
back_ref_tran_id,
back_ref_sched_nm,
schedule_type,
schedule_type_desc,
line_num,
image_num,
file_num,
prev_file_num,
amndt_ind,
reps.rptnum AS amndt_number,
link_id,
orig_sub_id,
sub_id,
filing_form,
rpt_tp,
rpt_yr,
election_cycle,
pdf_url,
is_notice,
payee_name_text,
COALESCE(s_o_cand_office, cand.cand_office) AS cand_office,
COALESCE(s_o_cand_office_st, cand.cand_office_st) AS cand_office_st,
COALESCE(s_o_cand_office_district, cand.cand_office_district) AS cand_office_district,
cand.cand_pty_affiliation,
cmte.cmte_tp,
cmte.cmte_dsgn,
now() as pg_date
FROM se
LEFT OUTER JOIN disclosure.cand_valid_fec_yr cand
ON se.s_o_cand_id = cand.cand_id AND se.election_cycle = cand.fec_election_yr
LEFT OUTER JOIN disclosure.cmte_valid_fec_yr cmte
ON se.cmte_id = cmte.cmte_id AND se.election_cycle = cmte.fec_election_yr
LEFT OUTER JOIN real_efile.reps ON se.file_num = reps.repid
;

-- grants
ALTER TABLE public.ofec_sched_e_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_e_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_sched_e_mv_tmp TO fec_read;

-- Set up the unique key
create unique index IF NOT EXISTS idx_ofec_sched_e_mv_sub_id_tmp on ofec_sched_e_mv_tmp (sub_id);


-- Create simple indices on filtered columns
create index IF NOT EXISTS idx_ofec_sched_e_mv_cmte_id_tmp on ofec_sched_e_mv_tmp (cmte_id);
create index IF NOT EXISTS idx_ofec_sched_e_mv_cand_id_tmp on ofec_sched_e_mv_tmp (s_o_cand_id);
create index IF NOT EXISTS idx_ofec_sched_e_mv_filing_form_tmp on ofec_sched_e_mv_tmp (filing_form);
create index IF NOT EXISTS idx_ofec_sched_e_mv_election_cycle_tmp on ofec_sched_e_mv_tmp (election_cycle);
create index IF NOT EXISTS idx_ofec_sched_e_mv_is_notice_tmp on ofec_sched_e_mv_tmp (is_notice);

create index IF NOT EXISTS idx_ofec_sched_e_mv_cand_office_tmp on ofec_sched_e_mv_tmp (cand_office);
create index IF NOT EXISTS idx_ofec_sched_e_mv_cand_office_st_tmp on ofec_sched_e_mv_tmp (cand_office_st);
create index IF NOT EXISTS idx_ofec_sched_e_mv_cand_pty_tmp on ofec_sched_e_mv_tmp (cand_pty_affiliation);

-- -----------------------------------------------
-- public.ofec_sched_e_vw depends on public.ofec_sched_e_mv.  
-- It is not used by API OR other MV/VW yet.  Just drop and recreated
DROP VIEW IF EXISTS public.ofec_sched_e_vw;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_e_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_sched_e_mv_tmp RENAME TO ofec_sched_e_mv;

-- ---------------------------------
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_sub_id_tmp RENAME TO idx_ofec_sched_e_mv_sub_id;

ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_cmte_id_tmp RENAME TO idx_ofec_sched_e_mv_cmte_id;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_cand_id_tmp RENAME TO idx_ofec_sched_e_mv_cand_id;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_filing_form_tmp RENAME TO idx_ofec_sched_e_mv_filing_form;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_election_cycle_tmp RENAME TO idx_ofec_sched_e_mv_election_cycle;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_is_notice_tmp RENAME TO idx_ofec_sched_e_mv_is_notice;

ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_cand_office_tmp RENAME TO idx_ofec_sched_e_mv_cand_office;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_cand_office_st_tmp RENAME TO idx_ofec_sched_e_mv_cand_office_st;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_cand_pty_tmp RENAME TO idx_ofec_sched_e_mv_cand_pty;


-- ------------------------
CREATE OR REPLACE VIEW ofec_sched_e_vw AS SELECT * FROM ofec_sched_e_mv;
ALTER VIEW ofec_sched_e_vw OWNER TO fec;
GRANT SELECT ON ofec_sched_e_vw TO fec_read;


/*
This migration is needed to address change under V0144__add_affiliated_committee_to_committee_history.sql
while also preserving the to_tsvector component

Add `affiliated_committee_name` to:
1)  `ofec_committee_history_mv` and `public.ofec_committee_history_vw`
2)  `ofec_committee_detail_mv` and `public.ofec_committee_detail_vw`

    a) `create or replace `ofec_committee_history_vw` to use new `MV` logic
    b) drop old `MV`
    c) recreate `MV` with new logic
    d) `create or replace `ofec_committee_history_vw` -> `select all` from new `MV`
*/

-- Add `affiliated_committee_name` to:
-- 1)  `ofec_committee_history_mv` and `public.ofec_committee_history_vw`


-- a) `create or replace `ofec_committee_history_vw` to use new `MV` logic
CREATE OR REPLACE VIEW public.ofec_committee_history_vw AS
WITH cycles AS (
         SELECT cmte_valid_fec_yr.cmte_id,
            (array_agg(cmte_valid_fec_yr.fec_election_yr))::integer[] AS cycles,
            max(cmte_valid_fec_yr.fec_election_yr) AS max_cycle
           FROM disclosure.cmte_valid_fec_yr
          GROUP BY cmte_valid_fec_yr.cmte_id
        ), dates AS (
         SELECT f_rpt_or_form_sub.cand_cmte_id AS cmte_id,
            min(f_rpt_or_form_sub.receipt_dt) AS first_file_date,
            max(f_rpt_or_form_sub.receipt_dt) AS last_file_date,
            max(f_rpt_or_form_sub.receipt_dt) FILTER (WHERE ((f_rpt_or_form_sub.form_tp)::text = 'F1'::text)) AS last_f1_date
           FROM disclosure.f_rpt_or_form_sub
          GROUP BY f_rpt_or_form_sub.cand_cmte_id
        ), candidates AS (
         SELECT cand_cmte_linkage.cmte_id,
            (array_agg(DISTINCT cand_cmte_linkage.cand_id))::text[] AS candidate_ids
           FROM disclosure.cand_cmte_linkage
          GROUP BY cand_cmte_linkage.cmte_id
        )
 SELECT DISTINCT ON (fec_yr.cmte_id, fec_yr.fec_election_yr) row_number() OVER () AS idx,
    fec_yr.fec_election_yr AS cycle,
    fec_yr.cmte_id AS committee_id,
    fec_yr.cmte_nm AS name,
    fec_yr.tres_nm AS treasurer_name,
    to_tsvector(parse_fulltext((fec_yr.tres_nm)::text)) AS treasurer_text,
    f1.org_tp AS organization_type,
    expand_organization_type((f1.org_tp)::text) AS organization_type_full,
    fec_yr.cmte_st1 AS street_1,
    fec_yr.cmte_st2 AS street_2,
    fec_yr.cmte_city AS city,
    fec_yr.cmte_st AS state,
    expand_state((fec_yr.cmte_st)::text) AS state_full,
    fec_yr.cmte_zip AS zip,
    f1.tres_city AS treasurer_city,
    f1.tres_f_nm AS treasurer_name_1,
    f1.tres_l_nm AS treasurer_name_2,
    f1.tres_m_nm AS treasurer_name_middle,
    f1.tres_ph_num AS treasurer_phone,
    f1.tres_prefix AS treasurer_name_prefix,
    f1.tres_st AS treasurer_state,
    f1.tres_st1 AS treasurer_street_1,
    f1.tres_st2 AS treasurer_street_2,
    f1.tres_suffix AS treasurer_name_suffix,
    f1.tres_title AS treasurer_name_title,
    f1.tres_zip AS treasurer_zip,
    f1.cust_rec_city AS custodian_city,
    f1.cust_rec_f_nm AS custodian_name_1,
    f1.cust_rec_l_nm AS custodian_name_2,
    f1.cust_rec_m_nm AS custodian_name_middle,
    f1.cust_rec_nm AS custodian_name_full,
    f1.cust_rec_ph_num AS custodian_phone,
    f1.cust_rec_prefix AS custodian_name_prefix,
    f1.cust_rec_st AS custodian_state,
    f1.cust_rec_st1 AS custodian_street_1,
    f1.cust_rec_st2 AS custodian_street_2,
    f1.cust_rec_suffix AS custodian_name_suffix,
    f1.cust_rec_title AS custodian_name_title,
    f1.cust_rec_zip AS custodian_zip,
    fec_yr.cmte_email AS email,
    f1.cmte_fax AS fax,
    fec_yr.cmte_url AS website,
    f1.form_tp AS form_type,
    f1.leadership_pac,
    f1.lobbyist_registrant_pac,
    f1.cand_pty_tp AS party_type,
    f1.cand_pty_tp_desc AS party_type_full,
    f1.qual_dt AS qualifying_date,
    ((dates.first_file_date)::text)::date AS first_file_date,
    ((dates.last_file_date)::text)::date AS last_file_date,
    ((dates.last_f1_date)::text)::date AS last_f1_date,
    fec_yr.cmte_dsgn AS designation,
    expand_committee_designation((fec_yr.cmte_dsgn)::text) AS designation_full,
    fec_yr.cmte_tp AS committee_type,
    expand_committee_type((fec_yr.cmte_tp)::text) AS committee_type_full,
    fec_yr.cmte_filing_freq AS filing_frequency,
    fec_yr.cmte_pty_affiliation AS party,
    fec_yr.cmte_pty_affiliation_desc AS party_full,
    cycles.cycles,
    COALESCE(candidates.candidate_ids, '{}'::text[]) AS candidate_ids,
    f1.affiliated_cmte_nm AS affiliated_committee_name
   FROM ((((disclosure.cmte_valid_fec_yr fec_yr
     LEFT JOIN fec_vsum_f1_vw f1 ON ((((fec_yr.cmte_id)::text = (f1.cmte_id)::text) AND (fec_yr.fec_election_yr >= f1.rpt_yr))))
     LEFT JOIN cycles ON (((fec_yr.cmte_id)::text = (cycles.cmte_id)::text)))
     LEFT JOIN dates ON (((fec_yr.cmte_id)::text = (dates.cmte_id)::text)))
     LEFT JOIN candidates ON (((fec_yr.cmte_id)::text = (candidates.cmte_id)::text)))
  WHERE ((cycles.max_cycle >= (1979)::numeric) AND (NOT ((fec_yr.cmte_id)::text IN ( SELECT DISTINCT unverified_filers_vw.cmte_id
           FROM unverified_filers_vw
          WHERE ((unverified_filers_vw.cmte_id)::text ~~ 'C%'::text)))))
  ORDER BY fec_yr.cmte_id, fec_yr.fec_election_yr DESC, f1.rpt_yr DESC;

-- b) drop old `MV`

DROP MATERIALIZED VIEW public.ofec_committee_history_mv;

-- c) recreate `MV` with new logic

CREATE MATERIALIZED VIEW public.ofec_committee_history_mv AS
WITH cycles AS (
         SELECT cmte_valid_fec_yr.cmte_id,
            (array_agg(cmte_valid_fec_yr.fec_election_yr))::integer[] AS cycles,
            max(cmte_valid_fec_yr.fec_election_yr) AS max_cycle
           FROM disclosure.cmte_valid_fec_yr
          GROUP BY cmte_valid_fec_yr.cmte_id
        ), dates AS (
         SELECT f_rpt_or_form_sub.cand_cmte_id AS cmte_id,
            min(f_rpt_or_form_sub.receipt_dt) AS first_file_date,
            max(f_rpt_or_form_sub.receipt_dt) AS last_file_date,
            max(f_rpt_or_form_sub.receipt_dt) FILTER (WHERE ((f_rpt_or_form_sub.form_tp)::text = 'F1'::text)) AS last_f1_date
           FROM disclosure.f_rpt_or_form_sub
          GROUP BY f_rpt_or_form_sub.cand_cmte_id
        ), candidates AS (
         SELECT cand_cmte_linkage.cmte_id,
            (array_agg(DISTINCT cand_cmte_linkage.cand_id))::text[] AS candidate_ids
           FROM disclosure.cand_cmte_linkage
          GROUP BY cand_cmte_linkage.cmte_id
        )
 SELECT DISTINCT ON (fec_yr.cmte_id, fec_yr.fec_election_yr) row_number() OVER () AS idx,
    fec_yr.fec_election_yr AS cycle,
    fec_yr.cmte_id AS committee_id,
    fec_yr.cmte_nm AS name,
    fec_yr.tres_nm AS treasurer_name,
    to_tsvector(parse_fulltext((fec_yr.tres_nm)::text)) AS treasurer_text,
    f1.org_tp AS organization_type,
    expand_organization_type((f1.org_tp)::text) AS organization_type_full,
    fec_yr.cmte_st1 AS street_1,
    fec_yr.cmte_st2 AS street_2,
    fec_yr.cmte_city AS city,
    fec_yr.cmte_st AS state,
    expand_state((fec_yr.cmte_st)::text) AS state_full,
    fec_yr.cmte_zip AS zip,
    f1.tres_city AS treasurer_city,
    f1.tres_f_nm AS treasurer_name_1,
    f1.tres_l_nm AS treasurer_name_2,
    f1.tres_m_nm AS treasurer_name_middle,
    f1.tres_ph_num AS treasurer_phone,
    f1.tres_prefix AS treasurer_name_prefix,
    f1.tres_st AS treasurer_state,
    f1.tres_st1 AS treasurer_street_1,
    f1.tres_st2 AS treasurer_street_2,
    f1.tres_suffix AS treasurer_name_suffix,
    f1.tres_title AS treasurer_name_title,
    f1.tres_zip AS treasurer_zip,
    f1.cust_rec_city AS custodian_city,
    f1.cust_rec_f_nm AS custodian_name_1,
    f1.cust_rec_l_nm AS custodian_name_2,
    f1.cust_rec_m_nm AS custodian_name_middle,
    f1.cust_rec_nm AS custodian_name_full,
    f1.cust_rec_ph_num AS custodian_phone,
    f1.cust_rec_prefix AS custodian_name_prefix,
    f1.cust_rec_st AS custodian_state,
    f1.cust_rec_st1 AS custodian_street_1,
    f1.cust_rec_st2 AS custodian_street_2,
    f1.cust_rec_suffix AS custodian_name_suffix,
    f1.cust_rec_title AS custodian_name_title,
    f1.cust_rec_zip AS custodian_zip,
    fec_yr.cmte_email AS email,
    f1.cmte_fax AS fax,
    fec_yr.cmte_url AS website,
    f1.form_tp AS form_type,
    f1.leadership_pac,
    f1.lobbyist_registrant_pac,
    f1.cand_pty_tp AS party_type,
    f1.cand_pty_tp_desc AS party_type_full,
    f1.qual_dt AS qualifying_date,
    ((dates.first_file_date)::text)::date AS first_file_date,
    ((dates.last_file_date)::text)::date AS last_file_date,
    ((dates.last_f1_date)::text)::date AS last_f1_date,
    fec_yr.cmte_dsgn AS designation,
    expand_committee_designation((fec_yr.cmte_dsgn)::text) AS designation_full,
    fec_yr.cmte_tp AS committee_type,
    expand_committee_type((fec_yr.cmte_tp)::text) AS committee_type_full,
    fec_yr.cmte_filing_freq AS filing_frequency,
    fec_yr.cmte_pty_affiliation AS party,
    fec_yr.cmte_pty_affiliation_desc AS party_full,
    cycles.cycles,
    COALESCE(candidates.candidate_ids, '{}'::text[]) AS candidate_ids,
    f1.affiliated_cmte_nm AS affiliated_committee_name
   FROM ((((disclosure.cmte_valid_fec_yr fec_yr
     LEFT JOIN fec_vsum_f1_vw f1 ON ((((fec_yr.cmte_id)::text = (f1.cmte_id)::text) AND (fec_yr.fec_election_yr >= f1.rpt_yr))))
     LEFT JOIN cycles ON (((fec_yr.cmte_id)::text = (cycles.cmte_id)::text)))
     LEFT JOIN dates ON (((fec_yr.cmte_id)::text = (dates.cmte_id)::text)))
     LEFT JOIN candidates ON (((fec_yr.cmte_id)::text = (candidates.cmte_id)::text)))
  WHERE ((cycles.max_cycle >= (1979)::numeric) AND (NOT ((fec_yr.cmte_id)::text IN ( SELECT DISTINCT unverified_filers_vw.cmte_id
           FROM unverified_filers_vw
          WHERE ((unverified_filers_vw.cmte_id)::text ~~ 'C%'::text)))))
  ORDER BY fec_yr.cmte_id, fec_yr.fec_election_yr DESC, f1.rpt_yr DESC;

--Permissions

ALTER TABLE public.ofec_committee_history_mv
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_committee_history_mv TO fec;
GRANT SELECT ON TABLE public.ofec_committee_history_mv TO fec_read;

--Indices

CREATE UNIQUE INDEX ofec_committee_history_mv_idx_idx1
ON public.ofec_committee_history_mv
USING btree (idx);

CREATE INDEX ofec_committee_history_mv_committee_id_idx1
ON public.ofec_committee_history_mv
USING btree (committee_id);

CREATE INDEX ofec_committee_history_mv_cycle_committee_id_idx1
ON public.ofec_committee_history_mv
USING btree (cycle, committee_id);

CREATE INDEX ofec_committee_history_mv_cycle_idx1
ON public.ofec_committee_history_mv
USING btree (cycle);

CREATE INDEX ofec_committee_history_mv_designation_idx1
ON public.ofec_committee_history_mv
USING btree (designation);

CREATE INDEX ofec_committee_history_mv_first_file_date_idx
ON public.ofec_committee_history_mv
USING btree (first_file_date);

CREATE INDEX ofec_committee_history_mv_name_idx1
ON public.ofec_committee_history_mv
USING btree (name);

CREATE INDEX ofec_committee_history_mv_state_idx1
ON public.ofec_committee_history_mv
USING btree (state);

CREATE INDEX ofec_committee_history_mv_comid_state_idx1
ON public.ofec_committee_history_mv
USING btree (committee_id, state);


-- d) `create or replace `public.ofec_committee_history_vw` -> `select all` from new `MV`

CREATE OR REPLACE VIEW public.ofec_committee_history_vw AS
SELECT * FROM public.ofec_committee_history_mv;

-- Add `affiliated_committee_name` to:
-- 2)  `ofec_committee_detail_mv` and `public.ofec_committee_detail_vw`

-- a) `create or replace `XXX_vw` to use new `MV` logic

CREATE OR REPLACE VIEW public.ofec_committee_detail_vw AS
SELECT DISTINCT ON (ofec_committee_history_vw.committee_id)
    ofec_committee_history_vw.idx,
    ofec_committee_history_vw.cycle,
    ofec_committee_history_vw.committee_id,
    ofec_committee_history_vw.name,
    ofec_committee_history_vw.treasurer_name,
    ofec_committee_history_vw.treasurer_text,
    ofec_committee_history_vw.organization_type,
    ofec_committee_history_vw.organization_type_full,
    ofec_committee_history_vw.street_1,
    ofec_committee_history_vw.street_2,
    ofec_committee_history_vw.city,
    ofec_committee_history_vw.state,
    ofec_committee_history_vw.state_full,
    ofec_committee_history_vw.zip,
    ofec_committee_history_vw.treasurer_city,
    ofec_committee_history_vw.treasurer_name_1,
    ofec_committee_history_vw.treasurer_name_2,
    ofec_committee_history_vw.treasurer_name_middle,
    ofec_committee_history_vw.treasurer_phone,
    ofec_committee_history_vw.treasurer_name_prefix,
    ofec_committee_history_vw.treasurer_state,
    ofec_committee_history_vw.treasurer_street_1,
    ofec_committee_history_vw.treasurer_street_2,
    ofec_committee_history_vw.treasurer_name_suffix,
    ofec_committee_history_vw.treasurer_name_title,
    ofec_committee_history_vw.treasurer_zip,
    ofec_committee_history_vw.custodian_city,
    ofec_committee_history_vw.custodian_name_1,
    ofec_committee_history_vw.custodian_name_2,
    ofec_committee_history_vw.custodian_name_middle,
    ofec_committee_history_vw.custodian_name_full,
    ofec_committee_history_vw.custodian_phone,
    ofec_committee_history_vw.custodian_name_prefix,
    ofec_committee_history_vw.custodian_state,
    ofec_committee_history_vw.custodian_street_1,
    ofec_committee_history_vw.custodian_street_2,
    ofec_committee_history_vw.custodian_name_suffix,
    ofec_committee_history_vw.custodian_name_title,
    ofec_committee_history_vw.custodian_zip,
    ofec_committee_history_vw.email,
    ofec_committee_history_vw.fax,
    ofec_committee_history_vw.website,
    ofec_committee_history_vw.form_type,
    ofec_committee_history_vw.leadership_pac,
    ofec_committee_history_vw.lobbyist_registrant_pac,
    ofec_committee_history_vw.party_type,
    ofec_committee_history_vw.party_type_full,
    ofec_committee_history_vw.qualifying_date,
    ofec_committee_history_vw.first_file_date,
    ofec_committee_history_vw.last_file_date,
    ofec_committee_history_vw.last_f1_date,
    ofec_committee_history_vw.designation,
    ofec_committee_history_vw.designation_full,
    ofec_committee_history_vw.committee_type,
    ofec_committee_history_vw.committee_type_full,
    ofec_committee_history_vw.filing_frequency,
    ofec_committee_history_vw.party,
    ofec_committee_history_vw.party_full,
    ofec_committee_history_vw.cycles,
    ofec_committee_history_vw.candidate_ids,
    ofec_committee_history_vw.affiliated_committee_name
   FROM ofec_committee_history_vw
  ORDER BY ofec_committee_history_vw.committee_id, ofec_committee_history_vw.cycle DESC;

-- b) drop old `MV`

DROP MATERIALIZED VIEW public.ofec_committee_detail_mv;

-- c) recreate `MV` with new logic

CREATE MATERIALIZED VIEW public.ofec_committee_detail_mv AS
SELECT DISTINCT ON (ofec_committee_history_vw.committee_id)
    ofec_committee_history_vw.idx,
    ofec_committee_history_vw.cycle,
    ofec_committee_history_vw.committee_id,
    ofec_committee_history_vw.name,
    ofec_committee_history_vw.treasurer_name,
    ofec_committee_history_vw.treasurer_text,
    ofec_committee_history_vw.organization_type,
    ofec_committee_history_vw.organization_type_full,
    ofec_committee_history_vw.street_1,
    ofec_committee_history_vw.street_2,
    ofec_committee_history_vw.city,
    ofec_committee_history_vw.state,
    ofec_committee_history_vw.state_full,
    ofec_committee_history_vw.zip,
    ofec_committee_history_vw.treasurer_city,
    ofec_committee_history_vw.treasurer_name_1,
    ofec_committee_history_vw.treasurer_name_2,
    ofec_committee_history_vw.treasurer_name_middle,
    ofec_committee_history_vw.treasurer_phone,
    ofec_committee_history_vw.treasurer_name_prefix,
    ofec_committee_history_vw.treasurer_state,
    ofec_committee_history_vw.treasurer_street_1,
    ofec_committee_history_vw.treasurer_street_2,
    ofec_committee_history_vw.treasurer_name_suffix,
    ofec_committee_history_vw.treasurer_name_title,
    ofec_committee_history_vw.treasurer_zip,
    ofec_committee_history_vw.custodian_city,
    ofec_committee_history_vw.custodian_name_1,
    ofec_committee_history_vw.custodian_name_2,
    ofec_committee_history_vw.custodian_name_middle,
    ofec_committee_history_vw.custodian_name_full,
    ofec_committee_history_vw.custodian_phone,
    ofec_committee_history_vw.custodian_name_prefix,
    ofec_committee_history_vw.custodian_state,
    ofec_committee_history_vw.custodian_street_1,
    ofec_committee_history_vw.custodian_street_2,
    ofec_committee_history_vw.custodian_name_suffix,
    ofec_committee_history_vw.custodian_name_title,
    ofec_committee_history_vw.custodian_zip,
    ofec_committee_history_vw.email,
    ofec_committee_history_vw.fax,
    ofec_committee_history_vw.website,
    ofec_committee_history_vw.form_type,
    ofec_committee_history_vw.leadership_pac,
    ofec_committee_history_vw.lobbyist_registrant_pac,
    ofec_committee_history_vw.party_type,
    ofec_committee_history_vw.party_type_full,
    ofec_committee_history_vw.qualifying_date,
    ofec_committee_history_vw.first_file_date,
    ofec_committee_history_vw.last_file_date,
    ofec_committee_history_vw.last_f1_date,
    ofec_committee_history_vw.designation,
    ofec_committee_history_vw.designation_full,
    ofec_committee_history_vw.committee_type,
    ofec_committee_history_vw.committee_type_full,
    ofec_committee_history_vw.filing_frequency,
    ofec_committee_history_vw.party,
    ofec_committee_history_vw.party_full,
    ofec_committee_history_vw.cycles,
    ofec_committee_history_vw.candidate_ids,
    ofec_committee_history_vw.affiliated_committee_name
   FROM ofec_committee_history_vw
  ORDER BY ofec_committee_history_vw.committee_id, ofec_committee_history_vw.cycle DESC;

--Permissions

ALTER TABLE public.ofec_committee_detail_mv
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_committee_detail_mv TO fec;
GRANT SELECT ON TABLE public.ofec_committee_detail_mv TO fec_read;

--Indices

CREATE UNIQUE INDEX ofec_committee_detail_mv_idx_idx1
ON ofec_committee_detail_mv USING btree (idx);

CREATE INDEX ofec_committee_detail_mv_candidate_ids_idx1
ON ofec_committee_detail_mv USING gin (candidate_ids);

CREATE INDEX ofec_committee_detail_mv_committee_id_idx1
ON ofec_committee_detail_mv USING btree (committee_id);

CREATE INDEX ofec_committee_detail_mv_committee_type_full_idx1
ON ofec_committee_detail_mv USING btree (committee_type_full);

CREATE INDEX ofec_committee_detail_mv_committee_type_idx1
ON ofec_committee_detail_mv USING btree (committee_type);

CREATE INDEX ofec_committee_detail_mv_cycles_candidate_ids_idx1
ON ofec_committee_detail_mv USING gin (cycles, candidate_ids);

CREATE INDEX ofec_committee_detail_mv_cycles_idx1
ON ofec_committee_detail_mv USING gin (cycles);

CREATE INDEX ofec_committee_detail_mv_designation_full_idx1
ON ofec_committee_detail_mv USING btree (designation_full);

CREATE INDEX ofec_committee_detail_mv_designation_idx1
ON ofec_committee_detail_mv USING btree (designation);

CREATE INDEX ofec_committee_detail_mv_first_file_date_idx1
ON ofec_committee_detail_mv USING btree (first_file_date);

CREATE INDEX ofec_committee_detail_mv_last_file_date_idx1
ON ofec_committee_detail_mv USING btree (last_file_date);

CREATE INDEX ofec_committee_detail_mv_name_idx1
ON ofec_committee_detail_mv USING btree (name);

CREATE INDEX ofec_committee_detail_mv_organization_type_full_idx1
ON ofec_committee_detail_mv USING btree (organization_type_full);

CREATE INDEX ofec_committee_detail_mv_organization_type_idx1
ON ofec_committee_detail_mv USING btree (organization_type);

CREATE INDEX ofec_committee_detail_mv_party_full_idx1
ON ofec_committee_detail_mv USING btree (party_full);

CREATE INDEX ofec_committee_detail_mv_party_idx1
ON ofec_committee_detail_mv USING btree (party);

CREATE INDEX ofec_committee_detail_mv_state_idx1
ON ofec_committee_detail_mv USING btree (state);

CREATE INDEX ofec_committee_detail_mv_treasurer_name_idx1
ON ofec_committee_detail_mv USING btree (treasurer_name);

CREATE INDEX ofec_committee_detail_mv_treasurer_text_idx1
ON ofec_committee_detail_mv USING gin (treasurer_text);

-- d) `create or replace `public.XXX_vw` -> `select all` from new `MV`

CREATE OR REPLACE VIEW public.ofec_committee_detail_vw AS
SELECT * FROM public.ofec_committee_detail_mv;
