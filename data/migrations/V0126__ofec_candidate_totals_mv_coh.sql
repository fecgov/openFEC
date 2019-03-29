/*
Fix COH for ofec_candidate_totals_mv/ofec_candidate_totals_vw

Issue #3635

Some candidates file on F3 and F3P - this adjusts the COH calculation
where there is more than one totals row for the same cycle for the same committee

max(COH) instead of sum(COH)
max(debt) instead of sum(debt)
Will resolve the problem of candidates filing multiple form_tp.

Addition layers of aggregation are added to address the issue of candidates with multiple
P/A cmtes.  The COH of these rows need to be summed up.

Since API still referring ofec_candidate_totals_mv in the model file, and database migration
taking place BEFORE new API during deployment, the _tmp approach is used here to minimize the down time.

*/

-- Replace the definition of ofec_candidate_totals_vw to have the new mv's defintion
-- to remove the dependency on ofec_candidate_totals_mv
CREATE OR REPLACE VIEW ofec_candidate_totals_vw AS 
WITH 
-- basic financial info from ofec_totals_combined_mv 
totals AS 
(
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
)
, link AS 
-- Get latest cmte info for cmte_dsgn=P/A cmtes per cand_id/cmte_id/cmte_dsgn/rounded cand_election_yr/fec_election_yr
(
  SELECT DISTINCT ofec_cand_cmte_linkage_vw.cand_id,
  ofec_cand_cmte_linkage_vw.cand_election_yr + ofec_cand_cmte_linkage_vw.cand_election_yr % 2::numeric AS rounded_election_yr,
  ofec_cand_cmte_linkage_vw.fec_election_yr,
  ofec_cand_cmte_linkage_vw.cmte_id,
  ofec_cand_cmte_linkage_vw.cmte_dsgn
  FROM ofec_cand_cmte_linkage_vw
  WHERE ofec_cand_cmte_linkage_vw.cmte_dsgn::text = ANY (ARRAY['P'::character varying::text, 'A'::character varying::text])
)
, cycle_cmte_totals_basic AS 
-- calculate the latest available running total items (last_cash_on_hand_end_period, last_debts_owed_by_committee) per cand_id, election_yr, cycle, cmte_id
(
  SELECT  
  link.cand_id,
  link.cmte_id,
  link.rounded_election_yr,
  totals_1.cycle,
  false AS is_election,
  totals_1.receipts,
  totals_1.disbursements,
  first_value(totals_1.last_cash_on_hand_end_period) 
  OVER (PARTITION BY link.cand_id, link.rounded_election_yr, totals_1.cycle, link.cmte_id ORDER BY totals_1.coverage_end_date DESC NULLS LAST) AS last_cash_on_hand_end_period,
  first_value(totals_1.last_debts_owed_by_committee) 
  OVER (PARTITION BY link.cand_id, link.rounded_election_yr, totals_1.cycle, link.cmte_id ORDER BY totals_1.coverage_end_date DESC NULLS LAST) AS last_debts_owed_by_committee,
  totals_1.coverage_start_date,
  totals_1.coverage_end_date,
  totals_1.federal_funds_flag
  FROM (link
  JOIN totals totals_1 ON ((((link.cmte_id)::text = (totals_1.committee_id)::text) AND (link.fec_election_yr = (totals_1.cycle)::numeric))))
)
, cycle_cmte_totals AS 
-- sum up data per cand_id/election_year/cycle/cmte_id
(
  SELECT 
  cand_id AS candidate_id,
  cmte_id,
  rounded_election_yr AS election_year,
  cycle,
  sum(receipts) AS receipts,
  sum(disbursements) AS disbursements,
  max(last_cash_on_hand_end_period) AS cash_on_hand_end_period_per_cmte,
  max(last_debts_owed_by_committee) AS debts_owed_by_committee_per_cmte,
  min(coverage_start_date) AS coverage_start_date,
  max(coverage_end_date) AS coverage_end_date,
  array_agg(federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
  FROM cycle_cmte_totals_basic
  GROUP BY cand_id, rounded_election_yr, cycle, cmte_id
)
, cycle_totals AS 
-- sum up data per cand_id/election_year/cycle
-- for candidates only have one committee, this will be the same as cycle_cmte_totals
(
  SELECT 
  candidate_id,
  election_year,
  cycle,
  false AS is_election,
  sum(receipts) AS receipts,
  sum(disbursements) AS disbursements,
  sum(receipts) > 0::numeric AS has_raised_funds,
  sum(cash_on_hand_end_period_per_cmte) AS cash_on_hand_end_period,
  sum(debts_owed_by_committee_per_cmte) AS debts_owed_by_committee,
  min(coverage_start_date) AS coverage_start_date,
  max(coverage_end_date) AS coverage_end_date,
  array_agg(federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
  FROM cycle_cmte_totals
  GROUP BY candidate_id, election_year, cycle
)
, election_cmte_totals_basic AS 
-- calculate the latest available running total items (last_cash_on_hand_end_period, last_debts_owed_by_committee) per cand_id, election_yr, cmte_id
(
  SELECT candidate_id,
  cmte_id,
  cycle,
  election_year,
  receipts,
  disbursements,
  first_value(cash_on_hand_end_period_per_cmte) 
  OVER (PARTITION BY candidate_id, election_year, cmte_id ORDER BY cycle DESC NULLS LAST) AS last_cash_on_hand_end_period,
  first_value(debts_owed_by_committee_per_cmte) 
  OVER (PARTITION BY candidate_id, election_year, cmte_id ORDER BY cycle DESC NULLS LAST) AS last_debts_owed_by_committee,
  coverage_start_date,
  coverage_end_date,
  federal_funds_flag
  FROM cycle_cmte_totals
)
, election_cmte_totals AS (
-- sum up data per cand_id/election_year/cmte_id
  SELECT candidate_id,
  cmte_id,
  election_year,
  sum(receipts) AS receipts,
  sum(disbursements) AS disbursements,
  max(last_cash_on_hand_end_period) as last_cash_on_hand_end_period,
  max(last_debts_owed_by_committee) as last_debts_owed_by_committee,
  min(coverage_start_date) AS coverage_start_date,
  max(coverage_end_date) AS coverage_end_date,
  array_agg(federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
  from election_cmte_totals_basic
  group by candidate_id, election_year, cmte_id
) 
, combined_totals AS 
(
  -- election_totals 
  -- sum up data per cand_id/election_year
  SELECT candidate_id,
  election_year,
  election_year AS cycle,
  true AS is_election,
  sum(receipts) as receipts,
  sum(disbursements) as disbursements,
  sum(receipts) > 0::numeric AS has_raised_funds,
  sum(last_cash_on_hand_end_period) as cash_on_hand_end_period,
  sum(last_debts_owed_by_committee) as debts_owed_by_committee,
  min(coverage_start_date) as coverage_start_date,
  max(coverage_end_date) as coverage_end_date,
  array_agg(federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
  from election_cmte_totals
  group by candidate_id, election_year 
  --
  union all
  -- cycle_totals
  SELECT candidate_id,
  election_year,
  cycle,
  false AS is_election,
  receipts,
  disbursements,
  has_raised_funds,
  cash_on_hand_end_period,
  debts_owed_by_committee,
  coverage_start_date,
  coverage_end_date,
  federal_funds_flag
  from cycle_totals
)
 SELECT cand.candidate_id,
    cand.candidate_election_year AS election_year,
    cand.two_year_period AS cycle,
    COALESCE(totals.is_election,
        CASE
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
    COALESCE(totals.federal_funds_flag, false) AS federal_funds_flag
   FROM ofec_candidate_history_with_future_election_vw cand
     LEFT JOIN combined_totals totals ON cand.candidate_id::text = totals.candidate_id::text AND cand.two_year_period = totals.cycle
;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_totals_mv_tmp;
CREATE MATERIALIZED VIEW ofec_candidate_totals_mv_tmp AS
WITH 
-- basic financial info from ofec_totals_combined_mv 
totals AS 
(
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
)
, link AS 
-- Get latest cmte info for cmte_dsgn=P/A cmtes per cand_id/cmte_id/cmte_dsgn/rounded cand_election_yr/fec_election_yr
(
  SELECT DISTINCT ofec_cand_cmte_linkage_vw.cand_id,
  ofec_cand_cmte_linkage_vw.cand_election_yr + ofec_cand_cmte_linkage_vw.cand_election_yr % 2::numeric AS rounded_election_yr,
  ofec_cand_cmte_linkage_vw.fec_election_yr,
  ofec_cand_cmte_linkage_vw.cmte_id,
  ofec_cand_cmte_linkage_vw.cmte_dsgn
  FROM ofec_cand_cmte_linkage_vw
  WHERE ofec_cand_cmte_linkage_vw.cmte_dsgn::text = ANY (ARRAY['P'::character varying::text, 'A'::character varying::text])
)
, cycle_cmte_totals_basic AS 
-- calculate the latest available running total items (last_cash_on_hand_end_period, last_debts_owed_by_committee) per cand_id, election_yr, cycle, cmte_id
(
  SELECT  
  link.cand_id,
  link.cmte_id,
  link.rounded_election_yr,
  totals_1.cycle,
  false AS is_election,
  totals_1.receipts,
  totals_1.disbursements,
  first_value(totals_1.last_cash_on_hand_end_period) 
  OVER (PARTITION BY link.cand_id, link.rounded_election_yr, totals_1.cycle, link.cmte_id ORDER BY totals_1.coverage_end_date DESC NULLS LAST) AS last_cash_on_hand_end_period,
  first_value(totals_1.last_debts_owed_by_committee) 
  OVER (PARTITION BY link.cand_id, link.rounded_election_yr, totals_1.cycle, link.cmte_id ORDER BY totals_1.coverage_end_date DESC NULLS LAST) AS last_debts_owed_by_committee,
  totals_1.coverage_start_date,
  totals_1.coverage_end_date,
  totals_1.federal_funds_flag
  FROM (link
  JOIN totals totals_1 ON ((((link.cmte_id)::text = (totals_1.committee_id)::text) AND (link.fec_election_yr = (totals_1.cycle)::numeric))))
)
, cycle_cmte_totals AS 
-- sum up data per cand_id/election_year/cycle/cmte_id
(
  SELECT 
  cand_id AS candidate_id,
  cmte_id,
  rounded_election_yr AS election_year,
  cycle,
  sum(receipts) AS receipts,
  sum(disbursements) AS disbursements,
  max(last_cash_on_hand_end_period) AS cash_on_hand_end_period_per_cmte,
  max(last_debts_owed_by_committee) AS debts_owed_by_committee_per_cmte,
  min(coverage_start_date) AS coverage_start_date,
  max(coverage_end_date) AS coverage_end_date,
  array_agg(federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
  FROM cycle_cmte_totals_basic
  GROUP BY cand_id, rounded_election_yr, cycle, cmte_id
)
, cycle_totals AS 
-- sum up data per cand_id/election_year/cycle
-- for candidates only have one committee, this will be the same as cycle_cmte_totals
(
  SELECT 
  candidate_id,
  election_year,
  cycle,
  false AS is_election,
  sum(receipts) AS receipts,
  sum(disbursements) AS disbursements,
  sum(receipts) > 0::numeric AS has_raised_funds,
  sum(cash_on_hand_end_period_per_cmte) AS cash_on_hand_end_period,
  sum(debts_owed_by_committee_per_cmte) AS debts_owed_by_committee,
  min(coverage_start_date) AS coverage_start_date,
  max(coverage_end_date) AS coverage_end_date,
  array_agg(federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
  FROM cycle_cmte_totals
  GROUP BY candidate_id, election_year, cycle
)
, election_cmte_totals_basic AS 
-- calculate the latest available running total items (last_cash_on_hand_end_period, last_debts_owed_by_committee) per cand_id, election_yr, cmte_id
(
  SELECT candidate_id,
  cmte_id,
  cycle,
  election_year,
  receipts,
  disbursements,
  first_value(cash_on_hand_end_period_per_cmte) 
  OVER (PARTITION BY candidate_id, election_year, cmte_id ORDER BY cycle DESC NULLS LAST) AS last_cash_on_hand_end_period,
  first_value(debts_owed_by_committee_per_cmte) 
  OVER (PARTITION BY candidate_id, election_year, cmte_id ORDER BY cycle DESC NULLS LAST) AS last_debts_owed_by_committee,
  coverage_start_date,
  coverage_end_date,
  federal_funds_flag
  FROM cycle_cmte_totals
)
, election_cmte_totals AS (
-- sum up data per cand_id/election_year/cmte_id
  SELECT candidate_id,
  cmte_id,
  election_year,
  sum(receipts) AS receipts,
  sum(disbursements) AS disbursements,
  max(last_cash_on_hand_end_period) as last_cash_on_hand_end_period,
  max(last_debts_owed_by_committee) as last_debts_owed_by_committee,
  min(coverage_start_date) AS coverage_start_date,
  max(coverage_end_date) AS coverage_end_date,
  array_agg(federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
  from election_cmte_totals_basic
  group by candidate_id, election_year, cmte_id
) 
, combined_totals AS 
(
  -- election_totals 
  -- sum up data per cand_id/election_year
  SELECT candidate_id,
  election_year,
  election_year AS cycle,
  true AS is_election,
  sum(receipts) as receipts,
  sum(disbursements) as disbursements,
  sum(receipts) > 0::numeric AS has_raised_funds,
  sum(last_cash_on_hand_end_period) as cash_on_hand_end_period,
  sum(last_debts_owed_by_committee) as debts_owed_by_committee,
  min(coverage_start_date) as coverage_start_date,
  max(coverage_end_date) as coverage_end_date,
  array_agg(federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
  from election_cmte_totals
  group by candidate_id, election_year 
  --
  union all
  -- cycle_totals
  SELECT candidate_id,
  election_year,
  cycle,
  false AS is_election,
  receipts,
  disbursements,
  has_raised_funds,
  cash_on_hand_end_period,
  debts_owed_by_committee,
  coverage_start_date,
  coverage_end_date,
  federal_funds_flag
  from cycle_totals
)
 SELECT cand.candidate_id,
    cand.candidate_election_year AS election_year,
    cand.two_year_period AS cycle,
    COALESCE(totals.is_election,
        CASE
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
    COALESCE(totals.federal_funds_flag, false) AS federal_funds_flag
   FROM ofec_candidate_history_with_future_election_vw cand
     LEFT JOIN combined_totals totals ON cand.candidate_id::text = totals.candidate_id::text AND cand.two_year_period = totals.cycle
WITH DATA;

--Permissions
ALTER TABLE public.ofec_candidate_totals_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_candidate_totals_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_candidate_totals_mv_tmp TO fec_read;

--Indexes
CREATE UNIQUE INDEX idx_ofec_candidate_totals_mv_tmp_cand_id_cycle_is_election ON public.ofec_candidate_totals_mv_tmp USING btree (candidate_id, cycle, is_election);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_cand_id ON public.ofec_candidate_totals_mv_tmp USING btree (candidate_id);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_cycle ON public.ofec_candidate_totals_mv_tmp USING btree (cycle);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_is_election ON public.ofec_candidate_totals_mv_tmp USING btree (is_election);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_receipts ON public.ofec_candidate_totals_mv_tmp USING btree (receipts);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_disbursements ON public.ofec_candidate_totals_mv_tmp USING btree (disbursements);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_election_year ON public.ofec_candidate_totals_mv_tmp USING btree (election_year);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_federal_funds_flag ON public.ofec_candidate_totals_mv_tmp USING btree (federal_funds_flag);

CREATE INDEX idx_ofec_candidate_totals_mv_tmp_has_raised_funds ON public.ofec_candidate_totals_mv_tmp USING btree (has_raised_funds);

-- drop old `MV`
DROP MATERIALIZED VIEW public.ofec_candidate_totals_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_candidate_totals_mv_tmp RENAME TO ofec_candidate_totals_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_cand_id_cycle_is_election RENAME TO idx_ofec_candidate_totals_mv_cand_id_cycle_is_election;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_cand_id RENAME TO idx_ofec_candidate_totals_mv_cand_id;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_cycle RENAME TO idx_ofec_candidate_totals_mv_cycle;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_is_election RENAME TO idx_ofec_candidate_totals_mv_is_election;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_receipts RENAME TO idx_ofec_candidate_totals_mv_receipts;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_disbursements RENAME TO idx_ofec_candidate_totals_mv_disbursements;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_election_year RENAME TO idx_ofec_candidate_totals_mv_election_year;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_federal_funds_flag RENAME TO idx_ofec_candidate_totals_mv_federal_funds_flag;

ALTER INDEX IF EXISTS idx_ofec_candidate_totals_mv_tmp_has_raised_funds RENAME TO idx_ofec_candidate_totals_mv_has_raised_funds;

-- recreate ofec_candidate_totals_vw` -> `select all` from new `MV`
CREATE OR REPLACE VIEW ofec_candidate_totals_vw AS SELECT * FROM ofec_candidate_totals_mv;
ALTER VIEW ofec_candidate_totals_vw OWNER TO fec;
GRANT SELECT ON ofec_candidate_totals_vw TO fec_read;
