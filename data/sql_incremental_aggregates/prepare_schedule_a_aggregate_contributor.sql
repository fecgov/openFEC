-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_contributor;
create table ofec_sched_a_aggregate_contributor as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    clean_repeated(contbr_id, cmte_id) as contbr_id,
    max(contbr_nm) as contbr_nm,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from sched_a
where rpt_yr >= :START_YEAR_AGGREGATE
and contb_receipt_amt is not null
and clean_repeated(contbr_id, cmte_id) is not null
and coalesce(entity_tp, '') != 'IND'
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, clean_repeated(contbr_id, cmte_id)
;

-- Create indices on aggregate
create index on ofec_sched_a_aggregate_contributor (cmte_id);
create index on ofec_sched_a_aggregate_contributor (cycle);
create index on ofec_sched_a_aggregate_contributor (contbr_id);
create index on ofec_sched_a_aggregate_contributor (total);
create index on ofec_sched_a_aggregate_contributor (count);

-- Create update function
create or replace function ofec_sched_a_update_aggregate_contributor() returns void as $$
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
            clean_repeated(contbr_id, cmte_id) as contbr_id,
            max(contbr_nm) as contbr_nm,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and clean_repeated(contbr_id, cmte_id) is not null
        and coalesce(entity_tp, '') != 'IND'
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, clean_repeated(contbr_id, cmte_id)
    ),
    inc as (
        update ofec_sched_a_aggregate_contributor ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.contbr_id) = (patch.cmte_id, patch.cycle, patch.contbr_id)
    )
    insert into ofec_sched_a_aggregate_contributor (
        select patch.* from patch
        left join ofec_sched_a_aggregate_contributor ag using (cmte_id, cycle, contbr_id)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
