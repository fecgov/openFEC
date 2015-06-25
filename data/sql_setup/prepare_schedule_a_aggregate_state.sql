drop table if exists ofec_sched_a_aggregate_state;
create table ofec_sched_a_aggregate_state as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contbr_st as state,
    sum(contb_receipt_amt) as total
from sched_a
    where rpt_yr >= :START_YEAR_ITEMIZED
    group by cmte_id, cycle, state
;

create index on ofec_sched_a_aggregate_state (cmte_id);
create index on ofec_sched_a_aggregate_state (cycle);
create index on ofec_sched_a_aggregate_state (state);

-- Create update function
create or replace function ofec_sched_a_update_aggregate_state() returns void as $$
begin
    with new as (
      select
        cmte_id,
        rpt_yr + rpt_yr % 2 as cycle,
        contbr_st as state,
        sum(contb_receipt_amt) as total
      from ofec_sched_a_queue_new
      group by cmte_id, cycle, state
    ),
    old as (
      select
        cmte_id,
        rpt_yr + rpt_yr % 2 as cycle,
        contbr_st as state,
        -1 * sum(contb_receipt_amt) as total
      from ofec_sched_a_queue_old
      group by cmte_id, cycle, state
    ),
    patch as (
      select * from new
      union all
      select * from old
    )
    update ofec_sched_a_aggregate_state ag
    set total = ag.total + patch.total
    from patch
    where (ag.cmte_id, ag.cycle, ag.state) = (patch.cmte_id, patch.cycle, patch.state)
    ;
end
$$ language plpgsql;
