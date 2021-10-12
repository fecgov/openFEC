/*
This migration file continues for #4951
1 - Modify `ofec_totals_house_senate_mv` and `ofec_totals_house_senate_vw`to add: `first_f1_date`
    
    Replaces V0233

2 - Modify `ofec_totals_ie_only_mv` to add: `first_f1_date`
    
    Replaces V0233
*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_house_senate_mv_tmp;

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
    f3.treasurer_text,
    f3.filing_frequency,
    f3.filing_frequency_full,
    f3.first_file_date,
    f3.organization_type,
    f3.organization_type_full,
    ---- Added w/V0236
    f3.first_f1_date   
   FROM ofec_totals_combined_vw f3
  WHERE f3.form_type in ('F3', 'F3P', 'F3X')
  AND f3.committee_type in ('H','S')
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

-- 2 - Modify `ofec_totals_ie_only_mv`

DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_ie_only_mv_tmp;

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
    ofec_totals_combined_vw.filing_frequency,
    ofec_totals_combined_vw.filing_frequency_full,
    ofec_totals_combined_vw.first_file_date,
    ofec_totals_combined_vw.organization_type,
    ofec_totals_combined_vw.organization_type_full,
    ofec_totals_combined_vw.first_f1_date   ---- Added w/V0236
FROM ofec_totals_combined_vw
WHERE ofec_totals_combined_vw.form_type = 'F5'
WITH DATA;

-- Permissions
ALTER TABLE public.ofec_totals_ie_only_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_ie_only_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_totals_ie_only_mv_tmp TO fec_read;

-- Indexes

CREATE UNIQUE INDEX idx_ofec_totals_ie_only_mv_tmp_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (idx);

CREATE INDEX idx_ofec_totals_ie_only_mv_tmp_committee_designation_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (committee_designation, idx);

CREATE INDEX idx_ofec_totals_ie_only_mv_tmp_committee_id_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (committee_id, idx);

CREATE INDEX idx_ofec_totals_ie_only_mv_tmp_committee_type_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (committee_type, idx);

CREATE INDEX idx_ofec_totals_ie_only_mv_tmp_cycle_committee_id
ON public.ofec_totals_ie_only_mv_tmp USING btree (cycle, committee_id);

CREATE INDEX idx_ofec_totals_ie_only_mv_tmp_cycle_idx
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
ALTER INDEX IF EXISTS idx_ofec_totals_ie_only_mv_tmp_idx
RENAME TO idx_ofec_totals_ie_only_mv_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_ie_only_mv_tmp_committee_designation_idx
RENAME TO idx_ofec_totals_ie_only_mv_committee_designation_idx ;

ALTER INDEX IF EXISTS idx_ofec_totals_ie_only_mv_tmp_committee_id_idx
RENAME TO idx_ofec_totals_ie_only_mv_committee_id_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_ie_only_mv_tmp_committee_type_idx
RENAME TO idx_ofec_totals_ie_only_mv_committee_type_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_ie_only_mv_tmp_cycle_committee_id
RENAME TO idx_ofec_totals_ie_only_mv_cycle_committee_id;

ALTER INDEX IF EXISTS idx_ofec_totals_ie_only_mv_tmp_cycle_idx
RENAME TO idx_ofec_totals_ie_only_mv_cycle_idx;
