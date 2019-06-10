/*
This is part of migration files solving issues 
	#3768 Candidate missing from /candidates/totals
	#3709 Candidate totals incorrect for one candidate ("Puerto Rico's resident commissioner has a 4-year election cycle. Even though the commissioner serves in the house.")

ofec_candidate_totals_mv has two major components, one from financial side, one from the candidate site.
There are two major types of candidates that caused the mismatch of these two worlds. 
- candidates has committees but did not file financial reports
- candidates has no committees at all

We had noticed the candidate_election_year logic has problem.
In previous ticket #3700, we had fixed the financial side.  
In another ticket #3736, the candidate side had been fixed.
This ticket we combined the two sides together with some minor updates
we noticed from previous tickets.
*/

-- ----------------------
-- public.ofec_candidate_detail_mv
-- ofec_candidate_detail_mv represent the latest candidate data of a candidate
-- update candidate information with the latest candidate_election_year that particular candidate has
-- ----------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_detail_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_candidate_detail_mv_tmp AS 
 SELECT DISTINCT ON (cand_hist.candidate_id) cand_hist.idx,
    cand_hist.load_date,
    cand_hist.two_year_period,
    first_value (cand_hist.candidate_election_year) over (partition by candidate_id order by cand_hist.candidate_election_year DESC NULLS LAST)::numeric(4, 0) as candidate_election_year,
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
    cand_hist.active_through
   FROM ofec_candidate_history_vw cand_hist
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
  (candidate_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_cand_status
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (candidate_status COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_cycles_cand_id
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (cycles, candidate_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_cycles
  ON public.ofec_candidate_detail_mv_tmp
  USING gin
  (cycles);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_dstrct
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (district COLLATE pg_catalog."default");

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
  (incumbent_challenge COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_load_dt
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (load_date);

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_name
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (name COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_office_full
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (office_full COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_office
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (office COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_party_full
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (party_full COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_party
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (party COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_detail_mv_tmp_state
  ON public.ofec_candidate_detail_mv_tmp
  USING btree
  (state COLLATE pg_catalog."default");

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