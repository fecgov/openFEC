-- Add F13, F4 forms to ofec_totals_pacs_parties_mv.
-- Name: ofec_totals_pacs_parties_mv; 
-- Type: MATERIALIZED VIEW; 
-- Schema: public; Owner: fec

SET search_path = public, pg_catalog;

-- public.ofec_totals_pacs_parties_mv;
--   only change the where clause to include F13 and F4 in addtion to F3X
--   no change to column_name, column_type, or column_position

-- The following two MVs are logically depending on this MV.  
-- public.ofec_totals_parties_mv;
-- public.ofec_totals_pacs_mv;
-- however, they only select from ofec_totals_pacs_parties_mv with simple filter
-- therefore, a simple view should be enough, no need for MVs for them.

CREATE OR REPLACE VIEW public.ofec_totals_pacs_parties_vw AS 
 SELECT oft.sub_id AS idx,
    oft.committee_id,
    oft.committee_name,
    oft.cycle,
    oft.coverage_start_date,
    oft.coverage_end_date,
    oft.all_loans_received,
    oft.allocated_federal_election_levin_share,
    oft.contribution_refunds,
    oft.contributions,
    oft.coordinated_expenditures_by_party_committee,
    oft.disbursements,
    oft.fed_candidate_committee_contributions,
    oft.fed_candidate_contribution_refunds,
    oft.fed_disbursements,
    oft.fed_election_activity,
    oft.fed_receipts,
    oft.independent_expenditures,
    oft.refunded_individual_contributions,
    oft.individual_itemized_contributions,
    oft.individual_unitemized_contributions,
    oft.individual_contributions,
    oft.loan_repayments_other_loans AS loan_repayments_made,
    oft.loan_repayments_other_loans,
    oft.loan_repayments_received,
    oft.loans_made,
    oft.transfers_to_other_authorized_committee,
    oft.net_operating_expenditures,
    oft.non_allocated_fed_election_activity,
    oft.total_transfers,
    oft.offsets_to_operating_expenditures,
    oft.operating_expenditures,
    oft.operating_expenditures AS fed_operating_expenditures,
    oft.other_disbursements,
    oft.other_fed_operating_expenditures,
    oft.other_fed_receipts,
    oft.other_political_committee_contributions,
    oft.refunded_other_political_committee_contributions,
    oft.political_party_committee_contributions,
    oft.refunded_political_party_committee_contributions,
    oft.receipts,
    oft.shared_fed_activity,
    oft.shared_fed_activity_nonfed,
    oft.shared_fed_operating_expenditures,
    oft.shared_nonfed_operating_expenditures,
    oft.transfers_from_affiliated_party,
    oft.transfers_from_nonfed_account,
    oft.transfers_from_nonfed_levin,
    oft.transfers_to_affiliated_committee,
    oft.net_contributions,
    oft.last_report_type_full,
    oft.last_beginning_image_number,
    oft.last_cash_on_hand_end_period,
    oft.cash_on_hand_beginning_period,
    oft.last_debts_owed_by_committee,
    oft.last_debts_owed_to_committee,
    oft.last_report_year,
    oft.committee_type,
    oft.committee_designation,
    oft.committee_type_full,
    oft.committee_designation_full,
    oft.party_full,
    comm_dets.designation
   FROM ofec_totals_combined_vw oft
     JOIN ofec_committee_detail_vw comm_dets USING (committee_id)
  WHERE oft.form_type IN ('F3X', 'F13', 'F4');

ALTER TABLE public.ofec_totals_pacs_parties_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_pacs_parties_vw TO fec;
GRANT SELECT ON TABLE public.ofec_totals_pacs_parties_vw TO fec_read;

-- ----------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_pacs_parties_mv;

