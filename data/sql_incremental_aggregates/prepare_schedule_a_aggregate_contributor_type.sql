create or replace function contributor_type(value text) returns bool as $$
begin
    return upper(value) in ('11AI', '17A');
end
$$ language plpgsql;

-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_contributor_type;
create table ofec_sched_a_aggregate_contributor_type as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contributor_type(line_num) as individual,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from sched_a
where rpt_yr >= :START_YEAR_ITEMIZED
and contb_receipt_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, individual
;

-- Create indices on aggregate
create index on ofec_sched_a_aggregate_contributor_type (cmte_id);
create index on ofec_sched_a_aggregate_contributor_type (cycle);
create index on ofec_sched_a_aggregate_contributor_type (individual);
create index on ofec_sched_a_aggregate_contributor_type (total);
create index on ofec_sched_a_aggregate_contributor_type (count);

-- Create update function
create or replace function ofec_sched_a_update_aggregate_contributor_type() returns void as $$
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
            contributor_type(line_num) as individual,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, individual
    ),
    inc as (
        update ofec_sched_a_aggregate_contributor_type ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.individual) = (patch.cmte_id, patch.cycle, patch.individual)
    )
    insert into ofec_sched_a_aggregate_contributor_type (
        select patch.* from patch
        left join ofec_sched_a_aggregate_contributor_type ag using (cmte_id, cycle, individual)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
