/*
This migration file is to solve 
issue #3564 Exclude inactive candidates from election pages

The main driver for the endpoint issue (ElectionView) is 
ofec_candidate_history_mv, which already has the candidate_inactive column. 
The dynamic query built in ElectionView already has the condition 
candidate_inactive = false built in. 
However, the sql statement that create ofec_candidate_history_mv 
need to be updated to produce correct data to exclude inactive candidate. 

The candidate_inactive flag for two_year_period other than the cand_election_year 
also need to be set as 'f'

Since the model file is directly point to the mv itself, 
the _tmp approach is used to minimize the the downtime.  

There are still some MV dependency that were not handled before.
ofec_candidate_history_mv -> ofec_candidate_history_with_future_election_mv
ofec_candidate_history_mv -> ofec_candidate_detail_mv
  ofec_candidate_detail_mv -> ofec_candidate_election_mv

There are no actual change on the following MVs except referring to the front-end VW instead of base MVs:
ofec_candidate_history_with_future_election_mv
ofec_candidate_detail_mv
ofec_candidate_election_mv
*/
-- ---------------
-- ofec_candidate_election_mv
-- ---------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_election_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_candidate_election_mv_tmp AS 
 WITH years AS (
         SELECT cand_detail.candidate_id,
            unnest(cand_detail.election_years) AS cand_election_year
           FROM ofec_candidate_detail_vw cand_detail
        )
 SELECT DISTINCT ON (years.candidate_id, years.cand_election_year) years.candidate_id,
    years.cand_election_year,
    GREATEST(prev.cand_election_year, years.cand_election_year - election_duration(substr(years.candidate_id::text, 1, 1))) AS prev_election_year
   FROM years
     LEFT JOIN years prev ON years.candidate_id::text = prev.candidate_id::text AND prev.cand_election_year < years.cand_election_year
  ORDER BY years.candidate_id, years.cand_election_year, prev.cand_election_year DESC
WITH DATA;

ALTER TABLE public.ofec_candidate_election_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_candidate_election_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_candidate_election_mv_tmp TO fec_read;


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


-- ---------------
-- ofec_candidate_detail_mv
-- ---------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_detail_mv_tmp;
CREATE MATERIALIZED VIEW public.ofec_candidate_detail_mv_tmp AS 
 SELECT DISTINCT ON (cand_hist.candidate_id) cand_hist.idx,
    cand_hist.load_date,
    cand_hist.two_year_period,
    cand_hist.candidate_election_year,
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
DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_detail_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_candidate_detail_mv_tmp RENAME TO ofec_candidate_detail_mv;
-- ---------------
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
-- ---------------
-- ofec_candidate_history_with_future_election_mv
-- ---------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_history_with_future_election_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_candidate_history_with_future_election_mv_tmp AS 
 WITH combined AS (
         SELECT cand_hist.load_date,
            cand_hist.two_year_period,
            cand_hist.candidate_election_year + cand_hist.candidate_election_year % 2::numeric AS candidate_election_year,
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
        UNION
         SELECT DISTINCT ON (cand_hist.candidate_id) cand_hist.load_date,
            cand_hist.candidate_election_year + cand_hist.candidate_election_year % 2::numeric AS two_year_period,
            cand_hist.candidate_election_year + cand_hist.candidate_election_year % 2::numeric AS candidate_election_year,
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
          WHERE (cand_hist.candidate_election_year::double precision - date_part('year'::text, 'now'::text::date)) >= 2::double precision
        )
 SELECT row_number() OVER () AS idx,
    combined.load_date,
    combined.two_year_period,
    combined.candidate_election_year + combined.candidate_election_year % 2::numeric AS candidate_election_year,
    combined.candidate_id,
    combined.name,
    combined.address_state,
    combined.address_city,
    combined.address_street_1,
    combined.address_street_2,
    combined.address_zip,
    combined.incumbent_challenge,
    combined.incumbent_challenge_full,
    combined.candidate_status,
    combined.candidate_inactive,
    combined.office,
    combined.office_full,
    combined.state,
    combined.district,
    combined.district_number,
    combined.party,
    combined.party_full,
    combined.cycles,
    combined.first_file_date,
    combined.last_file_date,
    combined.last_f2_date,
    combined.election_years,
    combined.election_districts,
    combined.active_through
   FROM combined
