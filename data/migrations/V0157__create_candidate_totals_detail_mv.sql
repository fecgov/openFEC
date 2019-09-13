/* This materialized view has all the totals of all candidates,
  election_full = false: totals for fec_cycle.
  election_full = true:  totals for candidate_election_year
*/

--- subquery linkage is created to handle case that candidates run more than one elections in one fec_cycle. Example: H0PA12181, H8NC09123
--- subquery cand_total_per_cycle calculates totals per candidate per fec_cycle ( election_full = false ). Candidate with multiple committees will be aggregated here
--- subquery cand_ending_total_per_election calculates 5 ending totals per candidate per candidate_election_year
--- subquery cand_total_per_election calculates totals per candidate per candidate_election_year ( election_full = true )

-- View: public.ofec_candidate_totals_detail_mv

-- DROP MATERIALIZED VIEW public.ofec_candidate_totals_detail_mv;

CREATE MATERIALIZED VIEW public.ofec_candidate_totals_detail_mv AS
WITH linkage AS (
        SELECT DISTINCT ofec_cand_cmte_linkage_vw.cand_id,
            ofec_cand_cmte_linkage_vw.fec_election_yr,
            ofec_cand_cmte_linkage_vw.cmte_id,
            ofec_cand_cmte_linkage_vw.cmte_dsgn,
            ofec_cand_cmte_linkage_vw.election_yr_to_be_included
           FROM ofec_cand_cmte_linkage_vw
          WHERE ofec_cand_cmte_linkage_vw.cmte_dsgn IN ('P', 'A')
    ), cand_total_per_cycle AS (
        SELECT ccl.cand_id,
            ccl.fec_election_yr,
            max(ccl.election_yr_to_be_included) AS election_year,
            min(ct.coverage_start_date) AS coverage_start_date,
            sum(ct.candidate_contribution) AS candidate_contribution,
            sum(ct.contribution_refunds) AS contribution_refunds,
            sum(ct.contributions) AS contributions,
            sum(ct.disbursements) AS disbursements,
            sum(ct.exempt_legal_accounting_disbursement) AS exempt_legal_accounting_disbursement,
            sum(ct.federal_funds) AS federal_funds,
            sum(ct.federal_funds) > 0 AS federal_funds_flag,
            sum(ct.fundraising_disbursements) AS fundraising_disbursements,
            sum(ct.individual_contributions) AS individual_contributions,
            sum(ct.individual_unitemized_contributions) AS individual_unitemized_contributions,
            sum(ct.individual_itemized_contributions) AS individual_itemized_contributions,
            sum(ct.loans_received) AS loans_received,
            sum(ct.loans_received_from_candidate) AS loans_received_from_candidate,
            sum(ct.loan_repayments_made) AS loan_repayments_made,
            sum(ct.offsets_to_fundraising_expenditures) AS offsets_to_fundraising_expenditures,
            sum(ct.offsets_to_legal_accounting) AS offsets_to_legal_accounting,
            sum(ct.offsets_to_operating_expenditures) AS offsets_to_operating_expenditures,
            sum(ct.total_offsets_to_operating_expenditures) AS total_offsets_to_operating_expenditures,
            sum(ct.operating_expenditures) AS operating_expenditures,
            sum(ct.other_disbursements) AS other_disbursements,
            sum(ct.other_loans_received) AS other_loans_received,
            sum(ct.other_political_committee_contributions) AS other_political_committee_contributions,
            sum(ct.other_receipts) AS other_receipts,
            sum(ct.political_party_committee_contributions) AS political_party_committee_contributions,
            sum(ct.receipts) AS receipts,
            sum(ct.refunded_individual_contributions) AS refunded_individual_contributions,
            sum(ct.refunded_other_political_committee_contributions) AS refunded_other_political_committee_contributions,
            sum(ct.refunded_political_party_committee_contributions) AS refunded_political_party_committee_contributions,
            sum(ct.repayments_loans_made_by_candidate) AS repayments_loans_made_by_candidate,
            sum(ct.repayments_other_loans) AS repayments_other_loans,
            sum(ct.transfers_from_affiliated_committee) AS transfers_from_affiliated_committee,
            sum(ct.transfers_to_other_authorized_committee) AS transfers_to_other_authorized_committee,
            sum(ct.net_operating_expenditures) AS net_operating_expenditures,
            sum(ct.net_contributions) AS net_contributions,
            max(ct.coverage_end_date) AS coverage_end_date,
            max(trans_date.transaction_coverage_date) AS transaction_coverage_date,
            max(ct.last_report_type_full) AS last_report_type_full,
            min(ct.last_beginning_image_number) AS last_beginning_image_number,
            sum(ct.last_cash_on_hand_end_period) AS last_cash_on_hand_end_period,
            sum(ct.last_debts_owed_by_committee) AS last_debts_owed_by_committee,
            sum(ct.last_debts_owed_to_committee) AS last_debts_owed_to_committee,
            max(ct.last_report_year) AS last_report_year,
            sum(ct.last_net_operating_expenditures) AS last_net_operating_expenditures,
            sum(ct.last_net_contributions) AS last_net_contributions
        FROM linkage ccl
            LEFT JOIN ofec_committee_totals_per_cycle_vw ct ON ccl.cmte_id = ct.committee_id AND ccl.fec_election_yr = ct.cycle
            LEFT JOIN ofec_agg_coverage_date_vw trans_date ON ccl.cmte_id = trans_date.committee_id AND ccl.fec_election_yr = trans_date.fec_election_yr
        GROUP BY ccl.cand_id, ccl.fec_election_yr
    ), cand_ending_total_per_election AS (
        SELECT DISTINCT cand_total_per_cycle.cand_id,
            cand_total_per_cycle.election_year,
            first_value(cand_total_per_cycle.last_cash_on_hand_end_period) OVER (PARTITION BY cand_total_per_cycle.cand_id, cand_total_per_cycle.election_year ORDER BY cand_total_per_cycle.fec_election_yr DESC NULLS LAST) AS last_cash_on_hand_end_period,
            first_value(cand_total_per_cycle.last_debts_owed_by_committee) OVER (PARTITION BY cand_total_per_cycle.cand_id, cand_total_per_cycle.election_year ORDER BY cand_total_per_cycle.fec_election_yr DESC NULLS LAST) AS last_debts_owed_by_committee,
            first_value(cand_total_per_cycle.last_debts_owed_to_committee) OVER (PARTITION BY cand_total_per_cycle.cand_id, cand_total_per_cycle.election_year ORDER BY cand_total_per_cycle.fec_election_yr DESC NULLS LAST) AS last_debts_owed_to_committee,
            first_value(cand_total_per_cycle.last_net_operating_expenditures) OVER (PARTITION BY cand_total_per_cycle.cand_id, cand_total_per_cycle.election_year ORDER BY cand_total_per_cycle.fec_election_yr DESC NULLS LAST) AS last_net_operating_expenditures,
            first_value(cand_total_per_cycle.last_net_contributions) OVER (PARTITION BY cand_total_per_cycle.cand_id, cand_total_per_cycle.election_year ORDER BY cand_total_per_cycle.fec_election_yr DESC NULLS LAST) AS last_net_contributions
        FROM cand_total_per_cycle
        WHERE cand_total_per_cycle.election_year IS NOT NULL
    ), cand_total_per_election AS (
        SELECT cand_total_per_cycle.cand_id,
            cand_total_per_cycle.election_year,
            min(cand_total_per_cycle.coverage_start_date) AS coverage_start_date,
            sum(cand_total_per_cycle.candidate_contribution) AS candidate_contribution,
            sum(cand_total_per_cycle.contribution_refunds) AS contribution_refunds,
            sum(cand_total_per_cycle.contributions) AS contributions,
            sum(cand_total_per_cycle.disbursements) AS disbursements,
            sum(cand_total_per_cycle.exempt_legal_accounting_disbursement) AS exempt_legal_accounting_disbursement,
            sum(cand_total_per_cycle.federal_funds) AS federal_funds,
            sum(cand_total_per_cycle.federal_funds) > 0 AS federal_funds_flag,
            sum(cand_total_per_cycle.fundraising_disbursements) AS fundraising_disbursements,
            sum(cand_total_per_cycle.individual_contributions) AS individual_contributions,
            sum(cand_total_per_cycle.individual_unitemized_contributions) AS individual_unitemized_contributions,
            sum(cand_total_per_cycle.individual_itemized_contributions) AS individual_itemized_contributions,
            sum(cand_total_per_cycle.loans_received) AS loans_received,
            sum(cand_total_per_cycle.loans_received_from_candidate) AS loans_received_from_candidate,
            sum(cand_total_per_cycle.loan_repayments_made) AS loan_repayments_made,
            sum(cand_total_per_cycle.offsets_to_fundraising_expenditures) AS offsets_to_fundraising_expenditures,
            sum(cand_total_per_cycle.offsets_to_legal_accounting) AS offsets_to_legal_accounting,
            sum(cand_total_per_cycle.offsets_to_operating_expenditures) AS offsets_to_operating_expenditures,
            sum(cand_total_per_cycle.total_offsets_to_operating_expenditures) AS total_offsets_to_operating_expenditures,
            sum(cand_total_per_cycle.operating_expenditures) AS operating_expenditures,
            sum(cand_total_per_cycle.other_disbursements) AS other_disbursements,
            sum(cand_total_per_cycle.other_loans_received) AS other_loans_received,
            sum(cand_total_per_cycle.other_political_committee_contributions) AS other_political_committee_contributions,
            sum(cand_total_per_cycle.other_receipts) AS other_receipts,
            sum(cand_total_per_cycle.political_party_committee_contributions) AS political_party_committee_contributions,
            sum(cand_total_per_cycle.receipts) AS receipts,
            sum(cand_total_per_cycle.refunded_individual_contributions) AS refunded_individual_contributions,
            sum(cand_total_per_cycle.refunded_other_political_committee_contributions) AS refunded_other_political_committee_contributions,
            sum(cand_total_per_cycle.refunded_political_party_committee_contributions) AS refunded_political_party_committee_contributions,
            sum(cand_total_per_cycle.repayments_loans_made_by_candidate) AS repayments_loans_made_by_candidate,
            sum(cand_total_per_cycle.repayments_other_loans) AS repayments_other_loans,
            sum(cand_total_per_cycle.transfers_from_affiliated_committee) AS transfers_from_affiliated_committee,
            sum(cand_total_per_cycle.transfers_to_other_authorized_committee) AS transfers_to_other_authorized_committee,
            sum(cand_total_per_cycle.net_operating_expenditures) AS net_operating_expenditures,
            sum(cand_total_per_cycle.net_contributions) AS net_contributions,
            max(cand_total_per_cycle.coverage_end_date) AS coverage_end_date,
            max(cand_total_per_cycle.transaction_coverage_date) AS transaction_coverage_date,
            max(cand_total_per_cycle.last_report_type_full) AS last_report_type_full,
            min(cand_total_per_cycle.last_beginning_image_number) AS last_beginning_image_number,
            max(cand_ending_total_per_election.last_cash_on_hand_end_period) AS last_cash_on_hand_end_period,
            max(cand_ending_total_per_election.last_debts_owed_by_committee) AS last_debts_owed_by_committee,
            max(cand_ending_total_per_election.last_debts_owed_to_committee) AS last_debts_owed_to_committee,
            max(cand_total_per_cycle.last_report_year) AS last_report_year,
            max(cand_ending_total_per_election.last_net_operating_expenditures) AS last_net_operating_expenditures,
            max(cand_ending_total_per_election.last_net_contributions) AS last_net_contributions
        FROM cand_total_per_cycle
            JOIN cand_ending_total_per_election
            ON cand_total_per_cycle.cand_id = cand_ending_total_per_election.cand_id AND cand_total_per_cycle.election_year = cand_ending_total_per_election.election_year
        GROUP BY cand_total_per_cycle.cand_id, cand_total_per_cycle.election_year
        )
 SELECT cand_total_per_cycle.cand_id AS candidate_id,
    cand_total_per_cycle.fec_election_yr AS cycle,
    cand_total_per_cycle.election_year AS candidate_election_year,
    cand_total_per_cycle.coverage_start_date,
    cand_total_per_cycle.candidate_contribution,
    cand_total_per_cycle.contribution_refunds,
    cand_total_per_cycle.contributions,
    cand_total_per_cycle.disbursements,
    cand_total_per_cycle.exempt_legal_accounting_disbursement,
    cand_total_per_cycle.federal_funds,
    cand_total_per_cycle.federal_funds > 0 AS federal_funds_flag,
    cand_total_per_cycle.fundraising_disbursements,
    cand_total_per_cycle.individual_contributions,
    cand_total_per_cycle.individual_unitemized_contributions,
    cand_total_per_cycle.individual_itemized_contributions,
    cand_total_per_cycle.loans_received,
    cand_total_per_cycle.loans_received_from_candidate,
    cand_total_per_cycle.loan_repayments_made,
    cand_total_per_cycle.offsets_to_fundraising_expenditures,
    cand_total_per_cycle.offsets_to_legal_accounting,
    cand_total_per_cycle.offsets_to_operating_expenditures,
    cand_total_per_cycle.total_offsets_to_operating_expenditures,
    cand_total_per_cycle.operating_expenditures,
    cand_total_per_cycle.other_disbursements,
    cand_total_per_cycle.other_loans_received,
    cand_total_per_cycle.other_political_committee_contributions,
    cand_total_per_cycle.other_receipts,
    cand_total_per_cycle.political_party_committee_contributions,
    cand_total_per_cycle.receipts,
    cand_total_per_cycle.refunded_individual_contributions,
    cand_total_per_cycle.refunded_other_political_committee_contributions,
    cand_total_per_cycle.refunded_political_party_committee_contributions,
    cand_total_per_cycle.repayments_loans_made_by_candidate,
    cand_total_per_cycle.repayments_other_loans,
    cand_total_per_cycle.transfers_from_affiliated_committee,
    cand_total_per_cycle.transfers_to_other_authorized_committee,
    cand_total_per_cycle.net_operating_expenditures,
    cand_total_per_cycle.net_contributions,
    false AS election_full,
    cand_total_per_cycle.coverage_end_date,
    cand_total_per_cycle.transaction_coverage_date,
    cand_total_per_cycle.last_report_type_full,
    cand_total_per_cycle.last_beginning_image_number,
    cand_total_per_cycle.last_cash_on_hand_end_period,
    cand_total_per_cycle.last_debts_owed_by_committee,
    cand_total_per_cycle.last_debts_owed_to_committee,
    cand_total_per_cycle.last_report_year,
    cand_total_per_cycle.last_net_operating_expenditures,
    cand_total_per_cycle.last_net_contributions
   FROM cand_total_per_cycle
