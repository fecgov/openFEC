-- Makes a master calendar form several FEC tables getting as much metadata as possible
-- See helper and cleaning functions in data/functions/calendar.sql
drop materialized view if exists ofec_omnibus_dates_mv;
create or replace view ofec_dates_vw as
 (
    -- most data comes from cal_event and is imported as is, it does not have state filtering.
    select distinct on (category_name, event_name, description, location, start_date, end_date)
        cal_event_id,
        category_name::text as category,
        event_name::text as summary,
        describe_cal_event(category_name::text, event_name::text, description::text) as description,
        null::text[] as states,
        location::text,
        start_date,
        end_date,
        use_time = 'N' as all_day,
        url,
        to_tsvector(event_name) as summary_text,
        to_tsvector(describe_cal_event(category_name::text, event_name::text, description::text)) as description_text,
        cal_category_id as calendar_category_id
    from fecapp.cal_event
    join fecapp.cal_event_category using (cal_event_id)
    join fecapp.cal_category using (cal_category_id)
    where
        -- the status of 3 narrows down the events to those that a published
        cal_event_status_id = 3 and
        active = 'Y'
);

drop function if exists expand_election_type_caucus_convention_clean(trc_election_type_id text, trc_election_id numeric);
drop function if exists expand_election_type_plurals(acronym text);
drop function if exists create_election_description(election_type text, office_sought text, contest text[], party text, election_notes text);
drop function if exists create_election_summary(election_type text, office_sought text, contest text[], party text, election_notes text);
drop function if exists create_report_description(office_sought text, report_type text, rpt_tp_desc text, contest text[], election_notes text);
drop function if exists create_report_summary(office_sought text, report_type text, rpt_tp_desc text, report_contest text[], election_notes text);
drop function if exists create_24hr_text(rp_election_text text, ie_24hour_end date);
drop function if exists create_48hr_text(rp_election_text text, ie_48hour_end date);
drop function if exists create_electioneering_text(rp_election_text text, ec_end date);
drop function if exists add_reporting_states(election_state text[], report_type text);
drop function if exists create_reporting_link(due_date timestamp);
