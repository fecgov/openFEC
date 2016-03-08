drop table if exists ofec_sched_a_aggregate_size_merged_tmp;
create table ofec_sched_a_aggregate_size_merged_tmp as
with grouped as (
    select
        committee_id as cmte_id,
        cycle as cycle,
        0 as size,
        individual_unitemized_contributions as total,
        0 as count
    from ofec_committee_totals
    where cycle >= %(START_YEAR_AGGREGATE)s
    union all
    select * from ofec_sched_a_aggregate_size
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

create unique index on ofec_sched_a_aggregate_size_merged_tmp (idx);

create index on ofec_sched_a_aggregate_size_merged_tmp (cmte_id, idx);
create index on ofec_sched_a_aggregate_size_merged_tmp (cycle, idx);
create index on ofec_sched_a_aggregate_size_merged_tmp (size, idx);
create index on ofec_sched_a_aggregate_size_merged_tmp (total, idx);
create index on ofec_sched_a_aggregate_size_merged_tmp (count, idx);

drop table if exists ofec_sched_a_aggregate_size_merged;
alter table ofec_sched_a_aggregate_size_merged_tmp rename to ofec_sched_a_aggregate_size_merged;
