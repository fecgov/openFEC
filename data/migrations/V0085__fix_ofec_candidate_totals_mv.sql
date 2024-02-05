/*
Addresses #3196 and #3200

#3196: Fix doubled totals for off-year special election candidates
#3200: Fixes missing off-year special candidates

- Recreate ofec_candidate_totals_mv
- Recreate two dependent views:
    -ofec_candidate_flag_mv
    -ofec_candidate_totals_with_0s_mv;

*/

SET search_path = public;

DROP MATERIALIZED VIEW IF EXISTS ofec_candidate_totals_mv_tmp;

CREATE MATERIALIZED VIEW ofec_candidate_totals_mv_tmp AS
 WITH totals AS (
         SELECT ofec_totals_house_senate_mv.committee_id,
            ofec_totals_house_senate_mv.cycle,
            ofec_totals_house_senate_mv.receipts,
            ofec_totals_house_senate_mv.disbursements,
            ofec_totals_house_senate_mv.last_cash_on_hand_end_period,
            ofec_totals_house_senate_mv.last_debts_owed_by_committee,
            ofec_totals_house_senate_mv.coverage_start_date,
            ofec_totals_house_senate_mv.coverage_end_date,
            false AS federal_funds_flag
           FROM ofec_totals_house_senate_mv
        UNION ALL
         SELECT ofec_totals_presidential_mv.committee_id,
            ofec_totals_presidential_mv.cycle,
            ofec_totals_presidential_mv.receipts,
            ofec_totals_presidential_mv.disbursements,
            ofec_totals_presidential_mv.last_cash_on_hand_end_period,
            ofec_totals_presidential_mv.last_debts_owed_by_committee,
            ofec_totals_presidential_mv.coverage_start_date,
            ofec_totals_presidential_mv.coverage_end_date,
            ofec_totals_presidential_mv.federal_funds_flag
           FROM ofec_totals_presidential_mv
 ), link AS ( --Off-year special election candidates have > 1 row/cycle
         SELECT DISTINCT cand_id,
            cand_election_yr + cand_election_yr % 2 as rounded_election_yr,
            fec_election_yr,
            cmte_id,
            cmte_dsgn
          FROM ofec_cand_cmte_linkage_mv
          WHERE cmte_dsgn IN ('P', 'A')
 ), cycle_totals AS (
         SELECT DISTINCT ON (link.cand_id, totals.cycle) link.cand_id AS candidate_id,
            max(link.rounded_election_yr) AS election_year,
            totals.cycle,
            false AS is_election,
            sum(totals.receipts) AS receipts,
            sum(totals.disbursements) AS disbursements,
            (sum(totals.receipts) > (0)::numeric) AS has_raised_funds,
            sum(totals.last_cash_on_hand_end_period) AS cash_on_hand_end_period,
            sum(totals.last_debts_owed_by_committee) AS debts_owed_by_committee,
            min(totals.coverage_start_date) AS coverage_start_date,
            max(totals.coverage_end_date) AS coverage_end_date,
            (array_agg(totals.federal_funds_flag) @> ARRAY[true]) AS federal_funds_flag
           FROM link
             INNER JOIN totals
                ON link.cmte_id = totals.committee_id
                AND link.fec_election_yr = totals.cycle
             LEFT JOIN ofec_candidate_election_mv election
                ON link.cand_id = election.candidate_id
                AND totals.cycle <= election.cand_election_year
                AND totals.cycle > election.prev_election_year
          GROUP BY link.cand_id, election.cand_election_year, totals.cycle
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
         SELECT DISTINCT ON (totals.candidate_id, totals.election_year) totals.candidate_id,
            totals.election_year,
            totals.cash_on_hand_end_period,
            totals.debts_owed_by_committee,
            totals.federal_funds_flag
           FROM cycle_totals totals
          ORDER BY totals.candidate_id, totals.election_year, totals.cycle DESC
 ), election_totals AS (
         SELECT totals.candidate_id,
            totals.election_year,
            totals.election_year AS cycle,
            true AS is_election,
            totals.receipts,
            totals.disbursements,
            totals.has_raised_funds,
            latest.cash_on_hand_end_period,
            latest.debts_owed_by_committee,
            totals.coverage_start_date,
            totals.coverage_end_date,
            totals.federal_funds_flag
           FROM (election_aggregates totals
             JOIN election_latest latest USING (candidate_id, election_year))
 )
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
   FROM election_totals;

--Permissions

ALTER TABLE ofec_candidate_totals_mv_tmp OWNER TO fec;
GRANT SELECT ON TABLE ofec_candidate_totals_mv_tmp TO fec_read;

--Indexes--------------

