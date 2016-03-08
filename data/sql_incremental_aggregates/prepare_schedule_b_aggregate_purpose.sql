drop table if exists ofec_sched_b_aggregate_purpose;
create table ofec_sched_b_aggregate_purpose as
select
    cmte_id,
    get_cycle(rpt_yr) as cycle,
    disbursement_purpose(disb_tp, disb_desc) as purpose,
    sum(disb_amt) as total,
    count(disb_amt) as count
from sched_b
where rpt_yr >= %(START_YEAR_AGGREGATE)s
and disb_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, purpose
;

alter table ofec_sched_b_aggregate_purpose add column idx serial primary key;

create index on ofec_sched_b_aggregate_purpose (cmte_id, idx);
create index on ofec_sched_b_aggregate_purpose (cycle, idx);
create index on ofec_sched_b_aggregate_purpose (purpose, idx);
create index on ofec_sched_b_aggregate_purpose (total, idx);
create index on ofec_sched_b_aggregate_purpose (count, idx);

-- Create update function
create or replace function ofec_sched_b_update_aggregate_purpose() returns void as $$
begin
    with new as (
        select 1 as multiplier, *
        from ofec_sched_b_queue_new
    ),
    old as (
        select -1 as multiplier, *
        from ofec_sched_b_queue_old
    ),
    patch as (
        select
            cmte_id,
            get_cycle(rpt_yr) as cycle,
            disbursement_purpose(disb_tp, disb_desc) as purpose,
            sum(disb_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where disb_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, purpose
    ),
    inc as (
        update ofec_sched_b_aggregate_purpose ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.purpose) = (patch.cmte_id, patch.cycle, patch.purpose)
    )
    insert into ofec_sched_b_aggregate_purpose (
        select patch.* from patch
        left join ofec_sched_b_aggregate_purpose ag using (cmte_id, cycle, purpose)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
