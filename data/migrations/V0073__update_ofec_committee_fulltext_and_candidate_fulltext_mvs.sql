/*
From issue #3057 - Update sort order for search results

-Add disbursement totals and IE totals to committees: ofec_committee_fulltext_mv
-Add disbursement totals to candidates: ofec_candidate_fulltext_mv

- Add indexes and permissions

- Rename _tmp views and indexes
*/

SET search_path = public, pg_catalog;

DROP MATERIALIZED VIEW IF EXISTS ofec_committee_fulltext_mv_tmp;

CREATE MATERIALIZED VIEW ofec_committee_fulltext_mv_tmp AS
 WITH pacronyms AS (
         SELECT ofec_pacronyms."ID NUMBER" AS committee_id,
            string_agg(ofec_pacronyms."PACRONYM", ' '::text) AS pacronyms
           FROM ofec_pacronyms
          GROUP BY ofec_pacronyms."ID NUMBER"
        ), totals AS (
         SELECT ofec_totals_combined_mv.committee_id,
            sum(ofec_totals_combined_mv.receipts) AS receipts,
            sum(ofec_totals_combined_mv.disbursements) AS disbursements,
            sum(ofec_totals_combined_mv.independent_expenditures) AS independent_expenditures
           FROM ofec_totals_combined_mv
          GROUP BY ofec_totals_combined_mv.committee_id
        )
 SELECT DISTINCT ON (committee_id) row_number() OVER () AS idx,
    committee_id AS id,
    cd.name,
        CASE
            WHEN (cd.name IS NOT NULL) THEN ((setweight(to_tsvector((cd.name)::text), 'A'::"char") || setweight(to_tsvector(COALESCE(pac.pacronyms, ''::text)), 'A'::"char")) || setweight(to_tsvector((committee_id)::text), 'B'::"char"))
            ELSE NULL::tsvector
        END AS fulltxt,
    COALESCE(totals.receipts, (0)::numeric) AS receipts,
    COALESCE(totals.disbursements, (0)::numeric) AS disbursements,
    COALESCE(totals.independent_expenditures, (0)::numeric) AS independent_expenditures,
    COALESCE(totals.receipts, (0)::numeric) + COALESCE(totals.disbursements, (0)::numeric) + COALESCE(totals.independent_expenditures, (0)::numeric) AS total_activity
   FROM ((ofec_committee_detail_mv cd
     LEFT JOIN pacronyms pac USING (committee_id))
     LEFT JOIN totals USING (committee_id));

--Permissions-------------------

ALTER TABLE ofec_committee_fulltext_mv_tmp OWNER TO fec;
GRANT SELECT ON TABLE ofec_committee_fulltext_mv_tmp TO fec_read;
GRANT ALL ON TABLE ofec_committee_fulltext_mv_tmp TO fec;

--Indexes including unique idx--

CREATE UNIQUE INDEX ofec_committee_fulltext_mv_idx_idx1_tmp ON ofec_committee_fulltext_mv_tmp USING btree (idx);

CREATE INDEX ofec_committee_fulltext_mv_fulltxt_idx1_tmp ON ofec_committee_fulltext_mv_tmp USING gin (fulltxt);

CREATE INDEX ofec_committee_fulltext_mv_receipts_idx1_tmp ON ofec_committee_fulltext_mv_tmp USING btree (receipts);

CREATE INDEX ofec_committee_fulltext_mv_disbursements_idx1_tmp ON ofec_committee_fulltext_mv_tmp USING btree (disbursements);

CREATE INDEX ofec_committee_fulltext_mv_independent_expenditures_idx1_tmp ON ofec_committee_fulltext_mv_tmp USING btree (independent_expenditures);

CREATE INDEX ofec_committee_fulltext_mv_total_activity_idx1_tmp ON ofec_committee_fulltext_mv_tmp USING btree (total_activity);

----Rename view & indexes-------

DROP MATERIALIZED VIEW IF EXISTS ofec_committee_fulltext_mv;

ALTER MATERIALIZED VIEW IF EXISTS ofec_committee_fulltext_mv_tmp RENAME TO ofec_committee_fulltext_mv;

