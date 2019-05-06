/*
This is to solve issue #3747
Calculation of election_yr_to_be_included column in this mv does not address the odd year special election under some situation.
*/
CREATE OR REPLACE VIEW public.ofec_cand_cmte_linkage_vw AS 
WITH 
election_yr AS (
    SELECT cand_cmte_linkage.cand_id,
-- -----  
    cand_cmte_linkage.cand_election_yr AS orig_cand_election_yr,
-- -----  
    cand_cmte_linkage.cand_election_yr + cand_cmte_linkage.cand_election_yr % 2::numeric AS cand_election_yr
    FROM disclosure.cand_cmte_linkage
    WHERE substr(cand_cmte_linkage.cand_id::text, 1, 1) = cand_cmte_linkage.cmte_tp::text OR (cand_cmte_linkage.cmte_tp::text <> ALL (ARRAY['P'::character varying::text, 'S'::character varying::text, 'H'::character varying::text]))
    GROUP BY cand_cmte_linkage.cand_id, cand_election_yr, (cand_cmte_linkage.cand_election_yr + cand_cmte_linkage.cand_election_yr % 2::numeric)
), cand_election_yrs AS (
    SELECT election_yr.cand_id,
    election_yr.orig_cand_election_yr,
    election_yr.cand_election_yr,
-- -----      
    lead(election_yr.cand_election_yr) OVER (PARTITION BY election_yr.cand_id ORDER BY election_yr.orig_cand_election_yr) AS next_election
    FROM election_yr
)
SELECT row_number() OVER () AS idx,
    link.linkage_id,
    link.cand_id,
    link.cand_election_yr,
    link.fec_election_yr,
    link.cmte_id,
    link.cmte_tp,
    link.cmte_dsgn,
    link.linkage_type,
    link.user_id_entered,
    link.date_entered,
    link.user_id_changed,
    link.date_changed,
    link.cmte_count_cand_yr,
    link.efile_paper_ind,
    link.pg_date,
        CASE
            WHEN link.cand_election_yr = link.fec_election_yr THEN link.cand_election_yr
    -- -----  
        WHEN link.cand_election_yr%2 = 1 and substr(link.cand_id::text, 1, 1) = 'H' THEN
            CASE 
            WHEN link.fec_election_yr <= link.cand_election_yr+link.cand_election_yr%2 then link.cand_election_yr+link.cand_election_yr%2
            ELSE NULL
            END
    -- -----
            WHEN yrs.next_election IS NULL THEN
            CASE
            WHEN link.fec_election_yr <= yrs.cand_election_yr AND (yrs.cand_election_yr-link.fec_election_yr <
            CASE
            WHEN link.cmte_tp::text = 'P'::text THEN 4
            WHEN link.cmte_tp::text = 'S'::text THEN 6
            WHEN link.cmte_tp::text = 'H'::text THEN 2
            ELSE NULL::integer
            END::numeric) 
            THEN yrs.cand_election_yr
                ELSE NULL::numeric
                END
            --
            WHEN link.fec_election_yr > link.cand_election_yr AND link.fec_election_yr > (yrs.next_election -
                CASE
                WHEN link.cmte_tp::text = 'P'::text THEN 4
                WHEN link.cmte_tp::text = 'S'::text THEN 6
                WHEN link.cmte_tp::text = 'H'::text THEN 2
                ELSE NULL::integer
                END::numeric) 
                THEN yrs.next_election
            --
            WHEN link.fec_election_yr > link.cand_election_yr AND link.fec_election_yr <= (yrs.next_election -
                CASE
                WHEN link.cmte_tp::text = 'P'::text THEN 4
                WHEN link.cmte_tp::text = 'S'::text THEN 6
                WHEN link.cmte_tp::text = 'H'::text THEN 2
                ELSE NULL::integer
                END::numeric) 
                THEN NULL::numeric
    -- -----
            WHEN link.fec_election_yr < link.cand_election_yr AND (yrs.cand_election_yr-link.fec_election_yr <
                CASE
                WHEN link.cmte_tp::text = 'P'::text THEN 4
                WHEN link.cmte_tp::text = 'S'::text THEN 6
                WHEN link.cmte_tp::text = 'H'::text THEN 2
                ELSE NULL::integer
                END::numeric) 
                THEN yrs.cand_election_yr
    -- -----
            ELSE NULL::numeric
        END::numeric(4,0) AS election_yr_to_be_included
        --, yrs.next_election
        --, yrs.cand_election_yr yrs_cand_yr
   FROM disclosure.cand_cmte_linkage link
     LEFT JOIN cand_election_yrs yrs ON link.cand_id::text = yrs.cand_id::text AND link.cand_election_yr = yrs.orig_cand_election_yr
  WHERE substr(link.cand_id::text, 1, 1) = link.cmte_tp::text OR (link.cmte_tp::text <> ALL (ARRAY['P'::character varying::text, 'S'::character varying::text, 'H'::character varying::text]));

