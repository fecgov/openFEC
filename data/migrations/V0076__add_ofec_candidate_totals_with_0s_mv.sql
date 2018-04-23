/*
Issue #3023

-Based on `ofec_candidate_all_totals_mv`
-Bring over the existing logic but use `ofec_candidate_history_mv`
as base table in order to show $0 for candidates who haven't filed yet

*/

SET search_path = public, pg_catalog;

CREATE MATERIALIZED VIEW ofec_candidate_totals_with_0s_mv AS
  SELECT cand.candidate_id,
    cand.candidate_election_year AS election_year,
    cand.two_year_period AS cycle,
    COALESCE (totals.is_election, false) AS is_election,
    COALESCE (totals.receipts, 0) AS receipts,
    COALESCE (totals.disbursements, 0) AS disbursements,
    COALESCE (totals.has_raised_funds, false) AS has_raised_funds,
    COALESCE (totals.cash_on_hand_end_period, 0) AS cash_on_hand_end_period,
    COALESCE (totals.debts_owed_by_committee, 0) AS debts_owed_by_committee,
    totals.coverage_start_date,
    totals.coverage_end_date,
    COALESCE (totals.federal_funds_flag, false) AS federal_funds_flag
  FROM ofec_candidate_history_mv cand
  LEFT JOIN ofec_candidate_totals_mv totals
  ON cand.candidate_id = totals.candidate_id
    AND cand.candidate_election_year = totals.election_year
    AND cand.two_year_period = totals.cycle;

--Permissions-------------------

ALTER TABLE ofec_candidate_totals_with_0s_mv OWNER TO fec;
GRANT SELECT ON TABLE ofec_candidate_totals_with_0s_mv TO fec_read;
GRANT ALL ON TABLE ofec_candidate_totals_with_0s_mv TO fec;

--Indexes including unique idx--

CREATE UNIQUE INDEX ofec_candidate_totals_with_0s_mv_candidate_id_cycle_is_election_idx
    ON ofec_candidate_totals_with_0s_mv USING btree (candidate_id, cycle, is_election);

CREATE INDEX ofec_candidate_totals_with_0s_mv_candidate_id_idx
    ON ofec_candidate_totals_with_0s_mv USING btree (candidate_id);

CREATE INDEX ofec_candidate_totals_with_0s_mv_cycle_candidate_id_idx1
    ON ofec_candidate_totals_with_0s_mv USING btree (cycle, candidate_id);

CREATE INDEX ofec_candidate_totals_with_0s_mv_cycle_idx
    ON ofec_candidate_totals_with_0s_mv USING btree (cycle);

CREATE INDEX ofec_candidate_totals_with_0s_mv_disbursements_idx
    ON ofec_candidate_totals_with_0s_mv USING btree (disbursements);

CREATE INDEX ofec_candidate_totals_with_0s_mv_election_year_idx
    ON ofec_candidate_totals_with_0s_mv USING btree (election_year);

CREATE INDEX ofec_candidate_totals_with_0s_mv_federal_funds_flag_idx1
    ON ofec_candidate_totals_with_0s_mv USING btree (federal_funds_flag);

CREATE INDEX ofec_candidate_totals_with_0s_mv_has_raised_funds_idx1
    ON ofec_candidate_totals_with_0s_mv USING btree (has_raised_funds);

CREATE INDEX ofec_candidate_totals_with_0s_mv_is_election_idx
    ON ofec_candidate_totals_with_0s_mv USING btree (is_election);

CREATE INDEX ofec_candidate_totals_with_0s_mv_receipts_idx
    ON ofec_candidate_totals_with_0s_mv USING btree (receipts);
