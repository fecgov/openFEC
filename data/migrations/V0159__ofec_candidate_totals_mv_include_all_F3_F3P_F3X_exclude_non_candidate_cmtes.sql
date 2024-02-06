/*
This is part of migration files solving issues #3925
Candidate committees supposed to report their financial activity by
cmte_tp = H/S (filed F3)
cmte_tp = P (filed F3P)
However, sometimes candidate committees filed incorrect F3* forms.  
Original the source of the totals in this MV are from 
ofec_totals_house_senate_vw
ofec_totals_presidential_vw
which are both derived from ofec_totals_combined_vw, separated by Form_type.
This will miss F3X filed by candidate committees.
This migration file update the definition to directly takes the totals from ofec_totals_combined_vw.
Takes all F3* forms (candidate committees also files other forms such as F10, F11, F12, F5)
filed by cmte_dsgn P/A (exclude J, D, etc) candidate committees ('H','P','S')
*/

-- ----------------------
-- ofec_candidate_totals_mv_tmp
-- ----------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_totals_mv_tmp;
CREATE MATERIALIZED VIEW ofec_candidate_totals_mv_tmp AS
WITH totals AS (
         SELECT ofec_totals_combined_vw.committee_id,
            ofec_totals_combined_vw.cycle,
            ofec_totals_combined_vw.receipts,
            ofec_totals_combined_vw.disbursements,
            ofec_totals_combined_vw.last_cash_on_hand_end_period,
            ofec_totals_combined_vw.last_debts_owed_by_committee,
            ofec_totals_combined_vw.coverage_start_date,
            ofec_totals_combined_vw.coverage_end_date,
            ofec_totals_combined_vw.federal_funds_flag
           FROM ofec_totals_combined_vw
           WHERE form_type in ('F3', 'F3P', 'F3X')
           AND committee_type in ('H','P','S')
           AND committee_designation in ('P','A')
        ), link AS (
         SELECT ofec_cand_cmte_linkage_vw.cand_id,
            ofec_cand_cmte_linkage_vw.election_yr_to_be_included + ofec_cand_cmte_linkage_vw.election_yr_to_be_included % 2::numeric AS election_yr_to_be_included,
            ofec_cand_cmte_linkage_vw.fec_election_yr,
            ofec_cand_cmte_linkage_vw.cmte_id
           FROM ofec_cand_cmte_linkage_vw
          WHERE ofec_cand_cmte_linkage_vw.cmte_dsgn in ('P','A')
          -- should only include candidate committees 
          AND ofec_cand_cmte_linkage_vw.cmte_tp in ('H','P','S')
          --
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
ALTER TABLE public.ofec_candidate_totals_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_candidate_totals_vw TO fec;
GRANT SELECT ON TABLE public.ofec_candidate_totals_vw TO fec_read;


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
