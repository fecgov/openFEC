-- Create initial aggregate
drop table if exists ofec_sched_b_aggregate_recipient_id;
create table ofec_sched_b_aggregate_recipient_id as
select
    cmte_id,
    get_cycle(rpt_yr) as cycle,
    clean_repeated(recipient_cmte_id, cmte_id) as recipient_cmte_id,
    max(recipient_nm) as recipient_nm,
    sum(disb_amt) as total,
    count(disb_amt) as count
from sched_b
where rpt_yr >= %(START_YEAR_AGGREGATE)s
and disb_amt is not null
and (memo_cd != 'X' or memo_cd is null)
and clean_repeated(recipient_cmte_id, cmte_id) is not null
group by cmte_id, cycle, clean_repeated(recipient_cmte_id, cmte_id)
;

alter table ofec_sched_b_aggregate_recipient_id add column idx serial primary key;

-- Create indices on aggregate
create index on ofec_sched_b_aggregate_recipient_id (cmte_id, idx);
create index on ofec_sched_b_aggregate_recipient_id (cycle, idx);
create index on ofec_sched_b_aggregate_recipient_id (recipient_cmte_id, idx);
create index on ofec_sched_b_aggregate_recipient_id (total, idx);
create index on ofec_sched_b_aggregate_recipient_id (count, idx);

-- Create update function
create or replace function ofec_sched_b_update_aggregate_recipient_id() returns void as $$
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
            get_cycle(rpt_yr) as cycle,
            clean_repeated(recipient_cmte_id, cmte_id) as recipient_cmte_id,
            max(recipient_nm) as recipient_nm,
            sum(disb_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where disb_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        and clean_repeated(recipient_cmte_id, cmte_id) is not null
        group by cmte_id, cycle, clean_repeated(recipient_cmte_id, cmte_id)
    ),
    inc as (
        update ofec_sched_b_aggregate_recipient_id ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.recipient_cmte_id) = (patch.cmte_id, patch.cycle, patch.recipient_cmte_id)
    )
    insert into ofec_sched_b_aggregate_recipient_id (
        select patch.* from patch
        left join ofec_sched_b_aggregate_recipient_id ag using (cmte_id, cycle, recipient_cmte_id)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
