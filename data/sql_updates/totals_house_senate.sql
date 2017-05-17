drop materialized view if exists ofec_totals_house_senate_mv_tmp cascade;
create materialized view ofec_totals_house_senate_mv_tmp as
select
    candidate_id,
    cycle,
    sub_id,
    committee_id,
    election_cycle,
    coverage_start_date,
    coverage_end_date,
    all_other_loans,
    candidate_contribution,
    contribution_refunds,
    contributions,
    disbursements,
    individual_contributions,
    individual_itemized_contributions,
    individual_unitemized_contributions,
    loan_repayments,
    loan_repayments_candidate_loans,
    loan_repayments_other_loans,
    loans,
    loans_made_by_candidate,
    net_contributions,
    net_operating_expenditures,
    offsets_to_operating_expenditures,
    operating_expenditures,
    other_disbursements,
    other_political_committee_contributions,
    other_receipts,
    political_party_committee_contributions,
    receipts,
    refunded_individual_contributions,
    refunded_other_political_committee_contributions,
    refunded_political_party_committee_contributions,
    transfers_from_other_authorized_committee,
    transfers_to_other_authorized_committee,
    last_report_type_full,
    last_beginning_image_number,
    cash_on_hand_beginning_period,
    last_cash_on_hand_end_period,
    last_debts_owed_by_committee,
    last_debts_owed_to_committee,
    last_report_year
from
    ofec_totals_combined_mv_tmp
where
    form_type = 'F3'
;

create unique index on ofec_totals_house_senate_mv_tmp(sub_id);

create index on ofec_totals_house_senate_mv_tmp(cycle, sub_id);
create index on ofec_totals_house_senate_mv_tmp(candidate_id, sub_id);
create index on ofec_totals_house_senate_mv_tmp(cycle, committee_id);
create index on ofec_totals_house_senate_mv_tmp(committee_id, sub_id);
