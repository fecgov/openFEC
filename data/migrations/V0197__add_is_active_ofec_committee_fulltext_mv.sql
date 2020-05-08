/*
This migration file is for #4296
1) Add is_active column to ofec_committee_fulltext_mv
*/

-- ----------
-- ofec_committee_detail_mv
-- ----------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_committee_fulltext_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_committee_fulltext_mv_tmp AS
WITH pacronyms AS (
         SELECT ofec_pacronyms."ID NUMBER" AS committee_id,
            string_agg(ofec_pacronyms."PACRONYM", ' '::text) AS pacronyms
           FROM ofec_pacronyms
          GROUP BY ofec_pacronyms."ID NUMBER"
        ), totals AS (
         SELECT ofec_totals_combined_vw.committee_id,
            sum(ofec_totals_combined_vw.receipts) AS receipts,
            sum(ofec_totals_combined_vw.disbursements) AS disbursements,
            sum(ofec_totals_combined_vw.independent_expenditures) AS independent_expenditures
           FROM ofec_totals_combined_vw
          GROUP BY ofec_totals_combined_vw.committee_id
        )
 SELECT DISTINCT ON (committee_id) row_number() OVER () AS idx,
    committee_id AS id,
    cd.name,
        CASE
            WHEN cd.name IS NOT NULL THEN (setweight(to_tsvector(parse_fulltext(cd.name::text)::text), 'A'::"char") || setweight(to_tsvector(COALESCE(parse_fulltext(pac.pacronyms), ''::text::character varying)::text), 'A'::"char")) || setweight(to_tsvector(parse_fulltext(committee_id::text)::text), 'B'::"char")
            ELSE NULL::tsvector
        END AS fulltxt,
    COALESCE(totals.receipts, 0::numeric) AS receipts,
    COALESCE(totals.disbursements, 0::numeric) AS disbursements,
    COALESCE(totals.independent_expenditures, 0::numeric) AS independent_expenditures,
    COALESCE(totals.receipts, 0::numeric) + COALESCE(totals.disbursements, 0::numeric) + COALESCE(totals.independent_expenditures, 0::numeric) AS total_activity
   FROM ofec_committee_detail_vw cd
     LEFT JOIN pacronyms pac USING (committee_id)
     LEFT JOIN totals USING (committee_id)
WITH DATA;

--Permissions

ALTER TABLE public.ofec_committee_fulltext_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_committee_fulltext_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_committee_fulltext_mv_tmp TO fec_read;

--Indices

CREATE INDEX idx_ofec_committee_fulltext_mv_tmp_disbursements
 ON public.ofec_committee_fulltext_mv_tmp
 USING btree
 (disbursements);
CREATE INDEX idx_ofec_committee_fulltext_mv_tmp_fulltxt
 ON public.ofec_committee_fulltext_mv_tmp
 USING gin
 (fulltxt);
CREATE UNIQUE INDEX idx_ofec_committee_fulltext_mv_tmp_idx
 ON public.ofec_committee_fulltext_mv_tmp
 USING btree
 (idx);
CREATE INDEX idx_ofec_committee_fulltext_mv_tmp_independent_expenditures
 ON public.ofec_committee_fulltext_mv_tmp
 USING btree
 (independent_expenditures);
CREATE INDEX idx_ofec_committee_fulltext_mv_tmp_receipts
 ON public.ofec_committee_fulltext_mv_tmp
 USING btree
 (receipts);
CREATE INDEX idx_ofec_committee_fulltext_mv_tmp_total_activity
 ON public.ofec_committee_fulltext_mv_tmp
 USING btree
 (total_activity);

-- ----------
CREATE OR REPLACE VIEW ofec_committee_fulltext_vw AS
 SELECT * FROM ofec_committee_fulltext_mv_tmp;
-- ----------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_committee_fulltext_mv;
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_committee_fulltext_mv_tmp RENAME TO ofec_committee_fulltext_mv;
-- ----------
ALTER INDEX public.idx_ofec_committee_fulltext_mv_tmp_disbursements RENAME TO idx_ofec_committee_fulltext_mv_disbursements;
ALTER INDEX public.idx_ofec_committee_fulltext_mv_tmp_fulltxt RENAME TO idx_ofec_committee_fulltext_mv_fulltxt;
ALTER INDEX public.idx_ofec_committee_fulltext_mv_tmp_idx RENAME TO idx_ofec_committee_fulltext_tmp_idx;
ALTER INDEX public.idx_ofec_committee_fulltext_mv_tmp_independent_expenditures RENAME TO idx_ofec_committee_fulltext_mv_independent_expenditures;
ALTER INDEX public.idx_ofec_committee_fulltext_mv_tmp_receipts RENAME TO idx_ofec_committee_fulltext_mv_receipts;
ALTER INDEX public.idx_ofec_committee_fulltext_mv_tmp_total_activity RENAME TO idx_ofec_committee_fulltext_mv_total_activity;
