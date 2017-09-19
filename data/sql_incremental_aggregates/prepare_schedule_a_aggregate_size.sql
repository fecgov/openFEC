-- Running this update requires a update_schemas afterward
--
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

-- Remove previous aggregate and rename new aggregate
-- ofec_sched_a_aggregate_size_old is removed when the dependent materialized
-- view (ofec_sched_a_aggregate_size_merged_mv) is recreated to prevent
-- missing data impacting the API during a refresh/rebuild.
drop table if exists ofec_sched_a_aggregate_size_old;
alter table if exists ofec_sched_a_aggregate_size rename to ofec_sched_a_aggregate_size_old;
-- might need some if table exists logic here
select add_index_suffix('ofec_sched_a_aggregate_size', '_old');

-- Create initial aggregate
create table ofec_sched_a_aggregate_size as
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

alter table ofec_sched_a_aggregate_size add constraint uq_ofec_sched_a_aggregate_size_cmte_id_cycle_size unique (cmte_id, cycle, size);
-- Create indices on aggregate
create index ofec_sched_a_aggregate_size_cmte_id on ofec_sched_a_aggregate_tmp(cmte_id);
create index ofec_sched_a_aggregate_size_cycle on ofec_sched_a_aggregate_tmp(cycle);
create index ofec_sched_a_aggregate_size_size on ofec_sched_a_aggregate_tmp(size);
create index ofec_sched_a_aggregate_size_total on ofec_sched_a_aggregate_tmp(total);
create index ofec_sched_a_aggregate_size_count on ofec_sched_a_aggregate_size(count);
create index ofec_sched_a_aggregate_size_cmte_id_cycle on ofec_sched_a_aggregate_size(cmte_id, cycle);

