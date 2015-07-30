-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_zip;
create table ofec_sched_a_aggregate_zip as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contbr_zip as zip,
    max(contbr_st) as state,
    expand_state(max(contbr_st)) as state_full,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from sched_a
where rpt_yr >= :START_YEAR_ITEMIZED
and contb_receipt_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, zip
;

-- Create indices on aggregate
create index on ofec_sched_a_aggregate_zip (cmte_id);
create index on ofec_sched_a_aggregate_zip (cycle);
create index on ofec_sched_a_aggregate_zip (zip);
create index on ofec_sched_a_aggregate_zip (state);
create index on ofec_sched_a_aggregate_zip (state_full);
create index on ofec_sched_a_aggregate_zip (total);
create index on ofec_sched_a_aggregate_zip (count);
