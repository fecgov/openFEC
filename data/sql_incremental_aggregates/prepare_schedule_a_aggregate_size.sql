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
drop table if exists ofec_sched_a_aggregate_size cascade;
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

alter table ofec_sched_a_aggregate_size_tmp add constraint uq_ofec_sched_a_aggregate_size_tmp_cmte_id_cycle_size unique (cmte_id, cycle, size);
-- Create indices on aggregate
create index ofec_sched_a_aggregate_size_tmp_cmte_id on ofec_sched_a_aggregate_size_tmp(cmte_id);
create index ofec_sched_a_aggregate_size_tmp_cycle on ofec_sched_a_aggregate_size_tmp(cycle);
create index ofec_sched_a_aggregate_size_tmp_size on ofec_sched_a_aggregate_size_tmp(size);
create index ofec_sched_a_aggregate_size_tmp_total on ofec_sched_a_aggregate_size_tmp(total);
create index ofec_sched_a_aggregate_size_tmp_count on ofec_sched_a_aggregate_size_tmp(count);
create index ofec_sched_a_aggregate_size_tmp_cmte_id_cycle on ofec_sched_a_aggregate_size_tmp(cmte_id, cycle);

drop table if exists ofec_sched_a_aggregate_size cascade;
alter table ofec_sched_a_aggregate_size_tmp rename to ofec_sched_a_aggregate_size;
select rename_indexes('ofec_sched_a_aggregate_size');
