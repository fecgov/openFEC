/*
This migration file is for #4878

New fields/columns need to be at the end

1 - Modify `ofec_committee_totals_per_cycle_vw` to add:
    `committee_state`
    `treasurer_name`,
    `filing_frequency`,
    `filing_frequency_full`,
    `first_file_date`,

    Replaces V0127

2 - Modify `ofec_totals_house_senate_mv` to add:
    `committee_state`
    `treasurer_name`,
    `filing_frequency`,
    `filing_frequency_full`,
    `first_file_date`,

    Replaces V0211

3 - Modify `ofec_totals_ie_only_mv` to add:
    `committee_state`
    `treasurer_name`,
    `filing_frequency`,
    `filing_frequency_full`,
    `first_file_date`,

    Replaces V0107

*/


-- 1 - Modify `ofec_committee_totals_per_cycle_vw`

CREATE OR REPLACE VIEW public.ofec_committee_totals_per_cycle_vw AS
SELECT
    max(ofec_totals_combined_vw.committee_id::text) AS committee_id,
    max(ofec_totals_combined_vw.committee_name) AS committee_name,
    max(ofec_totals_combined_vw.committee_type) AS committee_type,
    max(ofec_totals_combined_vw.committee_type_full) AS committee_type_full,
    max(ofec_totals_combined_vw.committee_designation) AS committee_designation,
    max(ofec_totals_combined_vw.committee_designation_full) AS committee_designation_full,
    max(ofec_totals_combined_vw.cycle) AS cycle,
    max(ofec_totals_combined_vw.party_full) AS party_full,
    max(ofec_totals_combined_vw.candidate_id) AS candidate_id,
    max(ofec_totals_combined_vw.candidate_name) AS candidate_name,
    max(ofec_totals_combined_vw.last_beginning_image_number) AS last_beginning_image_number,
    max(ofec_totals_combined_vw.last_cash_on_hand_end_period) AS last_cash_on_hand_end_period,
    max(ofec_totals_combined_vw.last_debts_owed_by_committee) AS last_debts_owed_by_committee,
    max(ofec_totals_combined_vw.last_debts_owed_to_committee) AS last_debts_owed_to_committee,
    max(ofec_totals_combined_vw.last_net_contributions) AS last_net_contributions,
    max(ofec_totals_combined_vw.last_net_operating_expenditures) AS last_net_operating_expenditures,
    max(ofec_totals_combined_vw.cash_on_hand_beginning_period) AS cash_on_hand_beginning_period,
    max(ofec_totals_combined_vw.last_report_year) AS last_report_year,
    max(ofec_totals_combined_vw.coverage_start_date) AS coverage_start_date,
    max(ofec_totals_combined_vw.coverage_end_date) AS coverage_end_date,
    max(ofec_totals_combined_vw.sub_id) AS sub_id,
    max(ofec_totals_combined_vw.last_report_type) AS last_report_type,
    max(ofec_totals_combined_vw.last_report_type_full) AS last_report_type_full,
    sum(COALESCE(ofec_totals_combined_vw.all_loans_received, 0.0)) AS all_loans_received,
    sum(COALESCE(ofec_totals_combined_vw.all_other_loans, 0.0)) AS all_other_loans,
    sum(COALESCE(ofec_totals_combined_vw.allocated_federal_election_levin_share, 0.0)) AS allocated_federal_election_levin_share,
    sum(COALESCE(ofec_totals_combined_vw.candidate_contribution, 0.0)) AS candidate_contribution,
    sum(COALESCE(ofec_totals_combined_vw.contribution_refunds, 0.0)) AS contribution_refunds,
    sum(COALESCE(ofec_totals_combined_vw.contributions, 0.0)) AS contributions,
    sum(COALESCE(ofec_totals_combined_vw.coordinated_expenditures_by_party_committee, 0.0)) AS coordinated_expenditures_by_party_committee,
    sum(COALESCE(ofec_totals_combined_vw.disbursements, 0.0)) AS disbursements,
    sum(COALESCE(ofec_totals_combined_vw.exempt_legal_accounting_disbursement, 0.0)) AS exempt_legal_accounting_disbursement,
    sum(COALESCE(ofec_totals_combined_vw.exp_subject_limits, 0.0)) AS exp_subject_limits,
    sum(COALESCE(ofec_totals_combined_vw.exp_prior_years_subject_limits, 0.0)) AS exp_prior_years_subject_limits,
    sum(COALESCE(ofec_totals_combined_vw.fed_candidate_committee_contributions, 0.0)) AS fed_candidate_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.fed_candidate_contribution_refunds, 0.0)) AS fed_candidate_contribution_refunds,
    sum(COALESCE(ofec_totals_combined_vw.fed_disbursements, 0.0)) AS fed_disbursements,
    sum(COALESCE(ofec_totals_combined_vw.fed_election_activity, 0.0)) AS fed_election_activity,
    sum(COALESCE(ofec_totals_combined_vw.fed_receipts, 0.0)) AS fed_receipts,
    sum(COALESCE(ofec_totals_combined_vw.federal_funds, 0.0)) AS federal_funds,
    sum(COALESCE(ofec_totals_combined_vw.federal_funds, 0.0)) > 0 AS federal_funds_flag,
    sum(COALESCE(ofec_totals_combined_vw.fundraising_disbursements, 0.0)) AS fundraising_disbursements,
    sum(COALESCE(ofec_totals_combined_vw.independent_expenditures, 0.0)) AS independent_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.individual_contributions, 0.0)) AS individual_contributions,
    sum(COALESCE(ofec_totals_combined_vw.individual_itemized_contributions, 0.0)) AS individual_itemized_contributions,
    sum(COALESCE(ofec_totals_combined_vw.individual_unitemized_contributions, 0.0)) AS individual_unitemized_contributions,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments_candidate_loans, 0.0)) AS loan_repayments_candidate_loans,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments, 0.0)) AS loan_repayments,
    sum(COALESCE(ofec_totals_combined_vw.loans_received, 0.0)) AS loans_received,
    sum(COALESCE(ofec_totals_combined_vw.loans, 0.0)) AS loans,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments_made, 0.0)) AS loan_repayments_made,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments_received, 0.0)) AS loan_repayments_received,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments_other_loans, 0.0)) AS loan_repayments_other_loans,
    sum(COALESCE(ofec_totals_combined_vw.loans_received_from_candidate, 0.0)) AS loans_received_from_candidate,
    sum(COALESCE(ofec_totals_combined_vw.loans_made, 0.0)) AS loans_made,
    sum(COALESCE(ofec_totals_combined_vw.loans_made_by_candidate, 0.0)) AS loans_made_by_candidate,
    sum(COALESCE(ofec_totals_combined_vw.net_contributions, 0.0)) AS net_contributions,
    sum(COALESCE(ofec_totals_combined_vw.net_operating_expenditures, 0.0)) AS net_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.non_allocated_fed_election_activity, 0.0)) AS non_allocated_fed_election_activity,
    sum(COALESCE(ofec_totals_combined_vw.offsets_to_fundraising_expenditures, 0.0)) AS offsets_to_fundraising_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.offsets_to_legal_accounting, 0.0)) AS offsets_to_legal_accounting,
    sum(COALESCE(ofec_totals_combined_vw.offsets_to_operating_expenditures, 0.0)) AS offsets_to_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.operating_expenditures, 0.0)) AS operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.other_loans_received, 0.0)) AS other_loans_received,
    sum(COALESCE(ofec_totals_combined_vw.other_disbursements, 0.0)) AS other_disbursements,
    sum(COALESCE(ofec_totals_combined_vw.other_fed_operating_expenditures, 0.0)) AS other_fed_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.other_fed_receipts, 0.0)) AS other_fed_receipts,
    sum(COALESCE(ofec_totals_combined_vw.other_receipts, 0.0)) AS other_receipts,
    sum(COALESCE(ofec_totals_combined_vw.other_political_committee_contributions, 0.0)) AS other_political_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.political_party_committee_contributions, 0.0)) AS political_party_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.receipts, 0.0)) AS receipts,
    sum(COALESCE(ofec_totals_combined_vw.refunded_individual_contributions, 0.0)) AS refunded_individual_contributions,
    sum(COALESCE(ofec_totals_combined_vw.refunded_other_political_committee_contributions, 0.0)) AS refunded_other_political_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.refunded_political_party_committee_contributions, 0.0)) AS refunded_political_party_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.refunds_relating_convention_exp, 0.0)) AS refunds_relating_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.repayments_loans_made_by_candidate, 0.0)) AS repayments_loans_made_by_candidate,
    sum(COALESCE(ofec_totals_combined_vw.repayments_other_loans, 0.0)) AS repayments_other_loans,
    sum(COALESCE(ofec_totals_combined_vw.shared_fed_activity, 0.0)) AS shared_fed_activity,
    sum(COALESCE(ofec_totals_combined_vw.shared_fed_activity_nonfed, 0.0)) AS shared_fed_activity_nonfed,
    sum(COALESCE(ofec_totals_combined_vw.shared_fed_operating_expenditures, 0.0)) AS shared_fed_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.shared_nonfed_operating_expenditures, 0.0)) AS shared_nonfed_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.total_exp_subject_limits, 0.0)) AS total_exp_subject_limits,
    sum(COALESCE(ofec_totals_combined_vw.total_offsets_to_operating_expenditures, 0.0)) AS total_offsets_to_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.total_transfers, 0.0)) AS total_transfers,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_nonfed_account, 0.0)) AS transfers_from_nonfed_account,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_nonfed_levin, 0.0)) AS transfers_from_nonfed_levin,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_affiliated_committee, 0.0)) AS transfers_from_affiliated_committee,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_affiliated_party, 0.0)) AS transfers_from_affiliated_party,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_other_authorized_committee, 0.0)) AS transfers_from_other_authorized_committee,
    sum(COALESCE(ofec_totals_combined_vw.transfers_to_affiliated_committee, 0.0)) AS transfers_to_affiliated_committee,
    sum(COALESCE(ofec_totals_combined_vw.transfers_to_other_authorized_committee, 0.0)) AS transfers_to_other_authorized_committee,
    sum(COALESCE(ofec_totals_combined_vw.itemized_refunds_relating_convention_exp, 0.0)) AS itemized_refunds_relating_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_refunds_relating_convention_exp, 0.0)) AS unitemized_refunds_relating_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.other_refunds, 0.0)) AS other_refunds,
    sum(COALESCE(ofec_totals_combined_vw.itemized_other_refunds, 0.0)) AS itemized_other_refunds,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_other_refunds, 0.0)) AS unitemized_other_refunds,
    sum(COALESCE(ofec_totals_combined_vw.itemized_other_income, 0.0)) AS itemized_other_income,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_other_income, 0.0)) AS unitemized_other_income,
    sum(COALESCE(ofec_totals_combined_vw.convention_exp, 0.0)) AS convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.itemized_convention_exp, 0.0)) AS itemized_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_convention_exp, 0.0)) AS unitemized_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.itemized_other_disb, 0.0)) AS itemized_other_disb,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_other_disb, 0.0)) AS unitemized_other_disb,
    max(ofec_totals_combined_vw.committee_state) AS committee_state,
    max(ofec_totals_combined_vw.treasurer_name) AS treasurer_name,
    max(ofec_totals_combined_vw.filing_frequency) AS filing_frequency,
    max(ofec_totals_combined_vw.filing_frequency_full) AS filing_frequency_full,
    min(ofec_totals_combined_vw.first_file_date) AS first_file_date
