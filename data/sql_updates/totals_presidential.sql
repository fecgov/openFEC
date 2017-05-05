drop materialized view if exists ofec_totals_presidential_mv_tmp cascade;
create materialized view ofec_totals_presidential_mv_tmp as
select
    sub_id,
    committee_id,
    cycle,
    coverage_start_date,
    coverage_end_date,
    candidate_contribution,
    contribution_refunds,
    contributions,
    disbursements,
    exempt_legal_accounting_disbursement,
    federal_funds,
    federal_funds_flag,
    fundraising_disbursements,
    individual_contributions,
    individual_unitemized_contributions,
    individual_itemized_contributions,
    loans_received,
    loans_received_from_candidate,
    loan_repayments_made,
    offsets_to_fundraising_expenditures,
    offsets_to_legal_accounting,
    offsets_to_operating_expenditures,
    total_offsets_to_operating_expenditures,
    operating_expenditures,
    other_disbursements,
    other_loans_received,
    other_political_committee_contributions,
    other_receipts,
    political_party_committee_contributions,
    receipts,
    refunded_individual_contributions,
    refunded_other_political_committee_contributions,
    refunded_political_party_committee_contributions,
    epayments_loans_made_by_candidate,
    repayments_other_loans,
    transfers_from_affiliated_committee,
    transfers_to_other_authorized_committee,
    cash_on_hand_beginning_of_period,
    debts_owed_by_cmte,
    debts_owed_to_cmte,
    net_contributions,
    net_operating_expenditures,
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

create unique index on ofec_totals_presidential_mv_tmp(sub_id);

create index on ofec_totals_presidential_mv_tmp(cycle, sub_id);
create index on ofec_totals_presidential_mv_tmp(committee_id, sub_id);
