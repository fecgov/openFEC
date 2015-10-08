-- Merge aggregated Schedule A receipts with committee totals views
drop materialized view if exists ofec_sched_a_aggregate_size_merged_mv_tmp;
create materialized view ofec_sched_a_aggregate_size_merged_mv_tmp as
with grouped as (
    select
        committee_id as cmte_id,
        cycle as cycle,
        0 as size,
        individual_unitemized_contributions as total,
        0 as count
    from ofec_totals_pacs_parties_mv_tmp
    where cycle >= :START_YEAR_AGGREGATE
    union all
    select
        committee_id as cmte_id,
        cycle as cycle,
        0 as size,
        individual_unitemized_contributions as total,
        0 as count
    from ofec_totals_presidential_mv_tmp
    where cycle >= :START_YEAR_AGGREGATE
    union all
    select
        committee_id as cmte_id,
        cycle as cycle,
        0 as size,
        individual_unitemized_contributions as total,
        0 as count
    from ofec_totals_house_senate_mv_tmp
    where cycle >= :START_YEAR_AGGREGATE
    union all
    select *
    from ofec_sched_a_aggregate_size
)
select
    row_number() over () as idx,
    cmte_id,
    cycle,
    size,
    sum(total) as total,
    case
        when size = 0 then null
        else sum(count)
    end as count
from grouped
group by cmte_id, cycle, size
;

create unique index on ofec_sched_a_aggregate_size_merged_mv_tmp (idx);

create index on ofec_sched_a_aggregate_size_merged_mv_tmp (cmte_id);
create index on ofec_sched_a_aggregate_size_merged_mv_tmp (cycle);
create index on ofec_sched_a_aggregate_size_merged_mv_tmp (size);
create index on ofec_sched_a_aggregate_size_merged_mv_tmp (total);
create index on ofec_sched_a_aggregate_size_merged_mv_tmp (count);
