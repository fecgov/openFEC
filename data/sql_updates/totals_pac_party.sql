drop materialized view if exists ofec_totals_pacs_parties_mv_tmp cascade;
create materialized view ofec_totals_pacs_parties_mv_tmp as
select
    oft.sub_id as idx,
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
    -- for F3x total loan repayments made are called other loans
    oft.loan_repayments_other_loans as loan_repayments_made,
    oft.loan_repayments_other_loans,
    oft.loan_repayments_received,
    oft.loans_made,
    oft.transfers_to_other_authorized_committee, -- was not here before
    oft.net_operating_expenditures,
    oft.non_allocated_fed_election_activity,
    oft.total_transfers,
    oft.offsets_to_operating_expenditures,
    -- I think this is a labeling issue, I am going to try this and see if it fixes the front end display, if it does, I think we will want to get rid of fed operating expenditures
    oft.operating_expenditures,
    oft.operating_expenditures as fed_operating_expenditures,
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
from
    ofec_totals_combined_mv_tmp oft
    inner join ofec_committee_detail_mv_tmp comm_dets using(committee_id)
where
    oft.form_type = 'F3X'
;

create unique index on ofec_totals_pacs_parties_mv_tmp(idx);

create index on ofec_totals_pacs_parties_mv_tmp(receipts);
create index on ofec_totals_pacs_parties_mv_tmp(disbursements);
create index on ofec_totals_pacs_parties_mv_tmp(cycle, idx);
create index on ofec_totals_pacs_parties_mv_tmp(committee_id, idx );
create index on ofec_totals_pacs_parties_mv_tmp(committee_type, idx );
create index on ofec_totals_pacs_parties_mv_tmp(designation, idx );
create index on ofec_totals_pacs_parties_mv_tmp(committee_type_full, idx);
create index on ofec_totals_pacs_parties_mv_tmp(committee_designation_full, idx);

drop materialized view if exists ofec_totals_pacs_mv_tmp;
create materialized view ofec_totals_pacs_mv_tmp as
select *
from ofec_totals_pacs_parties_mv_tmp
where
    (committee_type = 'N' or committee_type = 'Q'
    or committee_type = 'O' or committee_type = 'V'
    or committee_type = 'W')
;

create unique index on ofec_totals_pacs_mv_tmp(idx);

create index on ofec_totals_pacs_mv_tmp(receipts);
create index on ofec_totals_pacs_mv_tmp(disbursements);
create index on ofec_totals_pacs_mv_tmp(cycle, idx);
create index on ofec_totals_pacs_mv_tmp(committee_id, idx );
create index on ofec_totals_pacs_mv_tmp(committee_type, idx );
create index on ofec_totals_pacs_mv_tmp(designation, idx );
create index on ofec_totals_pacs_mv_tmp(committee_type_full, idx);
create index on ofec_totals_pacs_mv_tmp(committee_designation_full, idx);

drop materialized view if exists ofec_totals_parties_mv_tmp;
create materialized view ofec_totals_parties_mv_tmp as
select *
from ofec_totals_pacs_parties_mv_tmp pp
where
    (committee_type = 'X' or committee_type = 'Y')
;

create unique index on ofec_totals_parties_mv_tmp(idx);

create index on ofec_totals_parties_mv_tmp(receipts);
create index on ofec_totals_parties_mv_tmp(disbursements);
create index on ofec_totals_parties_mv_tmp(cycle, idx);
create index on ofec_totals_parties_mv_tmp(committee_id, idx );
create index on ofec_totals_parties_mv_tmp(committee_type, idx );
create index on ofec_totals_parties_mv_tmp(designation, idx );
create index on ofec_totals_parties_mv_tmp(committee_type_full, idx);
create index on ofec_totals_parties_mv_tmp(committee_designation_full, idx);