CREATE MATERIALIZED VIEW IF NOT EXISTS public.ofec_totals_pacs_parties_mv AS 
 SELECT oft.sub_id AS idx,
    oft.committee_id,
    oft.committee_name,
    oft.cycle,
    oft.coverage_start_date,
    oft.coverage_end_date,
    oft.all_loans_received,
    oft.allocated_federal_election_levin_share,
    oft.contribution_refunds,
    oft.contributions,
    oft.coordinated_expenditures_by_party_committee,
    oft.disbursements,
    oft.fed_candidate_committee_contributions,
    oft.fed_candidate_contribution_refunds,
    oft.fed_disbursements,
    oft.fed_election_activity,
    oft.fed_receipts,
    oft.independent_expenditures,
    oft.refunded_individual_contributions,
    oft.individual_itemized_contributions,
    oft.individual_unitemized_contributions,
    oft.individual_contributions,
    oft.loan_repayments_other_loans AS loan_repayments_made,
    oft.loan_repayments_other_loans,
    oft.loan_repayments_received,
    oft.loans_made,
    oft.transfers_to_other_authorized_committee,
    oft.net_operating_expenditures,
    oft.non_allocated_fed_election_activity,
    oft.total_transfers,
    oft.offsets_to_operating_expenditures,
    oft.operating_expenditures,
    oft.operating_expenditures AS fed_operating_expenditures,
    oft.other_disbursements,
    oft.other_fed_operating_expenditures,
    oft.other_fed_receipts,
    oft.other_political_committee_contributions,
    oft.refunded_other_political_committee_contributions,
    oft.political_party_committee_contributions,
    oft.refunded_political_party_committee_contributions,
    oft.receipts,
    oft.shared_fed_activity,
    oft.shared_fed_activity_nonfed,
    oft.shared_fed_operating_expenditures,
    oft.shared_nonfed_operating_expenditures,
    oft.transfers_from_affiliated_party,
    oft.transfers_from_nonfed_account,
    oft.transfers_from_nonfed_levin,
    oft.transfers_to_affiliated_committee,
    oft.net_contributions,
    oft.last_report_type_full,
    oft.last_beginning_image_number,
    oft.last_cash_on_hand_end_period,
    oft.cash_on_hand_beginning_period,
    oft.last_debts_owed_by_committee,
    oft.last_debts_owed_to_committee,
    oft.last_report_year,
    oft.committee_type,
    oft.committee_designation,
    oft.committee_type_full,
    oft.committee_designation_full,
    oft.party_full,
    comm_dets.designation
   FROM ofec_totals_combined_vw oft
     JOIN ofec_committee_detail_vw comm_dets USING (committee_id)
    WHERE oft.form_type IN ('F3X', 'F13', 'F4')
WITH DATA;

ALTER TABLE public.ofec_totals_pacs_parties_mv
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_pacs_parties_mv TO fec;
GRANT SELECT ON TABLE public.ofec_totals_pacs_parties_mv TO fec_read;

CREATE UNIQUE INDEX idx_ofec_totals_pacs_parties_mv_idx
  ON public.ofec_totals_pacs_parties_mv
  USING btree
  (idx);

CREATE INDEX idx_ofec_totals_pacs_parties_mv_cmte_id_idx
  ON public.ofec_totals_pacs_parties_mv
  USING btree
  (committee_id COLLATE pg_catalog."default", idx);

CREATE INDEX idx_ofec_totals_pacs_parties_mv_cmte_tp_full_idx
  ON public.ofec_totals_pacs_parties_mv
  USING btree
  (committee_type_full COLLATE pg_catalog."default", idx);

CREATE INDEX idx_ofec_totals_pacs_parties_mv_cmte_tp_idx
  ON public.ofec_totals_pacs_parties_mv
  USING btree
  (committee_type COLLATE pg_catalog."default", idx);

CREATE INDEX idx_ofec_totals_pacs_parties_mv_cycle_idx
  ON public.ofec_totals_pacs_parties_mv
  USING btree
  (cycle, idx);

CREATE INDEX idx_ofec_totals_pacs_parties_mv_dsgn_idx
  ON public.ofec_totals_pacs_parties_mv
  USING btree
  (designation COLLATE pg_catalog."default", idx);

CREATE INDEX idx_ofec_totals_pacs_parties_mv_disbursements
  ON public.ofec_totals_pacs_parties_mv
  USING btree
  (disbursements);

CREATE INDEX idx_ofec_totals_pacs_parties_mv_receipts
  ON public.ofec_totals_pacs_parties_mv
  USING btree
  (receipts);

CREATE INDEX idx_ofec_totals_pacs_parties_mv_cmte_dsgn_full_idx
  ON public.ofec_totals_pacs_parties_mv
  USING btree
  (committee_designation_full COLLATE pg_catalog."default", idx);

-- --------------------------
CREATE OR REPLACE VIEW ofec_totals_pacs_parties_vw AS 
SELECT * FROM ofec_totals_pacs_parties_mv;

ALTER TABLE public.ofec_totals_pacs_parties_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_pacs_parties_vw TO fec;
GRANT SELECT ON TABLE public.ofec_totals_pacs_parties_vw TO fec_read;
