drop table if exists ofec_sched_a_aggregate_state;
create table ofec_sched_a_aggregate_state as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contbr_st as state,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from sched_a
where rpt_yr >= :START_YEAR_ITEMIZED
and contb_receipt_amt is not null
and memo_cd != 'X'
group by cmte_id, cycle, state
;

create index on ofec_sched_a_aggregate_state (cmte_id);
create index on ofec_sched_a_aggregate_state (cycle);
create index on ofec_sched_a_aggregate_state (state);
create index on ofec_sched_a_aggregate_state (total);
create index on ofec_sched_a_aggregate_state (count);

-- Create update function
create or replace function ofec_sched_a_update_aggregate_state() returns void as $$
begin
    with new as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contbr_st as state,
            sum(contb_receipt_amt) as total,
            count(contb_receipt_amt) as count
        from ofec_sched_a_queue_new
        where contb_receipt_amt is not null
        and memo_cd != 'X'
        group by cmte_id, cycle, state
    ),
    old as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contbr_st as state,
            -1 * sum(contb_receipt_amt) as total,
            -1 * count(contb_receipt_amt) as count
        from ofec_sched_a_queue_old
        where contb_receipt_amt is not null
        and memo_cd != 'X'
        group by cmte_id, cycle, state
    ),
    patch as (
        select * from new
        union all
        select * from old
    ),
    inc as (
        update ofec_sched_a_aggregate_state ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.state) = (patch.cmte_id, patch.cycle, patch.state)
    )
    insert into ofec_sched_a_aggregate_state (
        select patch.* from patch
        left join ofec_sched_a_aggregate_state ag using (cmte_id, cycle, state)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