SELECT rename_indexes('ofec_committee_fulltext_mv');

/*------------------------------

Candidates - add disbursements only

-------------------------------*/

DROP MATERIALIZED VIEW IF EXISTS ofec_candidate_fulltext_mv_tmp;

CREATE MATERIALIZED VIEW ofec_candidate_fulltext_mv_tmp AS
 WITH nicknames AS (
         SELECT ofec_nicknames.candidate_id,
            string_agg(ofec_nicknames.nickname, ' '::text) AS nicknames
           FROM ofec_nicknames
          GROUP BY ofec_nicknames.candidate_id
        ), totals AS (
         SELECT link.cand_id AS candidate_id,
            sum(totals_1.receipts) AS receipts,
            sum(totals_1.disbursements) AS disbursements
           FROM (disclosure.cand_cmte_linkage link
             JOIN ofec_totals_combined_mv totals_1 ON ((((link.cmte_id)::text = (totals_1.committee_id)::text) AND (link.fec_election_yr = (totals_1.cycle)::numeric))))
          WHERE (((link.cmte_dsgn)::text = ANY ((ARRAY['P'::character varying, 'A'::character varying])::text[])) AND ((substr((link.cand_id)::text, 1, 1) = (link.cmte_tp)::text) OR ((link.cmte_tp)::text <> ALL ((ARRAY['P'::character varying, 'S'::character varying, 'H'::character varying])::text[]))))
          GROUP BY link.cand_id
        )
 SELECT DISTINCT ON (candidate_id) row_number() OVER () AS idx,
    candidate_id AS id,
    ofec_candidate_detail_mv.name,
    ofec_candidate_detail_mv.office AS office_sought,
        CASE
            WHEN (ofec_candidate_detail_mv.name IS NOT NULL) THEN ((setweight(to_tsvector((ofec_candidate_detail_mv.name)::text), 'A'::"char") || setweight(to_tsvector(COALESCE(nicknames.nicknames, ''::text)), 'A'::"char")) || setweight(to_tsvector((candidate_id)::text), 'B'::"char"))
            ELSE NULL::tsvector
        END AS fulltxt,
    COALESCE(totals.receipts, (0)::numeric) AS receipts,
    COALESCE(totals.disbursements, (0)::numeric) AS disbursements,
    COALESCE(totals.receipts, (0)::numeric) + COALESCE(totals.disbursements, (0)::numeric) AS total_activity
   FROM ((ofec_candidate_detail_mv
     LEFT JOIN nicknames USING (candidate_id))
     LEFT JOIN totals USING (candidate_id));

--Permissions-------------------

ALTER TABLE ofec_candidate_fulltext_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE ofec_candidate_fulltext_mv_tmp TO fec;
GRANT SELECT ON TABLE ofec_candidate_fulltext_mv_tmp TO fec_read;

--Indexes uncluding unique idx---

CREATE UNIQUE INDEX ofec_candidate_fulltext_mv_idx_idx1_tmp ON ofec_candidate_fulltext_mv_tmp USING btree (idx);

CREATE INDEX ofec_candidate_fulltext_mv_fulltxt_idx1_tmp ON ofec_candidate_fulltext_mv_tmp USING gin (fulltxt);

CREATE INDEX ofec_candidate_fulltext_mv_receipts_idx1_tmp ON ofec_candidate_fulltext_mv_tmp USING btree (receipts);

CREATE INDEX ofec_candidate_fulltext_mv_disbursements_idx1_tmp ON ofec_candidate_fulltext_mv_tmp USING btree (disbursements);

CREATE INDEX ofec_candidate_fulltext_mv_total_activity_idx1_tmp ON ofec_candidate_fulltext_mv_tmp USING btree (total_activity);

----Rename view & indexes-------

DROP MATERIALIZED VIEW IF EXISTS ofec_candidate_fulltext_mv;

ALTER MATERIALIZED VIEW IF EXISTS ofec_candidate_fulltext_mv_tmp RENAME TO ofec_candidate_fulltext_mv;

SELECT rename_indexes('ofec_candidate_fulltext_mv');
