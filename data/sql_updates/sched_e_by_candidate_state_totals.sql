drop materialized view if exists ofec_cand_state_totals_mv_tmp;
create materialized view ofec_cand_state_totals_mv_tmp as
with records as (
    select
        cmte_id,
        s_o_cand_id as cand_id,
        s_o_ind as support_oppose_indicator,
        s_o_cand_office_st as candidate_state,
        committee_type,
        rpt_yr,
        rpt_tp,
        memo_cd,
        exp_amt
    from
        fec_vsum_sched_e
    join
        ofec_committee_detail_mv as cd
    on
        cmte_id = cd.committee_id
    where
        candidate_state in (
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
    union all
    select
        f57.filer_cmte_id as cmte_id,
        f57.s_o_cand_id as cand_id,
        f57.s_o_ind as support_oppose_indicator,
        f57.s_o_cand_office_st as candidate_state,
        committee_type,
        f5.rpt_yr,
        f5.rpt_tp,
        null as memo_cd,
        exp_amt
    from
        fec_vsum_f57 f57
    join
        fec_vsum_f5 f5
    on
        (f5.sub_id = f57.link_id)
    join
        ofec_committee_detail_mv as cd
    on
        f57.filer_cmte_id = cd.committee_id
    where
        candidate_state in (
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
),
processed_records as (
    select
        cmte_id,
        cand_id,
        support_oppose_indicator,
        candidate_state,
        committee_type,
        rpt_yr + rpt_yr % 2 as cycle,
        sum(exp_amt) as total,
        count(exp_amt) as count
    from
        records
    where
        exp_amt is not null and
        candidate_state is not null and
        rpt_tp not in ('24', '48') and
        (memo_cd != 'X' or memo_cd is null)
    group by
        candidate_state,
        cand_id,
        support_oppose_indicator,
        cycle
),
totals as (
    select
        sum(total) as state_total,
        candidate_state as state,
        committee_type,
        support_oppose_indicator,
        cycle,
        cand_id
    from
        processed_records
    group by
        candidate_state,
        cand_id,
        support_oppose_indicator,
        cycle
    order by
        state,
        cycle
)

select
    row_number() over () as idx,
    totals.*
from
    totals
;

create unique index on ofec_cand_state_totals_mv_tmp (idx);

create index on ofec_cand_state_totals_mv_tmp (state_total, idx);
create index on ofec_cand_state_totals_mv_tmp (state, idx);
create index on ofec_cand_state_totals_mv_tmp (committee_type, idx);
create index on ofec_cand_state_totals_mv_tmp (support_oppose_indicator, idx);
create index on ofec_cand_state_totals_mv_tmp (cycle, idx);
create index on ofec_cand_state_totals_mv_tmp (cand_id, idx);
