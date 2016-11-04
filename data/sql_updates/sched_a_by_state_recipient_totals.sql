-- Schedule A summary of individual contributions by state raised for each committee type per cycle.
drop materialized view if exists ofec_sched_a_aggregate_state_recipient_totals_mv_tmp;

create materialized view ofec_sched_a_aggregate_state_recipient_totals_mv_tmp as
with grouped_totals as (
    select
        sum(agg_st.total) as total,
        count(agg_st.total) as count,
        agg_st.cycle,
        agg_st.state,
        agg_st.state_full,
        cd.committee_type,
        cd.committee_type_full
    from
        ofec_sched_a_aggregate_state as agg_st
    join
        ofec_committee_detail_mv_tmp as cd
    on
        agg_st.cmte_id = cd.committee_id
    where
        agg_st.state in (
            select
                "Official USPS Code"
            from
                ofec_fips_states

            -- NOTE:  If we ever need to account for the FIPS numeric codes,
            --        we can do so with this subquery instead.

            --select
            --    "FIPS State Numeric Code"::text as state_codes
            --from
            --    ofec_fips_states
            --union all
            --select
            --    "Official USPS Code"::text as state_codes
            --from
            --    ofec_fips_states
        )
    group by
        agg_st.cycle,
        agg_st.state,
        agg_st.state_full,
        cd.committee_type,
        cd.committee_type_full
),
candidate_totals as (
    select
        sum(totals.total) as total,
        sum(totals.count) as count,
        totals.cycle,
        totals.state,
        totals.state_full,
        'ALL_CANDIDATES'::text as committee_type,
        'All Candidates'::text as committee_type_full
    from
        grouped_totals as totals
    where
        totals.committee_type in ('H', 'S', 'P')
    group by
        totals.cycle,
        totals.state,
        totals.state_full
),
pacs_totals as (
    select
        sum(totals.total) as total,
        sum(totals.count) as count,
        totals.cycle,
        totals.state,
        totals.state_full,
        'ALL_PACS'::text as committee_type,
        'All PACs'::text as committee_type_full
    from
        grouped_totals as totals
    where
        totals.committee_type in ('N', 'O', 'Q', 'V', 'W')
    group by
        totals.cycle,
        totals.state,
        totals.state_full
),
overall_total as (
    select
        sum(totals.total) as total,
        sum(totals.count) as count,
        totals.cycle,
        totals.state,
        totals.state_full,
        'ALL'::text as committee_type,
        'All'::text as committee_type_full
    from
        grouped_totals as totals
    group by
        totals.cycle,
        totals.state,
        totals.state_full
),
combined as (
    select * from grouped_totals
    union all
    select * from candidate_totals
    union all
    select * from pacs_totals
    union all
    select * from overall_total
    order by
        state, cycle, committee_type
)

select
    row_number() over () as idx,
    combined.*
from
    combined
;

create unique index on ofec_sched_a_aggregate_state_recipient_totals_mv_tmp (idx);

create index on ofec_sched_a_aggregate_state_recipient_totals_mv_tmp (total, idx);
create index on ofec_sched_a_aggregate_state_recipient_totals_mv_tmp (count, idx);
create index on ofec_sched_a_aggregate_state_recipient_totals_mv_tmp (cycle, idx);
create index on ofec_sched_a_aggregate_state_recipient_totals_mv_tmp (state, idx);
create index on ofec_sched_a_aggregate_state_recipient_totals_mv_tmp (state_full, idx);
create index on ofec_sched_a_aggregate_state_recipient_totals_mv_tmp (committee_type, idx);
create index on ofec_sched_a_aggregate_state_recipient_totals_mv_tmp (committee_type_full, idx);
