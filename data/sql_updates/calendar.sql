-- Makes a master calendar form several FEC tables getting as much metadata as possible
-- See helper and cleaning functions in data/functions/calendar.sql
drop materialized view if exists ofec_omnibus_dates_mv_tmp;
create or replace view ofec_dates_v as
 (
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
    from fecapp.cal_event
    join fecapp.cal_event_category using (cal_event_id)
    join fecapp.cal_category using (cal_category_id)
    where
        active = 'Y'
);
