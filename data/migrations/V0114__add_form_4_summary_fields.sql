/*
Add missing fields for Form 4 totals

- Add ofec_totals_combined_vw.loans to ofec_totals_pacs_parties_vw
Name it `loans_and_loan_repayments`
Maps to Form 4's `subttl_loan_repymts_per` (Line 16)

- Add ofec_totals_combined_vw.federal_funds to ofec_totals_pacs_parties_vw
Maps to Form 4's `fed_funds_per` (Line 13)

- Add missing fields to public.ofec_totals_combined_mv

*/

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
    comm_dets.designation,
    oft.loans AS loans_and_loan_repayments, --needed for Form 4
    oft.federal_funds --needed for Form 4
   FROM ofec_totals_combined_vw oft
     JOIN ofec_committee_detail_vw comm_dets USING (committee_id)
  WHERE oft.form_type IN ('F3X', 'F13', 'F4');
