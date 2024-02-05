DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_detail_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_candidate_detail_mv_tmp AS 
 WITH cand_inactive AS (
         SELECT cand_inactive.cand_id,
            array_agg(cand_inactive.election_yr)::integer[] AS inactive_election_years
           FROM disclosure.cand_inactive
          GROUP BY cand_inactive.cand_id
        )
 SELECT DISTINCT ON (cand_hist.candidate_id) cand_hist.idx,
    cand_hist.load_date,
    cand_hist.two_year_period,
    first_value(cand_hist.candidate_election_year) OVER (PARTITION BY cand_hist.candidate_id ORDER BY cand_hist.candidate_election_year DESC NULLS LAST)::numeric(4,0) AS candidate_election_year,
    cand_hist.candidate_id,
    cand_hist.name,
    cand_hist.address_state,
    cand_hist.address_city,
    cand_hist.address_street_1,
    cand_hist.address_street_2,
    cand_hist.address_zip,
    cand_hist.incumbent_challenge,
    cand_hist.incumbent_challenge_full,
    cand_hist.candidate_status,
    cand_hist.candidate_inactive,
    cand_hist.office,
    cand_hist.office_full,
    cand_hist.state,
    cand_hist.district,
    cand_hist.district_number,
    cand_hist.party,
    cand_hist.party_full,
    cand_hist.cycles,
    cand_hist.first_file_date,
    cand_hist.last_file_date,
    cand_hist.last_f2_date,
    cand_hist.election_years,
    cand_hist.election_districts,
    cand_hist.active_through,
    inactive.inactive_election_years
   FROM ofec_candidate_history_vw cand_hist
     LEFT JOIN cand_inactive inactive ON cand_hist.candidate_id::text = inactive.cand_id::text
  ORDER BY cand_hist.candidate_id, cand_hist.two_year_period DESC
WITH DATA;

ALTER TABLE public.ofec_candidate_detail_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_candidate_detail_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_candidate_detail_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_candidate_detail_mv_tmp_idx
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (idx);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_cand_id
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (candidate_id);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_cand_status
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (candidate_status);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_cycles_cand_id
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (cycles, candidate_id);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_cycles
  ON public.ofec_candidate_detail_mv_tmp
  USING gin
  (cycles);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_dstrct
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (district);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_election_yrs
  ON public.ofec_candidate_detail_mv_tmp
  USING gin
  (election_years);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_1st_file_dt
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (first_file_date);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_incumbent_challenge
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (incumbent_challenge);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_load_dt
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (load_date);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_name
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (name);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_office_full
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (office_full);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_office
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (office);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_party_full
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (party_full);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_party
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (party);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_state
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (state);

-- ---------------
CREATE OR REPLACE VIEW public.ofec_candidate_detail_vw AS 
SELECT * FROM public.ofec_candidate_detail_mv_tmp;
-- ---------------
-- drop old MV
DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_detail_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_candidate_detail_mv_tmp RENAME TO ofec_candidate_detail_mv;

-- rename indexes
ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_idx RENAME TO idx_ofec_candidate_detail_mv_idx;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_cand_id RENAME TO idx_ofec_candidate_detail_mv_cand_id;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_cand_status RENAME TO idx_ofec_candidate_detail_mv_cand_status;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_cycles_cand_id RENAME TO idx_ofec_candidate_detail_mv_cycles_cand_id;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_cycles RENAME TO idx_ofec_candidate_detail_mv_cycles;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_dstrct RENAME TO idx_ofec_candidate_detail_mv_dstrct;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_election_yrs RENAME TO idx_ofec_candidate_detail_mv_election_yrs;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_1st_file_dt RENAME TO idx_ofec_candidate_detail_mv_1st_file_dt;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_incumbent_challenge RENAME TO idx_ofec_candidate_detail_mv_incumbent_challenge;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_load_dt RENAME TO idx_ofec_candidate_detail_mv_load_dt;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_name RENAME TO idx_ofec_candidate_detail_mv_name;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_office_full RENAME TO idx_ofec_candidate_detail_mv_office_full;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_office RENAME TO idx_ofec_candidate_detail_mv_office;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_party_full RENAME TO idx_ofec_candidate_detail_mv_party_full;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_party RENAME TO idx_ofec_candidate_detail_mv_party;

ALTER INDEX public.idx_ofec_candidate_detail_mv_tmp_state RENAME TO idx_ofec_candidate_detail_mv_state;
