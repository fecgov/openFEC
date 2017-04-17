-- Create initial aggregate
drop table if exists ofec_sched_b_aggregate_purpose_tmp;
create table ofec_sched_b_aggregate_purpose_tmp as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    disbursement_purpose(disb_tp, disb_desc) as purpose,
    sum(disb_amt) as total,
    count(disb_amt) as count
from fec_vsum_sched_b_vw
where rpt_yr >= :START_YEAR_AGGREGATE
and disb_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, purpose
;

alter table ofec_sched_b_aggregate_purpose_tmp add column idx serial primary key;

-- Create indices on aggregate
create index on ofec_sched_b_aggregate_purpose_tmp (cmte_id, idx);
create index on ofec_sched_b_aggregate_purpose_tmp (cycle, idx);
create index on ofec_sched_b_aggregate_purpose_tmp (purpose, idx);
create index on ofec_sched_b_aggregate_purpose_tmp (total, idx);
create index on ofec_sched_b_aggregate_purpose_tmp (count, idx);

-- Remove previous aggregate and rename new aggregate
drop table if exists ofec_sched_b_aggregate_purpose;
alter table ofec_sched_b_aggregate_purpose_tmp rename to ofec_sched_b_aggregate_purpose;

-- Create update function
create or replace function ofec_sched_b_update_aggregate_purpose() returns void as $$
begin
    with new as (
        select 1 as multiplier, cmte_id, rpt_yr, disb_tp, disb_desc, disb_amt, memo_cd
        from ofec_sched_b_queue_new
    ),
    old as (
        select -1 as multiplier, cmte_id, rpt_yr, disb_tp, disb_desc, disb_amt, memo_cd
        from ofec_sched_b_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            disbursement_purpose(disb_tp, disb_desc) as purpose,
            sum(disb_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where disb_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, purpose
    ),
    inc as (
        update ofec_sched_b_aggregate_purpose ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.purpose) = (patch.cmte_id, patch.cycle, patch.purpose)
    )
    insert into ofec_sched_b_aggregate_purpose (
        select patch.* from patch
        left join ofec_sched_b_aggregate_purpose ag using (cmte_id, cycle, purpose)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
