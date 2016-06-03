drop materialized view if exists ofec_totals_combined_mv_tmp;
create materialized view ofec_totals_combined_mv_tmp as
with rows as (
    select
        committee_id,
        cycle,
        receipts,
        disbursements,
        contributions,
        last_cash_on_hand_end_period as cash_on_hand_end_period,
        last_debts_owed_by_committee as debts_owed_by_committee,
        null::numeric as independent_expenditures
    from ofec_totals_house_senate_mv_tmp
    union all
    select
        committee_id,
        cycle,
        receipts,
        disbursements,
        contributions,
        last_cash_on_hand_end_period as cash_on_hand_end_period,
        last_debts_owed_by_committee as debts_owed_by_committee,
        null::numeric as independent_expenditures
    from ofec_totals_presidential_mv_tmp
    union all
    select
        committee_id,
        cycle,
        receipts,
        disbursements,
        contributions,
        last_cash_on_hand_end_period as cash_on_hand_end_period,
        last_debts_owed_by_committee as debts_owed_by_committee,
        independent_expenditures
    from ofec_totals_pacs_parties_mv_tmp
)
select
    row_number() over () as idx,
    *
from rows
;

create unique index on ofec_totals_combined_mv_tmp (idx);

create index on ofec_totals_combined_mv_tmp (committee_id);
create index on ofec_totals_combined_mv_tmp (cycle);
create index on ofec_totals_combined_mv_tmp (receipts);
create index on ofec_totals_combined_mv_tmp (disbursements);
