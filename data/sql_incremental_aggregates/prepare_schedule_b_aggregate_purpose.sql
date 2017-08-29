-- Create initial aggregate
drop table if exists ofec_sched_b_aggregate_purpose_tmp;
create table ofec_sched_b_aggregate_purpose_tmp as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    disbursement_purpose(disb_tp, disb_desc) as purpose,
    sum(disb_amt) as total,
    count(disb_amt) as count
from fec_fitem_sched_b_vw
where rpt_yr >= :START_YEAR_AGGREGATE
and disb_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, purpose
;

alter table ofec_sched_b_aggregate_purpose_tmp add column idx serial;
alter table ofec_sched_b_aggregate_purpose_tmp add constraint uq_cmte_id_cycle_purpose unique (cmte_id, cycle, purpose);

-- Create indices on aggregate
create index on ofec_sched_b_aggregate_purpose_tmp (cmte_id);
create index on ofec_sched_b_aggregate_purpose_tmp (cycle);
create index on ofec_sched_b_aggregate_purpose_tmp (purpose);
create index on ofec_sched_b_aggregate_purpose_tmp (total);
create index on ofec_sched_b_aggregate_purpose_tmp (count);
create index on ofec_sched_b_aggregate_purpose_tmp (cycle, cmte_id);

-- Remove previous aggregate and rename new aggregate
drop table if exists ofec_sched_b_aggregate_purpose;
alter table ofec_sched_b_aggregate_purpose_tmp rename to ofec_sched_b_aggregate_purpose;
