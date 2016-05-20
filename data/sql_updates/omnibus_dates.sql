-- Makes a master calendar form several FEC tables getting as much metadata as possible
-- See helper and cleaning functions in data/functions/calendar.sql
drop materialized view if exists ofec_omnibus_dates_mv_tmp;
create materialized view ofec_omnibus_dates_mv_tmp as
with elections_raw as(
    select
        *,
        -- Create House State-district info when available
        case
            when office_sought = 'H' and election_district != ' ' then array_to_string(
                array[
                    election_state,
                    election_district
                ], '-')
            else election_state
        end as contest,
        -- check and correct bad codes
        expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric) as election_type
    from
        trc_election
    where
        trc_election_status_id = 1
), elections as (
    select
        'election'::text as category,
        generate_election_description(
            election_type::text,
            expand_office_description(office_sought::text),
            array_agg(contest order by contest)::text[],
            rp.pty_desc::text
        ) as description,
        generate_election_summary(
            election_type::text,
            expand_office_description(office_sought::text),
            array_agg(contest order by contest)::text[],
            rp.pty_desc::text
        ) as summary,
        array_remove(array_agg(election_state order by election_state)::text[], null) as states,
        null::text as location,
        election_date::timestamp as start_date,
        null::timestamp as end_date,
        true as all_day,
        null::text as url
    from elections_raw
        left join ref_pty rp on elections_raw.election_party = rp.pty_cd
    group by
        office_sought,
        election_date,
        rp.pty_desc,
        election_type
), reports_raw as (
    select
         *,
        -- Create House State-district info when available
        case
            when office_sought = 'H' and election_district != ' ' then array_to_string(
                array[
                    elections_raw.election_state,
                    elections_raw.election_district
                ], '-')
            else elections_raw.election_state
        end as report_contest
    from trc_report_due_date reports
    left join dimreporttype on reports.report_type = dimreporttype.rpt_tp
    left join elections_raw using (trc_election_id)
    where
        coalesce(trc_election_status_id, 1) = 1
), reports as (
    select
        'report-' || report_type as category,
        generate_report_description(
            office_sought::text,
            report_type::text,
            clean_report(rpt_tp_desc::text),
            array_agg(report_contest order by report_contest)::text[]
        ) as description,
        generate_report_summary(
            office_sought::text,
            report_type::text,
            clean_report(rpt_tp_desc::text),
            array_agg(report_contest order by report_contest)::text[]
        ) as summary,
        array_remove(array_agg(election_state)::text[], null) as states,
        null::text as location,
        due_date::timestamp as start_date,
        null::timestamp as end_date,
        true as all_day,
        null::text as url
    from reports_raw
    where
        -- exclude pre-primary presidential reports in even years, realistically people file monthly.
        not (report_type in ('12C', '12P') and extract(year from due_date)::numeric % 2 = 0 and office_sought = 'P')
    group by
        report_type,
        rpt_tp_desc,
        due_date,
        office_sought
), other as (
    -- most data comes from cal_event and is imported as is, it does not have state filtering.
    select distinct on (category_name, event_name, description, location, start_date, end_date)
        category_name::text as category,
        event_name::text as summary,
        describe_cal_event(category_name::text, event_name::text, description::text) as description,
        array_remove(null::text[], null) as states,
        location::text,
        start_date,
        end_date,
        use_time = 'N' as all_day,
        url
    from cal_event
    join cal_event_category using (cal_event_id)
    join cal_category using (cal_category_id)
    where
        category_name not in ('Election Dates', 'Reporting Deadlines', 'Quarterly', 'Monthly', 'Pre and Post-Elections') and
        active = 'Y'
), combined as (
    select * from elections
    union all
    select * from reports
    union all
    select * from other
)
select
    row_number() over () as idx,
    combined.*,
    to_tsvector(summary) as summary_text,
    to_tsvector(description) as description_text
from combined
;

create unique index on ofec_omnibus_dates_mv_tmp (idx);

create index on ofec_omnibus_dates_mv_tmp (category);
create index on ofec_omnibus_dates_mv_tmp (location);
create index on ofec_omnibus_dates_mv_tmp (start_date);
create index on ofec_omnibus_dates_mv_tmp (end_date);

create index on ofec_omnibus_dates_mv_tmp using gin (states);
create index on ofec_omnibus_dates_mv_tmp using gin (summary_text);
create index on ofec_omnibus_dates_mv_tmp using gin (description_text);
