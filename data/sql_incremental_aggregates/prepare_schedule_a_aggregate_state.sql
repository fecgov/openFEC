-- Drop the old functions if they still exist.
drop function if exists ofec_sched_a_update_aggregate_state();
DROP MATERIALIZED VIEW IF EXISTS ofec_sched_a_aggregate_state_recipient_totals_mv;

-- Create initial aggregate
drop table if exists ofec_sched_a_aggregate_state_tmp;
create table ofec_sched_a_aggregate_state_tmp as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    contbr_st as state,
    expand_state(contbr_st) as state_full,
    sum(contb_receipt_amt) as total,
    count(contb_receipt_amt) as count
from fec_fitem_sched_a_vw
where
    rpt_yr >= :START_YEAR_AGGREGATE and
    is_unitemized(memo_text::text) = false
and contb_receipt_amt is not null
and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id, cmte_id)
group by cmte_id, cycle, state
;

alter table ofec_sched_a_aggregate_state_tmp add column idx serial;
alter table ofec_sched_a_aggregate_state_tmp add constraint uq_ofec_sched_a_aggregate_state_tmp_cmte_id_cycle_state unique (cmte_id, cycle, state);

-- Create indices on aggregate
create index ofec_sched_a_aggregate_state_tmp_cmte_id on ofec_sched_a_aggregate_state_tmp(cmte_id);
create index ofec_sched_a_aggregate_state_tmp_cycle on ofec_sched_a_aggregate_state_tmp(cycle);
create index ofec_sched_a_aggregate_state_tmp_state on ofec_sched_a_aggregate_state_tmp(state);
create index ofec_sched_a_aggregate_state_tmp_state_full on ofec_sched_a_aggregate_state_tmp(state_full);
create index ofec_sched_a_aggregate_state_tmp_total on ofec_sched_a_aggregate_state_tmp(total);
create index ofec_sched_a_aggregate_state_tmp_count on ofec_sched_a_aggregate_state_tmp(count);
create index ofec_sched_a_aggregate_state_tmp_cycle_cmte_id on ofec_sched_a_aggregate_state_tmp(cycle, cmte_id);

-- Remove previous aggregate and rename new aggregate
drop table if exists ofec_sched_a_aggregate_state;
alter table ofec_sched_a_aggregate_state_tmp rename to ofec_sched_a_aggregate_state;
select rename_indexes('ofec_sched_a_aggregate_state');

-- Create update function
create or replace function ofec_sched_a_update_aggregate_state() returns void as $$
begin
    with new as (
        select 1 as multiplier, cmte_id, rpt_yr, contbr_st, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_new
    ),
    old as (
        select -1 as multiplier, cmte_id, rpt_yr, contbr_st, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contbr_st as state,
            expand_state(contbr_st) as state_full,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id, cmte_id)
        group by cmte_id, cycle, state
    ),
    inc as (
        update ofec_sched_a_aggregate_state ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.state) = (patch.cmte_id, patch.cycle, patch.state)
    )
    insert into ofec_sched_a_aggregate_state (
        select patch.* from patch
        left join ofec_sched_a_aggregate_state ag using (cmte_id, cycle, state)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