DROP MATERIALIZED VIEW IF EXISTS public.ofec_cand_cmte_linkage_mv_tmp;
CREATE MATERIALIZED VIEW ofec_cand_cmte_linkage_mv_tmp AS
WITH 
election_yr AS (
    SELECT cand_cmte_linkage.cand_id,
-- -----  
    cand_cmte_linkage.cand_election_yr AS orig_cand_election_yr,
-- -----  
    cand_cmte_linkage.cand_election_yr + cand_cmte_linkage.cand_election_yr % 2::numeric AS cand_election_yr
    FROM disclosure.cand_cmte_linkage
    WHERE substr(cand_cmte_linkage.cand_id::text, 1, 1) = cand_cmte_linkage.cmte_tp::text OR (cand_cmte_linkage.cmte_tp::text <> ALL (ARRAY['P'::character varying::text, 'S'::character varying::text, 'H'::character varying::text]))
    GROUP BY cand_cmte_linkage.cand_id, cand_election_yr, (cand_cmte_linkage.cand_election_yr + cand_cmte_linkage.cand_election_yr % 2::numeric)
), cand_election_yrs AS (
    SELECT election_yr.cand_id,
    election_yr.orig_cand_election_yr,
    election_yr.cand_election_yr,
-- -----      
    lead(election_yr.cand_election_yr) OVER (PARTITION BY election_yr.cand_id ORDER BY election_yr.orig_cand_election_yr) AS next_election
    FROM election_yr
)
SELECT row_number() OVER () AS idx,
    link.linkage_id,
    link.cand_id,
    link.cand_election_yr,
    link.fec_election_yr,
    link.cmte_id,
    link.cmte_tp,
    link.cmte_dsgn,
    link.linkage_type,
    link.user_id_entered,
    link.date_entered,
    link.user_id_changed,
    link.date_changed,
    link.cmte_count_cand_yr,
    link.efile_paper_ind,
    link.pg_date,
        CASE
            WHEN link.cand_election_yr = link.fec_election_yr THEN link.cand_election_yr
    -- -----  
        WHEN link.cand_election_yr%2 = 1 and substr(link.cand_id::text, 1, 1) = 'H' THEN
            CASE 
            WHEN link.fec_election_yr <= link.cand_election_yr+link.cand_election_yr%2 then link.cand_election_yr+link.cand_election_yr%2
            ELSE NULL
            END
    -- -----
            WHEN yrs.next_election IS NULL THEN
            CASE
            WHEN link.fec_election_yr <= yrs.cand_election_yr AND (yrs.cand_election_yr-link.fec_election_yr <
            CASE
            WHEN link.cmte_tp::text = 'P'::text THEN 4
            WHEN link.cmte_tp::text = 'S'::text THEN 6
            WHEN link.cmte_tp::text = 'H'::text THEN 2
            ELSE NULL::integer
            END::numeric) 
            THEN yrs.cand_election_yr
                ELSE NULL::numeric
                END
            --
            WHEN link.fec_election_yr > link.cand_election_yr AND link.fec_election_yr > (yrs.next_election -
                CASE
                WHEN link.cmte_tp::text = 'P'::text THEN 4
                WHEN link.cmte_tp::text = 'S'::text THEN 6
                WHEN link.cmte_tp::text = 'H'::text THEN 2
                ELSE NULL::integer
                END::numeric) 
                THEN yrs.next_election
            --
            WHEN link.fec_election_yr > link.cand_election_yr AND link.fec_election_yr <= (yrs.next_election -
                CASE
                WHEN link.cmte_tp::text = 'P'::text THEN 4
                WHEN link.cmte_tp::text = 'S'::text THEN 6
                WHEN link.cmte_tp::text = 'H'::text THEN 2
                ELSE NULL::integer
                END::numeric) 
                THEN NULL::numeric
    -- -----
            WHEN link.fec_election_yr < link.cand_election_yr AND (yrs.cand_election_yr-link.fec_election_yr <
                CASE
                WHEN link.cmte_tp::text = 'P'::text THEN 4
                WHEN link.cmte_tp::text = 'S'::text THEN 6
                WHEN link.cmte_tp::text = 'H'::text THEN 2
                ELSE NULL::integer
                END::numeric) 
                THEN yrs.cand_election_yr
    -- -----
            ELSE NULL::numeric
        END::numeric(4,0) AS election_yr_to_be_included
        --, yrs.next_election
        --, yrs.cand_election_yr yrs_cand_yr
   FROM disclosure.cand_cmte_linkage link
     LEFT JOIN cand_election_yrs yrs ON link.cand_id::text = yrs.cand_id::text AND link.cand_election_yr = yrs.orig_cand_election_yr
  WHERE substr(link.cand_id::text, 1, 1) = link.cmte_tp::text OR (link.cmte_tp::text <> ALL (ARRAY['P'::character varying::text, 'S'::character varying::text, 'H'::character varying::text]))
  WITH DATA;
