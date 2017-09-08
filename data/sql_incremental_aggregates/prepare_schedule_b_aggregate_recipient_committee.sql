-- Drop the old functions if they still exist.
drop function if exists ofec_sched_b_update_aggregate_recipient_id();

-- Create initial aggregate
drop table if exists ofec_sched_b_aggregate_recipient_id_tmp;
create table ofec_sched_b_aggregate_recipient_id_tmp as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    clean_repeated(recipient_cmte_id, cmte_id) as recipient_cmte_id,
    max(recipient_nm) as recipient_nm,
    sum(disb_amt) as total,
    count(disb_amt) as count
from fec_fitem_sched_b_vw
where rpt_yr >= :START_YEAR_AGGREGATE
and disb_amt is not null
and (memo_cd != 'X' or memo_cd is null)
and clean_repeated(recipient_cmte_id, cmte_id) is not null
group by cmte_id, cycle, clean_repeated(recipient_cmte_id, cmte_id)
;

alter table ofec_sched_b_aggregate_recipient_id_tmp add column idx serial;
-- Have to violate naming convention below due to Postgres identifier length limitations
alter table ofec_sched_b_aggregate_recipient_id_tmp add constraint uq_sched_b_agg_recpnt_id_tmp_cmte_id_cycle_recipient_cmte_id unique (cmte_id, cycle, recipient_cmte_id);

-- Create indices on aggregate
create index ofec_sched_b_aggregate_recipient_id_tmp_cmte_id on ofec_sched_b_aggregate_recipient_id_tmp(cmte_id);
create index ofec_sched_b_aggregate_recipient_id_tmp_cycle on ofec_sched_b_aggregate_recipient_id_tmp(cycle);
create index ofec_sched_b_aggregate_recipient_id_tmp_recipient_cmte_id on ofec_sched_b_aggregate_recipient_id_tmp(recipient_cmte_id);
create index ofec_sched_b_aggregate_recipient_id_tmp_total on ofec_sched_b_aggregate_recipient_id_tmp(total);
create index ofec_sched_b_aggregate_recipient_id_tmp_count on ofec_sched_b_aggregate_recipient_id_tmp(count);
create index ofec_sched_b_aggregate_recipient_id_tmp_cmte_id_cycle on ofec_sched_b_aggregate_recipient_id_tmp(cmte_id, cycle);

-- Remove previous aggregate and rename new aggregate
drop table if exists ofec_sched_b_aggregate_recipient_id;
alter table ofec_sched_b_aggregate_recipient_id_tmp rename to ofec_sched_b_aggregate_recipient_id;
select rename_indexes('ofec_sched_b_aggregate_recipient_id');
