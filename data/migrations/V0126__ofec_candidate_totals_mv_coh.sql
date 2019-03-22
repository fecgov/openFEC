/*
Fix COH for ofec_candidate_totals_vw

Issue #3635

Some candidates file on F3 and F3P - this adjusts the COH calculation
where there is more than one totals row for the same cycle for the same committee

Line 200: max(COH) instead of sum(COH)
Line 201: max(debt) instead of sum(debt)

- 1) Fix logic for ofec_candidate_totals_vw
    a) `create or replace ofec_candidate_totals_vw` to use new `MV` logic
    b) drop old `MV`
    c) recreate `MV` with new logic
    d) `create or replace ofec_candidate_totals_vw` -> `select all` from new `MV`

*/

-- Drop testing MV

DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_totals_mv_tmp;

-- a) `create or replace ofec_candidate_totals_vw` to use new `MV` logic

CREATE OR REPLACE VIEW ofec_candidate_totals_vw AS
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
           FROM public.ofec_totals_house_senate_vw
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
           FROM public.ofec_totals_presidential_vw
        ), link AS (
         SELECT DISTINCT ofec_cand_cmte_linkage_vw.cand_id,
            (ofec_cand_cmte_linkage_vw.cand_election_yr + (ofec_cand_cmte_linkage_vw.cand_election_yr % (2)::numeric)) AS rounded_election_yr,
            ofec_cand_cmte_linkage_vw.fec_election_yr,
            ofec_cand_cmte_linkage_vw.cmte_id,
            ofec_cand_cmte_linkage_vw.cmte_dsgn
           FROM public.ofec_cand_cmte_linkage_vw
          WHERE ((ofec_cand_cmte_linkage_vw.cmte_dsgn)::text = ANY ((ARRAY['P'::character varying, 'A'::character varying])::text[]))
        ), cycle_totals AS (
         SELECT DISTINCT ON (link.cand_id, totals_1.cycle) link.cand_id AS candidate_id,
            max(link.rounded_election_yr) AS election_year,
            totals_1.cycle,
            false AS is_election,
            sum(totals_1.receipts) AS receipts,
            sum(totals_1.disbursements) AS disbursements,
            (sum(totals_1.receipts) > (0)::numeric) AS has_raised_funds,
            max(totals_1.last_cash_on_hand_end_period) AS cash_on_hand_end_period,
            max(totals_1.last_debts_owed_by_committee) AS debts_owed_by_committee,
            min(totals_1.coverage_start_date) AS coverage_start_date,
            max(totals_1.coverage_end_date) AS coverage_end_date,
            (array_agg(totals_1.federal_funds_flag) @> ARRAY[true]) AS federal_funds_flag
           FROM (link
             JOIN totals totals_1 ON ((((link.cmte_id)::text = (totals_1.committee_id)::text) AND (link.fec_election_yr = (totals_1.cycle)::numeric))))
          GROUP BY link.cand_id, totals_1.cycle
        ), election_aggregates AS (
         SELECT cycle_totals.candidate_id,
            cycle_totals.election_year,
            sum(cycle_totals.receipts) AS receipts,
            sum(cycle_totals.disbursements) AS disbursements,
            (sum(cycle_totals.receipts) > (0)::numeric) AS has_raised_funds,
            min(cycle_totals.coverage_start_date) AS coverage_start_date,
            max(cycle_totals.coverage_end_date) AS coverage_end_date,
            (array_agg(cycle_totals.federal_funds_flag) @> ARRAY[true]) AS federal_funds_flag
           FROM cycle_totals
          GROUP BY cycle_totals.candidate_id, cycle_totals.election_year
        ), election_latest AS (
         SELECT DISTINCT ON (totals_1.candidate_id, totals_1.election_year) totals_1.candidate_id,
            totals_1.election_year,
            totals_1.cash_on_hand_end_period,
            totals_1.debts_owed_by_committee,
            totals_1.federal_funds_flag
           FROM cycle_totals totals_1
          ORDER BY totals_1.candidate_id, totals_1.election_year, totals_1.cycle DESC
        ), election_totals AS (
         SELECT totals_1.candidate_id,
            totals_1.election_year,
            totals_1.election_year AS cycle,
            true AS is_election,
            totals_1.receipts,
            totals_1.disbursements,
            totals_1.has_raised_funds,
            latest.cash_on_hand_end_period,
            latest.debts_owed_by_committee,
            totals_1.coverage_start_date,
            totals_1.coverage_end_date,
            totals_1.federal_funds_flag
           FROM (election_aggregates totals_1
             JOIN election_latest latest USING (candidate_id, election_year))
        ), combined_totals AS (
         SELECT cycle_totals.candidate_id,
            cycle_totals.election_year,
            cycle_totals.cycle,
            cycle_totals.is_election,
            cycle_totals.receipts,
            cycle_totals.disbursements,
            cycle_totals.has_raised_funds,
            cycle_totals.cash_on_hand_end_period,
            cycle_totals.debts_owed_by_committee,
            cycle_totals.coverage_start_date,
            cycle_totals.coverage_end_date,
            cycle_totals.federal_funds_flag
           FROM cycle_totals
        UNION ALL
         SELECT election_totals.candidate_id,
            election_totals.election_year,
            election_totals.cycle,
            election_totals.is_election,
            election_totals.receipts,
            election_totals.disbursements,
            election_totals.has_raised_funds,
            election_totals.cash_on_hand_end_period,
            election_totals.debts_owed_by_committee,
            election_totals.coverage_start_date,
            election_totals.coverage_end_date,
            election_totals.federal_funds_flag
           FROM election_totals
        )
 SELECT cand.candidate_id,
    cand.candidate_election_year AS election_year,
    cand.two_year_period AS cycle,
    COALESCE(totals.is_election,
        CASE
            WHEN (cand.candidate_election_year = cand.two_year_period) THEN true
            ELSE false
        END) AS is_election,
    COALESCE(totals.receipts, (0)::numeric) AS receipts,
    COALESCE(totals.disbursements, (0)::numeric) AS disbursements,
    COALESCE(totals.has_raised_funds, false) AS has_raised_funds,
    COALESCE(totals.cash_on_hand_end_period, (0)::numeric) AS cash_on_hand_end_period,
    COALESCE(totals.debts_owed_by_committee, (0)::numeric) AS debts_owed_by_committee,
    totals.coverage_start_date,
    totals.coverage_end_date,
    COALESCE(totals.federal_funds_flag, false) AS federal_funds_flag
   FROM (public.ofec_candidate_history_with_future_election_vw cand
     LEFT JOIN combined_totals totals ON ((((cand.candidate_id)::text = (totals.candidate_id)::text) AND (cand.two_year_period = totals.cycle))));

