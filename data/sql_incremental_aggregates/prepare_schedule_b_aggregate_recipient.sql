-- Create initial aggregate
drop table if exists ofec_sched_b_aggregate_recipient;
create table ofec_sched_b_aggregate_recipient as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    recipient_nm,
    sum(disb_amt) as total,
    count(disb_amt) as count
from sched_b
where rpt_yr >= :START_YEAR_ITEMIZED
and disb_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, recipient_nm
;

-- Create indices on aggregate
create index on ofec_sched_b_aggregate_recipient (cmte_id);
create index on ofec_sched_b_aggregate_recipient (cycle);
create index on ofec_sched_b_aggregate_recipient (recipient_nm);
create index on ofec_sched_b_aggregate_recipient (total);
create index on ofec_sched_b_aggregate_recipient (count);

-- Create update function
create or replace function ofec_sched_b_update_aggregate_recipient() returns void as $$
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
            rpt_yr + rpt_yr % 2 as cycle,
            recipient_nm,
            sum(disb_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where disb_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, recipient_nm
    ),
    inc as (
        update ofec_sched_b_aggregate_recipient ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.recipient_nm) = (patch.cmte_id, patch.cycle, patch.recipient_nm)
    )
    insert into ofec_sched_b_aggregate_recipient (
        select patch.* from patch
        left join ofec_sched_b_aggregate_recipient ag using (cmte_id, cycle, recipient_nm)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
