-- this is a short term fix to correct a coding error where the code C was used for caucuses and conventions
create or replace function expand_election_type_caucus_convention_clean(trc_election_type_id text, trc_election_id numeric)
returns text as $$
    begin
        return case
            when trc_election_id in (1978, 1987, 2020, 2023, 2032, 2041, 2052, 2065, 2100, 2107, 2144, 2157, 2310, 2313, 2314, 2316, 2321, 2323, 2325, 2326, 2328, 2338, 2339, 2341)
                then 'Caucus'
            when trc_election_id in (2322, 2329, 2330, 2331, 2334, 2335, 2336, 2337, 2340)
                then 'Convention'
            else
                expand_election_type(trc_election_type_id)
        end;
    end
$$ language plpgsql;


--Descriptions and summaries are repetitive, so we are trying to only show the descriptions in some places, That works for most things except court cases, advisory opinions and conferences.
create or replace function describe_cal_event(event_name text, summary text, description text)
returns text as $$
    begin
        return case
            when event_name in ('Litigation', 'AOs and Rules', 'Conferences') then
                summary || ' ' || description
            else
                description
        end;
    end
$$ language plpgsql;


-- Trying to make the names flow together as best as possible
-- To keep the titles concise states are abbreviated as multi state if there is more than one
-- Like:
    -- FL House General Election
    -- NH DEM Convention
    -- General Election Multi-state
create or replace function generate_election_title(trc_election_type_id text, office_sought text, contest text[], party text, trc_election_id numeric)
returns text as $$
    begin
        return case
        when array_length(contest, 1) > 3 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric),
                'Multi-state'::text,
                'held today'
            ], ' ')
        when array_length(contest, 1) = 0 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric),
                'held today'
            ], ' ')
        else array_to_string(
            array[
                array_to_string(contest, ', ') || ':',
                party,
                office_sought,
                expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric),
                'held today'
            ], ' ')
        end;
    end
$$ language plpgsql;


-- Not all report types are on dimreporttype, so for the reports to all have
-- titles, I am adding a case. Ideally, we would want the right mapping.
create or replace function name_reports(office_sought text, report_type text, rpt_tp_desc text, election_state text[])
returns text as $$
    begin
        return case
            when rpt_tp_desc is null and array_length(election_state, 1) > 3 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    'report multi-state due today'
                ], ' ')
            when pt_tp_desc is null and array_length(election_state, 1) = 0 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    'due today'
                ], ' ')
            when rpt_tp_desc is null then
                array_to_string(
                array[
                    array_to_string(election_state, ', ') || ':',
                    expand_office_description(office_sought),
                    report_type,
                    'due today'
                ], ' '
            when array_length(election_state, 1) > 3 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'report multi-state due today'
                ], ' ')
            when array_length(election_state, 1) = 0 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'due today'
                ], ' ')
            else
                array_to_string(
                array[
                    array_to_string(election_state, ', ') || ':',
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'due today'
                ], ' ')
        end;
    end
$$ language plpgsql;


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
        end as contest
    from
        trc_election
    where
        trc_election_status_id = 1
), elections as (
    select
        'election'::text as category,
        generate_election_title(
            trc_election_type_id::text,
            expand_office_description(office_sought::text),
            array_agg(contest order by contest)::text[],
            dp.party_affiliation_desc::text,
            trc_election_id::numeric
        ) as description,
        array_to_string(array[
                dp.party_affiliation_desc::text,
                expand_office_description(office_sought::text),
                expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric),
                array_to_string(array_agg(contest order by contest)::text[], ', '),
                'held today'
        ], ' ') as summary,
        array_agg(election_state order by election_state)::text[] as states,
        null::text as location,
        election_date::timestamp as start_date,
        null::timestamp as end_date,
        true as all_day,
        null::text as url
    from elections_raw
        left join dimparty dp on elections_raw.election_party = dp.party_affiliation
    group by
        contest,
        office_sought,
        election_date,
        dp.party_affiliation_desc,
        trc_election_type_id,
        trc_election_id
), reports_raw as (
    select * from trc_report_due_date reports
    left join dimreporttype on reports.report_type = dimreporttype.rpt_tp
    left join elections_raw using (trc_election_id)
    where
        coalesce(trc_election_status_id, 1) = 1
), reports as (
    select
        'report-' || report_type as category,
        name_reports(
            office_sought::text,
            report_type::text,
            clean_report(rpt_tp_desc::text),
            array_agg(election_state)::text[]
        ) as description,
        array_to_string(array[
            expand_office_description(office_sought::text),
            clean_report(rpt_tp_desc::text),
            array_to_string(array_agg(election_state order by election_state)::text[], ', '),
            'due today'
        ], ' ') as summary,
        array_agg(election_state)::text[] as states,
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
