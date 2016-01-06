-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_employer;
create table ofec_sched_a_aggregate_employer as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contbr_employer as employer,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from sched_a
where rpt_yr >= :START_YEAR_AGGREGATE
and contb_receipt_amt is not null
and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text)
group by cmte_id, cycle, employer
;

alter table ofec_sched_a_aggregate_employer add column idx serial primary key;

-- Create indices on aggregate
create index on ofec_sched_a_aggregate_employer (cmte_id, idx);
create index on ofec_sched_a_aggregate_employer (cycle, idx);
create index on ofec_sched_a_aggregate_employer (employer, idx);
create index on ofec_sched_a_aggregate_employer (total, idx);
create index on ofec_sched_a_aggregate_employer (count, idx);

-- Create update function
create or replace function ofec_sched_a_update_aggregate_employer() returns void as $$
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
            rpt_yr + rpt_yr % 2 as cycle,
            contbr_employer as employer,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text)
        group by cmte_id, cycle, employer
    ),
    inc as (
        update ofec_sched_a_aggregate_employer ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.employer) = (patch.cmte_id, patch.cycle, patch.employer)
    )
    insert into ofec_sched_a_aggregate_employer (
        select patch.* from patch
        left join ofec_sched_a_aggregate_employer ag using (cmte_id, cycle, employer)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
