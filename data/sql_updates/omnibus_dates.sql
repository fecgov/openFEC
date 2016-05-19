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
        expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric) as election_type,
        dp.party_affiliation_desc as party
    from trc_election
    left join dimparty dp on trc_election.election_party = dp.party_affiliation
    where
        trc_election_status_id = 1
), elections as (
    select
        'election'::text as category,
        generate_election_description(
            election_type::text,
            expand_office_description(office_sought::text),
            array_agg(contest order by contest)::text[],
            party::text
        ) || ' is Held Today.' as description,
        generate_election_summary(
            election_type::text,
            expand_office_description(office_sought::text),
            array_agg(contest order by contest)::text[],
            party::text
        ) || ' is Held Today.' as summary,
        array_remove(array_agg(election_state order by election_state)::text[], null) as states,
        null::text as location,
        election_date::timestamp as start_date,
        null::timestamp as end_date,
        true as all_day,
        null::text as url
    from elections_raw
    group by
        office_sought,
        election_date,
        party,
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
), reporting_periods_raw as (
    select
        *,
        elections_raw.contest as rp_contest,
        elections_raw.election_state as rp_state,
        elections_raw.election_type as rp_election_type,
        elections_raw.office_sought as rp_office,
        elections_raw.party as rp_party
    from
        trc_election_dates
    left join elections_raw using (trc_election_id)
), start_24hr as(
    select
        'IE Periods'::text as category,
        generate_24hr_text(
            generate_election_summary(
                rp_election_type::text,
                expand_office_description(rp_office::text),
                array_agg(rp_contest order by rp_contest)::text[],
                rp_party::text
            )::text,
            ie_48hour_end::date
        ) as summary,
        generate_24hr_text(
            generate_election_description(
                rp_election_type::text,
                expand_office_description(rp_office::text),
                array_agg(rp_contest order by rp_contest)::text[],
                rp_party::text
            )::text,
            ie_48hour_end::date
        ) as description,
        -- duplicate state problem for some reason
        array_remove(array_agg(rp_state order by rp_state)::text[], null) as states,
        null::text as location,
        f48hour_start::timestamp as start_date,
        null::timestamp as end_date,
        true as all_day,
        -- re create these links later
        null::text as url
    from reporting_periods_raw
    group by
        f48hour_start,
        ie_48hour_end,
        rp_office,
        rp_election_type,
        rp_party
), electioneering as(
    select
        'EC Periods'::text as category,
        generate_electioneering_text(
            generate_election_summary(
                rp_election_type::text,
                expand_office_description(rp_office::text),
                array_agg(rp_contest order by rp_contest)::text[],
                rp_party::text
            )::text,
            ec_end::date
        ) as summary,
        generate_electioneering_text(
            generate_election_description(
                rp_election_type::text,
                expand_office_description(rp_office::text),
                array_agg(rp_contest order by rp_contest)::text[],
                rp_party::text
            )::text,
            ec_end::date
        ) as description,
        -- duplicate state problem for some reason
        array_remove(array_agg(rp_state order by rp_state)::text[], null) as states,
        null::text as location,
        ec_start::timestamp as start_date,
        null::timestamp as end_date,
        true as all_day,
        -- re create these links later
        null::text as url
    from reporting_periods_raw
    group by
        ec_start,
        ec_end,
        rp_office,
        rp_election_type,
        rp_party
), other as (
    -- most data comes from cal_event and is imported as is, it does not have state filtering.
    select distinct on (category_name, event_name, description, location, start_date, end_date)
        category_name::text as category,
        event_name::text as summary,
        describe_cal_event(category_name::text, event_name::text, description::text) as description,
        null::text[] as states,
        location::text,
        start_date,
        end_date,
        use_time = 'N' as all_day,
        url
    from cal_event
    join cal_event_category using (cal_event_id)
    join cal_category using (cal_category_id)
    where
        -- when successful add 'IE Periods' and 'EC Periods'
        category_name not in ('Election Dates', 'Reporting Deadlines', 'Quarterly', 'Monthly', 'Pre and Post-Elections', 'IE Periods', 'EC Periods') and
        active = 'Y'
), combined as (
    select * from elections
    union all
    select * from reports
    union all
    select * from start_24hr
    union all
    select * from electioneering
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