-- b) drop old `MV`

DROP MATERIALIZED VIEW public.ofec_candidate_totals_mv;

-- c) recreate `MV` with new logic

CREATE MATERIALIZED VIEW public.ofec_candidate_totals_mv AS
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
           FROM public.ofec_totals_house_senate_vw
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
           FROM public.ofec_totals_presidential_vw
        ), link AS (
         SELECT DISTINCT ofec_cand_cmte_linkage_vw.cand_id,
            (ofec_cand_cmte_linkage_vw.cand_election_yr + (ofec_cand_cmte_linkage_vw.cand_election_yr % (2)::numeric)) AS rounded_election_yr,
            ofec_cand_cmte_linkage_vw.fec_election_yr,
            ofec_cand_cmte_linkage_vw.cmte_id,
            ofec_cand_cmte_linkage_vw.cmte_dsgn
           FROM public.ofec_cand_cmte_linkage_vw
          WHERE ((ofec_cand_cmte_linkage_vw.cmte_dsgn)::text = ANY ((ARRAY['P'::character varying, 'A'::character varying])::text[]))
        ), cycle_totals AS (
         SELECT DISTINCT ON (link.cand_id, totals_1.cycle) link.cand_id AS candidate_id,
            max(link.rounded_election_yr) AS election_year,
            totals_1.cycle,
            false AS is_election,
            sum(totals_1.receipts) AS receipts,
            sum(totals_1.disbursements) AS disbursements,
            (sum(totals_1.receipts) > (0)::numeric) AS has_raised_funds,
            max(totals_1.last_cash_on_hand_end_period) AS cash_on_hand_end_period,
            max(totals_1.last_debts_owed_by_committee) AS debts_owed_by_committee,
            min(totals_1.coverage_start_date) AS coverage_start_date,
            max(totals_1.coverage_end_date) AS coverage_end_date,
            (array_agg(totals_1.federal_funds_flag) @> ARRAY[true]) AS federal_funds_flag
           FROM (link
             JOIN totals totals_1 ON ((((link.cmte_id)::text = (totals_1.committee_id)::text) AND (link.fec_election_yr = (totals_1.cycle)::numeric))))
          GROUP BY link.cand_id, totals_1.cycle
        ), election_aggregates AS (
         SELECT cycle_totals.candidate_id,
            cycle_totals.election_year,
            sum(cycle_totals.receipts) AS receipts,
            sum(cycle_totals.disbursements) AS disbursements,
            (sum(cycle_totals.receipts) > (0)::numeric) AS has_raised_funds,
            min(cycle_totals.coverage_start_date) AS coverage_start_date,
            max(cycle_totals.coverage_end_date) AS coverage_end_date,
            (array_agg(cycle_totals.federal_funds_flag) @> ARRAY[true]) AS federal_funds_flag
           FROM cycle_totals
          GROUP BY cycle_totals.candidate_id, cycle_totals.election_year
        ), election_latest AS (
         SELECT DISTINCT ON (totals_1.candidate_id, totals_1.election_year) totals_1.candidate_id,
            totals_1.election_year,
            totals_1.cash_on_hand_end_period,
            totals_1.debts_owed_by_committee,
            totals_1.federal_funds_flag
           FROM cycle_totals totals_1
          ORDER BY totals_1.candidate_id, totals_1.election_year, totals_1.cycle DESC
        ), election_totals AS (
         SELECT totals_1.candidate_id,
            totals_1.election_year,
            totals_1.election_year AS cycle,
            true AS is_election,
            totals_1.receipts,
            totals_1.disbursements,
            totals_1.has_raised_funds,
            latest.cash_on_hand_end_period,
            latest.debts_owed_by_committee,
            totals_1.coverage_start_date,
            totals_1.coverage_end_date,
            totals_1.federal_funds_flag
           FROM (election_aggregates totals_1
             JOIN election_latest latest USING (candidate_id, election_year))
        ), combined_totals AS (
         SELECT cycle_totals.candidate_id,
            cycle_totals.election_year,
            cycle_totals.cycle,
            cycle_totals.is_election,
            cycle_totals.receipts,
            cycle_totals.disbursements,
            cycle_totals.has_raised_funds,
            cycle_totals.cash_on_hand_end_period,
            cycle_totals.debts_owed_by_committee,
            cycle_totals.coverage_start_date,
            cycle_totals.coverage_end_date,
            cycle_totals.federal_funds_flag
           FROM cycle_totals
        UNION ALL
         SELECT election_totals.candidate_id,
            election_totals.election_year,
            election_totals.cycle,
            election_totals.is_election,
            election_totals.receipts,
            election_totals.disbursements,
            election_totals.has_raised_funds,
            election_totals.cash_on_hand_end_period,
            election_totals.debts_owed_by_committee,
            election_totals.coverage_start_date,
            election_totals.coverage_end_date,
            election_totals.federal_funds_flag
           FROM election_totals
        )
 SELECT cand.candidate_id,
    cand.candidate_election_year AS election_year,
    cand.two_year_period AS cycle,
    COALESCE(totals.is_election,
        CASE
            WHEN (cand.candidate_election_year = cand.two_year_period) THEN true
            ELSE false
        END) AS is_election,
    COALESCE(totals.receipts, (0)::numeric) AS receipts,
    COALESCE(totals.disbursements, (0)::numeric) AS disbursements,
    COALESCE(totals.has_raised_funds, false) AS has_raised_funds,
    COALESCE(totals.cash_on_hand_end_period, (0)::numeric) AS cash_on_hand_end_period,
    COALESCE(totals.debts_owed_by_committee, (0)::numeric) AS debts_owed_by_committee,
    totals.coverage_start_date,
    totals.coverage_end_date,
    COALESCE(totals.federal_funds_flag, false) AS federal_funds_flag
   FROM (public.ofec_candidate_history_with_future_election_vw cand
     LEFT JOIN combined_totals totals ON ((((cand.candidate_id)::text = (totals.candidate_id)::text) AND (cand.two_year_period = totals.cycle))))
  WITH DATA;

