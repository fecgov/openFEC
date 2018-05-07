--
-- Name: ofec_entity_chart_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_entity_chart_mv AS
 WITH cand_totals AS (
         SELECT 'candidate'::text AS type,
            date_part('month'::text, ofec_totals_house_senate_mv.coverage_end_date) AS month,
            date_part('year'::text, ofec_totals_house_senate_mv.coverage_end_date) AS year,
            sum((COALESCE(ofec_totals_house_senate_mv.receipts, (0)::numeric) - ((((COALESCE(ofec_totals_house_senate_mv.political_party_committee_contributions, (0)::numeric) + COALESCE(ofec_totals_house_senate_mv.other_political_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.offsets_to_operating_expenditures, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.loan_repayments, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.contribution_refunds, (0)::numeric)))) AS candidate_adjusted_total_receipts,
            sum((COALESCE(ofec_totals_house_senate_mv.disbursements, (0)::numeric) - (((COALESCE(ofec_totals_house_senate_mv.transfers_to_other_authorized_committee, (0)::numeric) + COALESCE(ofec_totals_house_senate_mv.loan_repayments, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.other_disbursements, (0)::numeric)))) AS candidate_adjusted_total_disbursements
           FROM ofec_totals_house_senate_mv
          WHERE (ofec_totals_house_senate_mv.cycle >= 2008)
          GROUP BY (date_part('month'::text, ofec_totals_house_senate_mv.coverage_end_date)), (date_part('year'::text, ofec_totals_house_senate_mv.coverage_end_date))
        ), pac_totals AS (
         SELECT 'pac'::text AS type,
            date_part('month'::text, ofec_totals_pacs_mv.coverage_end_date) AS month,
            date_part('year'::text, ofec_totals_pacs_mv.coverage_end_date) AS year,
            sum((COALESCE(ofec_totals_pacs_mv.receipts, (0)::numeric) - ((((((COALESCE(ofec_totals_pacs_mv.political_party_committee_contributions, (0)::numeric) + COALESCE(ofec_totals_pacs_mv.other_political_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.offsets_to_operating_expenditures, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.fed_candidate_contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.transfers_from_nonfed_account, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.loan_repayments_other_loans, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.contribution_refunds, (0)::numeric)))) AS pac_adjusted_total_receipts,
            sum((COALESCE(ofec_totals_pacs_mv.disbursements, (0)::numeric) - (((((COALESCE(ofec_totals_pacs_mv.shared_nonfed_operating_expenditures, (0)::numeric) + COALESCE(ofec_totals_pacs_mv.transfers_to_affiliated_committee, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.fed_candidate_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.loan_repayments_other_loans, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.other_disbursements, (0)::numeric)))) AS pac_adjusted_total_disbursements
           FROM ofec_totals_pacs_mv
          WHERE ((ofec_totals_pacs_mv.committee_type = ANY (ARRAY['N'::text, 'Q'::text, 'O'::text, 'V'::text, 'W'::text])) AND ((ofec_totals_pacs_mv.designation)::text <> 'J'::text) AND (ofec_totals_pacs_mv.cycle >= 2008))
          GROUP BY (date_part('month'::text, ofec_totals_pacs_mv.coverage_end_date)), (date_part('year'::text, ofec_totals_pacs_mv.coverage_end_date))
        ), party_totals AS (
         SELECT 'party'::text AS type,
            date_part('month'::text, ofec_totals_parties_mv.coverage_end_date) AS month,
            date_part('year'::text, ofec_totals_parties_mv.coverage_end_date) AS year,
            sum((COALESCE(ofec_totals_parties_mv.receipts, (0)::numeric) - ((((((COALESCE(ofec_totals_parties_mv.political_party_committee_contributions, (0)::numeric) + COALESCE(ofec_totals_parties_mv.other_political_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.offsets_to_operating_expenditures, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.fed_candidate_contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.transfers_from_nonfed_account, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.loan_repayments_other_loans, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.contribution_refunds, (0)::numeric)))) AS party_adjusted_total_receipts,
            sum((COALESCE(ofec_totals_parties_mv.disbursements, (0)::numeric) - (((((COALESCE(ofec_totals_parties_mv.shared_nonfed_operating_expenditures, (0)::numeric) + COALESCE(ofec_totals_parties_mv.transfers_to_other_authorized_committee, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.fed_candidate_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.loan_repayments_other_loans, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.other_disbursements, (0)::numeric)))) AS party_adjusted_total_disbursements
           FROM ofec_totals_parties_mv
          WHERE ((ofec_totals_parties_mv.committee_type = ANY (ARRAY['X'::text, 'Y'::text])) AND ((ofec_totals_parties_mv.designation)::text <> 'J'::text) AND ((ofec_totals_parties_mv.committee_id)::text <> ALL ((ARRAY['C00578419'::character varying, 'C00485110'::character varying, 'C00422048'::character varying, 'C00567057'::character varying, 'C00483586'::character varying, 'C00431791'::character varying, 'C00571133'::character varying, 'C00500405'::character varying, 'C00435560'::character varying, 'C00572958'::character varying, 'C00493254'::character varying, 'C00496570'::character varying, 'C00431593'::character varying])::text[])) AND (ofec_totals_parties_mv.cycle >= 2008))
          GROUP BY (date_part('month'::text, ofec_totals_parties_mv.coverage_end_date)), (date_part('year'::text, ofec_totals_parties_mv.coverage_end_date))
        ), combined AS (
         SELECT month,
            year,
            ((year)::numeric + ((year)::numeric % (2)::numeric)) AS cycle,
                CASE
                    WHEN (max(cand_totals.candidate_adjusted_total_receipts) IS NULL) THEN (0)::numeric
                    ELSE max(cand_totals.candidate_adjusted_total_receipts)
                END AS candidate_receipts,
                CASE
                    WHEN (max(cand_totals.candidate_adjusted_total_disbursements) IS NULL) THEN (0)::numeric
                    ELSE max(cand_totals.candidate_adjusted_total_disbursements)
                END AS canidate_disbursements,
                CASE
                    WHEN (max(pac_totals.pac_adjusted_total_receipts) IS NULL) THEN (0)::numeric
                    ELSE max(pac_totals.pac_adjusted_total_receipts)
                END AS pac_receipts,
                CASE
                    WHEN (max(pac_totals.pac_adjusted_total_disbursements) IS NULL) THEN (0)::numeric
                    ELSE max(pac_totals.pac_adjusted_total_disbursements)
                END AS pac_disbursements,
                CASE
                    WHEN (max(party_totals.party_adjusted_total_receipts) IS NULL) THEN (0)::numeric
                    ELSE max(party_totals.party_adjusted_total_receipts)
                END AS party_receipts,
                CASE
                    WHEN (max(party_totals.party_adjusted_total_disbursements) IS NULL) THEN (0)::numeric
                    ELSE max(party_totals.party_adjusted_total_disbursements)
                END AS party_disbursements
           FROM ((cand_totals
             FULL JOIN pac_totals USING (month, year))
             FULL JOIN party_totals USING (month, year))
          GROUP BY month, year
          ORDER BY year, month
        )
 SELECT row_number() OVER () AS idx,
    combined.month,
    combined.year,
    combined.cycle,
    last_day_of_month(make_timestamp((combined.year)::integer, (combined.month)::integer, 1, 0, 0, (0.0)::double precision)) AS date,
    sum(combined.candidate_receipts) OVER (PARTITION BY combined.cycle ORDER BY combined.year, combined.month) AS cumulative_candidate_receipts,
    combined.candidate_receipts,
    sum(combined.canidate_disbursements) OVER (PARTITION BY combined.cycle ORDER BY combined.year, combined.month) AS cumulative_candidate_disbursements,
    combined.canidate_disbursements,
    sum(combined.pac_receipts) OVER (PARTITION BY combined.cycle ORDER BY combined.year, combined.month) AS cumulative_pac_receipts,
    combined.pac_receipts,
    sum(combined.pac_disbursements) OVER (PARTITION BY combined.cycle ORDER BY combined.year, combined.month) AS cumulative_pac_disbursements,
    combined.pac_disbursements,
    sum(combined.party_receipts) OVER (PARTITION BY combined.cycle ORDER BY combined.year, combined.month) AS cumulative_party_receipts,
    combined.party_receipts,
    sum(combined.party_disbursements) OVER (PARTITION BY combined.cycle ORDER BY combined.year, combined.month) AS cumulative_party_disbursements,
    combined.party_disbursements
   FROM combined
  WHERE (combined.cycle >= (2008)::numeric)
  WITH DATA;


ALTER TABLE ofec_entity_chart_mv OWNER TO fec;

--
-- Name: ofec_entity_chart_mv_tmp_cycle_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_entity_chart_mv_tmp_cycle_idx1 ON ofec_entity_chart_mv USING btree (cycle);

--
-- Name: ofec_entity_chart_mv_tmp_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_entity_chart_mv_tmp_idx_idx1 ON ofec_entity_chart_mv USING btree (idx);

--
-- Name: ofec_entity_chart_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_entity_chart_mv TO fec_read;
