-- Merge aggregated Schedule A receipts with committee totals views
drop table if exists ofec_sched_a_aggregate_size_merged_tmp;

create table ofec_sched_a_aggregate_size_merged_tmp as
with grouped as (
    select
        committee_id as cmte_id,
        cycle as cycle,
        0 as size,
        individual_unitemized_contributions as total,
        0 as count
    from ofec_totals_combined_mv
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

create unique index ofec_sched_a_aggregate_size_merged_tmp_idx on ofec_sched_a_aggregate_size_merged_tmp (idx);

create index ofec_sched_a_aggregate_size_merged_tmp_cmte_idx on ofec_sched_a_aggregate_size_merged_tmp (cmte_id);
create index ofec_sched_a_aggregate_size_merged_tmp_cycle on ofec_sched_a_aggregate_size_merged_tmp (cycle);
create index ofec_sched_a_aggregate_size_merged_tmp_size on ofec_sched_a_aggregate_size_merged_tmp (size);
create index ofec_sched_a_aggregate_size_merged_tmp_cycle_cmte_id on ofec_sched_a_aggregate_size_merged_tmp (cycle, cmte_id);

drop table if exists ofec_sched_a_aggregate_size_merged;
alter table ofec_sched_a_aggregate_size_merged_tmp rename to ofec_sched_a_aggregate_size_merged;
select rename_indexes('ofec_sched_a_aggregate_size_merged');
