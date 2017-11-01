-- Drop the old functions if they still exist.
drop function if exists ofec_sched_a_update_aggregate_size();

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
drop table if exists ofec_sched_a_aggregate_size_tmp cascade;
create table ofec_sched_a_aggregate_size_tmp as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contribution_size(contb_receipt_amt) as size,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from fec_fitem_sched_a_vw
where rpt_yr >= :START_YEAR_AGGREGATE
and contb_receipt_amt is not null
and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id, cmte_id)
group by cmte_id, cycle, size
;

-- Create indices on aggregate
create index ofec_sched_a_aggregate_size_tmp_cmte_id on ofec_sched_a_aggregate_size_tmp(cmte_id);
create index ofec_sched_a_aggregate_size_tmp_cycle on ofec_sched_a_aggregate_size_tmp(cycle);
create index ofec_sched_a_aggregate_size_tmp_size on ofec_sched_a_aggregate_size_tmp(size);
create index ofec_sched_a_aggregate_size_tmp_total on ofec_sched_a_aggregate_size_tmp(total);
create index ofec_sched_a_aggregate_size_tmp_count on ofec_sched_a_aggregate_size_tmp(count);
create index ofec_sched_a_aggregate_size_tmp_cmte_id_cycle on ofec_sched_a_aggregate_size_tmp(cmte_id, cycle);

drop table if exists ofec_sched_a_aggregate_size cascade;
alter table ofec_sched_a_aggregate_size_tmp rename to ofec_sched_a_aggregate_size;
select rename_indexes('ofec_sched_a_aggregate_size');

-- Create update function
create or replace function ofec_sched_a_update_aggregate_size() returns void as $$
begin
    with new as (
        select 1 as multiplier, cmte_id, rpt_yr, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_new
    ),
    old as (
        select -1 as multiplier, cmte_id, rpt_yr, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contribution_size(contb_receipt_amt) as size,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id, cmte_id)
        group by cmte_id, cycle, size
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