--Permissions

ALTER TABLE public.ofec_candidate_totals_mv OWNER TO fec;

--Indexes

CREATE UNIQUE INDEX ofec_candidate_totals_mv_candidate_id_cycle_is_election_idx ON public.ofec_candidate_totals_mv USING btree (candidate_id, cycle, is_election);

CREATE INDEX ofec_candidate_totals_mv_candidate_id_idx ON public.ofec_candidate_totals_mv USING btree (candidate_id);

CREATE INDEX ofec_candidate_totals_mv_cycle_candidate_id_idx ON public.ofec_candidate_totals_mv USING btree (cycle, candidate_id);

CREATE INDEX ofec_candidate_totals_mv_cycle_idx ON public.ofec_candidate_totals_mv USING btree (cycle);

CREATE INDEX ofec_candidate_totals_mv_disbursements_idx ON public.ofec_candidate_totals_mv USING btree (disbursements);

CREATE INDEX ofec_candidate_totals_mv_election_year_idx ON public.ofec_candidate_totals_mv USING btree (election_year);

CREATE INDEX ofec_candidate_totals_mv_federal_funds_flag_idx ON public.ofec_candidate_totals_mv USING btree (federal_funds_flag);

CREATE INDEX ofec_candidate_totals_mv_has_raised_funds_idx ON public.ofec_candidate_totals_mv USING btree (has_raised_funds);

CREATE INDEX ofec_candidate_totals_mv_is_election_idx ON public.ofec_candidate_totals_mv USING btree (is_election);

CREATE INDEX ofec_candidate_totals_mv_receipts_idx ON public.ofec_candidate_totals_mv USING btree (receipts);

-- d) `create or replace ofec_candidate_totals_vw` -> `select all` from new `MV`

CREATE OR REPLACE VIEW ofec_candidate_totals_vw AS SELECT * FROM ofec_candidate_totals_mv;
ALTER VIEW ofec_candidate_totals_vw OWNER TO fec;
GRANT SELECT ON ofec_candidate_totals_vw TO fec_read;
