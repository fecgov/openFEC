drop materialized view if exists ofec_candidate_totals_mv_tmp;
create materialized view ofec_candidate_totals_mv_tmp as
-- Consolidated two-year committee totals
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
),
-- Aggregated totals by candidate by cycle
cycle_totals as (
    select
        link.cand_id as candidate_id,
        totals.cycle,
        false as is_election,
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
        candidate_id,
        totals.cycle
),
-- Aggregated totals by candidate by election
election_aggregates as (
    select
        totals.candidate_id,
        election.cand_election_year,
        sum(receipts) as receipts,
        sum(disbursements) as disbursements
    from cycle_totals totals
    join ofec_candidate_election_mv_tmp election on
        totals.candidate_id = election.candidate_id and
        totals.cycle <= election.cand_election_year and
        totals.cycle > election.cand_election_year - election_duration(substr(totals.candidate_id, 1, 1))
    group by
        totals.candidate_id,
        election.cand_election_year
),
-- Ending financials by candidate by election
election_latest as (
    select distinct on (totals.candidate_id, election.cand_election_year)
        totals.candidate_id,
        election.cand_election_year,
        totals.cash_on_hand_end_period,
        totals.debts_owed_by_committee
    from cycle_totals totals
    join ofec_candidate_election_mv_tmp election on
        totals.candidate_id = election.candidate_id and
        totals.cycle <= election.cand_election_year and
        totals.cycle > election.cand_election_year - election_duration(substr(totals.candidate_id, 1, 1))
    order by
        totals.candidate_id,
        election.cand_election_year,
        totals.cycle desc
),
-- Combined totals and ending financials by candidate by election
election_totals as (
    select
        totals.candidate_id,
        totals.cand_election_year as cycle,
        true as is_election,
        totals.receipts,
        totals.disbursements,
        latest.cash_on_hand_end_period,
        latest.debts_owed_by_committee
    from election_aggregates totals
    join election_latest latest using (candidate_id, cand_election_year)
)
-- Combined cycle and election totals by candidate
select * from cycle_totals
union all
select * from election_totals
;

create unique index on ofec_candidate_totals_mv_tmp (candidate_id, cycle, is_election);

create index on ofec_candidate_totals_mv_tmp (candidate_id);
create index on ofec_candidate_totals_mv_tmp (cycle);
create index on ofec_candidate_totals_mv_tmp (is_election);
create index on ofec_candidate_totals_mv_tmp (receipts);
create index on ofec_candidate_totals_mv_tmp (disbursements);
