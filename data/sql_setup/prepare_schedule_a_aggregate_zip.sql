-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_zip;
create table ofec_sched_a_aggregate_zip as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contbr_zip as zip,
    sum(contb_receipt_amt) as total
from sched_a
    where rpt_yr >= :START_YEAR_ITEMIZED
    group by cmte_id, cycle, zip
;

-- Create indices on aggregate
create index on ofec_sched_a_aggregate_zip (cmte_id);
create index on ofec_sched_a_aggregate_zip (cycle);
create index on ofec_sched_a_aggregate_zip (zip);

-- Create update function
create or replace function ofec_sched_a_update_aggregate_zip() returns void as $$
begin
    with new as (
      select
        cmte_id,
        rpt_yr + rpt_yr % 2 as cycle,
        contbr_zip as zip,
        sum(contb_receipt_amt) as total
      from ofec_sched_a_queue_new
      group by cmte_id, cycle, zip
    ),
    old as (
      select
        cmte_id,
        rpt_yr + rpt_yr % 2 as cycle,
        contbr_zip as zip,
        -1 * sum(contb_receipt_amt) as total
      from ofec_sched_a_queue_old
      group by cmte_id, cycle, zip
    ),
    patch as (
      select * from new
      union all
      select * from old
    )
    update ofec_sched_a_aggregate_zip ag
    set total = ag.total + patch.total
    from patch
    where (ag.cmte_id, ag.cycle, ag.zip) = (patch.cmte_id, patch.cycle, patch.zip)
    ;
end
$$ language plpgsql;
