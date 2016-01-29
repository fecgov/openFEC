drop materialized view if exists ofec_candidate_aggregate_mv_tmp;
create materialized view ofec_candidate_aggregate_mv_tmp as
with totals as (
    select
        committee_id,
        cycle,
        receipts,
        disbursements,
        last_cash_on_hand_end_period,
        last_debts_owed_by_committee
    from ofec_totals_house_senate_mv_tmp
    union all
    select
        committee_id,
        cycle,
        receipts,
        disbursements,
        last_cash_on_hand_end_period,
        last_debts_owed_by_committee
    from ofec_totals_presidential_mv_tmp
)
select
    link.cand_id,
    totals.cycle,
    sum(totals.receipts) as receipts,
    sum(totals.disbursements) as disbursements,
    sum(last_cash_on_hand_end_period) as cash_on_hand_end_period,
    sum(last_debts_owed_by_committee) as debts_owed_by_committee
from ofec_cand_cmte_linkage_mv_tmp link
join totals on
    link.cmte_id = totals.committee_id and
    link.fec_election_yr = totals.cycle
where
    link.cmte_dsgn in ('P', 'A')
group by
    link.cand_id,
    totals.cycle
;

create unique index on ofec_candidate_aggregate_mv_tmp (cand_id, cycle);

create index on ofec_candidate_aggregate_mv_tmp (cand_id);
create index on ofec_candidate_aggregate_mv_tmp (cycle);
create index on ofec_candidate_aggregate_mv_tmp (receipts);
create index on ofec_candidate_aggregate_mv_tmp (disbursements);
create index on ofec_candidate_aggregate_mv_tmp (cash_on_hand_end_period);
create index on ofec_candidate_aggregate_mv_tmp (debts_owed_by_committee);

drop materialized view if exists ofec_candidate_election_aggregate_mv_tmp;
create materialized view ofec_candidate_election_aggregate_mv_tmp as
with totals as (
    select
        cand_id,
        election.cand_election_year,
        sum(receipts) as receipts,
        sum(disbursements) as disbursements
    from ofec_candidate_aggregate_mv_tmp cand
    join ofec_candidate_election_mv_tmp election on
        cand.cand_id = election.candidate_id and
        cand.cycle <= election.cand_election_year and
        cand.cycle > election.cand_election_year - election_duration(substr(cand.cand_id, 1, 1))
    group by
        cand_id,
        election.cand_election_year
), latest as (
    select distinct on (cand.cand_id, election.cand_election_year)
        cand.cand_id,
        election.cand_election_year,
        cand.cash_on_hand_end_period,
        cand.debts_owed_by_committee
    from ofec_candidate_aggregate_mv_tmp cand
    join ofec_candidate_election_mv_tmp election on
        cand.cand_id = election.candidate_id and
        cand.cycle <= election.cand_election_year and
        cand.cycle > election.cand_election_year - election_duration(substr(cand.cand_id, 1, 1))
    order by
        cand.cand_id,
        election.cand_election_year,
        cand.cycle desc
)
select
    totals.cand_id,
    totals.cand_election_year as cycle,
    totals.receipts,
    totals.disbursements,
    latest.cash_on_hand_end_period,
    latest.debts_owed_by_committee
from totals
join latest using (cand_id, cand_election_year)
;

create unique index on ofec_candidate_election_aggregate_mv_tmp (cand_id, cycle);

create index on ofec_candidate_election_aggregate_mv_tmp (cand_id);
create index on ofec_candidate_election_aggregate_mv_tmp (cycle);
create index on ofec_candidate_election_aggregate_mv_tmp (receipts);
create index on ofec_candidate_election_aggregate_mv_tmp (disbursements);
create index on ofec_candidate_election_aggregate_mv_tmp (cash_on_hand_end_period);
create index on ofec_candidate_election_aggregate_mv_tmp (debts_owed_by_committee);
