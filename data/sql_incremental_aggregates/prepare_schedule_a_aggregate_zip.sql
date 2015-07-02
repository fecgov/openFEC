-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_zip;
create table ofec_sched_a_aggregate_zip as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contbr_zip as zip,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from sched_a
where rpt_yr >= :START_YEAR_ITEMIZED
group by cmte_id, cycle, zip
;

-- Create indices on aggregate
create index on ofec_sched_a_aggregate_zip (cmte_id);
create index on ofec_sched_a_aggregate_zip (cycle);
create index on ofec_sched_a_aggregate_zip (zip);
create index on ofec_sched_a_aggregate_zip (total);
create index on ofec_sched_a_aggregate_zip (count);

-- Create update function
create or replace function ofec_sched_a_update_aggregate_zip() returns void as $$
begin
    with new as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contbr_zip as zip,
            sum(contb_receipt_amt) as total,
            count(contb_receipt_amt) as count
        from ofec_sched_a_queue_new
        group by cmte_id, cycle, zip
    ),
    old as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contbr_zip as zip,
            -1 * sum(contb_receipt_amt) as total,
            -1 * count(contb_receipt_amt) as count
        from ofec_sched_a_queue_old
        group by cmte_id, cycle, zip
    ),
    patch as (
      select * from new
      union all
      select * from old
    ),
    inc as (
        update ofec_sched_a_aggregate_zip ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.zip) = (patch.cmte_id, patch.cycle, patch.zip)
    )
    insert into ofec_sched_a_aggregate_zip (
        select patch.* from patch
        left join ofec_sched_a_aggregate_zip ag using (cmte_id, cycle, zip)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
