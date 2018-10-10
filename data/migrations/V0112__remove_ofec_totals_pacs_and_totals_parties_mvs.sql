SET search_path = public, pg_catalog;

-- The following two MVs are logically depending on public.ofec_totals_pacs_parties_mv.  
-- public.ofec_totals_parties_mv;
-- public.ofec_totals_pacs_mv;
-- however, they only select from ofec_totals_pacs_parties_mv with simple filter
-- therefore, a simple view should be enough, no need for MVs for them.

-- --------------------------
CREATE OR REPLACE VIEW public.ofec_totals_pacs_vw AS 
 SELECT ofec_totals_pacs_parties_vw.idx,
    ofec_totals_pacs_parties_vw.committee_id,
    ofec_totals_pacs_parties_vw.committee_name,
    ofec_totals_pacs_parties_vw.cycle,
    ofec_totals_pacs_parties_vw.coverage_start_date,
    ofec_totals_pacs_parties_vw.coverage_end_date,
    ofec_totals_pacs_parties_vw.all_loans_received,
    ofec_totals_pacs_parties_vw.allocated_federal_election_levin_share,
    ofec_totals_pacs_parties_vw.contribution_refunds,
    ofec_totals_pacs_parties_vw.contributions,
    ofec_totals_pacs_parties_vw.coordinated_expenditures_by_party_committee,
    ofec_totals_pacs_parties_vw.disbursements,
    ofec_totals_pacs_parties_vw.fed_candidate_committee_contributions,
    ofec_totals_pacs_parties_vw.fed_candidate_contribution_refunds,
    ofec_totals_pacs_parties_vw.fed_disbursements,
    ofec_totals_pacs_parties_vw.fed_election_activity,
    ofec_totals_pacs_parties_vw.fed_receipts,
    ofec_totals_pacs_parties_vw.independent_expenditures,
    ofec_totals_pacs_parties_vw.refunded_individual_contributions,
    ofec_totals_pacs_parties_vw.individual_itemized_contributions,
    ofec_totals_pacs_parties_vw.individual_unitemized_contributions,
    ofec_totals_pacs_parties_vw.individual_contributions,
    ofec_totals_pacs_parties_vw.loan_repayments_made,
    ofec_totals_pacs_parties_vw.loan_repayments_other_loans,
    ofec_totals_pacs_parties_vw.loan_repayments_received,
    ofec_totals_pacs_parties_vw.loans_made,
    ofec_totals_pacs_parties_vw.transfers_to_other_authorized_committee,
    ofec_totals_pacs_parties_vw.net_operating_expenditures,
    ofec_totals_pacs_parties_vw.non_allocated_fed_election_activity,
    ofec_totals_pacs_parties_vw.total_transfers,
    ofec_totals_pacs_parties_vw.offsets_to_operating_expenditures,
    ofec_totals_pacs_parties_vw.operating_expenditures,
    ofec_totals_pacs_parties_vw.fed_operating_expenditures,
    ofec_totals_pacs_parties_vw.other_disbursements,
    ofec_totals_pacs_parties_vw.other_fed_operating_expenditures,
    ofec_totals_pacs_parties_vw.other_fed_receipts,
    ofec_totals_pacs_parties_vw.other_political_committee_contributions,
    ofec_totals_pacs_parties_vw.refunded_other_political_committee_contributions,
    ofec_totals_pacs_parties_vw.political_party_committee_contributions,
    ofec_totals_pacs_parties_vw.refunded_political_party_committee_contributions,
    ofec_totals_pacs_parties_vw.receipts,
    ofec_totals_pacs_parties_vw.shared_fed_activity,
    ofec_totals_pacs_parties_vw.shared_fed_activity_nonfed,
    ofec_totals_pacs_parties_vw.shared_fed_operating_expenditures,
    ofec_totals_pacs_parties_vw.shared_nonfed_operating_expenditures,
    ofec_totals_pacs_parties_vw.transfers_from_affiliated_party,
    ofec_totals_pacs_parties_vw.transfers_from_nonfed_account,
    ofec_totals_pacs_parties_vw.transfers_from_nonfed_levin,
    ofec_totals_pacs_parties_vw.transfers_to_affiliated_committee,
    ofec_totals_pacs_parties_vw.net_contributions,
    ofec_totals_pacs_parties_vw.last_report_type_full,
    ofec_totals_pacs_parties_vw.last_beginning_image_number,
    ofec_totals_pacs_parties_vw.last_cash_on_hand_end_period,
    ofec_totals_pacs_parties_vw.cash_on_hand_beginning_period,
    ofec_totals_pacs_parties_vw.last_debts_owed_by_committee,
    ofec_totals_pacs_parties_vw.last_debts_owed_to_committee,
    ofec_totals_pacs_parties_vw.last_report_year,
    ofec_totals_pacs_parties_vw.committee_type,
    ofec_totals_pacs_parties_vw.committee_designation,
    ofec_totals_pacs_parties_vw.committee_type_full,
    ofec_totals_pacs_parties_vw.committee_designation_full,
    ofec_totals_pacs_parties_vw.party_full,
    ofec_totals_pacs_parties_vw.designation
   FROM ofec_totals_pacs_parties_vw
  WHERE ofec_totals_pacs_parties_vw.committee_type in ('N','Q','O','V','W');