--Permissions
ALTER TABLE public.ofec_cand_cmte_linkage_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_cand_cmte_linkage_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_cand_cmte_linkage_mv_tmp TO fec_read;

--Indexes
CREATE INDEX idx_ofec_cand_cmte_linkage_mv_tmp_cand_elec_yr
  ON public.ofec_cand_cmte_linkage_mv_tmp
  USING btree
  (cand_election_yr);

CREATE INDEX idx_ofec_cand_cmte_linkage_mv_tmp_cand_id
  ON public.ofec_cand_cmte_linkage_mv_tmp
  USING btree
  (cand_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_cand_cmte_linkage_mv_tmp_cmte_id
  ON public.ofec_cand_cmte_linkage_mv_tmp
  USING btree
  (cmte_id COLLATE pg_catalog."default");

CREATE UNIQUE INDEX idx_ofec_cand_cmte_linkage_mv_tmp_idx
  ON public.ofec_cand_cmte_linkage_mv_tmp
  USING btree
  (idx);

-- drop old MV
DROP MATERIALIZED VIEW public.ofec_cand_cmte_linkage_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_cand_cmte_linkage_mv_tmp RENAME TO ofec_cand_cmte_linkage_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_cand_cmte_linkage_mv_tmp_cand_elec_yr RENAME TO idx_ofec_cand_cmte_linkage_mv_cand_elec_yr;

ALTER INDEX IF EXISTS idx_ofec_cand_cmte_linkage_mv_tmp_cand_id RENAME TO idx_ofec_cand_cmte_linkage_mv_cand_id;

ALTER INDEX IF EXISTS idx_ofec_cand_cmte_linkage_mv_tmp_cmte_id RENAME TO idx_ofec_cand_cmte_linkage_mv_cmte_id;

ALTER INDEX IF EXISTS idx_ofec_cand_cmte_linkage_mv_tmp_idx RENAME TO idx_ofec_cand_cmte_linkage_mv_idx;

-- recreate ofec_candidate_totals_vw -> select * from new MV
CREATE OR REPLACE VIEW public.ofec_cand_cmte_linkage_vw AS SELECT * FROM public.ofec_cand_cmte_linkage_mv;
ALTER VIEW ofec_cand_cmte_linkage_vw OWNER TO fec;
GRANT SELECT ON ofec_cand_cmte_linkage_vw TO fec_read;

REFRESH MATERIALIZED VIEW CONCURRENTLY ofec_candidate_totals_mv;