WITH DATA;

ALTER TABLE public.ofec_candidate_history_with_future_election_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_candidate_history_with_future_election_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_candidate_history_with_future_election_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_candidate_history_with_future_election_mv_tmp_idx
  ON public.ofec_candidate_history_with_future_election_mv_tmp
  USING btree
  (idx);

CREATE INDEX idx_ofec_candidate_history_with_future_election_mv_tmp_cand_id
  ON public.ofec_candidate_history_with_future_election_mv_tmp
  USING btree
  (candidate_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_with_future_election_mv_tmp_distr
  ON public.ofec_candidate_history_with_future_election_mv_tmp
  USING btree
  (district COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_with_future_election_mv_tmp_distr_nb
  ON public.ofec_candidate_history_with_future_election_mv_tmp
  USING btree
  (district_number);

CREATE INDEX idx_ofec_candidate_history_with_future_election_mv_tmp_1st_file
  ON public.ofec_candidate_history_with_future_election_mv_tmp
  USING btree
  (first_file_date);

CREATE INDEX idx_ofec_candidate_history_with_future_election_mv_tmp_load_dt
  ON public.ofec_candidate_history_with_future_election_mv_tmp
  USING btree
  (load_date);

CREATE INDEX idx_ofec_candidate_history_with_future_election_mv_tmp_office
  ON public.ofec_candidate_history_with_future_election_mv_tmp
  USING btree
  (office COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_with_future_election_mv_tmp_state
  ON public.ofec_candidate_history_with_future_election_mv_tmp
  USING btree
  (state COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_with_future_election_mv_tmp_cycle
  ON public.ofec_candidate_history_with_future_election_mv_tmp
  USING btree
  (two_year_period, candidate_id COLLATE pg_catalog."default");

-- ---------------
CREATE OR REPLACE VIEW public.ofec_candidate_history_with_future_election_vw AS 
SELECT * FROM public.ofec_candidate_history_with_future_election_mv_tmp;
-- ---------------

DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_history_with_future_election_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_candidate_history_with_future_election_mv_tmp RENAME TO ofec_candidate_history_with_future_election_mv;

-- ---------------
ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_with_future_election_mv_tmp_idx RENAME TO idx_ofec_candidate_history_with_future_election_mv_idx;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_with_future_election_mv_tmp_cand_id RENAME TO idx_ofec_candidate_history_with_future_election_mv_cand_id;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_with_future_election_mv_tmp_dstrct RENAME TO idx_ofec_candidate_history_with_future_election_mv_dstrct;
 
ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_with_future_election_mv_tmp_dstrct_n RENAME TO idx_ofec_candidate_history_with_future_election_mv_dstrct_nbr;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_with_future_election_mv_tmp_1st_file RENAME TO idx_ofec_candidate_history_with_future_election_mv_1st_file_dt;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_with_future_election_mv_tmp_load_dt RENAME TO idx_ofec_candidate_history_with_future_election_mv_load_dt;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_with_future_election_mv_tmp_office RENAME TO idx_ofec_candidate_history_with_future_election_mv_office;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_with_future_election_mv_tmp_state RENAME TO idx_ofec_candidate_history_with_future_election_mv_state;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_with_future_election_mv_tmp_cycle RENAME TO idx_ofec_candidate_history_with_future_election_mv_cycle;

-- ***************
-- real code involves ofec_candidate_history_mv starts here
-- ***************
DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_history_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_candidate_history_mv_tmp AS 
 WITH fec_yr AS (
         SELECT DISTINCT ON (cand.cand_valid_yr_id) cand.cand_valid_yr_id,
            cand.cand_id,
            cand.fec_election_yr,
            cand.cand_election_yr,
            cand.cand_status,
            cand.cand_ici,
            cand.cand_office,
            cand.cand_office_st,
            cand.cand_office_district,
            cand.cand_pty_affiliation,
            cand.cand_name,
            cand.cand_st1,
            cand.cand_st2,
            cand.cand_city,
            cand.cand_state,
            cand.cand_zip,
            cand.race_pk,
            cand.lst_updt_dt,
            cand.latest_receipt_dt,
            cand.user_id_entered,
            cand.date_entered,
            cand.user_id_changed,
            cand.date_changed,
            cand.ref_cand_pk,
            cand.ref_lst_updt_dt,
            cand.pg_date
           FROM disclosure.cand_valid_fec_yr cand
             LEFT JOIN disclosure.cand_cmte_linkage link ON cand.cand_id::text = link.cand_id::text AND cand.fec_election_yr = link.fec_election_yr AND (link.linkage_type::text = ANY (ARRAY['P'::character varying, 'A'::character varying]::text[]))
        ), elections AS (
         SELECT dedup.cand_id,
            max(dedup.cand_election_yr) AS active_through,
            array_agg(dedup.cand_election_yr)::integer[] AS election_years,
            array_agg(dedup.cand_office_district)::text[] AS election_districts
           FROM ( SELECT DISTINCT ON (fec_yr_1.cand_id, fec_yr_1.cand_election_yr) fec_yr_1.cand_valid_yr_id,
                    fec_yr_1.cand_id,
                    fec_yr_1.fec_election_yr,
                    fec_yr_1.cand_election_yr,
                    fec_yr_1.cand_status,
                    fec_yr_1.cand_ici,
                    fec_yr_1.cand_office,
                    fec_yr_1.cand_office_st,
                    fec_yr_1.cand_office_district,
                    fec_yr_1.cand_pty_affiliation,
                    fec_yr_1.cand_name,
                    fec_yr_1.cand_st1,
                    fec_yr_1.cand_st2,
                    fec_yr_1.cand_city,
                    fec_yr_1.cand_state,
                    fec_yr_1.cand_zip,
                    fec_yr_1.race_pk,
                    fec_yr_1.lst_updt_dt,
                    fec_yr_1.latest_receipt_dt,
                    fec_yr_1.user_id_entered,
                    fec_yr_1.date_entered,
                    fec_yr_1.user_id_changed,
                    fec_yr_1.date_changed,
                    fec_yr_1.ref_cand_pk,
                    fec_yr_1.ref_lst_updt_dt,
                    fec_yr_1.pg_date
                   FROM fec_yr fec_yr_1
                  ORDER BY fec_yr_1.cand_id, fec_yr_1.cand_election_yr) dedup
          GROUP BY dedup.cand_id
        ), cycles AS (
         SELECT fec_yr_1.cand_id,
            array_agg(fec_yr_1.fec_election_yr)::integer[] AS cycles,
            max(fec_yr_1.fec_election_yr) AS max_cycle
           FROM fec_yr fec_yr_1
          GROUP BY fec_yr_1.cand_id
        ), dates AS (
         SELECT f_rpt_or_form_sub.cand_cmte_id AS cand_id,
            min(f_rpt_or_form_sub.receipt_dt) AS first_file_date,
            max(f_rpt_or_form_sub.receipt_dt) AS last_file_date,
            max(f_rpt_or_form_sub.receipt_dt) FILTER (WHERE f_rpt_or_form_sub.form_tp::text = 'F2'::text) AS last_f2_date
           FROM disclosure.f_rpt_or_form_sub
          GROUP BY f_rpt_or_form_sub.cand_cmte_id
        )
 SELECT DISTINCT ON (fec_yr.cand_id, fec_yr.fec_election_yr) row_number() OVER () AS idx,
    fec_yr.lst_updt_dt AS load_date,
    fec_yr.fec_election_yr AS two_year_period,
    fec_yr.cand_election_yr AS candidate_election_year,
    fec_yr.cand_id AS candidate_id,
    fec_yr.cand_name AS name,
    fec_yr.cand_state AS address_state,
    fec_yr.cand_city AS address_city,
    fec_yr.cand_st1 AS address_street_1,
    fec_yr.cand_st2 AS address_street_2,
    fec_yr.cand_zip AS address_zip,
    fec_yr.cand_ici AS incumbent_challenge,
    expand_candidate_incumbent(fec_yr.cand_ici::text) AS incumbent_challenge_full,
    fec_yr.cand_status AS candidate_status,
    inactive.cand_id IS NOT NULL AS candidate_inactive,
    fec_yr.cand_office AS office,
    expand_office(fec_yr.cand_office::text) AS office_full,
    fec_yr.cand_office_st AS state,
    fec_yr.cand_office_district AS district,
    fec_yr.cand_office_district::integer AS district_number,
    fec_yr.cand_pty_affiliation AS party,
    clean_party(ref_party.pty_desc::text) AS party_full,
    cycles.cycles,
    dates.first_file_date::text::date AS first_file_date,
    dates.last_file_date::text::date AS last_file_date,
    dates.last_f2_date::text::date AS last_f2_date,
    elections.election_years,
    elections.election_districts,
    elections.active_through
   FROM fec_yr
     LEFT JOIN cycles USING (cand_id)
     LEFT JOIN elections USING (cand_id)
     LEFT JOIN dates USING (cand_id)
     LEFT JOIN disclosure.cand_inactive inactive ON fec_yr.cand_id::text = inactive.cand_id::text AND fec_yr.cand_election_yr = inactive.election_yr
     LEFT JOIN staging.ref_pty ref_party ON fec_yr.cand_pty_affiliation::text = ref_party.pty_cd::text
  WHERE cycles.max_cycle >= 1979::numeric AND NOT (fec_yr.cand_id::text IN ( SELECT DISTINCT unverified_filers_vw.cmte_id
           FROM unverified_filers_vw
          WHERE unverified_filers_vw.cmte_id::text ~ similar_escape('(P|S|H)%'::text, NULL::text)))
WITH DATA;

ALTER TABLE public.ofec_candidate_history_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_candidate_history_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_candidate_history_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_candidate_history_mv_tmp_idx
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (idx);

CREATE INDEX idx_ofec_candidate_history_mv_tmp_cand_id
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (candidate_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_mv_tmp_dstrct
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (district COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_mv_tmp_dstrct_nbr
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (district_number);

CREATE INDEX idx_ofec_candidate_history_mv_tmp_1st_file_dt
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (first_file_date);

CREATE INDEX idx_ofec_candidate_history_mv_tmp_load_dt
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (load_date);

CREATE INDEX idx_ofec_candidate_history_mv_tmp_office
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (office COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_mv_tmp_state
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (state COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_mv_tmp_cycle_cand_id
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (two_year_period, candidate_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_mv_tmp_cycle
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (two_year_period);

-- ---------------
CREATE OR REPLACE VIEW public.ofec_candidate_history_vw AS 
SELECT * FROM public.ofec_candidate_history_mv_tmp;
-- ---------------

DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_history_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_candidate_history_mv_tmp RENAME TO ofec_candidate_history_mv;

-- ---------------
ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_mv_tmp_cand_id RENAME TO idx_ofec_candidate_history_mv_cand_id;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_mv_tmp_dstrct RENAME TO idx_ofec_candidate_history_mv_dstrct;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_mv_tmp_dstrct_nbr RENAME TO idx_ofec_candidate_history_mv_dstrct_nbr;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_mv_tmp_1st_file_dt RENAME TO idx_ofec_candidate_history_mv_1st_file_dt;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_mv_tmp_load_dt RENAME TO idx_ofec_candidate_history_mv_load_dt;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_mv_tmp_office RENAME TO idx_ofec_candidate_history_mv_office;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_mv_tmp_state RENAME TO idx_ofec_candidate_history_mv_state;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_mv_tmp_cycle_cand_id RENAME TO idx_ofec_candidate_history_mv_cycle_cand_id;

ALTER INDEX IF EXISTS public.idx_ofec_candidate_history_mv_tmp_cycle RENAME TO idx_ofec_candidate_history_mv_cycle;
