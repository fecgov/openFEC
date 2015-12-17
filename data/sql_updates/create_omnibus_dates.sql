CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- for running locally

create or replace function expand_office_description(acronym text)
returns text as $$
    begin
        return case acronym
            when 'P' then 'Presidential'
            when 'S' then 'Senate'
            when 'H' then 'House'
            else ''
        end;
    end
$$ language plpgsql;


create or replace function expand_election_type(acronym text)
returns text as $$
    begin
        return case acronym
            when 'P' then 'Primary'
            when 'PR' then 'Primary runoff'
            when 'SP' then 'Special primary'
            when 'SPR' then 'Special primary runoff'
            when 'G' then 'General'
            when 'GR' then 'General runoff'
            when 'SG' then 'Special general'
            when 'SGR' then 'Special general runoff'
            when 'O' then 'Other'
            when 'C' then 'Convention'
            when 'SC' then 'Special convention'
            when 'R' then 'Runoff'
            when 'SR' then 'Special runoff'
            when 'S' then 'Special'
            when 'E' then 'Recount'
            else ''
        end;
    end
$$ language plpgsql;

--
create or replace function generate_election_title(trc_election_type_id text, office_sought text, state bigint,  election_states text[])
returns text as $$
    begin
        return case when state > 1 then
            'Election ' || expand_office_description(office_sought) || ' multi-state'
        else expand_office_description(office_sought) || ' ' || expand_election_type(trc_election_type_id) || ' ' ||
            array_to_string(election_states, ', ')
        end;
    end
$$ language plpgsql;

-- add party
create or replace function generate_election_discription(trc_election_type_id text, office_sought text, election_states text[])
returns text as $$
    begin
        return case when trc_election_type_id='G' and election_states is not null then
            expand_office(office_sought) || ' ' || 'General ' || array_to_string(election_states, ', ')
        else expand_office_description(office_sought) || ' ' ||
            expand_election_type(trc_election_type_id) || ' ' || array_to_string(election_states, ', ')
        end;
    end
$$ language plpgsql;




drop materialized view if exists ofec_omnibus_dates_mv_tmp;
create materialized view ofec_omnibus_dates_mv_tmp as
with elections as (
    select
        uuid_generate_v1mc() as idx,
        'election-' || trc_election_type_id as category,
        generate_election_title(trc_election_type_id::text, office_sought::text, count(election_state)::int, array_agg(election_state order by election_state)::text[]) as description,
        generate_election_discription(trc_election_type_id::text, office_sought::text, array_agg(election_state order by election_state)::text[]) as summary,
        array_agg(election_state order by election_state)::text[] as states,
        null as location,
        election_date::timestamp as start_date,
        null::timestamp as end_date
    from trc_election
    where
        trc_election_status_id = 1
    group by
        office_sought,
        election_date,
        trc_election_type_id
    -- getting rid of this for now by looking for non-existent election type
    -- I don't understand why I can't just delete the union all and the next select but it errors
    union all
    select
        uuid_generate_v1mc() as idx,
        'election-' || trc_election_type_id as category,
        expand_office(office_sought) || ' ' || expand_election_type(trc_election_type_id) as description,
        expand_office(office_sought) || ' ' ||
            expand_election_type(trc_election_type_id) || ' ' ||
            election_state as summary,
        array[election_state]::text[] as states,
        null as location,
        election_date::timestamp as start_date,
        null::timestamp as end_date
    from trc_election
    where
        trc_election_type_id = 'xxx'
), reports_raw as (
    select * from trc_report_due_date reports
    left join dimreporttype on reports.report_type = dimreporttype.rpt_tp
    left join trc_election using (trc_election_id)
    where coalesce(trc_election_status_id, 1) = 1
), reports as (
    select
        uuid_generate_v1mc() as idx,
        'report-' || rpt_tp as category,
        rpt_tp_desc::text as description,  -- TODO: Implement
        '' as summary,     -- TODO: Implement
        array_agg(election_state)::text[] as states,
        null as location,
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
        uuid_generate_v1mc() as idx,
        'report-' || rpt_tp as category,
        rpt_tp_desc::text as description,
        '' as summary,
        array[election_state]::text[] as states,
        null as location,
        due_date::timestamp as start_date,
        null::timestamp as end_date
    from reports_raw
    where trc_election_type_id != 'G'
), other as (
    select
        uuid_generate_v1mc() as idx,
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
)
select * from elections
union all
select * from reports
union all
select * from other
;