FROM public.ofec_totals_combined_vw
GROUP BY ofec_totals_combined_vw.committee_id, ofec_totals_combined_vw.cycle;

ALTER TABLE public.ofec_committee_totals_per_cycle_vw OWNER TO fec;

GRANT SELECT ON public.ofec_committee_totals_per_cycle_vw TO fec_read;


-- 2 - Modify `ofec_totals_house_senate_mv`


CREATE MATERIALIZED VIEW public.ofec_totals_house_senate_mv_tmp AS
SELECT f3.candidate_id,
    f3.cycle,
    f3.sub_id AS idx,
    f3.committee_id,
    f3.coverage_start_date,
    f3.coverage_end_date,
    f3.all_other_loans,
    f3.candidate_contribution,
    f3.contribution_refunds,
    f3.contributions,
    f3.disbursements,
    f3.individual_contributions,
    f3.individual_itemized_contributions,
    f3.individual_unitemized_contributions,
    f3.loan_repayments,
    f3.loan_repayments_candidate_loans,
    f3.loan_repayments_other_loans,
    f3.loans,
    f3.loans_made_by_candidate,
    f3.net_contributions,
    f3.net_operating_expenditures,
    f3.offsets_to_operating_expenditures,
    f3.operating_expenditures,
    f3.other_disbursements,
    f3.other_political_committee_contributions,
    f3.other_receipts,
    f3.political_party_committee_contributions,
    f3.receipts,
    f3.refunded_individual_contributions,
    f3.refunded_other_political_committee_contributions,
    f3.refunded_political_party_committee_contributions,
    f3.transfers_from_other_authorized_committee,
    f3.transfers_to_other_authorized_committee,
    f3.last_report_type_full,
    f3.last_beginning_image_number,
    f3.cash_on_hand_beginning_period,
    f3.last_cash_on_hand_end_period,
    f3.last_debts_owed_by_committee,
    f3.last_debts_owed_to_committee,
    f3.last_report_year,
    f3.committee_name,
    f3.committee_type,
    f3.committee_designation,
    f3.committee_type_full,
    f3.committee_designation_full,
    f3.party_full,
    f3.committee_state,
    f3.treasurer_name,
    f3.filing_frequency,
    f3.filing_frequency_full,
    f3.first_file_date
