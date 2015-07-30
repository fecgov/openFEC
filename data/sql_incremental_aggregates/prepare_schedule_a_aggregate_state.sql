drop table if exists ofec_sched_a_aggregate_state;
create table ofec_sched_a_aggregate_state as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contbr_st as state,
    expand_state(contbr_st) as state_full,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from sched_a
where rpt_yr >= :START_YEAR_ITEMIZED
and contb_receipt_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, state
;

create index on ofec_sched_a_aggregate_state (cmte_id);
create index on ofec_sched_a_aggregate_state (cycle);
create index on ofec_sched_a_aggregate_state (state);
create index on ofec_sched_a_aggregate_state (state_full);
create index on ofec_sched_a_aggregate_state (total);
create index on ofec_sched_a_aggregate_state (count);
