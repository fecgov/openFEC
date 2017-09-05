-- Drop the old functions if they still exist.
drop function if exists ofec_sched_a_update_aggregate_employer();

-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_employer_tmp;
create table ofec_sched_a_aggregate_employer_tmp as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contbr_employer as employer,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from fec_fitem_sched_a_vw
where rpt_yr >= :START_YEAR_AGGREGATE
and contb_receipt_amt is not null
and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id, cmte_id)
group by cmte_id, cycle, employer
;

alter table ofec_sched_a_aggregate_employer_tmp add column idx serial;
alter table ofec_sched_a_aggregate_employer_tmp add constraint uq_cmte_id_cycle_employer unique (cmte_id, cycle, employer);

-- Create indices on aggregate
create index on ofec_sched_a_aggregate_employer_tmp (cmte_id);
create index on ofec_sched_a_aggregate_employer_tmp (cycle);
create index on ofec_sched_a_aggregate_employer_tmp (employer);
create index on ofec_sched_a_aggregate_employer_tmp (total);
create index on ofec_sched_a_aggregate_employer_tmp (count);
create index on ofec_sched_a_aggregate_employer_tmp (cycle, cmte_id);

-- Remove previous aggregate and rename new aggregate
drop table if exists ofec_sched_a_aggregate_employer;
alter table ofec_sched_a_aggregate_employer_tmp rename to ofec_sched_a_aggregate_employer;
