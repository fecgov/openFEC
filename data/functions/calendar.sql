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
    -- FL: House General Election Held Today
    -- NH, DE: DEM Convention Held Today
    -- General Election Multi-state Held Today
create or replace function generate_election_description(trc_election_type_id text, office_sought text, contest text[], party text, trc_election_id numeric)
returns text as $$
    begin
        return case
        when array_length(contest, 1) > 3 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric),
                'Multi-state',
                'Held Today'
            ], ' ')
        when array_length(contest, 1) = 0 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric),
                'Held Today'
            ], ' ')
        else array_to_string(
            array[
                array_to_string(contest, ', ') || ':',
                party,
                office_sought,
                expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric),
                'Held Today'
            ], ' ')
        end;
    end
$$ language plpgsql;


-- Trying to make the names flow together as best as possible
-- Like:
    -- FL: House General Election Held Today
    -- NH, DE: DEM Convention Held Today
    -- General Election Held today States: NY, CA, FL, LA
create or replace function generate_election_summary(trc_election_type_id text, office_sought text, contest text[], party text, trc_election_id numeric)
returns text as $$
    begin
        return case
        when array_length(contest, 1) > 3 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric),
                'Held Today',
                'Contests:',
                array_to_string(contest, ', ')
            ], ' ')
        when array_length(contest, 1) = 0 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric),
                'Held Today'
            ], ' ')
        else array_to_string(
            array[
                array_to_string(contest, ', ') || ':',
                party,
                office_sought,
                expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric),
                'Held Today'
            ], ' ')
        end;
    end
$$ language plpgsql;



-- Not all report types are on dimreporttype, so for the reports to all have
-- titles, I am adding a case. Ideally, we would want the right mapping.
create or replace function generate_report_description(office_sought text, report_type text, rpt_tp_desc text, contest text[])
returns text as $$
    begin
        return case
            when rpt_tp_desc is null and array_length(contest, 1) > 3 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    'Report Multi-state Due Today'
                ], ' ')
            when rpt_tp_desc is null and array_length(contest, 1) = 0 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    'Report Due Today'
                ], ' ')
            when rpt_tp_desc is null then
                array_to_string(
                array[
                    array_to_string(contest, ', ') || ':',
                    expand_office_description(office_sought),
                    report_type,
                    'Report Due Today'
                ], ' ')
            when array_length(contest, 1) < 3 and array_length(contest, 1) >= 1 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report Multi-state Due Today'
                ], ' ')
            when array_length(contest, 1) = 0 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report Due Today'
                ], ' ')
            else
                array_to_string(
                array[
                    array_to_string(contest, ', ') || ':',
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report Due Today'
                ], ' ')
        end;
    end
$$ language plpgsql;



-- Not all report types are on dimreporttype, so for the reports to all have
-- titles, I am adding a case. Ideally, we would want the right mapping.
create or replace function generate_report_summary(office_sought text, report_type text, rpt_tp_desc text, report_contest text[])
returns text as $$
    begin
        return case
            when rpt_tp_desc is null and array_length(report_contest, 1) < 3 and array_length(report_contest, 1) >= 1 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    'Due Today',
                    'States:',
                    array_to_string(report_contest, ', ')
                ], ' ')
            when rpt_tp_desc is null and array_length(report_contest, 1) < 1 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    'Report Due Today'
                ], ' ')
            when rpt_tp_desc is null then
                array_to_string(
                array[
                    array_to_string(report_contest, ', ') || ':',
                    expand_office_description(office_sought),
                    report_type,
                    'Report Due Today'
                ], ' ')
            when array_length(report_contest, 1) < 3 and array_length(report_contest, 1) >= 1 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report Due Today',
                    'States:',
                    array_to_string(report_contest, ', ')
                ], ' ')
            when array_length(report_contest, 1) = 0 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report Due Today'
                ], ' ')
            else
                array_to_string(
                array[
                    array_to_string(report_contest, ', ') || ':',
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report Due Today'
                ], ' ')
        end;
    end
$$ language plpgsql;




