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
        last_debts_owed_by_committee,
        coverage_start_date,
        coverage_end_date,
        false as federal_funds_flag
    from ofec_totals_house_senate_mv_tmp
    union all
    select
        committee_id,
        cycle,
        receipts,
        disbursements,
        last_cash_on_hand_end_period,
        last_debts_owed_by_committee,
        coverage_start_date,
        coverage_end_date,
        cast(federal_funds_flag as boolean) as federal_funds_flag
    from ofec_totals_presidential_mv_tmp
),
link as (
    select distinct on (cand_id, cand_election_yr)
    *
    from ofec_cand_cmte_linkage_mv
),
-- Aggregated totals by candidate by cycle
cycle_totals as (
    select distinct on (link.cand_id, election.cand_election_year, totals.cycle)
        link.cand_id as candidate_id,
        max(election.cand_election_year) as election_year,
        totals.cycle,
        false as is_election,
        sum(totals.receipts) as receipts,
        sum(totals.disbursements) as disbursements,
        sum(receipts) > 0 as has_raised_funds,
        sum(last_cash_on_hand_end_period) as cash_on_hand_end_period,
        sum(last_debts_owed_by_committee) as debts_owed_by_committee,
        min(coverage_start_date) as coverage_start_date,
        max(coverage_end_date) as coverage_end_date,
        array_agg(federal_funds_flag)::boolean array @> array[true] as federal_funds_flag
    from link
    join totals on
        link.cmte_id = totals.committee_id and
        link.fec_election_yr = totals.cycle
    left join ofec_candidate_election_mv_tmp election on
        link.cand_id = election.candidate_id and
        totals.cycle <= election.cand_election_year and
        totals.cycle > election.prev_election_year
    where
        link.cmte_dsgn in ('P', 'A')
    group by
        link.cand_id,
        election.cand_election_year,
        totals.cycle
),
-- Aggregated totals by candidate by election
election_aggregates as (
    select
        candidate_id,
        election_year,
        sum(receipts) as receipts,
        sum(disbursements) as disbursements,
        sum(receipts) > 0 as has_raised_funds,
        min(coverage_start_date) as coverage_start_date,
        max(coverage_end_date) as coverage_end_date,
        array_agg(federal_funds_flag) @> array[cast('true' as boolean)] as federal_funds_flag
    from cycle_totals
    group by
        candidate_id,
        election_year
),
-- Ending financials by candidate by election
election_latest as (
    select distinct on (candidate_id, election_year)
        candidate_id,
        election_year,
        cash_on_hand_end_period,
        debts_owed_by_committee,
        federal_funds_flag
    from cycle_totals totals
    order by
        candidate_id,
        election_year,
        cycle desc
),
-- Combined totals and ending financials by candidate by election
election_totals as (
    select
        totals.candidate_id,
        totals.election_year as election_year,
        totals.election_year as cycle,
        true as is_election,
        totals.receipts,
        totals.disbursements,
        totals.has_raised_funds,
        latest.cash_on_hand_end_period,
        latest.debts_owed_by_committee,
        totals.coverage_start_date,
        totals.coverage_end_date,
        totals.federal_funds_flag
    from election_aggregates totals
    join election_latest latest using (candidate_id, election_year)
)
-- Combined cycle and election totals by candidate
select * from cycle_totals
union all
select * from election_totals
;

create unique index on ofec_candidate_totals_mv_tmp (candidate_id, cycle, is_election);

create index on ofec_candidate_totals_mv_tmp (candidate_id);
create index on ofec_candidate_totals_mv_tmp (election_year);
create index on ofec_candidate_totals_mv_tmp (cycle);
create index on ofec_candidate_totals_mv_tmp (is_election);
create index on ofec_candidate_totals_mv_tmp (receipts);
create index on ofec_candidate_totals_mv_tmp (disbursements);
create index on ofec_candidate_totals_mv_tmp (has_raised_funds);
create index on ofec_candidate_totals_mv_tmp (federal_funds_flag);
create index on ofec_candidate_totals_mv_tmp (cycle, candidate_id);
