/*
This migration file continues for #6624
1 - Modify ofec_totals_house_senate_mv and ofec_totals_house_senate_vw to summarize financial data 
    when a committee submits mixed form types within the same cycle.
    
    Replaces V0237
*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_house_senate_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_totals_house_senate_mv_tmp AS
SELECT max(f3.candidate_id) AS candidate_id,
    f3.cycle,
    max(f3.sub_id) AS idx,
    f3.committee_id,
    max(f3.coverage_start_date) AS coverage_start_date,
    max(f3.coverage_end_date) AS coverage_end_date,
    sum(f3.all_other_loans) AS all_other_loans,
    sum(f3.candidate_contribution) AS candidate_contribution,
    sum(f3.contribution_refunds) AS contribution_refunds,
    sum(f3.contributions) AS contributions,
    sum(f3.disbursements) AS disbursements,
    sum(f3.individual_contributions) AS individual_contributions,
    sum(f3.individual_itemized_contributions) AS individual_itemized_contributions,
    sum(f3.individual_unitemized_contributions) AS individual_unitemized_contributions,
    sum(f3.loan_repayments) AS loan_repayments,
    sum(f3.loan_repayments_candidate_loans) AS loan_repayments_candidate_loans,
    sum(f3.loan_repayments_other_loans) AS loan_repayments_other_loans,
    sum(f3.loans) AS loans,
    sum(f3.loans_made_by_candidate) AS loans_made_by_candidate,
    sum(f3.net_contributions) AS net_contributions,
    sum(f3.net_operating_expenditures) AS net_operating_expenditures,
    sum(f3.offsets_to_operating_expenditures) AS offsets_to_operating_expenditures,
    sum(f3.operating_expenditures) AS operating_expenditures,
    sum(f3.other_disbursements) AS other_disbursements,
    sum(f3.other_political_committee_contributions) AS other_political_committee_contributions,
    sum(f3.other_receipts) AS other_receipts,
    sum(f3.political_party_committee_contributions) AS political_party_committee_contributions,
    sum(f3.receipts) AS receipts,
    sum(f3.refunded_individual_contributions) AS refunded_individual_contributions,
    sum(f3.refunded_other_political_committee_contributions) AS refunded_other_political_committee_contributions,
    sum(f3.refunded_political_party_committee_contributions) AS refunded_political_party_committee_contributions,
    sum(f3.transfers_from_other_authorized_committee) AS transfers_from_other_authorized_committee,
    sum(f3.transfers_to_other_authorized_committee) AS transfers_to_other_authorized_committee,
    max(f3.last_report_type_full) AS last_report_type_full,
    max(f3.last_beginning_image_number) AS last_beginning_image_number,
    max(f3.cash_on_hand_beginning_period) AS cash_on_hand_beginning_period,
    max(f3.last_cash_on_hand_end_period) AS last_cash_on_hand_end_period,
    max(f3.last_debts_owed_by_committee) AS last_debts_owed_by_committee,
    max(f3.last_debts_owed_to_committee) AS last_debts_owed_to_committee,
    max(f3.last_report_year) AS last_report_year,
    max(f3.committee_name) AS committee_name,
    max(f3.committee_type) AS committee_type,
    max(f3.committee_designation) AS committee_designation,
    max(f3.committee_type_full) AS committee_type_full,
    max(f3.committee_designation_full) AS committee_designation_full,
    max(f3.party_full) AS party_full,
    max(f3.committee_state) AS committee_state,
    max(f3.treasurer_name) AS treasurer_name,
    max(f3.treasurer_text) AS treasurer_text,
    max(f3.filing_frequency) AS filing_frequency,
    max(f3.filing_frequency_full) AS filing_frequency_full,
    max(f3.first_file_date) AS first_file_date,
    max(f3.organization_type) AS organization_type,
    max(f3.organization_type_full) AS organization_type_full,
    max(f3.first_f1_date) AS first_f1_date
  FROM ofec_totals_combined_vw f3
  WHERE f3.form_type in ('F3', 'F3P', 'F3X')
  AND f3.committee_type in ('H','S')
  GROUP BY f3.committee_id, f3.cycle
  WITH DATA;


--Permissions
ALTER TABLE public.ofec_totals_house_senate_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_house_senate_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_totals_house_senate_mv_tmp TO fec_read;

--Indexes
CREATE UNIQUE INDEX idx_ofec_totals_house_senate_mv_tmp_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree (idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cand_id_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (candidate_id, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cmte_id_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (committee_id, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cmte_tp_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (committee_type, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cycle_cmte_id
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (cycle, committee_id);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cycle_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (cycle, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cmte_dsgn_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (committee_designation, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_treas_text_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING gin (treasurer_text);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_org_tp_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (organization_type, idx);

---- Added w/V0236
CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_first_f1_date_idx
    ON public.ofec_totals_house_senate_mv_tmp USING btree
    (first_f1_date, idx);

-----------------
CREATE OR REPLACE VIEW public.ofec_totals_house_senate_vw AS
SELECT * FROM public.ofec_totals_house_senate_mv_tmp;
-----------------
ALTER TABLE public.ofec_totals_house_senate_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_house_senate_vw TO fec;
GRANT SELECT ON TABLE public.ofec_totals_house_senate_vw TO fec_read;

-- drop old MV
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_house_senate_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_totals_house_senate_mv_tmp RENAME TO ofec_totals_house_senate_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_idx
  RENAME TO idx_ofec_totals_house_senate_mv_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cand_id_idx
  RENAME TO idx_ofec_totals_house_senate_mv_cand_id_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cmte_id_idx
  RENAME TO idx_ofec_totals_house_senate_mv_cmte_id_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cmte_tp_idx
  RENAME TO idx_ofec_totals_house_senate_mv_cmte_tp_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cycle_cmte_id
  RENAME TO idx_ofec_totals_house_senate_mv_cycle_cmte_id;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cycle_idx
  RENAME TO idx_ofec_totals_house_senate_mv_cycle_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cmte_dsgn_idx
  RENAME TO idx_ofec_totals_house_senate_mv_cmte_dsgn_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_treas_text_idx
  RENAME TO idx_ofec_totals_house_senate_mv_treas_text_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_org_tp_idx
  RENAME TO idx_ofec_totals_house_senate_mv_org_tp_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_first_f1_date_idx
  RENAME TO idx_ofec_totals_house_senate_mv_first_f1_date_idx;