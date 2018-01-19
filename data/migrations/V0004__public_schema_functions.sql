SET check_function_bodies = false;
SET search_path = public, pg_catalog;

--
-- Name: add_index_suffix(text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION add_index_suffix(p_table_name text, suffix text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
    indexes_cursor CURSOR FOR
        SELECT indexname AS name
        FROM pg_indexes
        WHERE tablename = p_table_name;
BEGIN
    FOR index_name IN indexes_cursor LOOP
        EXECUTE format('ALTER INDEX %1$I RENAME TO %2$I', index_name.name,  index_name.name || suffix);
    END LOOP;
END
$_$;


ALTER FUNCTION public.add_index_suffix(p_table_name text, suffix text) OWNER TO fec;

--
-- Name: add_partition_cycles(numeric, numeric); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION add_partition_cycles(start_year numeric, amount numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    first_cycle_end_year NUMERIC = get_cycle(start_year);
    last_cycle_end_year NUMERIC = first_cycle_end_year + (amount - 1) * 2;
    master_table_name TEXT;
    child_table_name TEXT;
    schedule TEXT;
BEGIN
    FOR cycle IN first_cycle_end_year..last_cycle_end_year BY 2 LOOP
        FOREACH schedule IN ARRAY ARRAY['a', 'b'] LOOP
            master_table_name = format('ofec_sched_%s_master', schedule);
            child_table_name = format('ofec_sched_%s_%s_%s', schedule, cycle - 1, cycle);
            EXECUTE format('CREATE TABLE %I (
                CHECK ( two_year_transaction_period in (%s, %s) )
            ) INHERITS (%I)', child_table_name, cycle - 1, cycle, master_table_name);
        END LOOP;
    END LOOP;
    PERFORM finalize_itemized_schedule_a_tables(first_cycle_end_year, last_cycle_end_year, FALSE, TRUE);
    PERFORM finalize_itemized_schedule_b_tables(first_cycle_end_year, last_cycle_end_year, FALSE, TRUE);
END
$$;


ALTER FUNCTION public.add_partition_cycles(start_year numeric, amount numeric) OWNER TO fec;

--
-- Name: add_reporting_states(text[], text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION add_reporting_states(election_state text[], report_type text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when
            report_type in ('M10', 'M11', 'M12', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7', 'M7S', 'M8', 'M9', 'MSA', 'MSY', 'MY', 'MYS', 'Q1', 'Q2', 'Q2S', 'Q3', 'QMS', 'QSA', 'QYE', 'QYS') then
                array['AK', 'AL', 'AR', 'AS', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'GU', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MP', 'MS', 'MT', 'NC', 'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', 'NY', 'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VA', 'VI', 'VT', 'WA', 'WI', 'WV', 'WY']
            else
                array_remove(election_state::text[], null)
        end;
    end
$$;


ALTER FUNCTION public.add_reporting_states(election_state text[], report_type text) OWNER TO fec;

--
-- Name: clean_party(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION clean_party(party text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
begin
    return regexp_replace(party, '\s*(Added|Removed|\(.*?)\)$', '');
end
$_$;


ALTER FUNCTION public.clean_party(party text) OWNER TO fec;

--
-- Name: clean_repeated(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION clean_repeated(first anyelement, second anyelement) RETURNS anyelement
    LANGUAGE plpgsql
    AS $$
begin
    return case
        when first = second then null
        else first
    end;
end
$$;


ALTER FUNCTION public.clean_repeated(first anyelement, second anyelement) OWNER TO fec;

--
-- Name: clean_report(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION clean_report(report text) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
    return trim(both from regexp_replace(report, ' {.*}', ''));
end
$$;


ALTER FUNCTION public.clean_report(report text) OWNER TO fec;

--
-- Name: contribution_size(numeric); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION contribution_size(value numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
    return case
        when abs(value) <= 200 then 0
        when abs(value) < 500 then 200
        when abs(value) < 1000 then 500
        when abs(value) < 2000 then 1000
        else 2000
    end;
end
$$;


ALTER FUNCTION public.contribution_size(value numeric) OWNER TO fec;

--
-- Name: contributor_type(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION contributor_type(value text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

begin

    return upper(value) in ('11AI', '17A');

end

$$;


ALTER FUNCTION public.contributor_type(value text) OWNER TO fec;

--
-- Name: create_24hr_text(text, date); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION create_24hr_text(rp_election_text text, ie_24hour_end date) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when
                rp_election_text like '%Runoff%' then array_to_string(
                array[
                    '24-Hour Report Period of Independent Expenditures begins for the',
                    rp_election_text,
                     '(if necessary). Ends on',
                    to_char(ie_24hour_end, 'Mon DD, YYYY') || '.'
            ], ' ')
            else
                array_to_string(
                array[
                    '24-Hour Report Period of Independent Expenditures begins for the',
                    rp_election_text || '. Ends on',
                    to_char(ie_24hour_end, 'Mon DD, YYYY') || '.'
            ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.create_24hr_text(rp_election_text text, ie_24hour_end date) OWNER TO fec;

--
-- Name: create_48hr_text(text, date); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION create_48hr_text(rp_election_text text, ie_48hour_end date) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when
                rp_election_text like '%Runoff%' then array_to_string(
                array[
                    '48-Hour Report Period of Independent Expenditures begins for the',
                    rp_election_text,
                     '(if necessary). Ends on',
                    to_char(ie_48hour_end, 'Mon DD, YYYY') || '.'
            ], ' ')
            else
                array_to_string(
                array[
                    '48-Hour Report Period of Independent Expenditures begins for the',
                    rp_election_text || '. Ends on',
                    to_char(ie_48hour_end, 'Mon DD, YYYY') || '.'
            ], ' ')
        end;
    end
$$;

ALTER FUNCTION public.create_48hr_text(rp_election_text text, ie_48hour_end date) OWNER TO fec;

--
-- Name: create_election_description(text, text, text[], text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION create_election_description(election_type text, office_sought text, contest text[], party text, election_notes text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
        when array_length(contest, 1) >= 3 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type_plurals(election_type),
                election_notes,
                'in multiple states'
            ], ' ')
        when array_length(contest, 1) = 0 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type(election_type),
                election_notes
            ], ' ')
        when array_length(contest, 1) = 1 then  array_to_string(
            array[
                array_to_string(contest, ', '),
                party,
                office_sought,
                expand_election_type(election_type),
                election_notes
            ], ' ')
        else array_to_string(
            array[
                array_to_string(contest, ', '),
                party,
                office_sought,
                expand_election_type_plurals(election_type),
                election_notes
            ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.create_election_description(election_type text, office_sought text, contest text[], party text, election_notes text) OWNER TO fec;

--
-- Name: create_election_summary(text, text, text[], text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION create_election_summary(election_type text, office_sought text, contest text[], party text, election_notes text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
        when array_length(contest, 1) >= 3 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type_plurals(election_type),
                election_notes,
                'in',
                array_to_string(contest, ', ')
            ], ' ')
        when array_length(contest, 1) = 0 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type(election_type),
                election_notes
            ], ' ')
         when array_length(contest, 1) = 1 then array_to_string(
            array[
                contest[0],
                party,
                office_sought,
                expand_election_type(election_type),
                election_notes
            ], ' ')
        else array_to_string(
            array[
                array_to_string(contest, ', '),
                party,
                office_sought,
                expand_election_type_plurals(election_type),
                election_notes
            ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.create_election_summary(election_type text, office_sought text, contest text[], party text, election_notes text) OWNER TO fec;

--
-- Name: create_electioneering_text(text, date); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION create_electioneering_text(rp_election_text text, ec_end date) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when
                rp_election_text like '%Runoff%' then array_to_string(
                array[
                    'Electioneering Communications Period begins for the',
                    rp_election_text,
                     ', if needed. Ends on Election Day-',
                    to_char(ec_end, 'Day, Mon DD, YYYY') || '.'
            ], ' ')
            else
                array_to_string(
                array[
                    'Electioneering Communications Period begins for the',
                    rp_election_text || '. Ends on Election Day-',
                    to_char(ec_end, 'Day, Mon DD, YYYY') || '.'
            ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.create_electioneering_text(rp_election_text text, ec_end date) OWNER TO fec;

--
-- Name: create_itemized_schedule_partition(text, numeric, numeric); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION create_itemized_schedule_partition(schedule text, start_year numeric, end_year numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    child_table_name TEXT;
    master_table_name TEXT = format('ofec_sched_%s_master_tmp', schedule);
BEGIN
    FOR cycle IN start_year..end_year BY 2 LOOP
        child_table_name = format('ofec_sched_%s_%s_%s_tmp', schedule, cycle - 1, cycle);
        EXECUTE format('CREATE TABLE %I (
            CHECK ( two_year_transaction_period in (%s, %s) )
        ) INHERITS (%I)', child_table_name, cycle - 1, cycle, master_table_name);
    END LOOP;
END
$$;


ALTER FUNCTION public.create_itemized_schedule_partition(schedule text, start_year numeric, end_year numeric) OWNER TO fec;

--
-- Name: create_report_description(text, text, text, text[], text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION create_report_description(office_sought text, report_type text, rpt_tp_desc text, contest text[], election_notes text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when rpt_tp_desc is null and array_length(contest, 1) = 0 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    election_notes,
                    'Report in Multiple States is Due'
                ], ' ')
            when rpt_tp_desc is null and array_length(contest, 1) > 4 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    election_notes,
                    'Report is Due'
                ], ' ')
            when rpt_tp_desc is null then
                array_to_string(
                array[
                    array_to_string(contest, ', ') || ':',
                    expand_office_description(office_sought),
                    report_type,
                    election_notes,
                    'Report is Due'
                ], ' ')
            when array_length(contest, 1) = 0 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report is Due'
                ], ' ')
            when array_length(contest, 1) > 4 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report (for Multiple States) is Due'
                ], ' ')
            else
                array_to_string(
                array[
                    array_to_string(contest, ', ') || ':',
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report is Due'
                ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.create_report_description(office_sought text, report_type text, rpt_tp_desc text, contest text[], election_notes text) OWNER TO fec;

--
-- Name: create_report_summary(text, text, text, text[], text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION create_report_summary(office_sought text, report_type text, rpt_tp_desc text, report_contest text[], election_notes text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when rpt_tp_desc is null and array_length(report_contest, 1) = 0 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    election_notes,
                    'Report is Due'
                ], ' ')
            when rpt_tp_desc is null and array_length(report_contest, 1) < 3 and array_length(report_contest, 1) >= 1 then
                array_to_string(
                array[
                    array_to_string(report_contest, ', ') || ':',
                    expand_office_description(office_sought),
                    report_type,
                    election_notes,
                    'Report is Due'
                ], ' ')
            when rpt_tp_desc is null then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    election_notes,
                    'Report is Due. States:',
                    array_to_string(report_contest, ', ')
                ], ' ')
            when array_length(report_contest, 1) = 1 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report is Due'
                ], ' ')
            when array_length(report_contest, 1) <= 3 then array_to_string(
                array[
                    array_to_string(report_contest, ', ') || ':',
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report is Due'
                ], ' ')
            when array_length(report_contest, 1) > 4 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report is Due. States:',
                    array_to_string(report_contest, ', ')
                ], ' ')
            else
                array_to_string(
                array[
                    array_to_string(report_contest, ', ') || ':',
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report is Due'
                ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.create_report_summary(office_sought text, report_type text, rpt_tp_desc text, report_contest text[], election_notes text) OWNER TO fec;

--
-- Name: create_reporting_link(timestamp without time zone); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION create_reporting_link(due_date timestamp without time zone) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when extract (year from due_date) > 2010 and
            extract (year from due_date) <= extract (year from current_date) then
                'http://www.fec.gov/info/report_dates_' || extract (year from due_date::timestamp) || '.shtml'
            else
                null::text
        end;
    end
$$;


ALTER FUNCTION public.create_reporting_link(due_date timestamp without time zone) OWNER TO fec;

--
-- Name: date_or_null(integer); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION date_or_null(value integer) RETURNS date
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return to_date(value::text, 'YYYYMMDD');
exception
    when others then return null::date;
end
$$;


ALTER FUNCTION public.date_or_null(value integer) OWNER TO fec;

--
-- Name: date_or_null(text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION date_or_null(value text, format text) RETURNS date
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return to_date(value, format);
exception
    when others then return null::date;
end
$$;


ALTER FUNCTION public.date_or_null(value text, format text) OWNER TO fec;

--
-- Name: describe_cal_event(text, text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION describe_cal_event(event_name text, summary text, description text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when event_name in ('Litigation', 'AOs and Rules', 'Conferences') then
                summary || ' ' || description
            else
                description
        end;
    end
$$;


ALTER FUNCTION public.describe_cal_event(event_name text, summary text, description text) OWNER TO fec;

--
-- Name: disbursement_purpose(text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION disbursement_purpose(code text, description text) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    cleaned varchar = regexp_replace(description, '[^a-zA-Z0-9]+', ' ');
begin
    return case
        when code in ('24G') then 'TRANSFERS'
        when code in ('24K') then 'CONTRIBUTIONS'
        when code in ('20C', '20F', '20G', '20R', '22J', '22K', '22L', '22U') then 'LOAN-REPAYMENTS'
        when code in ('17R', '20Y', '21Y', '22R', '22Y', '22Z', '23Y', '28L', '40T', '40Y', '40Z', '41T', '41Y', '41Z', '42T', '42Y', '42Z') then 'REFUNDS'
        when cleaned ~* 'salary|overhead|rent|postage|office supplies|office equipment|furniture|ballot access fees|petition drive|party fee|legal fee|accounting fee' then 'ADMINISTRATIVE'
        when cleaned ~* 'travel reimbursement|commercial carrier ticket|reimbursement for use of private vehicle|advance payments? for corporate aircraft|lodging|meal' then 'TRAVEL'
        when cleaned ~* 'direct mail|fundraising event|mailing list|consultant fee|call list|invitations including printing|catering|event space rental' then 'FUNDRAISING'
        when cleaned ~* 'general public advertising|radio|television|print|related production costs|media' then 'ADVERTISING'
        when cleaned ~* 'opinion poll' then 'POLLING'
        when cleaned ~* 'button|bumper sticker|brochure|mass mailing|pen|poster|balloon' then 'MATERIALS'
        when cleaned ~* 'candidate appearance|campaign rall(y|ies)|town meeting|phone bank|catering|get out the vote|canvassing|driving voters to polls' then 'EVENTS'
        when cleaned ~* 'contributions? to federal candidate|contributions? to federal political committee|donations? to nonfederal candidate|donations? to nonfederal committee' then 'CONTRIBUTIONS'
        else 'OTHER'
    end;
end
$$;


ALTER FUNCTION public.disbursement_purpose(code text, description text) OWNER TO fec;

--
-- Name: disbursement_purpose(character varying, character varying); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION disbursement_purpose(code character varying, description character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
    cleaned varchar = regexp_replace(description, '[^a-zA-Z0-9]+', ' ');
begin
    return case
        when code in ('24G') then 'TRANSFERS'
        when code in ('24K') then 'CONTRIBUTIONS'
        when code in ('20C', '20F', '20G', '20R', '22J', '22K', '22L', '22U') then 'LOAN-REPAYMENTS'
        when code in ('17R', '20Y', '21Y', '22R', '22Y', '22Z', '23Y', '28L', '40T', '40Y', '40Z', '41T', '41Y', '41Z', '42T', '42Y', '42Z') then 'REFUNDS'
        when cleaned ~* 'salary|overhead|rent|postage|office supplies|office equipment|furniture|ballot access fees|petition drive|party fee|legal fee|accounting fee' then 'ADMINISTRATIVE'
        when cleaned ~* 'travel reimbursement|commercial carrier ticket|reimbursement for use of private vehicle|advance payments? for corporate aircraft|lodging|meal' then 'TRAVEL'
        when cleaned ~* 'direct mail|fundraising event|mailing list|consultant fee|call list|invitations including printing|catering|event space rental' then 'FUNDRAISING'
        when cleaned ~* 'general public advertising|radio|television|print|related production costs|media' then 'ADVERTISING'
        when cleaned ~* 'opinion poll' then 'POLLING'
        when cleaned ~* 'button|bumper sticker|brochure|mass mailing|pen|poster|balloon' then 'MATERIALS'
        when cleaned ~* 'candidate appearance|campaign rall(y|ies)|town meeting|phone bank|catering|get out the vote|canvassing|driving voters to polls' then 'EVENTS'
        when cleaned ~* 'contributions? to federal candidate|contributions? to federal political committee|donations? to nonfederal candidate|donations? to nonfederal committee' then 'CONTRIBUTIONS'
        else 'OTHER'
    end;
end
$$;


ALTER FUNCTION public.disbursement_purpose(code character varying, description character varying) OWNER TO fec;

--
-- Name: drop_old_itemized_schedule_a_indexes(numeric, numeric); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION drop_old_itemized_schedule_a_indexes(start_year numeric, end_year numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    child_table_root TEXT;
BEGIN
    FOR cycle in start_year..end_year BY 2 LOOP
        child_table_root = format('ofec_sched_a_%s_%s', cycle - 1, cycle);
        EXECUTE format('DROP INDEX IF EXISTS idx_%s_contributor_employer_text', child_table_root);
        EXECUTE format('DROP INDEX IF EXISTS idx_%s_contributor_name_text', child_table_root);
        EXECUTE format('DROP INDEX IF EXISTS idx_%s_contributor_occupation_text', child_table_root);
    END LOOP;
END
$$;


ALTER FUNCTION public.drop_old_itemized_schedule_a_indexes(start_year numeric, end_year numeric) OWNER TO fec;

--
-- Name: drop_old_itemized_schedule_b_indexes(numeric, numeric); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION drop_old_itemized_schedule_b_indexes(start_year numeric, end_year numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    child_table_root TEXT;
BEGIN
    FOR cycle in start_year..end_year BY 2 LOOP
        child_table_root = format('ofec_sched_a_%s_%s', cycle - 1, cycle);
        EXECUTE format('DROP INDEX IF EXISTS idx_%s_recipient_name_text', child_table_root);
        EXECUTE format('DROP INDEX IF EXISTS idx_%s_disbursement_description_text', child_table_root);
    END LOOP;
END
$$;


ALTER FUNCTION public.drop_old_itemized_schedule_b_indexes(start_year numeric, end_year numeric) OWNER TO fec;

--
-- Name: election_duration(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION election_duration(office text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
    return case office
        when 'S' then 6
        when 'P' then 4
        else 2
    end;
end
$$;


ALTER FUNCTION public.election_duration(office text) OWNER TO fec;

--
-- Name: expand_candidate_incumbent(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_candidate_incumbent(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case acronym
            when 'I' then 'Incumbent'
            when 'C' then 'Challenger'
            when 'O' then 'Open seat'
            else null
        end;
    end
$$;


ALTER FUNCTION public.expand_candidate_incumbent(acronym text) OWNER TO fec;

--
-- Name: expand_candidate_status(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_candidate_status(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case acronym
            when 'C' then 'Candidate'
            when 'F' then 'Future candidate'
            when 'N' then 'Not yet a candidate'
            when 'P' then 'Prior candidate'
            else null
        end;
    end
$$;


ALTER FUNCTION public.expand_candidate_status(acronym text) OWNER TO fec;

--
-- Name: expand_committee_designation(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_committee_designation(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case acronym
            when 'A' then 'Authorized by a candidate'
            when 'J' then 'Joint fundraising committee'
            when 'P' then 'Principal campaign committee'
            when 'U' then 'Unauthorized'
            when 'B' then 'Lobbyist/Registrant PAC'
            when 'D' then 'Leadership PAC'
            else null
        end;
    end
$$;


ALTER FUNCTION public.expand_committee_designation(acronym text) OWNER TO fec;

--
-- Name: expand_committee_type(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_committee_type(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case acronym
            when 'P' then 'Presidential'
            when 'H' then 'House'
            when 'S' then 'Senate'
            when 'C' then 'Communication Cost'
            when 'D' then 'Delegate Committee'
            when 'E' then 'Electioneering Communication'
            when 'I' then 'Independent Expenditor (Person or Group)'
            when 'N' then 'PAC - Nonqualified'
            when 'O' then 'Super PAC (Independent Expenditure-Only)'
            when 'Q' then 'PAC - Qualified'
            when 'U' then 'Single Candidate Independent Expenditure'
            when 'V' then 'PAC with Non-Contribution Account - Nonqualified'
            when 'W' then 'PAC with Non-Contribution Account - Qualified'
            when 'X' then 'Party - Nonqualified'
            when 'Y' then 'Party - Qualified'
            when 'Z' then 'National Party Nonfederal Account'
            else null
        end;
    end
$$;


ALTER FUNCTION public.expand_committee_type(acronym text) OWNER TO fec;

--
-- Name: expand_document(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_document(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case acronym
            when '2' then '24 Hour Contribution Notice'
            when '4' then '48 Hour Contribution Notice'
            when 'A' then 'Debt Settlement Statement'
            when 'B' then 'Acknowledgment of Receipt of Debt Settlement Statement'
            when 'C' then 'RFAI: Debt Settlement First Notice'
            when 'D' then 'Commission Debt Settlement Review'
            when 'E' then 'Commission Response TO Debt Settlement Request'
            when 'F' then 'Administrative Termination'
            when 'G' then 'Debt Settlement Plan Amendment'
            when 'H' then 'Disavowal Notice'
            when 'I' then 'Disavowal Response'
            when 'J' then 'Conduit Report'
            when 'K' then 'Termination Approval'
            when 'L' then 'Repeat Non-Filer Notice'
            when 'M' then 'Filing Frequency Change Notice'
            when 'N' then 'Paper Amendment to Electronic Report'
            when 'O' then 'Acknowledgment of Filing Frequency Change'
            when 'S' then 'RFAI: Debt Settlement Second'
            when 'T' then 'Miscellaneous Report TO FEC'
            when 'V' then 'Repeat Violation Notice (441A OR 441B)'
            when 'P' then 'Notice of Paper Filing'
            when 'R' then 'F3L Filing Frequency Change Notice'
            when 'Q' then 'Acknowledgment of F3L Filing Frequency Change'
            when 'U' then 'Unregistered Committee Notice'
            else null
        end;
    end
$$;


ALTER FUNCTION public.expand_document(acronym text) OWNER TO fec;

--
-- Name: expand_election_type(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_election_type(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
     begin
         return case acronym
             when 'P' then 'Primary Election'
             when 'PR' then 'Primary Runoff Election'
             when 'SP' then 'Special Primary Election'
             when 'SPR' then 'Special Primary Runoff Election'
             when 'G' then 'General Election'
             when 'GR' then 'General Runoff Election'
             when 'SG' then 'Special General Election'
             when 'SGR' then 'Special General Runoff Election'
             when 'O' then 'Other'
             when 'C' then 'Caucus or Convention'
             when 'CAU' then 'Caucus'
             when 'CON' then 'Convention'
             when 'SC' then 'Special Convention'
             when 'R' then 'Runoff Election'
             when 'SR' then 'Special Runoff Election'
             when 'S' then 'Special Election'
             when 'E' then 'Recount Election'
             else null
         end;
     end
 $$;


ALTER FUNCTION public.expand_election_type(acronym text) OWNER TO fec;

--
-- Name: expand_election_type_caucus_convention_clean(text, numeric); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_election_type_caucus_convention_clean(trc_election_type_id text, trc_election_id numeric) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when trc_election_id in (1978, 1987, 2020, 2023, 2032, 2041, 2052, 2065, 2100, 2107, 2144, 2157, 2310, 2313, 2314, 2316, 2321, 2323, 2325, 2326, 2328, 2338, 2339, 2341)
                then 'CAU'
            when trc_election_id in (2322, 2329, 2330, 2331, 2334, 2335, 2336, 2337, 2340)
                then 'CON'
            else
                trc_election_type_id
        end;
    end
$$;


ALTER FUNCTION public.expand_election_type_caucus_convention_clean(trc_election_type_id text, trc_election_id numeric) OWNER TO fec;

--
-- Name: expand_election_type_plurals(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_election_type_plurals(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
     begin
         return case acronym
             when 'P' then 'Primary Elections'
             when 'PR' then 'Primary Runoff Elections'
             when 'SP' then 'Special Primary Elections'
             when 'SPR' then 'Special Primary Runoff Elections'
             when 'G' then 'General Elections'
             when 'GR' then 'General Runoff Elections'
             when 'SG' then 'Special General Elections'
             when 'SGR' then 'Special General Runoff Elections'
             when 'O' then 'Other'
             when 'C' then 'Caucuses or Conventions'
             when 'CAU' then 'Caucuses'
             when 'CON' then 'Conventions'
             when 'SC' then 'Special Conventions'
             when 'R' then 'Runoff Elections'
             when 'SR' then 'Special Runoff Elections'
             when 'S' then 'Special Elections'
             when 'E' then 'Recount Elections'
             else null
         end;
     end
 $$;


ALTER FUNCTION public.expand_election_type_plurals(acronym text) OWNER TO fec;

--
-- Name: expand_line_number(text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_line_number(form_type text, line_number text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case form_type
            when 'F3X' then expand_line_number_f3x(line_number)
            when 'F3P' then expand_line_number_f3p(line_number)
            when 'F3' then expand_line_number_f3(line_number)
            else null
        end;
    end
$$;


ALTER FUNCTION public.expand_line_number(form_type text, line_number text) OWNER TO fec;

--
-- Name: expand_line_number_f3(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_line_number_f3(line_number text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case line_number
            when '11A1' then 'Contributions From Individuals/Persons Other Than Political Committees'
            when '11AI' then 'Contributions From Individuals/Persons Other Than Political Committees'
            when '11B' then 'Contributions From Political Party Committees'
            when '11C' then 'Contributions From Other Political Committees'
            when '11D' then 'Contributions From the Candidate'
            when '12' then 'Transfers from authorized committees'
            when '13' then 'Loans Received'
            when '13A' then 'Loans Received from the Candidate'
            when '13B' then 'All Other Loans Received'
            when '14' then 'Offsets to Operating Expenditures'
            when '15' then 'Total Amount of Other Receipts'
            when '17' then 'Operating Expenditures'
            when '18' then 'Transfers to Other Authorized Committees'
            when '19' then 'Loan Repayments'
            when '19A' then 'Loan Repayments Made or Guaranteed by Candidate'
            when '19B' then 'Other Loan Repayments'
            when '20A' then 'Refunds of Contributions to Individuals/Persons Other Than Political Committees'
            when '20B' then 'Refunds of Contributions to Political Party Committees'
            when '20C' then 'Refunds of Contributions to Other Political Committees'
            when '21' then 'Other Disbursements'
            else null
        end;
    end
$$;


ALTER FUNCTION public.expand_line_number_f3(line_number text) OWNER TO fec;

--
-- Name: expand_line_number_f3p(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_line_number_f3p(line_number text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case line_number
            when '16' then 'Federal Funds'
            when '17A' then 'Contributions From Individuals/Persons Other Than Political Committees'
            when '17B' then 'Contributions From Political Party Committees'
            when '17C' then 'Contributions From Other Political Committees'
            when '17D' then 'Contributions From the Candidate'
            when '18' then 'Transfers From Other Authorized Committees'
            when '19A' then 'Loans Received From or Guaranteed by Candidate'
            when '19B' then 'Other Loans'
            when '20A' then 'Offsets To Expenditures - Operating'
            when '20B' then 'Offsets To Expenditures - Fundraising'
            when '20C' then 'Offsets To Expenditures - Legal and Accounting'
            when '21' then 'Other Receipts'
            when '23' then 'Operating Expenditures'
            when '24' then 'Transfers to Other Authorized Committees'
            when '25' then 'Fundraising Disbursements'
            when '26' then 'Exempt Legal and Accounting Disbursements'
            when '27A' then 'Loan Repayments Made or Guaranteed by Candidate'
            when '27B' then 'Other Loan Repayments'
            when '28A' then 'Refunds of Contributions to Individuals/Persons Other Than Political Committees'
            when '28B' then 'Refunds of Contributions to Political Party Committees'
            when '28C' then 'Refunds of Contributions to Other Political Committees'
            when '29' then 'Other Disbursements'
            else null
        end;
    end
$$;


ALTER FUNCTION public.expand_line_number_f3p(line_number text) OWNER TO fec;

--
-- Name: expand_line_number_f3x(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_line_number_f3x(line_number text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case line_number
            when '11A1' then 'Contributions From Individuals/Persons Other Than Political Committees'
            when '11AI' then 'Contributions From Individuals/Persons Other Than Political Committees'
            when '11B' then 'Contributions From Political Party Committees'
            when '11C' then 'Contributions From Other Political Committees'
            when '11D' then 'Contributions From the Candidate'
            when '12' then 'Transfers from Authorized Committees'
            when '13' then 'Loans Received'
            when '14' then 'Loan Repayments Received'
            when '15' then 'Offsets To Operating Expenditures '
            when '16' then 'Refunds of Contributions Made to Federal Candidates and Other Political Committees'
            when '17' then 'Other Federal Receipts (Dividends, Interest, etc.).'
            when 'SL1A' then 'Non-Federal Receipts from Persons Levin (L-1A)'
            when 'SL2' then 'Non-Federal Other Receipt Levin (L-2)'
            when '21' then 'Operating Expenditures'
            when '21B' then 'Other Federal Operating Expenditures'
            when '22' then 'Transfers to Affiliated/Other Party Committees'
            when '23' then 'Contributions to Federal Candidates/Committees and Other Political Committees'
            when '24' then 'Independent Expenditures'
            when '25' then 'Coordinated Party Expenditures'
            when '26' then 'Loan Repayments Made'
            when '27' then 'Loans Made'
            when '28A' then 'Refunds of Contributions Made to Individuals/Persons Other Than Political Committees'
            when '28B' then 'Refunds of Contributions to Political Party Committees'
            when '28C' then 'Refunds of Contributions to Other Political Committees'
            when '28D' then 'Total Contributions Refunds'
            when '29' then 'Other Disbursements'
            when '30' then 'Federal Election Activity'
            when '30A' then 'Allocated Federal Election Activity'
            when '30B' then 'Federal Election Activity Paid Entirely With Federal Funds'
            when 'SL4A' then 'Levin Funds'
            when 'SL4B' then 'Levin Funds'
            when 'SL4C' then 'Levin Funds'
            when 'SL4D' then 'Levin Funds'
            when 'SL5' then 'Levin Funds'
            else null
        end;
    end
$$;


ALTER FUNCTION public.expand_line_number_f3x(line_number text) OWNER TO fec;

--
-- Name: expand_office(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_office(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case acronym
            when 'P' then 'President'
            when 'S' then 'Senate'
            when 'H' then 'House'
        end;
    end
$$;


ALTER FUNCTION public.expand_office(acronym text) OWNER TO fec;

--
-- Name: expand_office_description(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_office_description(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case acronym
            when 'P' then 'Presidential'
            when 'S' then 'Senate'
            when 'H' then 'House'
            else null
        end;
    end
$$;


ALTER FUNCTION public.expand_office_description(acronym text) OWNER TO fec;

--
-- Name: expand_organization_type(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_organization_type(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case acronym
            when 'C' then 'Corporation'
            when 'L' then 'Labor Organization'
            when 'M' then 'Membership Organization'
            when 'T' then 'Trade Association'
            when 'V' then 'Cooperative'
            when 'W' then 'Corporation w/o capital stock'
            else null
        end;
    end
$$;


ALTER FUNCTION public.expand_organization_type(acronym text) OWNER TO fec;

--
-- Name: expand_state(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION expand_state(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case acronym
            when 'AK' then 'Alaska'
            when 'AL' then 'Alabama'
            when 'AS' then 'American Samoa'
            when 'AR' then 'Arkansas'
            when 'AZ' then 'Arizona'
            when 'CA' then 'California'
            when 'CO' then 'Colorado'
            when 'CT' then 'Connecticut'
            when 'DC' then 'District Of Columbia'
            when 'DE' then 'Delaware'
            when 'FL' then 'Florida'
            when 'GA' then 'Georgia'
            when 'GU' then 'Guam'
            when 'HI' then 'Hawaii'
            when 'IA' then 'Iowa'
            when 'ID' then 'Idaho'
            when 'IL' then 'Illinois'
            when 'IN' then 'Indiana'
            when 'KS' then 'Kansas'
            when 'KY' then 'Kentucky'
            when 'LA' then 'Louisiana'
            when 'MA' then 'Massachusetts'
            when 'MD' then 'Maryland'
            when 'ME' then 'Maine'
            when 'MI' then 'Michigan'
            when 'MN' then 'Minnesota'
            when 'MO' then 'Missouri'
            when 'MS' then 'Mississippi'
            when 'MT' then 'Montana'
            when 'NC' then 'North Carolina'
            when 'ND' then 'North Dakota'
            when 'NE' then 'Nebraska'
            when 'NH' then 'New Hampshire'
            when 'NJ' then 'New Jersey'
            when 'NM' then 'New Mexico'
            when 'NV' then 'Nevada'
            when 'NY' then 'New York'
            when 'MP' then 'Northern Mariana Islands'
            when 'OH' then 'Ohio'
            when 'OK' then 'Oklahoma'
            when 'OR' then 'Oregon'
            when 'PA' then 'Pennsylvania'
            when 'PR' then 'Puerto Rico'
            when 'RI' then 'Rhode Island'
            when 'SC' then 'South Carolina'
            when 'SD' then 'South Dakota'
            when 'TN' then 'Tennessee'
            when 'TX' then 'Texas'
            when 'UT' then 'Utah'
            when 'VI' then 'Virgin Islands'
            when 'VA' then 'Virginia'
            when 'VT' then 'Vermont'
            when 'WA' then 'Washington'
            when 'WI' then 'Wisconsin'
            when 'WV' then 'West Virginia'
            when 'WY' then 'Wyoming'
            else null
        end;
    end
$$;


ALTER FUNCTION public.expand_state(acronym text) OWNER TO fec;

--
-- Name: fec_vsum_f57_update_queues(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION fec_vsum_f57_update_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if tg_op = 'INSERT' then
        delete from fec_vsum_f57_queue_new where sub_id = new.sub_id;
        insert into fec_vsum_f57_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from fec_vsum_f57_queue_new where sub_id = new.sub_id;
        delete from fec_vsum_f57_queue_old where sub_id = old.sub_id;
        insert into fec_vsum_f57_queue_new values (new.*);
        insert into fec_vsum_f57_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from fec_vsum_f57_queue_old where sub_id = old.sub_id;
        insert into fec_vsum_f57_queue_old values (old.*);
        return old;
    end if;
end
$$;


ALTER FUNCTION public.fec_vsum_f57_update_queues() OWNER TO fec;

--
-- Name: filings_year(numeric, date); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION filings_year(report_year numeric, receipt_date date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
    return case
        when report_year != 0 then report_year
        else date_part('year', receipt_date)
    end;
end
$$;


ALTER FUNCTION public.filings_year(report_year numeric, receipt_date date) OWNER TO fec;

--
-- Name: finalize_itemized_schedule_a_tables(numeric, numeric, boolean, boolean); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION finalize_itemized_schedule_a_tables(start_year numeric, end_year numeric, p_use_tmp boolean, p_create_primary_key boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    child_table_root TEXT;
    child_table_name TEXT;
    index_name_suffix TEXT;
BEGIN
    FOR cycle in start_year..end_year BY 2 LOOP
        child_table_root = format('ofec_sched_a_%s_%s', cycle - 1, cycle);
        IF p_use_tmp THEN
            child_table_name = format('ofec_sched_a_%s_%s_tmp', cycle - 1, cycle);
            index_name_suffix = '_tmp';
        ELSE
            child_table_name = format('ofec_sched_a_%s_%s', cycle - 1, cycle);
            index_name_suffix = '';
        END IF;
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_image_num_dt%s ON %I (image_num, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contbr_st_dt%s ON %I (contbr_st, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contbr_city_dt%s ON %I (contbr_city, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contbr_zip_dt%s ON %I (contbr_zip, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_is_individual_dt%s ON %I (is_individual, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_clean_contbr_id_dt%s ON %I (clean_contbr_id, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_amount_dt%s ON %I (contb_receipt_amt, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_cmte_id_dt%s ON %I (cmte_id, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_line_num_dt%s ON %I (line_num, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_two_year_transaction_period_dt%s ON %I (two_year_transaction_period, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contrib_name_text_dt%s ON %I USING GIN (contributor_name_text, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contrib_emp_text_dt%s ON %I USING GIN (contributor_employer_text, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contrib_occ_text_dt%s ON %I USING GIN (contributor_occupation_text, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_image_num_amt%s ON %I (image_num, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contbr_st_amt%s ON %I (contbr_st, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contbr_city_amt%s ON %I (contbr_city, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contbr_zip_amt%s ON %I (contbr_zip, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_is_individual_amt%s ON %I (is_individual, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_clean_contbr_id_amt%s ON %I (clean_contbr_id, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_date_amt%s ON %I (contb_receipt_dt, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_cmte_id_amt%s ON %I (cmte_id, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_line_num_amt%s ON %I (line_num, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_two_year_transaction_period_amt%s ON %I (two_year_transaction_period, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contrib_name_text_amt%s ON %I USING GIN (contributor_name_text, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contrib_emp_text_amt%s ON %I USING GIN (contributor_employer_text, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_contrib_occ_text_amt%s ON %I USING GIN (contributor_occupation_text, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_rpt_yr%s ON %I (rpt_yr)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_pg_date%s ON %I (pg_date)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_entity_tp%s ON %I (entity_tp)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_amount%s ON %I (contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_cmte_id_amount%s ON %I (cmte_id, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_cmte_id_date%s ON %I (cmte_id, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE UNIQUE INDEX IF NOT EXISTS idx_%s_sub_id%s ON %I (sub_id)', child_table_root, index_name_suffix, child_table_name);
        IF p_create_primary_key THEN
            EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY USING INDEX idx_%s_sub_id%s', child_table_name, child_table_root, index_name_suffix);
        END IF;
        EXECUTE format('ALTER TABLE %I ALTER COLUMN contbr_st SET STATISTICS 1000', child_table_name);
        EXECUTE format('ANALYZE %I', child_table_name);
    END LOOP;
END
$$;


ALTER FUNCTION public.finalize_itemized_schedule_a_tables(start_year numeric, end_year numeric, p_use_tmp boolean, p_create_primary_key boolean) OWNER TO fec;

--
-- Name: finalize_itemized_schedule_b_tables(numeric, numeric, boolean, boolean); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION finalize_itemized_schedule_b_tables(start_year numeric, end_year numeric, p_use_tmp boolean, p_create_primary_key boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    child_table_root TEXT;
    child_table_name TEXT;
    index_name_suffix TEXT;
BEGIN
    FOR cycle in start_year..end_year BY 2 LOOP
        child_table_root = format('ofec_sched_b_%s_%s', cycle - 1, cycle);
        IF p_use_tmp THEN
            child_table_name = format('ofec_sched_b_%s_%s_tmp', cycle - 1, cycle);
            index_name_suffix = '_tmp';
        ELSE
            child_table_name = format('ofec_sched_b_%s_%s', cycle - 1, cycle);
            index_name_suffix = '';
        END IF;
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_image_num_dt%s ON %I (image_num, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_clean_recipient_cmte_id_dt%s ON %I (clean_recipient_cmte_id, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_recipient_city_dt%s ON %I (recipient_city, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_recipient_st_dt%s ON %I (recipient_st, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_rpt_yr_dt%s ON %I (rpt_yr, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_two_year_transaction_period_dt%s ON %I (two_year_transaction_period, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_line_num_dt%s ON %I (line_num, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_amount_dt%s ON %I (disb_amt, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_cmte_id_dt%s ON %I (cmte_id, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_recip_name_text_dt%s ON %I USING GIN (recipient_name_text, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_disb_desc_text_dt%s ON %I USING GIN (disbursement_description_text, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_image_num_amt%s ON %I (image_num, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_clean_recipient_cmte_id_amt%s ON %I (clean_recipient_cmte_id, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_recipient_city_amt%s ON %I (recipient_city, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_recipient_st_amt%s ON %I (recipient_st, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_rpt_yr_amt%s ON %I (rpt_yr, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_two_year_transaction_period_amt%s ON %I (two_year_transaction_period, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_line_num_amt%s ON %I (line_num, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_date_amt%s ON %I (disb_dt, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_cmte_id_amt%s ON %I (cmte_id, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_recip_name_text_amt%s ON %I USING GIN (recipient_name_text, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_disb_desc_text_amt%s ON %I USING GIN (disbursement_description_text, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_cmte_id_disb_amt_sub_id%s ON %I (cmte_id, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_cmte_id_disb_dt_sub_id%s ON %I (cmte_id, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_pg_date%s ON %I (pg_date)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE UNIQUE INDEX IF NOT EXISTS idx_%s_sub_id%s ON %I (sub_id)', child_table_root, index_name_suffix, child_table_name);
        IF p_create_primary_key THEN
            EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY USING INDEX idx_%s_sub_id%s', child_table_name, child_table_root, index_name_suffix);
        END IF;
        EXECUTE format('ALTER TABLE %I ALTER COLUMN recipient_st SET STATISTICS 1000', child_table_name);
        EXECUTE format('ANALYZE %I', child_table_name);
    END LOOP;
END
$$;


ALTER FUNCTION public.finalize_itemized_schedule_b_tables(start_year numeric, end_year numeric, p_use_tmp boolean, p_create_primary_key boolean) OWNER TO fec;

--
-- Name: first_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: openfec_read
--

CREATE FUNCTION first_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
        SELECT $1;
$_$;


ALTER FUNCTION public.first_agg(anyelement, anyelement) OWNER TO openfec_read;

--
-- Name: fix_party_spelling(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION fix_party_spelling(branch text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case branch
            when 'Party/Non Pary' then 'Party/Non Party'
            else branch
        end;
    end
$$;


ALTER FUNCTION public.fix_party_spelling(branch text) OWNER TO fec;

--
-- Name: generate_election_description(text, text, text[], text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION generate_election_description(election_type text, office_sought text, contest text[], party text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
        when array_length(contest, 1) >= 3 then array_to_string(
            array[
                party,
                office_sought,
                election_type,
                '(for Multiple States)',
                'is Held Today'
            ], ' ')
        when array_length(contest, 1) = 0 then array_to_string(
            array[
                party,
                office_sought,
                election_type,
                'is Held Today'
            ], ' ')
        else array_to_string(
            array[
                array_to_string(contest, ', ') || ':',
                party,
                office_sought,
                election_type,
                'is Held Today'
            ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.generate_election_description(election_type text, office_sought text, contest text[], party text) OWNER TO fec;

--
-- Name: generate_election_summary(text, text, text[], text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION generate_election_summary(election_type text, office_sought text, contest text[], party text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
        when array_length(contest, 1) >= 3 then array_to_string(
            array[
                party,
                office_sought,
                election_type,
                'is Held Today',
                'States:',
                array_to_string(contest, ', ')
            ], ' ')
        when array_length(contest, 1) = 0 then array_to_string(
            array[
                party,
                office_sought,
                election_type,
                'is Held Today'
            ], ' ')
        else array_to_string(
            array[
                array_to_string(contest, ', ') || ':',
                party,
                office_sought,
                election_type,
                'is Held Today'
            ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.generate_election_summary(election_type text, office_sought text, contest text[], party text) OWNER TO fec;

--
-- Name: generate_election_title(text, text, text[], text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION generate_election_title(trc_election_type_id text, office_sought text, election_states text[], party text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
        when array_length(election_states, 1) > 1 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type(trc_election_type_id),
                'Multi-state'::text
            ], ' ')
        else array_to_string(
            array[
                party,
                office_sought,
                expand_election_type(trc_election_type_id),
                array_to_string(election_states, ', ')
        ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.generate_election_title(trc_election_type_id text, office_sought text, election_states text[], party text) OWNER TO fec;

--
-- Name: generate_election_title(text, text, text[], text, numeric); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION generate_election_title(trc_election_type_id text, office_sought text, contest text[], party text, trc_election_id numeric) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
        when array_length(contest, 1) > 1 then array_to_string(
            array[
                party,
                office_sought,
                 expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric),
                'Multi-state'::text
            ], ' ')
        else array_to_string(
            array[
                array_to_string(contest, ', '),
                party,
                office_sought,
                 expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric)
            ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.generate_election_title(trc_election_type_id text, office_sought text, contest text[], party text, trc_election_id numeric) OWNER TO fec;

--
-- Name: generate_report_description(text, text, text, text[]); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION generate_report_description(office_sought text, report_type text, rpt_tp_desc text, contest text[]) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when rpt_tp_desc is null and array_length(contest, 1) = 0 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    'Report (for Multiple States) is Due Today'
                ], ' ')
            when rpt_tp_desc is null and array_length(contest, 1) > 4 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    'Report is Due Today'
                ], ' ')
            when rpt_tp_desc is null then
                array_to_string(
                array[
                    array_to_string(contest, ', ') || ':',
                    expand_office_description(office_sought),
                    report_type,
                    'Report is Due Today'
                ], ' ')
            when array_length(contest, 1) = 0 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report is Due Today'
                ], ' ')
            when array_length(contest, 1) > 4 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report (for Multiple States) is Due Today'
                ], ' ')
            else
                array_to_string(
                array[
                    array_to_string(contest, ', ') || ':',
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report is Due Today'
                ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.generate_report_description(office_sought text, report_type text, rpt_tp_desc text, contest text[]) OWNER TO fec;

--
-- Name: generate_report_summary(text, text, text, text[]); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION generate_report_summary(office_sought text, report_type text, rpt_tp_desc text, report_contest text[]) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when rpt_tp_desc is null and array_length(report_contest, 1) = 0 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    'Report is Due Today'
                ], ' ')
            when rpt_tp_desc is null and array_length(report_contest, 1) < 3 and array_length(report_contest, 1) >= 1 then
                array_to_string(
                array[
                    array_to_string(report_contest, ', ') || ':',
                    expand_office_description(office_sought),
                    report_type,
                    'Report is Due Today'
                ], ' ')
            when rpt_tp_desc is null then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    'Report is Due Today. States:',
                    array_to_string(report_contest, ', ')
                ], ' ')
            when array_length(report_contest, 1) = 1 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report is Due Today'
                ], ' ')
            when array_length(report_contest, 1) <= 3 then array_to_string(
                array[
                    array_to_string(report_contest, ', ') || ':',
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report is Due Today'
                ], ' ')
            when array_length(report_contest, 1) > 4 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report is Due Today. States:',
                    array_to_string(report_contest, ', ')
                ], ' ')
            else
                array_to_string(
                array[
                    array_to_string(report_contest, ', ') || ':',
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report is Due Today'
                ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.generate_report_summary(office_sought text, report_type text, rpt_tp_desc text, report_contest text[]) OWNER TO fec;

--
-- Name: get_cycle(numeric); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION get_cycle(year numeric) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return year + year % 2;
end
$$;


ALTER FUNCTION public.get_cycle(year numeric) OWNER TO fec;

--
-- Name: get_partition_suffix(numeric); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION get_partition_suffix(year numeric) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    IF year % 2 = 0 THEN
        RETURN (year - 1)::TEXT || '_' || year::TEXT;
    ELSE
        RETURN year::TEXT || '_' || (year + 1)::TEXT;
    END IF;
END
$$;


ALTER FUNCTION public.get_partition_suffix(year numeric) OWNER TO fec;

--
-- Name: get_projected_weekly_itemized_total(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION get_projected_weekly_itemized_total(schedule text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    weekly_total integer;
begin
    execute 'select
        (select count(*) from ofec_sched_' || schedule || '_master where pg_date > current_date - interval ''7 days'') +
        (select count(*) from ofec_sched_' || schedule || '_queue_new) -
        (select count(*) from ofec_sched_' || schedule || '_queue_old)'
    into weekly_total;
    return weekly_total;
end
$$;


ALTER FUNCTION public.get_projected_weekly_itemized_total(schedule text) OWNER TO fec;

--
-- Name: get_transaction_year(date, numeric); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION get_transaction_year(transaction_date date, report_year numeric) RETURNS smallint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    transaction_year numeric = coalesce(extract(year from transaction_date), report_year);
begin
    return get_cycle(transaction_year);
end
$$;


ALTER FUNCTION public.get_transaction_year(transaction_date date, report_year numeric) OWNER TO fec;

--
-- Name: get_transaction_year(timestamp without time zone, numeric); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION get_transaction_year(transaction_date timestamp without time zone, report_year numeric) RETURNS smallint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    dah_date date = date(transaction_date);
begin
    return get_transaction_year(dah_date, report_year);
end
$$;


ALTER FUNCTION public.get_transaction_year(transaction_date timestamp without time zone, report_year numeric) OWNER TO fec;

--
-- Name: image_pdf_url(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION image_pdf_url(image_number text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return 'http://docquery.fec.gov/cgi-bin/fecimg/?' || image_number;
end
$$;


ALTER FUNCTION public.image_pdf_url(image_number text) OWNER TO fec;

--
-- Name: insert_sched_master(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION insert_sched_master() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    transaction_period_lower_guard SMALLINT = TG_ARGV[0]::SMALLINT - 1;
    child_table_name TEXT;
BEGIN
    IF new.two_year_transaction_period >= transaction_period_lower_guard THEN
        child_table_name = replace(TG_TABLE_NAME, 'master', get_partition_suffix(new.two_year_transaction_period));
        EXECUTE format('INSERT INTO %I VALUES ($1.*)', child_table_name)
            USING new;
    END IF;
    RETURN NULL;
END
$_$;


ALTER FUNCTION public.insert_sched_master() OWNER TO fec;

--
-- Name: is_amended(integer, integer); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_amended(most_recent_file_number integer, file_number integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return not is_most_recent(most_recent_file_number, file_number);
end
$$;


ALTER FUNCTION public.is_amended(most_recent_file_number integer, file_number integer) OWNER TO fec;

--
-- Name: is_amended(integer, integer, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_amended(most_recent_file_number integer, file_number integer, form_type text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return case
        when form_type = 'F99' then false
        when form_type = 'FRQ' then false
        else not is_most_recent(most_recent_file_number, file_number)
    end;
end
$$;


ALTER FUNCTION public.is_amended(most_recent_file_number integer, file_number integer, form_type text) OWNER TO fec;

--
-- Name: is_coded_individual(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_coded_individual(receipt_type text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return coalesce(receipt_type, '') in ('10', '15', '15E', '15J', '30', '30T', '31', '31T', '32', '10J', '11', '11J', '30J', '31J', '32T', '32J');
end
$$;


ALTER FUNCTION public.is_coded_individual(receipt_type text) OWNER TO fec;

--
-- Name: is_earmark(text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_earmark(memo_code text, memo_text text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
  return (
      coalesce(memo_code, '') = 'X' and
      coalesce(memo_text, '') ~* 'earmark|earmk|ermk'
  );
end
$$;


ALTER FUNCTION public.is_earmark(memo_code text, memo_text text) OWNER TO fec;

--
-- Name: is_electronic(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_electronic(image_number text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return case
        when char_length(image_number) = 18 and substring(image_number from 9 for 1) = '9' then true
        when char_length(image_number) = 11 and substring(image_number from 3 for 1) = '9' then true
        when char_length(image_number) = 11 and substring(image_number from 3 for 2) = '02' then false
        when char_length(image_number) = 11 and substring(image_number from 3 for 2) = '03' then false
        else false
    end;
end
$$;


ALTER FUNCTION public.is_electronic(image_number text) OWNER TO fec;

--
-- Name: is_individual(numeric, text, text, text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_individual(amount numeric, receipt_type text, line_number text, memo_code text, memo_text text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return (
        is_coded_individual(receipt_type) or
        is_inferred_individual(amount, line_number, memo_code, memo_text)
    );
end
$$;


ALTER FUNCTION public.is_individual(amount numeric, receipt_type text, line_number text, memo_code text, memo_text text) OWNER TO fec;

--
-- Name: is_individual(numeric, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_individual(amount numeric, receipt_type text, line_number text, memo_code text, memo_text text, contbr_id text, cmte_id text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return (
        (
            is_coded_individual(receipt_type) or
            is_inferred_individual(amount, line_number, memo_code, memo_text, contbr_id, cmte_id)
        ) and
        is_not_committee(contbr_id, cmte_id, line_number)
    );
end
$$;


ALTER FUNCTION public.is_individual(amount numeric, receipt_type text, line_number text, memo_code text, memo_text text, contbr_id text, cmte_id text) OWNER TO fec;

--
-- Name: is_inferred_individual(numeric, text, text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_inferred_individual(amount numeric, line_number text, memo_code text, memo_text text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return (
        amount < 200 and
        coalesce(line_number, '') in ('11AI', '12', '17', '17A', '18') and
        not is_earmark(memo_code, memo_text)
    );
end
$$;


ALTER FUNCTION public.is_inferred_individual(amount numeric, line_number text, memo_code text, memo_text text) OWNER TO fec;

--
-- Name: is_inferred_individual(numeric, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_inferred_individual(amount numeric, line_number text, memo_code text, memo_text text, contbr_id text, cmte_id text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return (
        amount < 200 and
        coalesce(line_number, '') in ('11AI', '12', '17', '17A', '18') and
        not is_earmark(memo_code, memo_text)
    );
end
$$;


ALTER FUNCTION public.is_inferred_individual(amount numeric, line_number text, memo_code text, memo_text text, contbr_id text, cmte_id text) OWNER TO fec;

--
-- Name: is_most_recent(integer, integer); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_most_recent(most_recent_file_number integer, file_number integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return most_recent_file_number = file_number;
end
$$;


ALTER FUNCTION public.is_most_recent(most_recent_file_number integer, file_number integer) OWNER TO fec;

--
-- Name: is_most_recent(integer, integer, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_most_recent(most_recent_file_number integer, file_number integer, form_type text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return case
        when form_type = 'F99' then true
        when form_type = 'FRQ' then true
        else most_recent_file_number = file_number
    end;
end
$$;


ALTER FUNCTION public.is_most_recent(most_recent_file_number integer, file_number integer, form_type text) OWNER TO fec;

--
-- Name: is_not_committee(text, text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_not_committee(contbr_id text, cmte_id text, line_number text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return(
        (
            coalesce(contbr_id, '') != '' or
            (coalesce(contbr_id, '') != '' and contbr_id = cmte_id)
        ) or
        (not coalesce(line_number, '') in ('15E', '15J', '17'))
    );
end
$$;


ALTER FUNCTION public.is_not_committee(contbr_id text, cmte_id text, line_number text) OWNER TO fec;

--
-- Name: is_unitemized(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION is_unitemized(memo_text text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
  return (coalesce(memo_text, '') ~* 'UNITEM');
end
$$;


ALTER FUNCTION public.is_unitemized(memo_text text) OWNER TO fec;

--
-- Name: last_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: openfec_read
--

CREATE FUNCTION last_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
        SELECT $2;
$_$;


ALTER FUNCTION public.last_agg(anyelement, anyelement) OWNER TO openfec_read;

--
-- Name: last_day_of_month(timestamp without time zone); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION last_day_of_month(timestamp without time zone) RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $_$
    begin
        return date_trunc('month', $1) + (interval '1 month - 1 day');
    end
$_$;


ALTER FUNCTION public.last_day_of_month(timestamp without time zone) OWNER TO fec;

--
-- Name: means_filed(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION means_filed(image_number text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return case
        when is_electronic(image_number) then 'e-file'
        else 'paper'
    end;
end
$$;


ALTER FUNCTION public.means_filed(image_number text) OWNER TO fec;

--
-- Name: name_reports(text, text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION name_reports(office_sought text, report_type text, rpt_tp_desc text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when rpt_tp_desc is null then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    'Report'
                ], ' ')
            else array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report'
                ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.name_reports(office_sought text, report_type text, rpt_tp_desc text) OWNER TO fec;

--
-- Name: name_reports(text, text, text, text[]); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION name_reports(office_sought text, report_type text, rpt_tp_desc text, election_state text[]) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when rpt_tp_desc is null and array_length(election_state, 1) > 1 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    'Report Multi-state'
                ], ' ')
            when rpt_tp_desc is null then
                array_to_string(
                array[
                    array_to_string(election_state, ', '),
                    expand_office_description(office_sought),
                    report_type
                ], ' ')
            when array_length(election_state, 1) > 1 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    'Report Multi-state'
                ], ' ')
            else
                array_to_string(
                array[
                    array_to_string(election_state, ', '),
                    expand_office_description(office_sought),
                    rpt_tp_desc
                ], ' ')
        end;
    end
$$;


ALTER FUNCTION public.name_reports(office_sought text, report_type text, rpt_tp_desc text, election_state text[]) OWNER TO fec;

--
-- Name: ofec_f57_update_notice_queues(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_f57_update_notice_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if tg_op = 'INSERT' then
        delete from public.ofec_f57_queue_new where sub_id = new.sub_id;
        insert into public.ofec_f57_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from public.ofec_f57_queue_new where sub_id = new.sub_id;
        delete from public.ofec_f57_queue_old where sub_id = old.sub_id;
        insert into public.ofec_f57_queue_new values (new.*);
        insert into public.ofec_f57_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from public.ofec_f57_queue_old where sub_id = old.sub_id;
        insert into public.ofec_f57_queue_old values (old.*);
        return old;
    end if;
end
$$;


ALTER FUNCTION public.ofec_f57_update_notice_queues() OWNER TO fec;

--
-- Name: ofec_sched_a_delete_update_queues(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_a_delete_update_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    start_year int = TG_ARGV[0]::int;
    view_row public.fec_fitem_sched_a_vw%ROWTYPE;
begin
        select into view_row * from public.fec_fitem_sched_a_vw where sub_id = old.sub_id;
        if FOUND then
            if view_row.election_cycle >= start_year then
                delete from ofec_sched_a_queue_old where sub_id = view_row.sub_id;
                insert into ofec_sched_a_queue_old values (view_row.*, current_timestamp, view_row.election_cycle);
            end if;
        end if;
    if tg_op = 'DELETE' then
        return old;
    elsif tg_op = 'UPDATE' then
        return new;
    end if;
end
$$;


ALTER FUNCTION public.ofec_sched_a_delete_update_queues() OWNER TO fec;

--
-- Name: ofec_sched_a_insert_update_queues(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_a_insert_update_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    start_year int = TG_ARGV[0]::int;
    view_row public.fec_fitem_sched_a_vw%ROWTYPE;
begin
    select into view_row * from public.fec_fitem_sched_a_vw where sub_id = new.sub_id;
    if FOUND then
        if view_row.election_cycle >= start_year then
            delete from ofec_sched_a_queue_new where sub_id = view_row.sub_id;
            insert into ofec_sched_a_queue_new values (view_row.*, current_timestamp, view_row.election_cycle);
        end if;
    end if;
    RETURN NULL; -- result is ignored since this is an AFTER trigger
end
$$;


ALTER FUNCTION public.ofec_sched_a_insert_update_queues() OWNER TO fec;

--
-- Name: ofec_sched_a_update(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_a_update() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    delete from ofec_sched_a
    where sched_a_sk = any(select sched_a_sk from ofec_sched_a_queue_old)
    ;
    insert into ofec_sched_a(
        select distinct on (sched_a_sk)
            new.*,
            image_pdf_url(new.image_num) as pdf_url,
            to_tsvector(new.contbr_nm) || to_tsvector(coalesce(new.contbr_id, ''))
                as contributor_name_text,
            to_tsvector(new.contbr_employer) as contributor_employer_text,
            to_tsvector(new.contbr_occupation) as contributor_occupation_text,
            is_individual(new.contb_receipt_amt, new.receipt_tp, new.line_num, new.memo_cd, new.memo_text)
                as is_individual,
            clean_repeated(new.contbr_id, new.cmte_id) as clean_contbr_id
        from ofec_sched_a_queue_new new
        left join ofec_sched_a_queue_old old on new.sched_a_sk = old.sched_a_sk and old.timestamp > new.timestamp
        where old.sched_a_sk is null
        order by new.sched_a_sk, new.timestamp desc
    );
end
$$;


ALTER FUNCTION public.ofec_sched_a_update() OWNER TO fec;

--
-- Name: ofec_sched_a_update_aggregate_contributor(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_a_update_aggregate_contributor() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    with new as (
        select 1 as multiplier, *
        from ofec_sched_a_queue_new
    ),
    old as (
        select -1 as multiplier, *
        from ofec_sched_a_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            clean_repeated(contbr_id, cmte_id) as contbr_id,
            max(contbr_nm) as contbr_nm,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and clean_repeated(contbr_id, cmte_id) is not null
        and coalesce(entity_tp, '') != 'IND'
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, clean_repeated(contbr_id, cmte_id)
    ),
    inc as (
        update ofec_sched_a_aggregate_contributor ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.contbr_id) = (patch.cmte_id, patch.cycle, patch.contbr_id)
    )
    insert into ofec_sched_a_aggregate_contributor (
        select patch.* from patch
        left join ofec_sched_a_aggregate_contributor ag using (cmte_id, cycle, contbr_id)
        where ag.cmte_id is null
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_a_update_aggregate_contributor() OWNER TO fec;

--
-- Name: ofec_sched_a_update_aggregate_contributor_type(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_a_update_aggregate_contributor_type() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    with new as (
        select 1 as multiplier, *
        from ofec_sched_a_queue_new
    ),
    old as (
        select -1 as multiplier, *
        from ofec_sched_a_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contributor_type(line_num) as individual,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, individual
    ),
    inc as (
        update ofec_sched_a_aggregate_contributor_type ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.individual) = (patch.cmte_id, patch.cycle, patch.individual)
    )
    insert into ofec_sched_a_aggregate_contributor_type (
        select patch.* from patch
        left join ofec_sched_a_aggregate_contributor_type ag using (cmte_id, cycle, individual)
        where ag.cmte_id is null
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_a_update_aggregate_contributor_type() OWNER TO fec;

--
-- Name: ofec_sched_a_update_aggregate_employer(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_a_update_aggregate_employer() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    with new as (
        select 1 as multiplier, cmte_id, rpt_yr, contbr_employer, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_new
    ),
    old as (
        select -1 as multiplier, cmte_id, rpt_yr, contbr_employer, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contbr_employer as employer,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id, cmte_id)
        group by cmte_id, cycle, employer
    ),
    inc as (
        update ofec_sched_a_aggregate_employer ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.employer) = (patch.cmte_id, patch.cycle, patch.employer)
    )
    insert into ofec_sched_a_aggregate_employer (
        select patch.* from patch
        left join ofec_sched_a_aggregate_employer ag using (cmte_id, cycle, employer)
        where ag.cmte_id is null
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_a_update_aggregate_employer() OWNER TO fec;

--
-- Name: ofec_sched_a_update_aggregate_occupation(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_a_update_aggregate_occupation() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    with new as (
        select 1 as multiplier, cmte_id, rpt_yr, contbr_occupation, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_new
    ),
    old as (
        select -1 as multiplier, cmte_id, rpt_yr, contbr_occupation, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contbr_occupation as occupation,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id, cmte_id)
        group by cmte_id, cycle, occupation
    ),
    inc as (
        update ofec_sched_a_aggregate_occupation ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.occupation) = (patch.cmte_id, patch.cycle, patch.occupation)
    )
    insert into ofec_sched_a_aggregate_occupation (
        select patch.* from patch
        left join ofec_sched_a_aggregate_occupation ag using (cmte_id, cycle, occupation)
        where ag.cmte_id is null
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_a_update_aggregate_occupation() OWNER TO fec;

--
-- Name: ofec_sched_a_update_aggregate_size(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_a_update_aggregate_size() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    with new as (
        select 1 as multiplier, cmte_id, rpt_yr, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_new
    ),
    old as (
        select -1 as multiplier, cmte_id, rpt_yr, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contribution_size(contb_receipt_amt) as size,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id, cmte_id)
        group by cmte_id, cycle, size
    ),
    inc as (
        update ofec_sched_a_aggregate_size ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.size) = (patch.cmte_id, patch.cycle, patch.size)
    )
    insert into ofec_sched_a_aggregate_size (
        select patch.* from patch
        left join ofec_sched_a_aggregate_size ag using (cmte_id, cycle, size)
        where ag.cmte_id is null
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_a_update_aggregate_size() OWNER TO fec;

--
-- Name: ofec_sched_a_update_aggregate_state(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_a_update_aggregate_state() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    with new as (
        select 1 as multiplier, cmte_id, rpt_yr, contbr_st, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_new
    ),
    old as (
        select -1 as multiplier, cmte_id, rpt_yr, contbr_st, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contbr_st as state,
            expand_state(contbr_st) as state_full,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id, cmte_id)
        group by cmte_id, cycle, state
    ),
    inc as (
        update ofec_sched_a_aggregate_state ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.state) = (patch.cmte_id, patch.cycle, patch.state)
    )
    insert into ofec_sched_a_aggregate_state (
        select patch.* from patch
        left join ofec_sched_a_aggregate_state ag using (cmte_id, cycle, state)
        where ag.cmte_id is null
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_a_update_aggregate_state() OWNER TO fec;

--
-- Name: ofec_sched_a_update_aggregate_zip(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_a_update_aggregate_zip() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    with new as (
        select 1 as multiplier, cmte_id, rpt_yr, contbr_zip, contbr_st, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_new
    ),
    old as (
        select -1 as multiplier, cmte_id, rpt_yr, contbr_zip, contbr_st, contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id
        from ofec_sched_a_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            contbr_zip as zip,
            max(contbr_st) as state,
            expand_state(max(contbr_st)) as state_full,
            sum(contb_receipt_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where contb_receipt_amt is not null
        and is_individual(contb_receipt_amt, receipt_tp, line_num, memo_cd, memo_text, contbr_id, cmte_id)
        group by cmte_id, cycle, zip
    ),
    inc as (
        update ofec_sched_a_aggregate_zip ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.zip) = (patch.cmte_id, patch.cycle, patch.zip)
    )
    insert into ofec_sched_a_aggregate_zip (
        select patch.* from patch
        left join ofec_sched_a_aggregate_zip ag using (cmte_id, cycle, zip)
        where ag.cmte_id is null
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_a_update_aggregate_zip() OWNER TO fec;

--
-- Name: ofec_sched_a_update_fulltext(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_a_update_fulltext() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    delete from ofec_sched_a_fulltext
    where sched_a_sk = any(select sched_a_sk from ofec_sched_a_queue_old)
    ;
    insert into ofec_sched_a_fulltext (
        select
            sched_a_sk,
            to_tsvector(contbr_nm) as contributor_name_text,
            to_tsvector(contbr_employer) as contributor_employer_text
        from ofec_sched_a_queue_new
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_a_update_fulltext() OWNER TO fec;

--
-- Name: ofec_sched_a_update_queues(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_a_update_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    start_year int = TG_ARGV[0]::int;
    timestamp timestamp = current_timestamp;
    two_year_transaction_period_new smallint;
    two_year_transaction_period_old smallint;
begin
    if tg_op = 'INSERT' then
        two_year_transaction_period_new = get_transaction_year(new.contb_receipt_dt, new.rpt_yr);
        if two_year_transaction_period_new >= start_year then
            delete from ofec_sched_a_queue_new where sub_id = new.sub_id;
            insert into ofec_sched_a_queue_new values (new.*, timestamp, two_year_transaction_period_new);
        end if;
        return new;
    elsif tg_op = 'UPDATE' then
        two_year_transaction_period_new = get_transaction_year(new.contb_receipt_dt, new.rpt_yr);
        two_year_transaction_period_old = get_transaction_year(old.contb_receipt_dt, old.rpt_yr);
        if two_year_transaction_period_new >= start_year then
            delete from ofec_sched_a_queue_new where sub_id = new.sub_id;
            delete from ofec_sched_a_queue_old where sub_id = old.sub_id;
            insert into ofec_sched_a_queue_new values (new.*, timestamp, two_year_transaction_period_new);
            insert into ofec_sched_a_queue_old values (old.*, timestamp, two_year_transaction_period_old);
        end if;
        return new;
    elsif tg_op = 'DELETE' then
        two_year_transaction_period_old = get_transaction_year(old.contb_receipt_dt, old.rpt_yr);
        if two_year_transaction_period_old >= start_year then
            delete from ofec_sched_a_queue_old where sub_id = old.sub_id;
            insert into ofec_sched_a_queue_old values (old.*, timestamp, two_year_transaction_period_old);
        end if;
        return old;
    end if;
end
$$;


ALTER FUNCTION public.ofec_sched_a_update_queues() OWNER TO fec;

--
-- Name: ofec_sched_b_delete_update_queues(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_b_delete_update_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    start_year int = TG_ARGV[0]::int;
    view_row public.fec_fitem_sched_b_vw%ROWTYPE;
begin
    select into view_row * from public.fec_fitem_sched_b_vw where sub_id = old.sub_id;
    if FOUND then
        if view_row.election_cycle >= start_year then
            delete from ofec_sched_b_queue_old where sub_id = view_row.sub_id;
            insert into ofec_sched_b_queue_old values (view_row.*, current_timestamp, view_row.election_cycle);
        end if;
    end if;
    if tg_op = 'DELETE' then
        return old;
    elsif tg_op = 'UPDATE' then
        return new;
    end if;
end
$$;


ALTER FUNCTION public.ofec_sched_b_delete_update_queues() OWNER TO fec;

--
-- Name: ofec_sched_b_insert_update_queues(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_b_insert_update_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    start_year int = TG_ARGV[0]::int;
    view_row public.fec_fitem_sched_b_vw%ROWTYPE;
begin
    select into view_row * from public.fec_fitem_sched_b_vw where sub_id = new.sub_id;
    if FOUND then
        if view_row.election_cycle >= start_year then
            delete from ofec_sched_b_queue_new where sub_id = view_row.sub_id;
            insert into ofec_sched_b_queue_new values (view_row.*, current_timestamp, view_row.election_cycle);
        end if;
    end if;
    RETURN NULL; -- result is ignored since this is an AFTER trigger
end
$$;


ALTER FUNCTION public.ofec_sched_b_insert_update_queues() OWNER TO fec;

--
-- Name: ofec_sched_b_update(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_b_update() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    delete from ofec_sched_b
    where sched_b_sk = any(select sched_b_sk from ofec_sched_b_queue_old)
    ;
    insert into ofec_sched_b(
        select distinct on(sched_b_sk)
            new.*,
            image_pdf_url(new.image_num) as pdf_url,
            to_tsvector(new.recipient_nm) || to_tsvector(coalesce(clean_repeated(new.recipient_cmte_id, new.cmte_id), ''))
                as recipient_name_text,
            to_tsvector(new.disb_desc) as disbursement_description_text,
            disbursement_purpose(new.disb_tp, new.disb_desc) as disbursement_purpose_category,
            clean_repeated(new.recipient_cmte_id, new.cmte_id) as clean_recipient_cmte_id
        from ofec_sched_b_queue_new new
        left join ofec_sched_b_queue_old old on new.sched_b_sk = old.sched_b_sk and old.timestamp > new.timestamp
        where old.sched_b_sk is null
        order by new.sched_b_sk, new.timestamp desc
    );
end
$$;


ALTER FUNCTION public.ofec_sched_b_update() OWNER TO fec;

--
-- Name: ofec_sched_b_update_aggregate_purpose(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_b_update_aggregate_purpose() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    with new as (
        select 1 as multiplier, cmte_id, rpt_yr, disb_tp, disb_desc, disb_amt, memo_cd
        from ofec_sched_b_queue_new
    ),
    old as (
        select -1 as multiplier, cmte_id, rpt_yr, disb_tp, disb_desc, disb_amt, memo_cd
        from ofec_sched_b_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            disbursement_purpose(disb_tp, disb_desc) as purpose,
            sum(disb_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where disb_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, purpose
    ),
    inc as (
        update ofec_sched_b_aggregate_purpose ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.purpose) = (patch.cmte_id, patch.cycle, patch.purpose)
    )
    insert into ofec_sched_b_aggregate_purpose (
        select patch.* from patch
        left join ofec_sched_b_aggregate_purpose ag using (cmte_id, cycle, purpose)
        where ag.cmte_id is null
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_b_update_aggregate_purpose() OWNER TO fec;

--
-- Name: ofec_sched_b_update_aggregate_recipient(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_b_update_aggregate_recipient() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    with new as (
        select 1 as multiplier, cmte_id, rpt_yr, recipient_nm, disb_amt, memo_cd
        from ofec_sched_b_queue_new
    ),
    old as (
        select -1 as multiplier, cmte_id, rpt_yr, recipient_nm, disb_amt, memo_cd
        from ofec_sched_b_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            recipient_nm,
            sum(disb_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where disb_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, recipient_nm
    ),
    inc as (
        update ofec_sched_b_aggregate_recipient ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.recipient_nm) = (patch.cmte_id, patch.cycle, patch.recipient_nm)
    )
    insert into ofec_sched_b_aggregate_recipient (
        select patch.* from patch
        left join ofec_sched_b_aggregate_recipient ag using (cmte_id, cycle, recipient_nm)
        where ag.cmte_id is null
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_b_update_aggregate_recipient() OWNER TO fec;

--
-- Name: ofec_sched_b_update_aggregate_recipient_id(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_b_update_aggregate_recipient_id() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    with new as (
        select 1 as multiplier, cmte_id, rpt_yr, recipient_cmte_id, recipient_nm, disb_amt, memo_cd
        from ofec_sched_b_queue_new
    ),
    old as (
        select -1 as multiplier, cmte_id, rpt_yr, recipient_cmte_id, recipient_nm, disb_amt, memo_cd
        from ofec_sched_b_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            clean_repeated(recipient_cmte_id, cmte_id) as recipient_cmte_id,
            max(recipient_nm) as recipient_nm,
            sum(disb_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where disb_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        and clean_repeated(recipient_cmte_id, cmte_id) is not null
        group by cmte_id, cycle, clean_repeated(recipient_cmte_id, cmte_id)
    ),
    inc as (
        update ofec_sched_b_aggregate_recipient_id ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.recipient_cmte_id) = (patch.cmte_id, patch.cycle, patch.recipient_cmte_id)
    )
    insert into ofec_sched_b_aggregate_recipient_id (
        select patch.* from patch
        left join ofec_sched_b_aggregate_recipient_id ag using (cmte_id, cycle, recipient_cmte_id)
        where ag.cmte_id is null
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_b_update_aggregate_recipient_id() OWNER TO fec;

--
-- Name: ofec_sched_b_update_fulltext(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_b_update_fulltext() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    delete from ofec_sched_b_fulltext
    where sched_b_sk = any(select sched_b_sk from ofec_sched_b_queue_old)
    ;
    insert into ofec_sched_b_fulltext (
        select
            sched_b_sk,
            to_tsvector(recipient_nm) as recipient_name_text,
            to_tsvector(disb_desc) as disbursement_description_text
        from ofec_sched_b_queue_new
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_b_update_fulltext() OWNER TO fec;

--
-- Name: ofec_sched_b_update_queues(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_b_update_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    start_year int = TG_ARGV[0]::int;
    timestamp timestamp = current_timestamp;
    two_year_transaction_period_new smallint;
    two_year_transaction_period_old smallint;
begin
    if tg_op = 'INSERT' then
        two_year_transaction_period_new = get_transaction_year(new.disb_dt, new.rpt_yr);
        if two_year_transaction_period_new >= start_year then
            delete from ofec_sched_b_queue_new where sub_id = new.sub_id;
            insert into ofec_sched_b_queue_new values (new.*, timestamp, two_year_transaction_period_new);
        end if;
        return new;
    elsif tg_op = 'UPDATE' then
        two_year_transaction_period_new = get_transaction_year(new.disb_dt, new.rpt_yr);
        two_year_transaction_period_old = get_transaction_year(old.disb_dt, old.rpt_yr);
        if two_year_transaction_period_new >= start_year then
            delete from ofec_sched_b_queue_new where sub_id = new.sub_id;
            delete from ofec_sched_b_queue_old where sub_id = old.sub_id;
            insert into ofec_sched_b_queue_new values (new.*, timestamp, two_year_transaction_period_new);
            insert into ofec_sched_b_queue_old values (old.*, timestamp, two_year_transaction_period_old);
        end if;
        return new;
    elsif tg_op = 'DELETE' then
        two_year_transaction_period_old = get_transaction_year(old.disb_dt, old.rpt_yr);
        if two_year_transaction_period_old >= start_year then
            delete from ofec_sched_b_queue_old where sub_id = old.sub_id;
            insert into ofec_sched_b_queue_old values (old.*, timestamp, two_year_transaction_period_old);
        end if;
        return old;
    end if;
end
$$;


ALTER FUNCTION public.ofec_sched_b_update_queues() OWNER TO fec;

--
-- Name: ofec_sched_c_update(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_c_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.loan_source_name_text := to_tsvector(new.loan_src_nm);
  new.candidate_name_text := to_tsvector(new.cand_nm);
  return new;
end
$$;


ALTER FUNCTION public.ofec_sched_c_update() OWNER TO fec;

--
-- Name: ofec_sched_d_update(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_d_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.creditor_debtor_name_text := to_tsvector(new.cred_dbtr_nm);
  return new;
end
$$;


ALTER FUNCTION public.ofec_sched_d_update() OWNER TO fec;

--
-- Name: ofec_sched_e_f57_notice_update(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_e_f57_notice_update() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    delete from ofec_sched_e
    where sub_id = any(select sub_id from ofec_f57_queue_old)
    ;
    insert into ofec_sched_e (cmte_id, pye_nm, payee_l_nm, payee_f_nm, payee_m_nm, payee_prefix, payee_suffix,pye_st1, pye_st2, pye_city, pye_st,
        pye_zip, entity_tp, entity_tp_desc, catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_nm_first,
        s_o_cand_nm_last, s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
        s_o_cand_office_st, s_o_cand_office_st_desc, s_o_cand_office_district, s_o_ind, s_o_ind_desc, election_tp,
        fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt, exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm,
        conduit_cmte_st1, conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd, action_cd_desc,
        tran_id, filing_form, schedule_type, schedule_type_desc, image_num, file_num, link_id, orig_sub_id, sub_id,
        rpt_tp, rpt_yr, election_cycle, timestamp, pdf_url, is_notice, payee_name_text)
    select f57.filer_cmte_id,
        f57.pye_nm,
        f57.pye_l_nm,
        f57.pye_f_nm,
        f57.pye_m_nm,
        f57.pye_prefix,
        f57.pye_suffix,
        f57.pye_st1,
        f57.pye_st2,
        f57.pye_city,
        f57.pye_st,
        f57.pye_zip,
        f57.entity_tp,
        f57.entity_tp_desc,
        f57.catg_cd,
        f57.catg_cd_desc,
        f57.s_o_cand_id,
        f57.s_o_cand_nm,
        f57.s_o_cand_f_nm,
        f57.s_o_cand_l_nm,
        f57.s_o_cand_m_nm,
        f57.s_o_cand_prefix,
        f57.s_o_cand_suffix,
        f57.s_o_cand_office,
        f57.s_o_cand_office_desc,
        f57.s_o_cand_office_st,
        f57.s_o_cand_office_state_desc,
        f57.s_o_cand_office_district,
        f57.s_o_ind,
        f57.s_o_ind_desc,
        f57.election_tp,
        f57.fec_election_tp_desc,
        f57.cal_ytd_ofc_sought,
        f57.exp_amt,
        f57.exp_dt,
        f57.exp_tp,
        f57.exp_tp_desc,
        f57.conduit_cmte_id,
        f57.conduit_cmte_nm,
        f57.conduit_cmte_st1,
        f57.conduit_cmte_st2,
        f57.conduit_cmte_city,
        f57.conduit_cmte_st,
        f57.conduit_cmte_zip,
        f57.amndt_ind AS action_cd,
        f57.amndt_ind_desc AS action_cd_desc,
            CASE
                WHEN "substring"(f57.sub_id::character varying::text, 1, 1) = '4'::text THEN f57.tran_id
                ELSE NULL::character varying
            END AS tran_id,
        'F5' as filing_form,
        'SE-F57' AS schedule_type,
        f57.form_tp_desc AS schedule_type_desc,
        f57.image_num,
        f57.file_num,
        f57.link_id,
        f57.orig_sub_id,
        f57.sub_id,
        f5.rpt_tp,
        f5.rpt_yr,
        f5.rpt_yr + mod(f5.rpt_yr, 2::numeric) AS cycle,
        cast(null as timestamp) as TIMESTAMP,
        image_pdf_url(f57.image_num) as pdf_url,
        True,
        to_tsvector(f57.pye_nm)
    from ofec_f57_queue_new f57, disclosure.nml_form_5 f5
    where f57.link_id = f5.sub_id AND (f5.rpt_tp::text = ANY (ARRAY['24'::character varying, '48'::character varying]::text[])) AND f57.amndt_ind::text <> 'D'::text AND f57.delete_ind IS NULL AND f5.delete_ind IS NULL;
end
$$;


ALTER FUNCTION public.ofec_sched_e_f57_notice_update() OWNER TO fec;

--
-- Name: ofec_sched_e_notice_update_from_f24(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_e_notice_update_from_f24() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    delete from ofec_sched_e
    where sub_id = any(select sub_id from public.ofec_nml_24_queue_old)
    ;
    insert into ofec_sched_e (cmte_id, pye_nm, payee_l_nm, payee_f_nm, payee_m_nm, payee_prefix, payee_suffix,pye_st1, pye_st2, pye_city, pye_st,
        pye_zip, entity_tp, entity_tp_desc, catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_nm_first,
        s_o_cand_nm_last, s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
        s_o_cand_office_st, s_o_cand_office_st_desc, s_o_cand_office_district, memo_cd, memo_cd_desc, s_o_ind, s_o_ind_desc, election_tp,
        fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt, exp_dt, exp_tp, exp_tp_desc, memo_text, conduit_cmte_id, conduit_cmte_nm,
        conduit_cmte_st1, conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd, action_cd_desc,
        tran_id, filing_form, schedule_type, schedule_type_desc, image_num, file_num, link_id, orig_sub_id, sub_id,
        rpt_tp, rpt_yr, election_cycle, timestamp, pdf_url, is_notice, payee_name_text)
    select se.cmte_id,
        se.pye_nm,
        se.payee_l_nm as pye_l_nm,
        se.payee_f_nm as pye_f_nm,
        se.payee_m_nm as pye_m_nm,
        se.payee_prefix as pye_prefix,
        se.payee_suffix as pye_suffix,
        se.pye_st1,
        se.pye_st2,
        se.pye_city,
        se.pye_st,
        se.pye_zip,
        se.entity_tp,
        se.entity_tp_desc,
        se.catg_cd,
        se.catg_cd_desc,
        se.s_o_cand_id,
        se.s_o_cand_nm,
        se.s_o_cand_nm_first,
        se.s_o_cand_nm_last,
        se.s_0_cand_m_nm AS s_o_cand_m_nm,
        se.s_0_cand_prefix AS s_o_cand_prefix,
        se.s_0_cand_suffix AS s_o_cand_suffix,
        se.s_o_cand_office,
        se.s_o_cand_office_desc,
        se.s_o_cand_office_st,
        se.s_o_cand_office_st_desc,
        se.s_o_cand_office_district,
        se.memo_cd,
        se.memo_cd_desc,
        se.s_o_ind,
        se.s_o_ind_desc,
        se.election_tp,
        se.fec_election_tp_desc,
        se.cal_ytd_ofc_sought,
        se.exp_amt,
        se.exp_dt,
        se.exp_tp,
        se.exp_tp_desc,
        se.memo_text,
        se.conduit_cmte_id,
        se.conduit_cmte_nm,
        se.conduit_cmte_st1,
        se.conduit_cmte_st2,
        se.conduit_cmte_city,
        se.conduit_cmte_st,
        se.conduit_cmte_zip,
        se.amndt_ind AS action_cd,
        se.amndt_ind_desc AS action_cd_desc,
            CASE
                WHEN "substring"(se.sub_id::character varying::text, 1, 1) = '4'::text THEN se.tran_id
                ELSE NULL::character varying
            END AS tran_id,
        'F24' AS filing_form,
        'SE' AS schedule_type,
        se.form_tp_desc AS schedule_type_desc,
        se.image_num,
        se.file_num,
        se.link_id,
        se.orig_sub_id,
        se.sub_id,
        f24.rpt_tp,
        f24.rpt_yr,
        f24.rpt_yr + mod(f24.rpt_yr, 2::numeric) AS cycle,
        cast(null as timestamp) as TIMESTAMP,
        image_pdf_url(se.image_num) as pdf_url,
        True,
        to_tsvector(se.pye_nm)
    from disclosure.nml_form_24 f24, public.ofec_nml_24_queue_new se
    where se.link_id = f24.sub_id and f24.delete_ind is null and se.delete_ind is null and se.amndt_ind::text <> 'D'::text;
end
$$;


ALTER FUNCTION public.ofec_sched_e_notice_update_from_f24() OWNER TO fec;

--
-- Name: ofec_sched_e_update(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_e_update() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    delete from ofec_sched_e
    where sub_id = any(select sub_id from ofec_sched_e_queue_old)
    ;
    insert into ofec_sched_e (
        select
            new.*,
            image_pdf_url(new.image_num) as pdf_url,
            coalesce(new.rpt_tp, '') in ('24', '48') as is_notice,
            to_tsvector(new.pye_nm) as payee_name_text,
            now() as pg_date
        from ofec_sched_e_queue_new new
        left join ofec_sched_e_queue_old old on new.sub_id = old.sub_id and old.timestamp > new.timestamp
        where old.sub_id is null
        order by new.sub_id, new.timestamp desc
    );
end
$$;


ALTER FUNCTION public.ofec_sched_e_update() OWNER TO fec;

--
-- Name: ofec_sched_e_update_from_f57(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_e_update_from_f57() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    delete from ofec_sched_e
    where sub_id = any(select sub_id from fec_vsum_f57_queue_old)
    ;
    insert into ofec_sched_e (cmte_id, pye_nm, payee_l_nm, payee_f_nm, payee_m_nm, payee_prefix, payee_suffix,pye_st1, pye_st2, pye_city, pye_st,
        pye_zip, entity_tp, entity_tp_desc, catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_nm_first,
        s_o_cand_nm_last, s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
        s_o_cand_office_st, s_o_cand_office_st_desc, s_o_cand_office_district, s_o_ind, s_o_ind_desc, election_tp,
        fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt, exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm,
        conduit_cmte_st1, conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip,tran_id, filing_form,
        schedule_type, image_num, file_num, link_id, orig_sub_id, sub_id,
        timestamp, pdf_url, is_notice, payee_name_text)
    select f57.filer_cmte_id,
        f57.pye_nm,
        f57.pye_l_nm,
        f57.pye_f_nm,
        f57.pye_m_nm,
        f57.pye_prefix,
        f57.pye_suffix,
        f57.pye_st1,
        f57.pye_st2,
        f57.pye_city,
        f57.pye_st,
        f57.pye_zip,
        f57.entity_tp,
        f57.entity_tp_desc,
        f57.catg_cd,
        f57.catg_cd_desc,
        f57.s_o_cand_id,
        f57.s_o_cand_nm,
        f57.s_o_cand_f_nm,
        f57.s_o_cand_l_nm,
        f57.s_o_cand_m_nm,
        f57.s_o_cand_prefix,
        f57.s_o_cand_suffix,
        f57.s_o_cand_office,
        f57.s_o_cand_office_desc,
        f57.s_o_cand_office_st,
        f57.s_o_cand_office_state_desc,
        f57.s_o_cand_office_district,
        f57.s_o_ind,
        f57.s_o_ind_desc,
        f57.election_tp,
        f57.fec_election_tp_desc,
        f57.cal_ytd_ofc_sought,
        f57.exp_amt,
        f57.exp_dt,
        f57.exp_tp,
        f57.exp_tp_desc,
        f57.conduit_cmte_id,
        f57.conduit_cmte_nm,
        f57.conduit_cmte_st1,
        f57.conduit_cmte_st2,
        f57.conduit_cmte_city,
        f57.conduit_cmte_st,
        f57.conduit_cmte_zip,
        f57.tran_id,
        f57.filing_form,
        f57.schedule_type,
        f57.image_num,
        f57.file_num,
        f57.link_id,
        f57.orig_sub_id,
        f57.sub_id,
        cast(null as timestamp) as TIMESTAMP,
        image_pdf_url(f57.image_num) as pdf_url,
        False,
        to_tsvector(f57.pye_nm)
    from fec_vsum_f57_queue_new f57;
end
$$;


ALTER FUNCTION public.ofec_sched_e_update_from_f57() OWNER TO fec;

--
-- Name: ofec_sched_e_update_fulltext(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_e_update_fulltext() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    delete from ofec_sched_e_fulltext
    where sched_e_sk = any(select sched_e_sk from ofec_sched_e_queue_old)
    ;
    insert into ofec_sched_e_fulltext (
        select
            sched_e_sk,
            to_tsvector(pye_nm) as payee_name_text
        from ofec_sched_e_queue_new
    )
    ;
end
$$;


ALTER FUNCTION public.ofec_sched_e_update_fulltext() OWNER TO fec;

--
-- Name: ofec_sched_e_update_notice_queues(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_e_update_notice_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if tg_op = 'INSERT' then
        delete from public.ofec_nml_24_queue_new where sub_id = new.sub_id;
        insert into public.ofec_nml_24_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from public.ofec_nml_24_queue_new where sub_id = new.sub_id;
        delete from public.ofec_nml_24_queue_old where sub_id = old.sub_id;
        insert into public.ofec_nml_24_queue_new values (new.*);
        insert into public.ofec_nml_24_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from public.ofec_nml_24_queue_old where sub_id = old.sub_id;
        insert into public.ofec_nml_24_queue_old values (old.*);
        return old;
    end if;
end
$$;


ALTER FUNCTION public.ofec_sched_e_update_notice_queues() OWNER TO fec;

--
-- Name: ofec_sched_e_update_queues(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION ofec_sched_e_update_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    start_year int = TG_ARGV[0]::int;
begin
    if tg_op = 'INSERT' then
        delete from ofec_sched_e_queue_new where sub_id = new.sub_id;
        insert into ofec_sched_e_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from ofec_sched_e_queue_new where sub_id = new.sub_id;
        delete from ofec_sched_e_queue_old where sub_id = old.sub_id;
        insert into ofec_sched_e_queue_new values (new.*);
        insert into ofec_sched_e_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from ofec_sched_e_queue_old where sub_id = old.sub_id;
        insert into ofec_sched_e_queue_old values (old.*);
        return old;
    end if;
end
$$;


ALTER FUNCTION public.ofec_sched_e_update_queues() OWNER TO fec;

--
-- Name: real_efile_sa7_update(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION real_efile_sa7_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.contributor_name_text := to_tsvector(concat_ws(',', new.fname, new.name, new.mname));
  return new;
end
$$;


ALTER FUNCTION public.real_efile_sa7_update() OWNER TO fec;

--
-- Name: refresh_materialized(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION refresh_materialized(schema_arg text DEFAULT 'public'::text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    view RECORD;
  BEGIN
    RAISE NOTICE 'Refreshing materialized views in schema %', schema_arg;
    FOR view IN SELECT matviewname FROM pg_matviews WHERE schemaname = schema_arg
    LOOP
      RAISE NOTICE 'Refreshing %.%', schema_arg, view.matviewname;
      EXECUTE 'REFRESH MATERIALIZED VIEW CONCURRENTLY ' || schema_arg || '.' || view.matviewname;
    END LOOP;
    RETURN 1;
  END
$$;


ALTER FUNCTION public.refresh_materialized(schema_arg text) OWNER TO fec;

--
-- Name: rename_indexes(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION rename_indexes(p_table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
    indexes_cursor CURSOR FOR
        SELECT indexname AS name
        FROM pg_indexes
        WHERE tablename = p_table_name;
BEGIN
    FOR index_name IN indexes_cursor LOOP
        EXECUTE format('ALTER INDEX %1$I RENAME TO %2$I', index_name.name, regexp_replace(index_name.name, '_tmp', ''));
    END LOOP;
END
$_$;


ALTER FUNCTION public.rename_indexes(p_table_name text) OWNER TO fec;

--
-- Name: rename_table_cascade(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION rename_table_cascade(table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
    child_tmp_table_name TEXT;
    child_table_name TEXT;
    child_tables_cursor CURSOR (parent TEXT) FOR
        SELECT c.oid::pg_catalog.regclass AS name
        FROM pg_catalog.pg_class c, pg_catalog.pg_inherits i
        WHERE c.oid=i.inhrelid
            AND i.inhparent = (SELECT oid from pg_catalog.pg_class rc where relname = parent);
BEGIN
    EXECUTE format('DROP TABLE IF EXISTS %I CASCADE', table_name);
    EXECUTE format('ALTER TABLE %1$I_tmp RENAME TO %1$I', table_name);
    FOR child_tmp_table IN child_tables_cursor(table_name) LOOP
        child_tmp_table_name = child_tmp_table.name;
        child_table_name =  regexp_replace(child_tmp_table_name, '_tmp$', '');
        EXECUTE format('ALTER TABLE %1$I RENAME TO %2$I', child_tmp_table_name, child_table_name);
        PERFORM rename_indexes(child_table_name);
    END LOOP;
END
$_$;


ALTER FUNCTION public.rename_table_cascade(table_name text) OWNER TO fec;

--
-- Name: rename_temporary_views(text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION rename_temporary_views(schema_arg text DEFAULT 'public'::text, suffix text DEFAULT '_tmp'::text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    view RECORD;
    view_name TEXT;
  BEGIN
    RAISE NOTICE 'Renaming temporary materialized views in schema %', schema_arg;
    FOR view IN SELECT matviewname FROM pg_matviews WHERE schemaname = schema_arg AND matviewname LIKE '%' || suffix
    LOOP
      RAISE NOTICE 'Renaming %.%', schema_arg, view.matviewname;
      view_name := replace(view.matviewname, suffix, '');
      EXECUTE 'DROP MATERIALIZED VIEW IF EXISTS ' || schema_arg || '.' || view_name || ' CASCADE';
      EXECUTE 'ALTER MATERIALIZED VIEW ' || schema_arg || '.' || view.matviewname || ' RENAME TO ' || view_name;
    END LOOP;
    RETURN 1;
  END
$$;


ALTER FUNCTION public.rename_temporary_views(schema_arg text, suffix text) OWNER TO fec;

--
-- Name: report_fec_url(text, integer); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION report_fec_url(image_number text, file_number integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
begin
    return case
        when file_number < 1 then null
        when image_number is not null and not is_electronic(image_number) then format(
            'http://docquery.fec.gov/paper/posted/%1$s.fec',
            file_number
        )
        when image_number is not null and is_electronic(image_number) then format(
            'http://docquery.fec.gov/dcdev/posted/%1$s.fec',
            file_number
        )
    end;
end
$_$;


ALTER FUNCTION public.report_fec_url(image_number text, file_number integer) OWNER TO fec;

--
-- Name: report_html_url(text, text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION report_html_url(means_filed text, cmte_id text, filing_id text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
BEGIN
    return CASE
       when means_filed = 'paper' and filing_id::int > 0 then format (
           'http://docquery.fec.gov/cgi-bin/paper_forms/%1$s/%2$s/',
            cmte_id,
            filing_id
       )
       when means_filed = 'e-file' then format (
           'http://docquery.fec.gov/cgi-bin/forms/%1$s/%2$s/',
            cmte_id,
            filing_id
       )
       else null
    end;
END
$_$;


ALTER FUNCTION public.report_html_url(means_filed text, cmte_id text, filing_id text) OWNER TO fec;

--
-- Name: report_pdf_url(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION report_pdf_url(image_number text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
begin
    return case
        when image_number is not null then format(
            'http://docquery.fec.gov/pdf/%1$s/%2$s/%2$s.pdf',
            substr(image_number, length(image_number) - 2, length(image_number)),
            image_number
        )
        else null
    end;
end
$_$;


ALTER FUNCTION public.report_pdf_url(image_number text) OWNER TO fec;

--
-- Name: report_pdf_url_or_null(text, numeric, text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION report_pdf_url_or_null(image_number text, report_year numeric, committee_type text, form_type text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return case
        when image_number is not null and (
                report_year >= 2000 or
                (form_type in ('F3X', 'F3P') and report_year > 1993) or
                (form_type = 'F3' and committee_type = 'H' and report_year > 1996)
            ) then report_pdf_url(image_number)
        else null
    end;
end
$$;


ALTER FUNCTION public.report_pdf_url_or_null(image_number text, report_year numeric, committee_type text, form_type text) OWNER TO fec;

--
-- Name: rollback_real_time_filings(bigint); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION rollback_real_time_filings(p_repid bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
 cur_del CURSOR FOR
    SELECT  table_name
       FROM information_schema.tables
       WHERE  table_schema='public'
        and table_catalog='fec'
        and table_type='BASE TABLE'
    and (table_name like 'real_efile%' or  table_name like 'real_pfile%');
v_table text;
begin
   OPEN cur_del;
 loop
  fetch cur_del into v_table;
   EXIT WHEN NOT FOUND;
  -- RAISE NOTICE 'delete from % where repid= %',v_table,p_repid;
    execute 'delete from '||v_table ||' where repid='||p_repid;
 end loop;
close cur_del;
return 'SUCCESS';
end
$$;


ALTER FUNCTION public.rollback_real_time_filings(p_repid bigint) OWNER TO fec;

--
-- Name: strip_triggers(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION strip_triggers() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$ DECLARE
    triggNameRecord RECORD;
    triggTableRecord RECORD;
BEGIN
    FOR triggNameRecord IN select distinct(trigger_name) from information_schema.triggers where trigger_schema = 'public' LOOP
        FOR triggTableRecord IN SELECT distinct(event_object_table) from information_schema.triggers where trigger_name = triggNameRecord.trigger_name LOOP
            RAISE NOTICE 'Dropping trigger: % on table: %', triggNameRecord.trigger_name, triggTableRecord.event_object_table;
            EXECUTE 'DROP TRIGGER ' || triggNameRecord.trigger_name || ' ON ' || triggTableRecord.event_object_table || ';';
        END LOOP;
    END LOOP;
END;
$$;


ALTER FUNCTION public.strip_triggers() OWNER TO fec;

--
-- Name: upd_pg_date(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION upd_pg_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.pg_date := now()::timestamp(0);
  return new;
end
$$;


ALTER FUNCTION public.upd_pg_date() OWNER TO fec;

--
-- Name: update_aggregates(); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE FUNCTION update_aggregates() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    perform ofec_sched_a_update_aggregate_zip();
    perform ofec_sched_a_update_aggregate_size();
    perform ofec_sched_a_update_aggregate_state();
    perform ofec_sched_a_update_aggregate_employer();
    perform ofec_sched_a_update_aggregate_occupation();

    perform ofec_sched_b_update_aggregate_purpose();
    perform ofec_sched_b_update_aggregate_recipient();
    perform ofec_sched_b_update_aggregate_recipient_id();
end
$$;


ALTER FUNCTION public.update_aggregates() OWNER TO fec;
