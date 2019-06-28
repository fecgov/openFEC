/*
This migration file is to solve part of https://github.com/fecgov/openFEC/issues/3709

`ofec_totals_candidate_committees_mv` depends on `ofec_candidate_election_vw`

1) Update `ofec_candidate_election_mv` and, by extension, `ofec_candidate_election_vw`,
 to use new `candidate_election_duration` function
2) Drop function `election_duration` because it's no longer being used


*/

--1) Update `ofec_candidate_election_mv` and `ofec_candidate_election_vw`

DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_election_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_candidate_election_mv_tmp AS
 WITH years AS (
         SELECT cand_detail.candidate_id,
            unnest(cand_detail.election_years) AS cand_election_year
           FROM ofec_candidate_detail_vw cand_detail
        )
 SELECT DISTINCT ON (years.candidate_id, years.cand_election_year) years.candidate_id,
    years.cand_election_year,
    GREATEST(prev.cand_election_year, years.cand_election_year - candidate_election_duration(years.candidate_id)) AS prev_election_year
   FROM years
     LEFT JOIN years prev ON years.candidate_id::text = prev.candidate_id::text AND prev.cand_election_year < years.cand_election_year
  ORDER BY years.candidate_id, years.cand_election_year, prev.cand_election_year DESC
WITH DATA;

--Permissions

ALTER TABLE public.ofec_candidate_election_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_candidate_election_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_candidate_election_mv_tmp TO fec_read;

--Indices

CREATE UNIQUE INDEX idx_ofec_candidate_election_mv_tmp_cand_id_cand_election_yr
  ON public.ofec_candidate_election_mv_tmp
  USING btree
  (candidate_id COLLATE pg_catalog."default", cand_election_year);

CREATE INDEX idx_ofec_candidate_election_mv_tmp_cand_election_yr
  ON public.ofec_candidate_election_mv_tmp
  USING btree
  (cand_election_year);

CREATE INDEX idx_ofec_candidate_election_mv_tmp_cand_id
  ON public.ofec_candidate_election_mv_tmp
  USING btree
  (candidate_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_election_mv_tmp_prev_election_yr
  ON public.ofec_candidate_election_mv_tmp
  USING btree
  (prev_election_year);

-- ---------------
CREATE OR REPLACE VIEW public.ofec_candidate_election_vw AS
SELECT * FROM public.ofec_candidate_election_mv_tmp;
-- ---------------

DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_election_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_candidate_election_mv_tmp RENAME TO ofec_candidate_election_mv;

-- ---------------

ALTER INDEX public.idx_ofec_candidate_election_mv_tmp_cand_id_cand_election_yr RENAME TO idx_ofec_candidate_election_mv_cand_id_cand_election_yr;

ALTER INDEX public.idx_ofec_candidate_election_mv_tmp_cand_election_yr RENAME TO idx_ofec_candidate_election_mv_cand_election_yr;

ALTER INDEX public.idx_ofec_candidate_election_mv_tmp_cand_id RENAME TO idx_ofec_candidate_election_mv_cand_id;

ALTER INDEX public.idx_ofec_candidate_election_mv_tmp_prev_election_yr RENAME TO idx_ofec_candidate_election_mv_prev_election_yr;

-- 2) Drop function `election_duration` because it's no longer being used

DROP FUNCTION IF EXISTS public.election_duration();
