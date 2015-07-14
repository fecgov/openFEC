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
where rpt_yr >= :START_YEAR_ITEMIZED
and contb_receipt_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, employer
;

-- Create indices on aggregate
create index on ofec_sched_a_aggregate_employer (cmte_id);
create index on ofec_sched_a_aggregate_employer (cycle);
create index on ofec_sched_a_aggregate_employer (employer);
create index on ofec_sched_a_aggregate_employer (total);
create index on ofec_sched_a_aggregate_employer (count);

-- Create update function
create or replace function ofec_sched_a_update_aggregate_employer() returns void as $$
begin
    with new as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contbr_employer as employer,
            sum(contb_receipt_amt) as total,
            count(contb_receipt_amt) as count
        from ofec_sched_a_queue_new
        where contb_receipt_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, employer
    ),
    old as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contbr_employer as employer,
            -1 * sum(contb_receipt_amt) as total,
            -1 * count(contb_receipt_amt) as count
        from ofec_sched_a_queue_old
        where contb_receipt_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, employer
    ),
    patch as (
      select * from new
      union all
      select * from old
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
