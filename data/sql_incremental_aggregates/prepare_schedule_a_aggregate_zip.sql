-- Drop the old functions if they still exist.
drop function if exists ofec_sched_a_update_aggregate_zip();

-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_zip_tmp;
create table ofec_sched_a_aggregate_zip_tmp as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contbr_zip as zip,
    max(contbr_st) as state,
    expand_state(max(contbr_st)) as state_full,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from fec_fitem_sched_a_vw
where rpt_yr >= :START_YEAR_AGGREGATE
and contb_receipt_amt is not null
and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id, cmte_id)
group by cmte_id, cycle, zip
;

alter table ofec_sched_a_aggregate_zip_tmp add column idx serial;
alter table ofec_sched_a_aggregate_zip_tmp add constraint uq_ofec_sched_a_aggregate_zip_tmp_cmte_id_cycle_zip unique (cmte_id, cycle, zip);

-- Create indices on aggregate
create index ofec_sched_a_aggregate_zip_tmp_cmte_id on ofec_sched_a_aggregate_zip_tmp(cmte_id);
create index ofec_sched_a_aggregate_zip_tmp_cycle on ofec_sched_a_aggregate_zip_tmp(cycle);
create index ofec_sched_a_aggregate_zip_tmp_zip on ofec_sched_a_aggregate_zip_tmp(zip);
create index ofec_sched_a_aggregate_zip_tmp_state on ofec_sched_a_aggregate_zip_tmp(state);
create index ofec_sched_a_aggregate_zip_tmp_state_full on ofec_sched_a_aggregate_zip_tmp(state_full);
create index ofec_sched_a_aggregate_zip_tmp_total on ofec_sched_a_aggregate_zip_tmp(total);
create index ofec_sched_a_aggregate_zip_tmp_count on ofec_sched_a_aggregate_zip_tmp(count);

-- Remove previous aggregate and rename new aggregate
drop table if exists ofec_sched_a_aggregate_zip;
alter table ofec_sched_a_aggregate_zip_tmp rename to ofec_sched_a_aggregate_zip;
select rename_indexes('ofec_sched_a_aggregate_zip');
