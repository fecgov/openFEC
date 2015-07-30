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
from sched_a
where rpt_yr >= :START_YEAR_ITEMIZED
and contb_receipt_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, size
;

-- Create indices on aggregate
create index on ofec_sched_a_aggregate_size (cmte_id);
create index on ofec_sched_a_aggregate_size (cycle);
create index on ofec_sched_a_aggregate_size (size);
create index on ofec_sched_a_aggregate_size (total);
create index on ofec_sched_a_aggregate_size (count);