UNION ALL
 SELECT cand_total_per_election.cand_id AS candidate_id,
    NULL AS cycle,
    cand_total_per_election.election_year AS candidate_election_year,
    cand_total_per_election.coverage_start_date,
    cand_total_per_election.candidate_contribution,
    cand_total_per_election.contribution_refunds,
    cand_total_per_election.contributions,
    cand_total_per_election.disbursements,
    cand_total_per_election.exempt_legal_accounting_disbursement,
    cand_total_per_election.federal_funds,
    cand_total_per_election.federal_funds > 0 AS federal_funds_flag,
    cand_total_per_election.fundraising_disbursements,
    cand_total_per_election.individual_contributions,
    cand_total_per_election.individual_unitemized_contributions,
    cand_total_per_election.individual_itemized_contributions,
    cand_total_per_election.loans_received,
    cand_total_per_election.loans_received_from_candidate,
    cand_total_per_election.loan_repayments_made,
    cand_total_per_election.offsets_to_fundraising_expenditures,
    cand_total_per_election.offsets_to_legal_accounting,
    cand_total_per_election.offsets_to_operating_expenditures,
    cand_total_per_election.total_offsets_to_operating_expenditures,
    cand_total_per_election.operating_expenditures,
    cand_total_per_election.other_disbursements,
    cand_total_per_election.other_loans_received,
    cand_total_per_election.other_political_committee_contributions,
    cand_total_per_election.other_receipts,
    cand_total_per_election.political_party_committee_contributions,
    cand_total_per_election.receipts,
    cand_total_per_election.refunded_individual_contributions,
    cand_total_per_election.refunded_other_political_committee_contributions,
    cand_total_per_election.refunded_political_party_committee_contributions,
    cand_total_per_election.repayments_loans_made_by_candidate,
    cand_total_per_election.repayments_other_loans,
    cand_total_per_election.transfers_from_affiliated_committee,
    cand_total_per_election.transfers_to_other_authorized_committee,
    cand_total_per_election.net_operating_expenditures,
    cand_total_per_election.net_contributions,
    true AS election_full,
    cand_total_per_election.coverage_end_date,
    cand_total_per_election.transaction_coverage_date,
    cand_total_per_election.last_report_type_full,
    cand_total_per_election.last_beginning_image_number,
    cand_total_per_election.last_cash_on_hand_end_period,
    cand_total_per_election.last_debts_owed_by_committee,
    cand_total_per_election.last_debts_owed_to_committee,
    cand_total_per_election.last_report_year,
    cand_total_per_election.last_net_operating_expenditures,
    cand_total_per_election.last_net_contributions
   FROM cand_total_per_election
