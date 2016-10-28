-- Schedule A summary of individual contributions by state raised for each committee type per cycle.
drop table if exists ofec_sched_a_aggregate_state_recipient_totals_tmp;

create table ofec_sched_a_aggregate_state_recipient_totals_tmp as
with grouped_totals as (
    select
        sum(agg_st.total) as total,
        agg_st.cycle,
        agg_st.state,
        cd.committee_type,
        cd.committee_type_full
    from
        ofec_sched_a_aggregate_state as agg_st
    join
        ofec_committee_detail_mv_tmp as cd
    on (agg_st.cmte_id = cd.committee_id)
    where
        agg_st.state in (
            select "Official USPS Code"
            from ofec_fips_states
        )
    group by
        agg_st.cycle,
        agg_st.state,
        cd.committee_type,
        cd.committee_type_full
),
overall_total as (
    select
        sum(totals.total) as total,
        totals.cycle,
        totals.state,
        ' '::text as committee_type,
        'All'::text as committee_type_full
    from
        grouped_totals as totals
    group by
        totals.cycle,
        totals.state
),
combined as (
    select * from grouped_totals
    union all
    select * from overall_total
)

select
    row_number() over () as idx,
    combined.*
from
    combined
order by
    combined.state
;

create unique index on ofec_sched_a_aggregate_state_recipient_totals_tmp (idx);

create index on ofec_sched_a_aggregate_state_recipient_totals_tmp (total, idx);
create index on ofec_sched_a_aggregate_state_recipient_totals_tmp (cycle, idx);
create index on ofec_sched_a_aggregate_state_recipient_totals_tmp (state, idx);
create index on ofec_sched_a_aggregate_state_recipient_totals_tmp (committee_type, idx);
create index on ofec_sched_a_aggregate_state_recipient_totals_tmp (committee_type_full, idx);

-- Remove previous aggregate total table and rename new aggregate total table.
drop table if exists ofec_sched_a_aggregate_state_recipient_totals;
alter table ofec_sched_a_aggregate_state_recipient_totals_tmp rename to ofec_sched_a_aggregate_state_recipient_totals;
