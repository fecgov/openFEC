drop materialized view if exists ofec_totals_pacs_parties_mv_tmp cascade;
create materialized view ofec_totals_pacs_parties_mv_tmp as
select
     sub_id,
     committee_id,
     cycle,
     coverage_start_date,
     coverage_end_date,
     all_loans_received,
     allocated_federal_election_levin_share,
     contribution_refunds,
     contributions,
     coordinated_expenditures_by_party_committee,
     disbursements,
     fed_candidate_committee_contributions,
     fed_candidate_contribution_refunds,
     -- not sure about this one i think it might be fed_funds_per
     --sum(pnp.ttl_fed_disb_per) as fed_disbursements,
     fed_disbursements,
     fed_election_activity,
     -- sum(pnp.ttl_fed_op_exp_per) as fed_operating_expenditures, -- was in F3x can't find in detsum
     fed_receipts,
     independent_expenditures,
     refunded_individual_contributions,
     individual_itemized_contributions,
     individual_unitemized_contributions,
     individual_contributions,
     loan_repayments_made,
     loan_repayments_received,
     loans_made,
     net_operating_expenditures,
     non_allocated_fed_election_activity,
     total_transfers,
     offsets_to_operating_expenditures,
     operating_expenditures,
     other_disbursements,
     other_fed_operating_expenditures,
     other_fed_receipts,
     other_political_committee_contributions,
     refunded_other_political_committee_contributions,
     political_party_committee_contributions,
     refunded_political_party_committee_contributions,
     receipts,
     shared_fed_activity,
     shared_fed_activity_nonfed,
     shared_fed_operating_expenditures,
     shared_nonfed_operating_expenditures,
     transfers_from_affiliated_party,
     transfers_from_nonfed_account,
     transfers_from_nonfed_levin,
     transfers_to_affiliated_committee,
     net_contributions,
     last_report_type_full,
     last_beginning_image_number,
     last_cash_on_hand_end_period,
     -- last_cash_on_hand_beginning_period,
     cash_on_hand_beginning_period,
     last_debts_owed_by_committee,
     last_debts_owed_to_committee,
     last_report_year,
     comm_dets.committee_type,
     comm_dets.designation
from
    ofec_totals_combined_mv_tmp
    inner join ofec_committee_detail_mv_tmp comm_dets using(committee_id)
where
    form_type = 'F3X'
;

create unique index on ofec_totals_pacs_parties_mv_tmp(sub_id);

create index on ofec_totals_pacs_parties_mv_tmp(cycle, sub_id);
create index on ofec_totals_pacs_parties_mv_tmp(committee_id, sub_id );
create index on ofec_totals_pacs_parties_mv_tmp(committee_type, sub_id );
create index on ofec_totals_pacs_parties_mv_tmp(designation, sub_id );

drop materialized view if exists ofec_totals_pacs_mv_tmp;
create materialized view ofec_totals_pacs_mv_tmp as
select *
from ofec_totals_pacs_parties_mv_tmp
where
    (committee_type = 'N' or committee_type = 'Q'
    or committee_type = 'O' or committee_type = 'V'
    or committee_type = 'W')
;


drop materialized view if exists ofec_totals_parties_mv_tmp;
create materialized view ofec_totals_parties_mv_tmp as
select *
from ofec_totals_pacs_parties_mv_tmp pp
where
    (committee_type = 'X' or committee_type = 'Y')
;
