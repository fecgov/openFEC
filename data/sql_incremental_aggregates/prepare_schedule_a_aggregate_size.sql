-- Drop the old functions if they still exist.
drop function if exists ofec_sched_a_update_aggregate_size();

create or replace function contribution_size(value numeric) returns int as $$
begin
    return case
        when abs(value) <= 200 then 0
        when abs(value) < 500 then 200
        when abs(value) < 1000 then 500
        when abs(value) < 2000 then 1000
        else 2000
    end;
end
$$ language plpgsql;

-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_size_tmp cascade;
create table ofec_sched_a_aggregate_size_tmp as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contribution_size(contb_receipt_amt) as size,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from fec_fitem_sched_a_vw
where rpt_yr >= :START_YEAR_AGGREGATE
and contb_receipt_amt is not null
and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id, cmte_id)
group by cmte_id, cycle, size
;

alter table ofec_sched_a_aggregate_size_tmp add constraint uq_cmte_id_cycle_size unique (cmte_id, cycle, size);
-- Create indices on aggregate
create index on ofec_sched_a_aggregate_size_tmp (cmte_id);
create index on ofec_sched_a_aggregate_size_tmp (cycle);
create index on ofec_sched_a_aggregate_size_tmp (size);
create index on ofec_sched_a_aggregate_size_tmp (total);
create index on ofec_sched_a_aggregate_size_tmp (count);
create index on ofec_sched_a_aggregate_size_tmp (cmte_id, cycle);

-- this drops totals during rebuild
drop table if exists ofec_sched_a_aggregate_state cascade;
drop table if exists ofec_sched_a_aggregate_size_old cascade;

-- Remove previous aggregate and rename new aggregate
-- ofec_sched_a_aggregate_size_old is removed when the dependent materialized
-- view (ofec_sched_a_aggregate_size_merged_mv) is recreated to prevent
-- missing data impacting the API during a refresh/rebuild.
alter table if exists ofec_sched_a_aggregate_size rename to ofec_sched_a_aggregate_size_old;
alter table ofec_sched_a_aggregate_size_tmp rename to ofec_sched_a_aggregate_size;