/*
Filters on this model for TotalsCandidateView:

- filter_multi_fields = election_year, cycle
- filter_range_fields = receipts, disbursements, cash_on_hand_end_period, debts_owed_by_committee
- filter_match_fields = has_raised_funds, federal_funds_flag, is_election

*/

CREATE UNIQUE INDEX ofec_candidate_totals_mv_candidate_id_cycle_is_election_idx_tmp ON ofec_candidate_totals_mv_tmp USING btree (candidate_id, cycle, is_election);

CREATE INDEX ofec_candidate_totals_mv_candidate_id_idx_tmp
    ON ofec_candidate_totals_mv_tmp USING btree (candidate_id);

CREATE INDEX ofec_candidate_totals_mv_cycle_candidate_id_idx_tmp
    ON ofec_candidate_totals_mv_tmp USING btree (cycle, candidate_id);

CREATE INDEX ofec_candidate_totals_mv_cycle_idx_tmp
    ON ofec_candidate_totals_mv_tmp USING btree (cycle);

CREATE INDEX ofec_candidate_totals_mv_receipts_idx_tmp
    ON ofec_candidate_totals_mv_tmp USING btree (receipts);

CREATE INDEX ofec_candidate_totals_mv_disbursements_idx_tmp
    ON ofec_candidate_totals_mv_tmp USING btree (disbursements);

CREATE INDEX ofec_candidate_totals_mv_election_year_idx_tmp
    ON ofec_candidate_totals_mv_tmp USING btree (election_year);

CREATE INDEX ofec_candidate_totals_mv_federal_funds_flag_idx_tmp
    ON ofec_candidate_totals_mv_tmp USING btree (federal_funds_flag);

CREATE INDEX ofec_candidate_totals_mv_has_raised_funds_idx_tmp
    ON ofec_candidate_totals_mv_tmp USING btree (has_raised_funds);

CREATE INDEX ofec_candidate_totals_mv_is_election_idx_tmp
    ON ofec_candidate_totals_mv_tmp USING btree (is_election);


/*
Drop dependent MV's
*/

DROP MATERIALIZED VIEW IF EXISTS ofec_candidate_flag_mv;

DROP MATERIALIZED VIEW IF EXISTS ofec_candidate_totals_with_0s_mv;

/*
Drop old ofec_candidate_totals_mv, rename _tmp MV and indexes
*/

DROP MATERIALIZED VIEW IF EXISTS ofec_candidate_totals_mv;

ALTER MATERIALIZED VIEW IF EXISTS ofec_candidate_totals_mv_tmp RENAME TO ofec_candidate_totals_mv;

SELECT rename_indexes('ofec_candidate_totals_mv');

/*
Recreate ofec_candidate_flag_mv

Supersedes migrations V0026, V0034, V0038, V0059.2, V0059, V0069
*/

CREATE MATERIALIZED VIEW ofec_candidate_flag_mv AS
 SELECT row_number() OVER () AS idx,
    ofec_candidate_history_mv.candidate_id,
    (array_agg(oct.has_raised_funds) @> ARRAY[true]) AS has_raised_funds,
    (array_agg(oct.federal_funds_flag) @> ARRAY[true]) AS federal_funds_flag
   FROM ofec_candidate_history_mv
     LEFT JOIN ofec_candidate_totals_mv oct USING (candidate_id)
  GROUP BY ofec_candidate_history_mv.candidate_id;


ALTER TABLE ofec_candidate_flag_mv OWNER TO fec;
GRANT SELECT ON TABLE ofec_candidate_flag_mv TO fec_read;


CREATE UNIQUE INDEX ofec_candidate_flag_mv_idx_idx
    ON ofec_candidate_flag_mv USING btree (idx);

CREATE INDEX ofec_candidate_flag_mv_candidate_id_idx
    ON ofec_candidate_flag_mv USING btree (candidate_id);

CREATE INDEX ofec_candidate_flag_mv_federal_funds_flag_idx
    ON ofec_candidate_flag_mv USING btree (federal_funds_flag);

CREATE INDEX ofec_candidate_flag_mv_has_raised_funds_idx
    ON ofec_candidate_flag_mv USING btree (has_raised_funds);

/*
Recreate ofec_candidate_totals_with_0s_mv

Supersedes migration V0076
*/


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
    AND cand.two_year_period = totals.cycle;
    --Removed overly restrictive join that was preventing some candidates from appearing

--Permissions-------------------

ALTER TABLE ofec_candidate_totals_with_0s_mv OWNER TO fec;
GRANT SELECT ON TABLE ofec_candidate_totals_with_0s_mv TO fec_read;

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

--MV no longer needed

DROP MATERIALIZED VIEW IF EXISTS ofec_candidate_history_latest_mv
