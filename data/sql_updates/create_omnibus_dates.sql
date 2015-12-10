drop materialized_view if exists ofec_omnibus_dates_mv_tmp
create materialized view ofec_omnibus_dates_mv_tmp as
with elections as (
    -- TODO: Hide state names for general elections
    -- TODO: Add district if applicable
    select
        expand_office(office_sought) || ' General' as title,
        expand_office(office_sought) || ' ' ||
            'General ' ||
            string_agg(election_state, ', ') as description,
        array_agg(election_state order by election_state) as states,
        null as location,
        election_date as start_date,
        null as end_date
    from trc_election
    where
        trc_election_type_id = 'G' and
        trc_election_status_id = 1 and
        election_state is not null and
        office_sought is not null
    group by
        office_sought,
        election_date
    union all
    select
        expand_office(office_sought) || ' ' || expand_election_type(trc_election_type_id) as title,
        expand_office(office_sought) || ' ' ||
            expand_election_type(trc_election_type_id) || ' ' ||
            election_state as description,
        array[election_state] as states,
        null as location,
        election_date as start_date,
        null as end_date
    from trc_election
    where
        trc_election_type_id != 'G' and
        trc_election_status_id = 1 and
        election_state is not null and
        office_sought is not null
), reports_raw as (
    select * from trc_report_due_date reports
    left join dimreporttype on reports.report_type = dimreporttype.rpt_tp
    left join trc_election using (trc_election_id)
    where coalesce(trc_election_status_id, 1) = 1
), reports as (
    select
        rpt_tp_desc as title,  -- TODO: Implement
        '' as description,     -- TODO: Implement
        null as location,
        array_agg(election_state) as states,
        due_date as start_date,
        null as end_date
    from reports_raw
    where trc_election_type_id = 'G'
    group by
        rpt_tp_desc,
        due_date,
        office_sought
    union all
    select
        rpt_tp_desc as title,
        '' as description,
        null as location,
        array[election_state] as states,
        due_date as start_date,
        null as end_date
    from reports_raw
    where trc_election_type_id != 'G'
)
select * from elections
union all
select * from reports
;

-- approximate table structure
-- title
-- description
-- location [nullable]
-- states [nullable]
-- start_date
-- end_date [nullable]
