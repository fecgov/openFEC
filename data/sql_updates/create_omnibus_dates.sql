


-- add party
create or replace function generate_election_title(trc_election_type_id text, office_sought text, election_states text[], party text)
returns text as $$
    begin
        return case when count(election_states) > 1 then
            expand_election_type(trc_election_type_id) || ' ' ||
            expand_office_description(office_sought) || ' ' ||
            ' multi-state'
        else expand_office_description(office_sought) || ' ' ||
            expand_office_description(office_sought) || ' ' ||
            array_to_string(election_states, ', ')
        end;
    end
$$ language plpgsql;


drop materialized view if exists ofec_omnibus_dates_mv_tmp;
create materialized view ofec_omnibus_dates_mv_tmp as
with elections as (
    -- Select all elections, grouping by...
    select
        'election-' || trc_election_type_id as category,
        generate_election_title(
            trc_election_type_id::text,
            office_sought::text,
            array_agg(election_state order by election_state)::text[],
            election_party::text
        ) as description,
        array_to_string(
            array[
                election_party,
                expand_office_description(office_sought),
                expand_election_type(trc_election_type_id),
                -- TODO add a check to see if there are states
                'states: ' || array_to_string(array_agg(election_state order by election_state)::text[], ', ')
            ], ' '
        ) as summary,
        array_agg(election_state order by election_state)::text[] as states,
        null::text as location,
        election_date::timestamp as start_date,
        null::timestamp as end_date
    from trc_election
    where
        trc_election_status_id = 1
    group by
        office_sought,
        election_date,
        election_party,
        trc_election_type_id
), reports_raw as (
    select * from trc_report_due_date reports
    left join dimreporttype on reports.report_type = dimreporttype.rpt_tp
    left join trc_election using (trc_election_id)
    where coalesce(trc_election_status_id, 1) = 1
), reports as (
    select
        'report-' || rpt_tp as category,
        rpt_tp_desc::text as description,  -- TODO: Implement
        rpt_tp_desc::text || ' ' || office_sought::text as summary,     -- TODO: Implement
        array_agg(election_state)::text[] as states,
        null::text as location,
        due_date::timestamp as start_date,
        null::timestamp as end_date
    from reports_raw
    where trc_election_type_id = 'G'
    group by
        rpt_tp,
        rpt_tp_desc,
        due_date,
        office_sought
    union all
    select
        'report-' || rpt_tp as category,
        rpt_tp_desc::text as description,
        '' as summary,
        array[election_state]::text[] as states,
        null::text as location,
        due_date::timestamp as start_date,
        null::timestamp as end_date
    from reports_raw
    where coalesce(trc_election_type_id, '') != 'G'
), other as (
    select
        category_name as category,
        event_name::text as description,
        description::text,
        null::text[] as states,
        location::text,
        start_date,
        end_date
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
