-- Create initial aggregate
drop table if exists ofec_sched_b_aggregate_recipient;
create table ofec_sched_b_aggregate_recipient as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    recipient_nm,
    sum(disb_amt) as total,
    count(disb_amt) as count
from sched_b
where rpt_yr >= :START_YEAR_ITEMIZED
and disb_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, recipient_nm
;

-- Create indices on aggregate
create index on ofec_sched_b_aggregate_recipient (cmte_id);
create index on ofec_sched_b_aggregate_recipient (cycle);
create index on ofec_sched_b_aggregate_recipient (recipient_nm);
create index on ofec_sched_b_aggregate_recipient (total);
create index on ofec_sched_b_aggregate_recipient (count);