FROM ofec_totals_combined_vw f3
WHERE f3.form_type in ('F3', 'F3P', 'F3X')
AND f3.committee_type in ('H','S')
WITH DATA;

--Permissions
ALTER TABLE public.ofec_totals_house_senate_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_house_senate_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_totals_house_senate_mv_tmp TO fec_read;

--Indexes
CREATE UNIQUE INDEX idx_ofec_totals_house_senate_mv_tmp_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cand_id_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (candidate_id, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cmte_id_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (committee_id, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cmte_type_full_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (committee_type_full, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cycle_cmte_id
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (cycle, committee_id);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cycle_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (cycle, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cmte_dsgn_full_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (committee_designation_full, idx);

-- ---------------
DROP VIEW IF EXISTS public.ofec_totals_house_senate_vw;

CREATE OR REPLACE VIEW public.ofec_totals_house_senate_vw AS
SELECT * FROM public.ofec_totals_house_senate_mv_tmp;
-- ---------------
ALTER TABLE public.ofec_totals_house_senate_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_house_senate_vw TO fec;
GRANT SELECT ON TABLE public.ofec_totals_house_senate_vw TO fec_read;

-- drop old MV
DROP MATERIALIZED VIEW public.ofec_totals_house_senate_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_totals_house_senate_mv_tmp RENAME TO ofec_totals_house_senate_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_idx RENAME TO idx_ofec_totals_house_senate_mv_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cand_id_idx RENAME TO idx_ofec_totals_house_senate_mv_cand_id_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cmte_id_idx RENAME TO idx_ofec_totals_house_senate_mv_cmte_id_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cmte_type_full_idx RENAME TO idx_ofec_totals_house_senate_mv_cmte_tp_full_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cycle_cmte_id RENAME TO idx_ofec_totals_house_senate_mv_cycle_cmte_id;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cycle_idx RENAME TO idx_ofec_totals_house_senate_mv_cycle_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cmte_dsgn_full_idx RENAME TO idx_ofec_totals_house_senate_mv_cmte_dsgn_full_idx;



-- 3 - Modify `ofec_totals_ie_only_mv`

CREATE MATERIALIZED VIEW public.ofec_totals_ie_only_mv_tmp AS
 SELECT ofec_totals_combined_vw.sub_id AS idx,
    ofec_totals_combined_vw.committee_id,
    ofec_totals_combined_vw.cycle,
    ofec_totals_combined_vw.coverage_start_date,
    ofec_totals_combined_vw.coverage_end_date,
    ofec_totals_combined_vw.contributions AS total_independent_contributions,
    ofec_totals_combined_vw.independent_expenditures AS total_independent_expenditures,
    ofec_totals_combined_vw.last_beginning_image_number,
    ofec_totals_combined_vw.committee_name,
    ofec_totals_combined_vw.committee_type,
    ofec_totals_combined_vw.committee_designation,
    ofec_totals_combined_vw.committee_type_full,
    ofec_totals_combined_vw.committee_designation_full,
    ofec_totals_combined_vw.party_full,
    ofec_totals_combined_vw.committee_state,
    ofec_totals_combined_vw.treasurer_name,
    ofec_totals_combined_vw.filing_frequency,
    ofec_totals_combined_vw.filing_frequency_full,
    ofec_totals_combined_vw.first_file_date
   FROM public.ofec_totals_combined_vw
  WHERE ((ofec_totals_combined_vw.form_type)::text = 'F5'::text)
  WITH DATA;

-- Permissions

ALTER TABLE public.ofec_totals_ie_only_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_ie_only_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_totals_ie_only_mv_tmp TO fec_read;

-- Indexes

CREATE UNIQUE INDEX ofec_totals_ie_only_mv_tmp_idx_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (idx);

CREATE INDEX ofec_totals_ie_only_mv_tmp_committee_designation_full_idx_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (committee_designation_full, idx);

CREATE INDEX ofec_totals_ie_only_mv_tmp_committee_id_idx_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (committee_id, idx);

CREATE INDEX ofec_totals_ie_only_mv_tmp_committee_type_full_idx_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (committee_type_full, idx);

CREATE INDEX ofec_totals_ie_only_mv_tmp_cycle_committee_id_idx1
ON public.ofec_totals_ie_only_mv_tmp USING btree (cycle, committee_id);

CREATE INDEX ofec_totals_ie_only_mv_tmp_cycle_idx_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (cycle, idx);

-- Recreate view

CREATE OR REPLACE VIEW public.ofec_totals_ie_only_vw AS
SELECT * FROM public.ofec_totals_ie_only_mv_tmp;

ALTER VIEW ofec_totals_ie_only_vw OWNER TO fec;
GRANT ALL ON TABLE ofec_totals_ie_only_vw TO fec;
GRANT SELECT ON ofec_totals_ie_only_vw TO fec_read;


-- Drop old MV
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_ie_only_mv;

-- Rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_totals_ie_only_mv_tmp
RENAME TO ofec_totals_ie_only_mv;

-- Rename indexes

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_idx
RENAME TO idx_ofec_totals_house_senate_mv_idx;

ALTER INDEX IF EXISTS ofec_totals_ie_only_mv_tmp_idx_idx
RENAME TO ofec_totals_ie_only_mv_idx_idx ;

ALTER INDEX IF EXISTS ofec_totals_ie_only_mv_tmp_committee_designation_full_idx_idx
RENAME TO ofec_totals_ie_only_mv_committee_designation_full_idx_idx;

ALTER INDEX IF EXISTS ofec_totals_ie_only_mv_tmp_committee_id_idx_idx
RENAME TO ofec_totals_ie_only_mv_committee_id_idx_idx;

ALTER INDEX IF EXISTS ofec_totals_ie_only_mv_tmp_committee_type_full_idx_idx
RENAME TO ofec_totals_ie_only_mv_committee_type_full_idx_idx;

ALTER INDEX IF EXISTS ofec_totals_ie_only_mv_tmp_cycle_committee_id_idx1
RENAME TO ofec_totals_ie_only_mv_cycle_committee_id_idx1;

ALTER INDEX IF EXISTS ofec_totals_ie_only_mv_tmp_cycle_idx_idx
RENAME TO ofec_totals_ie_only_mv_cycle_idx_idx;
