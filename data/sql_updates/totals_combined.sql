drop table if exists ofec_committee_totals;
create table ofec_committee_totals as
    select
        committee_id,
        cycle,
        receipts,
        disbursements,
        last_cash_on_hand_end_period,
        last_debts_owed_by_committee,
        individual_unitemized_contributions
    from ofec_totals_pacs_parties
    union all
    select
        committee_id,
        cycle,
        receipts,
        disbursements,
        last_cash_on_hand_end_period,
        last_debts_owed_by_committee,
        individual_unitemized_contributions
    from ofec_totals_house_senate
    union all
    select
        committee_id,
        cycle,
        receipts,
        disbursements,
        last_cash_on_hand_end_period,
        last_debts_owed_by_committee,
        individual_unitemized_contributions
    from ofec_totals_presidential
;