WITH DATA;

ALTER TABLE public.ofec_candidate_totals_detail_mv OWNER TO fec;
    

GRANT ALL ON TABLE public.ofec_candidate_totals_detail_mv TO fec;
GRANT SELECT ON TABLE public.ofec_candidate_totals_detail_mv TO fec_read;

--add indexes
CREATE UNIQUE INDEX idx_ofec_candidate_totals_detail_mv_cand_id_cycle_elect_full
    ON public.ofec_candidate_totals_detail_mv USING btree
    (candidate_id, cycle, election_full);
CREATE INDEX idx_ofec_candidate_totals_detail_mv_cand_id
    ON public.ofec_candidate_totals_detail_mv USING btree
    (candidate_id);
CREATE INDEX idx_ofec_candidate_totals_detail_mv_cycle
    ON public.ofec_candidate_totals_detail_mv USING btree
    (cycle);
CREATE INDEX idx_ofec_candidate_totals_detail_mv_disbursements
    ON public.ofec_candidate_totals_detail_mv USING btree
    (disbursements);
CREATE INDEX idx_ofec_candidate_totals_detail_mv_cand_election_year
    ON public.ofec_candidate_totals_detail_mv USING btree
    (candidate_election_year);
CREATE INDEX idx_ofec_candidate_totals_detail_mv_federal_funds_flag
    ON public.ofec_candidate_totals_detail_mv USING btree
    (federal_funds_flag);
CREATE INDEX idx_ofec_candidate_totals_detail_mv_receipts
    ON public.ofec_candidate_totals_detail_mv USING btree
    (receipts);

-- create view
CREATE OR REPLACE VIEW public.ofec_candidate_totals_detail_vw AS 
  SELECT * FROM public.ofec_candidate_totals_detail_mv;

ALTER TABLE public.ofec_candidate_totals_detail_vw OWNER TO fec;
    

GRANT ALL ON TABLE public.ofec_candidate_totals_detail_vw TO fec;
GRANT SELECT ON TABLE public.ofec_candidate_totals_detail_vw TO fec_read;