ALTER TABLE public.ofec_totals_pacs_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_pacs_vw TO fec;
GRANT SELECT ON TABLE public.ofec_totals_pacs_vw TO fec_read;

-- ----------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_pacs_mv;

-- ----------------------------
-- ----------------------------
CREATE OR REPLACE VIEW public.ofec_totals_parties_vw AS 
 SELECT pp.idx,
    pp.committee_id,
    pp.committee_name,
    pp.cycle,
    pp.coverage_start_date,
    pp.coverage_end_date,
    pp.all_loans_received,
    pp.allocated_federal_election_levin_share,
    pp.contribution_refunds,
    pp.contributions,
    pp.coordinated_expenditures_by_party_committee,
    pp.disbursements,
    pp.fed_candidate_committee_contributions,
    pp.fed_candidate_contribution_refunds,
    pp.fed_disbursements,
    pp.fed_election_activity,
    pp.fed_receipts,
    pp.independent_expenditures,
    pp.refunded_individual_contributions,
    pp.individual_itemized_contributions,
    pp.individual_unitemized_contributions,
    pp.individual_contributions,
    pp.loan_repayments_made,
    pp.loan_repayments_other_loans,
    pp.loan_repayments_received,
    pp.loans_made,
    pp.transfers_to_other_authorized_committee,
    pp.net_operating_expenditures,
    pp.non_allocated_fed_election_activity,
    pp.total_transfers,
    pp.offsets_to_operating_expenditures,
    pp.operating_expenditures,
    pp.fed_operating_expenditures,
    pp.other_disbursements,
    pp.other_fed_operating_expenditures,
    pp.other_fed_receipts,
    pp.other_political_committee_contributions,
    pp.refunded_other_political_committee_contributions,
    pp.political_party_committee_contributions,
    pp.refunded_political_party_committee_contributions,
    pp.receipts,
    pp.shared_fed_activity,
    pp.shared_fed_activity_nonfed,
    pp.shared_fed_operating_expenditures,
    pp.shared_nonfed_operating_expenditures,
    pp.transfers_from_affiliated_party,
    pp.transfers_from_nonfed_account,
    pp.transfers_from_nonfed_levin,
    pp.transfers_to_affiliated_committee,
    pp.net_contributions,
    pp.last_report_type_full,
    pp.last_beginning_image_number,
    pp.last_cash_on_hand_end_period,
    pp.cash_on_hand_beginning_period,
    pp.last_debts_owed_by_committee,
    pp.last_debts_owed_to_committee,
    pp.last_report_year,
    pp.committee_type,
    pp.committee_designation,
    pp.committee_type_full,
    pp.committee_designation_full,
    pp.party_full,
    pp.designation
   FROM ofec_totals_pacs_parties_vw pp
  WHERE pp.committee_type in ('X','Y');

ALTER TABLE public.ofec_totals_parties_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_parties_vw TO fec;
GRANT SELECT ON TABLE public.ofec_totals_parties_vw TO fec_read;
 
-- ----------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_parties_mv;