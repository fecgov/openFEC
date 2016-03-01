-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_occupation;
create table ofec_sched_a_aggregate_occupation as
select
    cmte_id,
    get_cycle(rpt_yr) as cycle,
    contbr_occupation as occupation,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from sched_a
where rpt_yr >= %(START_YEAR_AGGREGATE)s
and contb_receipt_amt is not null
and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text)
group by cmte_id, cycle, occupation
;

alter table ofec_sched_a_aggregate_occupation add column idx serial primary key;

-- Create indices on aggregate
create index on ofec_sched_a_aggregate_occupation (cmte_id, idx);
create index on ofec_sched_a_aggregate_occupation (cycle, idx);
create index on ofec_sched_a_aggregate_occupation (occupation, idx);
create index on ofec_sched_a_aggregate_occupation (total, idx);
create index on ofec_sched_a_aggregate_occupation (count, idx);

-- Create update function
create or replace function ofec_sched_a_update_aggregate_occupation() returns void as $$
begin
    with new as (
        select 1 as multiplier, *
        from ofec_sched_a_queue_new
    ),
    old as (
        select -1 as multiplier, *
        from ofec_sched_a_queue_old
    ),
    patch as (
        select
            cmte_id,
            get_cycle(rpt_yr) as cycle,
            contbr_occupation as occupation,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text)
        group by cmte_id, cycle, occupation
    ),
    inc as (
        update ofec_sched_a_aggregate_occupation ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.occupation) = (patch.cmte_id, patch.cycle, patch.occupation)
    )
    insert into ofec_sched_a_aggregate_occupation (
        select patch.* from patch
        left join ofec_sched_a_aggregate_occupation ag using (cmte_id, cycle, occupation)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
