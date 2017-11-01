-- Drop original table referenced in the creation of this view.
-- This is done here in order to prevent missing data impacting the API during
-- a refresh/rebuild.
drop table if exists ofec_sched_a_aggregate_size_old cascade;

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
    from ofec_totals_combined_mv_tmp
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

create index on ofec_sched_a_aggregate_size_merged_mv_tmp (cmte_id, idx);
create index on ofec_sched_a_aggregate_size_merged_mv_tmp (cycle, idx);
create index on ofec_sched_a_aggregate_size_merged_mv_tmp (size, idx);
create index on ofec_sched_a_aggregate_size_merged_mv_tmp (total, idx);
create index on ofec_sched_a_aggregate_size_merged_mv_tmp (count, idx);
create index on ofec_sched_a_aggregate_size_merged_mv_tmp (cycle, cmte_id);
