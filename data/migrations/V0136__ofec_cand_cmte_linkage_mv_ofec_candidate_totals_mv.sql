/*
This is to solve issue #3768 Candidate missing from /candidates/totals
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
-- ofec_cand_cmte_linkage_mv
-- tighten up logic for ofec_cand_cmte_linkage_mv (updated rule #4)
-- also update to use substr(link.cand_id, 1, 1) to calculate election_duration since some P/A committees have cmte_tp other than H/P/S
-- ----------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_cand_cmte_linkage_mv_tmp;
CREATE MATERIALIZED VIEW ofec_cand_cmte_linkage_mv_tmp AS
WITH 
election_yr AS (
    SELECT cand_cmte_linkage.cand_id,
    cand_cmte_linkage.cand_election_yr AS orig_cand_election_yr,
    cand_cmte_linkage.cand_election_yr + cand_cmte_linkage.cand_election_yr % 2::numeric AS cand_election_yr
    FROM disclosure.cand_cmte_linkage
    WHERE substr(cand_cmte_linkage.cand_id::text, 1, 1) = cand_cmte_linkage.cmte_tp::text OR (cand_cmte_linkage.cmte_tp::text <> ALL (ARRAY['P'::character varying::text, 'S'::character varying::text, 'H'::character varying::text]))
    GROUP BY cand_cmte_linkage.cand_id, cand_election_yr, (cand_cmte_linkage.cand_election_yr + cand_cmte_linkage.cand_election_yr % 2::numeric)
), cand_election_yrs AS (
    SELECT election_yr.cand_id,
    election_yr.orig_cand_election_yr,
    election_yr.cand_election_yr,
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
            -- #1
            WHEN link.cand_election_yr = link.fec_election_yr THEN link.cand_election_yr
	    -- #2
    	    -- handle odd year House here since it is simple.  P and S need more consideration and are handled in the following rules.
            WHEN link.cand_election_yr%2 = 1 and substr(link.cand_id::text, 1, 1) = 'H' THEN
            CASE 
            WHEN link.fec_election_yr <= link.cand_election_yr+link.cand_election_yr%2 then link.cand_election_yr+link.cand_election_yr%2
            ELSE NULL
            END
            -- #3
	    -- when this is the last election this candidate has, and the fec_election_yr falls in this candidate election cycle. 
            WHEN yrs.next_election IS NULL THEN
            CASE
            WHEN link.fec_election_yr <= yrs.cand_election_yr AND (yrs.cand_election_yr-link.fec_election_yr <
                CASE WHEN substr(link.cand_id, 1, 1) in ('H', 'S', 'P')
                THEN election_duration (substr(link.cand_id, 1, 1))
                ELSE null
                END
            ) 
            THEN yrs.cand_election_yr
                ELSE NULL::numeric
                END
	    -- #4
	    -- when fec_election_yr is between previous cand_election and next_election, and fec_election_cycle is within the duration of the next_election cycle
	    -- note: different from the calculation in candidate_history the next_election here is a rounded number so it need to include <
	    WHEN link.fec_election_yr > link.cand_election_yr AND link.fec_election_yr > (yrs.next_election -
                CASE WHEN substr(link.cand_id, 1, 1) in ('H', 'S', 'P')
                THEN election_duration (substr(link.cand_id, 1, 1))
                ELSE null
                END
            ) 
            AND ((link.cand_election_yr%2=1 AND link.fec_election_yr <= yrs.next_election) OR (link.cand_election_yr%2=0 AND link.fec_election_yr < yrs.next_election))
            THEN yrs.next_election
        -- #5
	    -- when fec_election_yr is after previous cand_election, but NOT within the duration of the next_election cycle (previous cand_election and the next_election has gaps)
            WHEN link.fec_election_yr > link.cand_election_yr AND link.fec_election_yr <= (yrs.next_election -
                CASE WHEN substr(link.cand_id, 1, 1) in ('H', 'S', 'P')
                THEN election_duration (substr(link.cand_id, 1, 1))
                ELSE null
                END
            ) 
                THEN NULL::numeric
        -- #6                
	    -- fec_election_yr are within THIS election_cycle
            WHEN link.fec_election_yr < link.cand_election_yr AND (yrs.cand_election_yr-link.fec_election_yr <
                CASE WHEN substr(link.cand_id, 1, 1) in ('H', 'S', 'P')
                THEN election_duration (substr(link.cand_id, 1, 1))
                ELSE null
                END
            ) 
                THEN yrs.cand_election_yr
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

-- ---------------
CREATE OR REPLACE VIEW public.ofec_cand_cmte_linkage_vw AS 
SELECT * FROM public.ofec_cand_cmte_linkage_mv_tmp;
-- ---------------

-- drop old MV
DROP MATERIALIZED VIEW public.ofec_cand_cmte_linkage_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_cand_cmte_linkage_mv_tmp RENAME TO ofec_cand_cmte_linkage_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_cand_cmte_linkage_mv_tmp_cand_elec_yr RENAME TO idx_ofec_cand_cmte_linkage_mv_cand_elec_yr;

ALTER INDEX IF EXISTS idx_ofec_cand_cmte_linkage_mv_tmp_cand_id RENAME TO idx_ofec_cand_cmte_linkage_mv_cand_id;

ALTER INDEX IF EXISTS idx_ofec_cand_cmte_linkage_mv_tmp_cmte_id RENAME TO idx_ofec_cand_cmte_linkage_mv_cmte_id;

ALTER INDEX IF EXISTS idx_ofec_cand_cmte_linkage_mv_tmp_idx RENAME TO idx_ofec_cand_cmte_linkage_mv_idx;



-- ----------------------
-- ofec_candidate_totals_mv_tmp
--
--
-- ----------------------

DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_totals_mv_tmp;
CREATE MATERIALIZED VIEW ofec_candidate_totals_mv_tmp AS
WITH totals AS (
         SELECT ofec_totals_house_senate_vw.committee_id,
            ofec_totals_house_senate_vw.cycle,
            ofec_totals_house_senate_vw.receipts,
            ofec_totals_house_senate_vw.disbursements,
            ofec_totals_house_senate_vw.last_cash_on_hand_end_period,
            ofec_totals_house_senate_vw.last_debts_owed_by_committee,
            ofec_totals_house_senate_vw.coverage_start_date,
            ofec_totals_house_senate_vw.coverage_end_date,
            false AS federal_funds_flag
           FROM ofec_totals_house_senate_vw
        UNION ALL
         SELECT ofec_totals_presidential_vw.committee_id,
            ofec_totals_presidential_vw.cycle,
            ofec_totals_presidential_vw.receipts,
            ofec_totals_presidential_vw.disbursements,
            ofec_totals_presidential_vw.last_cash_on_hand_end_period,
            ofec_totals_presidential_vw.last_debts_owed_by_committee,
            ofec_totals_presidential_vw.coverage_start_date,
            ofec_totals_presidential_vw.coverage_end_date,
            ofec_totals_presidential_vw.federal_funds_flag
           FROM ofec_totals_presidential_vw
        ), link AS (
         SELECT ofec_cand_cmte_linkage_vw.cand_id,
            ofec_cand_cmte_linkage_vw.election_yr_to_be_included + ofec_cand_cmte_linkage_vw.election_yr_to_be_included % 2::numeric AS election_yr_to_be_included,
            ofec_cand_cmte_linkage_vw.fec_election_yr,
            ofec_cand_cmte_linkage_vw.cmte_id
           FROM ofec_cand_cmte_linkage_vw
          WHERE ofec_cand_cmte_linkage_vw.cmte_dsgn::text = ANY (ARRAY['P'::character varying::text, 'A'::character varying::text])
          GROUP BY ofec_cand_cmte_linkage_vw.cand_id, ofec_cand_cmte_linkage_vw.election_yr_to_be_included, ofec_cand_cmte_linkage_vw.fec_election_yr, ofec_cand_cmte_linkage_vw.cmte_id
        ), cycle_cmte_totals_basic AS (
         SELECT link.cand_id,
            link.cmte_id,
            link.election_yr_to_be_included,
            totals_1.cycle,
            false AS is_election,
            totals_1.receipts,
            totals_1.disbursements,
            first_value(totals_1.last_cash_on_hand_end_period) OVER (PARTITION BY link.cand_id, link.election_yr_to_be_included, totals_1.cycle, link.cmte_id ORDER BY totals_1.coverage_end_date DESC NULLS LAST) AS last_cash_on_hand_end_period,
            first_value(totals_1.last_debts_owed_by_committee) OVER (PARTITION BY link.cand_id, link.election_yr_to_be_included, totals_1.cycle, link.cmte_id ORDER BY totals_1.coverage_end_date DESC NULLS LAST) AS last_debts_owed_by_committee,
            totals_1.coverage_start_date,
            totals_1.coverage_end_date,
            totals_1.federal_funds_flag
           FROM link
           -- --
             JOIN totals totals_1 ON link.cmte_id::text = totals_1.committee_id::text AND link.fec_election_yr = totals_1.cycle::numeric
        ), cycle_cmte_totals AS (
         SELECT cycle_cmte_totals_basic.cand_id AS candidate_id,
            cycle_cmte_totals_basic.cmte_id,
            cycle_cmte_totals_basic.election_yr_to_be_included AS election_year,
            cycle_cmte_totals_basic.cycle,
            sum(cycle_cmte_totals_basic.receipts) AS receipts,
            sum(cycle_cmte_totals_basic.disbursements) AS disbursements,
            max(cycle_cmte_totals_basic.last_cash_on_hand_end_period) AS cash_on_hand_end_period_per_cmte,
            max(cycle_cmte_totals_basic.last_debts_owed_by_committee) AS debts_owed_by_committee_per_cmte,
            min(cycle_cmte_totals_basic.coverage_start_date) AS coverage_start_date,
            max(cycle_cmte_totals_basic.coverage_end_date) AS coverage_end_date,
            array_agg(cycle_cmte_totals_basic.federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
           FROM cycle_cmte_totals_basic
          GROUP BY cycle_cmte_totals_basic.cand_id, cycle_cmte_totals_basic.election_yr_to_be_included, cycle_cmte_totals_basic.cycle, cycle_cmte_totals_basic.cmte_id
        ), cycle_totals AS (
         SELECT cycle_cmte_totals.candidate_id,
            cycle_cmte_totals.election_year,
            cycle_cmte_totals.cycle,
            false AS is_election,
            sum(cycle_cmte_totals.receipts) AS receipts,
            sum(cycle_cmte_totals.disbursements) AS disbursements,
            sum(cycle_cmte_totals.receipts) > 0::numeric AS has_raised_funds,
            sum(cycle_cmte_totals.cash_on_hand_end_period_per_cmte) AS cash_on_hand_end_period,
            sum(cycle_cmte_totals.debts_owed_by_committee_per_cmte) AS debts_owed_by_committee,
            min(cycle_cmte_totals.coverage_start_date) AS coverage_start_date,
            max(cycle_cmte_totals.coverage_end_date) AS coverage_end_date,
            array_agg(cycle_cmte_totals.federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
           FROM cycle_cmte_totals
          GROUP BY cycle_cmte_totals.candidate_id, cycle_cmte_totals.election_year, cycle_cmte_totals.cycle
        ), election_cmte_totals_basic AS (
         SELECT cycle_cmte_totals.candidate_id,
            cycle_cmte_totals.cmte_id,
            cycle_cmte_totals.cycle,
            cycle_cmte_totals.election_year,
            cycle_cmte_totals.receipts,
            cycle_cmte_totals.disbursements,
            first_value(cycle_cmte_totals.cash_on_hand_end_period_per_cmte) OVER (PARTITION BY cycle_cmte_totals.candidate_id, cycle_cmte_totals.election_year, cycle_cmte_totals.cmte_id ORDER BY cycle_cmte_totals.cycle DESC NULLS LAST) AS last_cash_on_hand_end_period,
            first_value(cycle_cmte_totals.debts_owed_by_committee_per_cmte) OVER (PARTITION BY cycle_cmte_totals.candidate_id, cycle_cmte_totals.election_year, cycle_cmte_totals.cmte_id ORDER BY cycle_cmte_totals.cycle DESC NULLS LAST) AS last_debts_owed_by_committee,
            cycle_cmte_totals.coverage_start_date,
            cycle_cmte_totals.coverage_end_date,
            cycle_cmte_totals.federal_funds_flag
           FROM cycle_cmte_totals
        ), election_cmte_totals AS (
         SELECT election_cmte_totals_basic.candidate_id,
            election_cmte_totals_basic.cmte_id,
            election_cmte_totals_basic.election_year,
            sum(election_cmte_totals_basic.receipts) AS receipts,
            sum(election_cmte_totals_basic.disbursements) AS disbursements,
            max(election_cmte_totals_basic.last_cash_on_hand_end_period) AS last_cash_on_hand_end_period,
            max(election_cmte_totals_basic.last_debts_owed_by_committee) AS last_debts_owed_by_committee,
            min(election_cmte_totals_basic.coverage_start_date) AS coverage_start_date,
            max(election_cmte_totals_basic.coverage_end_date) AS coverage_end_date,
            array_agg(election_cmte_totals_basic.federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
           FROM election_cmte_totals_basic
          GROUP BY election_cmte_totals_basic.candidate_id, election_cmte_totals_basic.election_year, election_cmte_totals_basic.cmte_id
        ), combined_totals AS (
         SELECT election_cmte_totals.candidate_id,
            election_cmte_totals.election_year,
            election_cmte_totals.election_year AS cycle,
            true AS is_election,
            sum(election_cmte_totals.receipts) AS receipts,
            sum(election_cmte_totals.disbursements) AS disbursements,
            sum(election_cmte_totals.receipts) > 0::numeric AS has_raised_funds,
            sum(election_cmte_totals.last_cash_on_hand_end_period) AS cash_on_hand_end_period,
            sum(election_cmte_totals.last_debts_owed_by_committee) AS debts_owed_by_committee,
            min(election_cmte_totals.coverage_start_date) AS coverage_start_date,
            max(election_cmte_totals.coverage_end_date) AS coverage_end_date,
            array_agg(election_cmte_totals.federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
           FROM election_cmte_totals
          GROUP BY election_cmte_totals.candidate_id, election_cmte_totals.election_year
        UNION ALL
         SELECT cycle_totals.candidate_id,
            cycle_totals.election_year,
            cycle_totals.cycle,
            false AS is_election,
            cycle_totals.receipts,
            cycle_totals.disbursements,
            cycle_totals.has_raised_funds,
            cycle_totals.cash_on_hand_end_period,
            cycle_totals.debts_owed_by_committee,
            cycle_totals.coverage_start_date,
            cycle_totals.coverage_end_date,
            cycle_totals.federal_funds_flag
           FROM cycle_totals
        )
 SELECT cand.candidate_id,
 -- --
    candidate_election_year AS election_year,
    cand.two_year_period AS cycle,
    COALESCE(totals.is_election,
        CASE
        -- --
            WHEN cand.candidate_election_year = cand.two_year_period THEN true
            ELSE false
        END) AS is_election,
    COALESCE(totals.receipts, 0::numeric) AS receipts,
    COALESCE(totals.disbursements, 0::numeric) AS disbursements,
    COALESCE(totals.has_raised_funds, false) AS has_raised_funds,
    COALESCE(totals.cash_on_hand_end_period, 0::numeric) AS cash_on_hand_end_period,
    COALESCE(totals.debts_owed_by_committee, 0::numeric) AS debts_owed_by_committee,
    totals.coverage_start_date,
    totals.coverage_end_date,
    COALESCE(totals.federal_funds_flag, false) AS federal_funds_flag,
    cand.party,
    cand.office,
    cand.candidate_inactive
   FROM ofec_candidate_history_with_future_election_vw cand
     LEFT JOIN combined_totals totals ON cand.candidate_id::text = totals.candidate_id::text AND cand.two_year_period = totals.cycle
WITH DATA;

--Permissions
ALTER TABLE public.ofec_candidate_totals_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_candidate_totals_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_candidate_totals_mv_tmp TO fec_read;

--Indexes
CREATE UNIQUE INDEX idx_ofec_candidate_totals_mv_tmp_cand_id_elec_yr_cycle_is_elect ON public.ofec_candidate_totals_mv_tmp USING btree (candidate_id, election_year, cycle, is_election);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_cand_id ON public.ofec_candidate_totals_mv_tmp USING btree (candidate_id);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_cycle ON public.ofec_candidate_totals_mv_tmp USING btree (cycle);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_is_election ON public.ofec_candidate_totals_mv_tmp USING btree (is_election);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_receipts ON public.ofec_candidate_totals_mv_tmp USING btree (receipts);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_disbursements ON public.ofec_candidate_totals_mv_tmp USING btree (disbursements);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_election_year ON public.ofec_candidate_totals_mv_tmp USING btree (election_year);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_federal_funds_flag ON public.ofec_candidate_totals_mv_tmp USING btree (federal_funds_flag);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_has_raised_funds ON public.ofec_candidate_totals_mv_tmp USING btree (has_raised_funds);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_office ON public.ofec_candidate_totals_mv_tmp USING btree (office);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_party ON public.ofec_candidate_totals_mv_tmp USING btree (party);


-- ---------------
CREATE OR REPLACE VIEW public.ofec_candidate_totals_vw AS 
SELECT * FROM public.ofec_candidate_totals_mv_tmp;
-- ---------------

-- drop old MV
DROP MATERIALIZED VIEW public.ofec_candidate_totals_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_candidate_totals_mv_tmp RENAME TO ofec_candidate_totals_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_cand_id_elec_yr_cycle_is_elect RENAME TO idx_ofec_candidate_totals_mv_cand_id_elec_yr_cycle_is_elect;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_cand_id RENAME TO idx_ofec_candidate_totals_mv_cand_id;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_cycle RENAME TO idx_ofec_candidate_totals_mv_cycle;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_is_election RENAME TO idx_ofec_candidate_totals_mv_is_election;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_receipts RENAME TO idx_ofec_candidate_totals_mv_receipts;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_disbursements RENAME TO idx_ofec_candidate_totals_mv_disbursements;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_election_year RENAME TO idx_ofec_candidate_totals_mv_election_year;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_federal_funds_flag RENAME TO idx_ofec_candidate_totals_mv_federal_funds_flag;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_has_raised_funds RENAME TO idx_ofec_candidate_totals_mv_has_raised_funds;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_office RENAME TO idx_ofec_candidate_totals_mv_office;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_party RENAME TO idx_ofec_candidate_totals_mv_party;


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