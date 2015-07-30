-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_employer;
create table ofec_sched_a_aggregate_employer as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contbr_employer as employer,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from sched_a
where rpt_yr >= :START_YEAR_ITEMIZED
and contb_receipt_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, employer
;

-- Create indices on aggregate
create index on ofec_sched_a_aggregate_employer (cmte_id);
create index on ofec_sched_a_aggregate_employer (cycle);
create index on ofec_sched_a_aggregate_employer (employer);
create index on ofec_sched_a_aggregate_employer (total);
create index on ofec_sched_a_aggregate_employer (count);
