create or replace function contribution_size(value numeric) returns int as $$
begin
    return case
        when abs(value) <= 200 then 0
        when abs(value) < 500 then 200
        when abs(value) < 1000 then 500
        when abs(value) < 2000 then 1000
        else 2000
    end;
end
$$ language plpgsql;

-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_size cascade;
create table ofec_sched_a_aggregate_size as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contribution_size(contb_receipt_amt) as size,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from sched_a
where rpt_yr >= :START_YEAR_ITEMIZED
and contb_receipt_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, size
;

-- Create indices on aggregate
create index on ofec_sched_a_aggregate_size (cmte_id);
create index on ofec_sched_a_aggregate_size (cycle);
create index on ofec_sched_a_aggregate_size (size);
create index on ofec_sched_a_aggregate_size (total);
create index on ofec_sched_a_aggregate_size (count);

-- Create update function
create or replace function ofec_sched_a_update_aggregate_size() returns void as $$
begin
    with new as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contribution_size(contb_receipt_amt) as size,
            sum(contb_receipt_amt) as total,
            count(contb_receipt_amt) as count
        from ofec_sched_a_queue_new
        where contb_receipt_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, size
    ),
    old as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contribution_size(contb_receipt_amt) as size,
            -1 * sum(contb_receipt_amt) as total,
            -1 * count(contb_receipt_amt) as count
        from ofec_sched_a_queue_old
        where contb_receipt_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, size
    ),
    patch as (
        select * from new
        union all
        select * from old
    ),
    inc as (
        update ofec_sched_a_aggregate_size ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.size) = (patch.cmte_id, patch.cycle, patch.size)
    )
    insert into ofec_sched_a_aggregate_size (
        select patch.* from patch
        left join ofec_sched_a_aggregate_size ag using (cmte_id, cycle, size)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
