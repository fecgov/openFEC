SET idle_in_transaction_session_timeout = 0;
SET row_security = off;
SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE EXTENSION IF NOT EXISTS btree_gin;

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;

CREATE SCHEMA disclosure;

CREATE SCHEMA fecapp;

CREATE SCHEMA real_efile;

CREATE SCHEMA staging;


SET search_path = disclosure, pg_catalog;

CREATE FUNCTION get_first_receipt_dt(pcand_cmte_id character varying, pfiler_tp numeric) RETURNS date
    LANGUAGE plpgsql
    AS $$ declare my_date date := null; begin if  (pfiler_tp = 1) then select min(RECEIPT_DT) into my_date from DISCLOSURE.NML_FORM_1_1Z_VIEW where cmte_id=pcand_cmte_id; else select min(RECEIPT_DT) into my_date from DISCLOSURE.NML_FORM_2_2Z_VIEW where cand_id=pcand_cmte_id; end if; return my_date; end; $$;

CREATE FUNCTION get_pcmte_nm(pcand_cmte_id character varying, pfiler_tp numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$ declare pCMTE_NM  varchar := null; begin if (pfiler_tp = 1) then select CMTE_NM into pCMTE_NM from (select CMTE_NM, rank() over (partition by cmte_id order by FEC_ELECTION_YR desc) as rank_num from DISCLOSURE.CMTE_VALID_FEC_YR where cmte_id=pcand_cmte_id) as cmte_query where rank_num=1; else select CAND_NAME  into pCMTE_NM from (select CAND_NAME, rank() over (partition by cand_id order by FEC_ELECTION_YR desc) as rank_num from DISCLOSURE.CAND_VALID_FEC_YR where cand_id=pcand_cmte_id) as cand_query where rank_num=1; end if; return pCMTE_NM; end; $$;

SET search_path = public, pg_catalog;

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

CREATE FUNCTION array_distinct(anyarray) RETURNS anyarray
    LANGUAGE sql
    AS $_$
  SELECT ARRAY(SELECT DISTINCT unnest($1))
$_$;

CREATE FUNCTION array_sort(anyarray) RETURNS anyarray
    LANGUAGE sql
    AS $_$
  SELECT ARRAY(SELECT unnest($1) ORDER BY 1)
$_$;

-- Handle typos and notes in party description:
-- * "Commandments Party (Removed)" becomes "Commandments Party"
-- * "Green Party Added)" becomes "Green Party"
CREATE FUNCTION clean_party(party text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
begin
    return regexp_replace(party, '\s*(Added|Removed|\(.*?)\)$', '');
end
$_$;


-- Compare two values. If equal, return `NULL`, else return the first value.
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


-- These fields include additional descriptions in curly braces that we don't want to show in the dimreporttype table that appear in curly braces. Like: { one of 4 codes }
CREATE FUNCTION clean_report(report text) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
    return trim(both from regexp_replace(report, ' {.*}', ''));
end
$$;


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


CREATE FUNCTION contributor_type(value text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
    return upper(value) in ('11AI', '17A');
end
$$;


-- 24-Hour Report Period of Independent Expenditures begins for the xx. Ends on xx.
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


-- 48-Hour Report Period of Independent Expenditures begins for the xx. Ends on xx.
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


CREATE FUNCTION create_contest(election_state text, election_district numeric) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when office_sought = 'H' and election_district != ' ' then array_to_string(
                array[
                    election_state,
                    election_district
                ], '-')
            else election_state
        end;
    end
$$;


-- To keep the titles concise states are abbreviated as multi state if there is more than one
-- Like:
    -- FL: House General Election Held Today
    -- NH, DE: DEM Convention Held Today
    -- General Election Multi-state Held Today
-- used for elections and as a part of the elections in IE descriptions
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


-- Electioneering Communications Period begins for the xx. Ends on Election Day, xx.
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


CREATE FUNCTION date_or_null(value text, format text) RETURNS date
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return to_date(value, format);
exception
    when others then return null::date;
end
$$;


-- Descriptions and summaries are repetitive, so we are trying to only show the descriptions in some places, That works for most things except court cases, advisory opinions and conferences.
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


CREATE OR REPLACE FUNCTION expand_candidate_incumbent(acronym TEXT)
RETURNS TEXT AS $$
    BEGIN
        RETURN CASE acronym
            WHEN 'I' THEN 'Incumbent'
            WHEN 'C' THEN 'Challenger'
            WHEN 'O' THEN 'Open seat'
            ELSE NULL
        END;
    END
$$ LANGUAGE plpgsql;


CREATE FUNCTION expand_candidate_status(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN CASE acronym
            WHEN 'C' THEN 'Candidate'
            WHEN 'F' THEN 'Future candidate'
            WHEN 'N' THEN 'Not yet a candidate'
            WHEN 'P' THEN 'Prior candidate'
            ELSE NULL
        END;
    END
$$;


CREATE FUNCTION expand_committee_designation(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN CASE acronym
            WHEN 'A' THEN 'Authorized by a candidate'
            WHEN 'J' THEN 'Joint fundraising committee'
            WHEN 'P' THEN 'Principal campaign committee'
            WHEN 'U' THEN 'Unauthorized'
            WHEN 'B' THEN 'Lobbyist/Registrant PAC'
            WHEN 'D' THEN 'Leadership PAC'
            ELSE NULL
        END;
    END
$$;


CREATE FUNCTION expand_committee_type(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN CASE acronym
            WHEN 'P' THEN 'Presidential'
            WHEN 'H' THEN 'House'
            WHEN 'S' THEN 'Senate'
            WHEN 'C' THEN 'Communication Cost'
            WHEN 'D' THEN 'Delegate Committee'
            WHEN 'E' THEN 'Electioneering Communication'
            WHEN 'I' THEN 'Independent Expenditor (Person or Group)'
            WHEN 'N' THEN 'PAC - Nonqualified'
            WHEN 'O' THEN 'Super PAC (Independent Expenditure-Only)'
            WHEN 'Q' THEN 'PAC - Qualified'
            WHEN 'U' THEN 'Single Candidate Independent Expenditure'
            WHEN 'V' THEN 'PAC with Non-Contribution Account - Nonqualified'
            WHEN 'W' THEN 'PAC with Non-Contribution Account - Qualified'
            WHEN 'X' THEN 'Party - Nonqualified'
            WHEN 'Y' THEN 'Party - Qualified'
            WHEN 'Z' THEN 'National Party Nonfederal Account'
            ELSE NULL
        END;
    END
$$;


CREATE FUNCTION expand_document(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN CASE acronym
            WHEN '2' THEN '24 Hour Contribution Notice'
            WHEN '4' THEN '48 Hour Contribution Notice'
            WHEN 'A' THEN 'Debt Settlement Statement'
            WHEN 'B' THEN 'Acknowledgment of Receipt of Debt Settlement Statement'
            WHEN 'C' THEN 'RFAI: Debt Settlement First Notice'
            WHEN 'D' THEN 'Commission Debt Settlement Review'
            WHEN 'E' THEN 'Commission Response TO Debt Settlement Request'
            WHEN 'F' THEN 'Administrative Termination'
            WHEN 'G' THEN 'Debt Settlement Plan Amendment'
            WHEN 'H' THEN 'Disavowal Notice'
            WHEN 'I' THEN 'Disavowal Response'
            WHEN 'J' THEN 'Conduit Report'
            WHEN 'K' THEN 'Termination Approval'
            WHEN 'L' THEN 'Repeat Non-Filer Notice'
            WHEN 'M' THEN 'Filing Frequency Change Notice'
            WHEN 'N' THEN 'Paper Amendment to Electronic Report'
            WHEN 'O' THEN 'Acknowledgment of Filing Frequency Change'
            WHEN 'S' THEN 'RFAI: Debt Settlement Second'
            WHEN 'T' THEN 'Miscellaneous Report TO FEC'
            WHEN 'V' THEN 'Repeat Violation Notice (441A OR 441B)'
            WHEN 'P' THEN 'Notice of Paper Filing'
            WHEN 'R' THEN 'F3L Filing Frequency Change Notice'
            WHEN 'Q' THEN 'Acknowledgment of F3L Filing Frequency Change'
            WHEN 'U' THEN 'Unregistered Committee Notice'
            ELSE NULL
        END;
    END
$$;


CREATE OR REPLACE FUNCTION expand_election_type(acronym TEXT)
RETURNS TEXT AS $$
    BEGIN
        RETURN CASE acronym
            WHEN 'P' THEN 'Primary Election'
            WHEN 'PR' THEN 'Primary Runoff Election'
            WHEN 'SP' THEN 'Special Primary Election'
            WHEN 'SPR' THEN 'Special Primary Runoff Election'
            WHEN 'G' THEN 'General Election'
            WHEN 'GR' THEN 'General Runoff Election'
            WHEN 'SG' THEN 'Special General Election'
            WHEN 'SGR' THEN 'Special General Runoff Election'
            WHEN 'O' THEN 'Other'
            WHEN 'C' THEN 'Caucus or Convention'
            WHEN 'CAU' THEN 'Caucus'
            WHEN 'CON' THEN 'Convention'
            WHEN 'SC' THEN 'Special Convention'
            WHEN 'R' THEN 'Runoff Election'
            WHEN 'SR' THEN 'Special Runoff Election'
            WHEN 'S' THEN 'Special Election'
            WHEN 'E' THEN 'Recount Election'
            ELSE NULL
        END;
    END
$$ LANGUAGE plpgsql;


-- this is a short term fix to correct a coding error where the code C was used for caucuses and conventions
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


-- because we can't just add an s to pluralize caucus
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
CREATE FUNCTION expand_line_number(form_type text, line_number text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN CASE form_type
            WHEN 'F3X' THEN expand_line_number_f3x(line_number)
            WHEN 'F3P' THEN expand_line_number_f3p(line_number)
            WHEN 'F3' THEN expand_line_number_f3(line_number)
            ELSE NULL
        END;
    END
$$;


CREATE FUNCTION expand_line_number_f3(line_number text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN CASE line_number
            WHEN '11A1' THEN 'Contributions From Individuals/Persons Other Than Political Committees'
            WHEN '11AI' THEN 'Contributions From Individuals/Persons Other Than Political Committees'
            WHEN '11B' THEN 'Contributions From Political Party Committees'
            WHEN '11C' THEN 'Contributions From Other Political Committees'
            WHEN '11D' THEN 'Contributions From the Candidate'
            WHEN '12' THEN 'Transfers from authorized committees'
            WHEN '13' THEN 'Loans Received'
            WHEN '13A' THEN 'Loans Received from the Candidate'
            WHEN '13B' THEN 'All Other Loans Received'
            WHEN '14' THEN 'Offsets to Operating Expenditures'
            WHEN '15' THEN 'Total Amount of Other Receipts'
            WHEN '17' THEN 'Operating Expenditures'
            WHEN '18' THEN 'Transfers to Other Authorized Committees'
            WHEN '19' THEN 'Loan Repayments'
            WHEN '19A' THEN 'Loan Repayments Made or Guaranteed by Candidate'
            WHEN '19B' THEN 'Other Loan Repayments'
            WHEN '20A' THEN 'Refunds of Contributions to Individuals/Persons Other Than Political Committees'
            WHEN '20B' THEN 'Refunds of Contributions to Political Party Committees'
            WHEN '20C' THEN 'Refunds of Contributions to Other Political Committees'
            WHEN '21' THEN 'Other Disbursements'
            ELSE NULL
        END;
    END
$$;


CREATE FUNCTION expand_line_number_f3p(line_number text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN CASE line_number
            WHEN '16' THEN 'Federal Funds'
            WHEN '17A' THEN 'Contributions From Individuals/Persons Other Than Political Committees'
            WHEN '17B' THEN 'Contributions From Political Party Committees'
            WHEN '17C' THEN 'Contributions From Other Political Committees'
            WHEN '17D' THEN 'Contributions From the Candidate'
            WHEN '18' THEN 'Transfers From Other Authorized Committees'
            WHEN '19A' THEN 'Loans Received From or Guaranteed by Candidate'
            WHEN '19B' THEN 'Other Loans'
            WHEN '20A' THEN 'Offsets To Expenditures - Operating'
            WHEN '20B' THEN 'Offsets To Expenditures - Fundraising'
            WHEN '20C' THEN 'Offsets To Expenditures - Legal and Accounting'
            WHEN '21' THEN 'Other Receipts'
            WHEN '23' THEN 'Operating Expenditures'
            WHEN '24' THEN 'Transfers to Other Authorized Committees'
            WHEN '25' THEN 'Fundraising Disbursements'
            WHEN '26' THEN 'Exempt Legal and Accounting Disbursements'
            WHEN '27A' THEN 'Loan Repayments Made or Guaranteed by Candidate'
            WHEN '27B' THEN 'Other Loan Repayments'
            WHEN '28A' THEN 'Refunds of Contributions to Individuals/Persons Other Than Political Committees'
            WHEN '28B' THEN 'Refunds of Contributions to Political Party Committees'
            WHEN '28C' THEN 'Refunds of Contributions to Other Political Committees'
            WHEN '29' THEN 'Other Disbursements'
            ELSE NULL
        END;
    END
$$;


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


CREATE OR REPLACE FUNCTION expand_office(acronym TEXT)
RETURNS TEXT AS $$
    BEGIN
        RETURN CASE acronym
            WHEN 'P' THEN 'President'
            WHEN 'S' THEN 'Senate'
            WHEN 'H' THEN 'House'
        END;
    END
$$ LANGUAGE plpgsql;


CREATE FUNCTION expand_office_description(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN CASE acronym
            WHEN 'P' THEN 'Presidential'
            WHEN 'S' THEN 'Senate'
            WHEN 'H' THEN 'House'
            ELSE NULL
        END;
    END
$$;


CREATE FUNCTION expand_organization_type(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN CASE acronym
            when 'C' THEN 'Corporation'
            WHEN 'L' THEN 'Labor Organization'
            WHEN 'M' THEN 'Membership Organization'
            WHEN 'T' THEN 'Trade Association'
            WHEN 'V' THEN 'Cooperative'
            WHEN 'W' THEN 'Corporation w/o capital stock'
            ELSE NULL
        END;
    END
$$;


CREATE FUNCTION expand_state(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN CASE acronym
            WHEN 'AK' THEN 'Alaska'
            WHEN 'AL' THEN 'Alabama'
            WHEN 'AS' THEN 'American Samoa'
            WHEN 'AR' THEN 'Arkansas'
            WHEN 'AZ' THEN 'Arizona'
            WHEN 'CA' THEN 'California'
            WHEN 'CO' THEN 'Colorado'
            WHEN 'CT' THEN 'Connecticut'
            WHEN 'DC' THEN 'District Of Columbia'
            WHEN 'DE' THEN 'Delaware'
            WHEN 'FL' THEN 'Florida'
            WHEN 'GA' THEN 'Georgia'
            WHEN 'GU' THEN 'Guam'
            WHEN 'HI' THEN 'Hawaii'
            WHEN 'IA' THEN 'Iowa'
            WHEN 'ID' THEN 'Idaho'
            WHEN 'IL' THEN 'Illinois'
            WHEN 'IN' THEN 'Indiana'
            WHEN 'KS' THEN 'Kansas'
            WHEN 'KY' THEN 'Kentucky'
            WHEN 'LA' THEN 'Louisiana'
            WHEN 'MA' THEN 'Massachusetts'
            WHEN 'MD' THEN 'Maryland'
            WHEN 'ME' THEN 'Maine'
            WHEN 'MI' THEN 'Michigan'
            WHEN 'MN' THEN 'Minnesota'
            WHEN 'MO' THEN 'Missouri'
            WHEN 'MS' THEN 'Mississippi'
            WHEN 'MT' THEN 'Montana'
            WHEN 'NC' THEN 'North Carolina'
            WHEN 'ND' THEN 'North Dakota'
            WHEN 'NE' THEN 'Nebraska'
            WHEN 'NH' THEN 'New Hampshire'
            WHEN 'NJ' THEN 'New Jersey'
            WHEN 'NM' THEN 'New Mexico'
            WHEN 'NV' THEN 'Nevada'
            WHEN 'NY' THEN 'New York'
            WHEN 'MP' THEN 'Northern Mariana Islands'
            WHEN 'OH' THEN 'Ohio'
            WHEN 'OK' THEN 'Oklahoma'
            WHEN 'OR' THEN 'Oregon'
            WHEN 'PA' THEN 'Pennsylvania'
            WHEN 'PR' THEN 'Puerto Rico'
            WHEN 'RI' THEN 'Rhode Island'
            WHEN 'SC' THEN 'South Carolina'
            WHEN 'SD' THEN 'South Dakota'
            WHEN 'TN' THEN 'Tennessee'
            WHEN 'TX' THEN 'Texas'
            WHEN 'UT' THEN 'Utah'
            WHEN 'VI' THEN 'Virgin Islands'
            WHEN 'VA' THEN 'Virginia'
            WHEN 'VT' THEN 'Vermont'
            WHEN 'WA' THEN 'Washington'
            WHEN 'WI' THEN 'Wisconsin'
            WHEN 'WV' THEN 'West Virginia'
            WHEN 'WY' THEN 'Wyoming'
            ELSE NULL
        END;
    END
$$;


CREATE FUNCTION fec_fitem_f57_update_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if tg_op = 'INSERT' then
        delete from fec_fitem_f57_queue_new where sub_id = new.sub_id;
        insert into fec_fitem_f57_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from fec_fitem_f57_queue_new where sub_id = new.sub_id;
        delete from fec_fitem_f57_queue_old where sub_id = old.sub_id;
        insert into fec_fitem_f57_queue_new values (new.*);
        insert into fec_fitem_f57_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from fec_fitem_f57_queue_old where sub_id = old.sub_id;
        insert into fec_fitem_f57_queue_old values (old.*);
        return old;
    end if;
end
$$;


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


CREATE FUNCTION first_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
        SELECT $1;
$_$;


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


CREATE FUNCTION format_start_date(start_date timestamp without time zone, end_date timestamp without time zone) RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when end_date is null then date_trunc('day', start_date)
            else start_date
        end;
    end
$$;


CREATE FUNCTION generate_24hr_text(rp_election_text text, ie_24hour_end date) RETURNS text
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


CREATE FUNCTION generate_48hr_text(rp_election_text text, ie_48hour_end date) RETURNS text
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


CREATE FUNCTION generate_election_description(trc_election_type_id text, office_sought text, election_states text[]) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case when trc_election_type_id='G' and election_states is not null then
            expand_office(office_sought) || ' ' || 'General ' || array_to_string(election_states, ', ')
        else expand_office_description(office_sought) || ' ' ||
            expand_election_type(trc_election_type_id) || ' ' || array_to_string(election_states, ', ')
        end;
    end
$$;


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


CREATE FUNCTION generate_election_description(trc_election_type_id text, office_sought text, contest text[], party text, trc_election_id numeric) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
        when array_length(contest, 1) >= 3 then array_to_string(
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
$$;


CREATE FUNCTION generate_election_description(election_type text, office_sought text, contest text[], party text, election_notes text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
        when array_length(contest, 1) >= 3 then array_to_string(
            array[
                party,
                office_sought,
                election_type,
                election_notes,
                '(for Multiple States)'
            ], ' ')
        when array_length(contest, 1) = 0 then array_to_string(
            array[
                party,
                office_sought,
                election_type,
                election_notes
            ], ' ')
        else array_to_string(
            array[
                array_to_string(contest, ', ') || ':',
                party,
                office_sought,
                election_type,
                election_notes
            ], ' ')
        end;
    end
$$;


CREATE FUNCTION generate_election_discription(trc_election_type_id text, office_sought text, election_states text[]) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case when trc_election_type_id='G' and election_states is not null then
            expand_office(office_sought) || ' ' || 'General ' || array_to_string(election_states, ', ')
        else expand_office_description(office_sought) || ' ' ||
            expand_election_type(trc_election_type_id) || ' ' || array_to_string(election_states, ', ')
        end;
    end
$$;


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


CREATE FUNCTION generate_election_summary(trc_election_type_id text, office_sought text, contest text[], party text, trc_election_id numeric) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
        when array_length(contest, 1) >= 3 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type_caucus_convention_clean(trc_election_type_id::text, trc_election_id::numeric),
                'Held Today',
                'States:',
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
$$;


CREATE FUNCTION generate_election_summary(election_type text, office_sought text, contest text[], party text, election_notes text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
        when array_length(contest, 1) >= 3 then array_to_string(
            array[
                party,
                office_sought,
                election_type,
                election_notes,
                'States:',
                array_to_string(contest, ', ')
            ], ' ')
        when array_length(contest, 1) = 0 then array_to_string(
            array[
                party,
                office_sought,
                election_type,
                election_notes
            ], ' ')
        else array_to_string(
            array[
                array_to_string(contest, ', ') || ':',
                party,
                office_sought,
                election_type,
                election_notes
            ], ' ')
        end;
    end
$$;


CREATE FUNCTION generate_election_title(trc_election_type_id text, office_sought text, state integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case state
            when state > 1 then expand_office_description(office_sought) || ' multi-state'
            else expand_office(office_sought) || ' ' || expand_election_type(trc_election_type_id) || ' ' ||
                election_state
        end;
    end
$$;


CREATE FUNCTION generate_election_title(trc_election_type_id text, office_sought text, state bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case when state > 1
            then expand_office_description(office_sought) || ' multi-state'
        else expand_office_description(office_sought) || ' ' || expand_election_type(trc_election_type_id) || ' ' ||
            election_state
        end;
    end
$$;


CREATE FUNCTION generate_election_title(trc_election_type_id text, office_sought text, state text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case state

            when array_length(state) > 1 then expand_office_description(office_sought) || ' multi-state'
            else expand_office(office_sought) || ' ' || expand_election_type(trc_election_type_id) || ' ' ||
                election_state
        end;
    end
$$;


CREATE FUNCTION generate_election_title(trc_election_type_id numeric, office_sought text, contest text[], party text) RETURNS text
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


CREATE FUNCTION generate_election_title(trc_election_type_id text, office_sought text, contest text[], party text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
        when array_length(contest, 1) > 1 then array_to_string(
            array[
                party,
                office_sought,
                expand_election_type(trc_election_type_id),
                'Multi-state'::text
            ], ' ')
        else array_to_string(
            array[
                array_to_string(contest, ', '),
                party,
                office_sought,
                expand_election_type(trc_election_type_id)
        ], ' ')
        end;
    end
$$;


CREATE FUNCTION generate_election_title(trc_election_type_id text, office_sought text, state bigint, election_states text[]) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case when state > 1 then
            'Election ' || expand_office_description(office_sought) || ' multi-state'
        else expand_office_description(office_sought) || ' ' || expand_election_type(trc_election_type_id) || ' ' ||
            array_to_string(election_states, ', ')
        end;
    end
$$;


CREATE FUNCTION generate_election_title(trc_election_type_id text, office_sought text, state bigint, election_state text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case when state > 1
            then expand_office_description(office_sought) || ' multi-state'
        else expand_office_description(office_sought) || ' ' || expand_election_type(trc_election_type_id) || ' ' ||
            election_state
        end;
    end
$$;


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


CREATE FUNCTION generate_electioneering_text(rp_election_text text, ec_end date) RETURNS text
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


CREATE FUNCTION generate_report_description(office_sought text, report_type text, rpt_tp_desc text, contest text[], election_notes text) RETURNS text
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
                    'Report (for Multiple States) is Due Today'
                ], ' ')
            when rpt_tp_desc is null and array_length(contest, 1) > 4 then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    election_notes,
                    'Report is Due Today'
                ], ' ')
            when rpt_tp_desc is null then
                array_to_string(
                array[
                    array_to_string(contest, ', ') || ':',
                    expand_office_description(office_sought),
                    report_type,
                    election_notes,
                    'Report is Due Today'
                ], ' ')
            when array_length(contest, 1) = 0 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report is Due Today'
                ], ' ')
            when array_length(contest, 1) > 4 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report (for Multiple States) is Due Today'
                ], ' ')
            else
                array_to_string(
                array[
                    array_to_string(contest, ', ') || ':',
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report is Due Today'
                ], ' ')
        end;
    end
$$;


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


CREATE FUNCTION generate_report_summary(office_sought text, report_type text, rpt_tp_desc text, report_contest text[], election_notes text) RETURNS text
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
                    'Report is Due Today'
                ], ' ')
            when rpt_tp_desc is null and array_length(report_contest, 1) < 3 and array_length(report_contest, 1) >= 1 then
                array_to_string(
                array[
                    array_to_string(report_contest, ', ') || ':',
                    expand_office_description(office_sought),
                    report_type,
                    election_notes,
                    'Report is Due Today'
                ], ' ')
            when rpt_tp_desc is null then
                array_to_string(
                array[
                    expand_office_description(office_sought),
                    report_type,
                    election_notes,
                    'Report is Due Today. States:',
                    array_to_string(report_contest, ', ')
                ], ' ')
            when array_length(report_contest, 1) = 1 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report is Due Today'
                ], ' ')
            when array_length(report_contest, 1) <= 3 then array_to_string(
                array[
                    array_to_string(report_contest, ', ') || ':',
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report is Due Today'
                ], ' ')
            when array_length(report_contest, 1) > 4 then array_to_string(
                array[
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report is Due Today. States:',
                    array_to_string(report_contest, ', ')
                ], ' ')
            else
                array_to_string(
                array[
                    array_to_string(report_contest, ', ') || ':',
                    expand_office_description(office_sought),
                    rpt_tp_desc,
                    election_notes,
                    'Report is Due Today'
                ], ' ')
        end;
    end
$$;


CREATE FUNCTION get_cycle(year numeric) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return year + year % 2;
end
$$;


CREATE FUNCTION get_report_category(report_type text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when report_type in ('M2', 'M3', 'M4', 'M5', 'M6', 'M7', 'M8', 'M9', 'M10', 'M11', 'M12') then 'M'
            when report_type in ('Q1', 'Q2', 'Q3') then 'Q'
            when report_type in ('12P', '12C', '12G', '12R', '12S', '30G', '30R', '30S', '30P', '60D', '30D') then 'E'
            else report_type
        end;
    end
$$;


CREATE FUNCTION get_transaction_year(transaction_date date, report_year numeric) RETURNS smallint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    transaction_year numeric = coalesce(extract(year from transaction_date), report_year);
begin
    return get_cycle(transaction_year);
end
$$;


CREATE FUNCTION get_transaction_year(transaction_date timestamp without time zone, report_year numeric) RETURNS smallint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    dah_date date = date(transaction_date);
begin
    return get_transaction_year(dah_date, report_year);
end
$$;


CREATE FUNCTION image_pdf_url(image_number text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return 'http://docquery.fec.gov/cgi-bin/fecimg/?' || image_number;
end
$$;


CREATE FUNCTION is_amended(most_recent_file_number integer, file_number integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return not is_most_recent(most_recent_file_number, file_number);
end
$$;


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


-- checks line numbers to determine if a transactions is from an individual
CREATE FUNCTION is_coded_individual(receipt_type text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return coalesce(receipt_type, '') in ('10', '15', '15E', '15J', '30', '30T', '31', '31T', '32', '10J', '11', '11J', '30J', '31J', '32T', '32J');
end
$$;


CREATE FUNCTION is_coded_individual_revised(receipt_type text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return coalesce(receipt_type, '') in ('10', '15', '15E', '15J', '18J');
end
$$;


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


CREATE FUNCTION is_earmark_revised(memo_code text, memo_text text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
  return (
      coalesce(memo_code, '') = 'X' or
      coalesce(memo_text, '') ~* 'earmark|earmk|ermk'
  );
end
$$;


--If the image number string is of length 18, and the 9th character is a 9, then it is electronic
--if the image number string is of length 11, and the 3rd character is a 9, then also electronic
--if imaage number is of length 11 and the 3rd and 4th characters are 02 and 03 then it is paper
--all other combinations are paper filers. (this encoding is outlined at this GitHub issue:
--https://github.com/18F/openFEC/issues/1882
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


-- This function gets used to sort unique, individual contributions for aggregates and filtering.
-- It checks line numbers first to determine the transaction type,
-- then it looks at contribution under 200 dollars removing earmarks.
-- Finally, it looks for mistakes where a donation with committee id is listed
-- as an individual when it shouldn't be.
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


CREATE FUNCTION is_individual_revised(amount numeric, receipt_type text, line_number text, memo_code text, memo_text text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return (
        is_coded_individual_revised(receipt_type) or
        is_inferred_individual_revised(amount, line_number, memo_code, memo_text)
    );
end
$$;


-- looking for individual donations by line number, or if it is under $200 looking at memo text and memo code in is_earmark()
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


CREATE FUNCTION is_inferred_individual_revised(amount numeric, line_number text, memo_code text, memo_text text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return (
        amount < 200 and
        coalesce(line_number, '') in ('11AI', '12', '17', '17A', '18') and
        not is_earmark_revised(memo_code, memo_text)
    );
end
$$;


CREATE FUNCTION is_most_recent(most_recent_file_number integer, file_number integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$

begin

    return most_recent_file_number = file_number;

end

$$;


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


-- There are a lot of data errors, this makes sure that we are not marking committees as individuals
-- when there is an obvious error. For example, marking the DNC as an individual, or putting your own
-- committee id in as the contributor id.
-- Some line numbers are expected to have committee ids so we white-list those.
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


-- unitemized contributions should not be included in the state breakdowns
CREATE FUNCTION is_unitemized(memo_text text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
  return (coalesce(memo_text, '') ~* 'UNITEM');
end
$$;


CREATE FUNCTION last_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
        SELECT $2;
$_$;


-- Retrieves the last day of the month for a given timestamp.
CREATE FUNCTION last_day_of_month(timestamp without time zone) RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $_$
    begin
        return date_trunc('month', $1) + (interval '1 month - 1 day');
    end
$_$;


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


CREATE FUNCTION name_reports(report_type text, rpt_tp_desc text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case
            when rpt_tp_desc is null then report_type || ' Report'
            else rpt_tp_desc || ' Report'
        end;
    end
$$;


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


CREATE FUNCTION ofec_f57_update_notice_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if tg_op = 'INSERT' then
        delete from ofec_f57_queue_new where sub_id = new.sub_id;
        insert into ofec_f57_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from ofec_f57_queue_new where sub_id = new.sub_id;
        delete from ofec_f57_queue_old where sub_id = old.sub_id;
        insert into ofec_f57_queue_new values (new.*);
        insert into ofec_f57_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from ofec_f57_queue_old where sub_id = old.sub_id;
        insert into ofec_f57_queue_old values (old.*);
        return old;
    end if;
end
$$;


CREATE FUNCTION ofec_nml_24_update_queues_from_notice() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin

    if tg_op = 'INSERT' then
        delete from ofec_nml_24_queue_new where sub_id = new.sub_id;
        insert into ofec_nml_24_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from ofec_nml_24_queue_new where sub_id = new.sub_id;
        delete from ofec_nml_24_queue_old where sub_id = old.sub_id;
        insert into ofec_nml_24_queue_new values (new.*);
        insert into ofec_nml_24_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from ofec_nml_24_queue_old where sub_id = old.sub_id;
        insert into ofec_nml_24_queue_old values (old.*);
        return old;
    end if;
end
$$;


CREATE FUNCTION ofec_sched_c_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.loan_source_name_text := to_tsvector(new.loan_src_nm);
  new.candidate_name_text := to_tsvector(new.cand_nm);
  return new;
end
$$;


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


CREATE FUNCTION ofec_sched_e_nml_update_queues_from_notice() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if tg_op = 'INSERT' then
        delete from ofec_nml_sched_e_queue_new where sub_id = new.sub_id;
        insert into ofec_nml_sched_e_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from ofec_nml_sched_e_queue_new where sub_id = new.sub_id;
        delete from ofec_nml_sched_e_queue_old where sub_id = old.sub_id;
        insert into ofec_nml_sched_e_queue_new values (new.*);
        insert into ofec_nml_sched_e_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from ofec_nml_sched_e_queue_old where sub_id = old.sub_id;
        insert into ofec_nml_sched_e_queue_old values (old.*);
        return old;
    end if;
end
$$;


CREATE FUNCTION ofec_sched_e_notice_update_from_f24() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    delete from ofec_sched_e
    where sub_id = any(select sub_id from ofec_nml_24_queue_old)
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
    from disclosure.nml_form_24 f24, ofec_nml_24_queue_new se
    where se.link_id = f24.sub_id and f24.delete_ind is null and se.delete_ind is null and se.amndt_ind::text <> 'D'::text;
end
$$;


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


CREATE FUNCTION ofec_sched_e_update_from_f57() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    delete from ofec_sched_e
    where sub_id = any(select sub_id from fec_fitem_f57_queue_old)
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
    from fec_fitem_f57_queue_new f57;
end
$$;


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


CREATE FUNCTION ofec_sched_e_update_notice_queues() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if tg_op = 'INSERT' then
        delete from ofec_nml_24_queue_new where sub_id = new.sub_id;
        insert into ofec_nml_24_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from ofec_nml_24_queue_new where sub_id = new.sub_id;
        delete from ofec_nml_24_queue_old where sub_id = old.sub_id;
        insert into ofec_nml_24_queue_new values (new.*);
        insert into ofec_nml_24_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from ofec_nml_24_queue_old where sub_id = old.sub_id;
        insert into ofec_nml_24_queue_old values (old.*);
        return old;
    end if;
end
$$;


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


CREATE FUNCTION ofec_sched_e_update_queues_from_notice() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


CREATE FUNCTION real_efile_sa7_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.contributor_name_text := to_tsvector(concat_ws(',', new.fname, new.name, new.mname));
  return new;
end
$$;


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
CREATE FUNCTION report_pdf_url_or_null(image_number text, report_year integer, committee_type text, form_type text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return case
        when report_year >= 2000 or
                (form_type in ('F3X', 'F3P') and report_year > 1993) or
                (form_type = 'F3' and committee_type = 'H' and report_year > 1996)
            then report_pdf_url(image_number)
        else null
    end;
end
$$;


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


CREATE FUNCTION rollback_real_time_filings(p_repid bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
 cur_del CURSOR FOR
    SELECT  table_name
       FROM information_schema.tables
       WHERE  table_schema='public'
        and table_catalog='fec'
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
    perform ofec_sched_e_update();
    delete from ofec_sched_e_queue_new;
    delete from ofec_sched_e_queue_old;
    perform ofec_sched_e_update_from_f57();
    delete from fec_fitem_f57_queue_new;
    delete from fec_fitem_f57_queue_old;
    perform ofec_sched_e_notice_update_from_f24();
    delete from ofec_nml_24_queue_old;
    delete from ofec_nml_24_queue_new where sub_id in (select sub_id from ofec_sched_e);
    perform ofec_sched_e_f57_notice_update();
    delete from ofec_f57_queue_old;
    delete from ofec_f57_queue_new where sub_id in (select sub_id from ofec_sched_e);
    delete from ofec_f57_queue_new where sub_id in (select new.sub_id from ofec_f57_queue_new new, disclosure.nml_form_5 f5
        where new.link_id = f5.sub_id and (f5.rpt_tp <> '48' or f5.rpt_tp <> '24'));
    delete from ofec_f57_queue_old where sub_id in (select new.sub_id from ofec_f57_queue_new new, disclosure.nml_form_5 f5
        where new.link_id = f5.sub_id and (f5.rpt_tp <> '48' or f5.rpt_tp <> '24'));
end
$$;


CREATE AGGREGATE first(anyelement) (
    SFUNC = first_agg,
    STYPE = anyelement
);


CREATE AGGREGATE last(anyelement) (
    SFUNC = last_agg,
    STYPE = anyelement
);


SET search_path = disclosure, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

CREATE TABLE cand_cmte_linkage (
    linkage_id numeric(12,0),
    cand_id character varying(9),
    cand_election_yr numeric(4,0),
    fec_election_yr numeric(4,0),
    cmte_id character varying(9),
    cmte_tp character varying(1),
    cmte_dsgn character varying(1),
    linkage_type character varying(1),
    user_id_entered numeric(12,0),
    date_entered date,
    user_id_changed numeric(12,0),
    date_changed date,
    cmte_count_cand_yr numeric(2,0),
    efile_paper_ind character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE cand_inactive (
    cand_id character varying(9),
    election_yr numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE cand_valid_fec_yr (
    cand_valid_yr_id numeric(12,0),
    cand_id character varying(9),
    fec_election_yr numeric(4,0),
    cand_election_yr numeric(4,0),
    cand_status character varying(1),
    cand_ici character varying(1),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    cand_pty_affiliation character varying(3),
    cand_name character varying(90),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_state character varying(2),
    cand_zip character varying(9),
    race_pk numeric,
    lst_updt_dt date,
    latest_receipt_dt date,
    user_id_entered numeric(6,0),
    date_entered date,
    user_id_changed numeric(6,0),
    date_changed date,
    ref_cand_pk numeric(19,0),
    ref_lst_updt_dt date,
    pg_date timestamp without time zone
);


CREATE TABLE cmte_valid_fec_yr (
    valid_fec_yr_id numeric(12,0),
    cmte_id character varying(9),
    fec_election_yr numeric(4,0),
    cmte_tp character varying(1),
    cmte_dsgn character varying(1),
    org_tp character varying(1),
    cmte_filing_freq character varying(1),
    cmte_pty_affiliation character varying(3),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    tres_nm character varying(90),
    connected_org_nm character varying(200),
    cmte_email character varying(90),
    cmte_url character varying(90),
    cmte_qual_start_dt date,
    cmte_term_request_dt date,
    cmte_term_dt date,
    latest_receipt_dt date,
    filed_cmte_tp_desc character varying(60),
    filed_cmte_dsgn_desc character varying(50),
    org_tp_desc character varying(40),
    cmte_filing_freq_desc character varying(30),
    cmte_pty_affiliation_desc character varying(50),
    user_id_entered numeric(6,0),
    date_entered date,
    user_id_changed numeric(6,0),
    date_changed date,
    ref_cmte_pk numeric(19,0),
    ref_lst_updt_dt date,
    pg_date timestamp without time zone
);


CREATE TABLE f_item_receipt_or_exp (
    sub_id numeric(19,0) NOT NULL,
    v_sum_link_id numeric(19,0) NOT NULL,
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    rpt_receipt_dt date,
    cmte_id character varying(9),
    image_num character varying(18),
    line_num character varying(12),
    form_tp_cd character varying(8),
    sched_tp_cd character varying(8),
    name character varying(200),
    first_name character varying(38),
    last_name character varying(38),
    street_1 character varying(34),
    street_2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip_code character varying(9),
    employer character varying(38),
    occupation character varying(38),
    transaction_dt numeric(8,0),
    transaction_amt numeric(14,2),
    transaction_pgi character varying(5),
    aggregate_amt numeric(14,2),
    transaction_tp character varying(3),
    purpose character varying(100),
    category character varying(3),
    category_desc character varying(40),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    other_id character varying(9),
    subordinate_cmte character varying(9),
    cand_id character varying(9),
    support_oppose_ind character varying(3),
    conduit_cmte_id character varying(9),
    national_cmte_nonfed_acct character varying(9),
    increased_limit character varying(1),
    unlimited_spending character varying(1),
    refund_or_excess character varying(1),
    communication_dt numeric(8,0),
    loan_dt numeric(8,0),
    loan_amt numeric(14,2),
    loan_interest_rate character varying(15),
    loan_due_dt character varying(15),
    loan_pymt_to_dt numeric(14,2),
    loan_outstanding_balance numeric(14,2),
    sched_a_line_num character varying(3),
    original_loan_date numeric(8,0),
    credit_amt_this_draw numeric(14,2),
    depository_acct_est_dt numeric(8,0),
    depository_acct_auth_dt numeric(8,0),
    debt_outstanding_balance_bop numeric(14,2),
    debt_outstanding_balance_cop numeric(14,2),
    debt_amt_incurred_per numeric(14,2),
    debt_pymt_per numeric(14,2),
    communication_cost numeric(14,2),
    communication_tp character varying(2),
    communication_class character varying(1),
    loan_flag character varying(1),
    account_nm character varying(90),
    event_nm character varying(90),
    event_tp character varying(2),
    event_tp_desc character varying(50),
    federal_share numeric(14,2),
    nonfederal_levin_share numeric(14,2),
    admin_voter_drive_ind character varying(1),
    ratio_cd character varying(1),
    fundraising_ind character varying(1),
    exempt_ind character varying(1),
    direct_candidate_support_ind character varying(1),
    admin_ind character varying(1),
    voter_drive_ind character varying(1),
    pub_comm_ref_pty_chk character varying(1),
    voter_reg_amt numeric(14,2),
    voter_id_amt numeric(14,2),
    gotv_amt numeric(14,2),
    gen_campaign_amt numeric(14,2),
    np_fixed_fed_pct numeric(7,4),
    hsp_min_fed_pct numeric(7,4),
    hsp_est_fed_dir_cand_supp_pct numeric(7,4),
    hsp_est_nonfed_cand_supp_pct numeric(7,4),
    hsp_actl_fed_dir_cand_supp_amt numeric(14,2),
    hsp_actl_nonfed_cand_supp_amt numeric(14,2),
    hsp_actl_fed_dir_cand_supp_pct numeric(7,4),
    ssf_fed_est_dir_cand_supp_pct numeric(7,4),
    ssf_nfed_est_dir_cand_supp_pct numeric(7,4),
    ssf_actl_fed_dir_cand_supp_amt numeric(14,2),
    ssf_actl_nonfed_cand_supp_amt numeric(14,2),
    ssf_actl_fed_dir_cand_supp_pct numeric(7,4),
    president_ind numeric(1,0),
    us_senate_ind numeric(1,0),
    us_congress_ind numeric(1,0),
    subttl_fed numeric(1,0),
    governor_ind numeric(1,0),
    other_st_offices_ind numeric(1,0),
    st_senate_ind numeric(1,0),
    st_rep_ind numeric(1,0),
    local_cand_ind numeric(1,0),
    extra_non_fed_point_ind numeric(1,0),
    subttl_non_fed numeric(2,0),
    ttl_fed_and_nonfed numeric(2,0),
    fed_alloctn numeric(5,0),
    st_loc_pres_only character varying(1),
    st_loc_pres_sen character varying(1),
    st_loc_sen_only character varying(1),
    st_loc_nonpres_nonsen character varying(1),
    flat_min_fed_pct character varying(1),
    fed_pct numeric(5,0),
    non_fed_pct numeric(5,0),
    admin_ratio_chk character varying(1),
    gen_voter_drive_chk character varying(1),
    last_update_dt timestamp without time zone,
    entity_tp character varying(3),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    dissem_dt numeric(8,0),
    pg_date timestamp without time zone DEFAULT now()
);


CREATE TABLE f_rpt_or_form_sub (
    sub_id numeric(19,0),
    cvg_start_dt numeric(8,0),
    cvg_end_dt numeric(8,0),
    receipt_dt numeric(8,0),
    election_yr numeric(4,0),
    cand_cmte_id character varying(9),
    form_tp character varying(8),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    amndt_ind character varying(1),
    request_tp character varying(3),
    to_from_ind character varying(1),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    pages numeric(8,0),
    ttl_receipts numeric(14,2),
    ttl_indt_contb numeric(14,2),
    net_dons numeric(14,2),
    ttl_disb numeric(14,2),
    ttl_indt_exp numeric(14,2),
    ttl_communication_cost numeric(14,2),
    coh_bop numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    hse_pers_funds_amt numeric(14,2),
    sen_pers_funds_amt numeric(14,2),
    oppos_pers_fund_amt numeric(14,2),
    cand_pk numeric(19,0),
    cmte_pk numeric(19,0),
    tres_nm character varying(38),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    lst_updt_dt timestamp without time zone,
    rpt_pgi character varying(5),
    pg_date timestamp without time zone
);


CREATE TABLE nml_form_1 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    submit_dt timestamp without time zone,
    cmte_nm_chg_flg character varying(1),
    cmte_addr_chg_flg character varying(1),
    filed_cmte_tp character varying(1),
    filed_cmte_tp_desc character varying(58),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_pty_tp character varying(3),
    cand_pty_tp_desc character varying(90),
    affiliated_cmte_id character varying(9),
    affiliated_cmte_nm character varying(200),
    affiliated_cmte_st1 character varying(34),
    affiliated_cmte_st2 character varying(34),
    affiliated_cmte_city character varying(30),
    affiliated_cmte_st character varying(2),
    affiliated_cmte_zip character varying(9),
    cmte_rltshp character varying(38),
    org_tp character varying(1),
    org_tp_desc character varying(90),
    cust_rec_nm character varying(90),
    cust_rec_st1 character varying(34),
    cust_rec_st2 character varying(34),
    cust_rec_city character varying(30),
    cust_rec_st character varying(2),
    cust_rec_zip character varying(9),
    cust_rec_title character varying(20),
    cust_rec_ph_num character varying(10),
    tres_nm character varying(90),
    tres_st1 character varying(34),
    tres_st2 character varying(34),
    tres_city character varying(30),
    tres_st character varying(2),
    tres_zip character varying(9),
    tres_title character varying(20),
    tres_ph_num character varying(10),
    designated_agent_nm character varying(90),
    designated_agent_st1 character varying(34),
    designated_agent_st2 character varying(34),
    designated_agent_city character varying(30),
    designated_agent_st character varying(2),
    designated_agent_zip character varying(9),
    designated_agent_title character varying(20),
    designated_agent_ph_num character varying(10),
    bank_depository_nm character varying(200),
    bank_depository_st1 character varying(34),
    bank_depository_st2 character varying(34),
    bank_depository_city character varying(30),
    bank_depository_st character varying(2),
    bank_depository_zip character varying(9),
    sec_bank_depository_nm character varying(200),
    sec_bank_depository_st1 character varying(34),
    sec_bank_depository_st2 character varying(34),
    sec_bank_depository_city character varying(30),
    sec_bank_depository_st character varying(2),
    sec_bank_depository_zip character varying(10),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    cmte_email character varying(90),
    cmte_web_url character varying(90),
    receipt_dt timestamp without time zone,
    filed_cmte_dsgn character varying(1),
    filed_cmte_dsgn_desc character varying(90),
    cmte_dsgn_desc character varying(20),
    cmte_class_desc character varying(20),
    cmte_tp_desc character varying(23),
    cmte_subtp_desc character varying(35),
    jntfndrsg_cmte_flg character varying(1),
    filing_freq character varying(1),
    filing_freq_desc character varying(27),
    qual_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    cmte_fax character varying(12),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    leadership_pac character varying(1),
    affiliated_relationship_cd character varying(3),
    efiling_cmte_tp character varying(1),
    cmte_email_chg_flg character varying(1),
    cmte_url_chg_flg character varying(1),
    lobbyist_registrant_pac character varying(1),
    affiliated_cand_id character varying(9),
    affiliated_cand_l_nm character varying(30),
    affiliated_cand_f_nm character varying(20),
    affiliated_cand_m_nm character varying(20),
    affiliated_cand_prefix character varying(10),
    affiliated_cand_suffix character varying(10),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cust_rec_l_nm character varying(30),
    cust_rec_f_nm character varying(20),
    cust_rec_m_nm character varying(20),
    cust_rec_prefix character varying(10),
    cust_rec_suffix character varying(10),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    designated_agent_l_nm character varying(30),
    designated_agent_f_nm character varying(20),
    designated_agent_m_nm character varying(20),
    designated_agent_prefix character varying(10),
    designated_agent_suffix character varying(10),
    f3l_filing_freq character varying(1),
    tres_nm_rlp_flg character varying(1),
    cand_pty_affiliation_rlp_flg character varying(1),
    filed_cmte_dsgn_rlp_flg character varying(1),
    filing_freq_rlp_flg character varying(1),
    org_tp_rlp_flg character varying(1),
    cmte_city_rlp_flg character varying(1),
    cmte_zip_rlp_flg character varying(1),
    cmte_st_rlp_flg character varying(1),
    cmte_st1_st2_rlp_flg character varying(1),
    cmte_nm_rlp_flg character varying(1),
    filed_cmte_tp_rlp_flg character varying(1),
    cmte_email_rlp_flg character varying(1),
    cmte_web_url_rlp_flg character varying(1),
    sign_l_nm character varying(30),
    sign_f_nm character varying(20),
    sign_m_nm character varying(20),
    sign_prefix character varying(10),
    sign_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


CREATE TABLE nml_form_1z (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    submit_dt timestamp without time zone,
    cmte_nm_chg_flg character varying(1),
    cmte_addr_chg_flg character varying(1),
    filed_cmte_tp character varying(1),
    filed_cmte_tp_desc character varying(58),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_pty_tp character varying(3),
    cand_pty_tp_desc character varying(90),
    affiliated_cmte_id character varying(9),
    affiliated_cmte_nm character varying(200),
    affiliated_cmte_st1 character varying(34),
    affiliated_cmte_st2 character varying(34),
    affiliated_cmte_city character varying(30),
    affiliated_cmte_st character varying(2),
    affiliated_cmte_zip character varying(9),
    cmte_rltshp character varying(38),
    org_tp character varying(1),
    org_tp_desc character varying(90),
    cust_rec_nm character varying(90),
    cust_rec_st1 character varying(34),
    cust_rec_st2 character varying(34),
    cust_rec_city character varying(30),
    cust_rec_st character varying(2),
    cust_rec_zip character varying(9),
    cust_rec_title character varying(20),
    cust_rec_ph_num character varying(10),
    tres_nm character varying(90),
    tres_st1 character varying(34),
    tres_st2 character varying(34),
    tres_city character varying(30),
    tres_st character varying(2),
    tres_zip character varying(9),
    tres_title character varying(20),
    tres_ph_num character varying(10),
    designated_agent_nm character varying(90),
    designated_agent_st1 character varying(34),
    designated_agent_st2 character varying(34),
    designated_agent_city character varying(30),
    designated_agent_st character varying(2),
    designated_agent_zip character varying(9),
    designated_agent_title character varying(20),
    designated_agent_ph_num character varying(10),
    bank_depository_nm character varying(200),
    bank_depository_st1 character varying(34),
    bank_depository_st2 character varying(34),
    bank_depository_city character varying(30),
    bank_depository_st character varying(2),
    bank_depository_zip character varying(9),
    sec_bank_depository_nm character varying(200),
    sec_bank_depository_st1 character varying(34),
    sec_bank_depository_st2 character varying(34),
    sec_bank_depository_city character varying(30),
    sec_bank_depository_st character varying(2),
    sec_bank_depository_zip character varying(10),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    cmte_email character varying(90),
    cmte_web_url character varying(90),
    receipt_dt timestamp without time zone,
    filed_cmte_dsgn character varying(1),
    filed_cmte_dsgn_desc character varying(90),
    cmte_dsgn_desc character varying(20),
    cmte_class_desc character varying(20),
    cmte_tp_desc character varying(23),
    cmte_subtp_desc character varying(35),
    jntfndrsg_cmte_flg character varying(1),
    filing_freq character varying(1),
    filing_freq_desc character varying(27),
    qual_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    cmte_fax character varying(12),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    leadership_pac character varying(1),
    affiliated_relationship_cd character varying(3),
    efiling_cmte_tp character varying(1),
    cmte_email_chg_flg character varying(1),
    cmte_url_chg_flg character varying(1),
    lobbyist_registrant_pac character varying(1),
    affiliated_cand_id character varying(9),
    affiliated_cand_l_nm character varying(30),
    affiliated_cand_f_nm character varying(20),
    affiliated_cand_m_nm character varying(20),
    affiliated_cand_prefix character varying(10),
    affiliated_cand_suffix character varying(10),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cust_rec_l_nm character varying(30),
    cust_rec_f_nm character varying(20),
    cust_rec_m_nm character varying(20),
    cust_rec_prefix character varying(10),
    cust_rec_suffix character varying(10),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    designated_agent_l_nm character varying(30),
    designated_agent_f_nm character varying(20),
    designated_agent_m_nm character varying(20),
    designated_agent_prefix character varying(10),
    designated_agent_suffix character varying(10),
    f3l_filing_freq character varying(1),
    tres_nm_rlp_flg character varying(1),
    cand_pty_affiliation_rlp_flg character varying(1),
    filed_cmte_dsgn_rlp_flg character varying(1),
    filing_freq_rlp_flg character varying(1),
    org_tp_rlp_flg character varying(1),
    cmte_city_rlp_flg character varying(1),
    cmte_zip_rlp_flg character varying(1),
    cmte_st_rlp_flg character varying(1),
    cmte_st1_st2_rlp_flg character varying(1),
    cmte_nm_rlp_flg character varying(1),
    filed_cmte_tp_rlp_flg character varying(1),
    cmte_email_rlp_flg character varying(1),
    cmte_web_url_rlp_flg character varying(1),
    sign_l_nm character varying(30),
    sign_f_nm character varying(20),
    sign_m_nm character varying(20),
    sign_prefix character varying(10),
    sign_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


CREATE VIEW nml_form_1_1z_view AS
 SELECT a.sub_id,
    a.begin_image_num,
    a.end_image_num,
    a.form_tp,
    a.form_tp_desc,
    a.amndt_ind,
    a.amndt_ind_desc,
    a.cmte_id,
    a.cmte_nm,
    a.cmte_st1,
    a.cmte_st2,
    a.cmte_city,
    a.cmte_st,
    a.cmte_zip,
    a.submit_dt,
    a.cmte_nm_chg_flg,
    a.cmte_addr_chg_flg,
    a.filed_cmte_tp,
    a.filed_cmte_tp_desc,
    a.cand_id,
    a.cand_nm,
    a.cand_nm_first,
    a.cand_nm_last,
    a.cand_office,
    a.cand_office_desc,
    a.cand_office_st,
    a.cand_office_st_desc,
    a.cand_office_district,
    a.cand_pty_affiliation,
    a.cand_pty_affiliation_desc,
    a.cand_pty_tp,
    a.cand_pty_tp_desc,
    a.affiliated_cmte_id,
    a.affiliated_cmte_nm,
    a.affiliated_cmte_st1,
    a.affiliated_cmte_st2,
    a.affiliated_cmte_city,
    a.affiliated_cmte_st,
    a.affiliated_cmte_zip,
    a.cmte_rltshp,
    a.org_tp,
    a.org_tp_desc,
    a.cust_rec_nm,
    a.cust_rec_st1,
    a.cust_rec_st2,
    a.cust_rec_city,
    a.cust_rec_st,
    a.cust_rec_zip,
    a.cust_rec_title,
    a.cust_rec_ph_num,
    a.tres_nm,
    a.tres_st1,
    a.tres_st2,
    a.tres_city,
    a.tres_st,
    a.tres_zip,
    a.tres_title,
    a.tres_ph_num,
    a.designated_agent_nm,
    a.designated_agent_st1,
    a.designated_agent_st2,
    a.designated_agent_city,
    a.designated_agent_st,
    a.designated_agent_zip,
    a.designated_agent_title,
    a.designated_agent_ph_num,
    a.bank_depository_nm,
    a.bank_depository_st1,
    a.bank_depository_st2,
    a.bank_depository_city,
    a.bank_depository_st,
    a.bank_depository_zip,
    a.sec_bank_depository_nm,
    a.sec_bank_depository_st1,
    a.sec_bank_depository_st2,
    a.sec_bank_depository_city,
    a.sec_bank_depository_st,
    a.sec_bank_depository_zip,
    a.tres_sign_nm,
    a.tres_sign_dt,
    a.cmte_email,
    a.cmte_web_url,
    a.receipt_dt,
    a.filed_cmte_dsgn,
    a.filed_cmte_dsgn_desc,
    a.cmte_dsgn_desc,
    a.cmte_class_desc,
    a.cmte_tp_desc,
    a.cmte_subtp_desc,
    a.jntfndrsg_cmte_flg,
    a.filing_freq,
    a.filing_freq_desc,
    a.qual_dt,
    a.image_tp,
    a.load_status,
    a.last_update_dt,
    a.delete_ind,
    a.leadership_pac,
    a.lobbyist_registrant_pac,
    a.f3l_filing_freq
   FROM nml_form_1 a
UNION
 SELECT z.sub_id,
    z.begin_image_num,
    z.end_image_num,
    z.form_tp,
    z.form_tp_desc,
    z.amndt_ind,
    z.amndt_ind_desc,
    z.cmte_id,
    z.cmte_nm,
    z.cmte_st1,
    z.cmte_st2,
    z.cmte_city,
    z.cmte_st,
    z.cmte_zip,
    z.submit_dt,
    z.cmte_nm_chg_flg,
    z.cmte_addr_chg_flg,
    z.filed_cmte_tp,
    z.filed_cmte_tp_desc,
    z.cand_id,
    z.cand_nm,
    z.cand_nm_first,
    z.cand_nm_last,
    z.cand_office,
    z.cand_office_desc,
    z.cand_office_st,
    z.cand_office_st_desc,
    z.cand_office_district,
    z.cand_pty_affiliation,
    z.cand_pty_affiliation_desc,
    z.cand_pty_tp,
    z.cand_pty_tp_desc,
    z.affiliated_cmte_id,
    z.affiliated_cmte_nm,
    z.affiliated_cmte_st1,
    z.affiliated_cmte_st2,
    z.affiliated_cmte_city,
    z.affiliated_cmte_st,
    z.affiliated_cmte_zip,
    z.cmte_rltshp,
    z.org_tp,
    z.org_tp_desc,
    z.cust_rec_nm,
    z.cust_rec_st1,
    z.cust_rec_st2,
    z.cust_rec_city,
    z.cust_rec_st,
    z.cust_rec_zip,
    z.cust_rec_title,
    z.cust_rec_ph_num,
    z.tres_nm,
    z.tres_st1,
    z.tres_st2,
    z.tres_city,
    z.tres_st,
    z.tres_zip,
    z.tres_title,
    z.tres_ph_num,
    z.designated_agent_nm,
    z.designated_agent_st1,
    z.designated_agent_st2,
    z.designated_agent_city,
    z.designated_agent_st,
    z.designated_agent_zip,
    z.designated_agent_title,
    z.designated_agent_ph_num,
    z.bank_depository_nm,
    z.bank_depository_st1,
    z.bank_depository_st2,
    z.bank_depository_city,
    z.bank_depository_st,
    z.bank_depository_zip,
    z.sec_bank_depository_nm,
    z.sec_bank_depository_st1,
    z.sec_bank_depository_st2,
    z.sec_bank_depository_city,
    z.sec_bank_depository_st,
    z.sec_bank_depository_zip,
    z.tres_sign_nm,
    z.tres_sign_dt,
    z.cmte_email,
    z.cmte_web_url,
    z.receipt_dt,
    z.filed_cmte_dsgn,
    z.filed_cmte_dsgn_desc,
    z.cmte_dsgn_desc,
    z.cmte_class_desc,
    z.cmte_tp_desc,
    z.cmte_subtp_desc,
    z.jntfndrsg_cmte_flg,
    z.filing_freq,
    z.filing_freq_desc,
    z.qual_dt,
    z.image_tp,
    z.load_status,
    z.last_update_dt,
    z.delete_ind,
    z.leadership_pac,
    z.lobbyist_registrant_pac,
    z.f3l_filing_freq
   FROM nml_form_1z z;


CREATE TABLE nml_form_2 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_st character varying(2),
    cand_zip character varying(9),
    addr_chg_flg character varying(1),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    election_yr numeric(4,0),
    pcc_cmte_id character varying(9),
    pcc_cmte_nm character varying(200),
    pcc_cmte_st1 character varying(34),
    pcc_cmte_st2 character varying(34),
    pcc_cmte_city character varying(30),
    pcc_cmte_st character varying(2),
    pcc_cmte_zip character varying(9),
    addl_auth_cmte_id character varying(9),
    addl_auth_cmte_nm character varying(200),
    addl_auth_cmte_st1 character varying(34),
    addl_auth_cmte_st2 character varying(34),
    addl_auth_cmte_city character varying(30),
    addl_auth_cmte_st character varying(2),
    addl_auth_cmte_zip character varying(9),
    cand_sign_nm character varying(90),
    cand_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    party_cd character varying(1),
    party_cd_desc character varying(33),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cand_ici character varying(1),
    cand_ici_desc character varying(15),
    cand_status character varying(1),
    cand_status_desc character varying(40),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    prim_pers_funds_decl numeric(14,2),
    gen_pers_funds_decl numeric(14,2),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_sign_l_nm character varying(30),
    cand_sign_f_nm character varying(20),
    cand_sign_m_nm character varying(20),
    cand_sign_prefix character varying(10),
    cand_sign_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


CREATE TABLE nml_form_24 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    amndt_ind character varying(1),
    orig_amndt_dt timestamp without time zone,
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


CREATE TABLE nml_form_2z (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_st character varying(2),
    cand_zip character varying(9),
    addr_chg_flg character varying(1),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    election_yr numeric(4,0),
    pcc_cmte_id character varying(9),
    pcc_cmte_nm character varying(200),
    pcc_cmte_st1 character varying(34),
    pcc_cmte_st2 character varying(34),
    pcc_cmte_city character varying(30),
    pcc_cmte_st character varying(2),
    pcc_cmte_zip character varying(9),
    addl_auth_cmte_id character varying(9),
    addl_auth_cmte_nm character varying(200),
    addl_auth_cmte_st1 character varying(34),
    addl_auth_cmte_st2 character varying(34),
    addl_auth_cmte_city character varying(30),
    addl_auth_cmte_st character varying(2),
    addl_auth_cmte_zip character varying(9),
    cand_sign_nm character varying(90),
    cand_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    party_cd character varying(1),
    party_cd_desc character varying(33),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cand_ici character varying(1),
    cand_ici_desc character varying(15),
    cand_status character varying(1),
    cand_status_desc character varying(40),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_sign_l_nm character varying(30),
    cand_sign_f_nm character varying(20),
    cand_sign_m_nm character varying(20),
    cand_sign_prefix character varying(10),
    cand_sign_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


CREATE VIEW nml_form_2_2z_view AS
 SELECT a.sub_id,
    a.begin_image_num,
    a.end_image_num,
    a.form_tp,
    a.form_tp_desc,
    a.cand_id,
    a.cand_nm,
    a.cand_nm_first,
    a.cand_nm_last,
    a.cand_st1,
    a.cand_st2,
    a.cand_city,
    a.cand_st,
    a.cand_zip,
    a.addr_chg_flg,
    a.cand_pty_affiliation,
    a.cand_pty_affiliation_desc,
    a.cand_office,
    a.cand_office_desc,
    a.cand_office_st,
    a.cand_office_st_desc,
    a.cand_office_district,
    a.election_yr,
    a.pcc_cmte_id,
    a.pcc_cmte_nm,
    a.pcc_cmte_st1,
    a.pcc_cmte_st2,
    a.pcc_cmte_city,
    a.pcc_cmte_st,
    a.pcc_cmte_zip,
    a.addl_auth_cmte_id,
    a.addl_auth_cmte_nm,
    a.addl_auth_cmte_st1,
    a.addl_auth_cmte_st2,
    a.addl_auth_cmte_city,
    a.addl_auth_cmte_st,
    a.addl_auth_cmte_zip,
    a.cand_sign_nm,
    a.cand_sign_dt,
    a.receipt_dt,
    a.party_cd,
    a.party_cd_desc,
    COALESCE(a.amndt_ind, 'A'::character varying) AS amndt_ind,
    a.amndt_ind_desc,
    a.cand_ici,
    a.cand_ici_desc,
    a.cand_status,
    a.cand_status_desc,
    a.image_tp,
    a.load_status,
    a.last_update_dt,
    a.delete_ind
   FROM nml_form_2 a
  WHERE (a.delete_ind IS NULL)
UNION
 SELECT a.sub_id,
    a.begin_image_num,
    a.end_image_num,
    a.form_tp,
    a.form_tp_desc,
    a.cand_id,
    a.cand_nm,
    a.cand_nm_first,
    a.cand_nm_last,
    a.cand_st1,
    a.cand_st2,
    a.cand_city,
    a.cand_st,
    a.cand_zip,
    a.addr_chg_flg,
    a.cand_pty_affiliation,
    a.cand_pty_affiliation_desc,
    a.cand_office,
    a.cand_office_desc,
    a.cand_office_st,
    a.cand_office_st_desc,
    a.cand_office_district,
    a.election_yr,
    a.pcc_cmte_id,
    a.pcc_cmte_nm,
    a.pcc_cmte_st1,
    a.pcc_cmte_st2,
    a.pcc_cmte_city,
    a.pcc_cmte_st,
    a.pcc_cmte_zip,
    a.addl_auth_cmte_id,
    a.addl_auth_cmte_nm,
    a.addl_auth_cmte_st1,
    a.addl_auth_cmte_st2,
    a.addl_auth_cmte_city,
    a.addl_auth_cmte_st,
    a.addl_auth_cmte_zip,
    a.cand_sign_nm,
    a.cand_sign_dt,
    a.receipt_dt,
    a.party_cd,
    a.party_cd_desc,
    COALESCE(a.amndt_ind, 'A'::character varying) AS amndt_ind,
    a.amndt_ind_desc,
    a.cand_ici,
    a.cand_ici_desc,
    a.cand_status,
    a.cand_status_desc,
    a.image_tp,
    a.load_status,
    a.last_update_dt,
    a.delete_ind
   FROM nml_form_2z a
  WHERE (a.delete_ind IS NULL)
  ORDER BY 6, 51;


CREATE TABLE nml_form_3 (
    sub_id numeric(19,0),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    cmte_election_st character varying(2),
    cmte_election_st_desc character varying(20),
    cmte_election_district character varying(2),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(5),
    rpt_pgi_desc character varying(10),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    primary_election character varying(1),
    general_election character varying(1),
    special_election character varying(1),
    runoff_election character varying(1),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    ttl_contb_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    net_contb_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    net_op_exp_per numeric(14,2),
    coh_cop_i numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    ttl_indv_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_column_ttl_per numeric(14,2),
    tranf_from_other_auth_cmte_per numeric(14,2),
    loans_made_by_cand_per numeric(14,2),
    all_other_loans_per numeric(14,2),
    ttl_loans_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    ttl_receipts_per_i numeric(14,2),
    op_exp_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    loan_repymts_cand_loans_per numeric(14,2),
    loan_repymts_other_loans_per numeric(14,2),
    ttl_loan_repymts_per numeric(14,2),
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    ttl_contb_ref_col_ttl_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per_i numeric(14,2),
    coh_bop numeric(14,2),
    ttl_receipts_ii numeric(14,2),
    subttl_per numeric(14,2),
    ttl_disb_per_ii numeric(14,2),
    coh_cop_ii numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd numeric(14,2),
    net_contb_ytd numeric(14,2),
    ttl_op_exp_ytd numeric(14,2),
    ttl_offsets_to_op_exp_ytd numeric(14,2),
    net_op_exp_ytd numeric(14,2),
    ttl_indv_item_contb_ytd numeric(14,2),
    ttl_indv_unitem_contb_ytd numeric(14,2),
    ttl_indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd numeric(14,2),
    other_pol_cmte_contb_ytd numeric(14,2),
    cand_contb_ytd numeric(14,2),
    ttl_contb_col_ttl_ytd numeric(14,2),
    tranf_from_other_auth_cmte_ytd numeric(14,2),
    loans_made_by_cand_ytd numeric(14,2),
    all_other_loans_ytd numeric(14,2),
    ttl_loans_ytd numeric(14,2),
    offsets_to_op_exp_ytd numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    op_exp_ytd numeric(14,2),
    tranf_to_other_auth_cmte_ytd numeric(14,2),
    loan_repymts_cand_loans_ytd numeric(14,2),
    loan_repymts_other_loans_ytd numeric(14,2),
    ttl_loan_repymts_ytd numeric(14,2),
    ref_indv_contb_ytd numeric(14,2),
    ref_pol_pty_cmte_contb_ytd numeric(14,2),
    ref_other_pol_cmte_contb_ytd numeric(14,2),
    ref_ttl_contb_col_ttl_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    grs_rcpt_auth_cmte_prim numeric(14,2),
    agr_amt_contrib_pers_fund_prim numeric(14,2),
    grs_rcpt_min_pers_contrib_prim numeric(14,2),
    grs_rcpt_auth_cmte_gen numeric(14,2),
    agr_amt_pers_contrib_gen numeric(14,2),
    grs_rcpt_min_pers_contrib_gen numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    f3z1_rpt_tp character varying(3),
    f3z1_rpt_tp_desc character varying(30),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone
);


CREATE TABLE nml_form_3p (
    cmte_id character varying(9),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    amndt_ind character varying(1),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0)
);


CREATE TABLE nml_form_3x (
    sub_id numeric(19,0),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    qual_cmte_flg character varying(1),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(5),
    rpt_pgi_desc character varying(10),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    ttl_indv_contb numeric(14,2),
    pol_pty_cmte_contb_per_i numeric(14,2),
    other_pol_cmte_contb_per_i numeric(14,2),
    ttl_contb_col_ttl_per numeric(14,2),
    tranf_from_affiliated_pty_per numeric(14,2),
    all_loans_received_per numeric(14,2),
    loan_repymts_received_per numeric(14,2),
    offsets_to_op_exp_per_i numeric(14,2),
    fed_cand_contb_ref_per numeric(14,2),
    other_fed_receipts_per numeric(14,2),
    tranf_from_nonfed_acct_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    ttl_fed_receipts_per numeric(14,2),
    shared_fed_op_exp_per numeric(14,2),
    shared_nonfed_op_exp_per numeric(14,2),
    other_fed_op_exp_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    tranf_to_affliliated_cmte_per numeric(14,2),
    fed_cand_cmte_contb_per numeric(14,2),
    indt_exp_per numeric(14,2),
    coord_exp_by_pty_cmte_per numeric(14,2),
    loan_repymts_made_per numeric(14,2),
    loans_made_per numeric(14,2),
    indv_contb_ref_per numeric(14,2),
    pol_pty_cmte_contb_per_ii numeric(14,2),
    other_pol_cmte_contb_per_ii numeric(14,2),
    ttl_contb_ref_per_i numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    ttl_fed_disb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    ttl_contb_ref_per_ii numeric(14,2),
    net_contb_per numeric(14,2),
    ttl_fed_op_exp_per numeric(14,2),
    offsets_to_op_exp_per_ii numeric(14,2),
    net_op_exp_per numeric(14,2),
    coh_begin_calendar_yr numeric(14,2),
    calendar_yr numeric(4,0),
    ttl_receipts_sum_page_ytd numeric(14,2),
    subttl_sum_ytd numeric(14,2),
    ttl_disb_sum_page_ytd numeric(14,2),
    coh_coy numeric(14,2),
    indv_item_contb_ytd numeric(14,2),
    indv_unitem_contb_ytd numeric(14,2),
    ttl_indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd_i numeric(14,2),
    other_pol_cmte_contb_ytd_i numeric(14,2),
    ttl_contb_col_ttl_ytd numeric(14,2),
    tranf_from_affiliated_pty_ytd numeric(14,2),
    all_loans_received_ytd numeric(14,2),
    loan_repymts_received_ytd numeric(14,2),
    offsets_to_op_exp_ytd_i numeric(14,2),
    fed_cand_cmte_contb_ytd numeric(14,2),
    other_fed_receipts_ytd numeric(14,2),
    tranf_from_nonfed_acct_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    ttl_fed_receipts_ytd numeric(14,2),
    shared_fed_op_exp_ytd numeric(14,2),
    shared_nonfed_op_exp_ytd numeric(14,2),
    other_fed_op_exp_ytd numeric(14,2),
    ttl_op_exp_ytd numeric(14,2),
    tranf_to_affilitated_cmte_ytd numeric(14,2),
    fed_cand_cmte_contb_ref_ytd numeric(14,2),
    indt_exp_ytd numeric(14,2),
    coord_exp_by_pty_cmte_ytd numeric(14,2),
    loan_repymts_made_ytd numeric(14,2),
    loans_made_ytd numeric(14,2),
    indv_contb_ref_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd_ii numeric(14,2),
    other_pol_cmte_contb_ytd_ii numeric(14,2),
    ttl_contb_ref_ytd_i numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    ttl_fed_disb_ytd numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd_ii numeric(14,2),
    net_contb_ytd numeric(14,2),
    ttl_fed_op_exp_ytd numeric(14,2),
    offsets_to_op_exp_ytd_ii numeric(14,2),
    net_op_exp_ytd numeric(14,2),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    multicand_flg character varying(1),
    receipt_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    tranf_from_nonfed_levin_per numeric(14,2),
    ttl_nonfed_tranf_per numeric(14,2),
    shared_fed_actvy_fed_shr_per numeric(14,2),
    shared_fed_actvy_nonfed_per numeric(14,2),
    non_alloc_fed_elect_actvy_per numeric(14,2),
    ttl_fed_elect_actvy_per numeric(14,2),
    tranf_from_nonfed_levin_ytd numeric(14,2),
    ttl_nonfed_tranf_ytd numeric(14,2),
    shared_fed_actvy_fed_shr_ytd numeric(14,2),
    shared_fed_actvy_nonfed_ytd numeric(14,2),
    non_alloc_fed_elect_actvy_ytd numeric(14,2),
    ttl_fed_elect_actvy_ytd numeric(14,2),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone
);


CREATE TABLE nml_form_5 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    indv_org_id character varying(9),
    indv_org_nm character varying(200),
    indv_org_st1 character varying(34),
    indv_org_st2 character varying(34),
    indv_org_city character varying(30),
    indv_org_st character varying(2),
    indv_org_zip character varying(9),
    addr_chg_flg character varying(1),
    qual_nonprofit_corp_ind character varying(1),
    indv_org_employer character varying(38),
    indv_org_occupation character varying(38),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(5),
    rpt_pgi_desc character varying(10),
    election_tp character varying(2),
    election_tp_desc character varying(50),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    ttl_indt_contb numeric(14,2),
    ttl_indt_exp numeric(14,2),
    filer_nm character varying(90),
    filer_sign_nm character varying(90),
    filer_sign_dt timestamp without time zone,
    notary_sign_dt timestamp without time zone,
    notary_commission_exprtn_dt timestamp without time zone,
    notary_nm character varying(38),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    entity_tp character varying(3),
    indv_l_nm character varying(30),
    indv_f_nm character varying(20),
    indv_m_nm character varying(20),
    indv_prefix character varying(10),
    indv_suffix character varying(10),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    orig_amndt_dt timestamp without time zone,
    pg_date timestamp without time zone DEFAULT now()
);


CREATE TABLE nml_form_57 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    filer_cmte_id character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_purpose character varying(100),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(20),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_state_desc character varying(20),
    s_o_cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    receipt_dt timestamp without time zone,
    tran_id character varying(32),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    catg_cd character varying(3),
    exp_tp character varying(3),
    cal_ytd_ofc_sought numeric(14,2),
    catg_cd_desc character varying(40),
    exp_tp_desc character varying(90),
    file_num numeric(7,0),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    orig_sub_id numeric(19,0),
    pye_l_nm character varying(30),
    pye_f_nm character varying(20),
    pye_m_nm character varying(20),
    pye_prefix character varying(10),
    pye_suffix character varying(10),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


CREATE TABLE nml_form_7 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    org_id character varying(9),
    org_nm character varying(200),
    org_st1 character varying(34),
    org_st2 character varying(34),
    org_city character varying(30),
    org_st character varying(2),
    org_zip character varying(9),
    org_tp character varying(1),
    org_tp_desc character varying(90),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(90),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    ttl_communication_cost numeric(14,2),
    filer_sign_nm character varying(90),
    filer_sign_dt timestamp without time zone,
    filer_title character varying(20),
    receipt_dt timestamp without time zone,
    rpt_pgi character varying(1),
    rpt_pgi_desc character varying(10),
    amdnt_ind character varying(1),
    amndt_ind_desc character varying(15),
    rpt_yr numeric(4,0),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


CREATE TABLE nml_form_9 (
    form_tp character varying(8),
    cmte_id character varying(9),
    ind_org_corp_nm character varying(200),
    ind_org_corp_st1 character varying(34),
    ind_org_corp_st2 character varying(34),
    ind_org_corp_city character varying(30),
    ind_org_corp_st character varying(2),
    ind_org_corp_zip character varying(9),
    addr_chg_flg character varying(1),
    ind_org_corp_emp character varying(38),
    ind_org_corp_occup character varying(38),
    beg_cvg_dt timestamp without time zone,
    end_cvg_dt timestamp without time zone,
    pub_distrib_dt timestamp without time zone,
    qual_nonprofit_flg character varying(18),
    segr_bank_acct_flg character varying(1),
    ind_custod_nm character varying(90),
    ind_custod_st1 character varying(34),
    ind_custod_st2 character varying(34),
    ind_custod_city character varying(30),
    ind_custod_st character varying(2),
    ind_custod_zip character varying(9),
    ind_custod_emp character varying(38),
    ind_custod_occup character varying(38),
    ttl_dons_this_stmt numeric(14,2),
    ttl_disb_this_stmt numeric(14,2),
    filer_sign_nm character varying(90),
    filer_sign_dt timestamp without time zone,
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp_desc character varying(90),
    ind_org_corp_st_desc character varying(20),
    addr_chg_flg_desc character varying(20),
    qual_nonprofit_flg_desc character varying(40),
    segr_bank_acct_flg_desc character varying(30),
    ind_custod_st_desc character varying(20),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    amndt_ind character varying(1),
    comm_title character varying(40),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    rpt_tp character varying(3),
    entity_tp character varying(3),
    filer_cd character varying(3),
    filer_cd_desc character varying(20),
    indv_l_nm character varying(30),
    indv_f_nm character varying(20),
    indv_m_nm character varying(20),
    indv_prefix character varying(10),
    indv_suffix character varying(10),
    cust_l_nm character varying(30),
    cust_f_nm character varying(20),
    cust_m_nm character varying(20),
    cust_prefix character varying(10),
    cust_suffix character varying(10),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


CREATE TABLE nml_form_rfai (
    sub_id numeric(19,0),
    id character varying(9),
    request_tp character varying(3),
    request_tp_desc character varying(65),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rfai_dt timestamp without time zone,
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    analyst_id character varying(3),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    chg_del_id numeric(19,0),
    file_num numeric(7,0),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    rpt_yr numeric(4,0),
    response_due_dt timestamp without time zone,
    response_dt timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE nml_sched_a (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    contbr_id character varying(9),
    contbr_nm character varying(200),
    contbr_nm_first character varying(38),
    contbr_m_nm character varying(20),
    contbr_nm_last character varying(38),
    contbr_prefix character varying(10),
    contbr_suffix character varying(10),
    contbr_st1 character varying(34),
    contbr_st2 character varying(34),
    contbr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    contb_aggregate_ytd numeric(14,2),
    contb_receipt_dt timestamp without time zone,
    contb_receipt_amt numeric(14,2),
    receipt_tp character varying(3),
    receipt_tp_desc character varying(90),
    receipt_desc character varying(100),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_m_nm character varying(20),
    cand_nm_last character varying(38),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    donor_cmte_nm character varying(200),
    national_cmte_nonfed_acct character varying(9),
    increased_limit character varying(1),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    schedule_type character varying(8),
    form_tp_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    form_tp_cd character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone,
    delete_ind numeric(1,0)
);


CREATE TABLE nml_sched_b (
    cmte_id character varying(9),
    recipient_cmte_id character varying(9),
    recipient_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    payee_employer character varying(38),
    payee_occupation character varying(38),
    recipient_st1 character varying(34),
    recipient_st2 character varying(34),
    recipient_city character varying(30),
    recipient_st character varying(2),
    recipient_zip character varying(9),
    disb_desc character varying(100),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_tp_year character varying(4),
    election_tp_desc character varying(20),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    disb_dt timestamp without time zone,
    disb_amt numeric(14,2),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    disb_tp character varying(3),
    disb_tp_desc character varying(90),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    national_cmte_nonfed_acct character varying(9),
    ref_disp_excess_flg character varying(1),
    comm_dt timestamp without time zone,
    benef_cmte_nm character varying(200),
    semi_an_bundled_refund numeric(14,2),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_id character varying(8),
    schedule_type character varying(8),
    form_tp_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    form_tp_cd character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone,
    delete_ind numeric(1,0)
);


CREATE TABLE nml_sched_d (
    sub_id numeric(19,0),
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    cred_dbtr_id character varying(9),
    cred_dbtr_nm character varying(200),
    cred_dbtr_st1 character varying(34),
    cred_dbtr_st2 character varying(34),
    cred_dbtr_city character varying(30),
    cred_dbtr_st character varying(2),
    cred_dbtr_zip character varying(9),
    nature_debt_purpose character varying(100),
    outstg_bal_bop numeric(14,2),
    amt_incurred_per numeric(14,2),
    pymt_per numeric(14,2),
    outstg_bal_cop numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    receipt_dt timestamp without time zone,
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    cred_dbtr_l_nm character varying(30),
    cred_dbtr_f_nm character varying(20),
    cred_dbtr_m_nm character varying(20),
    cred_dbtr_prefix character varying(10),
    cred_dbtr_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone,
    creditor_debtor_name_text tsvector
);


CREATE TABLE nml_sched_e (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    exp_desc character varying(100),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(50),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_nm_first character varying(38),
    s_o_cand_nm_last character varying(38),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    indt_sign_nm character varying(90),
    indt_sign_dt timestamp without time zone,
    notary_sign_nm character varying(90),
    notary_sign_dt timestamp without time zone,
    notary_commission_exprtn_dt timestamp without time zone,
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    receipt_dt timestamp without time zone,
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(1),
    rpt_pgi_desc character varying(10),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    catg_cd character varying(3),
    cal_ytd_ofc_sought numeric(14,2),
    catg_cd_desc character varying(40),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    s_0_cand_m_nm character varying(20),
    s_0_cand_prefix character varying(10),
    s_0_cand_suffix character varying(10),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    dissem_dt timestamp without time zone,
    pg_date timestamp without time zone DEFAULT now()
);


CREATE TABLE nml_sched_f (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_desg_coord_exp_ind character varying(1),
    desg_cmte_id character varying(9),
    desg_cmte_nm character varying(200),
    subord_cmte_id character varying(9),
    subord_cmte_nm character varying(200),
    subord_cmte_st1 character varying(34),
    subord_cmte_st2 character varying(34),
    subord_cmte_city character varying(30),
    subord_cmte_st character varying(2),
    subord_cmte_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    aggregate_gen_election_exp numeric(14,2),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    exp_purpose_desc character varying(100),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    receipt_dt timestamp without time zone,
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(1),
    rpt_pgi_desc character varying(10),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    unlimited_spending_flg character varying(1),
    catg_cd character varying(3),
    unlimited_spending_flg_desc character varying(40),
    catg_cd_desc character varying(40),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


CREATE TABLE rad_cmte_analyst_search_vw (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    anlyst_id numeric(38,0),
    rad_branch character varying(14),
    firstname character varying(255),
    lastname character varying(255),
    telephone_ext numeric(4,0),
    pg_date timestamp without time zone,
    anlyst_short_id numeric(4,0),
    anlyst_email character varying(255),
    anlyst_title character varying(255)
);


CREATE TABLE trc_report_due_date (
    trc_report_due_date_id numeric(12,0),
    report_year numeric(4,0),
    report_type character varying(6),
    due_date date,
    trc_election_id numeric,
    create_date date,
    update_date date,
    sec_user_id_create numeric(12,0),
    sec_user_id_update numeric(12,0),
    pg_date timestamp without time zone
);


CREATE TABLE unverified_cand_cmte (
    cand_cmte_id character varying(9) NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


SET search_path = public, pg_catalog;

CREATE TABLE detsum_sample (
    cvg_start_dt numeric(8,0),
    cmte_pk numeric(19,0),
    cvg_end_dt numeric(8,0),
    ttl_receipts numeric(14,2),
    tranf_from_other_auth_cmte numeric(14,2),
    indv_contb numeric(14,2),
    oth_cmte_contb numeric(14,2),
    oth_loans numeric(14,2),
    ttl_disb numeric(14,2),
    tranf_to_other_auth_cmte numeric(14,2),
    indv_ref numeric(14,2),
    oth_cmte_ref numeric(14,2),
    oth_loan_repymts numeric(14,2),
    coh_bop numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    cand_loan numeric(14,2),
    cand_loan_repymnt numeric(14,2),
    indv_unitem_contb numeric(14,2),
    pty_cmte_contb numeric(14,2),
    cand_cntb numeric(14,2),
    ttl_contb numeric(14,2),
    ttl_loans numeric(14,2),
    offsets_to_op_exp numeric(14,2),
    other_receipts numeric(14,2),
    pol_pty_cmte_contb numeric(14,2),
    ttl_contb_ref numeric(14,2),
    ttl_loan_repymts numeric(14,2),
    op_exp_per numeric(14,2),
    other_disb_per numeric(14,2),
    net_contb numeric(14,2),
    net_op_exp numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    all_loans_received_per numeric(14,2),
    fed_cand_contb_ref_per numeric(14,2),
    tranf_from_nonfed_acct_per numeric(14,2),
    tranf_from_nonfed_levin_per numeric(14,2),
    ttl_nonfed_tranf_per numeric(14,2),
    ttl_fed_receipts_per numeric(14,2),
    shared_fed_op_exp_per numeric(14,2),
    shared_nonfed_op_exp_per numeric(14,2),
    other_fed_op_exp_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    fed_cand_cmte_contb_per numeric(14,2),
    indt_exp_per numeric(14,2),
    coord_exp_by_pty_cmte_per numeric(14,2),
    loans_made_per numeric(14,2),
    shared_fed_actvy_fed_shr_per numeric(14,2),
    shared_fed_actvy_nonfed_per numeric(14,2),
    non_alloc_fed_elect_actvy_per numeric(14,2),
    ttl_fed_elect_actvy_per numeric(14,2),
    offsets_to_fndrsg numeric(14,2),
    offsets_to_legal_acctg numeric(14,2),
    ttl_offsets_to_op_exp numeric(14,2),
    fndrsg_disb numeric(14,2),
    exempt_legal_acctg_disb numeric(14,2),
    cmte_id character varying(9),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    receipt_dt timestamp without time zone,
    orig_sub_id numeric(19,0),
    election_st character varying(2),
    rpt_pgi character varying(5),
    form_tp_cd character varying(8),
    fed_funds_per numeric(14,2),
    item_ref_reb_ret_per numeric(14,2),
    unitem_ref_reb_ret_per numeric(14,2),
    subttl_ref_reb_ret_per numeric(14,2),
    item_other_ref_reb_ret_per numeric(14,2),
    unitem_other_ref_reb_ret_per numeric(14,2),
    subttl_other_ref_reb_ret_per numeric(14,2),
    item_other_income_per numeric(14,2),
    unitem_other_income_per numeric(14,2),
    item_convn_exp_disb_per numeric(14,2),
    unitem_convn_exp_disb_per numeric(14,2),
    subttl_convn_exp_disb_per numeric(14,2),
    tranf_to_st_local_pty_per numeric(14,2),
    direct_st_local_cand_supp_per numeric(14,2),
    voter_reg_amt_per numeric(14,2),
    voter_id_amt_per numeric(14,2),
    gotv_amt_per numeric(14,2),
    generic_campaign_amt_per numeric(14,2),
    tranf_to_fed_alloctn_per numeric(14,2),
    item_other_disb_per numeric(14,2),
    unitem_other_disb_per numeric(14,2),
    ttl_fed_disb_per numeric(14,2),
    coh_boy numeric(14,2),
    coh_coy numeric(14,2),
    exp_subject_limits_per numeric(14,2),
    exp_prior_yrs_subject_lim_per numeric(14,2),
    ttl_exp_subject_limits numeric(14,2),
    ttl_communication_cost numeric(14,2),
    oppos_pers_fund_amt numeric(14,2),
    hse_pers_funds_amt numeric(14,2),
    sen_pers_funds_amt numeric(14,2),
    loan_repymts_received_per numeric(14,2),
    file_num numeric(7,0),
    indv_item_contb numeric(14,2),
    last_update_date timestamp without time zone,
    prev_sub_id numeric(19,0),
    pg_date timestamp without time zone
);


SET search_path = disclosure, pg_catalog;

CREATE VIEW v_sum_and_det_sum_report AS
 SELECT detsum_sample.cvg_start_dt,
    detsum_sample.cmte_pk,
    detsum_sample.cvg_end_dt,
    detsum_sample.ttl_receipts,
    detsum_sample.tranf_from_other_auth_cmte,
    detsum_sample.indv_contb,
    detsum_sample.oth_cmte_contb,
    detsum_sample.oth_loans,
    detsum_sample.ttl_disb,
    detsum_sample.tranf_to_other_auth_cmte,
    detsum_sample.indv_ref,
    detsum_sample.oth_cmte_ref,
    detsum_sample.oth_loan_repymts,
    detsum_sample.coh_bop,
    detsum_sample.coh_cop,
    detsum_sample.debts_owed_by_cmte,
    detsum_sample.cand_loan,
    detsum_sample.cand_loan_repymnt,
    detsum_sample.indv_unitem_contb,
    detsum_sample.pty_cmte_contb,
    detsum_sample.cand_cntb,
    detsum_sample.ttl_contb,
    detsum_sample.ttl_loans,
    detsum_sample.offsets_to_op_exp,
    detsum_sample.other_receipts,
    detsum_sample.pol_pty_cmte_contb,
    detsum_sample.ttl_contb_ref,
    detsum_sample.ttl_loan_repymts,
    detsum_sample.op_exp_per,
    detsum_sample.other_disb_per,
    detsum_sample.net_contb,
    detsum_sample.net_op_exp,
    detsum_sample.debts_owed_to_cmte,
    detsum_sample.all_loans_received_per,
    detsum_sample.fed_cand_contb_ref_per,
    detsum_sample.tranf_from_nonfed_acct_per,
    detsum_sample.tranf_from_nonfed_levin_per,
    detsum_sample.ttl_nonfed_tranf_per,
    detsum_sample.ttl_fed_receipts_per,
    detsum_sample.shared_fed_op_exp_per,
    detsum_sample.shared_nonfed_op_exp_per,
    detsum_sample.other_fed_op_exp_per,
    detsum_sample.ttl_op_exp_per,
    detsum_sample.fed_cand_cmte_contb_per,
    detsum_sample.indt_exp_per,
    detsum_sample.coord_exp_by_pty_cmte_per,
    detsum_sample.loans_made_per,
    detsum_sample.shared_fed_actvy_fed_shr_per,
    detsum_sample.shared_fed_actvy_nonfed_per,
    detsum_sample.non_alloc_fed_elect_actvy_per,
    detsum_sample.ttl_fed_elect_actvy_per,
    detsum_sample.offsets_to_fndrsg,
    detsum_sample.offsets_to_legal_acctg,
    detsum_sample.ttl_offsets_to_op_exp,
    detsum_sample.fndrsg_disb,
    detsum_sample.exempt_legal_acctg_disb,
    detsum_sample.cmte_id,
    detsum_sample.rpt_tp,
    detsum_sample.rpt_yr,
    detsum_sample.receipt_dt,
    detsum_sample.orig_sub_id,
    detsum_sample.election_st,
    detsum_sample.rpt_pgi,
    detsum_sample.form_tp_cd,
    detsum_sample.fed_funds_per,
    detsum_sample.item_ref_reb_ret_per,
    detsum_sample.unitem_ref_reb_ret_per,
    detsum_sample.subttl_ref_reb_ret_per,
    detsum_sample.item_other_ref_reb_ret_per,
    detsum_sample.unitem_other_ref_reb_ret_per,
    detsum_sample.subttl_other_ref_reb_ret_per,
    detsum_sample.item_other_income_per,
    detsum_sample.unitem_other_income_per,
    detsum_sample.item_convn_exp_disb_per,
    detsum_sample.unitem_convn_exp_disb_per,
    detsum_sample.subttl_convn_exp_disb_per,
    detsum_sample.tranf_to_st_local_pty_per,
    detsum_sample.direct_st_local_cand_supp_per,
    detsum_sample.voter_reg_amt_per,
    detsum_sample.voter_id_amt_per,
    detsum_sample.gotv_amt_per,
    detsum_sample.generic_campaign_amt_per,
    detsum_sample.tranf_to_fed_alloctn_per,
    detsum_sample.item_other_disb_per,
    detsum_sample.unitem_other_disb_per,
    detsum_sample.ttl_fed_disb_per,
    detsum_sample.coh_boy,
    detsum_sample.coh_coy,
    detsum_sample.exp_subject_limits_per,
    detsum_sample.exp_prior_yrs_subject_lim_per,
    detsum_sample.ttl_exp_subject_limits,
    detsum_sample.ttl_communication_cost,
    detsum_sample.oppos_pers_fund_amt,
    detsum_sample.hse_pers_funds_amt,
    detsum_sample.sen_pers_funds_amt,
    detsum_sample.loan_repymts_received_per,
    detsum_sample.file_num,
    detsum_sample.indv_item_contb,
    detsum_sample.last_update_date,
    detsum_sample.prev_sub_id,
    detsum_sample.pg_date
   FROM public.detsum_sample;


SET search_path = fecapp, pg_catalog;

CREATE TABLE cal_category (
    cal_category_id numeric,
    category_name character varying(150),
    active character varying(1),
    order_numeric numeric,
    sec_user_id_create numeric(12,0),
    create_date timestamp without time zone,
    sec_user_id_update numeric(12,0),
    update_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE cal_category_subcat (
    cal_category_id numeric,
    cal_category_id_subcat numeric,
    sec_user_id_create numeric(12,0),
    create_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE cal_event (
    cal_event_id numeric,
    event_name character varying(150),
    description character varying(500),
    location character varying(200),
    url character varying(250),
    start_date timestamp without time zone,
    use_time character varying(1),
    end_date timestamp without time zone,
    cal_event_status_id numeric,
    priority numeric(1,0),
    sec_user_id_create numeric(12,0),
    create_date timestamp without time zone,
    sec_user_id_update numeric(12,0),
    update_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE cal_event_category (
    cal_event_id numeric,
    cal_category_id numeric,
    sec_user_id_create numeric(12,0),
    create_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE cal_event_status (
    cal_event_status_id numeric,
    cal_event_status_desc character varying(30),
    pg_date timestamp without time zone
);


CREATE TABLE trc_election (
    trc_election_id numeric,
    election_state character varying(2),
    election_district character varying(3),
    election_party character varying(3),
    office_sought character varying(1),
    election_date date,
    election_notes character varying(250),
    sec_user_id_update numeric(12,0),
    sec_user_id_create numeric(12,0),
    trc_election_type_id character varying(3),
    trc_election_status_id numeric,
    update_date timestamp without time zone,
    create_date timestamp without time zone,
    election_yr numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE trc_election_dates (
    trc_election_id numeric,
    election_date date,
    close_of_books date,
    rc_date date,
    filing_date date,
    f48hour_start date,
    f48hour_end date,
    notice_mail_date date,
    losergram_mail_date date,
    ec_start date,
    ec_end date,
    ie_48hour_start date,
    ie_48hour_end date,
    ie_24hour_start date,
    ie_24hour_end date,
    cc_start date,
    cc_end date,
    election_date2 date,
    ballot_deadline date,
    primary_voter_reg_start date,
    primary_voter_reg_end date,
    general_voter_reg_start date,
    general_voter_reg_end date,
    date_special_election_set date,
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    election_party character varying(3),
    display_flag character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE trc_report_due_date (
    trc_report_due_date_id numeric(12,0),
    report_year numeric(4,0),
    report_type character varying(6),
    due_date date,
    trc_election_id numeric,
    create_date date,
    update_date date,
    sec_user_id_create numeric(12,0),
    sec_user_id_update numeric(12,0),
    pg_date timestamp without time zone
);


SET search_path = public, pg_catalog;

CREATE TABLE ao (
    ao_id numeric NOT NULL,
    name character varying(120),
    req_date timestamp without time zone,
    issue_date timestamp without time zone,
    tags character varying(5),
    summary character varying(4000),
    stage numeric(1,0),
    status_is_new character(1),
    ao_no character varying(9),
    pg_date timestamp without time zone
);


CREATE TABLE blah (
    "?column?" integer
);


CREATE TABLE cal_user_category (
    sec_user_id numeric(12,0) NOT NULL,
    cal_category_id numeric NOT NULL,
    sec_user_id_create numeric(12,0) NOT NULL,
    create_date timestamp without time zone NOT NULL,
    pg_date timestamp without time zone
);


CREATE TABLE cand_cmte_linkage (
    linkage_id numeric(12,0) NOT NULL,
    cand_id character varying(9) NOT NULL,
    cand_election_yr numeric(4,0) NOT NULL,
    fec_election_yr numeric(4,0) NOT NULL,
    cmte_id character varying(9),
    cmte_tp character varying(1),
    cmte_dsgn character varying(1),
    linkage_type character varying(1),
    user_id_entered numeric(12,0),
    date_entered date,
    user_id_changed numeric(12,0),
    date_changed date,
    cmte_count_cand_yr numeric(2,0),
    efile_paper_ind character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE cand_inactive (
    cand_id character varying(9) NOT NULL,
    election_yr numeric(4,0) NOT NULL,
    pg_date timestamp without time zone
);


CREATE TABLE cand_valid_fec_yr (
    cand_valid_yr_id numeric(12,0) NOT NULL,
    cand_id character varying(9),
    fec_election_yr numeric(4,0),
    cand_election_yr numeric(4,0),
    cand_status character varying(1),
    cand_ici character varying(1),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    cand_pty_affiliation character varying(3),
    cand_name character varying(90),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_state character varying(2),
    cand_zip character varying(9),
    race_pk numeric,
    lst_updt_dt date,
    latest_receipt_dt date,
    user_id_entered numeric(6,0),
    date_entered date NOT NULL,
    user_id_changed numeric(6,0),
    date_changed date,
    ref_cand_pk numeric(19,0),
    ref_lst_updt_dt date,
    pg_date timestamp without time zone
);


CREATE TABLE candidate_summary (
    fec_election_yr numeric(4,0) NOT NULL,
    cand_election_yr numeric(4,0) NOT NULL,
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office character varying(1),
    cand_office_district character varying(2),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_id character varying(9) NOT NULL,
    cand_nm character varying(90),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_state character varying(2),
    cand_zip character varying(9),
    cand_ici_desc character varying(15),
    indv_item_contb numeric,
    indv_unitem_contb numeric,
    indv_contb numeric,
    oth_cmte_contb numeric,
    pty_cmte_contb numeric,
    cand_contb numeric,
    ttl_contb numeric,
    tranf_from_other_auth_cmte numeric,
    cand_loan numeric,
    oth_loans numeric,
    ttl_loans numeric,
    offsets_to_op_exp numeric,
    offsets_to_fndrsg numeric,
    offsets_to_legal_acctg numeric,
    other_receipts numeric,
    ttl_receipts numeric,
    op_exp_per numeric,
    exempt_legal_acctg_disb numeric,
    fndrsg_disb numeric,
    tranf_to_other_auth_cmte numeric,
    cand_loan_repymnt numeric,
    oth_loan_repymts numeric,
    ttl_loan_repymts numeric,
    indv_ref numeric,
    pty_cmte_ref numeric,
    oth_cmte_ref numeric,
    ttl_contb_ref numeric,
    other_disb_per numeric,
    ttl_disb numeric,
    net_contb numeric,
    net_op_exp numeric,
    coh_bop numeric,
    coh_cop numeric,
    debts_owed_by_cmte numeric,
    debts_owed_to_cmte numeric,
    cvg_start_dt character varying(10),
    cvg_end_dt character varying(10),
    efile_paper_ind character varying(1),
    cmte_count_cand_yr numeric(2,0),
    update_dt date,
    activity character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE cmte_cmte_linkage (
    linkage_id numeric(12,0) NOT NULL,
    sponsor_cmte_id character varying(9),
    filer_cmte_id character varying(9),
    fec_election_yr numeric(4,0),
    sponsor_cmte_tp character varying(1),
    filer_cmte_tp character varying(1),
    start_dt timestamp without time zone,
    end_dt timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE committee_summary_exclude (
    sub_id numeric(19,0) NOT NULL,
    cmte_id character varying(9),
    form_tp_cd character varying(8),
    pg_date timestamp without time zone
);


CREATE TABLE communication_costs_vw (
    cmte_id character varying(9),
    cand_id character varying(9),
    cmte_nm character varying(200),
    cand_name character varying(90),
    cand_office_st character varying(2),
    st_desc character varying(40),
    cand_office character varying(1),
    cand_office_district character varying(2),
    cand_pty_affiliation character varying(3),
    pty_desc character varying(50),
    transaction_dt timestamp without time zone,
    transaction_amt numeric(14,2),
    transaction_tp character varying(3),
    purpose character varying(100),
    communication_tp character varying(2),
    communication_class character varying(1),
    support_oppose_ind character varying(3),
    image_num character varying(18),
    line_num character varying(12),
    form_tp_cd character varying(8),
    sched_tp_cd character varying(8),
    tran_id character varying(32),
    sub_id numeric(19,0) NOT NULL,
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    f7_receipt_dt timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE customers (
    custno numeric(3,0) NOT NULL,
    custname character varying(30) NOT NULL,
    street character varying(20) NOT NULL,
    city character varying(20) NOT NULL,
    state character(2) NOT NULL,
    zip character varying(10) NOT NULL,
    phone character varying(12)
);


CREATE TABLE dim_calendar_inf (
    calendar_pk numeric(8,0) NOT NULL,
    calendar_dt timestamp without time zone,
    calendar_mth_cd numeric(2,0),
    calendar_mth_cd_desc character varying(9),
    calendar_qtr_cd character varying(2),
    calendar_qtr_cd_desc character varying(5),
    calendar_yr numeric(4,0),
    fec_election_year numeric(4,0),
    calendar_mth_id numeric(6,0),
    calendar_mth_id_desc character varying(15),
    pg_date timestamp without time zone
);


CREATE TABLE dim_cand_inf (
    cand_pk numeric(19,0) NOT NULL,
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_last character varying(38),
    cand_nm_first character varying(38),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_pty_cd character varying(1),
    cand_pty_cd_desc character varying(33),
    cand_ici character varying(1),
    cand_ici_desc character varying(15),
    cand_status character varying(1),
    cand_status_desc character varying(40),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    election_yr numeric(4,0),
    cand_st1 character varying(34),
    orig_receipt_dt timestamp without time zone,
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_state character varying(2),
    cand_zip character varying(9),
    mst_rct_rec_flg character varying(1),
    lst_updt_dt timestamp without time zone,
    pcc_cmte_id character varying(9),
    create_date timestamp without time zone,
    race_pk numeric(12,0),
    latest_receipt_dt timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE dim_cmte_ie_inf (
    cmte_pk numeric(19,0) NOT NULL,
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    filed_cmte_dsgn character varying(1),
    filed_cmte_tp character varying(1),
    filed_cmte_tp_desc character varying(58),
    cmte_subtp_desc character varying(35),
    filed_cmte_dsgn_desc character varying(90),
    jntfndrsg_cmte_flg character varying(1),
    cmte_pty_affiliation character varying(3),
    cmte_dsgn_desc character varying(20),
    cmte_pty_affiliation_desc character varying(50),
    cmte_class_desc character varying(20),
    cmte_email character varying(90),
    cmte_tp_desc character varying(23),
    cmte_url character varying(90),
    cmte_filing_freq character varying(1),
    cmte_filing_freq_desc character varying(27),
    cmte_qual_start_dt timestamp without time zone,
    cmte_term_request_dt timestamp without time zone,
    cmte_pty_tp character varying(3),
    cmte_term_dt timestamp without time zone,
    cmte_pty_tp_desc character varying(90),
    mst_rct_rec_flg character varying(1),
    lst_updt_dt timestamp without time zone,
    cmte_tp_start_dt timestamp without time zone,
    cmte_tp_end_dt timestamp without time zone,
    org_tp character varying(1),
    org_tp_desc character varying(90),
    tres_nm character varying(90),
    create_date timestamp without time zone,
    cmte_dsgn_start_date timestamp without time zone,
    cmte_dsgn_end_date timestamp without time zone,
    latest_filing_yr numeric(4,0),
    form_tp character varying(8),
    cmte_tp_dsgn_start_date timestamp without time zone,
    cmte_tp_dsgn_end_date timestamp without time zone,
    orig_receipt_dt timestamp without time zone,
    latest_receipt_dt timestamp without time zone,
    connected_org_nm character varying(200),
    f3l_filing_freq character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE dim_cmte_prsnl_inf (
    cmte_prsnl_id numeric(12,0) NOT NULL,
    cmte_pk numeric(19,0) NOT NULL,
    role character varying(90),
    prsnl_nm character varying(90),
    prsnl_st1 character varying(34),
    prsnl_st2 character varying(34),
    prsnl_city character varying(18),
    prsnl_state character varying(2),
    prsnl_zip character varying(9),
    title_position character varying(90),
    start_dt timestamp without time zone,
    end_dt timestamp without time zone,
    mst_rct_rec_flg character varying(1),
    lst_updt_dt timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE dim_election_attrib_inf (
    election_attrib_pk numeric(3,0) NOT NULL,
    election_tp_ind character varying(2),
    election_tp_ind_desc character varying(20),
    win_lost_status_ind character varying(1),
    win_lose_status_ind_desc character varying(20),
    source_tp character varying(1),
    source_tp_desc character varying(50),
    pg_date timestamp without time zone
);


CREATE TABLE dim_race_inf (
    race_pk numeric(12,0) NOT NULL,
    office character varying(1),
    office_desc character varying(20),
    state character varying(2),
    state_desc character varying(20),
    district character varying(2),
    election_yr numeric(4,0),
    open_seat_flg character varying(1),
    create_date timestamp without time zone,
    election_type_id character varying(2),
    cycle_start_dt timestamp without time zone,
    cycle_end_dt timestamp without time zone,
    election_dt timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE dimyears (
    year_sk numeric(10,0) NOT NULL,
    year numeric(4,0),
    load_date timestamp without time zone NOT NULL,
    pg_date timestamp without time zone
);


CREATE TABLE doc_order (
    doc_order_id numeric NOT NULL,
    category character varying(255),
    pg_date timestamp without time zone
);


CREATE TABLE document (
    document_id numeric NOT NULL,
    filename character varying(255),
    category character varying(255),
    document_date timestamp without time zone,
    fileimage bytea,
    ocrtext text,
    ao_id numeric,
    description character varying(255),
    doc_order_id numeric,
    pg_date timestamp without time zone
);


CREATE TABLE real_efile_reps (
    repid numeric(12,0) NOT NULL,
    form character varying(4),
    comid character varying(9),
    com_name character varying(200),
    filed_date date,
    "timestamp" date,
    from_date date,
    through_date date,
    md5 character varying(32),
    superceded numeric,
    previd numeric,
    rptcode character varying(4),
    ef character varying(1),
    version character varying(4),
    filed character varying(1),
    rptnum numeric,
    starting numeric,
    ending numeric,
    used character varying(1),
    create_dt timestamp without time zone,
    exclude_ind character varying(1),
    notes character varying(100)
);


CREATE VIEW efile_amendment_chain_vw AS
 WITH RECURSIVE oldest_filing AS (
         SELECT real_efile_reps.repid,
            real_efile_reps.comid,
            real_efile_reps.previd,
            ARRAY[real_efile_reps.repid] AS amendment_chain,
            1 AS depth,
            real_efile_reps.repid AS last
           FROM real_efile_reps
          WHERE (real_efile_reps.previd IS NULL)
        UNION
         SELECT se.repid,
            se.comid,
            se.previd,
            ((oldest.amendment_chain || se.repid))::numeric(12,0)[] AS "numeric",
            (oldest.depth + 1),
            oldest.amendment_chain[1] AS amendment_chain
           FROM oldest_filing oldest,
            real_efile_reps se
          WHERE ((se.previd = oldest.repid) AND (se.previd IS NOT NULL))
        ), latest AS (
         SELECT sub_query.repid,
            sub_query.comid,
            sub_query.previd,
            sub_query.amendment_chain,
            sub_query.depth,
            sub_query.last,
            sub_query.rank
           FROM ( SELECT oldest_filing.repid,
                    oldest_filing.comid,
                    oldest_filing.previd,
                    oldest_filing.amendment_chain,
                    oldest_filing.depth,
                    oldest_filing.last,
                    rank() OVER (PARTITION BY oldest_filing.last ORDER BY oldest_filing.depth DESC) AS rank
                   FROM oldest_filing) sub_query
          WHERE (sub_query.rank = 1)
        )
 SELECT of.repid,
    of.comid,
    of.previd,
    of.amendment_chain,
    of.depth,
    of.last,
    late.repid AS most_recent_filing,
    late.amendment_chain AS longest_chain
   FROM (oldest_filing of
     JOIN latest late ON ((of.last = late.last)));


CREATE TABLE efile_guide_f3 (
    index bigint,
    "summary line number" bigint,
    "f3 line number" text,
    description text,
    fecp_col_a text,
    fecp_col_b text,
    "Unnamed: 5" text
);


CREATE TABLE efile_guide_f3p (
    index bigint,
    "summary line number" bigint,
    "f3p line number" text,
    description text,
    fecp_col_a text,
    fecp_col_b text,
    "Unnamed: 5" text
);


CREATE TABLE efile_guide_f3x (
    index bigint,
    "summary line number" bigint,
    "f3x line number" text,
    description text,
    fecp_col_a text,
    fecp_col_b text,
    "Unnamed: 5" text
);


CREATE VIEW efiling_amendment_chain_vw AS
 WITH RECURSIVE oldest_filing AS (
         SELECT real_efile_reps.repid,
            real_efile_reps.comid,
            real_efile_reps.previd,
            ARRAY[real_efile_reps.repid] AS amendment_chain,
            1 AS depth,
            real_efile_reps.repid AS last
           FROM real_efile_reps
          WHERE (real_efile_reps.previd IS NULL)
        UNION
         SELECT se.repid,
            se.comid,
            se.previd,
            ((oldest.amendment_chain || se.repid))::numeric(12,0)[] AS "numeric",
            (oldest.depth + 1),
            oldest.amendment_chain[1] AS amendment_chain
           FROM oldest_filing oldest,
            real_efile_reps se
          WHERE ((se.previd = oldest.repid) AND (se.previd IS NOT NULL))
        ), latest AS (
         SELECT sub_query.repid,
            sub_query.comid,
            sub_query.previd,
            sub_query.amendment_chain,
            sub_query.depth,
            sub_query.last,
            sub_query.rank
           FROM ( SELECT oldest_filing.repid,
                    oldest_filing.comid,
                    oldest_filing.previd,
                    oldest_filing.amendment_chain,
                    oldest_filing.depth,
                    oldest_filing.last,
                    rank() OVER (PARTITION BY oldest_filing.last ORDER BY oldest_filing.depth DESC) AS rank
                   FROM oldest_filing) sub_query
          WHERE (sub_query.rank = 1)
        )
 SELECT of.repid,
    of.comid,
    of.previd,
    of.amendment_chain,
    of.depth,
    of.last,
    late.repid AS most_recent_filing,
    late.amendment_chain AS longest_chain
   FROM (oldest_filing of
     JOIN latest late ON ((of.last = late.last)));


CREATE TABLE electioneering_com_vw (
    cand_id character varying(9),
    cand_name character varying(90),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    sb_image_num character varying(18),
    payee_nm character varying(200),
    payee_st1 character varying(34),
    payee_city character varying(30),
    payee_st character varying(2),
    disb_desc character varying(100),
    disb_dt timestamp without time zone,
    comm_dt timestamp without time zone,
    pub_distrib_dt timestamp without time zone,
    reported_disb_amt numeric(14,2),
    number_of_candidates numeric,
    calculated_cand_share numeric,
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    rpt_yr numeric(4,0),
    sb_link_id numeric(19,0),
    f9_begin_image_num character varying(18),
    receipt_dt timestamp without time zone,
    election_tp character varying(5),
    file_num numeric(7,0),
    amndt_ind character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE entity (
    entity_id numeric NOT NULL,
    first_name character varying(30),
    last_name character varying(30),
    middle_name character varying(30),
    prefix character varying(10),
    suffix character varying(10),
    name character varying(90),
    type numeric,
    type2 numeric,
    type3 numeric,
    pg_date timestamp without time zone
);


CREATE TABLE entity_disbursements_chart (
    idx bigint,
    type text,
    month double precision,
    year double precision,
    cycle numeric,
    adjusted_total_disbursements numeric,
    sum numeric
);


CREATE TABLE entity_receipts_chart (
    idx bigint,
    type text,
    month double precision,
    year double precision,
    cycle numeric,
    adjusted_total_receipts double precision,
    sum double precision
);


CREATE TABLE entity_type (
    entity_type_id numeric NOT NULL,
    description character varying(255),
    flags character varying(30),
    pg_date timestamp without time zone
);


CREATE TABLE f1_filer_vw (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    affiliated_cmte_nm character varying(200),
    filed_cmte_tp character varying(1),
    filed_cmte_dsgn character varying(1),
    org_tp character varying(1),
    filing_freq character varying(1),
    tres_nm character varying(90),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_email character varying(90),
    cmte_web_url character varying(90),
    begin_image_num character varying(18),
    receipt_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE f2_filer_vw (
    cand_id character varying(9),
    cand_nm character varying(90),
    party character varying(50),
    party_cd character varying(3),
    cand_office character varying(9),
    cand_office_cd character varying(1),
    cand_office_st character varying(40),
    st_abv character varying(2),
    cand_office_district character varying(2),
    cand_city character varying(30),
    cand_st character varying(2),
    cand_zip character varying(9),
    election_yr numeric(4,0),
    rpt_yr numeric(4,0),
    receipt_dt timestamp without time zone,
    begin_image_num character varying(18),
    pg_date timestamp without time zone
);


CREATE TABLE f_campaign (
    cmte_pk numeric(19,0) NOT NULL,
    cand_pk numeric(19,0) NOT NULL,
    create_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE f_election_vote (
    race_pk numeric(12,0) NOT NULL,
    cand_pk numeric(19,0) NOT NULL,
    election_attrib_pk numeric(3,0) NOT NULL,
    num_of_votes_received numeric(12,0),
    pct_election_vote numeric(7,4),
    pg_date timestamp without time zone
);


CREATE TABLE f_item_selected_list_trans (
    sub_id numeric(19,0) NOT NULL,
    v_sum_link_id numeric(19,0) NOT NULL,
    rn numeric(19,0) NOT NULL,
    cmte_id character varying(9),
    fec_election_yr numeric(4,0),
    form_tp_cd character varying(8),
    line_num character varying(12),
    sched_tp_cd character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    name character varying(200),
    employer character varying(38),
    occupation character varying(38),
    purpose character varying(100),
    memo_text character varying(100),
    description character varying(200),
    city character varying(30),
    state character varying(2),
    zip_code character varying(9),
    image_num character varying(18),
    transaction_tp character varying(3),
    transaction_dt numeric(8,0),
    transaction_amt numeric(14,2),
    transaction_pgi character varying(5),
    memo_cd character varying(1),
    other_id character varying(9),
    cand_id character varying(9),
    communication_tp character varying(2),
    communication_class character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE f_item_selected_list_trans_cnt (
    cmte_id character varying(9),
    fec_election_yr numeric(4,0),
    form_tp_cd character varying(8),
    line_num character varying(12),
    ttl_trans numeric,
    pg_date timestamp without time zone
);


CREATE TABLE facthousesenate_f3 (
    facthousesenate_f3_sk numeric(10,0) NOT NULL,
    form_3_sk numeric(10,0),
    cmte_sk numeric(10,0),
    reporttype_sk numeric(10,0),
    two_yr_period_sk numeric(10,0),
    transaction_sk numeric(10,0),
    cvg_start_dt_sk numeric(10,0),
    cvg_end_dt_sk numeric(10,0),
    electiontp_sk numeric(10,0),
    rpt_yr numeric(4,0),
    ttl_contb_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    net_contb_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    net_op_exp_per numeric(14,2),
    coh_cop_i numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    ttl_indv_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_column_ttl_per numeric(14,2),
    tranf_from_other_auth_cmte_per numeric(14,2),
    loans_made_by_cand_per numeric(14,2),
    all_other_loans_per numeric(14,2),
    ttl_loans_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    ttl_receipts_per_i numeric(14,2),
    op_exp_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    loan_repymts_cand_loans_per numeric(14,2),
    loan_repymts_other_loans_per numeric(14,2),
    ttl_loan_repymts_per numeric(14,2),
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    ttl_contb_ref_col_ttl_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per_i numeric(14,2),
    coh_bop numeric(14,2),
    ttl_receipts_ii numeric(14,2),
    subttl_per numeric(14,2),
    ttl_disb_per_ii numeric(14,2),
    coh_cop_ii numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd numeric(14,2),
    net_contb_ytd numeric(14,2),
    ttl_op_exp_ytd numeric(14,2),
    ttl_offsets_to_op_exp_ytd numeric(14,2),
    net_op_exp_ytd numeric(14,2),
    ttl_indv_item_contb_ytd numeric(14,2),
    ttl_indv_unitem_contb_ytd numeric(14,2),
    ttl_indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd numeric(14,2),
    other_pol_cmte_contb_ytd numeric(14,2),
    cand_contb_ytd numeric(14,2),
    ttl_contb_col_ttl_ytd numeric(14,2),
    tranf_from_other_auth_cmte_ytd numeric(14,2),
    loans_made_by_cand_ytd numeric(14,2),
    all_other_loans_ytd numeric(14,2),
    ttl_loans_ytd numeric(14,2),
    offsets_to_op_exp_ytd numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    op_exp_ytd numeric(14,2),
    tranf_to_other_auth_cmte_ytd numeric(14,2),
    loan_repymts_cand_loans_ytd numeric(14,2),
    loan_repymts_other_loans_ytd numeric(14,2),
    ttl_loan_repymts_ytd numeric(14,2),
    ref_indv_contb_ytd numeric(14,2),
    ref_pol_pty_cmte_contb_ytd numeric(14,2),
    ref_other_pol_cmte_contb_ytd numeric(14,2),
    ref_ttl_contb_col_ttl_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    grs_rcpt_auth_cmte_prim numeric(14,2),
    agr_amt_contrib_pers_fund_prim numeric(14,2),
    grs_rcpt_min_pers_contrib_prim numeric(14,2),
    grs_rcpt_auth_cmte_gen numeric(14,2),
    agr_amt_pers_contrib_gen numeric(14,2),
    grs_rcpt_min_pers_contrib_gen numeric(14,2),
    begin_image_num numeric(18,0),
    end_image_num numeric(18,0),
    receipt_dt date,
    load_date timestamp without time zone NOT NULL,
    expire_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE factindpexpcontb_f5 (
    factindpexpcontb_f5_sk numeric(10,0) NOT NULL,
    form_5_sk numeric(10,0),
    indv_org_sk numeric(10,0),
    reporttype_sk numeric(10,0),
    two_yr_period_sk numeric(10,0),
    transaction_sk numeric(10,0),
    cvg_start_dt_sk numeric(10,0),
    cvg_end_dt_sk numeric(10,0),
    electiontp_sk numeric(10,0),
    rpt_yr numeric(4,0),
    ttl_indt_contb numeric(14,2),
    ttl_indt_exp numeric(14,2),
    filer_sign_dt date,
    notary_sign_dt date,
    notary_commission_exprtn_dt date,
    begin_image_num numeric(18,0),
    end_image_num numeric(18,0),
    receipt_dt date,
    load_date timestamp without time zone NOT NULL,
    expire_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE factpacsandparties_f3x (
    factpacsandparties_f3x_sk numeric(10,0) NOT NULL,
    form_3x_sk numeric(10,0),
    cmte_sk numeric(10,0),
    reporttype_sk numeric(10,0),
    two_yr_period_sk numeric(10,0),
    transaction_sk numeric(10,0),
    cvg_start_dt_sk numeric(10,0),
    cvg_end_dt_sk numeric(10,0),
    electiontp_sk numeric(10,0),
    rpt_yr numeric(4,0),
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    ttl_indv_contb numeric(14,2),
    pol_pty_cmte_contb_per_i numeric(14,2),
    other_pol_cmte_contb_per_i numeric(14,2),
    ttl_contb_col_ttl_per numeric(14,2),
    tranf_from_affiliated_pty_per numeric(14,2),
    all_loans_received_per numeric(14,2),
    loan_repymts_received_per numeric(14,2),
    offsets_to_op_exp_per_i numeric(14,2),
    fed_cand_contb_ref_per numeric(14,2),
    other_fed_receipts_per numeric(14,2),
    tranf_from_nonfed_acct_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    ttl_fed_receipts_per numeric(14,2),
    shared_fed_op_exp_per numeric(14,2),
    shared_nonfed_op_exp_per numeric(14,2),
    other_fed_op_exp_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    tranf_to_affliliated_cmte_per numeric(14,2),
    fed_cand_cmte_contb_per numeric(14,2),
    indt_exp_per numeric(14,2),
    coord_exp_by_pty_cmte_per numeric(14,2),
    loan_repymts_made_per numeric(14,2),
    loans_made_per numeric(14,2),
    indv_contb_ref_per numeric(14,2),
    pol_pty_cmte_contb_per_ii numeric(14,2),
    other_pol_cmte_contb_per_ii numeric(14,2),
    ttl_contb_ref_per_i numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    ttl_fed_disb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    ttl_contb_ref_per_ii numeric(14,2),
    net_contb_per numeric(14,2),
    ttl_fed_op_exp_per numeric(14,2),
    offsets_to_op_exp_per_ii numeric(14,2),
    net_op_exp_per numeric(14,2),
    coh_begin_calendar_yr numeric(14,2),
    calendar_yr numeric(4,0),
    ttl_receipts_sum_page_ytd numeric(14,2),
    subttl_sum_ytd numeric(14,2),
    ttl_disb_sum_page_ytd numeric(14,2),
    coh_coy numeric(14,2),
    indv_item_contb_ytd numeric(14,2),
    indv_unitem_contb_ytd numeric(14,2),
    ttl_indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd_i numeric(14,2),
    other_pol_cmte_contb_ytd_i numeric(14,2),
    ttl_contb_col_ttl_ytd numeric(14,2),
    tranf_from_affiliated_pty_ytd numeric(14,2),
    all_loans_received_ytd numeric(14,2),
    loan_repymts_received_ytd numeric(14,2),
    offsets_to_op_exp_ytd_i numeric(14,2),
    fed_cand_cmte_contb_ytd numeric(14,2),
    other_fed_receipts_ytd numeric(14,2),
    tranf_from_nonfed_acct_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    ttl_fed_receipts_ytd numeric(14,2),
    shared_fed_op_exp_ytd numeric(14,2),
    shared_nonfed_op_exp_ytd numeric(14,2),
    other_fed_op_exp_ytd numeric(14,2),
    ttl_op_exp_ytd numeric(14,2),
    tranf_to_affilitated_cmte_ytd numeric(14,2),
    fed_cand_cmte_contb_ref_ytd numeric(14,2),
    indt_exp_ytd numeric(14,2),
    coord_exp_by_pty_cmte_ytd numeric(14,2),
    loan_repymts_made_ytd numeric(14,2),
    loans_made_ytd numeric(14,2),
    indv_contb_ref_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd_ii numeric(14,2),
    other_pol_cmte_contb_ytd_ii numeric(14,2),
    ttl_contb_ref_ytd_i numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    ttl_fed_disb_ytd numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd_ii numeric(14,2),
    net_contb_ytd numeric(14,2),
    ttl_fed_op_exp_ytd numeric(14,2),
    offsets_to_op_exp_ytd_ii numeric(14,2),
    net_op_exp_ytd numeric(14,2),
    tranf_from_nonfed_levin_per numeric(14,2),
    ttl_nonfed_tranf_per numeric(14,2),
    shared_fed_actvy_fed_shr_per numeric(14,2),
    shared_fed_actvy_nonfed_per numeric(14,2),
    non_alloc_fed_elect_actvy_per numeric(14,2),
    ttl_fed_elect_actvy_per numeric(14,2),
    tranf_from_nonfed_levin_ytd numeric(14,2),
    ttl_nonfed_tranf_ytd numeric(14,2),
    shared_fed_actvy_fed_shr_ytd numeric(14,2),
    shared_fed_actvy_nonfed_ytd numeric(14,2),
    non_alloc_fed_elect_actvy_ytd numeric(14,2),
    ttl_fed_elect_actvy_ytd numeric(14,2),
    begin_image_num numeric(18,0),
    end_image_num numeric(18,0),
    receipt_dt date,
    load_date timestamp without time zone NOT NULL,
    expire_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE factpresidential_f3p (
    factpresidential_f3p_sk numeric(10,0) NOT NULL,
    form_3p_sk numeric(10,0),
    cmte_sk numeric(10,0),
    reporttype_sk numeric(10,0),
    two_yr_period_sk numeric(10,0),
    transaction_sk numeric(10,0),
    cvg_start_dt_sk numeric(10,0),
    cvg_end_dt_sk numeric(10,0),
    electiontp_sk numeric(10,0),
    rpt_yr numeric(4,0),
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    indv_contb_per numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    op_exp_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    fndrsg_disb_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    alabama_per numeric(14,2),
    alaska_per numeric(14,2),
    arizona_per numeric(14,2),
    arkansas_per numeric(14,2),
    california_per numeric(14,2),
    colorado_per numeric(14,2),
    connecticut_per numeric(14,2),
    delaware_per numeric(14,2),
    district_columbia_per numeric(14,2),
    florida_per numeric(14,2),
    georgia_per numeric(14,2),
    hawaii_per numeric(14,2),
    idaho_per numeric(14,2),
    illinois_per numeric(14,2),
    indiana_per numeric(14,2),
    iowa_per numeric(14,2),
    kansas_per numeric(14,2),
    kentucky_per numeric(14,2),
    louisiana_per numeric(14,2),
    maine_per numeric(14,2),
    maryland_per numeric(14,2),
    massachusetts_per numeric(14,2),
    michigan_per numeric(14,2),
    minnesota_per numeric(14,2),
    mississippi_per numeric(14,2),
    missouri_per numeric(14,2),
    montana_per numeric(14,2),
    nebraska_per numeric(14,2),
    nevada_per numeric(14,2),
    new_hampshire_per numeric(14,2),
    new_jersey_per numeric(14,2),
    new_mexico_per numeric(14,2),
    new_york_per numeric(14,2),
    north_carolina_per numeric(14,2),
    north_dakota_per numeric(14,2),
    ohio_per numeric(14,2),
    oklahoma_per numeric(14,2),
    oregon_per numeric(14,2),
    pennsylvania_per numeric(14,2),
    rhode_island_per numeric(14,2),
    south_carolina_per numeric(14,2),
    south_dakota_per numeric(14,2),
    tennessee_per numeric(14,2),
    texas_per numeric(14,2),
    utah_per numeric(14,2),
    vermont_per numeric(14,2),
    virginia_per numeric(14,2),
    washington_per numeric(14,2),
    west_virginia_per numeric(14,2),
    wisconsin_per numeric(14,2),
    wyoming_per numeric(14,2),
    puerto_rico_per numeric(14,2),
    guam_per numeric(14,2),
    virgin_islands_per numeric(14,2),
    ttl_per numeric(14,2),
    fed_funds_ytd numeric(14,2),
    indv_contb_ytd numeric(14,2),
    indv_unitem_contb_ytd numeric(14,2),
    indv_item_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd numeric(14,2),
    other_pol_cmte_contb_ytd numeric(14,2),
    cand_contb_ytd numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    tranf_from_affiliated_cmte_ytd numeric(14,2),
    loans_received_from_cand_ytd numeric(14,2),
    other_loans_received_ytd numeric(14,2),
    ttl_loans_received_ytd numeric(14,2),
    offsets_to_op_exp_ytd numeric(14,2),
    offsets_to_fndrsg_exp_ytd numeric(14,2),
    offsets_to_legal_acctg_ytd numeric(14,2),
    ttl_offsets_to_op_exp_ytd numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    op_exp_ytd numeric(14,2),
    tranf_to_other_auth_cmte_ytd numeric(14,2),
    fndrsg_disb_ytd numeric(14,2),
    exempt_legal_acctg_disb_ytd numeric(14,2),
    repymts_loans_made_cand_ytd numeric(14,2),
    repymts_other_loans_ytd numeric(14,2),
    ttl_loan_repymts_made_ytd numeric(14,2),
    ref_indv_contb_ytd numeric(14,2),
    ref_pol_pty_cmte_contb_ytd numeric(14,2),
    ref_other_pol_cmte_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    alabama_ytd numeric(14,2),
    alaska_ytd numeric(14,2),
    arizona_ytd numeric(14,2),
    arkansas_ytd numeric(14,2),
    california_ytd numeric(14,2),
    colorado_ytd numeric(14,2),
    connecticut_ytd numeric(14,2),
    delaware_ytd numeric(14,2),
    district_columbia_ytd numeric(14,2),
    florida_ytd numeric(14,2),
    georgia_ytd numeric(14,2),
    hawaii_ytd numeric(14,2),
    idaho_ytd numeric(14,2),
    illinois_ytd numeric(14,2),
    indiana_ytd numeric(14,2),
    iowa_ytd numeric(14,2),
    kansas_ytd numeric(14,2),
    kentucky_ytd numeric(14,2),
    louisiana_ytd numeric(14,2),
    maine_ytd numeric(14,2),
    maryland_ytd numeric(14,2),
    massachusetts_ytd numeric(14,2),
    michigan_ytd numeric(14,2),
    minnesota_ytd numeric(14,2),
    mississippi_ytd numeric(14,2),
    missouri_ytd numeric(14,2),
    montana_ytd numeric(14,2),
    nebraska_ytd numeric(14,2),
    nevada_ytd numeric(14,2),
    new_hampshire_ytd numeric(14,2),
    new_jersey_ytd numeric(14,2),
    new_mexico_ytd numeric(14,2),
    new_york_ytd numeric(14,2),
    north_carolina_ytd numeric(14,2),
    north_dakota_ytd numeric(14,2),
    ohio_ytd numeric(14,2),
    oklahoma_ytd numeric(14,2),
    oregon_ytd numeric(14,2),
    pennsylvania_ytd numeric(14,2),
    rhode_island_ytd numeric(14,2),
    south_carolina_ytd numeric(14,2),
    south_dakota_ytd numeric(14,2),
    tennessee_ytd numeric(14,2),
    texas_ytd numeric(14,2),
    utah_ytd numeric(14,2),
    vermont_ytd numeric(14,2),
    virginia_ytd numeric(14,2),
    washington_ytd numeric(14,2),
    west_virginia_ytd numeric(14,2),
    wisconsin_ytd numeric(14,2),
    wyoming_ytd numeric(14,2),
    puerto_rico_ytd numeric(14,2),
    guam_ytd numeric(14,2),
    virgin_islands_ytd numeric(14,2),
    ttl_ytd numeric(14,2),
    begin_image_num numeric(18,0),
    end_image_num numeric(18,0),
    receipt_dt date,
    load_date timestamp without time zone NOT NULL,
    expire_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE VIEW fec_f57_notice_vw AS
 SELECT f57.filer_cmte_id,
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
    f57.exp_purpose,
    f57.entity_tp,
    f57.entity_tp_desc,
    f57.catg_cd,
    f57.catg_cd_desc,
    f57.s_o_cand_id,
    f57.s_o_cand_l_nm,
    f57.s_o_cand_f_nm,
    f57.s_o_cand_m_nm,
    f57.s_o_cand_prefix,
    f57.s_o_cand_suffix,
    f57.s_o_cand_nm,
    f57.s_o_cand_office,
    f57.s_o_cand_office_desc,
    f57.s_o_cand_office_st,
    f57.s_o_cand_office_state_desc,
    f57.s_o_cand_office_district,
    f57.s_o_ind,
    f57.s_o_ind_desc,
    f57.election_tp,
    f57.fec_election_tp_desc,
    f57.fec_election_yr,
    f57.election_tp_desc,
    f57.cal_ytd_ofc_sought,
    f57.exp_dt,
    f57.exp_amt,
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
            WHEN ("substring"(((f57.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f57.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'F5'::character varying(8) AS filing_form,
    'SE-F57'::character varying(8) AS schedule_type,
    f57.form_tp_desc AS schedule_type_desc,
    f57.image_num,
    f57.file_num,
    f57.sub_id,
    f57.link_id,
    f57.orig_sub_id,
    f5.rpt_yr,
    f5.rpt_tp,
    (f5.rpt_yr + mod(f5.rpt_yr, (2)::numeric)) AS cycle
   FROM disclosure.nml_form_57 f57,
    disclosure.nml_form_5 f5
  WHERE ((f57.link_id = f5.sub_id) AND ((f5.rpt_tp)::text = ANY (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])) AND ((f57.amndt_ind)::text <> 'D'::text) AND (f57.delete_ind IS NULL) AND (f5.delete_ind IS NULL));


CREATE TABLE fec_fitem_f57_queue_new (
    filer_cmte_id character varying(9),
    pye_nm character varying(200),
    pye_l_nm character varying(30),
    pye_f_nm character varying(20),
    pye_m_nm character varying(20),
    pye_prefix character varying(10),
    pye_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_purpose character varying(100),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    s_o_cand_id character varying(9),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_state_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(20),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    cal_ytd_ofc_sought numeric(14,2),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    link_id numeric(19,0),
    image_num character varying(18),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0),
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0)
);


CREATE TABLE fec_vsum_f57 (
    filer_cmte_id character varying(9),
    pye_nm character varying(200),
    pye_l_nm character varying(30),
    pye_f_nm character varying(20),
    pye_m_nm character varying(20),
    pye_prefix character varying(10),
    pye_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_purpose character varying(100),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    s_o_cand_id character varying(9),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_state_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(20),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    cal_ytd_ofc_sought numeric(14,2),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    link_id numeric(19,0),
    image_num character varying(18),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0)
);


CREATE VIEW fec_fitem_f57_vw AS
 SELECT fec_vsum_f57.filer_cmte_id,
    fec_vsum_f57.pye_nm,
    fec_vsum_f57.pye_l_nm,
    fec_vsum_f57.pye_f_nm,
    fec_vsum_f57.pye_m_nm,
    fec_vsum_f57.pye_prefix,
    fec_vsum_f57.pye_suffix,
    fec_vsum_f57.pye_st1,
    fec_vsum_f57.pye_st2,
    fec_vsum_f57.pye_city,
    fec_vsum_f57.pye_st,
    fec_vsum_f57.pye_zip,
    fec_vsum_f57.exp_purpose,
    fec_vsum_f57.entity_tp,
    fec_vsum_f57.entity_tp_desc,
    fec_vsum_f57.catg_cd,
    fec_vsum_f57.catg_cd_desc,
    fec_vsum_f57.s_o_cand_id,
    fec_vsum_f57.s_o_cand_l_nm,
    fec_vsum_f57.s_o_cand_f_nm,
    fec_vsum_f57.s_o_cand_m_nm,
    fec_vsum_f57.s_o_cand_prefix,
    fec_vsum_f57.s_o_cand_suffix,
    fec_vsum_f57.s_o_cand_nm,
    fec_vsum_f57.s_o_cand_office,
    fec_vsum_f57.s_o_cand_office_desc,
    fec_vsum_f57.s_o_cand_office_st,
    fec_vsum_f57.s_o_cand_office_state_desc,
    fec_vsum_f57.s_o_cand_office_district,
    fec_vsum_f57.s_o_ind,
    fec_vsum_f57.s_o_ind_desc,
    fec_vsum_f57.election_tp,
    fec_vsum_f57.fec_election_tp_desc,
    fec_vsum_f57.fec_election_yr,
    fec_vsum_f57.election_tp_desc,
    fec_vsum_f57.cal_ytd_ofc_sought,
    fec_vsum_f57.exp_dt,
    fec_vsum_f57.exp_amt,
    fec_vsum_f57.exp_tp,
    fec_vsum_f57.exp_tp_desc,
    fec_vsum_f57.conduit_cmte_id,
    fec_vsum_f57.conduit_cmte_nm,
    fec_vsum_f57.conduit_cmte_st1,
    fec_vsum_f57.conduit_cmte_st2,
    fec_vsum_f57.conduit_cmte_city,
    fec_vsum_f57.conduit_cmte_st,
    fec_vsum_f57.conduit_cmte_zip,
    fec_vsum_f57.action_cd,
    fec_vsum_f57.action_cd_desc,
    fec_vsum_f57.tran_id,
    fec_vsum_f57.schedule_type,
    fec_vsum_f57.schedule_type_desc,
    fec_vsum_f57.link_id,
    fec_vsum_f57.image_num,
    fec_vsum_f57.file_num,
    fec_vsum_f57.orig_sub_id,
    fec_vsum_f57.sub_id,
    fec_vsum_f57.filing_form,
    fec_vsum_f57.rpt_tp,
    fec_vsum_f57.rpt_yr,
    fec_vsum_f57.election_cycle
   FROM fec_vsum_f57;


CREATE TABLE fec_vsum_f76 (
    org_id character varying(9),
    communication_tp character varying(2),
    communication_tp_desc character varying(40),
    communication_class character varying(1),
    communication_class_desc character varying(90),
    communication_dt timestamp without time zone,
    s_o_ind character varying(3),
    s_o_ind_desc character varying(90),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_rpt_pgi character varying(5),
    s_o_rpt_pgi_desc character varying(10),
    communication_cost numeric(14,2),
    election_other_desc character varying(20),
    transaction_tp character varying(3),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE VIEW fec_fitem_f76_vw AS
 SELECT fec_vsum_f76.org_id,
    fec_vsum_f76.communication_tp,
    fec_vsum_f76.communication_tp_desc,
    fec_vsum_f76.communication_class,
    fec_vsum_f76.communication_class_desc,
    fec_vsum_f76.communication_dt,
    fec_vsum_f76.s_o_ind,
    fec_vsum_f76.s_o_ind_desc,
    fec_vsum_f76.s_o_cand_id,
    fec_vsum_f76.s_o_cand_nm,
    fec_vsum_f76.s_o_cand_l_nm,
    fec_vsum_f76.s_o_cand_f_nm,
    fec_vsum_f76.s_o_cand_m_nm,
    fec_vsum_f76.s_o_cand_prefix,
    fec_vsum_f76.s_o_cand_suffix,
    fec_vsum_f76.s_o_cand_office,
    fec_vsum_f76.s_o_cand_office_desc,
    fec_vsum_f76.s_o_cand_office_st,
    fec_vsum_f76.s_o_cand_office_st_desc,
    fec_vsum_f76.s_o_cand_office_district,
    fec_vsum_f76.s_o_rpt_pgi,
    fec_vsum_f76.s_o_rpt_pgi_desc,
    fec_vsum_f76.communication_cost,
    fec_vsum_f76.election_other_desc,
    fec_vsum_f76.transaction_tp,
    fec_vsum_f76.action_cd,
    fec_vsum_f76.action_cd_desc,
    fec_vsum_f76.tran_id,
    fec_vsum_f76.schedule_type,
    fec_vsum_f76.schedule_type_desc,
    fec_vsum_f76.image_num,
    fec_vsum_f76.file_num,
    fec_vsum_f76.link_id,
    fec_vsum_f76.orig_sub_id,
    fec_vsum_f76.sub_id,
    fec_vsum_f76.filing_form,
    fec_vsum_f76.rpt_tp,
    fec_vsum_f76.rpt_yr,
    fec_vsum_f76.election_cycle,
    fec_vsum_f76.pg_date
   FROM fec_vsum_f76;


CREATE VIEW fec_fitem_sched_a_vw AS
 SELECT sa.cmte_id,
    sa.cmte_nm,
    sa.contbr_id,
    sa.contbr_nm,
    sa.contbr_nm_first,
    sa.contbr_m_nm,
    sa.contbr_nm_last,
    sa.contbr_prefix,
    sa.contbr_suffix,
    sa.contbr_st1,
    sa.contbr_st2,
    sa.contbr_city,
    sa.contbr_st,
    sa.contbr_zip,
    sa.entity_tp,
    sa.entity_tp_desc,
    sa.contbr_employer,
    sa.contbr_occupation,
    sa.election_tp,
    sa.fec_election_tp_desc,
    sa.fec_election_yr,
    sa.election_tp_desc,
    sa.contb_aggregate_ytd,
    sa.contb_receipt_dt,
    sa.contb_receipt_amt,
    sa.receipt_tp,
    sa.receipt_tp_desc,
    sa.receipt_desc,
    sa.memo_cd,
    sa.memo_cd_desc,
    sa.memo_text,
    sa.cand_id,
    sa.cand_nm,
    sa.cand_nm_first,
    sa.cand_m_nm,
    sa.cand_nm_last,
    sa.cand_prefix,
    sa.cand_suffix,
    sa.cand_office,
    sa.cand_office_desc,
    sa.cand_office_st,
    sa.cand_office_st_desc,
    sa.cand_office_district,
    sa.conduit_cmte_id,
    sa.conduit_cmte_nm,
    sa.conduit_cmte_st1,
    sa.conduit_cmte_st2,
    sa.conduit_cmte_city,
    sa.conduit_cmte_st,
    sa.conduit_cmte_zip,
    sa.donor_cmte_nm,
    sa.national_cmte_nonfed_acct,
    sa.increased_limit,
    sa.amndt_ind AS action_cd,
    sa.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sa.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sa.tran_id
            ELSE NULL::character varying(32)
        END AS tran_id,
        CASE
            WHEN ("substring"(((sa.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sa.back_ref_tran_id
            ELSE NULL::character varying(32)
        END AS back_ref_tran_id,
    sa.back_ref_sched_nm,
    'SA'::character varying(8) AS schedule_type,
    sa.form_tp_desc AS schedule_type_desc,
    sa.line_num,
    sa.image_num,
    sa.file_num,
    sa.link_id,
    sa.orig_sub_id,
    sa.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    ((fi.rpt_yr + (fi.rpt_yr % (2)::numeric)))::numeric(4,0) AS election_cycle
   FROM disclosure.nml_sched_a sa,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((sa.sub_id = fi.sub_id) AND ((sa.amndt_ind)::text <> 'D'::text) AND (sa.delete_ind IS NULL));


CREATE VIEW fec_fitem_sched_b_vw AS
 SELECT sb.cmte_id,
    sb.recipient_cmte_id,
    sb.recipient_nm,
    sb.payee_l_nm,
    sb.payee_f_nm,
    sb.payee_m_nm,
    sb.payee_prefix,
    sb.payee_suffix,
    sb.payee_employer,
    sb.payee_occupation,
    sb.recipient_st1,
    sb.recipient_st2,
    sb.recipient_city,
    sb.recipient_st,
    sb.recipient_zip,
    sb.disb_desc,
    sb.catg_cd,
    sb.catg_cd_desc,
    sb.entity_tp,
    sb.entity_tp_desc,
    sb.election_tp,
    sb.fec_election_tp_desc,
    sb.fec_election_tp_year,
    sb.election_tp_desc,
    sb.cand_id,
    sb.cand_nm,
    sb.cand_nm_first,
    sb.cand_nm_last,
    sb.cand_m_nm,
    sb.cand_prefix,
    sb.cand_suffix,
    sb.cand_office,
    sb.cand_office_desc,
    sb.cand_office_st,
    sb.cand_office_st_desc,
    sb.cand_office_district,
    sb.disb_dt,
    sb.disb_amt,
    sb.memo_cd,
    sb.memo_cd_desc,
    sb.memo_text,
    sb.disb_tp,
    sb.disb_tp_desc,
    sb.conduit_cmte_nm,
    sb.conduit_cmte_st1,
    sb.conduit_cmte_st2,
    sb.conduit_cmte_city,
    sb.conduit_cmte_st,
    sb.conduit_cmte_zip,
    sb.national_cmte_nonfed_acct,
    sb.ref_disp_excess_flg,
    sb.comm_dt,
    sb.benef_cmte_nm,
    sb.semi_an_bundled_refund,
    sb.amndt_ind AS action_cd,
    sb.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sb.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sb.tran_id
            ELSE NULL::character varying(32)
        END AS tran_id,
        CASE
            WHEN ("substring"(((sb.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sb.back_ref_tran_id
            ELSE NULL::character varying(32)
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((sb.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sb.back_ref_sched_id
            ELSE NULL::character varying(8)
        END AS back_ref_sched_id,
    'SB'::character varying(8) AS schedule_type,
    sb.form_tp_desc AS schedule_type_desc,
    sb.line_num,
    sb.image_num,
    sb.file_num,
    sb.link_id,
    sb.orig_sub_id,
    sb.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    ((fi.rpt_yr + (fi.rpt_yr % (2)::numeric)))::numeric(4,0) AS election_cycle
   FROM disclosure.nml_sched_b sb,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((sb.sub_id = fi.sub_id) AND ((sb.amndt_ind)::text <> 'D'::text) AND (sb.delete_ind IS NULL));


CREATE TABLE fec_vsum_sched_c (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    loan_src_l_nm character varying(30),
    loan_src_f_nm character varying(20),
    loan_src_m_nm character varying(20),
    loan_src_prefix character varying(10),
    loan_src_suffix character varying(10),
    loan_src_nm character varying(200),
    loan_src_st1 character varying(34),
    loan_src_st2 character varying(34),
    loan_src_city character varying(30),
    loan_src_st character varying(2),
    loan_src_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_tp_year character varying(4),
    election_tp_desc character varying(20),
    orig_loan_amt numeric(14,2),
    pymt_to_dt numeric(14,2),
    loan_bal numeric(14,2),
    incurred_dt timestamp without time zone,
    due_dt_terms character varying(15),
    interest_rate_terms character varying(15),
    secured_ind character varying(1),
    sched_a_line_num character varying(3),
    pers_fund_yes_no character varying(1),
    memo_cd character varying(1),
    memo_text character varying(100),
    fec_cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_state_desc character varying(20),
    cand_office_district character varying(2),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    pg_date timestamp without time zone,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    loan_name tsvector,
    candidate_name_text tsvector,
    loan_source_name_text tsvector
);


CREATE VIEW fec_fitem_sched_c_vw AS
 SELECT fec_vsum_sched_c.cmte_id,
    fec_vsum_sched_c.cmte_nm,
    fec_vsum_sched_c.loan_src_l_nm,
    fec_vsum_sched_c.loan_src_f_nm,
    fec_vsum_sched_c.loan_src_m_nm,
    fec_vsum_sched_c.loan_src_prefix,
    fec_vsum_sched_c.loan_src_suffix,
    fec_vsum_sched_c.loan_src_nm,
    fec_vsum_sched_c.loan_src_st1,
    fec_vsum_sched_c.loan_src_st2,
    fec_vsum_sched_c.loan_src_city,
    fec_vsum_sched_c.loan_src_st,
    fec_vsum_sched_c.loan_src_zip,
    fec_vsum_sched_c.entity_tp,
    fec_vsum_sched_c.entity_tp_desc,
    fec_vsum_sched_c.election_tp,
    fec_vsum_sched_c.fec_election_tp_desc,
    fec_vsum_sched_c.fec_election_tp_year,
    fec_vsum_sched_c.election_tp_desc,
    fec_vsum_sched_c.orig_loan_amt,
    fec_vsum_sched_c.pymt_to_dt,
    fec_vsum_sched_c.loan_bal,
    fec_vsum_sched_c.incurred_dt,
    fec_vsum_sched_c.due_dt_terms,
    fec_vsum_sched_c.interest_rate_terms,
    fec_vsum_sched_c.secured_ind,
    fec_vsum_sched_c.sched_a_line_num,
    fec_vsum_sched_c.pers_fund_yes_no,
    fec_vsum_sched_c.memo_cd,
    fec_vsum_sched_c.memo_text,
    fec_vsum_sched_c.fec_cmte_id,
    fec_vsum_sched_c.cand_id,
    fec_vsum_sched_c.cand_nm,
    fec_vsum_sched_c.cand_nm_first,
    fec_vsum_sched_c.cand_nm_last,
    fec_vsum_sched_c.cand_m_nm,
    fec_vsum_sched_c.cand_prefix,
    fec_vsum_sched_c.cand_suffix,
    fec_vsum_sched_c.cand_office,
    fec_vsum_sched_c.cand_office_desc,
    fec_vsum_sched_c.cand_office_st,
    fec_vsum_sched_c.cand_office_state_desc,
    fec_vsum_sched_c.cand_office_district,
    fec_vsum_sched_c.action_cd,
    fec_vsum_sched_c.action_cd_desc,
    fec_vsum_sched_c.tran_id,
    fec_vsum_sched_c.schedule_type,
    fec_vsum_sched_c.schedule_type_desc,
    fec_vsum_sched_c.line_num,
    fec_vsum_sched_c.image_num,
    fec_vsum_sched_c.file_num,
    fec_vsum_sched_c.link_id,
    fec_vsum_sched_c.orig_sub_id,
    fec_vsum_sched_c.sub_id,
    fec_vsum_sched_c.filing_form,
    fec_vsum_sched_c.rpt_tp,
    fec_vsum_sched_c.rpt_yr,
    fec_vsum_sched_c.election_cycle,
    fec_vsum_sched_c.loan_name
   FROM fec_vsum_sched_c;


CREATE TABLE fec_vsum_sched_d (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cred_dbtr_id character varying(9),
    cred_dbtr_nm character varying(200),
    cred_dbtr_l_nm character varying(30),
    cred_dbtr_f_nm character varying(20),
    cred_dbtr_m_nm character varying(20),
    cred_dbtr_prefix character varying(10),
    cred_dbtr_suffix character varying(10),
    cred_dbtr_st1 character varying(34),
    cred_dbtr_st2 character varying(34),
    cred_dbtr_city character varying(30),
    cred_dbtr_st character varying(2),
    cred_dbtr_zip character varying(9),
    entity_tp character varying(3),
    nature_debt_purpose character varying(100),
    outstg_bal_bop numeric(14,2),
    amt_incurred_per numeric(14,2),
    pymt_per numeric(14,2),
    outstg_bal_cop numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone,
    creditor_debtor_name_text tsvector
);


CREATE VIEW fec_fitem_sched_d_vw AS
 SELECT fec_vsum_sched_d.cmte_id,
    fec_vsum_sched_d.cmte_nm,
    fec_vsum_sched_d.cred_dbtr_id,
    fec_vsum_sched_d.cred_dbtr_nm,
    fec_vsum_sched_d.cred_dbtr_l_nm,
    fec_vsum_sched_d.cred_dbtr_f_nm,
    fec_vsum_sched_d.cred_dbtr_m_nm,
    fec_vsum_sched_d.cred_dbtr_prefix,
    fec_vsum_sched_d.cred_dbtr_suffix,
    fec_vsum_sched_d.cred_dbtr_st1,
    fec_vsum_sched_d.cred_dbtr_st2,
    fec_vsum_sched_d.cred_dbtr_city,
    fec_vsum_sched_d.cred_dbtr_st,
    fec_vsum_sched_d.cred_dbtr_zip,
    fec_vsum_sched_d.creditor_debtor_name_text,
    fec_vsum_sched_d.entity_tp,
    fec_vsum_sched_d.nature_debt_purpose,
    fec_vsum_sched_d.outstg_bal_bop,
    fec_vsum_sched_d.amt_incurred_per,
    fec_vsum_sched_d.pymt_per,
    fec_vsum_sched_d.outstg_bal_cop,
    fec_vsum_sched_d.cand_id,
    fec_vsum_sched_d.cand_nm,
    fec_vsum_sched_d.cand_nm_first,
    fec_vsum_sched_d.cand_nm_last,
    fec_vsum_sched_d.cand_office,
    fec_vsum_sched_d.cand_office_st,
    fec_vsum_sched_d.cand_office_st_desc,
    fec_vsum_sched_d.cand_office_district,
    fec_vsum_sched_d.conduit_cmte_id,
    fec_vsum_sched_d.conduit_cmte_nm,
    fec_vsum_sched_d.conduit_cmte_st1,
    fec_vsum_sched_d.conduit_cmte_st2,
    fec_vsum_sched_d.conduit_cmte_city,
    fec_vsum_sched_d.conduit_cmte_st,
    fec_vsum_sched_d.conduit_cmte_zip,
    fec_vsum_sched_d.action_cd,
    fec_vsum_sched_d.action_cd_desc,
    fec_vsum_sched_d.tran_id,
    fec_vsum_sched_d.schedule_type,
    fec_vsum_sched_d.schedule_type_desc,
    fec_vsum_sched_d.line_num,
    fec_vsum_sched_d.image_num,
    fec_vsum_sched_d.file_num,
    fec_vsum_sched_d.link_id,
    fec_vsum_sched_d.orig_sub_id,
    fec_vsum_sched_d.sub_id,
    fec_vsum_sched_d.filing_form,
    fec_vsum_sched_d.rpt_yr,
    fec_vsum_sched_d.rpt_tp,
    fec_vsum_sched_d.election_cycle,
    fec_vsum_sched_d.pg_date
   FROM fec_vsum_sched_d;


CREATE TABLE fec_vsum_sched_e (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    pye_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    exp_desc character varying(100),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_nm_first character varying(38),
    s_o_cand_nm_last character varying(38),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    cal_ytd_ofc_sought numeric(14,2),
    dissem_dt timestamp without time zone,
    exp_amt numeric(14,2),
    exp_dt timestamp without time zone,
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    indt_sign_nm character varying(90),
    indt_sign_dt timestamp without time zone,
    notary_sign_nm character varying(90),
    notary_sign_dt timestamp without time zone,
    notary_commission_exprtn_dt timestamp without time zone,
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0)
);


CREATE VIEW fec_fitem_sched_e_vw AS
 SELECT fec_vsum_sched_e.cmte_id,
    fec_vsum_sched_e.cmte_nm,
    fec_vsum_sched_e.pye_nm,
    fec_vsum_sched_e.payee_l_nm,
    fec_vsum_sched_e.payee_f_nm,
    fec_vsum_sched_e.payee_m_nm,
    fec_vsum_sched_e.payee_prefix,
    fec_vsum_sched_e.payee_suffix,
    fec_vsum_sched_e.pye_st1,
    fec_vsum_sched_e.pye_st2,
    fec_vsum_sched_e.pye_city,
    fec_vsum_sched_e.pye_st,
    fec_vsum_sched_e.pye_zip,
    fec_vsum_sched_e.entity_tp,
    fec_vsum_sched_e.entity_tp_desc,
    fec_vsum_sched_e.exp_desc,
    fec_vsum_sched_e.catg_cd,
    fec_vsum_sched_e.catg_cd_desc,
    fec_vsum_sched_e.s_o_cand_id,
    fec_vsum_sched_e.s_o_cand_nm,
    fec_vsum_sched_e.s_o_cand_nm_first,
    fec_vsum_sched_e.s_o_cand_nm_last,
    fec_vsum_sched_e.s_o_cand_m_nm,
    fec_vsum_sched_e.s_o_cand_prefix,
    fec_vsum_sched_e.s_o_cand_suffix,
    fec_vsum_sched_e.s_o_cand_office,
    fec_vsum_sched_e.s_o_cand_office_desc,
    fec_vsum_sched_e.s_o_cand_office_st,
    fec_vsum_sched_e.s_o_cand_office_st_desc,
    fec_vsum_sched_e.s_o_cand_office_district,
    fec_vsum_sched_e.s_o_ind,
    fec_vsum_sched_e.s_o_ind_desc,
    fec_vsum_sched_e.election_tp,
    fec_vsum_sched_e.fec_election_tp_desc,
    fec_vsum_sched_e.cal_ytd_ofc_sought,
    fec_vsum_sched_e.dissem_dt,
    fec_vsum_sched_e.exp_amt,
    fec_vsum_sched_e.exp_dt,
    fec_vsum_sched_e.exp_tp,
    fec_vsum_sched_e.exp_tp_desc,
    fec_vsum_sched_e.memo_cd,
    fec_vsum_sched_e.memo_cd_desc,
    fec_vsum_sched_e.memo_text,
    fec_vsum_sched_e.conduit_cmte_id,
    fec_vsum_sched_e.conduit_cmte_nm,
    fec_vsum_sched_e.conduit_cmte_st1,
    fec_vsum_sched_e.conduit_cmte_st2,
    fec_vsum_sched_e.conduit_cmte_city,
    fec_vsum_sched_e.conduit_cmte_st,
    fec_vsum_sched_e.conduit_cmte_zip,
    fec_vsum_sched_e.indt_sign_nm,
    fec_vsum_sched_e.indt_sign_dt,
    fec_vsum_sched_e.notary_sign_nm,
    fec_vsum_sched_e.notary_sign_dt,
    fec_vsum_sched_e.notary_commission_exprtn_dt,
    fec_vsum_sched_e.filer_l_nm,
    fec_vsum_sched_e.filer_f_nm,
    fec_vsum_sched_e.filer_m_nm,
    fec_vsum_sched_e.filer_prefix,
    fec_vsum_sched_e.filer_suffix,
    fec_vsum_sched_e.action_cd,
    fec_vsum_sched_e.action_cd_desc,
    fec_vsum_sched_e.tran_id,
    fec_vsum_sched_e.back_ref_tran_id,
    fec_vsum_sched_e.back_ref_sched_nm,
    fec_vsum_sched_e.schedule_type,
    fec_vsum_sched_e.schedule_type_desc,
    fec_vsum_sched_e.line_num,
    fec_vsum_sched_e.image_num,
    fec_vsum_sched_e.file_num,
    fec_vsum_sched_e.link_id,
    fec_vsum_sched_e.orig_sub_id,
    fec_vsum_sched_e.sub_id,
    fec_vsum_sched_e.filing_form,
    fec_vsum_sched_e.rpt_tp,
    fec_vsum_sched_e.rpt_yr,
    fec_vsum_sched_e.election_cycle
   FROM fec_vsum_sched_e;


CREATE TABLE fec_fitem_sched_f_vw (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_desg_coord_exp_ind character varying(1),
    desg_cmte_id character varying(9),
    desg_cmte_nm character varying(200),
    subord_cmte_id character varying(9),
    subord_cmte_nm character varying(200),
    subord_cmte_st1 character varying(34),
    subord_cmte_st2 character varying(34),
    subord_cmte_city character varying(30),
    subord_cmte_st character varying(2),
    subord_cmte_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    pye_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    aggregate_gen_election_exp numeric(14,2),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    exp_purpose_desc character varying(100),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    unlimited_spending_flg character varying(1),
    unlimited_spending_flg_desc character varying(40),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0),
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone,
    payee_name_text tsvector
);


CREATE VIEW fec_sched_e_notice_vw AS
 SELECT se.cmte_id,
    se.cmte_nm,
    se.pye_nm,
    se.payee_l_nm,
    se.payee_f_nm,
    se.payee_m_nm,
    se.payee_prefix,
    se.payee_suffix,
    se.pye_st1,
    se.pye_st2,
    se.pye_city,
    se.pye_st,
    se.pye_zip,
    se.entity_tp,
    se.entity_tp_desc,
    se.exp_desc,
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
    se.s_o_ind,
    se.s_o_ind_desc,
    se.election_tp,
    se.fec_election_tp_desc,
    se.cal_ytd_ofc_sought,
    se.dissem_dt,
    se.exp_amt,
    se.exp_dt,
    se.exp_tp,
    se.exp_tp_desc,
    se.memo_cd,
    se.memo_cd_desc,
    se.memo_text,
    se.conduit_cmte_id,
    se.conduit_cmte_nm,
    se.conduit_cmte_st1,
    se.conduit_cmte_st2,
    se.conduit_cmte_city,
    se.conduit_cmte_st,
    se.conduit_cmte_zip,
    se.indt_sign_nm,
    se.indt_sign_dt,
    se.notary_sign_nm,
    se.notary_sign_dt,
    se.notary_commission_exprtn_dt,
    se.filer_l_nm,
    se.filer_f_nm,
    se.filer_m_nm,
    se.filer_prefix,
    se.filer_suffix,
    se.amndt_ind AS action_cd,
    se.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((se.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN se.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((se.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN se.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((se.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN se.back_ref_sched_nm
            ELSE NULL::character varying
        END AS back_ref_sched_nm,
    'SE'::character varying(8) AS schedule_type,
    se.form_tp_desc AS schedule_type_desc,
    se.line_num,
    se.image_num,
    se.file_num,
    se.link_id,
    se.orig_sub_id,
    se.sub_id,
    'F24'::character varying(8) AS filing_form,
    f24.rpt_tp,
    f24.rpt_yr,
    (f24.rpt_yr + mod(f24.rpt_yr, (2)::numeric)) AS cycle
   FROM disclosure.nml_sched_e se,
    disclosure.nml_form_24 f24
  WHERE ((se.link_id = f24.sub_id) AND (f24.delete_ind IS NULL) AND (se.delete_ind IS NULL) AND ((se.amndt_ind)::text <> 'D'::text));


CREATE TABLE fec_viewer_disable_trans_link (
    cand_cmte_id character varying(9),
    fec_election_yr numeric,
    dont_check_flg character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE fec_viewer_independent_exp (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0) NOT NULL,
    file_num numeric(7,0),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    rpt_receipt_dt timestamp without time zone,
    cmte_id character varying(9),
    image_num character varying(18),
    line_num character varying(12),
    form_tp_cd character varying(8),
    sched_tp_cd character varying(8),
    name character varying(200),
    first_name character varying(38),
    last_name character varying(38),
    street_1 character varying(34),
    street_2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip_code character varying(9),
    employer character varying(38),
    occupation character varying(38),
    transaction_dt timestamp without time zone,
    transaction_amt numeric(14,2),
    transaction_pgi character varying(5),
    transaction_tp character varying(3),
    purpose character varying(100),
    category character varying(3),
    category_desc character varying(40),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    communication_tp character varying(2),
    communication_class character varying(2),
    other_id character varying(9),
    cand_id character varying(9),
    support_oppose_ind character varying(3),
    conduit_cmte_id character varying(9),
    tran_id character varying(32),
    delete_ind numeric,
    last_update_dt timestamp without time zone,
    cand_name character varying(90),
    cmte_name character varying(200),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_f1 (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_email character varying(90),
    cmte_web_url character varying(90),
    cmte_fax character varying(12),
    cmte_nm_chg_flg character varying(1),
    cmte_addr_chg_flg character varying(1),
    cmte_email_chg_flg character varying(1),
    cmte_url_chg_flg character varying(1),
    filing_freq character varying(1),
    filing_freq_desc character varying(27),
    f3l_filing_freq character varying(1),
    filed_cmte_tp character varying(1),
    filed_cmte_tp_desc character varying(58),
    qual_dt timestamp without time zone,
    efiling_cmte_tp character varying(1),
    filed_cmte_dsgn character varying(1),
    filed_cmte_dsgn_desc character varying(90),
    jntfndrsg_cmte_flg character varying(1),
    org_tp character varying(1),
    org_tp_desc character varying(90),
    leadership_pac character varying(1),
    lobbyist_registrant_pac character varying(1),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_pty_tp character varying(3),
    cand_pty_tp_desc character varying(90),
    affiliated_cmte_id character varying(9),
    affiliated_cmte_nm character varying(200),
    affiliated_cmte_st1 character varying(34),
    affiliated_cmte_st2 character varying(34),
    affiliated_cmte_city character varying(30),
    affiliated_cmte_st character varying(2),
    affiliated_cmte_zip character varying(9),
    affiliated_cand_id character varying(9),
    affiliated_cand_l_nm character varying(30),
    affiliated_cand_f_nm character varying(20),
    affiliated_cand_m_nm character varying(20),
    affiliated_cand_prefix character varying(10),
    affiliated_cand_suffix character varying(10),
    cmte_rltshp character varying(38),
    affiliated_relationship_cd character varying(3),
    cust_rec_nm character varying(90),
    cust_rec_l_nm character varying(30),
    cust_rec_f_nm character varying(20),
    cust_rec_m_nm character varying(20),
    cust_rec_prefix character varying(10),
    cust_rec_suffix character varying(10),
    cust_rec_st1 character varying(34),
    cust_rec_st2 character varying(34),
    cust_rec_city character varying(30),
    cust_rec_st character varying(2),
    cust_rec_zip character varying(9),
    cust_rec_title character varying(20),
    cust_rec_ph_num character varying(10),
    tres_nm character varying(90),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    tres_st1 character varying(34),
    tres_st2 character varying(34),
    tres_city character varying(30),
    tres_st character varying(2),
    tres_zip character varying(9),
    tres_title character varying(20),
    tres_ph_num character varying(10),
    designated_agent_nm character varying(90),
    designated_agent_l_nm character varying(30),
    designated_agent_f_nm character varying(20),
    designated_agent_m_nm character varying(20),
    designated_agent_prefix character varying(10),
    designated_agent_suffix character varying(10),
    designated_agent_st1 character varying(34),
    designated_agent_st2 character varying(34),
    designated_agent_city character varying(30),
    designated_agent_st character varying(2),
    designated_agent_zip character varying(9),
    designated_agent_title character varying(20),
    designated_agent_ph_num character varying(10),
    bank_depository_nm character varying(200),
    bank_depository_st1 character varying(34),
    bank_depository_st2 character varying(34),
    bank_depository_city character varying(30),
    bank_depository_st character varying(2),
    bank_depository_zip character varying(9),
    sec_bank_depository_nm character varying(200),
    sec_bank_depository_st1 character varying(34),
    sec_bank_depository_st2 character varying(34),
    sec_bank_depository_city character varying(30),
    sec_bank_depository_st character varying(2),
    sec_bank_depository_zip character varying(10),
    tres_sign_nm character varying(90),
    sign_l_nm character varying(30),
    sign_f_nm character varying(20),
    sign_m_nm character varying(20),
    sign_prefix character varying(10),
    sign_suffix character varying(10),
    tres_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    sub_id numeric(19,0) NOT NULL,
    first_form_1 character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_f105 (
    filer_cmte_id character varying(9),
    exp_dt timestamp without time zone,
    election_tp character varying(5),
    election_tp_desc character varying(20),
    fec_election_tp_desc character varying(20),
    exp_amt numeric(14,2),
    loan_chk_flg character varying(1),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE VIEW fec_vsum_f1_vw AS
 SELECT fec_vsum_f1.cmte_id,
    fec_vsum_f1.cmte_nm,
    fec_vsum_f1.cmte_st1,
    fec_vsum_f1.cmte_st2,
    fec_vsum_f1.cmte_city,
    fec_vsum_f1.cmte_st,
    fec_vsum_f1.cmte_zip,
    fec_vsum_f1.cmte_email,
    fec_vsum_f1.cmte_web_url,
    fec_vsum_f1.cmte_fax,
    fec_vsum_f1.cmte_nm_chg_flg,
    fec_vsum_f1.cmte_addr_chg_flg,
    fec_vsum_f1.cmte_email_chg_flg,
    fec_vsum_f1.cmte_url_chg_flg,
    fec_vsum_f1.filing_freq,
    fec_vsum_f1.filing_freq_desc,
    fec_vsum_f1.f3l_filing_freq,
    fec_vsum_f1.filed_cmte_tp,
    fec_vsum_f1.filed_cmte_tp_desc,
    fec_vsum_f1.qual_dt,
    fec_vsum_f1.efiling_cmte_tp,
    fec_vsum_f1.filed_cmte_dsgn,
    fec_vsum_f1.filed_cmte_dsgn_desc,
    fec_vsum_f1.jntfndrsg_cmte_flg,
    fec_vsum_f1.org_tp,
    fec_vsum_f1.org_tp_desc,
    fec_vsum_f1.leadership_pac,
    fec_vsum_f1.lobbyist_registrant_pac,
    fec_vsum_f1.cand_id,
    fec_vsum_f1.cand_nm,
    fec_vsum_f1.cand_nm_first,
    fec_vsum_f1.cand_nm_last,
    fec_vsum_f1.cand_m_nm,
    fec_vsum_f1.cand_prefix,
    fec_vsum_f1.cand_suffix,
    fec_vsum_f1.cand_office,
    fec_vsum_f1.cand_office_desc,
    fec_vsum_f1.cand_office_st,
    fec_vsum_f1.cand_office_st_desc,
    fec_vsum_f1.cand_office_district,
    fec_vsum_f1.cand_pty_affiliation,
    fec_vsum_f1.cand_pty_affiliation_desc,
    fec_vsum_f1.cand_pty_tp,
    fec_vsum_f1.cand_pty_tp_desc,
    fec_vsum_f1.affiliated_cmte_id,
    fec_vsum_f1.affiliated_cmte_nm,
    fec_vsum_f1.affiliated_cmte_st1,
    fec_vsum_f1.affiliated_cmte_st2,
    fec_vsum_f1.affiliated_cmte_city,
    fec_vsum_f1.affiliated_cmte_st,
    fec_vsum_f1.affiliated_cmte_zip,
    fec_vsum_f1.affiliated_cand_id,
    fec_vsum_f1.affiliated_cand_l_nm,
    fec_vsum_f1.affiliated_cand_f_nm,
    fec_vsum_f1.affiliated_cand_m_nm,
    fec_vsum_f1.affiliated_cand_prefix,
    fec_vsum_f1.affiliated_cand_suffix,
    fec_vsum_f1.cmte_rltshp,
    fec_vsum_f1.affiliated_relationship_cd,
    fec_vsum_f1.cust_rec_nm,
    fec_vsum_f1.cust_rec_l_nm,
    fec_vsum_f1.cust_rec_f_nm,
    fec_vsum_f1.cust_rec_m_nm,
    fec_vsum_f1.cust_rec_prefix,
    fec_vsum_f1.cust_rec_suffix,
    fec_vsum_f1.cust_rec_st1,
    fec_vsum_f1.cust_rec_st2,
    fec_vsum_f1.cust_rec_city,
    fec_vsum_f1.cust_rec_st,
    fec_vsum_f1.cust_rec_zip,
    fec_vsum_f1.cust_rec_title,
    fec_vsum_f1.cust_rec_ph_num,
    fec_vsum_f1.tres_nm,
    fec_vsum_f1.tres_l_nm,
    fec_vsum_f1.tres_f_nm,
    fec_vsum_f1.tres_m_nm,
    fec_vsum_f1.tres_prefix,
    fec_vsum_f1.tres_suffix,
    fec_vsum_f1.tres_st1,
    fec_vsum_f1.tres_st2,
    fec_vsum_f1.tres_city,
    fec_vsum_f1.tres_st,
    fec_vsum_f1.tres_zip,
    fec_vsum_f1.tres_title,
    fec_vsum_f1.tres_ph_num,
    fec_vsum_f1.designated_agent_nm,
    fec_vsum_f1.designated_agent_l_nm,
    fec_vsum_f1.designated_agent_f_nm,
    fec_vsum_f1.designated_agent_m_nm,
    fec_vsum_f1.designated_agent_prefix,
    fec_vsum_f1.designated_agent_suffix,
    fec_vsum_f1.designated_agent_st1,
    fec_vsum_f1.designated_agent_st2,
    fec_vsum_f1.designated_agent_city,
    fec_vsum_f1.designated_agent_st,
    fec_vsum_f1.designated_agent_zip,
    fec_vsum_f1.designated_agent_title,
    fec_vsum_f1.designated_agent_ph_num,
    fec_vsum_f1.bank_depository_nm,
    fec_vsum_f1.bank_depository_st1,
    fec_vsum_f1.bank_depository_st2,
    fec_vsum_f1.bank_depository_city,
    fec_vsum_f1.bank_depository_st,
    fec_vsum_f1.bank_depository_zip,
    fec_vsum_f1.sec_bank_depository_nm,
    fec_vsum_f1.sec_bank_depository_st1,
    fec_vsum_f1.sec_bank_depository_st2,
    fec_vsum_f1.sec_bank_depository_city,
    fec_vsum_f1.sec_bank_depository_st,
    fec_vsum_f1.sec_bank_depository_zip,
    fec_vsum_f1.tres_sign_nm,
    fec_vsum_f1.sign_l_nm,
    fec_vsum_f1.sign_f_nm,
    fec_vsum_f1.sign_m_nm,
    fec_vsum_f1.sign_prefix,
    fec_vsum_f1.sign_suffix,
    fec_vsum_f1.tres_sign_dt,
    fec_vsum_f1.receipt_dt,
    fec_vsum_f1.rpt_yr,
    fec_vsum_f1.election_cycle,
    fec_vsum_f1.file_num,
    fec_vsum_f1.prev_file_num,
    fec_vsum_f1.mst_rct_file_num,
    fec_vsum_f1.begin_image_num,
    fec_vsum_f1.end_image_num,
    fec_vsum_f1.form_tp,
    fec_vsum_f1.form_tp_desc,
    fec_vsum_f1.amndt_ind,
    fec_vsum_f1.amndt_ind_desc,
    fec_vsum_f1.sub_id,
    fec_vsum_f1.first_form_1,
    fec_vsum_f1.pg_date
   FROM fec_vsum_f1;


CREATE TABLE fec_vsum_f2 (
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_st character varying(2),
    cand_zip character varying(9),
    addr_chg_flg character varying(1),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_desc character varying(50),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    election_yr numeric(4,0),
    pcc_cmte_id character varying(9),
    pcc_cmte_nm character varying(200),
    pcc_cmte_st1 character varying(34),
    pcc_cmte_st2 character varying(34),
    pcc_cmte_city character varying(30),
    pcc_cmte_st character varying(2),
    pcc_cmte_zip character varying(9),
    addl_auth_cmte_id character varying(9),
    addl_auth_cmte_nm character varying(200),
    addl_auth_cmte_st1 character varying(34),
    addl_auth_cmte_st2 character varying(34),
    addl_auth_cmte_city character varying(30),
    addl_auth_cmte_st character varying(2),
    addl_auth_cmte_zip character varying(9),
    cand_sign_nm character varying(90),
    cand_sign_l_nm character varying(30),
    cand_sign_f_nm character varying(20),
    cand_sign_m_nm character varying(20),
    cand_sign_prefix character varying(10),
    cand_sign_suffix character varying(10),
    cand_sign_dt timestamp without time zone,
    party_cd character varying(1),
    party_cd_desc character varying(33),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cand_ici character varying(1),
    cand_ici_desc character varying(15),
    cand_status character varying(1),
    cand_status_desc character varying(40),
    prim_pers_funds_decl numeric(14,2),
    gen_pers_funds_decl numeric(14,2),
    receipt_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    sub_id numeric(19,0) NOT NULL,
    first_form_2 character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_f3 (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    cmte_election_st character varying(2),
    cmte_election_st_desc character varying(20),
    cmte_election_district character varying(2),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(5),
    rpt_pgi_desc character varying(10),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    receipt_dt timestamp without time zone,
    election_cycle numeric(4,0),
    tres_sign_nm character varying(90),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    tres_sign_dt timestamp without time zone,
    ttl_contb_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    net_contb_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    net_op_exp_per numeric(14,2),
    coh_cop_line_8 numeric(14,2),
    coh_cop numeric,
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    ttl_indv_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_column_ttl_per numeric(14,2),
    tranf_from_other_auth_cmte_per numeric(14,2),
    loans_made_by_cand_per numeric(14,2),
    all_other_loans_per numeric(14,2),
    ttl_loans_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    ttl_receipts_line_16 numeric(14,2),
    ttl_receipts_per numeric,
    op_exp_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    loan_repymts_cand_loans_per numeric(14,2),
    loan_repymts_other_loans_per numeric(14,2),
    ttl_loan_repymts_per numeric(14,2),
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    ttl_contb_ref_col_ttl_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_line_22 numeric(14,2),
    ttl_disb_per numeric,
    coh_bop numeric(14,2),
    ttl_receipts_line_24 numeric(14,2),
    subttl_per numeric(14,2),
    ttl_disb_line_26 numeric(14,2),
    coh_cop_line_27 numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd numeric(14,2),
    net_contb_ytd numeric(14,2),
    ttl_op_exp_ytd numeric(14,2),
    ttl_offsets_to_op_exp_ytd numeric(14,2),
    net_op_exp_ytd numeric(14,2),
    ttl_indv_item_contb_ytd numeric(14,2),
    ttl_indv_unitem_contb_ytd numeric(14,2),
    ttl_indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd numeric(14,2),
    other_pol_cmte_contb_ytd numeric(14,2),
    cand_contb_ytd numeric(14,2),
    ttl_contb_col_ttl_ytd numeric(14,2),
    tranf_from_other_auth_cmte_ytd numeric(14,2),
    loans_made_by_cand_ytd numeric(14,2),
    all_other_loans_ytd numeric(14,2),
    ttl_loans_ytd numeric(14,2),
    offsets_to_op_exp_ytd numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    op_exp_ytd numeric(14,2),
    tranf_to_other_auth_cmte_ytd numeric(14,2),
    loan_repymts_cand_loans_ytd numeric(14,2),
    loan_repymts_other_loans_ytd numeric(14,2),
    ttl_loan_repymts_ytd numeric(14,2),
    ref_indv_contb_ytd numeric(14,2),
    ref_pol_pty_cmte_contb_ytd numeric(14,2),
    ref_other_pol_cmte_contb_ytd numeric(14,2),
    ref_ttl_contb_col_ttl_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    grs_rcpt_auth_cmte_prim numeric(14,2),
    agr_amt_contrib_pers_fund_prim numeric(14,2),
    grs_rcpt_min_pers_contrib_prim numeric(14,2),
    grs_rcpt_auth_cmte_gen numeric(14,2),
    agr_amt_pers_contrib_gen numeric(14,2),
    grs_rcpt_min_pers_contrib_gen numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(90),
    f3z1_rpt_tp character varying(3),
    f3z1_rpt_tp_desc character varying(30),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    sub_id numeric(19,0) NOT NULL,
    most_recent_filing_flag character varying(1),
    pg_date timestamp without time zone
);


CREATE VIEW fec_vsum_f3_vw AS
 SELECT fec_vsum_f3.cmte_id,
    fec_vsum_f3.cmte_nm,
    fec_vsum_f3.cmte_st1,
    fec_vsum_f3.cmte_st2,
    fec_vsum_f3.cmte_city,
    fec_vsum_f3.cmte_st,
    fec_vsum_f3.cmte_zip,
    fec_vsum_f3.cmte_addr_chg_flg,
    fec_vsum_f3.cmte_election_st,
    fec_vsum_f3.cmte_election_st_desc,
    fec_vsum_f3.cmte_election_district,
    fec_vsum_f3.amndt_ind,
    fec_vsum_f3.amndt_ind_desc,
    fec_vsum_f3.rpt_tp,
    fec_vsum_f3.rpt_tp_desc,
    fec_vsum_f3.rpt_pgi,
    fec_vsum_f3.rpt_pgi_desc,
    fec_vsum_f3.election_dt,
    fec_vsum_f3.election_st,
    fec_vsum_f3.election_st_desc,
    fec_vsum_f3.cvg_start_dt,
    fec_vsum_f3.cvg_end_dt,
    fec_vsum_f3.rpt_yr,
    fec_vsum_f3.receipt_dt,
    fec_vsum_f3.election_cycle,
    fec_vsum_f3.tres_sign_nm,
    fec_vsum_f3.tres_l_nm,
    fec_vsum_f3.tres_f_nm,
    fec_vsum_f3.tres_m_nm,
    fec_vsum_f3.tres_prefix,
    fec_vsum_f3.tres_suffix,
    fec_vsum_f3.tres_sign_dt,
    fec_vsum_f3.ttl_contb_per,
    fec_vsum_f3.ttl_contb_ref_per,
    fec_vsum_f3.net_contb_per,
    fec_vsum_f3.ttl_op_exp_per,
    fec_vsum_f3.ttl_offsets_to_op_exp_per,
    fec_vsum_f3.net_op_exp_per,
    fec_vsum_f3.coh_cop_line_8,
    fec_vsum_f3.coh_cop,
    fec_vsum_f3.debts_owed_to_cmte,
    fec_vsum_f3.debts_owed_by_cmte,
    fec_vsum_f3.indv_item_contb_per,
    fec_vsum_f3.indv_unitem_contb_per,
    fec_vsum_f3.ttl_indv_contb_per,
    fec_vsum_f3.pol_pty_cmte_contb_per,
    fec_vsum_f3.other_pol_cmte_contb_per,
    fec_vsum_f3.cand_contb_per,
    fec_vsum_f3.ttl_contb_column_ttl_per,
    fec_vsum_f3.tranf_from_other_auth_cmte_per,
    fec_vsum_f3.loans_made_by_cand_per,
    fec_vsum_f3.all_other_loans_per,
    fec_vsum_f3.ttl_loans_per,
    fec_vsum_f3.offsets_to_op_exp_per,
    fec_vsum_f3.other_receipts_per,
    fec_vsum_f3.ttl_receipts_line_16,
    fec_vsum_f3.ttl_receipts_per,
    fec_vsum_f3.op_exp_per,
    fec_vsum_f3.tranf_to_other_auth_cmte_per,
    fec_vsum_f3.loan_repymts_cand_loans_per,
    fec_vsum_f3.loan_repymts_other_loans_per,
    fec_vsum_f3.ttl_loan_repymts_per,
    fec_vsum_f3.ref_indv_contb_per,
    fec_vsum_f3.ref_pol_pty_cmte_contb_per,
    fec_vsum_f3.ref_other_pol_cmte_contb_per,
    fec_vsum_f3.ttl_contb_ref_col_ttl_per,
    fec_vsum_f3.other_disb_per,
    fec_vsum_f3.ttl_disb_line_22,
    fec_vsum_f3.ttl_disb_per,
    fec_vsum_f3.coh_bop,
    fec_vsum_f3.ttl_receipts_line_24,
    fec_vsum_f3.subttl_per,
    fec_vsum_f3.ttl_disb_line_26,
    fec_vsum_f3.coh_cop_line_27,
    fec_vsum_f3.ttl_contb_ytd,
    fec_vsum_f3.ttl_contb_ref_ytd,
    fec_vsum_f3.net_contb_ytd,
    fec_vsum_f3.ttl_op_exp_ytd,
    fec_vsum_f3.ttl_offsets_to_op_exp_ytd,
    fec_vsum_f3.net_op_exp_ytd,
    fec_vsum_f3.ttl_indv_item_contb_ytd,
    fec_vsum_f3.ttl_indv_unitem_contb_ytd,
    fec_vsum_f3.ttl_indv_contb_ytd,
    fec_vsum_f3.pol_pty_cmte_contb_ytd,
    fec_vsum_f3.other_pol_cmte_contb_ytd,
    fec_vsum_f3.cand_contb_ytd,
    fec_vsum_f3.ttl_contb_col_ttl_ytd,
    fec_vsum_f3.tranf_from_other_auth_cmte_ytd,
    fec_vsum_f3.loans_made_by_cand_ytd,
    fec_vsum_f3.all_other_loans_ytd,
    fec_vsum_f3.ttl_loans_ytd,
    fec_vsum_f3.offsets_to_op_exp_ytd,
    fec_vsum_f3.other_receipts_ytd,
    fec_vsum_f3.ttl_receipts_ytd,
    fec_vsum_f3.op_exp_ytd,
    fec_vsum_f3.tranf_to_other_auth_cmte_ytd,
    fec_vsum_f3.loan_repymts_cand_loans_ytd,
    fec_vsum_f3.loan_repymts_other_loans_ytd,
    fec_vsum_f3.ttl_loan_repymts_ytd,
    fec_vsum_f3.ref_indv_contb_ytd,
    fec_vsum_f3.ref_pol_pty_cmte_contb_ytd,
    fec_vsum_f3.ref_other_pol_cmte_contb_ytd,
    fec_vsum_f3.ref_ttl_contb_col_ttl_ytd,
    fec_vsum_f3.other_disb_ytd,
    fec_vsum_f3.ttl_disb_ytd,
    fec_vsum_f3.grs_rcpt_auth_cmte_prim,
    fec_vsum_f3.agr_amt_contrib_pers_fund_prim,
    fec_vsum_f3.grs_rcpt_min_pers_contrib_prim,
    fec_vsum_f3.grs_rcpt_auth_cmte_gen,
    fec_vsum_f3.agr_amt_pers_contrib_gen,
    fec_vsum_f3.grs_rcpt_min_pers_contrib_gen,
    fec_vsum_f3.cand_id,
    fec_vsum_f3.cand_nm,
    fec_vsum_f3.f3z1_rpt_tp,
    fec_vsum_f3.f3z1_rpt_tp_desc,
    fec_vsum_f3.begin_image_num,
    fec_vsum_f3.end_image_num,
    fec_vsum_f3.form_tp,
    fec_vsum_f3.form_tp_desc,
    fec_vsum_f3.file_num,
    fec_vsum_f3.prev_file_num,
    fec_vsum_f3.mst_rct_file_num,
    fec_vsum_f3.sub_id,
    fec_vsum_f3.most_recent_filing_flag,
    fec_vsum_f3.pg_date
   FROM fec_vsum_f3;


CREATE TABLE fec_vsum_f3p (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    addr_chg_flg character varying(1),
    activity_primary character varying(1),
    activity_general character varying(1),
    term_rpt_flag character varying(1),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(5),
    rpt_pgi_desc character varying(10),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    receipt_dt timestamp without time zone,
    election_cycle numeric(4,0),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    coh_bop numeric(14,2),
    ttl_receipts_per numeric,
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_per numeric,
    ttl_disb_sum_page_per numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    ttl_indiv_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    ttl_receipts_per_line_22 numeric(14,2),
    op_exp_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    fndrsg_disb_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per_line_30 numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    alabama_per numeric(14,2),
    alaska_per numeric(14,2),
    arizona_per numeric(14,2),
    arkansas_per numeric(14,2),
    california_per numeric(14,2),
    colorado_per numeric(14,2),
    connecticut_per numeric(14,2),
    delaware_per numeric(14,2),
    district_columbia_per numeric(14,2),
    florida_per numeric(14,2),
    georgia_per numeric(14,2),
    hawaii_per numeric(14,2),
    idaho_per numeric(14,2),
    illinois_per numeric(14,2),
    indiana_per numeric(14,2),
    iowa_per numeric(14,2),
    kansas_per numeric(14,2),
    kentucky_per numeric(14,2),
    louisiana_per numeric(14,2),
    maine_per numeric(14,2),
    maryland_per numeric(14,2),
    massachusetts_per numeric(14,2),
    michigan_per numeric(14,2),
    minnesota_per numeric(14,2),
    mississippi_per numeric(14,2),
    missouri_per numeric(14,2),
    montana_per numeric(14,2),
    nebraska_per numeric(14,2),
    nevada_per numeric(14,2),
    new_hampshire_per numeric(14,2),
    new_jersey_per numeric(14,2),
    new_mexico_per numeric(14,2),
    new_york_per numeric(14,2),
    north_carolina_per numeric(14,2),
    north_dakota_per numeric(14,2),
    ohio_per numeric(14,2),
    oklahoma_per numeric(14,2),
    oregon_per numeric(14,2),
    pennsylvania_per numeric(14,2),
    rhode_island_per numeric(14,2),
    south_carolina_per numeric(14,2),
    south_dakota_per numeric(14,2),
    tennessee_per numeric(14,2),
    texas_per numeric(14,2),
    utah_per numeric(14,2),
    vermont_per numeric(14,2),
    virginia_per numeric(14,2),
    washington_per numeric(14,2),
    west_virginia_per numeric(14,2),
    wisconsin_per numeric(14,2),
    wyoming_per numeric(14,2),
    puerto_rico_per numeric(14,2),
    guam_per numeric(14,2),
    virgin_islands_per numeric(14,2),
    ttl_per numeric(14,2),
    fed_funds_ytd numeric(14,2),
    indv_item_contb_ytd numeric(14,2),
    indv_unitem_contb_ytd numeric(14,2),
    indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd numeric(14,2),
    other_pol_cmte_contb_ytd numeric(14,2),
    cand_contb_ytd numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    tranf_from_affiliated_cmte_ytd numeric(14,2),
    loans_received_from_cand_ytd numeric(14,2),
    other_loans_received_ytd numeric(14,2),
    ttl_loans_received_ytd numeric(14,2),
    offsets_to_op_exp_ytd numeric(14,2),
    offsets_to_fndrsg_exp_ytd numeric(14,2),
    offsets_to_legal_acctg_ytd numeric(14,2),
    ttl_offsets_to_op_exp_ytd numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    op_exp_ytd numeric(14,2),
    tranf_to_other_auth_cmte_ytd numeric(14,2),
    fndrsg_disb_ytd numeric(14,2),
    exempt_legal_acctg_disb_ytd numeric(14,2),
    repymts_loans_made_cand_ytd numeric(14,2),
    repymts_other_loans_ytd numeric(14,2),
    ttl_loan_repymts_made_ytd numeric(14,2),
    ref_indv_contb_ytd numeric(14,2),
    ref_pol_pty_cmte_contb_ytd numeric(14,2),
    ref_other_pol_cmte_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    alabama_ytd numeric(14,2),
    alaska_ytd numeric(14,2),
    arizona_ytd numeric(14,2),
    arkansas_ytd numeric(14,2),
    california_ytd numeric(14,2),
    colorado_ytd numeric(14,2),
    connecticut_ytd numeric(14,2),
    delaware_ytd numeric(14,2),
    district_columbia_ytd numeric(14,2),
    florida_ytd numeric(14,2),
    georgia_ytd numeric(14,2),
    hawaii_ytd numeric(14,2),
    idaho_ytd numeric(14,2),
    illinois_ytd numeric(14,2),
    indiana_ytd numeric(14,2),
    iowa_ytd numeric(14,2),
    kansas_ytd numeric(14,2),
    kentucky_ytd numeric(14,2),
    louisiana_ytd numeric(14,2),
    maine_ytd numeric(14,2),
    maryland_ytd numeric(14,2),
    massachusetts_ytd numeric(14,2),
    michigan_ytd numeric(14,2),
    minnesota_ytd numeric(14,2),
    mississippi_ytd numeric(14,2),
    missouri_ytd numeric(14,2),
    montana_ytd numeric(14,2),
    nebraska_ytd numeric(14,2),
    nevada_ytd numeric(14,2),
    new_hampshire_ytd numeric(14,2),
    new_jersey_ytd numeric(14,2),
    new_mexico_ytd numeric(14,2),
    new_york_ytd numeric(14,2),
    north_carolina_ytd numeric(14,2),
    north_dakota_ytd numeric(14,2),
    ohio_ytd numeric(14,2),
    oklahoma_ytd numeric(14,2),
    oregon_ytd numeric(14,2),
    pennsylvania_ytd numeric(14,2),
    rhode_island_ytd numeric(14,2),
    south_carolina_ytd numeric(14,2),
    south_dakota_ytd numeric(14,2),
    tennessee_ytd numeric(14,2),
    texas_ytd numeric(14,2),
    utah_ytd numeric(14,2),
    vermont_ytd numeric(14,2),
    virginia_ytd numeric(14,2),
    washington_ytd numeric(14,2),
    west_virginia_ytd numeric(14,2),
    wisconsin_ytd numeric(14,2),
    wyoming_ytd numeric(14,2),
    puerto_rico_ytd numeric(14,2),
    guam_ytd numeric(14,2),
    virgin_islands_ytd numeric(14,2),
    ttl_ytd numeric(14,2),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    sub_id numeric(19,0) NOT NULL,
    most_recent_filing_flag character varying(1),
    pg_date timestamp without time zone
);


CREATE VIEW fec_vsum_f3p_vw AS
 SELECT fec_vsum_f3p.cmte_id,
    fec_vsum_f3p.cmte_nm,
    fec_vsum_f3p.cmte_st1,
    fec_vsum_f3p.cmte_st2,
    fec_vsum_f3p.cmte_city,
    fec_vsum_f3p.cmte_st,
    fec_vsum_f3p.cmte_zip,
    fec_vsum_f3p.addr_chg_flg,
    fec_vsum_f3p.activity_primary,
    fec_vsum_f3p.activity_general,
    fec_vsum_f3p.term_rpt_flag,
    fec_vsum_f3p.amndt_ind,
    fec_vsum_f3p.amndt_ind_desc,
    fec_vsum_f3p.rpt_tp,
    fec_vsum_f3p.rpt_tp_desc,
    fec_vsum_f3p.rpt_pgi,
    fec_vsum_f3p.rpt_pgi_desc,
    fec_vsum_f3p.election_dt,
    fec_vsum_f3p.election_st,
    fec_vsum_f3p.election_st_desc,
    fec_vsum_f3p.cvg_start_dt,
    fec_vsum_f3p.cvg_end_dt,
    fec_vsum_f3p.rpt_yr,
    fec_vsum_f3p.receipt_dt,
    fec_vsum_f3p.election_cycle,
    fec_vsum_f3p.tres_sign_nm,
    fec_vsum_f3p.tres_sign_dt,
    fec_vsum_f3p.tres_l_nm,
    fec_vsum_f3p.tres_f_nm,
    fec_vsum_f3p.tres_m_nm,
    fec_vsum_f3p.tres_prefix,
    fec_vsum_f3p.tres_suffix,
    fec_vsum_f3p.coh_bop,
    fec_vsum_f3p.ttl_receipts_per,
    fec_vsum_f3p.ttl_receipts_sum_page_per,
    fec_vsum_f3p.subttl_sum_page_per,
    fec_vsum_f3p.ttl_disb_per,
    fec_vsum_f3p.ttl_disb_sum_page_per,
    fec_vsum_f3p.coh_cop,
    fec_vsum_f3p.debts_owed_to_cmte,
    fec_vsum_f3p.debts_owed_by_cmte,
    fec_vsum_f3p.exp_subject_limits,
    fec_vsum_f3p.net_contb_sum_page_per,
    fec_vsum_f3p.net_op_exp_sum_page_per,
    fec_vsum_f3p.fed_funds_per,
    fec_vsum_f3p.indv_item_contb_per,
    fec_vsum_f3p.indv_unitem_contb_per,
    fec_vsum_f3p.ttl_indiv_contb_per,
    fec_vsum_f3p.pol_pty_cmte_contb_per,
    fec_vsum_f3p.other_pol_cmte_contb_per,
    fec_vsum_f3p.cand_contb_per,
    fec_vsum_f3p.ttl_contb_per,
    fec_vsum_f3p.tranf_from_affilated_cmte_per,
    fec_vsum_f3p.loans_received_from_cand_per,
    fec_vsum_f3p.other_loans_received_per,
    fec_vsum_f3p.ttl_loans_received_per,
    fec_vsum_f3p.offsets_to_op_exp_per,
    fec_vsum_f3p.offsets_to_fndrsg_exp_per,
    fec_vsum_f3p.offsets_to_legal_acctg_per,
    fec_vsum_f3p.ttl_offsets_to_op_exp_per,
    fec_vsum_f3p.other_receipts_per,
    fec_vsum_f3p.ttl_receipts_per_line_22,
    fec_vsum_f3p.op_exp_per,
    fec_vsum_f3p.tranf_to_other_auth_cmte_per,
    fec_vsum_f3p.fndrsg_disb_per,
    fec_vsum_f3p.exempt_legal_acctg_disb_per,
    fec_vsum_f3p.repymts_loans_made_by_cand_per,
    fec_vsum_f3p.repymts_other_loans_per,
    fec_vsum_f3p.ttl_loan_repymts_made_per,
    fec_vsum_f3p.ref_indv_contb_per,
    fec_vsum_f3p.ref_pol_pty_cmte_contb_per,
    fec_vsum_f3p.ref_other_pol_cmte_contb_per,
    fec_vsum_f3p.ttl_contb_ref_per,
    fec_vsum_f3p.other_disb_per,
    fec_vsum_f3p.ttl_disb_per_line_30,
    fec_vsum_f3p.items_on_hand_liquidated,
    fec_vsum_f3p.alabama_per,
    fec_vsum_f3p.alaska_per,
    fec_vsum_f3p.arizona_per,
    fec_vsum_f3p.arkansas_per,
    fec_vsum_f3p.california_per,
    fec_vsum_f3p.colorado_per,
    fec_vsum_f3p.connecticut_per,
    fec_vsum_f3p.delaware_per,
    fec_vsum_f3p.district_columbia_per,
    fec_vsum_f3p.florida_per,
    fec_vsum_f3p.georgia_per,
    fec_vsum_f3p.hawaii_per,
    fec_vsum_f3p.idaho_per,
    fec_vsum_f3p.illinois_per,
    fec_vsum_f3p.indiana_per,
    fec_vsum_f3p.iowa_per,
    fec_vsum_f3p.kansas_per,
    fec_vsum_f3p.kentucky_per,
    fec_vsum_f3p.louisiana_per,
    fec_vsum_f3p.maine_per,
    fec_vsum_f3p.maryland_per,
    fec_vsum_f3p.massachusetts_per,
    fec_vsum_f3p.michigan_per,
    fec_vsum_f3p.minnesota_per,
    fec_vsum_f3p.mississippi_per,
    fec_vsum_f3p.missouri_per,
    fec_vsum_f3p.montana_per,
    fec_vsum_f3p.nebraska_per,
    fec_vsum_f3p.nevada_per,
    fec_vsum_f3p.new_hampshire_per,
    fec_vsum_f3p.new_jersey_per,
    fec_vsum_f3p.new_mexico_per,
    fec_vsum_f3p.new_york_per,
    fec_vsum_f3p.north_carolina_per,
    fec_vsum_f3p.north_dakota_per,
    fec_vsum_f3p.ohio_per,
    fec_vsum_f3p.oklahoma_per,
    fec_vsum_f3p.oregon_per,
    fec_vsum_f3p.pennsylvania_per,
    fec_vsum_f3p.rhode_island_per,
    fec_vsum_f3p.south_carolina_per,
    fec_vsum_f3p.south_dakota_per,
    fec_vsum_f3p.tennessee_per,
    fec_vsum_f3p.texas_per,
    fec_vsum_f3p.utah_per,
    fec_vsum_f3p.vermont_per,
    fec_vsum_f3p.virginia_per,
    fec_vsum_f3p.washington_per,
    fec_vsum_f3p.west_virginia_per,
    fec_vsum_f3p.wisconsin_per,
    fec_vsum_f3p.wyoming_per,
    fec_vsum_f3p.puerto_rico_per,
    fec_vsum_f3p.guam_per,
    fec_vsum_f3p.virgin_islands_per,
    fec_vsum_f3p.ttl_per,
    fec_vsum_f3p.fed_funds_ytd,
    fec_vsum_f3p.indv_item_contb_ytd,
    fec_vsum_f3p.indv_unitem_contb_ytd,
    fec_vsum_f3p.indv_contb_ytd,
    fec_vsum_f3p.pol_pty_cmte_contb_ytd,
    fec_vsum_f3p.other_pol_cmte_contb_ytd,
    fec_vsum_f3p.cand_contb_ytd,
    fec_vsum_f3p.ttl_contb_ytd,
    fec_vsum_f3p.tranf_from_affiliated_cmte_ytd,
    fec_vsum_f3p.loans_received_from_cand_ytd,
    fec_vsum_f3p.other_loans_received_ytd,
    fec_vsum_f3p.ttl_loans_received_ytd,
    fec_vsum_f3p.offsets_to_op_exp_ytd,
    fec_vsum_f3p.offsets_to_fndrsg_exp_ytd,
    fec_vsum_f3p.offsets_to_legal_acctg_ytd,
    fec_vsum_f3p.ttl_offsets_to_op_exp_ytd,
    fec_vsum_f3p.other_receipts_ytd,
    fec_vsum_f3p.ttl_receipts_ytd,
    fec_vsum_f3p.op_exp_ytd,
    fec_vsum_f3p.tranf_to_other_auth_cmte_ytd,
    fec_vsum_f3p.fndrsg_disb_ytd,
    fec_vsum_f3p.exempt_legal_acctg_disb_ytd,
    fec_vsum_f3p.repymts_loans_made_cand_ytd,
    fec_vsum_f3p.repymts_other_loans_ytd,
    fec_vsum_f3p.ttl_loan_repymts_made_ytd,
    fec_vsum_f3p.ref_indv_contb_ytd,
    fec_vsum_f3p.ref_pol_pty_cmte_contb_ytd,
    fec_vsum_f3p.ref_other_pol_cmte_contb_ytd,
    fec_vsum_f3p.ttl_contb_ref_ytd,
    fec_vsum_f3p.other_disb_ytd,
    fec_vsum_f3p.ttl_disb_ytd,
    fec_vsum_f3p.alabama_ytd,
    fec_vsum_f3p.alaska_ytd,
    fec_vsum_f3p.arizona_ytd,
    fec_vsum_f3p.arkansas_ytd,
    fec_vsum_f3p.california_ytd,
    fec_vsum_f3p.colorado_ytd,
    fec_vsum_f3p.connecticut_ytd,
    fec_vsum_f3p.delaware_ytd,
    fec_vsum_f3p.district_columbia_ytd,
    fec_vsum_f3p.florida_ytd,
    fec_vsum_f3p.georgia_ytd,
    fec_vsum_f3p.hawaii_ytd,
    fec_vsum_f3p.idaho_ytd,
    fec_vsum_f3p.illinois_ytd,
    fec_vsum_f3p.indiana_ytd,
    fec_vsum_f3p.iowa_ytd,
    fec_vsum_f3p.kansas_ytd,
    fec_vsum_f3p.kentucky_ytd,
    fec_vsum_f3p.louisiana_ytd,
    fec_vsum_f3p.maine_ytd,
    fec_vsum_f3p.maryland_ytd,
    fec_vsum_f3p.massachusetts_ytd,
    fec_vsum_f3p.michigan_ytd,
    fec_vsum_f3p.minnesota_ytd,
    fec_vsum_f3p.mississippi_ytd,
    fec_vsum_f3p.missouri_ytd,
    fec_vsum_f3p.montana_ytd,
    fec_vsum_f3p.nebraska_ytd,
    fec_vsum_f3p.nevada_ytd,
    fec_vsum_f3p.new_hampshire_ytd,
    fec_vsum_f3p.new_jersey_ytd,
    fec_vsum_f3p.new_mexico_ytd,
    fec_vsum_f3p.new_york_ytd,
    fec_vsum_f3p.north_carolina_ytd,
    fec_vsum_f3p.north_dakota_ytd,
    fec_vsum_f3p.ohio_ytd,
    fec_vsum_f3p.oklahoma_ytd,
    fec_vsum_f3p.oregon_ytd,
    fec_vsum_f3p.pennsylvania_ytd,
    fec_vsum_f3p.rhode_island_ytd,
    fec_vsum_f3p.south_carolina_ytd,
    fec_vsum_f3p.south_dakota_ytd,
    fec_vsum_f3p.tennessee_ytd,
    fec_vsum_f3p.texas_ytd,
    fec_vsum_f3p.utah_ytd,
    fec_vsum_f3p.vermont_ytd,
    fec_vsum_f3p.virginia_ytd,
    fec_vsum_f3p.washington_ytd,
    fec_vsum_f3p.west_virginia_ytd,
    fec_vsum_f3p.wisconsin_ytd,
    fec_vsum_f3p.wyoming_ytd,
    fec_vsum_f3p.puerto_rico_ytd,
    fec_vsum_f3p.guam_ytd,
    fec_vsum_f3p.virgin_islands_ytd,
    fec_vsum_f3p.ttl_ytd,
    fec_vsum_f3p.begin_image_num,
    fec_vsum_f3p.end_image_num,
    fec_vsum_f3p.form_tp,
    fec_vsum_f3p.form_tp_desc,
    fec_vsum_f3p.file_num,
    fec_vsum_f3p.prev_file_num,
    fec_vsum_f3p.mst_rct_file_num,
    fec_vsum_f3p.sub_id,
    fec_vsum_f3p.most_recent_filing_flag,
    fec_vsum_f3p.pg_date
   FROM fec_vsum_f3p;


CREATE TABLE fec_vsum_f3ps (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    election_dt timestamp without time zone,
    day_after_election_dt timestamp without time zone,
    net_contb numeric(14,2),
    net_exp numeric(14,2),
    fed_funds numeric(14,2),
    indv_item_contb numeric(14,2),
    indv_unitem_contb numeric(14,2),
    indv_contb numeric(14,2),
    pol_pty_cmte_contb numeric(14,2),
    pac_contb numeric(14,2),
    cand_contb numeric(14,2),
    ttl_contb numeric(14,2),
    tranf_from_affiliated_cmte numeric(14,2),
    loans_received_from_cand numeric(14,2),
    other_loans_received numeric(14,2),
    ttl_loans numeric(14,2),
    op_exp numeric(14,2),
    fndrsg_exp numeric(14,2),
    legal_and_acctg_exp numeric(14,2),
    ttl_offsets_to_op_exp numeric(14,2),
    other_receipts numeric(14,2),
    ttl_receipts numeric(14,2),
    op_exp2 numeric(14,2),
    tranf_to_other_auth_cmte numeric(14,2),
    fndrsg_disb numeric(14,2),
    exempt_legal_and_acctg_disb numeric(14,2),
    loan_repymts_made_by_cand numeric(14,2),
    other_repymts numeric(14,2),
    ttl_loan_repymts_made numeric(14,2),
    ref_indv_contb numeric(14,2),
    ref_pol_pty_contb numeric(14,2),
    ref_other_pol_cmte_contb numeric(14,2),
    ttl_contb_ref numeric(14,2),
    other_disb numeric(14,2),
    ttl_disb numeric(14,2),
    alabama numeric(14,2),
    alaska numeric(14,2),
    arizona numeric(14,2),
    arkansas numeric(14,2),
    california numeric(14,2),
    colorado numeric(14,2),
    connecticut numeric(14,2),
    delaware numeric(14,2),
    district_columbia numeric(14,2),
    florida numeric(14,2),
    georgia numeric(14,2),
    hawaii numeric(14,2),
    idaho numeric(14,2),
    illinois numeric(14,2),
    indiana numeric(14,2),
    iowa numeric(14,2),
    kansas numeric(14,2),
    kentucky numeric(14,2),
    louisiana numeric(14,2),
    maine numeric(14,2),
    maryland numeric(14,2),
    massachusetts numeric(14,2),
    michigan numeric(14,2),
    minnesota numeric(14,2),
    mississippi numeric(14,2),
    missouri numeric(14,2),
    montana numeric(14,2),
    nebraska numeric(14,2),
    nevada numeric(14,2),
    new_hampshire numeric(14,2),
    new_jersey numeric(14,2),
    new_mexico numeric(14,2),
    new_york numeric(14,2),
    north_carolina numeric(14,2),
    north_dakota numeric(14,2),
    ohio numeric(14,2),
    oklahoma numeric(14,2),
    oregon numeric(14,2),
    pennsylvania numeric(14,2),
    rhode_island numeric(14,2),
    south_carolina numeric(14,2),
    south_dakota numeric(14,2),
    tennessee numeric(14,2),
    texas numeric(14,2),
    utah numeric(14,2),
    vermont numeric(14,2),
    virginia numeric(14,2),
    washington numeric(14,2),
    west_virginia numeric(14,2),
    wisconsin numeric(14,2),
    wyoming numeric(14,2),
    puerto_rico numeric(14,2),
    guam numeric(14,2),
    virgin_islands numeric(14,2),
    ttl numeric(14,2),
    file_num numeric(7,0),
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    sub_id numeric(19,0) NOT NULL,
    receipt_dt timestamp without time zone,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    most_recent_filing_flag character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_f3s (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    election_dt timestamp without time zone,
    day_after_election_dt timestamp without time zone,
    ttl_contb numeric(14,2),
    ttl_contb_ref numeric(14,2),
    net_contb numeric(14,2),
    ttl_op_exp numeric(14,2),
    ttl_offsets_to_op_exp numeric(14,2),
    net_op_exp numeric(14,2),
    indv_item_contb numeric(14,2),
    indv_unitem_contb numeric(14,2),
    ttl_indv_contb numeric(14,2),
    pol_pty_cmte_contb numeric(14,2),
    other_pol_cmte_contb numeric(14,2),
    cand_contb numeric(14,2),
    ttl_contb_column_ttl numeric(14,2),
    tranf_from_other_auth_cmte numeric(14,2),
    loans_made_by_cand numeric(14,2),
    all_other_loans numeric(14,2),
    ttl_loans numeric(14,2),
    offsets_to_op_exp numeric(14,2),
    other_receipts numeric(14,2),
    ttl_receipts numeric(14,2),
    op_exp numeric(14,2),
    tranf_to_other_auth_cmte numeric(14,2),
    loan_repymts_cand_loans numeric(14,2),
    loan_repymts_other_loans numeric(14,2),
    ttl_loan_repymts numeric(14,2),
    ref_indv_contb numeric(14,2),
    ref_pol_pty_cmte_contb numeric(14,2),
    ref_other_pol_cmte_contb numeric(14,2),
    ttl_contb_ref_col_ttl numeric(14,2),
    other_disb numeric(14,2),
    ttl_disb numeric(14,2),
    file_num numeric(7,0),
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    sub_id numeric(19,0) NOT NULL,
    receipt_dt timestamp without time zone,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    most_recent_filing_flag character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_f3x (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    qual_cmte_flg character varying(1),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(5),
    rpt_pgi_desc character varying(10),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    receipt_dt timestamp without time zone,
    election_cycle numeric(4,0),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    multicand_flg character varying(1),
    coh_bop numeric(14,2),
    ttl_receipts numeric,
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb numeric,
    ttl_disb_sum_page_per numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    ttl_indv_contb numeric(14,2),
    pol_pty_cmte_contb_per_i numeric(14,2),
    other_pol_cmte_contb_per_i numeric(14,2),
    ttl_contb_col_ttl_per numeric(14,2),
    tranf_from_affiliated_pty_per numeric(14,2),
    all_loans_received_per numeric(14,2),
    loan_repymts_received_per numeric(14,2),
    offests_to_op_exp numeric,
    offests_to_op_exp_line_15 numeric(14,2),
    fed_cand_contb_ref_per numeric(14,2),
    other_fed_receipts_per numeric(14,2),
    tranf_from_nonfed_acct_per numeric(14,2),
    tranf_from_nonfed_levin_per numeric(14,2),
    ttl_nonfed_tranf_per numeric(14,2),
    ttl_receipts_per_line_19 numeric(14,2),
    ttl_fed_receipts_per numeric(14,2),
    shared_fed_op_exp_per numeric(14,2),
    shared_nonfed_op_exp_per numeric(14,2),
    other_fed_op_exp_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    tranf_to_affliliated_cmte_per numeric(14,2),
    fed_cand_cmte_contb_per numeric(14,2),
    indt_exp_per numeric(14,2),
    coord_exp_by_pty_cmte_per numeric(14,2),
    loan_repymts_made_per numeric(14,2),
    loans_made_per numeric(14,2),
    indv_contb_ref_per numeric(14,2),
    pol_pty_cmte_refund numeric(14,2),
    other_pol_cmte_refund numeric(14,2),
    ttl_contb_refund numeric,
    ttl_contb_refund_line_28d numeric(14,2),
    other_disb_per numeric(14,2),
    shared_fed_actvy_fed_shr_per numeric(14,2),
    shared_fed_actvy_nonfed_per numeric(14,2),
    non_alloc_fed_elect_actvy_per numeric(14,2),
    ttl_fed_elect_actvy_per numeric(14,2),
    ttl_disb_per_line_31 numeric(14,2),
    ttl_fed_disb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    ttl_contb_refund_line_34 numeric(14,2),
    net_contb_per numeric(14,2),
    ttl_fed_op_exp_per numeric(14,2),
    offests_to_op_exp_line_37 numeric(14,2),
    net_op_exp_per numeric(14,2),
    coh_begin_calendar_yr numeric(14,2),
    calendar_yr numeric(4,0),
    ttl_receipts_sum_page_ytd numeric(14,2),
    subttl_sum_ytd numeric(14,2),
    ttl_disb_sum_page_ytd numeric(14,2),
    coh_coy numeric(14,2),
    indv_item_contb_ytd numeric(14,2),
    indv_unitem_contb_ytd numeric(14,2),
    ttl_indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd_i numeric(14,2),
    other_pol_cmte_contb_ytd_i numeric(14,2),
    ttl_contb_col_ttl_ytd numeric(14,2),
    tranf_from_affiliated_pty_ytd numeric(14,2),
    all_loans_received_ytd numeric(14,2),
    loan_repymts_received_ytd numeric(14,2),
    offsets_to_op_exp_ytd_i numeric(14,2),
    fed_cand_cmte_contb_ytd numeric(14,2),
    other_fed_receipts_ytd numeric(14,2),
    tranf_from_nonfed_acct_ytd numeric(14,2),
    tranf_from_nonfed_levin_ytd numeric(14,2),
    ttl_nonfed_tranf_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    ttl_fed_receipts_ytd numeric(14,2),
    shared_fed_op_exp_ytd numeric(14,2),
    shared_nonfed_op_exp_ytd numeric(14,2),
    other_fed_op_exp_ytd numeric(14,2),
    ttl_op_exp_ytd numeric(14,2),
    tranf_to_affilitated_cmte_ytd numeric(14,2),
    fed_cand_cmte_contb_ref_ytd numeric(14,2),
    indt_exp_ytd numeric(14,2),
    coord_exp_by_pty_cmte_ytd numeric(14,2),
    loan_repymts_made_ytd numeric(14,2),
    loans_made_ytd numeric(14,2),
    indv_contb_ref_ytd numeric(14,2),
    pol_pty_cmte_refund_ytd numeric(14,2),
    other_pol_cmte_refund_ytd numeric(14,2),
    ttl_contb_refund_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    shared_fed_actvy_fed_shr_ytd numeric(14,2),
    shared_fed_actvy_nonfed_ytd numeric(14,2),
    non_alloc_fed_elect_actvy_ytd numeric(14,2),
    ttl_fed_elect_actvy_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    ttl_fed_disb_ytd numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd_ii numeric(14,2),
    net_contb_ytd numeric(14,2),
    ttl_fed_op_exp_ytd numeric(14,2),
    offsets_to_op_exp_ytd_ii numeric(14,2),
    net_op_exp_ytd numeric(14,2),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    sub_id numeric(19,0) NOT NULL,
    most_recent_filing_flag character varying(1),
    pg_date timestamp without time zone
);


CREATE VIEW fec_vsum_f3x_vw AS
 SELECT fec_vsum_f3x.cmte_id,
    fec_vsum_f3x.cmte_nm,
    fec_vsum_f3x.cmte_st1,
    fec_vsum_f3x.cmte_st2,
    fec_vsum_f3x.cmte_city,
    fec_vsum_f3x.cmte_st,
    fec_vsum_f3x.cmte_zip,
    fec_vsum_f3x.cmte_addr_chg_flg,
    fec_vsum_f3x.qual_cmte_flg,
    fec_vsum_f3x.amndt_ind,
    fec_vsum_f3x.amndt_ind_desc,
    fec_vsum_f3x.rpt_tp,
    fec_vsum_f3x.rpt_tp_desc,
    fec_vsum_f3x.rpt_pgi,
    fec_vsum_f3x.rpt_pgi_desc,
    fec_vsum_f3x.election_dt,
    fec_vsum_f3x.election_st,
    fec_vsum_f3x.election_st_desc,
    fec_vsum_f3x.cvg_start_dt,
    fec_vsum_f3x.cvg_end_dt,
    fec_vsum_f3x.rpt_yr,
    fec_vsum_f3x.receipt_dt,
    fec_vsum_f3x.election_cycle,
    fec_vsum_f3x.tres_sign_nm,
    fec_vsum_f3x.tres_sign_dt,
    fec_vsum_f3x.tres_l_nm,
    fec_vsum_f3x.tres_f_nm,
    fec_vsum_f3x.tres_m_nm,
    fec_vsum_f3x.tres_prefix,
    fec_vsum_f3x.tres_suffix,
    fec_vsum_f3x.multicand_flg,
    fec_vsum_f3x.coh_bop,
    fec_vsum_f3x.ttl_receipts,
    fec_vsum_f3x.ttl_receipts_sum_page_per,
    fec_vsum_f3x.subttl_sum_page_per,
    fec_vsum_f3x.ttl_disb,
    fec_vsum_f3x.ttl_disb_sum_page_per,
    fec_vsum_f3x.coh_cop,
    fec_vsum_f3x.debts_owed_to_cmte,
    fec_vsum_f3x.debts_owed_by_cmte,
    fec_vsum_f3x.indv_item_contb_per,
    fec_vsum_f3x.indv_unitem_contb_per,
    fec_vsum_f3x.ttl_indv_contb,
    fec_vsum_f3x.pol_pty_cmte_contb_per_i,
    fec_vsum_f3x.other_pol_cmte_contb_per_i,
    fec_vsum_f3x.ttl_contb_col_ttl_per,
    fec_vsum_f3x.tranf_from_affiliated_pty_per,
    fec_vsum_f3x.all_loans_received_per,
    fec_vsum_f3x.loan_repymts_received_per,
    fec_vsum_f3x.offests_to_op_exp,
    fec_vsum_f3x.offests_to_op_exp_line_15,
    fec_vsum_f3x.fed_cand_contb_ref_per,
    fec_vsum_f3x.other_fed_receipts_per,
    fec_vsum_f3x.tranf_from_nonfed_acct_per,
    fec_vsum_f3x.tranf_from_nonfed_levin_per,
    fec_vsum_f3x.ttl_nonfed_tranf_per,
    fec_vsum_f3x.ttl_receipts_per_line_19,
    fec_vsum_f3x.ttl_fed_receipts_per,
    fec_vsum_f3x.shared_fed_op_exp_per,
    fec_vsum_f3x.shared_nonfed_op_exp_per,
    fec_vsum_f3x.other_fed_op_exp_per,
    fec_vsum_f3x.ttl_op_exp_per,
    fec_vsum_f3x.tranf_to_affliliated_cmte_per,
    fec_vsum_f3x.fed_cand_cmte_contb_per,
    fec_vsum_f3x.indt_exp_per,
    fec_vsum_f3x.coord_exp_by_pty_cmte_per,
    fec_vsum_f3x.loan_repymts_made_per,
    fec_vsum_f3x.loans_made_per,
    fec_vsum_f3x.indv_contb_ref_per,
    fec_vsum_f3x.pol_pty_cmte_refund,
    fec_vsum_f3x.other_pol_cmte_refund,
    fec_vsum_f3x.ttl_contb_refund,
    fec_vsum_f3x.ttl_contb_refund_line_28d,
    fec_vsum_f3x.other_disb_per,
    fec_vsum_f3x.shared_fed_actvy_fed_shr_per,
    fec_vsum_f3x.shared_fed_actvy_nonfed_per,
    fec_vsum_f3x.non_alloc_fed_elect_actvy_per,
    fec_vsum_f3x.ttl_fed_elect_actvy_per,
    fec_vsum_f3x.ttl_disb_per_line_31,
    fec_vsum_f3x.ttl_fed_disb_per,
    fec_vsum_f3x.ttl_contb_per,
    fec_vsum_f3x.ttl_contb_refund_line_34,
    fec_vsum_f3x.net_contb_per,
    fec_vsum_f3x.ttl_fed_op_exp_per,
    fec_vsum_f3x.offests_to_op_exp_line_37,
    fec_vsum_f3x.net_op_exp_per,
    fec_vsum_f3x.coh_begin_calendar_yr,
    fec_vsum_f3x.calendar_yr,
    fec_vsum_f3x.ttl_receipts_sum_page_ytd,
    fec_vsum_f3x.subttl_sum_ytd,
    fec_vsum_f3x.ttl_disb_sum_page_ytd,
    fec_vsum_f3x.coh_coy,
    fec_vsum_f3x.indv_item_contb_ytd,
    fec_vsum_f3x.indv_unitem_contb_ytd,
    fec_vsum_f3x.ttl_indv_contb_ytd,
    fec_vsum_f3x.pol_pty_cmte_contb_ytd_i,
    fec_vsum_f3x.other_pol_cmte_contb_ytd_i,
    fec_vsum_f3x.ttl_contb_col_ttl_ytd,
    fec_vsum_f3x.tranf_from_affiliated_pty_ytd,
    fec_vsum_f3x.all_loans_received_ytd,
    fec_vsum_f3x.loan_repymts_received_ytd,
    fec_vsum_f3x.offsets_to_op_exp_ytd_i,
    fec_vsum_f3x.fed_cand_cmte_contb_ytd,
    fec_vsum_f3x.other_fed_receipts_ytd,
    fec_vsum_f3x.tranf_from_nonfed_acct_ytd,
    fec_vsum_f3x.tranf_from_nonfed_levin_ytd,
    fec_vsum_f3x.ttl_nonfed_tranf_ytd,
    fec_vsum_f3x.ttl_receipts_ytd,
    fec_vsum_f3x.ttl_fed_receipts_ytd,
    fec_vsum_f3x.shared_fed_op_exp_ytd,
    fec_vsum_f3x.shared_nonfed_op_exp_ytd,
    fec_vsum_f3x.other_fed_op_exp_ytd,
    fec_vsum_f3x.ttl_op_exp_ytd,
    fec_vsum_f3x.tranf_to_affilitated_cmte_ytd,
    fec_vsum_f3x.fed_cand_cmte_contb_ref_ytd,
    fec_vsum_f3x.indt_exp_ytd,
    fec_vsum_f3x.coord_exp_by_pty_cmte_ytd,
    fec_vsum_f3x.loan_repymts_made_ytd,
    fec_vsum_f3x.loans_made_ytd,
    fec_vsum_f3x.indv_contb_ref_ytd,
    fec_vsum_f3x.pol_pty_cmte_refund_ytd,
    fec_vsum_f3x.other_pol_cmte_refund_ytd,
    fec_vsum_f3x.ttl_contb_refund_ytd,
    fec_vsum_f3x.other_disb_ytd,
    fec_vsum_f3x.shared_fed_actvy_fed_shr_ytd,
    fec_vsum_f3x.shared_fed_actvy_nonfed_ytd,
    fec_vsum_f3x.non_alloc_fed_elect_actvy_ytd,
    fec_vsum_f3x.ttl_fed_elect_actvy_ytd,
    fec_vsum_f3x.ttl_disb_ytd,
    fec_vsum_f3x.ttl_fed_disb_ytd,
    fec_vsum_f3x.ttl_contb_ytd,
    fec_vsum_f3x.ttl_contb_ref_ytd_ii,
    fec_vsum_f3x.net_contb_ytd,
    fec_vsum_f3x.ttl_fed_op_exp_ytd,
    fec_vsum_f3x.offsets_to_op_exp_ytd_ii,
    fec_vsum_f3x.net_op_exp_ytd,
    fec_vsum_f3x.begin_image_num,
    fec_vsum_f3x.end_image_num,
    fec_vsum_f3x.form_tp,
    fec_vsum_f3x.form_tp_desc,
    fec_vsum_f3x.file_num,
    fec_vsum_f3x.prev_file_num,
    fec_vsum_f3x.mst_rct_file_num,
    fec_vsum_f3x.sub_id,
    fec_vsum_f3x.most_recent_filing_flag,
    fec_vsum_f3x.pg_date
   FROM fec_vsum_f3x;


CREATE TABLE fec_vsum_f3z (
    pcc_id character varying(9),
    pcc_nm character varying(200),
    auth_cmte_id character varying(9),
    auth_cmte_nm character varying(200),
    indv_contb numeric(14,2),
    pol_pty_contb numeric(14,2),
    other_pol_cmte_contb numeric(14,2),
    cand_contb numeric(14,2),
    ttl_contb numeric(14,2),
    tranf_from_other_auth_cmte numeric(14,2),
    loans_made_by_cand numeric(14,2),
    all_other_loans numeric(14,2),
    ttl_loans numeric(14,2),
    offsets_to_op_exp numeric(14,2),
    other_receipts numeric(14,2),
    ttl_receipts numeric(14,2),
    op_exp numeric(14,2),
    tranf_to_other_auth_cmte numeric(14,2),
    repymts_loans_made_cand numeric(14,2),
    repymts_all_other_loans numeric(14,2),
    ttl_loan_repymts numeric(14,2),
    ref_indv_contb numeric(14,2),
    ref_pol_pty_cmte_contb numeric(14,2),
    ref_other_pol_cmte_contb numeric(14,2),
    ttl_contb_ref numeric(14,2),
    other_disb numeric(14,2),
    ttl_disb numeric(14,2),
    coh_bop numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    net_contb numeric(14,2),
    net_op_exp numeric(14,2),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    file_num numeric(7,0),
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    sub_id numeric(19,0) NOT NULL,
    receipt_dt timestamp without time zone,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    most_recent_filing_flag character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_f5 (
    indv_org_id character varying(9),
    indv_org_nm character varying(200),
    indv_l_nm character varying(30),
    indv_f_nm character varying(20),
    indv_m_nm character varying(20),
    indv_prefix character varying(10),
    indv_suffix character varying(10),
    indv_org_st1 character varying(34),
    indv_org_st2 character varying(34),
    indv_org_city character varying(30),
    indv_org_st character varying(2),
    indv_org_zip character varying(9),
    entity_tp character varying(3),
    addr_chg_flg character varying(1),
    qual_nonprofit_corp_ind character varying(1),
    indv_org_employer character varying(38),
    indv_org_occupation character varying(38),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    orig_amndt_dt timestamp without time zone,
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(5),
    rpt_pgi_desc character varying(10),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    receipt_dt timestamp without time zone,
    election_cycle numeric(4,0),
    ttl_indt_contb numeric(14,2),
    ttl_indt_exp numeric(14,2),
    filer_nm character varying(90),
    filer_sign_nm character varying(90),
    filer_sign_dt timestamp without time zone,
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    notary_sign_dt timestamp without time zone,
    notary_commission_exprtn_dt timestamp without time zone,
    notary_nm character varying(38),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    sub_id numeric(19,0) NOT NULL,
    most_recent_filing_flag character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_f56 (
    filer_cmte_id character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    contbr_nm character varying(200),
    contbr_l_nm character varying(30),
    contbr_f_nm character varying(20),
    contbr_m_nm character varying(20),
    contbr_prefix character varying(10),
    contbr_suffix character varying(10),
    contbr_st1 character varying(34),
    contbr_st2 character varying(34),
    conbtr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    contb_dt timestamp without time zone,
    contb_amt numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_nm character varying(200),
    conduit_st1 character varying(34),
    conduit_st2 character varying(34),
    conduit_city character varying(30),
    conduit_st character varying(2),
    conduit_zip character varying(9),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_f57_queue_new (
    filer_cmte_id character varying(9),
    pye_nm character varying(200),
    pye_l_nm character varying(30),
    pye_f_nm character varying(20),
    pye_m_nm character varying(20),
    pye_prefix character varying(10),
    pye_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_purpose character varying(100),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    s_o_cand_id character varying(9),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_state_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(20),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    cal_ytd_ofc_sought numeric(14,2),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    link_id numeric(19,0),
    image_num character varying(18),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0),
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0)
);


CREATE VIEW fec_vsum_f5_vw AS
 SELECT fec_vsum_f5.indv_org_id,
    fec_vsum_f5.indv_org_nm,
    fec_vsum_f5.indv_l_nm,
    fec_vsum_f5.indv_f_nm,
    fec_vsum_f5.indv_m_nm,
    fec_vsum_f5.indv_prefix,
    fec_vsum_f5.indv_suffix,
    fec_vsum_f5.indv_org_st1,
    fec_vsum_f5.indv_org_st2,
    fec_vsum_f5.indv_org_city,
    fec_vsum_f5.indv_org_st,
    fec_vsum_f5.indv_org_zip,
    fec_vsum_f5.entity_tp,
    fec_vsum_f5.addr_chg_flg,
    fec_vsum_f5.qual_nonprofit_corp_ind,
    fec_vsum_f5.indv_org_employer,
    fec_vsum_f5.indv_org_occupation,
    fec_vsum_f5.amndt_ind,
    fec_vsum_f5.amndt_ind_desc,
    fec_vsum_f5.orig_amndt_dt,
    fec_vsum_f5.rpt_tp,
    fec_vsum_f5.rpt_tp_desc,
    fec_vsum_f5.rpt_pgi,
    fec_vsum_f5.rpt_pgi_desc,
    fec_vsum_f5.cvg_start_dt,
    fec_vsum_f5.cvg_end_dt,
    fec_vsum_f5.rpt_yr,
    fec_vsum_f5.receipt_dt,
    fec_vsum_f5.election_cycle,
    fec_vsum_f5.ttl_indt_contb,
    fec_vsum_f5.ttl_indt_exp,
    fec_vsum_f5.filer_nm,
    fec_vsum_f5.filer_sign_nm,
    fec_vsum_f5.filer_sign_dt,
    fec_vsum_f5.filer_l_nm,
    fec_vsum_f5.filer_f_nm,
    fec_vsum_f5.filer_m_nm,
    fec_vsum_f5.filer_prefix,
    fec_vsum_f5.filer_suffix,
    fec_vsum_f5.notary_sign_dt,
    fec_vsum_f5.notary_commission_exprtn_dt,
    fec_vsum_f5.notary_nm,
    fec_vsum_f5.begin_image_num,
    fec_vsum_f5.end_image_num,
    fec_vsum_f5.form_tp,
    fec_vsum_f5.form_tp_desc,
    fec_vsum_f5.file_num,
    fec_vsum_f5.prev_file_num,
    fec_vsum_f5.mst_rct_file_num,
    fec_vsum_f5.sub_id,
    fec_vsum_f5.most_recent_filing_flag,
    fec_vsum_f5.pg_date
   FROM fec_vsum_f5;


CREATE TABLE fec_vsum_f7 (
    org_id character varying(9),
    org_nm character varying(200),
    org_st1 character varying(34),
    org_st2 character varying(34),
    org_city character varying(30),
    org_st character varying(2),
    org_zip character varying(9),
    org_tp character varying(1),
    org_tp_desc character varying(90),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(90),
    rpt_pgi character varying(1),
    rpt_pgi_desc character varying(10),
    amdnt_ind character varying(1),
    amndt_ind_desc character varying(15),
    election_dt timestamp without time zone,
    election_st character varying(2),
    election_st_desc character varying(20),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    ttl_communication_cost numeric(14,2),
    filer_sign_nm character varying(90),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    filer_sign_dt timestamp without time zone,
    filer_title character varying(20),
    receipt_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    sub_id numeric(19,0) NOT NULL,
    most_recent_filing_flag character varying(1),
    pg_date timestamp without time zone
);


CREATE VIEW fec_vsum_f7_vw AS
 SELECT f7.org_id,
    f7.org_nm,
    f7.org_st1,
    f7.org_st2,
    f7.org_city,
    f7.org_st,
    f7.org_zip,
    f7.org_tp,
    f7.org_tp_desc,
    f7.rpt_tp,
    f7.rpt_tp_desc,
    f7.rpt_pgi,
    f7.rpt_pgi_desc,
    f7.amdnt_ind,
    f7.amndt_ind_desc,
    f7.election_dt,
    f7.election_st,
    f7.election_st_desc,
    f7.cvg_start_dt,
    f7.cvg_end_dt,
    f7.ttl_communication_cost,
    f7.filer_sign_nm,
    f7.filer_l_nm,
    f7.filer_f_nm,
    f7.filer_m_nm,
    f7.filer_prefix,
    f7.filer_suffix,
    f7.filer_sign_dt,
    f7.filer_title,
    f7.receipt_dt,
    f7.rpt_yr,
    (f7.rpt_yr + (f7.rpt_yr % (2)::numeric)) AS election_cycle,
    f7.begin_image_num,
    f7.end_image_num,
    'F7'::character varying(8) AS form_tp,
    f7.form_tp_desc,
    f7.file_num,
    f7.prev_file_num,
    f7.mst_rct_file_num,
    f7.sub_id,
        CASE
            WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM (disclosure.nml_form_7 f7
     LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f7.sub_id = vs.orig_sub_id)));


CREATE TABLE fec_vsum_f9 (
    cmte_id character varying(9),
    ind_org_corp_nm character varying(200),
    indv_l_nm character varying(30),
    indv_f_nm character varying(20),
    indv_m_nm character varying(20),
    indv_prefix character varying(10),
    indv_suffix character varying(10),
    ind_org_corp_st1 character varying(34),
    ind_org_corp_st2 character varying(34),
    ind_org_corp_city character varying(30),
    ind_org_corp_st character varying(2),
    ind_org_corp_st_desc character varying(20),
    ind_org_corp_zip character varying(9),
    entity_tp character varying(3),
    addr_chg_flg character varying(1),
    addr_chg_flg_desc character varying(20),
    ind_org_corp_emp character varying(38),
    ind_org_corp_occup character varying(38),
    amndt_ind character varying(1),
    rpt_tp character varying(3),
    beg_cvg_dt timestamp without time zone,
    end_cvg_dt timestamp without time zone,
    comm_title character varying(40),
    pub_distrib_dt timestamp without time zone,
    qual_nonprofit_flg character varying(18),
    qual_nonprofit_flg_desc character varying(40),
    segr_bank_acct_flg character varying(1),
    segr_bank_acct_flg_desc character varying(30),
    ind_custod_nm character varying(90),
    cust_l_nm character varying(30),
    cust_f_nm character varying(20),
    cust_m_nm character varying(20),
    cust_prefix character varying(10),
    cust_suffix character varying(10),
    ind_custod_st1 character varying(34),
    ind_custod_st2 character varying(34),
    ind_custod_city character varying(30),
    ind_custod_st character varying(2),
    ind_custod_st_desc character varying(20),
    ind_custod_zip character varying(9),
    ind_custod_emp character varying(38),
    ind_custod_occup character varying(38),
    ttl_dons_this_stmt numeric(14,2),
    ttl_disb_this_stmt numeric(14,2),
    filer_sign_nm character varying(90),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    filer_sign_dt timestamp without time zone,
    filer_cd character varying(3),
    filer_cd_desc character varying(20),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    receipt_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    sub_id numeric(19,0) NOT NULL,
    most_recent_filing_flag character varying(1),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_f91 (
    filer_cmte_id character varying(9),
    shr_ex_ctl_ind_nm character varying(90),
    shr_ex_ctl_l_nm character varying(30),
    shr_ex_ctl_f_nm character varying(20),
    shr_ex_ctl_m_nm character varying(20),
    shr_ex_ctl_prefix character varying(10),
    shr_ex_ctl_suffix character varying(10),
    shr_ex_ctl_street1 character varying(34),
    shr_ex_ctl_street2 character varying(34),
    shr_ex_ctl_city character varying(30),
    shr_ex_ctl_st character varying(2),
    shr_ex_ctl_st_desc character varying(20),
    shr_ex_ctl_zip character varying(9),
    shr_ex_ctl_employ character varying(38),
    shr_ex_ctl_occup character varying(38),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    begin_image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_f94 (
    filer_cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_l_nm character varying(30),
    cand_f_nm character varying(20),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    election_tp character varying(5),
    election_tp_desc character varying(20),
    fec_election_tp_desc character varying(20),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    begin_image_num character varying(18),
    sb_link_id numeric(19,0),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE VIEW fec_vsum_f9_vw AS
 SELECT f9.cmte_id,
    f9.ind_org_corp_nm,
    f9.indv_l_nm,
    f9.indv_f_nm,
    f9.indv_m_nm,
    f9.indv_prefix,
    f9.indv_suffix,
    f9.ind_org_corp_st1,
    f9.ind_org_corp_st2,
    f9.ind_org_corp_city,
    f9.ind_org_corp_st,
    f9.ind_org_corp_st_desc,
    f9.ind_org_corp_zip,
    f9.entity_tp,
    f9.addr_chg_flg,
    f9.addr_chg_flg_desc,
    f9.ind_org_corp_emp,
    f9.ind_org_corp_occup,
    f9.amndt_ind,
    f9.rpt_tp,
    f9.beg_cvg_dt,
    f9.end_cvg_dt,
    f9.comm_title,
    f9.pub_distrib_dt,
    f9.qual_nonprofit_flg,
    f9.qual_nonprofit_flg_desc,
    f9.segr_bank_acct_flg,
    f9.segr_bank_acct_flg_desc,
    f9.ind_custod_nm,
    f9.cust_l_nm,
    f9.cust_f_nm,
    f9.cust_m_nm,
    f9.cust_prefix,
    f9.cust_suffix,
    f9.ind_custod_st1,
    f9.ind_custod_st2,
    f9.ind_custod_city,
    f9.ind_custod_st,
    f9.ind_custod_st_desc,
    f9.ind_custod_zip,
    f9.ind_custod_emp,
    f9.ind_custod_occup,
    f9.ttl_dons_this_stmt,
    f9.ttl_disb_this_stmt,
    f9.filer_sign_nm,
    f9.filer_l_nm,
    f9.filer_f_nm,
    f9.filer_m_nm,
    f9.filer_prefix,
    f9.filer_suffix,
    f9.filer_sign_dt,
    f9.filer_cd,
    f9.filer_cd_desc,
    f9.begin_image_num,
    f9.end_image_num,
    'F9'::character varying(8) AS form_tp,
    f9.form_tp_desc,
    f9.receipt_dt,
    f9.rpt_yr,
    (f9.rpt_yr + (f9.rpt_yr % (2)::numeric)) AS election_cycle,
    f9.file_num,
    f9.prev_file_num,
    f9.mst_rct_file_num,
    f9.sub_id,
        CASE
            WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM (disclosure.nml_form_9 f9
     LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f9.sub_id = vs.orig_sub_id)));


CREATE TABLE fec_vsum_sched_a (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    contbr_id character varying(9),
    contbr_nm character varying(200),
    contbr_nm_first character varying(38),
    contbr_m_nm character varying(20),
    contbr_nm_last character varying(38),
    contbr_prefix character varying(10),
    contbr_suffix character varying(10),
    contbr_st1 character varying(34),
    contbr_st2 character varying(34),
    contbr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    contb_aggregate_ytd numeric(14,2),
    contb_receipt_dt timestamp without time zone,
    contb_receipt_amt numeric(14,2),
    receipt_tp character varying(3),
    receipt_tp_desc character varying(90),
    receipt_desc character varying(100),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_m_nm character varying(20),
    cand_nm_last character varying(38),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    donor_cmte_nm character varying(200),
    national_cmte_nonfed_acct character varying(9),
    increased_limit character varying(1),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    pg_date timestamp without time zone,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0)
);


CREATE TABLE fec_vsum_sched_b (
    cmte_id character varying(9),
    recipient_cmte_id character varying(9),
    recipient_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    payee_employer character varying(38),
    payee_occupation character varying(38),
    recipient_st1 character varying(34),
    recipient_st2 character varying(34),
    recipient_city character varying(30),
    recipient_st character varying(2),
    recipient_zip character varying(9),
    disb_desc character varying(100),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_tp_year character varying(4),
    election_tp_desc character varying(20),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    disb_dt timestamp without time zone,
    disb_amt numeric(14,2),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    disb_tp character varying(3),
    disb_tp_desc character varying(90),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    national_cmte_nonfed_acct character varying(9),
    ref_disp_excess_flg character varying(1),
    comm_dt timestamp without time zone,
    benef_cmte_nm character varying(200),
    semi_an_bundled_refund numeric(14,2),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_id character varying(8),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    pg_date timestamp without time zone,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0)
);


CREATE TABLE fec_vsum_sched_c1 (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    entity_tp_desc character varying(50),
    loan_src_nm character varying(200),
    loan_src_st1 character varying(34),
    loan_src_st2 character varying(34),
    loan_src_city character varying(30),
    loan_src_st character varying(2),
    loan_src_zip character varying(9),
    entity_tp character varying(3),
    loan_amt numeric(14,2),
    interest_rate_pct character varying(15),
    incurred_dt timestamp without time zone,
    due_dt character varying(15),
    loan_restructured_flg character varying(1),
    orig_loan_dt timestamp without time zone,
    credit_amt_this_draw numeric(14,2),
    ttl_bal numeric(14,2),
    other_liable_pty_flg character varying(1),
    collateral_flg character varying(1),
    collateral_desc character varying(100),
    collateral_value numeric(14,2),
    perfected_interest_flg character varying(1),
    future_income_flg character varying(1),
    future_income_desc character varying(100),
    future_income_est_value numeric(14,2),
    depository_acct_est_dt timestamp without time zone,
    acct_loc_nm character varying(90),
    acct_loc_st1 character varying(34),
    acct_loc_st2 character varying(34),
    acct_loc_city character varying(30),
    acct_loc_st character varying(2),
    acct_loc_zip character varying(9),
    depository_acct_auth_dt timestamp without time zone,
    loan_basis_desc character varying(100),
    tres_sign_nm character varying(90),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    tres_sign_dt timestamp without time zone,
    auth_sign_nm character varying(90),
    auth_sign_l_nm character varying(30),
    auth_sign_f_nm character varying(20),
    auth_sign_m_nm character varying(20),
    auth_sign_prefix character varying(10),
    auth_sign_suffix character varying(10),
    auth_rep_title character varying(20),
    auth_sign_dt timestamp without time zone,
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    pg_date timestamp without time zone,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0)
);


CREATE TABLE fec_vsum_sched_h1 (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    np_fixed_fed_pct numeric(7,4),
    hsp_min_fed_pct numeric(7,4),
    hsp_est_fed_dir_cand_supp_pct numeric(7,4),
    hsp_est_nonfed_cand_supp_pct numeric(7,4),
    hsp_actl_fed_dir_cand_supp_amt numeric(14,2),
    hsp_actl_nonfed_cand_supp_amt numeric(14,2),
    hsp_actl_fed_dir_cand_supp_pct numeric(7,4),
    ssf_fed_est_dir_cand_supp_pct numeric(7,4),
    ssf_nfed_est_dir_cand_supp_pct numeric(7,4),
    ssf_actl_fed_dir_cand_supp_amt numeric(14,2),
    ssf_actl_nonfed_cand_supp_amt numeric(14,2),
    ssf_actl_fed_dir_cand_supp_pct numeric(7,4),
    president_ind numeric(1,0),
    us_senate_ind numeric(1,0),
    us_congress_ind numeric(1,0),
    subttl_fed numeric(1,0),
    governor_ind numeric(1,0),
    other_st_offices_ind numeric(1,0),
    st_senate_ind numeric(1,0),
    st_rep_ind numeric(1,0),
    local_cand_ind numeric(1,0),
    extra_non_fed_point_ind numeric(1,0),
    subttl_non_fed numeric(2,0),
    ttl_fed_and_nonfed numeric(2,0),
    fed_alloctn numeric(5,0),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    st_loc_pres_only character varying(1),
    st_loc_pres_sen character varying(1),
    st_loc_sen_only character varying(1),
    st_loc_nonpres_nonsen character varying(1),
    flat_min_fed_pct character varying(1),
    fed_pct numeric(5,0),
    non_fed_pct numeric(5,0),
    admin_ratio_chk character varying(1),
    gen_voter_drive_chk character varying(1),
    pub_comm_ref_pty_chk character varying(1),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_sched_h2 (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    evt_activity_nm character varying(90),
    fndsg_acty_flg character varying(1),
    exempt_acty_flg character varying(1),
    direct_cand_support_acty_flg character varying(1),
    ratio_cd character varying(1),
    ratio_cd_desc character varying(30),
    fed_pct_amt numeric(7,4),
    nonfed_pct_amt numeric(7,4),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_sched_h3 (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    acct_nm character varying(90),
    evt_nm character varying(90),
    evt_tp character varying(2),
    event_tp_desc character varying(50),
    tranf_dt timestamp without time zone,
    tranf_amt numeric(14,2),
    ttl_tranf_amt numeric(14,2),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_sched_h4 (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    entity_tp character varying(3),
    entity_tp_desc character varying(30),
    pye_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    evt_purpose_nm character varying(100),
    evt_purpose_desc character varying(38),
    evt_purpose_dt timestamp without time zone,
    ttl_amt_disb numeric(14,2),
    evt_purpose_category_tp character varying(3),
    evt_purpose_category_tp_desc character varying(30),
    fed_share numeric(14,2),
    nonfed_share numeric(14,2),
    admin_voter_drive_acty_ind character varying(1),
    fndrsg_acty_ind character varying(1),
    exempt_acty_ind character varying(1),
    direct_cand_supp_acty_ind character varying(1),
    evt_amt_ytd numeric(14,2),
    add_desc character varying(100),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    admin_acty_ind character varying(1),
    gen_voter_drive_acty_ind character varying(1),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    disb_tp character varying(3),
    disb_tp_desc character varying(90),
    pub_comm_ref_pty_chk character varying(1),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_id character varying(8),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_sched_h5 (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    acct_nm character varying(90),
    tranf_dt timestamp without time zone,
    ttl_tranf_amt_voter_reg numeric(14,2),
    ttl_tranf_voter_id numeric(14,2),
    ttl_tranf_gotv numeric(14,2),
    ttl_tranf_gen_campgn_actvy numeric(14,2),
    ttl_tranf_amt numeric(14,2),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_sched_h6 (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(90),
    entity_tp character varying(3),
    pye_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_st_desc character varying(20),
    pye_zip character varying(9),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    disb_purpose character varying(3),
    disb_purpose_cat character varying(100),
    disb_dt timestamp without time zone,
    ttl_amt_disb numeric(14,2),
    fed_share numeric(14,2),
    levin_share numeric(14,2),
    voter_reg_yn_flg character varying(1),
    voter_reg_yn_flg_desc character varying(40),
    voter_id_yn_flg character varying(1),
    voter_id_yn_flg_desc character varying(40),
    gotv_yn_flg character varying(1),
    gotv_yn_flg_desc character varying(40),
    gen_campgn_yn_flg character varying(1),
    gen_campgn_yn_flg_desc character varying(40),
    evt_amt_ytd numeric(14,2),
    add_desc character varying(100),
    fec_committee_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_office character varying(1),
    cand_office_st_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_district numeric(2,0),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_st_desc character varying(20),
    conduit_cmte_zip character varying(9),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_id character varying(8),
    schedule_type character varying(8),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_sched_i (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(90),
    acct_num character varying(16),
    acct_nm character varying(90),
    other_acct_num character varying(9),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    ttl_receipts_per numeric(14,2),
    tranf_to_fed_alloctn_per numeric(14,2),
    tranf_to_st_local_pty_per numeric(14,2),
    direct_st_local_cand_supp_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    coh_bop numeric(14,2),
    receipts_per numeric(14,2),
    subttl_per numeric(14,2),
    disb_per numeric(14,2),
    coh_cop numeric(14,2),
    ttl_reciepts_ytd numeric(14,2),
    tranf_to_fed_alloctn_ytd numeric(14,2),
    tranf_to_st_local_pty_ytd numeric(14,2),
    direct_st_local_cand_supp_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    coh_boy numeric(14,2),
    receipts_ytd numeric(14,2),
    subttl_ytd numeric(14,2),
    disb_ytd numeric(14,2),
    coh_coy numeric(14,2),
    action_cd character varying(32),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE fec_vsum_sched_l (
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(90),
    acct_nm character varying(90),
    other_acct_num character varying(9),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    item_receipts_per_pers numeric(14,2),
    unitem_receipts_per_pers numeric(14,2),
    ttl_receipts_per_pers numeric(14,2),
    other_receipts_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    voter_reg_amt_per numeric(14,2),
    voter_id_amt_per numeric(14,2),
    gotv_amt_per numeric(14,2),
    generic_campaign_amt_per numeric(14,2),
    ttl_disb_sub_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    coh_bop numeric(14,2),
    receipts_per numeric(14,2),
    subttl_per numeric(14,2),
    disb_per numeric(14,2),
    coh_cop numeric(14,2),
    item_receipts_ytd_pers numeric(14,2),
    unitem_receipts_ytd_pers numeric(14,2),
    ttl_reciepts_ytd_pers numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    voter_reg_amt_ytd numeric(14,2),
    voter_id_amt_ytd numeric(14,2),
    gotv_amt_ytd numeric(14,2),
    generic_campaign_amt_ytd numeric(14,2),
    ttl_disb_ytd_sub numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    coh_boy numeric(14,2),
    receipts_ytd numeric(14,2),
    subttl_ytd numeric(14,2),
    disb_ytd numeric(14,2),
    coh_coy numeric(14,2),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying(32),
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    pg_date timestamp without time zone
);


CREATE VIEW fec_vsumcolumns_f3p_vw AS
 SELECT vs.cmte_id,
    vs.cvg_start_dt,
    vs.cvg_end_dt,
    vs.rpt_yr,
    vs.receipt_dt,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle,
    vs.coh_bop,
    vs.ttl_receipts AS ttl_receipts_per,
    vs.ttl_disb AS ttl_disb_per,
    vs.coh_cop,
    vs.debts_owed_to_cmte,
    vs.debts_owed_by_cmte,
    vs.net_contb AS net_contb_per,
    vs.op_exp_per AS ttl_op_exp_per,
    vs.fed_funds_per,
    vs.indv_item_contb AS indv_item_contb_per,
    vs.indv_unitem_contb AS indv_unitem_contb_per,
    vs.indv_ref AS ttl_indiv_contb_per,
    vs.pty_cmte_contb AS pol_pty_cmte_contb_per,
    vs.oth_cmte_contb AS other_pol_cmte_contb_per,
    vs.cand_cntb AS cand_contb_per,
    vs.ttl_contb AS ttl_contb_per,
    vs.tranf_from_other_auth_cmte AS tranf_from_affilated_cmte_per,
    vs.cand_loan AS loans_received_from_cand_per,
    vs.oth_loans AS other_loans_received_per,
    vs.ttl_loans AS ttl_loans_received_per,
    vs.offsets_to_op_exp AS offsets_to_op_exp_per,
    vs.offsets_to_fndrsg AS offsets_to_fndrsg_exp_per,
    vs.offsets_to_legal_acctg AS offsets_to_legal_acctg_per,
    ((vs.offsets_to_op_exp + vs.offsets_to_fndrsg) + vs.offsets_to_legal_acctg) AS ttl_offsets_to_op_exp_per,
    vs.other_receipts AS other_receipts_per,
    vs.op_exp_per,
    vs.tranf_to_other_auth_cmte AS tranf_to_other_auth_cmte_per,
    vs.fndrsg_disb AS fndrsg_disb_per,
    vs.exempt_legal_acctg_disb AS exempt_legal_acctg_disb_per,
    vs.cand_loan_repymnt AS repymts_loans_made_by_cand_per,
    vs.oth_loan_repymts AS repymts_other_loans_per,
    (vs.cand_loan_repymnt + vs.oth_loan_repymts) AS ttl_loan_repymts_made_per,
    vs.indv_ref AS ref_indv_contb_per,
    vs.pol_pty_cmte_contb AS ref_pol_pty_cmte_contb_per,
    vs.oth_cmte_ref AS ref_other_pol_cmte_contb_per,
    (vs.pol_pty_cmte_contb + vs.oth_cmte_ref) AS ttl_contb_ref_per,
    vs.other_disb_per,
    vs.orig_sub_id AS sub_id
   FROM disclosure.v_sum_and_det_sum_report vs;


CREATE VIEW fec_vsumcolumns_f3x_vw AS
 SELECT vs.cmte_id,
    vs.rpt_tp,
    vs.cvg_start_dt,
    vs.cvg_end_dt,
    vs.rpt_yr,
    vs.receipt_dt,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle,
    vs.coh_bop,
    vs.ttl_receipts,
    vs.net_contb,
    vs.ttl_disb AS ttl_disb_sum_page_per,
    vs.coh_cop,
    vs.debts_owed_to_cmte,
    vs.debts_owed_by_cmte,
    vs.indv_unitem_contb AS indv_unitem_contb_per,
    vs.indv_item_contb AS indv_item_contb_per,
    vs.indv_contb AS ttl_indv_contb,
    vs.pty_cmte_contb AS pol_pty_cmte_contb_per_i,
    vs.oth_cmte_contb AS other_pol_cmte_contb_per_i,
    vs.ttl_contb AS ttl_contb_col_ttl_per,
    vs.tranf_from_other_auth_cmte AS tranf_from_affiliated_pty_per,
    vs.all_loans_received_per,
    vs.loan_repymts_received_per,
    vs.offsets_to_op_exp AS offsets_to_op_exp_per_i,
    vs.fed_cand_contb_ref_per,
    vs.other_receipts AS other_fed_receipts_per,
    vs.tranf_from_nonfed_acct_per,
    vs.tranf_from_nonfed_levin_per,
    vs.ttl_nonfed_tranf_per,
    vs.ttl_fed_receipts_per,
    vs.shared_fed_op_exp_per,
    vs.shared_nonfed_op_exp_per,
    vs.other_fed_op_exp_per,
    vs.ttl_op_exp_per,
    vs.tranf_to_other_auth_cmte AS tranf_to_affliliated_cmte_per,
    vs.fed_cand_cmte_contb_per,
    vs.indt_exp_per,
    vs.coord_exp_by_pty_cmte_per,
    vs.loans_made_per,
    vs.oth_loan_repymts AS loan_repymts_made_per,
    vs.indv_ref AS indv_contb_ref_per,
    vs.pol_pty_cmte_contb AS pol_pty_cmte_refund,
    vs.oth_cmte_ref AS other_pol_cmte_refund,
    vs.ttl_contb_ref AS ttl_contb_refund,
    vs.other_disb_per,
    vs.shared_fed_actvy_fed_shr_per,
    vs.shared_fed_actvy_nonfed_per,
    vs.non_alloc_fed_elect_actvy_per,
    vs.ttl_fed_elect_actvy_per,
    vs.rpt_yr AS calendar_yr,
    vs.orig_sub_id AS sub_id
   FROM disclosure.v_sum_and_det_sum_report vs;


CREATE VIEW fec_vsumcolumns_f5_vw AS
 SELECT vs.cmte_id AS indv_org_id,
    vs.rpt_tp,
    vs.cvg_start_dt,
    vs.cvg_end_dt,
    vs.rpt_yr,
    vs.receipt_dt,
    (vs.rpt_yr + mod(vs.rpt_yr, (2)::numeric)) AS election_cycle,
    vs.ttl_contb AS ttl_indt_contb,
    vs.indt_exp_per AS ttl_indt_exp,
    'F5'::character varying(8) AS form_tp,
    vs.file_num,
    vs.orig_sub_id AS sub_id,
    'Y'::character varying(1) AS most_recent_filing_flag
   FROM disclosure.v_sum_and_det_sum_report vs
  WHERE ((vs.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text]));


CREATE TABLE filtertab (
    query_id numeric,
    document text,
    ao_id numeric,
    ctrl_flg character varying(30),
    pg_date timestamp without time zone
);


CREATE TABLE form_5 (
    form_5_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    amndt_ind character varying(1),
    indv_org_id character varying(9),
    indv_org_nm character varying(200),
    indv_org_st1 character varying(34),
    indv_org_st2 character varying(34),
    indv_org_city character varying(30),
    indv_org_st character varying(2),
    indv_org_zip character varying(9),
    addr_chg_flg character varying(1),
    qual_nonprofit_corp_ind character varying(1),
    indv_org_employer character varying(38),
    indv_org_occupation character varying(38),
    indv_suffix character varying(10),
    indv_prefix character varying(10),
    indv_m_nm character varying(20),
    indv_f_nm character varying(20),
    indv_l_nm character varying(30),
    orig_amndt_dt date,
    rpt_tp character varying(3),
    rpt_pgi character varying(5),
    election_tp character varying(5),
    election_dt date,
    election_st character varying(2),
    cvg_start_dt date,
    cvg_end_dt date,
    ttl_indt_contb numeric(14,2),
    ttl_indt_exp numeric(14,2),
    filer_nm character varying(90),
    filer_l_nm character varying(30),
    filer_m_nm character varying(20),
    filer_f_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    filer_sign_nm character varying(90),
    filer_sign_dt date,
    notary_sign_dt date,
    notary_commission_exprtn_dt date,
    notary_nm character varying(38),
    receipt_dt date,
    rpt_yr numeric(4,0),
    entity_tp character varying(3),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    file_num numeric(10,0),
    sub_id numeric(19,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date timestamp without time zone,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date timestamp without time zone,
    update_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE form_57 (
    form_57_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    entity_tp character varying(3),
    pye_suffix character varying(10),
    pye_prefix character varying(10),
    pye_m_nm character varying(20),
    pye_l_nm character varying(30),
    pye_f_nm character varying(20),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_purpose character varying(100),
    exp_dt date,
    exp_amt numeric(14,2),
    s_o_in character varying(3),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_office character varying(1),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    amndt_ind character varying(1),
    tran_id character varying(32),
    receipt_dt date,
    catg_cd character varying(3),
    exp_tp character varying(3),
    cal_ytd_ofc_sought numeric(14,2),
    catg_cd_desc character varying(40),
    exp_tp_desc character varying(50),
    election_tp character varying(5),
    election_tp_desc character varying(20),
    image_num character varying(18),
    orig_sub_id numeric(19,0),
    file_num numeric(10,0),
    sub_id numeric(19,0),
    link_id numeric(19,0),
    transaction_id numeric(10,0),
    filing_type character(1),
    load_date timestamp without time zone,
    update_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE form_7 (
    form_7_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    org_id character varying(9),
    org_nm character varying(200),
    org_st1 character varying(34),
    org_st2 character varying(34),
    org_city character varying(30),
    org_st character varying(2),
    org_zip character varying(9),
    org_tp character varying(1),
    rpt_tp character varying(3),
    election_dt date,
    election_st character varying(2),
    cvg_start_dt date,
    cvg_end_dt date,
    ttl_communication_cost numeric(14,2),
    filer_sign_nm character varying(90),
    filer_sign_dt date,
    filer_title character varying(20),
    filer_prefix character varying(10),
    filer_m_nm character varying(20),
    filer_f_nm character varying(20),
    filer_l_nm character varying(30),
    filer_suffix character varying(10),
    receipt_dt date,
    rpt_pgi character varying(5),
    amndt_ind character varying(1),
    rpt_yr numeric(4,0),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    file_num numeric(10,0),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date timestamp without time zone,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date timestamp without time zone,
    update_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE form_76 (
    form_76_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    org_id character varying(9),
    communication_tp character varying(2),
    communication_tp_desc character varying(40),
    communication_class character varying(1),
    communication_dt date,
    s_o_ind character varying(3),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_f_nm character varying(20),
    s_o_cand_l_nm character varying(30),
    s_o_cand_suffix character varying(10),
    s_o_cand_office character varying(1),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_district character varying(2),
    s_o_rpt_pgi character varying(5),
    communication_cost numeric(14,2),
    amndt_ind character varying(1),
    tran_id character varying(32),
    receipt_dt date,
    election_other_desc character varying(20),
    transaction_tp character varying(3),
    image_num character varying(18),
    orig_sub_id numeric(19,0),
    file_num numeric(10,0),
    sub_id numeric(19,0),
    link_id numeric(19,0),
    transaction_id numeric(10,0),
    filing_type character(1),
    load_date timestamp without time zone,
    update_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE form_9 (
    form_9_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cmte_id character varying(9),
    ind_org_corp_nm character varying(200),
    ind_org_corp_st1 character varying(34),
    ind_org_corp_st2 character varying(34),
    ind_org_corp_city character varying(30),
    ind_org_corp_st character varying(2),
    ind_org_corp_zip character varying(9),
    addr_chg_flg character varying(1),
    ind_org_corp_emp character varying(38),
    ind_org_corp_occup character varying(38),
    cvg_start_dt date,
    cvg_end_dt date,
    pub_distrib_dt date,
    qual_nonprofit_flg character varying(18),
    segr_bank_acct_flg character varying(1),
    ind_custod_nm character varying(90),
    ind_custod_st1 character varying(34),
    ind_custod_st2 character varying(34),
    ind_custod_city character varying(30),
    ind_custod_st character varying(2),
    ind_custod_zip character varying(9),
    ind_custod_emp character varying(38),
    ind_custod_occup character varying(38),
    cust_l_nm character varying(30),
    cust_f_nm character varying(20),
    cust_m_nm character varying(20),
    cust_prefix character varying(10),
    cust_suffix character varying(10),
    indv_suffix character varying(10),
    indv_prefix character varying(10),
    indv_m_nm character varying(20),
    indv_f_nm character varying(20),
    indv_l_nm character varying(30),
    ttl_dons_this_stmt numeric(14,2),
    ttl_disb_this_stmt numeric(14,2),
    filer_sign_nm character varying(90),
    filer_sign_dt date,
    filer_f_nm character varying(20),
    filer_l_nm character varying(30),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    last_update_dt timestamp without time zone,
    amndt_ind character varying(1),
    receipt_dt date,
    rpt_tp character varying(3),
    comm_title character varying(40),
    rpt_yr numeric(4,0),
    entity_tp character varying(3),
    filer_cd character varying(3),
    filer_cd_desc character varying(20),
    file_num numeric(10,0),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date timestamp without time zone,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date timestamp without time zone,
    update_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE form_91 (
    form_91_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    shr_ex_ctl_ind_nm character varying(90),
    shr_ex_ctl_street1 character varying(34),
    chr_ex_ctl_street2 character varying(34),
    shr_ex_ctl_city character varying(30),
    chr_ex_ctl_st character varying(2),
    shr_ex_ctl_zip character varying(9),
    shr_ex_ctl_employ character varying(38),
    shr_ex_ctl_occup character varying(38),
    shr_ex_ctl_prefix character varying(10),
    shr_ex_ctl_suffix character varying(10),
    shr_ex_ctl_m_nm character varying(20),
    shr_ex_ctl_f_nm character varying(20),
    shr_ex_ctl_l_nm character varying(30),
    amndt_ind character varying(1),
    tran_id character varying(32),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    receipt_dt date,
    orig_sub_id numeric(19,0),
    file_num numeric(10,0),
    sub_id numeric(19,0),
    link_id numeric(19,0),
    transaction_id numeric(10,0),
    filing_type character(1),
    load_date timestamp without time zone,
    update_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE form_94 (
    form_94_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_m_nm character varying(20),
    cand_f_nm character varying(38),
    cand_l_nm character varying(38),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    amndt_ind character varying(1),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_slot character varying(1),
    receipt_dt date,
    orig_sub_id numeric(19,0),
    file_num numeric(10,0),
    sub_id numeric(19,0),
    link_id numeric(19,0),
    transaction_id numeric(10,0),
    filing_type character(1),
    load_date timestamp without time zone,
    update_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE jd_nml_form_76_test (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    org_id character varying(9),
    communication_tp character varying(2),
    communication_tp_desc character varying(40),
    communication_class character varying(1),
    communication_class_desc character varying(90),
    communication_dt timestamp without time zone,
    s_o_ind character varying(3),
    s_o_ind_desc character varying(90),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_rpt_pgi character varying(5),
    s_o_rpt_pgi_desc character varying(10),
    communication_cost numeric(14,2),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    file_num numeric(7,0),
    election_other_desc character varying(20),
    orig_sub_id numeric(19,0),
    transaction_tp character varying(3),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    pg_date timestamp without time zone
);


CREATE TABLE lobbyist_data_view (
    begin_image_num character varying(18),
    cmte_nm character varying(200),
    cmte_id character varying(9),
    receipt_dt timestamp without time zone,
    lobbyist_regist character(1),
    pg_date timestamp without time zone
);


CREATE TABLE mahi_test (
    t1 date,
    t2 timestamp without time zone
);


CREATE TABLE map_states (
    st_desc character varying(40),
    st character varying(2),
    pg_date timestamp without time zone
);


CREATE TABLE markuptab (
    query_id numeric,
    document text,
    pg_date timestamp without time zone
);


CREATE TABLE mv_portal_pac_graph (
    fec_election_yr numeric(4,0),
    cvg_start_dt numeric(8,0),
    cvg_end_dt numeric(8,0),
    update_dt character varying(20),
    org_tp character varying(25),
    pac_to_lead numeric,
    pac_to_pac numeric,
    ind_exp numeric,
    nonfederal_disb numeric,
    pac_to_democrat_cand numeric,
    pac_to_republican_cand numeric,
    pac_to_democrat_pty numeric,
    pac_to_republican_pty numeric,
    other_federal_op_exp numeric,
    total_disbursements numeric,
    pg_date timestamp without time zone
);


CREATE TABLE mv_portal_pac_summary (
    fec_election_yr character varying(32),
    cvg_start_dt numeric,
    cvg_end_dt numeric,
    update_date timestamp without time zone,
    org_tp character varying(25),
    itemized_individual numeric,
    unitemized_individual numeric,
    total_individual numeric,
    party_committees numeric,
    other_committees numeric,
    total_contributions numeric,
    transfers_other_committees numeric,
    loans_received numeric,
    loan_repayments_received numeric,
    offsets_to_op_exp numeric,
    refunds_of_contributions_made numeric,
    other_federal_receipts numeric,
    xfers_from_nonfederal_account numeric,
    transfers_from_levin_account numeric,
    total_transfers numeric,
    total_federal_receipts numeric,
    total_receipts numeric,
    op_exp_federal_share numeric,
    op_exp_nonfederal_share numeric,
    other_federal_op_exp numeric,
    total_operating_expenditures numeric,
    transfers_to_other_committees numeric,
    contributions_cand_cmte numeric,
    independent_expenditures numeric,
    coordinated_expenditures numeric,
    loan_repayments_made numeric,
    loans_made numeric,
    individual_refunds numeric,
    political_party_refunds numeric,
    other_committee_refunds numeric,
    total_contribution_refunds numeric,
    other_disbursements numeric,
    fea_federal_share numeric,
    fea_levin_share numeric,
    fea_federal_funds_only numeric,
    total_fed_election_activity numeric,
    total_disbursements numeric,
    total_federal_disbursements numeric,
    ending_cash_on_hand numeric,
    net_contributions numeric,
    net_op_exp numeric,
    debts_owed_by numeric,
    debts_owed_to numeric,
    pg_date timestamp without time zone
);


CREATE TABLE mv_portal_pty_summary (
    fec_election_yr numeric(4,0) NOT NULL,
    through_dt numeric,
    cmte_id character varying(9) NOT NULL,
    cmte_nm character varying(200),
    cmte_pty_affiliation character varying(3),
    itemized_individual numeric,
    unitemized_individual numeric,
    total_individual numeric,
    party_committees numeric,
    other_committees numeric,
    total_contributions numeric,
    transfers_other_committees numeric,
    loans_received numeric,
    loan_repayments_received numeric,
    offsets_to_op_exp numeric,
    refunds_of_contributions_made numeric,
    other_federal_receipts numeric,
    xfers_from_nonfederal_account numeric,
    transfers_from_levin_account numeric,
    total_transfers numeric,
    total_federal_receipts numeric,
    total_receipts numeric,
    op_exp_federal_share numeric,
    op_exp_nonfederal_share numeric,
    other_federal_op_exp numeric,
    total_operating_expenditures numeric,
    transfers_to_other_committees numeric,
    contributions_cand_cmte numeric,
    independent_expenditures numeric,
    coordinated_expenditures numeric,
    loan_repayments_made numeric,
    loans_made numeric,
    individual_refunds numeric,
    political_party_refunds numeric,
    other_committee_refunds numeric,
    total_contribution_refunds numeric,
    other_disbursements numeric,
    fea_federal_share numeric,
    fea_levin_share numeric,
    fea_federal_funds_only numeric,
    total_fed_election_activity numeric,
    total_disbursements numeric,
    total_federal_disbursements numeric,
    ending_cash_on_hand numeric,
    net_contributions numeric,
    net_op_exp numeric,
    debts_owed_by numeric,
    debts_owed_to numeric,
    pg_date timestamp without time zone
);


CREATE TABLE mv_pres_cand_cmte_sched_state (
    cand_id character varying(9),
    contbr_st character varying(2),
    cand_pty_affiliation character varying(3),
    cand_nm character varying(90),
    net_receipts_state numeric,
    pg_date timestamp without time zone
);


CREATE TABLE nightly_process_error_log (
    code numeric(9,0),
    message character varying(200),
    info character varying(100),
    sub_id numeric(19,0),
    create_date timestamp without time zone,
    pg_date timestamp without time zone
);


CREATE TABLE nml_form_13 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    amndt_ind character varying(1),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    cmte_tp character varying(1),
    cmte_tp_desc character varying(40),
    rpt_tp character varying(3),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    ttl_dons_accepted numeric(14,2),
    ttl_dons_refunded numeric(14,2),
    net_dons numeric(14,2),
    desig_officer_last_nm character varying(30),
    desig_officer_first_nm character varying(20),
    desig_officer_middle_nm character varying(20),
    desig_officer_prefix character varying(10),
    desig_officer_suffix character varying(10),
    designated_officer_nm character varying(90),
    receipt_dt timestamp without time zone,
    signature_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    pg_date timestamp without time zone
);


CREATE TABLE nml_form_4 (
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_tp character varying(1),
    cmte_tp_desc character varying(58),
    cmte_desc character varying(40),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte_per numeric(14,2),
    debts_owed_by_cmte_per numeric(14,2),
    convn_exp_per numeric(14,2),
    ref_reb_ret_convn_exp_per numeric(14,2),
    exp_subject_limits_per numeric(14,2),
    exp_prior_yrs_subject_lim_per numeric(14,2),
    ttl_exp_subject_limits numeric(14,2),
    fed_funds_per numeric(14,2),
    item_convn_exp_contb_per numeric(14,2),
    unitem_convn_exp_contb_per numeric(14,2),
    subttl_convn_exp_contb_per numeric(14,2),
    tranf_from_affiliated_cmte_per numeric(14,2),
    loans_received_per numeric(14,2),
    loan_repymts_received_per numeric(14,2),
    subttl_loan_repymts_per numeric(14,2),
    item_ref_reb_ret_per numeric(14,2),
    unitem_ref_reb_ret_per numeric(14,2),
    subttl_ref_reb_ret_per numeric(14,2),
    item_other_ref_reb_ret_per numeric(14,2),
    unitem_other_ref_reb_ret_per numeric(14,2),
    subttl_other_ref_reb_ret_per numeric(14,2),
    item_other_income_per numeric(14,2),
    unitem_other_income_per numeric(14,2),
    subttl_other_income_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    item_convn_exp_disb_per numeric(14,2),
    unitem_convn_exp_disb_per numeric(14,2),
    subttl_convn_exp_disb_per numeric(14,2),
    tranf_to_affiliated_cmte_per numeric(14,2),
    loans_made_per numeric(14,2),
    loan_repymts_made_per numeric(14,2),
    subttl_loan_repymts_disb_per numeric(14,2),
    item_other_disb_per numeric(14,2),
    unitem_other_disb_per numeric(14,2),
    subttl_other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    coh_begin_calendar_yr numeric(14,2),
    calendar_yr numeric(4,0),
    ttl_receipts_sum_page_ytd numeric(14,2),
    subttl_sum_page_ytd numeric(14,2),
    ttl_disb_sum_page_ytd numeric(14,2),
    coh_coy numeric(14,2),
    convn_exp_ytd numeric(14,2),
    ref_reb_ret_convn_exp_ytd numeric(14,2),
    exp_subject_limits_ytd numeric(14,2),
    exp_prior_yrs_subject_lim_ytd numeric(14,2),
    ttl_exp_subject_limits_ytd numeric(14,2),
    fed_funds_ytd numeric(14,2),
    subttl_convn_exp_contb_ytd numeric(14,2),
    tranf_from_affiliated_cmte_ytd numeric(14,2),
    subttl_loan_repymts_ytd numeric(14,2),
    subttl_ref_reb_ret_deposit_ytd numeric(14,0),
    subttl_other_ref_reb_ret_ytd numeric(14,2),
    subttl_other_income_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    subttl_convn_exp_disb_ytd numeric(14,2),
    tranf_to_affiliated_cmte_ytd numeric(14,2),
    subttl_loan_repymts_disb_ytd numeric(14,2),
    subttl_other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    rpt_yr numeric(4,0),
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone
);


CREATE TABLE nml_form_76 (
    sub_id numeric(19,0) NOT NULL,
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    org_id character varying(9),
    communication_tp character varying(2),
    communication_tp_desc character varying(40),
    communication_class character varying(1),
    communication_class_desc character varying(90),
    communication_dt timestamp without time zone,
    s_o_ind character varying(3),
    s_o_ind_desc character varying(90),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_rpt_pgi character varying(5),
    s_o_rpt_pgi_desc character varying(10),
    communication_cost numeric(14,2),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    receipt_dt timestamp without time zone,
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    file_num numeric(7,0),
    election_other_desc character varying(20),
    orig_sub_id numeric(19,0),
    transaction_tp character varying(3),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    pg_date timestamp without time zone
);


CREATE TABLE nml_form_9 (
    form_tp character varying(8),
    cmte_id character varying(9),
    ind_org_corp_nm character varying(200),
    ind_org_corp_st1 character varying(34),
    ind_org_corp_st2 character varying(34),
    ind_org_corp_city character varying(30),
    ind_org_corp_st character varying(2),
    ind_org_corp_zip character varying(9),
    addr_chg_flg character varying(1),
    ind_org_corp_emp character varying(38),
    ind_org_corp_occup character varying(38),
    beg_cvg_dt timestamp without time zone,
    end_cvg_dt timestamp without time zone,
    pub_distrib_dt timestamp without time zone,
    qual_nonprofit_flg character varying(18),
    segr_bank_acct_flg character varying(1),
    ind_custod_nm character varying(90),
    ind_custod_st1 character varying(34),
    ind_custod_st2 character varying(34),
    ind_custod_city character varying(30),
    ind_custod_st character varying(2),
    ind_custod_zip character varying(9),
    ind_custod_emp character varying(38),
    ind_custod_occup character varying(38),
    ttl_dons_this_stmt numeric(14,2),
    ttl_disb_this_stmt numeric(14,2),
    filer_sign_nm character varying(90),
    filer_sign_dt timestamp without time zone,
    sub_id numeric(19,0) NOT NULL,
    begin_image_num character varying(18),
    end_image_num character varying(18),
    form_tp_desc character varying(90),
    ind_org_corp_st_desc character varying(20),
    addr_chg_flg_desc character varying(20),
    qual_nonprofit_flg_desc character varying(40),
    segr_bank_acct_flg_desc character varying(30),
    ind_custod_st_desc character varying(20),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    amndt_ind character varying(1),
    comm_title character varying(40),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    rpt_yr numeric(4,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    rpt_tp character varying(3),
    entity_tp character varying(3),
    filer_cd character varying(3),
    filer_cd_desc character varying(20),
    indv_l_nm character varying(30),
    indv_f_nm character varying(20),
    indv_m_nm character varying(20),
    indv_prefix character varying(10),
    indv_suffix character varying(10),
    cust_l_nm character varying(30),
    cust_f_nm character varying(20),
    cust_m_nm character varying(20),
    cust_prefix character varying(10),
    cust_suffix character varying(10),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    pg_date timestamp without time zone
);


CREATE TABLE operations_log (
    sub_id numeric(19,0) NOT NULL,
    status_num numeric(3,0),
    cand_cmte_id character varying(9),
    filer_tp character varying(1),
    beg_image_num character varying(18),
    end_image_num character varying(18),
    form_tp character varying(8),
    rpt_yr numeric(4,0),
    amndt_ind character varying(1),
    rpt_tp character varying(3),
    scan_dt timestamp without time zone,
    pass_1_entry_dt timestamp without time zone,
    pass_1_entry_id numeric(3,0),
    pass_1_coding_id numeric(3,0),
    pass_1_verified_dt timestamp without time zone,
    pass_1_verified_id numeric(3,0),
    pass_3_coding_dt timestamp without time zone,
    pass_3_coding_id numeric(3,0),
    pass_3_num_additions numeric(7,0),
    pass_3_num_changes numeric(7,0),
    pass_3_num_deletes numeric(7,0),
    pass_3_entry_began_dt timestamp without time zone,
    pass_3_entry_done_dt timestamp without time zone,
    pass_3_entry_id numeric(3,0),
    error_processing_dt timestamp without time zone,
    rad_sent_dt timestamp without time zone,
    error_listing_review_dt timestamp without time zone,
    error_listing_analyst_id character varying(3),
    error_listing_time numeric(7,0),
    basic_review_dt timestamp without time zone,
    basic_review_analyst_id character varying(3),
    basic_review_time numeric(7,0),
    batch_error_listing_dt timestamp without time zone,
    receipt_dt timestamp without time zone,
    beginning_coverage_dt timestamp without time zone,
    ending_coverage_dt timestamp without time zone,
    create_dt timestamp without time zone,
    last_change_dt timestamp without time zone,
    batch_num numeric(5,0),
    num_tran numeric(7,0),
    batch_close_dt timestamp without time zone,
    return_dt timestamp without time zone,
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    pg_date timestamp without time zone
);


CREATE TABLE original_rfai (
    ref_sub_id numeric(19,0),
    report_id numeric(19,0),
    pg_date timestamp without time zone
);


CREATE TABLE players (
    player_id numeric NOT NULL,
    ao_id numeric,
    role_id numeric,
    entity_id numeric,
    pg_date timestamp without time zone
);


CREATE TABLE pres_ca_cm_sched_a_join_16 (
    cand_id character varying(9),
    contbr_st character varying(2),
    zip_3 character varying(3),
    contb_receipt_amt numeric(14,2),
    election_yr numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE pres_ca_cm_sched_a_join_arc (
    cand_id character varying(9),
    contbr_st character varying(2),
    zip_3 character varying(3),
    contb_receipt_amt numeric(14,2),
    election_yr numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE pres_ca_cm_sched_link_sum_16 (
    contb_range_id numeric(2,0),
    cand_id character varying(9),
    contb_receipt_amt numeric(14,2),
    pg_date timestamp without time zone
);


CREATE TABLE pres_ca_cm_sched_link_sum_arc (
    contb_range_id numeric(2,0),
    cand_id character varying(9),
    contb_receipt_amt numeric(14,2),
    pg_date timestamp without time zone
);


CREATE TABLE pres_ca_cm_sched_state_16 (
    cand_id character varying(9),
    contbr_st character varying(2),
    cand_pty_affiliation character varying(3),
    cand_nm character varying(90),
    net_receipts_state numeric,
    pg_date timestamp without time zone
);


CREATE TABLE pres_ca_cm_sched_state_arc (
    cand_id character varying(9),
    contbr_st character varying(2),
    cand_pty_affiliation character varying(3),
    cand_nm character varying(90),
    net_receipts_state numeric,
    pg_date timestamp without time zone
);


CREATE TABLE pres_cand_cmte_sched_a_join (
    cand_id character varying(9),
    contbr_st character varying(2),
    zip_3 character varying(3),
    contb_receipt_amt numeric(14,2),
    election_yr numeric(4,0),
    pg_date timestamp without time zone
);


CREATE TABLE pres_cand_cmte_sched_link_sum (
    contb_range_id numeric(2,0),
    cand_id character varying(9),
    contb_receipt_amt numeric(14,2),
    pg_date timestamp without time zone
);


CREATE TABLE pres_f3p_totals_ca_cm_link_16 (
    pr_link_id numeric(12,0) NOT NULL,
    cmte_id character varying(9),
    cmte_nm character varying(200),
    filed_cmte_tp character varying(2),
    filed_cmte_dsgn character varying(1),
    link_tp numeric(1,0),
    active character varying(1),
    cand_pty_affiliation character varying(3),
    cand_id character varying(9),
    cand_nm character varying(90),
    election_yr numeric(4,0),
    ttl_contb_per numeric(14,2),
    indv_contb_per numeric,
    pol_pty_cmte_contb_per numeric,
    other_pol_cmte_contb_per numeric,
    cand_contb_per numeric,
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    op_exp_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    coh_cop numeric,
    load_dt timestamp without time zone,
    fndrsg_disb_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    other_disb_per numeric(14,2),
    mst_rct_rpt_yr numeric(4,0),
    mst_rct_rpt_tp character varying(3),
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    ttl_per numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    pg_date timestamp without time zone
);


CREATE TABLE pres_f3p_totals_ca_cm_link_arc (
    pr_link_id numeric(12,0) NOT NULL,
    cmte_id character varying(9),
    cmte_nm character varying(200),
    filed_cmte_tp character varying(2),
    filed_cmte_dsgn character varying(1),
    link_tp numeric(1,0),
    active character varying(1),
    cand_pty_affiliation character varying(3),
    cand_id character varying(9),
    cand_nm character varying(90),
    election_yr numeric(4,0),
    ttl_contb_per numeric(14,2),
    indv_contb_per numeric,
    pol_pty_cmte_contb_per numeric,
    other_pol_cmte_contb_per numeric,
    cand_contb_per numeric,
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    op_exp_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    coh_cop numeric,
    load_dt timestamp without time zone,
    fndrsg_disb_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    other_disb_per numeric(14,2),
    mst_rct_rpt_yr numeric(4,0),
    mst_rct_rpt_tp character varying(3),
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    ttl_per numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    pg_date timestamp without time zone
);


CREATE TABLE pres_f3p_totals_cand_cmte_link (
    pr_link_id numeric(12,0) NOT NULL,
    cmte_id character varying(9),
    cmte_nm character varying(200),
    filed_cmte_tp character varying(2),
    filed_cmte_dsgn character varying(1),
    link_tp numeric(1,0),
    active character varying(1),
    cand_pty_affiliation character varying(3),
    cand_id character varying(9),
    cand_nm character varying(90),
    election_yr numeric(4,0),
    ttl_contb_per numeric(14,2),
    indv_contb_per numeric,
    pol_pty_cmte_contb_per numeric,
    other_pol_cmte_contb_per numeric,
    cand_contb_per numeric,
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    op_exp_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    coh_cop numeric,
    load_dt timestamp without time zone,
    fndrsg_disb_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    other_disb_per numeric(14,2),
    mst_rct_rpt_yr numeric(4,0),
    mst_rct_rpt_tp character varying(3),
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    ttl_per numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_ca_cm_link_16 (
    pr_link_id numeric(12,0) NOT NULL,
    cand_id character varying(9),
    cand_nm character varying(90),
    election_yr numeric(4,0),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    filed_cmte_tp character varying(2),
    filed_cmte_dsgn character varying(1),
    link_tp numeric(1,0),
    active character varying(1),
    cand_pty_affiliation character varying(3),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_ca_cm_link_arc (
    pr_link_id numeric(12,0) NOT NULL,
    cand_id character varying(9),
    cand_nm character varying(90),
    election_yr numeric(4,0),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    filed_cmte_tp character varying(2),
    filed_cmte_dsgn character varying(1),
    link_tp numeric(1,0),
    active character varying(1),
    cand_pty_affiliation character varying(3),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_cand_cmte_link (
    pr_link_id numeric(12,0) NOT NULL,
    cand_id character varying(9),
    cand_nm character varying(90),
    election_yr numeric(4,0),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    filed_cmte_tp character varying(2),
    filed_cmte_dsgn character varying(1),
    link_tp numeric(1,0),
    active character varying(1),
    cand_pty_affiliation character varying(3),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_f3p_totals_16 (
    cand_id character varying(9) NOT NULL,
    cand_nm character varying(90),
    election_yr numeric(4,0) NOT NULL,
    ttl_contb_per numeric(14,2),
    indv_contb_per numeric,
    pol_pty_cmte_contb_per numeric,
    other_pol_cmte_contb_per numeric,
    cand_contb_per numeric,
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    op_exp_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    coh_cop numeric,
    load_dt timestamp without time zone,
    fndrsg_disb_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    other_disb_per numeric(14,2),
    mst_rct_rpt_yr numeric(4,0),
    mst_rct_rpt_tp character varying(3),
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    ttl_per numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_f3p_totals_arc (
    cand_id character varying(9) NOT NULL,
    cand_nm character varying(90),
    election_yr numeric(4,0) NOT NULL,
    ttl_contb_per numeric(14,2),
    indv_contb_per numeric,
    pol_pty_cmte_contb_per numeric,
    other_pol_cmte_contb_per numeric,
    cand_contb_per numeric,
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    op_exp_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    coh_cop numeric,
    load_dt timestamp without time zone,
    fndrsg_disb_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    other_disb_per numeric(14,2),
    mst_rct_rpt_yr numeric(4,0),
    mst_rct_rpt_tp character varying(3),
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    ttl_per numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_form_3p (
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    cmte_id character varying(9),
    cand_id character varying(9),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    cmte_nm character varying(200),
    cand_nm character varying(90),
    coh_cop numeric(14,2),
    indv_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    load_dt timestamp without time zone,
    debts_owed_by_cmte numeric(14,2),
    record_id numeric(16,0) NOT NULL,
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    op_exp_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    receipt_dt timestamp without time zone,
    load_status numeric(1,0),
    fndrsg_disb_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    other_disb_per numeric(14,2),
    election_yr numeric(4,0),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    amndt_ind character varying(1),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    addr_chg_flg character varying(1),
    activity_primary character varying(1),
    activity_general character varying(1),
    term_rpt_flag character varying(1),
    rpt_pgi character varying(5),
    election_dt timestamp without time zone,
    election_st character varying(2),
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    ttl_per numeric(14,2),
    fed_funds_ytd numeric(14,2),
    indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd numeric(14,2),
    other_pol_cmte_contb_ytd numeric(14,2),
    cand_contb_ytd numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    tranf_from_affiliated_cmte_ytd numeric(14,2),
    loans_received_from_cand_ytd numeric(14,2),
    other_loans_received_ytd numeric(14,2),
    ttl_loans_received_ytd numeric(14,2),
    offsets_to_op_exp_ytd numeric(14,2),
    offsets_to_fndrsg_exp_ytd numeric(14,2),
    offsets_to_legal_acctg_ytd numeric(14,2),
    ttl_offsets_to_op_exp_ytd numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    op_exp_ytd numeric(14,2),
    tranf_to_other_auth_cmte_ytd numeric(14,2),
    fndrsg_disb_ytd numeric(14,2),
    exempt_legal_acctg_disb_ytd numeric(14,2),
    repymts_loans_made_cand_ytd numeric(14,2),
    repymts_other_loans_ytd numeric(14,2),
    ttl_loan_repymts_made_ytd numeric(14,2),
    ref_indv_contb_ytd numeric(14,2),
    ref_pol_pty_cmte_contb_ytd numeric(14,2),
    ref_other_pol_cmte_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    ttl_ytd numeric(14,2),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    indv_item_contb_ytd numeric(14,2),
    indv_unitem_contb_ytd numeric(14,2),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_form_3p_16 (
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    cmte_id character varying(9),
    cand_id character varying(9),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    cmte_nm character varying(200),
    cand_nm character varying(90),
    coh_cop numeric(14,2),
    indv_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    load_dt timestamp without time zone,
    debts_owed_by_cmte numeric(14,2),
    record_id numeric(16,0) NOT NULL,
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    op_exp_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    receipt_dt timestamp without time zone,
    load_status numeric(1,0),
    fndrsg_disb_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    other_disb_per numeric(14,2),
    election_yr numeric(4,0),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    amndt_ind character varying(1),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    addr_chg_flg character varying(1),
    activity_primary character varying(1),
    activity_general character varying(1),
    term_rpt_flag character varying(1),
    rpt_pgi character varying(5),
    election_dt timestamp without time zone,
    election_st character varying(2),
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    ttl_per numeric(14,2),
    fed_funds_ytd numeric(14,2),
    indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd numeric(14,2),
    other_pol_cmte_contb_ytd numeric(14,2),
    cand_contb_ytd numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    tranf_from_affiliated_cmte_ytd numeric(14,2),
    loans_received_from_cand_ytd numeric(14,2),
    other_loans_received_ytd numeric(14,2),
    ttl_loans_received_ytd numeric(14,2),
    offsets_to_op_exp_ytd numeric(14,2),
    offsets_to_fndrsg_exp_ytd numeric(14,2),
    offsets_to_legal_acctg_ytd numeric(14,2),
    ttl_offsets_to_op_exp_ytd numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    op_exp_ytd numeric(14,2),
    tranf_to_other_auth_cmte_ytd numeric(14,2),
    fndrsg_disb_ytd numeric(14,2),
    exempt_legal_acctg_disb_ytd numeric(14,2),
    repymts_loans_made_cand_ytd numeric(14,2),
    repymts_other_loans_ytd numeric(14,2),
    ttl_loan_repymts_made_ytd numeric(14,2),
    ref_indv_contb_ytd numeric(14,2),
    ref_pol_pty_cmte_contb_ytd numeric(14,2),
    ref_other_pol_cmte_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    ttl_ytd numeric(14,2),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    indv_item_contb_ytd numeric(14,2),
    indv_unitem_contb_ytd numeric(14,2),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_form_3p_arc (
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    cmte_id character varying(9),
    cand_id character varying(9),
    cvg_start_dt timestamp without time zone,
    cvg_end_dt timestamp without time zone,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    cmte_nm character varying(200),
    cand_nm character varying(90),
    coh_cop numeric(14,2),
    indv_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    load_dt timestamp without time zone,
    debts_owed_by_cmte numeric(14,2),
    record_id numeric(16,0) NOT NULL,
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    op_exp_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    receipt_dt timestamp without time zone,
    load_status numeric(1,0),
    fndrsg_disb_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    other_disb_per numeric(14,2),
    election_yr numeric(4,0),
    begin_image_num character varying(18),
    end_image_num character varying(18),
    amndt_ind character varying(1),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    addr_chg_flg character varying(1),
    activity_primary character varying(1),
    activity_general character varying(1),
    term_rpt_flag character varying(1),
    rpt_pgi character varying(5),
    election_dt timestamp without time zone,
    election_st character varying(2),
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    ttl_per numeric(14,2),
    fed_funds_ytd numeric(14,2),
    indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd numeric(14,2),
    other_pol_cmte_contb_ytd numeric(14,2),
    cand_contb_ytd numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    tranf_from_affiliated_cmte_ytd numeric(14,2),
    loans_received_from_cand_ytd numeric(14,2),
    other_loans_received_ytd numeric(14,2),
    ttl_loans_received_ytd numeric(14,2),
    offsets_to_op_exp_ytd numeric(14,2),
    offsets_to_fndrsg_exp_ytd numeric(14,2),
    offsets_to_legal_acctg_ytd numeric(14,2),
    ttl_offsets_to_op_exp_ytd numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    op_exp_ytd numeric(14,2),
    tranf_to_other_auth_cmte_ytd numeric(14,2),
    fndrsg_disb_ytd numeric(14,2),
    exempt_legal_acctg_disb_ytd numeric(14,2),
    repymts_loans_made_cand_ytd numeric(14,2),
    repymts_other_loans_ytd numeric(14,2),
    ttl_loan_repymts_made_ytd numeric(14,2),
    ref_indv_contb_ytd numeric(14,2),
    ref_pol_pty_cmte_contb_ytd numeric(14,2),
    ref_other_pol_cmte_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    ttl_ytd numeric(14,2),
    tres_sign_nm character varying(90),
    tres_sign_dt timestamp without time zone,
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    indv_item_contb_ytd numeric(14,2),
    indv_unitem_contb_ytd numeric(14,2),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_form_3p_totals (
    cand_id character varying(9) NOT NULL,
    cand_nm character varying(90),
    election_yr numeric(4,0) NOT NULL,
    ttl_contb_per numeric(14,2),
    indv_contb_per numeric,
    pol_pty_cmte_contb_per numeric,
    other_pol_cmte_contb_per numeric,
    cand_contb_per numeric,
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    op_exp_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    coh_cop numeric,
    load_dt timestamp without time zone,
    fndrsg_disb_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    other_disb_per numeric(14,2),
    mst_rct_rpt_yr numeric(4,0),
    mst_rct_rpt_tp character varying(3),
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    ttl_per numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_sched_a (
    file_num numeric(7,0),
    cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    contbr_nm character varying(200),
    contb_receipt_amt numeric(14,2),
    contb_receipt_dt timestamp without time zone,
    contbr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    memo_cd character varying(1),
    memo_text character varying(100),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    zip_3 character varying(3),
    contbr_nm_last character varying(30),
    contbr_nm_first character varying(20),
    contbr_nm_middle character varying(20),
    contbr_nm_prefix character varying(10),
    contbr_nm_suffix character varying(10),
    form_tp character varying(8),
    load_status numeric(1,0),
    contbr_org_nm character varying(200),
    record_id numeric(16,0) NOT NULL,
    receipt_desc character varying(100),
    load_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    election_yr numeric(4,0),
    election_tp character varying(5),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_sched_a_16 (
    file_num numeric(7,0),
    cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    contbr_nm character varying(200),
    contb_receipt_amt numeric(14,2),
    contb_receipt_dt timestamp without time zone,
    contbr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    memo_cd character varying(1),
    memo_text character varying(100),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    zip_3 character varying(3),
    contbr_nm_last character varying(30),
    contbr_nm_first character varying(20),
    contbr_nm_middle character varying(20),
    contbr_nm_prefix character varying(10),
    contbr_nm_suffix character varying(10),
    form_tp character varying(8),
    load_status numeric(1,0),
    contbr_org_nm character varying(200),
    record_id numeric(16,0) NOT NULL,
    receipt_desc character varying(100),
    load_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    election_yr numeric(4,0),
    election_tp character varying(5),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_sched_a_arc (
    file_num numeric(7,0),
    cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    contbr_nm character varying(200),
    contb_receipt_amt numeric(14,2),
    contb_receipt_dt timestamp without time zone,
    contbr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    memo_cd character varying(1),
    memo_text character varying(100),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    zip_3 character varying(3),
    contbr_nm_last character varying(30),
    contbr_nm_first character varying(20),
    contbr_nm_middle character varying(20),
    contbr_nm_prefix character varying(10),
    contbr_nm_suffix character varying(10),
    form_tp character varying(8),
    load_status numeric(1,0),
    contbr_org_nm character varying(200),
    record_id numeric(16,0) NOT NULL,
    receipt_desc character varying(100),
    load_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    election_yr numeric(4,0),
    election_tp character varying(5),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_sched_b (
    file_num numeric(7,0),
    cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    recipient_nm character varying(200),
    disb_amt numeric(14,2),
    disb_dt timestamp without time zone,
    recipient_city character varying(30),
    recipient_st character varying(2),
    recipient_zip character varying(9),
    disb_desc character varying(40),
    memo_cd character varying(1),
    memo_text character varying(100),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    form_tp character varying(8),
    record_id numeric(16,0) NOT NULL,
    cmte_nm character varying(200),
    load_status numeric(1,0),
    load_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    election_yr numeric(4,0),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    election_tp character varying(5),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_sched_b_16 (
    file_num numeric(7,0),
    cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    recipient_nm character varying(200),
    disb_amt numeric(14,2),
    disb_dt timestamp without time zone,
    recipient_city character varying(30),
    recipient_st character varying(2),
    recipient_zip character varying(9),
    disb_desc character varying(40),
    memo_cd character varying(1),
    memo_text character varying(100),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    form_tp character varying(8),
    record_id numeric(16,0) NOT NULL,
    cmte_nm character varying(200),
    load_status numeric(1,0),
    load_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    election_yr numeric(4,0),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    election_tp character varying(5),
    pg_date timestamp without time zone
);


CREATE TABLE pres_nml_sched_b_arc (
    file_num numeric(7,0),
    cmte_id character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    recipient_nm character varying(200),
    disb_amt numeric(14,2),
    disb_dt timestamp without time zone,
    recipient_city character varying(30),
    recipient_st character varying(2),
    recipient_zip character varying(9),
    disb_desc character varying(40),
    memo_cd character varying(1),
    memo_text character varying(100),
    tran_id character varying(32),
    back_ref_tran_id character varying(32),
    form_tp character varying(8),
    record_id numeric(16,0) NOT NULL,
    cmte_nm character varying(200),
    load_status numeric(1,0),
    load_dt timestamp without time zone,
    rpt_yr numeric(4,0),
    election_yr numeric(4,0),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    election_tp character varying(5),
    pg_date timestamp without time zone
);


CREATE TABLE program_active_cycles (
    program_name character varying(30) NOT NULL,
    program_description character varying(100),
    fec_election_yr numeric NOT NULL,
    active character varying(1),
    default_select character varying(1),
    job_name character varying(30),
    pg_date timestamp without time zone
);


CREATE TABLE real_efile_f1 (
    repid numeric,
    comid character varying(9),
    com_name character varying(200),
    com_str1 character varying(34),
    com_str2 character varying(34),
    com_city character varying(30),
    com_state character varying(2),
    com_zip character varying(9),
    sub_date date,
    amend_name character varying(1),
    amend_address character varying(1),
    cmte_type character varying(1),
    canid character varying(9),
    can_lname character varying(90),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    office character varying(1),
    el_state character varying(2),
    district character varying(2),
    party character varying(3),
    party_code character varying(3),
    lrpac5e character varying(1),
    lrpac5f character varying(1),
    lead_pac character varying(1),
    aff_comid character varying(9),
    aff_canid character varying(9),
    ac_name character varying(200),
    aff_fname character varying(20),
    aff_mname character varying(20),
    aff_prefix character varying(10),
    aff_suffix character varying(10),
    acstr1 character varying(34),
    acstr2 character varying(34),
    accity character varying(30),
    acstate character varying(2),
    aczip character varying(9),
    relations character varying(38),
    organ_type character varying(1),
    affrel_code character varying(3),
    c_lname character varying(90),
    c_fname character varying(20),
    c_mname character varying(20),
    c_prefix character varying(10),
    c_suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    title character varying(20),
    phone character varying(10),
    t_lname character varying(90),
    t_fname character varying(20),
    t_mname character varying(20),
    t_prefix character varying(10),
    t_suffix character varying(10),
    tstr1 character varying(34),
    tstr2 character varying(34),
    tcity character varying(30),
    tstate character varying(2),
    tzip character varying(9),
    ttitle character varying(20),
    tphone character varying(10),
    d_lname character varying(90),
    d_fname character varying(20),
    d_mname character varying(20),
    d_prefix character varying(10),
    d_suffix character varying(10),
    dstr1 character varying(34),
    dstr2 character varying(34),
    dcity character varying(30),
    dstate character varying(2),
    dzip character varying(9),
    dtitle character varying(20),
    dphone character varying(10),
    b_lname character varying(200),
    bstr1 character varying(34),
    bstr2 character varying(34),
    bcity character varying(30),
    bstate character varying(2),
    bzip character varying(9),
    bname_2 character varying(200),
    bstr1_2 character varying(34),
    bstr2_2 character varying(34),
    bcity_2 character varying(30),
    bstate_2 character varying(2),
    bzip_2 character varying(9),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    amend_email character varying(1),
    email character varying(90),
    amend_url character varying(1),
    url character varying(90),
    fax character varying(12),
    imageno numeric,
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f10 (
    repid numeric(12,0),
    comid character varying(9),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    canid character varying(9),
    off character varying(1),
    state character varying(2),
    dist character varying(2),
    com_name character varying(200),
    com_str1 character varying(34),
    com_str2 character varying(34),
    com_city character varying(30),
    com_state character varying(2),
    com_zip character varying(9),
    previous numeric,
    total numeric,
    ctd numeric,
    s_lname character varying(90),
    s_fname character varying(20),
    s_mname character varying(20),
    s_prefix character varying(10),
    s_suffix character varying(10),
    sign_date date,
    f6 character varying(1),
    can_emp character varying(90),
    can_occ character varying(90),
    imageno character varying(22),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f105 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    exp_date date,
    item_elect_cd character varying(5),
    item_elect_oth character varying(20),
    amount numeric(12,2),
    loan character varying(1),
    amend character varying(1),
    tran_id character varying(32),
    imageno character varying(22),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f13 (
    repid numeric(12,0),
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    chgadd character varying(1),
    rptcode character varying(3),
    amend_date date,
    frm_date date,
    thr_date date,
    accepted numeric,
    refund numeric,
    net numeric,
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    f13_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f132 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    org character varying(200),
    last_nm character varying(30),
    first_nm character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    receipt_date date,
    received numeric,
    aggregate numeric,
    memo_code character varying(1),
    memo_text character varying(100),
    amend character varying(1),
    tran_id character varying(32),
    br_tran_id character varying(32),
    br_sname character varying(8),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f133 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    org character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    ref_date date,
    expended numeric,
    memo_code character varying(1),
    memo_text character varying(100),
    amend character varying(1),
    tran_id character varying(32),
    br_tran_id character varying(32),
    br_sname character varying(8),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f1m (
    repid numeric(12,0),
    comid character varying(9),
    com_name character varying(200),
    com_str1 character varying(34),
    com_str2 character varying(34),
    com_city character varying(30),
    com_state character varying(2),
    com_zip character varying(9),
    ctype character varying(1),
    aff_date date,
    aff_comid character varying(9),
    aff_name character varying(200),
    can1_id character varying(9),
    can1_lname character varying(90),
    can1_fname character varying(20),
    can1_mname character varying(20),
    can1_prefix character varying(10),
    can1_suffix character varying(10),
    can1_office character varying(1),
    can1_el_state character varying(2),
    can1_district character varying(2),
    can1_con date,
    can2_id character varying(9),
    can2_lname character varying(90),
    can2_fname character varying(20),
    can2_mname character varying(20),
    can2_prefix character varying(10),
    can2_suffix character varying(10),
    can2_office character varying(1),
    can2_el_state character varying(2),
    can2_district character varying(2),
    can2_con date,
    can3_id character varying(9),
    can3_lname character varying(90),
    can3_fname character varying(20),
    can3_mname character varying(20),
    can3_prefix character varying(10),
    can3_suffix character varying(10),
    can3_office character varying(1),
    can3_el_state character varying(2),
    can3_district character varying(2),
    can3_con date,
    can4_id character varying(9),
    can4_con date,
    can4_lname character varying(90),
    can4_fname character varying(20),
    can4_mname character varying(20),
    can4_prefix character varying(10),
    can4_suffix character varying(10),
    can4_office character varying(1),
    can4_el_state character varying(2),
    can4_district character varying(2),
    can5_id character varying(9),
    can5_lname character varying(90),
    can5_fname character varying(20),
    can5_mname character varying(20),
    can5_prefix character varying(10),
    can5_suffix character varying(10),
    can5_office character varying(1),
    can5_el_state character varying(2),
    can5_district character varying(2),
    can5_con date,
    date_51 date,
    orig_date date,
    metreq_date date,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f1s (
    repid numeric(12,0),
    comid character varying(9),
    jfrcomname character varying(200),
    jfrcomid character varying(9),
    aff_comid character varying(9),
    aff_canid character varying(9),
    ac_name character varying(200),
    aff_fname character varying(20),
    aff_mname character varying(20),
    aff_prefix character varying(10),
    aff_suffix character varying(10),
    acstr1 character varying(34),
    acstr2 character varying(34),
    accity character varying(30),
    acstate character varying(2),
    aczip character varying(9),
    relations character varying(38),
    organ_type character varying(1),
    affrel_code character varying(3),
    d_lname character varying(90),
    d_fname character varying(20),
    d_mname character varying(20),
    d_prefix character varying(10),
    d_suffix character varying(10),
    dstr1 character varying(34),
    dstr2 character varying(34),
    dcity character varying(30),
    dstate character varying(2),
    dzip character varying(9),
    dtitle character varying(20),
    dphone character varying(10),
    b_lname character varying(200),
    bstr1 character varying(34),
    bstr2 character varying(34),
    bcity character varying(30),
    bstate character varying(2),
    bzip character varying(9),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f2 (
    repid numeric(12,0),
    canid character varying(9),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    amend_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    pty character varying(3),
    office character varying(1),
    el_state character varying(2),
    district numeric,
    el_year character varying(4),
    comid character varying(9),
    c_name character varying(200),
    c_str1 character varying(34),
    c_str2 character varying(34),
    c_city character varying(30),
    c_state character varying(2),
    c_zip character varying(9),
    acomid character varying(9),
    ac_name character varying(200),
    ac_str1 character varying(34),
    ac_str2 character varying(34),
    ac_city character varying(30),
    ac_state character varying(2),
    ac_zip character varying(9),
    sign_date date,
    per_fund numeric,
    gen_fund numeric,
    can_lname character varying(30),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f24 (
    repid numeric(12,0),
    comid character varying(9),
    orgamd_date date,
    name character varying(34),
    str1 character varying(34),
    str2 character varying(30),
    city character varying(2),
    state character varying(9),
    zip character varying(90),
    lname character varying(20),
    fname character varying(20),
    mname character varying(10),
    prefix character varying(10),
    suffix character varying(7),
    sign_date date,
    rpttype character varying(22),
    imageno numeric(19,0)
);


CREATE TABLE real_efile_f2s (
    repid numeric(12,0),
    canid character varying(9),
    acomid character varying(9),
    ac_name character varying(200),
    ac_str1 character varying(34),
    ac_str2 character varying(34),
    ac_city character varying(30),
    ac_state character varying(2),
    ac_zip character varying(9),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f3 (
    repid numeric(12,0),
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    amend_addr character varying(1),
    rptcode character varying(3),
    rptpgi character varying(5),
    els character varying(2),
    eld numeric,
    el_date date,
    el_state character varying(2),
    act_pri character varying(1),
    act_gen character varying(1),
    act_spe character varying(1),
    act_run character varying(1),
    from_date date,
    through_date date,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    cash_hand numeric,
    canid character varying(9),
    can_lname character varying(90),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    f3z1 character varying(3),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f3l (
    repid numeric(12,0),
    comid character varying(9),
    com_name character varying(200),
    amend_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    els character varying(2),
    eld numeric,
    rptcode character varying(3),
    el_date date,
    el_state character varying(2),
    semiperiod character varying(1),
    from_date date,
    through_date date,
    semijun character varying(1),
    semidec character varying(1),
    bundledcont numeric,
    semibuncont numeric,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f3p (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    c_name character varying(200),
    c_str1 character varying(34),
    c_str2 character varying(34),
    c_city character varying(30),
    c_state character varying(2),
    c_zip character varying(9),
    amend_addr character varying(1),
    rptcode character varying(3),
    rptpgi character varying(5),
    el_date date,
    el_state character varying(2),
    act_pri character varying(1),
    act_gen character varying(1),
    from_date date,
    through_date date,
    cash numeric,
    tot_rec numeric,
    sub numeric,
    tot_dis numeric,
    cash_close numeric,
    debts_to numeric,
    debts_by numeric,
    expe numeric,
    net_con numeric,
    net_op numeric,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f3ps (
    repid numeric(12,0),
    comid character varying(9),
    ge_date date,
    dayafterge_dt date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f3s (
    repid numeric(12,0),
    comid character varying(9),
    ge_date date,
    dayafterge_dt date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f3x (
    repid numeric(12,0) NOT NULL,
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    amend_addr character varying(1),
    qual character varying(1),
    rptcode character varying(3),
    rptpgi character varying(5),
    el_date date,
    el_state character varying(2),
    from_date date,
    through_date date,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    date_signed date,
    sum_year character varying(4),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f3z (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    total character varying(1),
    comid character varying(9),
    acomid character varying(9),
    pccname character varying(200),
    acom_name date,
    from_date date,
    through_date numeric,
    a numeric,
    b numeric,
    c numeric,
    d numeric,
    e numeric,
    f numeric,
    g numeric,
    h numeric,
    i numeric,
    j numeric,
    k numeric,
    l numeric,
    m numeric,
    n numeric,
    o numeric,
    p numeric,
    q numeric,
    r numeric,
    s numeric,
    t numeric,
    u numeric,
    v numeric,
    w numeric,
    x numeric,
    y numeric,
    z numeric,
    aa numeric,
    bb numeric,
    cc numeric,
    imageno timestamp without time zone
);


CREATE TABLE real_efile_f4 (
    repid numeric(12,0),
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    con_type character varying(1),
    description character varying(40),
    rptcode character varying(3),
    from_date date,
    through_date date,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    year character varying(4),
    sign_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f5 (
    repid numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    com_name character varying(200),
    com_fname character varying(20),
    com_mname character varying(20),
    com_prefix character varying(10),
    com_suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(10),
    amend_addr character varying(1),
    qual character varying(1),
    indemp character varying(38),
    indocc character varying(38),
    rptcode character varying(3),
    rptpgi character varying(5),
    el_date date,
    el_state character varying(2),
    orig_amend_date date,
    from_date date,
    through_date numeric,
    total_con numeric,
    total_expe character varying(22),
    pcf_lname character varying(38),
    pcf_fname character varying(20),
    pcf_mname character varying(20),
    pcf_prefix character varying(10),
    pcf_suffix date,
    sign_date date,
    not_date date,
    expire_date character varying(7),
    lname character varying(38),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    h_code numeric,
    imageno timestamp without time zone
);


CREATE TABLE real_efile_f56 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    indemp character varying(38),
    indocc character varying(38),
    con_date date,
    amount numeric(12,2),
    other_comid character varying(9),
    other_canid character varying(9),
    can_name character varying(90),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    other_name character varying(90),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    amend character varying(1),
    tran_id character varying(32),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f57 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    exp_desc character varying(100),
    exp_date date,
    amount numeric(12,2),
    supop character varying(3),
    other_canid character varying(9),
    other_comid character varying(9),
    so_canid character varying(9),
    so_can_name character varying(90),
    so_can_fname character varying(20),
    so_can_mname character varying(20),
    so_can_prefix character varying(10),
    so_can_suffix character varying(10),
    so_can_off character varying(1),
    so_can_state character varying(2),
    so_can_dist character varying(2),
    can_name character varying(90),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    other_name character varying(90),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    amend character varying(1),
    tran_id character varying(32),
    cat_code character varying(3),
    trans_code character varying(3),
    ytd numeric,
    item_elect_cd character varying(5),
    item_elect_oth character varying(20),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f6 (
    repid numeric(12,0),
    comid character varying(9),
    orgamd_date character varying(7),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    canid character varying(9),
    lname character varying(38),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    office character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    sign_lname character varying(30),
    sign_fname character varying(20),
    sign_mname character varying(20),
    sign_prefix character varying(10),
    sign_suffix date,
    sign_date numeric,
    imageno timestamp without time zone
);


CREATE TABLE real_efile_f65 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    indemp character varying(38),
    indocc character varying(38),
    con_date date,
    amount numeric(12,2),
    other_canid character varying(9),
    other_comid character varying(9),
    can_name character varying(90),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    other_name character varying(90),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    amend character varying(1),
    tran_id character varying(32),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f7 (
    repid numeric(12,0),
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    org_type character varying(1),
    rptcode character varying(3),
    el_date date,
    el_state character varying(2),
    from_date date,
    through_date date,
    tot_cost numeric,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    title character varying(21),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f76 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    comm_type character varying(2),
    description character varying(40),
    comm_class character varying(1),
    comm_date date,
    supop character varying(3),
    other_canid character varying(9),
    can_name character varying(90),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    rptpgi character varying(5),
    elec_desc character varying(20),
    comm_cost numeric,
    amend character varying(1),
    tran_id character varying(32),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f8 (
    repid numeric(12,0),
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    l1 numeric,
    l1a date,
    l2 numeric,
    l3 numeric,
    l4 numeric,
    l5 numeric,
    l6 numeric,
    l7 numeric,
    l8 numeric,
    l9 numeric,
    l10 numeric,
    l11 character varying(1),
    l11d date,
    l12 character varying(1),
    l12d character varying(300),
    l13 character varying(1),
    l13d character varying(100),
    l14 character varying(1),
    l15 character varying(1),
    l15d character varying(100),
    suff character varying(1),
    suff_des character varying(100),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imageno character varying(22),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f8ii (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    a_lname character varying(90),
    a_fname character varying(20),
    a_mname character varying(20),
    a_prefix character varying(10),
    a_suffix character varying(10),
    creditor_type character varying(3),
    inc_date date,
    amount_owed numeric(12,2),
    amount_off numeric(12,2),
    adesc character varying(100),
    bdesc character varying(100),
    cdesc character varying(100),
    dyn character varying(1),
    ddesc character varying(100),
    eyn character varying(1),
    edesc character varying(100),
    credit_comid character varying(9),
    credit_canid character varying(9),
    credit_lname character varying(30),
    credit_fname character varying(20),
    credit_mname character varying(20),
    credit_prefix character varying(10),
    credit_suffix character varying(10),
    credit_off character varying(1),
    credit_state character varying(2),
    credit_dist character varying(2),
    sign_date date,
    amend character varying(1),
    tran_id character varying(32),
    imageno character varying(22),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f8iii (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    creditor_type character varying(3),
    yesno character varying(1),
    inc_date date,
    amount_owed numeric(12,2),
    amount_exp numeric(12,2),
    credit_comid character varying(9),
    credit_canid character varying(9),
    credit_lname character varying(30),
    credit_fname character varying(20),
    credit_mname character varying(20),
    credit_prefix character varying(10),
    credit_suffix character varying(10),
    credit_off character varying(1),
    credit_state character varying(2),
    credit_dist character varying(2),
    amend character varying(1),
    tran_id character varying(32),
    imageno character varying(22),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f9 (
    repid numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    addr_chg character varying(1),
    empl character varying(38),
    occup character varying(38),
    from_date date,
    through_date date,
    public_dist date,
    title character varying(40),
    qual_np character varying(1),
    filer_code character varying(3),
    filercd_desc character varying(20),
    segreg_bnk character varying(1),
    c_lname character varying(90),
    c_fname character varying(20),
    c_mname character varying(20),
    c_prefix character varying(10),
    c_suffix character varying(10),
    c_str1 character varying(34),
    c_str2 character varying(34),
    c_city character varying(30),
    c_state character varying(2),
    c_zip character varying(9),
    c_empl character varying(38),
    c_occup character varying(38),
    total numeric,
    disburs numeric,
    s_lname character varying(90),
    s_fname character varying(20),
    s_mname character varying(20),
    s_prefix character varying(10),
    s_suffix character varying(10),
    sign_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f91 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    empl character varying(38),
    occup character varying(38),
    amend character varying(1),
    tran_id character varying(32),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f92 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    item_elect_cd character varying(5),
    item_elect_oth character varying(20),
    indemp character varying(38),
    indocc character varying(38),
    ytd numeric,
    receipt_date date,
    amount numeric(12,2),
    trans_code character varying(3),
    trans_desc character varying(40),
    other_id character varying(9),
    canid character varying(9),
    can_name character varying(90),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    con_name character varying(200),
    con_str1 character varying(34),
    con_str2 character varying(34),
    con_city character varying(30),
    con_state character varying(2),
    con_zip character varying(9),
    memo_code character varying(1),
    memo_text character varying(100),
    amend character varying(1),
    tran_id character varying(32),
    br_tran_id character varying(32),
    br_sname character varying(8),
    nc_softacct character varying(9),
    limit_ind character varying(1),
    con_orgname character varying(200),
    con_lname character varying(30),
    con_fname character varying(20),
    con_mname character varying(20),
    con_prefix character varying(10),
    con_suffix character varying(10),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f93 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    trans_code character varying(3),
    trans_desc character varying(100),
    item_elect_cd character varying(5),
    item_elect_oth character varying(20),
    exp_date date,
    amount numeric(12,2),
    employer character varying(38),
    occupation character varying(38),
    other_id character varying(9),
    canid character varying(9),
    can_name character varying(90),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    con_name character varying(200),
    con_str1 character varying(34),
    con_str2 character varying(34),
    con_city character varying(30),
    con_state character varying(2),
    con_zip character varying(9),
    memo_code character varying(1),
    memo_text character varying(100),
    amend character varying(1),
    tran_id character varying(32),
    br_tran_id character varying(32),
    br_sname character varying(8),
    nc_softacct character varying(9),
    refund character varying(1),
    cat_code character varying(3),
    com_date date,
    rec_orgname character varying(200),
    rec_lname character varying(30),
    rec_fname character varying(20),
    rec_mname character varying(20),
    rec_prefix character varying(10),
    rec_suffix character varying(10),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f94 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    canid character varying(9),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    off character varying(1),
    state character varying(2),
    dist character varying(2),
    item_elect_cd character varying(5),
    item_elect_oth character varying(20),
    amend character varying(1),
    tran_id character varying(32),
    br_tran_id character varying(32),
    br_sname character varying(8),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_f99 (
    repid numeric(12,0),
    comid character varying(9),
    name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    text_code character varying(3),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_guarantors (
    repid numeric(12,0),
    comid character varying(9),
    line_num character varying(8),
    tran_id character varying(32),
    refid character varying(32),
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    indemp character varying(38),
    indocc character varying(38),
    amt_guar numeric(12,2),
    amend character varying(1),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_h1 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    nat_rate numeric,
    hs_min numeric,
    hs_persupport numeric,
    hs_pernonfed numeric,
    hs_actsupport numeric,
    hs_actnonfed numeric,
    hs_actperfed numeric,
    est_persupport numeric,
    est_pernonfed numeric,
    act_support numeric,
    act_nonfed numeric,
    act_perfed numeric,
    pres character varying(1),
    sen character varying(1),
    hse character varying(1),
    subtotal character varying(1),
    gov character varying(1),
    other_sw character varying(1),
    state_sen character varying(1),
    state_rep character varying(1),
    local character varying(1),
    extra character varying(1),
    sub character varying(2),
    total character varying(2),
    fed_per numeric,
    amend character varying(1),
    tran_id character varying(32),
    memo_code character varying(1),
    memo_text character varying(100),
    slp_pres character varying(1),
    slp_pres_sen character varying(1),
    slp_sen character varying(1),
    slp_non character varying(1),
    min_fedper character varying(1),
    federal numeric,
    non_federal numeric,
    admin_ratio character varying(1),
    gen_vd_ratio character varying(1),
    pub_crp_ratio character varying(1),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_h2 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    event character varying(90),
    fundraising character varying(1),
    exempt character varying(1),
    direct character varying(1),
    ratio_code character varying(1),
    fed_per numeric,
    nonfed_per numeric,
    amend character varying(1),
    tran_id character varying(32),
    memo_code character varying(1),
    memo_text character varying(100),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_h3 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    refid character varying(32),
    account character varying(90),
    event character varying(90),
    event_type character varying(2),
    rec_date date,
    amount numeric(12,2),
    tot_amount numeric(12,2),
    amend character varying(1),
    tran_id character varying(32),
    memo_code character varying(1),
    memo_text character varying(100),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_h4_2 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    tran_id character varying(32),
    br_tran_id character varying(20),
    br_sname character varying(8),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    description character varying(100),
    event_date date,
    amount numeric(12,2),
    fed_share numeric,
    nonfed_share numeric,
    event_ytd numeric,
    trans_code character varying(3),
    purpose character varying(100),
    cat_code character varying(3),
    admin_ind character varying(1),
    fundraising character varying(1),
    exempt_ind character varying(1),
    gen_vote character varying(1),
    voter_drive character varying(1),
    support character varying(1),
    activity_pc character varying(1),
    memo_code character varying(1),
    memo_text character varying(100),
    amend character varying(1),
    imageno numeric(19,0),
    used timestamp without time zone,
    upr_tran_id character varying(32)
);


CREATE TABLE real_efile_h5 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    receipt_date date,
    reg numeric,
    id numeric,
    gotv numeric,
    camp numeric,
    total numeric,
    amend character varying(1),
    tran_id character varying(32),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_h6 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    cat_code character varying(3),
    trans_code character varying(3),
    trans_desc character varying(100),
    exp_date date,
    total numeric,
    federal numeric,
    levin numeric,
    reg character varying(1),
    id character varying(1),
    gotv character varying(1),
    camp character varying(1),
    ytd numeric,
    exp_desc character varying(100),
    other_id character varying(9),
    canid character varying(9),
    can_lname character varying(90),
    can_fname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    con_comid character varying(9),
    con_name character varying(200),
    con_str1 character varying(34),
    con_str2 character varying(34),
    con_city character varying(30),
    con_state character varying(2),
    con_zip character varying(9),
    memo_code character varying(1),
    memo_text character varying(100),
    amend character varying(1),
    tran_id character varying(32),
    br_tran_id character varying(32),
    br_sname character varying(8),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_i_sum (
    repid numeric(12,0),
    iid numeric,
    lineno numeric(12,0),
    cola numeric,
    colb numeric,
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_sa7 (
    repid numeric(12,0),
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    tran_id character varying(32),
    br_tran_id character varying(20),
    br_sname character varying(8),
    entity character varying(3),
    name character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    pgo character varying(5),
    pg_des character varying(30),
    date_con date,
    amount numeric(12,2),
    ytd numeric,
    reccode character varying(3),
    transdesc character varying(100),
    limit_ind character varying(1),
    indemp character varying(38),
    indocc character varying(38),
    other_comid character varying(9),
    donor_comname character varying(200),
    other_canid character varying(9),
    can_name character varying(38),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    other_name character varying(200),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    memo_code character varying(1),
    memo_text character varying(100),
    nc_softacct character varying(9),
    amend character varying(1),
    imageno numeric(19,0),
    used character(1),
    create_dt timestamp without time zone,
    contributor_name_text tsvector,
    contributor_employer_text tsvector,
    contributor_occupation_text tsvector
);


CREATE TABLE real_efile_sb4 (
    repid numeric(12,0),
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    tran_id character varying(32),
    br_tran_id character varying(20),
    br_sname character varying(8),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    pgo character varying(5),
    pg_des character varying(20),
    date_dis date,
    amount numeric(12,2),
    sa_ref_amt numeric(12,2),
    dis_code character varying(3),
    transdesc character varying(100),
    cat_code character varying(3),
    refund character varying(1),
    other_comid character varying(9),
    ben_comname character varying(200),
    other_canid character varying(9),
    can_name character varying(38),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    other_name character varying(200),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    memo_code character varying(1),
    memo_text character varying(100),
    nc_softacct character varying(9),
    amend character varying(1),
    imageno numeric(19,0),
    create_dt timestamp without time zone,
    used character(1)
);


CREATE TABLE real_efile_sc (
    repid numeric(12,0),
    line_num character varying(8),
    rel_lineno numeric(12,0),
    refid character varying(32),
    entity character varying(3),
    comid character varying(9),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    code character varying(5),
    code_des character varying(20),
    orig_amt numeric(12,2),
    ptd numeric,
    balance numeric,
    date_inc date,
    date_due character varying(15),
    int_rate character varying(15),
    secured character varying(1),
    pers_funds character varying(1),
    other_comid character varying(9),
    other_canid character varying(9),
    can_name character varying(90),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    memo_cd character varying(1),
    memo_txt character varying(100),
    amend character varying(1),
    tran_id character varying(32),
    rec_lineno character varying(8),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_sc1 (
    repid numeric(12,0),
    line_num character varying(8),
    rel_lineno numeric(12,0),
    tran_id character varying(32),
    refid character varying(32),
    comid character varying(9),
    entity character varying(3),
    lender character varying(90),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    amount numeric(12,2),
    int_rate character varying(15),
    date_inc date,
    date_due character varying(15),
    restruct character varying(1),
    orig_date date,
    b1_credit numeric,
    balance numeric,
    others character varying(1),
    collateral character varying(1),
    coll_des character varying(100),
    coll_val numeric,
    perf_int character varying(1),
    future_inc character varying(1),
    fi_desc character varying(100),
    est_val numeric,
    account_date date,
    name_acc character varying(90),
    str1_acc character varying(34),
    str2_acc character varying(34),
    city_acc character varying(30),
    state_acc character varying(2),
    zip_acc character varying(9),
    a_date date,
    basis_desc character varying(100),
    t_lname character varying(90),
    t_fname character varying(20),
    t_mname character varying(20),
    t_prefix character varying(10),
    t_suffix character varying(10),
    signed_date date,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    auth_title character varying(20),
    auth_date date,
    amend character varying(1),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_se (
    repid numeric(12,0),
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    transdesc character varying(100),
    t_date date,
    amount numeric(12,2),
    so_canid character varying(9),
    so_can_name character varying(90),
    so_fname character varying(20),
    so_mname character varying(20),
    so_prefix character varying(10),
    so_suffix character varying(10),
    so_can_off character varying(1),
    so_can_state character varying(2),
    so_can_dist character varying(2),
    other_comid character varying(9),
    other_canid character varying(9),
    can_name character varying(90),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    other_name character varying(200),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    "position" character varying(3),
    pcf_lname character varying(90),
    pcf_fname character varying(20),
    pcf_mname character varying(20),
    pcf_prefix character varying(10),
    pcf_suffix character varying(10),
    sign_date date,
    not_date date,
    expire_date date,
    not_lname character varying(90),
    not_fname character varying(20),
    not_mname character varying(20),
    not_prefix character varying(10),
    not_suffix character varying(10),
    amend character varying(1),
    tran_id character varying(32),
    memo_code character varying(1),
    memo_text character varying(100),
    br_tran_id character varying(32),
    br_sname character varying(8),
    item_elect_cd character varying(5),
    item_elect_oth character varying(20),
    cat_code character varying(3),
    trans_code character varying(3),
    ytd numeric(12,2),
    imageno numeric(19,0),
    create_dt timestamp without time zone,
    dissem_dt date
);


CREATE VIEW real_efile_schedule_e_reports AS
 SELECT se.repid,
    se.line_num,
    se.rel_lineno,
    se.comid,
    se.entity,
    se.lname,
    se.fname,
    se.mname,
    se.prefix,
    se.suffix,
    se.str1,
    se.str2,
    se.city,
    se.state,
    se.zip,
    se.transdesc,
    se.t_date,
    se.amount,
    se.so_canid,
    se.so_can_name,
    se.so_fname,
    se.so_mname,
    se.so_prefix,
    se.so_suffix,
    se.so_can_off,
    se.so_can_state,
    se.so_can_dist,
    se.other_comid,
    se.other_canid,
    se.can_name,
    se.can_off,
    se.can_state,
    se.can_dist,
    se.other_name,
    se.other_str1,
    se.other_str2,
    se.other_city,
    se.other_state,
    se.other_zip,
    se."position",
    se.pcf_lname,
    se.pcf_fname,
    se.pcf_mname,
    se.pcf_prefix,
    se.pcf_suffix,
    se.sign_date,
    se.not_date,
    se.expire_date,
    se.not_lname,
    se.not_fname,
    se.not_mname,
    se.not_prefix,
    se.not_suffix,
    se.amend,
    se.tran_id,
    se.memo_code,
    se.memo_text,
    se.br_tran_id,
    se.br_sname,
    se.item_elect_cd,
    se.item_elect_oth,
    se.cat_code,
    se.trans_code,
    se.ytd,
    se.imageno,
    se.create_dt,
    se.dissem_dt,
    reps.form,
        CASE
            WHEN (upper((reps.form)::text) = 'F24N'::text) THEN true
            ELSE false
        END AS is_notice,
        CASE
            WHEN (length((se.item_elect_cd)::text) = 5) THEN (substr((se.item_elect_cd)::text, 2, 4))::integer
            ELSE NULL::integer
        END AS report_year,
    reps.rptcode AS report_type
   FROM (real_efile_se se
     JOIN real_efile_reps reps ON ((se.repid = reps.repid)));


CREATE TABLE real_efile_sd (
    repid numeric(12,0),
    line_num character varying(8),
    comid character varying(9),
    rel_lineno numeric(12,0),
    entity character varying(3),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    nature character varying(100),
    beg_balance numeric,
    incurred numeric,
    payment numeric,
    balance numeric,
    other_comid character varying(9),
    other_canid character varying(9),
    can_name character varying(90),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    other_name character varying(200),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    amend character varying(1),
    tran_id character varying(32),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE VIEW real_efile_se_f57_vw AS
 SELECT real_efile_f57.repid,
    NULL::character varying AS line_num,
    real_efile_f57.rel_lineno,
    real_efile_f57.comid,
    real_efile_f57.entity,
    real_efile_f57.lname,
    real_efile_f57.fname,
    real_efile_f57.mname,
    real_efile_f57.prefix,
    real_efile_f57.suffix,
    real_efile_f57.str1,
    real_efile_f57.str2,
    real_efile_f57.city,
    real_efile_f57.state,
    real_efile_f57.zip,
    real_efile_f57.exp_desc,
    real_efile_f57.exp_date,
    real_efile_f57.amount,
    real_efile_f57.so_canid,
    real_efile_f57.so_can_name,
    real_efile_f57.so_can_fname,
    real_efile_f57.so_can_mname,
    real_efile_f57.so_can_prefix,
    real_efile_f57.so_can_suffix,
    real_efile_f57.so_can_off,
    real_efile_f57.so_can_state,
    real_efile_f57.so_can_dist,
    real_efile_f57.other_comid,
    real_efile_f57.other_canid,
    real_efile_f57.can_name,
    real_efile_f57.can_off,
    real_efile_f57.can_state,
    real_efile_f57.can_dist,
    real_efile_f57.other_name,
    real_efile_f57.other_str1,
    real_efile_f57.other_str2,
    real_efile_f57.other_city,
    real_efile_f57.other_state,
    real_efile_f57.other_zip,
    real_efile_f57.supop,
    NULL::character varying AS pcf_lname,
    NULL::character varying AS pcf_fname,
    NULL::character varying AS pcf_mname,
    NULL::character varying AS pcf_prefix,
    NULL::character varying AS pcf_suffix,
    NULL::date AS sign_date,
    NULL::date AS not_date,
    NULL::date AS expire_date,
    NULL::character varying AS not_lanme,
    NULL::character varying AS not_fname,
    NULL::character varying AS not_mname,
    NULL::character varying AS not_prefix,
    NULL::character varying AS not_suffix,
    real_efile_f57.amend,
    real_efile_f57.tran_id,
    NULL::character varying AS memo_code,
    NULL::character varying AS memo_text,
    NULL::character varying AS br_tran_id,
    NULL::character varying AS br_sname,
    real_efile_f57.item_elect_cd,
    real_efile_f57.item_elect_oth,
    real_efile_f57.cat_code,
    real_efile_f57.trans_code,
    real_efile_f57.ytd,
    real_efile_f57.imageno,
    real_efile_f57.create_dt,
    NULL::date AS dissem_dt
   FROM real_efile_f57
UNION ALL
 SELECT real_efile_se.repid,
    real_efile_se.line_num,
    real_efile_se.rel_lineno,
    real_efile_se.comid,
    real_efile_se.entity,
    real_efile_se.lname,
    real_efile_se.fname,
    real_efile_se.mname,
    real_efile_se.prefix,
    real_efile_se.suffix,
    real_efile_se.str1,
    real_efile_se.str2,
    real_efile_se.city,
    real_efile_se.state,
    real_efile_se.zip,
    real_efile_se.transdesc AS exp_desc,
    real_efile_se.t_date AS exp_date,
    real_efile_se.amount,
    real_efile_se.so_canid,
    real_efile_se.so_can_name,
    real_efile_se.so_fname AS so_can_fname,
    real_efile_se.so_mname AS so_can_mname,
    real_efile_se.so_prefix AS so_can_prefix,
    real_efile_se.so_suffix AS so_can_suffix,
    real_efile_se.so_can_off,
    real_efile_se.so_can_state,
    real_efile_se.so_can_dist,
    real_efile_se.other_comid,
    real_efile_se.other_canid,
    real_efile_se.can_name,
    real_efile_se.can_off,
    real_efile_se.can_state,
    real_efile_se.can_dist,
    real_efile_se.other_name,
    real_efile_se.other_str1,
    real_efile_se.other_str2,
    real_efile_se.other_city,
    real_efile_se.other_state,
    real_efile_se.other_zip,
    real_efile_se."position" AS supop,
    real_efile_se.pcf_lname,
    real_efile_se.pcf_fname,
    real_efile_se.pcf_mname,
    real_efile_se.pcf_prefix,
    real_efile_se.pcf_suffix,
    real_efile_se.sign_date,
    real_efile_se.not_date,
    real_efile_se.expire_date,
    real_efile_se.not_lname AS not_lanme,
    real_efile_se.not_fname,
    real_efile_se.not_mname,
    real_efile_se.not_prefix,
    real_efile_se.not_suffix,
    real_efile_se.amend,
    real_efile_se.tran_id,
    real_efile_se.memo_code,
    real_efile_se.memo_text,
    real_efile_se.br_tran_id,
    real_efile_se.br_sname,
    real_efile_se.item_elect_cd,
    real_efile_se.item_elect_oth,
    real_efile_se.cat_code,
    real_efile_se.trans_code,
    real_efile_se.ytd,
    real_efile_se.imageno,
    real_efile_se.create_dt,
    real_efile_se.dissem_dt
   FROM real_efile_se;


CREATE TABLE real_efile_sf (
    repid numeric(12,0),
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    entity character varying(3),
    cord_exp character varying(1),
    des_comid character varying(9),
    des_com_name character varying(200),
    sub_comid character varying(9),
    sub_com_name character varying(200),
    sub_str1 character varying(34),
    sub_str2 character varying(34),
    sub_city character varying(30),
    sub_state character varying(2),
    sub_zip character varying(9),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    canid character varying(9),
    can_name character varying(90),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_off character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    agg_amount numeric(12,2),
    transdesc character varying(100),
    t_date date,
    amount numeric(12,2),
    other_comid character varying(9),
    other_name character varying(200),
    other_str1 character varying(34),
    other_str2 character varying(34),
    other_city character varying(30),
    other_state character varying(2),
    other_zip character varying(9),
    amend character varying(1),
    tran_id character varying(32),
    memo_code character varying(1),
    memo_text character varying(100),
    br_tran_id character varying(32),
    br_sname character varying(8),
    unlimit character varying(1),
    cat_code character varying(3),
    trans_code character varying(3),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_si (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    bankid character varying(16),
    account_name character varying(200),
    from_date date,
    to_date date,
    amend character varying(1),
    tran_id character varying(32),
    acct_num character varying(9),
    imageno character varying(22),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_sl (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    lname character varying(200),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    rec_id character varying(9),
    from_date date,
    through_date date,
    ending numeric,
    amend character varying(1),
    tran_id character varying(32),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_sl_sum (
    repid numeric(12,0),
    iid numeric,
    lineno numeric(12,0),
    cola numeric,
    colb numeric,
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_summary (
    repid numeric(12,0) NOT NULL,
    lineno numeric(12,0) NOT NULL,
    cola numeric,
    colb numeric,
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_supsum (
    repid numeric(12,0),
    lineno numeric(12,0),
    colbs numeric,
    create_dt timestamp without time zone
);


CREATE TABLE real_efile_text (
    repid numeric(12,0),
    comid character varying(9),
    tranid character varying(32),
    rec_type character varying(8),
    br_tran_id character varying(32),
    text_id character varying(40),
    amend character varying(1),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE real_pfile_f1 (
    repid numeric(12,0),
    comid character varying(9),
    chg_name character varying(1),
    name character varying(200),
    chg_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    amend_email character varying(1),
    email character varying(90),
    amend_url character varying(1),
    url character varying(90),
    fax character varying(12),
    sub_date date,
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    com_type character varying(1),
    can_last character varying(30),
    can_first character varying(20),
    can_middle character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_office character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    can_pcode character varying(3),
    can_ptype character varying(3),
    lead_pac character varying(1),
    lrpac5e character varying(1),
    lrpac5f character varying(1),
    aff_name character varying(200),
    aff_fname character varying(20),
    aff_mname character varying(20),
    aff_prefix character varying(10),
    aff_suffix character varying(10),
    aff_str1 character varying(34),
    aff_str2 character varying(34),
    aff_city character varying(30),
    aff_state character varying(2),
    aff_zip character varying(9),
    aff_relat character varying(38),
    aff_orgtyp character varying(1),
    affrel_code character varying(3),
    cus_last character varying(30),
    cus_first character varying(20),
    cus_middle character varying(20),
    cus_prefix character varying(10),
    cus_suffix character varying(10),
    cus_str1 character varying(34),
    cus_str2 character varying(34),
    cus_city character varying(30),
    cus_state character varying(2),
    cus_zip character varying(9),
    cus_title character varying(20),
    cus_phone character varying(10),
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_str1 character varying(34),
    tre_str2 character varying(34),
    tre_city character varying(30),
    tre_state character varying(2),
    tre_zip character varying(9),
    tre_title character varying(20),
    tre_phone character varying(10),
    des_last character varying(30),
    des_first character varying(20),
    des_middle character varying(20),
    des_prefix character varying(10),
    des_suffix character varying(10),
    des_str1 character varying(34),
    des_str2 character varying(34),
    des_city character varying(30),
    des_state character varying(2),
    des_zip character varying(9),
    des_title character varying(20),
    des_phone character varying(10),
    bnk_name character varying(200),
    bnk_str1 character varying(34),
    bnk_str2 character varying(34),
    bnk_city character varying(30),
    bnk_state character varying(2),
    bnk_zip character varying(9),
    bname_2 character varying(200),
    bstr1_2 character varying(34),
    bstr2_2 character varying(34),
    bcity_2 character varying(30),
    bstate_2 character varying(2),
    bzip_2 character varying(9),
    imgno character varying(11),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f10 (
    repid numeric(12,0),
    comid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    office character varying(1),
    state character varying(2),
    dist character varying(2),
    canid character varying(9),
    com_name character varying(90),
    com_str1 character varying(34),
    com_str2 character varying(34),
    com_city character varying(18),
    com_state character varying(2),
    com_zip character varying(9),
    previous numeric,
    total numeric,
    ctd numeric,
    f6 character varying(1),
    emp character varying(38),
    occ character varying(38),
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f105 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    receipt_date date,
    elc_code character varying(5),
    elc_other character varying(20),
    amount numeric(12,2),
    loan character varying(1),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f11 (
    repid numeric(12,0),
    comid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    canid character varying(9),
    off character varying(1),
    st character varying(2),
    dist character varying(2),
    name character varying(90),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(18),
    state character varying(2),
    zip character varying(9),
    not_last character varying(30),
    not_first character varying(20),
    not_middle character varying(20),
    not_prefix character varying(10),
    not_suffix character varying(10),
    not_name character varying(90),
    com_comid character varying(9),
    com_str1 character varying(34),
    com_str2 character varying(34),
    com_city character varying(18),
    com_state character varying(2),
    com_zip character varying(9),
    f10_date date,
    amount numeric(12,2),
    elc_code character varying(5),
    elc_other character varying(20),
    type character varying(1),
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    sign_date date,
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f12 (
    repid numeric(12,0),
    comid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    canid character varying(9),
    off character varying(1),
    st character varying(2),
    dist character varying(2),
    name character varying(90),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(18),
    state character varying(2),
    zip character varying(9),
    elc_code character varying(5),
    elc_other character varying(20),
    elc_type character varying(1),
    pcc_date date,
    pcc_amount numeric(12,2),
    pcc_f11date date,
    auth_date date,
    auth_amount numeric(12,2),
    auth_f11date date,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    sign_date date,
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f13 (
    repid numeric(12,0),
    comid character varying(9),
    name character varying(200),
    chg_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    rpt_code character varying(3),
    date_amend date,
    date_from date,
    date_through date,
    accepted numeric,
    refund numeric,
    net numeric,
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imgno character varying(11),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f132 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    receipt_date date,
    received numeric,
    aggregate numeric,
    memo_desc character varying(100),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone,
    memo_code character varying(1)
);


CREATE TABLE real_pfile_f133 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    exp_date date,
    expended numeric,
    memo_desc character varying(100),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f1m (
    repid numeric(12,0),
    comid character varying(9),
    name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    type character varying(1),
    aff_date date,
    aff_name character varying(200),
    aff_comid character varying(9),
    cn1_last character varying(30),
    cn1_first character varying(20),
    cn1_middle character varying(20),
    cn1_prefix character varying(10),
    cn1_suffix character varying(10),
    cn1_office character varying(1),
    cn1_state character varying(2),
    cn1_dist character varying(2),
    cn1_cont date,
    cn2_last character varying(30),
    cn2_first character varying(20),
    cn2_middle character varying(20),
    cn2_prefix character varying(10),
    cn2_suffix character varying(10),
    cn2_office character varying(1),
    cn2_state character varying(2),
    cn2_dist character varying(2),
    cn2_cont date,
    cn3_last character varying(30),
    cn3_first character varying(20),
    cn3_middle character varying(20),
    cn3_prefix character varying(10),
    cn3_suffix character varying(10),
    cn3_office character varying(1),
    cn3_state character varying(2),
    cn3_dist character varying(2),
    cn3_cont date,
    cn4_last character varying(30),
    cn4_first character varying(20),
    cn4_middle character varying(20),
    cn4_prefix character varying(10),
    cn4_suffix character varying(10),
    cn4_office character varying(1),
    cn4_state character varying(2),
    cn4_dist character varying(2),
    cn4_cont date,
    cn5_last character varying(30),
    cn5_first character varying(20),
    cn5_middle character varying(20),
    cn5_prefix character varying(10),
    cn5_suffix character varying(10),
    cn5_office character varying(1),
    cn5_state character varying(2),
    cn5_dist character varying(2),
    cn5_cont date,
    date_51 date,
    date_org date,
    date_com date,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    imgno character varying(11),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f1s (
    repid numeric(12,0),
    comid character varying(9),
    jfrcomname character varying(200),
    jfrcomid character varying(9),
    aff_name character varying(200),
    aff_fname character varying(20),
    aff_mname character varying(20),
    aff_prefix character varying(10),
    aff_suffix character varying(10),
    aff_str1 character varying(34),
    aff_str2 character varying(34),
    aff_city character varying(30),
    aff_state character varying(2),
    aff_zip character varying(9),
    aff_relat character varying(38),
    aff_orgtyp character varying(1),
    affrel_code character varying(3),
    des_last character varying(30),
    des_first character varying(20),
    des_middle character varying(20),
    des_prefix character varying(10),
    des_suffix character varying(10),
    des_str1 character varying(34),
    des_str2 character varying(34),
    des_city character varying(30),
    des_state character varying(2),
    des_zip character varying(9),
    des_title character varying(20),
    des_phone character varying(10),
    bnk_name character varying(200),
    bnk_str1 character varying(34),
    bnk_str2 character varying(34),
    bnk_city character varying(30),
    bnk_state character varying(2),
    bnk_zip character varying(9),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f2 (
    repid numeric(12,0),
    canid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    chg_addr character varying(1),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    party character varying(3),
    office character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    pcc_year character varying(4),
    pcc_name character varying(200),
    pcc_str1 character varying(34),
    pcc_str2 character varying(34),
    pcc_city character varying(30),
    pcc_state character varying(2),
    pcc_zip character varying(9),
    aut_name character varying(200),
    aut_str1 character varying(34),
    aut_str2 character varying(34),
    aut_city character varying(30),
    aut_state character varying(2),
    aut_zip character varying(9),
    pri_fund numeric,
    gen_fund numeric,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    imgno character varying(11),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f24 (
    repid numeric(12,0),
    comid character varying(9),
    name character varying(200),
    rpttyp character varying(2),
    orgamd_date date,
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    f24_date date,
    imgno character varying(11),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f3 (
    repid numeric(12,0),
    comid character varying(9),
    name character varying(200),
    chg_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    elc_state character varying(2),
    elc_dist character varying(2),
    rpt_code character varying(3),
    date_elc date,
    state_elc character varying(2),
    date_from date,
    date_through date,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    cash_open numeric,
    ttl_rcpt numeric,
    sub_ttl numeric,
    ttl_disb numeric,
    cash_close numeric,
    can_last character varying(30),
    can_first character varying(20),
    can_middle character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    canid character varying(9),
    f3z1 character varying(3),
    imgno character varying(11),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f3l (
    repid numeric(12,0),
    comid character varying(9),
    com_name character varying(200),
    amend_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    els character varying(2),
    eld numeric,
    rptcode character varying(3),
    el_date date,
    el_state character varying(2),
    semiperiod character varying(1),
    from_date date,
    through_date date,
    semijun character varying(1),
    semidec character varying(1),
    bundledcont numeric,
    semibuncont numeric,
    lname character varying(38),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imageno numeric(19,0),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f3p (
    repid numeric(12,0),
    comid character varying(9),
    c_name character varying(200),
    c_str1 character varying(34),
    c_str2 character varying(34),
    c_city character varying(30),
    c_state character varying(2),
    c_zip character varying(9),
    amend_addr character varying(1),
    rptcode character varying(3),
    rptpgi character varying(5),
    el_date date,
    el_state character varying(2),
    act_pri character varying(1),
    act_gen character varying(1),
    from_date date,
    through_date date,
    cash numeric,
    tot_rec numeric,
    sub numeric,
    tot_dis numeric,
    cash_close numeric,
    debts_to numeric,
    debts_by numeric,
    expe numeric,
    net_con numeric,
    net_op numeric,
    lname character varying(38),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imgno character varying(18),
    end_imgno character varying(18),
    receipt_dt date,
    create_date date
);


CREATE TABLE real_pfile_f3ps (
    repid numeric(12,0),
    comid character varying(9),
    ge_date date,
    dayafterge_dt date,
    imgno character varying(18)
);


CREATE TABLE real_pfile_f3s (
    repid numeric(12,0),
    comid character varying(9),
    date_ge date,
    date_age date,
    imgno character varying(19),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f3x (
    repid numeric(12,0),
    comid character varying(9),
    name character varying(200),
    chg_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    rpt_code character varying(3),
    date_elc date,
    state_elc character varying(2),
    date_from date,
    date_through date,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    qual character varying(1),
    coh_year character varying(4),
    imgno character varying(11),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f3z (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    totals character varying(1),
    comid character varying(9),
    name character varying(200),
    date_from date,
    date_through date,
    auth character varying(200),
    a numeric,
    b numeric,
    c numeric,
    d numeric,
    e numeric,
    f numeric,
    g numeric,
    h numeric,
    i numeric,
    j numeric,
    k numeric,
    l numeric,
    m numeric,
    n numeric,
    o numeric,
    p numeric,
    q numeric,
    r numeric,
    s numeric,
    t numeric,
    u numeric,
    v numeric,
    w numeric,
    x numeric,
    y numeric,
    z numeric,
    aa numeric,
    bb numeric,
    cc numeric,
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f4 (
    repid numeric(12,0),
    comid character varying(9),
    name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    type character varying(1),
    description character varying(40),
    rpt_code character varying(3),
    date_from date,
    date_through date,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    coh_year character varying(4),
    imgno character varying(11),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f5 (
    repid numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    chg_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(10),
    qual character varying(1),
    ind_emp character varying(38),
    ind_occ character varying(38),
    rpt_code character varying(3),
    hr_code character varying(2),
    pgi_code character varying(1),
    date_elc date,
    state_elc character varying(2),
    orig_amend_date date,
    date_from date,
    date_through date,
    ttl_cont numeric,
    ttl_expd numeric,
    ind_last character varying(30),
    ind_first character varying(20),
    ind_middle character varying(20),
    ind_prefix character varying(10),
    ind_suffix character varying(10),
    ind_date date,
    imgno character varying(11),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f56 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    fec_comid character varying(9),
    date_recv date,
    amount numeric(12,2),
    ind_emp character varying(38),
    ind_occ character varying(38),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f57 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    date_exp date,
    amount numeric(12,2),
    purp_exp character varying(40),
    cat_code character varying(3),
    so_last character varying(30),
    so_first character varying(20),
    so_middle character varying(20),
    so_prefix character varying(10),
    so_suffix character varying(10),
    so_office character varying(1),
    so_state character varying(2),
    so_dist character varying(2),
    sup_opp character varying(3),
    cal_ytd numeric,
    elc_code character varying(5),
    elc_other character varying(20),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f6 (
    repid numeric(12,0),
    comid character varying(9),
    orgamd_date date,
    name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    can_office character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    sign_date date,
    imgno character varying(11),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f65 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    ind_emp character varying(38),
    ind_occ character varying(38),
    date_cont date,
    amount numeric(12,2),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f7 (
    repid numeric(12,0),
    comid character varying(9),
    name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    org_type character varying(1),
    rpt_code character varying(3),
    date_elc date,
    state_elc character varying(2),
    date_from date,
    date_through date,
    ttl_cost numeric,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_title character varying(20),
    tre_date date,
    imgno character varying(11),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f76 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    exp_type character varying(2),
    description character varying(40),
    class character varying(1),
    exp_date date,
    sup_opp character varying(3),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    office character varying(1),
    state character varying(2),
    dist character varying(2),
    pgi character varying(5),
    cost numeric,
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f8 (
    repid numeric(12,0),
    comid character varying(9),
    name character varying(90),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(18),
    state character varying(2),
    zip character varying(9),
    l1 numeric,
    l1a date,
    l2 numeric,
    l3 numeric,
    l4 numeric,
    l5 numeric,
    l6 numeric,
    l7 numeric,
    l8 numeric,
    l9 numeric,
    l10 numeric,
    l11 character varying(1),
    l11d date,
    l12 character varying(1),
    l12d character varying(300),
    l13 character varying(1),
    l13d character varying(100),
    l14 character varying(1),
    l15 character varying(1),
    l15d character varying(100),
    suff character varying(1),
    suff_des character varying(100),
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f8ii (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(90),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(18),
    state character varying(2),
    zip character varying(9),
    date_inc date,
    amt_owed numeric(12,2),
    amt_offrd numeric(12,2),
    cred_code character varying(3),
    a_desc character varying(100),
    b_desc character varying(100),
    c_desc character varying(100),
    d_yn character varying(1),
    d_desc character varying(100),
    e_yn character varying(1),
    e_desc character varying(100),
    cred_last character varying(30),
    cred_first character varying(20),
    cred_middle character varying(20),
    cred_prefix character varying(10),
    cred_suffix character varying(10),
    cred_date date,
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f8iii (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(90),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    cred_code character varying(3),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(18),
    state character varying(2),
    zip character varying(9),
    yes_no character varying(1),
    amt_owed numeric(12,2),
    amt_pay numeric(12,2),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f9 (
    repid numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    chg_addr character varying(1),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    empl character varying(38),
    occup character varying(38),
    date_from date,
    date_through date,
    date_public date,
    title character varying(40),
    qual character varying(1),
    filer_code character varying(3),
    filercd_desc character varying(20),
    bnk_acc character varying(1),
    cus_last character varying(30),
    cus_first character varying(20),
    cus_middle character varying(20),
    cus_prefix character varying(10),
    cus_suffix character varying(10),
    cus_str1 character varying(34),
    cus_str2 character varying(34),
    cus_city character varying(30),
    cus_state character varying(2),
    cus_zip character varying(9),
    cus_emp character varying(38),
    cus_occ character varying(38),
    ttl_dona numeric,
    ttl_disb numeric,
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    imgno character varying(11),
    create_date timestamp without time zone,
    end_imgno character varying(18),
    receipt_dt date
);


CREATE TABLE real_pfile_f91 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    empl character varying(38),
    occup character varying(38),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f92 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    date_recv date,
    amount numeric(12,2),
    memo_desc character varying(100),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f93 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    date_disb date,
    amount numeric(12,2),
    date_comm date,
    purp_disb character varying(40),
    memo_desc character varying(100),
    sch_id character varying(1),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_f94 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    office character varying(1),
    state character varying(2),
    dist character varying(2),
    elc_code character varying(5),
    elc_other character varying(20),
    back_ref character varying(20),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_h1 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    pres character varying(1),
    pres_sen character varying(1),
    sen character varying(1),
    non_pres_sen character varying(1),
    minimum character varying(1),
    federal numeric,
    non_federal numeric,
    administrative character varying(1),
    generic character varying(1),
    public_comm character varying(1),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_h2 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(90),
    fundraising character varying(1),
    direct character varying(1),
    ratio character varying(1),
    federal numeric,
    non_federal numeric,
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_h3 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(90),
    receipt_date date,
    ttl_amount numeric(12,2),
    event_type character varying(2),
    amount numeric(12,2),
    event character varying(90),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_h4 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    purpose character varying(40),
    identifier character varying(100),
    cat_code character varying(3),
    administrative character varying(1),
    fundraising character varying(1),
    exempt character varying(1),
    generic character varying(1),
    support character varying(1),
    public_comm character varying(1),
    ytd numeric,
    exp_date date,
    federal numeric,
    non_federal numeric,
    amount numeric(12,2),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone,
    memo_code character varying(1),
    memo_desc character varying(100)
);


CREATE TABLE real_pfile_h5 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(90),
    receipt_date date,
    amount numeric(12,2),
    registration numeric,
    id numeric,
    gotv numeric,
    generic numeric,
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_h6 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    purpose character varying(40),
    cat_code character varying(3),
    registration character varying(1),
    gotv character varying(1),
    id character varying(1),
    generic character varying(1),
    ytd numeric,
    exp_date date,
    federal numeric,
    levin numeric,
    amount numeric(12,2),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone,
    memo_code character varying(1),
    memo_desc character varying(100)
);


CREATE TABLE real_pfile_reps (
    repid numeric(12,0),
    comid character varying(9),
    form character varying(4),
    name character varying(200),
    md5 character varying(32),
    date_filed date,
    "timestamp" date,
    date_from date,
    date_through date,
    rptcode character varying(4),
    version character varying(7),
    batch numeric,
    received date,
    starting numeric,
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_sa (
    repid numeric(12,0),
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    receipt_date date,
    fec_com character varying(9),
    ind_emp character varying(38),
    ind_occ character varying(38),
    elc_code character varying(5),
    elc_other character varying(20),
    ytd numeric,
    amount numeric(12,2),
    memo_desc character varying(100),
    limit_ind character varying(1),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone,
    memo_code character varying(1)
);


CREATE TABLE real_pfile_sb (
    repid numeric(12,0),
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    disb_date date,
    purp_disb character varying(40),
    ben_comname character varying(200),
    can_last character varying(30),
    can_first character varying(20),
    can_middle character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    cat_code character varying(3),
    can_office character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    elc_code character varying(5),
    elc_other character varying(20),
    amount numeric(12,2),
    sa_ref_amt numeric(12,2),
    memo_desc character varying(100),
    refund character varying(1),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone,
    memo_code character varying(1)
);


CREATE TABLE real_pfile_sc (
    repid numeric(12,0),
    line_num character varying(8),
    rel_lineno numeric(12,0),
    rcpt_lineno character varying(8),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    election character varying(5),
    elc_desc character varying(20),
    amount numeric(12,2),
    ptd numeric,
    balance numeric,
    date_inc date,
    date_due character varying(15),
    pct_rate character varying(15),
    secured character varying(1),
    pers_funds character varying(1),
    memo_desc character varying(100),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone,
    memo_code character varying(1)
);


CREATE TABLE real_pfile_sc1 (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    amount numeric(12,2),
    pct_rate character varying(15),
    date_inc date,
    date_due character varying(15),
    restruct character varying(1),
    date_orig date,
    credit numeric,
    balance numeric,
    liable character varying(1),
    collateral character varying(1),
    coll_desc character varying(100),
    coll_amt numeric(12,2),
    perfected character varying(1),
    future character varying(1),
    futr_desc character varying(100),
    estimated numeric,
    date_est date,
    acc_name character varying(200),
    acc_str1 character varying(34),
    acc_str2 character varying(34),
    acc_city character varying(30),
    acc_state character varying(2),
    acc_zip character varying(9),
    acc_desc character varying(100),
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    ath_last character varying(30),
    ath_first character varying(20),
    ath_middle character varying(20),
    ath_prefix character varying(10),
    ath_suffix character varying(10),
    ath_title character varying(20),
    ath_date date,
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone,
    dep_acc_ath_date date
);


CREATE TABLE real_pfile_sc2 (
    repid numeric(12,0),
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    ind_emp character varying(38),
    ind_occ character varying(38),
    amount numeric(12,2),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_sd (
    repid numeric(12,0),
    line_num character varying(8),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    nature character varying(40),
    beginning numeric,
    incurred numeric,
    payment numeric,
    closing numeric,
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_se (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(200),
    last character varying(30),
    first character varying(20),
    middle character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    exp_date date,
    amount numeric(12,2),
    disse_date date,
    purpose character varying(40),
    cat_code character varying(3),
    so_last character varying(30),
    so_first character varying(20),
    so_middle character varying(20),
    so_prefix character varying(10),
    so_suffix character varying(10),
    so_office character varying(1),
    so_state character varying(2),
    so_dist character varying(2),
    sup_opp character varying(3),
    cal_ytd numeric,
    elc_code character varying(5),
    elc_other character varying(20),
    tre_last character varying(30),
    tre_first character varying(20),
    tre_middle character varying(20),
    tre_prefix character varying(10),
    tre_suffix character varying(10),
    tre_date date,
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone,
    memo_code character varying(1),
    memo_desc character varying(100)
);


CREATE TABLE real_pfile_sf (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    hr_notice character varying(1),
    designated character varying(1),
    name_des character varying(200),
    name_sub character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    pay_name character varying(200),
    pay_last character varying(30),
    pay_first character varying(20),
    pay_middle character varying(20),
    pay_prefix character varying(10),
    pay_suffix character varying(10),
    pay_str1 character varying(34),
    pay_str2 character varying(34),
    pay_city character varying(30),
    pay_state character varying(2),
    pay_zip character varying(9),
    purpose character varying(40),
    cat_code character varying(3),
    exp_date date,
    can_last character varying(30),
    can_first character varying(20),
    can_middle character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    can_office character varying(1),
    can_state character varying(2),
    can_dist character varying(2),
    aggregate numeric,
    amount numeric(12,2),
    unlimited character varying(1),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone,
    memo_code character varying(1),
    memo_desc character varying(100)
);


CREATE TABLE real_pfile_sl (
    repid numeric(12,0),
    rel_lineno numeric(12,0),
    comid character varying(9),
    name character varying(90),
    tran_id character varying(32),
    imgno character varying(11),
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_summary (
    repid numeric(12,0),
    lineno numeric(12,0),
    cola numeric,
    colb numeric,
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_summary_sup (
    repid numeric(12,0),
    lineno numeric(12,0),
    colc numeric,
    create_date timestamp without time zone
);


CREATE TABLE real_pfile_supsum (
    repid numeric(12,0),
    lineno numeric(12,0),
    colbs numeric
);


CREATE TABLE ref_ai (
    ai character varying(1),
    ai_order numeric(1,0),
    v_sum_sort_order numeric(1,0),
    pg_date timestamp without time zone
);


CREATE TABLE ref_cand_ici (
    cand_ici_cd character varying(1),
    cand_ici_desc character varying(15),
    pg_date timestamp without time zone
);


CREATE TABLE ref_cand_office (
    cand_office_cd character varying(1),
    cand_office_desc character varying(20),
    pg_date timestamp without time zone
);


CREATE TABLE ref_filed_cmte_dsgn (
    filed_cmte_dsgn_cd character varying(1),
    filed_cmte_dsgn_desc character varying(90),
    pg_date timestamp without time zone
);


CREATE TABLE ref_filed_cmte_tp (
    filed_cmte_tp_cd character varying(1),
    filed_cmte_tp_desc character varying(58),
    pg_date timestamp without time zone
);


CREATE TABLE ref_filing_desc (
    filing_code character varying(10) NOT NULL,
    filing_code_desc character varying(90),
    pg_date timestamp without time zone
);


CREATE TABLE ref_pty (
    pty_cd character varying(3),
    pty_desc character varying(50),
    pg_date timestamp without time zone
);


CREATE TABLE ref_st (
    st_desc character varying(40),
    st character varying(2),
    pg_date timestamp without time zone
);


CREATE TABLE role (
    role_id numeric NOT NULL,
    description character varying(255),
    pg_date timestamp without time zone
);


CREATE TABLE sec_user (
    sec_user_id numeric(12,0) NOT NULL,
    username character varying(30) NOT NULL,
    password_hash character varying(40) NOT NULL,
    incorrect_login_count numeric(1,0) NOT NULL,
    email character varying(100),
    first_name character varying(30),
    last_name character varying(30),
    force_pw_change numeric(1,0) NOT NULL,
    last_pw_change_date timestamp without time zone NOT NULL,
    last_login_date timestamp without time zone,
    created_date timestamp without time zone NOT NULL,
    sec_user_status_id numeric(12,0) NOT NULL,
    pg_date timestamp without time zone
);


CREATE TABLE summary_format_display (
    display character varying(100),
    v_sum_column character varying(30),
    type_cd character varying(1),
    type numeric(1,0),
    "position" numeric(3,0),
    f3 character varying(1),
    f3p character varying(1),
    f3x character varying(1),
    f4 character varying(1),
    f5 character varying(1),
    f7 character varying(1),
    f13 character varying(1),
    graph_ind character varying(1),
    filter numeric,
    line_num character varying(100),
    display_code_pk numeric NOT NULL,
    pg_date timestamp without time zone
);


CREATE TABLE temp_electronic_filer_chain (
    cmte_id character varying(9),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    amndt_ind character varying(1),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    amendment_chain numeric(7,0)[]
);


CREATE TABLE temp_electronic_filer_chain_house_senate (
    cmte_id character varying(9),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    amndt_ind character varying(1),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    amendment_chain numeric(7,0)[]
);


CREATE TABLE temp_electronic_filer_chain_pac_party (
    cmte_id character varying(9),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    amndt_ind character varying(1),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    amendment_chain numeric(7,0)[]
);


CREATE TABLE temp_electronic_filer_chain_presidential (
    cmte_id character varying(9),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    amndt_ind character varying(1),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    amendment_chain numeric(7,0)[]
);


CREATE TABLE temp_paper_filer_chain (
    cmte_id character varying(9),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    amndt_ind character varying(1),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    amendment_chain numeric(7,0)[]
);


CREATE TABLE temp_paper_filer_chain_house_senate (
    cmte_id character varying(9),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    amndt_ind character varying(1),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    amendment_chain numeric(7,0)[],
    date_chain timestamp without time zone[],
    depth integer,
    last numeric(7,0)
);


CREATE TABLE temp_paper_filer_chain_pac_party (
    cmte_id character varying(9),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    amndt_ind character varying(1),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    amendment_chain numeric(7,0)[]
);


CREATE TABLE temp_paper_filer_chain_presidential (
    cmte_id character varying(9),
    rpt_yr numeric(4,0),
    rpt_tp character varying(3),
    amndt_ind character varying(1),
    receipt_dt timestamp without time zone,
    file_num numeric(7,0),
    prev_file_num numeric(7,0),
    mst_rct_file_num numeric(7,0),
    amendment_chain numeric(7,0)[]
);


CREATE TABLE temp_search (
    idx bigint,
    id text,
    name text,
    fulltxt tsvector,
    receipts numeric
);


CREATE TABLE test (
    cand_id character varying(9),
    five_thousand_flag boolean
);


CREATE TABLE test2 (
    cand_id character varying(9),
    five_thousand_flag boolean
);


CREATE TABLE test_elections (
    title text,
    description text,
    states text[],
    location text,
    start_date timestamp without time zone,
    end_date timestamp without time zone
);


CREATE TABLE test_other (
    title character varying(150),
    description character varying(500),
    location character varying(200),
    states text[],
    start_date timestamp without time zone,
    end_date timestamp without time zone
);


CREATE TABLE test_purpose (
    sched_b_sk numeric(10,0),
    disbursement_purpose character varying
);


CREATE TABLE test_reports (
    title text,
    description text,
    location text,
    states text[],
    start_date timestamp without time zone,
    end_date timestamp without time zone
);


CREATE TABLE testing2 (
    index bigint,
    "State" bigint,
    "ZCTA" bigint,
    "Congressional District" bigint
);


CREATE TABLE testing3 (
    index bigint,
    "State" bigint,
    "ZCTA" bigint,
    "Congressional District" bigint
);


CREATE TABLE testing4 (
    index bigint,
    "State" bigint,
    "ZCTA" bigint,
    "Congressional District" bigint
);


CREATE TABLE trc_election_status (
    name character varying(50) NOT NULL,
    trc_election_status_id numeric NOT NULL,
    pg_date timestamp without time zone
);


CREATE TABLE trc_election_type (
    trc_election_type_id character varying(3) NOT NULL,
    election_desc character varying(30),
    pg_date timestamp without time zone
);


CREATE VIEW unverified_filers_vw AS
 SELECT cmte_cand_query.cmte_id,
    cmte_cand_query.filer_tp,
    cmte_cand_query.cand_cmte_tp,
    cmte_cand_query.filed_cmte_tp_desc,
    (disclosure.get_pcmte_nm(cmte_cand_query.cmte_id, (cmte_cand_query.filer_tp)::numeric))::character varying(200) AS cmte_nm,
    disclosure.get_first_receipt_dt(cmte_cand_query.cmte_id, (cmte_cand_query.filer_tp)::numeric) AS first_receipt_dt
   FROM ( SELECT cv.cmte_id,
            1 AS filer_tp,
                CASE
                    WHEN ((cv.cmte_tp)::text = 'H'::text) THEN 'H'::text
                    WHEN ((cv.cmte_tp)::text = 'S'::text) THEN 'S'::text
                    WHEN ((cv.cmte_tp)::text = 'P'::text) THEN 'P'::text
                    ELSE 'O'::text
                END AS cand_cmte_tp,
                CASE
                    WHEN ((cv.cmte_tp)::text = 'H'::text) THEN 'HOUSE'::text
                    WHEN ((cv.cmte_tp)::text = 'S'::text) THEN 'SENATE'::text
                    WHEN ((cv.cmte_tp)::text = 'P'::text) THEN 'PRESIDENTIAL'::text
                    WHEN ((cv.cmte_tp)::text = 'N'::text) THEN 'POLITICAL ACTION COMMITTEE (PAC)'::text
                    WHEN ((cv.cmte_tp)::text = 'Q'::text) THEN 'POLITICAL ACTION COMMITTEE (PAC)'::text
                    WHEN ((cv.cmte_tp)::text = 'O'::text) THEN 'POLITICAL ACTION COMMITTEE (PAC)'::text
                    WHEN ((cv.cmte_tp)::text = 'U'::text) THEN 'POLITICAL ACTION COMMITTEE (PAC)'::text
                    WHEN ((cv.cmte_tp)::text = 'V'::text) THEN 'POLITICAL ACTION COMMITTEE (PAC)'::text
                    WHEN ((cv.cmte_tp)::text = 'W'::text) THEN 'POLITICAL ACTION COMMITTEE (PAC)'::text
                    WHEN ((cv.cmte_tp)::text = 'X'::text) THEN 'POLITICAL PARTY COMMITTEE'::text
                    WHEN ((cv.cmte_tp)::text = 'Y'::text) THEN 'POLITICAL PARTY COMMITTEE'::text
                    ELSE 'OTHER'::text
                END AS filed_cmte_tp_desc
           FROM disclosure.cmte_valid_fec_yr cv,
            disclosure.unverified_cand_cmte b
          WHERE ((cv.cmte_id)::text = (b.cand_cmte_id)::text)
        UNION
         SELECT cv.cand_id AS cmte_id,
            2 AS filer_tp,
            cv.cand_office AS cand_cmte_tp,
                CASE
                    WHEN ((cv.cand_office)::text = 'H'::text) THEN 'HOUSE'::text
                    WHEN ((cv.cand_office)::text = 'S'::text) THEN 'SENATE'::text
                    WHEN ((cv.cand_office)::text = 'P'::text) THEN 'PRESIDENTIAL'::text
                    ELSE 'OTHER'::text
                END AS filed_cmte_tp_desc
           FROM disclosure.cand_valid_fec_yr cv,
            disclosure.unverified_cand_cmte b
          WHERE ((cv.cand_id)::text = (b.cand_cmte_id)::text)) cmte_cand_query;


CREATE TABLE v_sum_and_det_sum_report (
    cvg_start_dt numeric(8,0),
    cmte_pk numeric(19,0),
    cvg_end_dt numeric(8,0),
    ttl_receipts numeric(14,2),
    tranf_from_other_auth_cmte numeric(14,2),
    indv_contb numeric(14,2),
    oth_cmte_contb numeric(14,2),
    oth_loans numeric(14,2),
    ttl_disb numeric(14,2),
    tranf_to_other_auth_cmte numeric(14,2),
    indv_ref numeric(14,2),
    oth_cmte_ref numeric(14,2),
    oth_loan_repymts numeric(14,2),
    coh_bop numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    cand_loan numeric(14,2),
    cand_loan_repymnt numeric(14,2),
    indv_unitem_contb numeric(14,2),
    pty_cmte_contb numeric(14,2),
    cand_cntb numeric(14,2),
    ttl_contb numeric(14,2),
    ttl_loans numeric(14,2),
    offsets_to_op_exp numeric(14,2),
    other_receipts numeric(14,2),
    pol_pty_cmte_contb numeric(14,2),
    ttl_contb_ref numeric(14,2),
    ttl_loan_repymts numeric(14,2),
    op_exp_per numeric(14,2),
    other_disb_per numeric(14,2),
    net_contb numeric(14,2),
    net_op_exp numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    all_loans_received_per numeric(14,2),
    fed_cand_contb_ref_per numeric(14,2),
    tranf_from_nonfed_acct_per numeric(14,2),
    tranf_from_nonfed_levin_per numeric(14,2),
    ttl_nonfed_tranf_per numeric(14,2),
    ttl_fed_receipts_per numeric(14,2),
    shared_fed_op_exp_per numeric(14,2),
    shared_nonfed_op_exp_per numeric(14,2),
    other_fed_op_exp_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    fed_cand_cmte_contb_per numeric(14,2),
    indt_exp_per numeric(14,2),
    coord_exp_by_pty_cmte_per numeric(14,2),
    loans_made_per numeric(14,2),
    shared_fed_actvy_fed_shr_per numeric(14,2),
    shared_fed_actvy_nonfed_per numeric(14,2),
    non_alloc_fed_elect_actvy_per numeric(14,2),
    ttl_fed_elect_actvy_per numeric(14,2),
    offsets_to_fndrsg numeric(14,2),
    offsets_to_legal_acctg numeric(14,2),
    ttl_offsets_to_op_exp numeric(14,2),
    fndrsg_disb numeric(14,2),
    exempt_legal_acctg_disb numeric(14,2),
    cmte_id character varying(9),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    receipt_dt date,
    orig_sub_id numeric(19,0) NOT NULL,
    election_st character varying(2),
    rpt_pgi character varying(5),
    form_tp_cd character varying(8) NOT NULL,
    fed_funds_per numeric(14,2),
    item_ref_reb_ret_per numeric(14,2),
    unitem_ref_reb_ret_per numeric(14,2),
    subttl_ref_reb_ret_per numeric(14,2),
    item_other_ref_reb_ret_per numeric(14,2),
    unitem_other_ref_reb_ret_per numeric(14,2),
    subttl_other_ref_reb_ret_per numeric(14,2),
    item_other_income_per numeric(14,2),
    unitem_other_income_per numeric(14,2),
    item_convn_exp_disb_per numeric(14,2),
    unitem_convn_exp_disb_per numeric(14,2),
    subttl_convn_exp_disb_per numeric(14,2),
    tranf_to_st_local_pty_per numeric(14,2),
    direct_st_local_cand_supp_per numeric(14,2),
    voter_reg_amt_per numeric(14,2),
    voter_id_amt_per numeric(14,2),
    gotv_amt_per numeric(14,2),
    generic_campaign_amt_per numeric(14,2),
    tranf_to_fed_alloctn_per numeric(14,2),
    item_other_disb_per numeric(14,2),
    unitem_other_disb_per numeric(14,2),
    ttl_fed_disb_per numeric(14,2),
    coh_boy numeric(14,2),
    coh_coy numeric(14,2),
    exp_subject_limits_per numeric(14,2),
    exp_prior_yrs_subject_lim_per numeric(14,2),
    ttl_exp_subject_limits numeric(14,2),
    ttl_communication_cost numeric(14,2),
    oppos_pers_fund_amt numeric(14,2),
    hse_pers_funds_amt numeric(14,2),
    sen_pers_funds_amt numeric(14,2),
    loan_repymts_received_per numeric(14,2),
    file_num numeric(7,0),
    indv_item_contb numeric(14,2),
    last_update_date timestamp without time zone,
    prev_sub_id numeric(19,0),
    pg_date timestamp without time zone
);


CREATE TABLE vw_filing_history (
    sub_id numeric(19,0) NOT NULL,
    coverage_start_date date,
    coverage_end_date date,
    receipt_date date,
    election_year numeric(4,0),
    committee_id character varying(9),
    form_type character varying(4),
    report_year numeric(4,0),
    report_type character varying(3),
    to_from_indicator character varying(1),
    begin_image_numeric character varying(18),
    end_image_numeric character varying(18),
    pages numeric,
    total_receipts numeric(14,2),
    total_individual_contributions numeric(14,2),
    net_donations numeric(14,2),
    total_disbursements numeric(14,2),
    total_independent_expenditures numeric(14,2),
    total_communication_cost numeric(14,2),
    beginning_cash_on_hand numeric(14,2),
    ending_cash_on_hand numeric(14,2),
    debts_owed_by numeric(14,2),
    debts_owed_to numeric(14,2),
    house_personal_funds numeric(14,2),
    senate_personal_funds numeric(14,2),
    opposition_personal_funds numeric(14,2),
    treasurer_name character varying(200),
    file_numeric numeric,
    previous_file_numeric numeric,
    report_pgi character varying(5),
    request_type character varying(3),
    amendment_indicator character varying(1),
    update_date date,
    pg_date timestamp without time zone
);


SET search_path = real_efile, pg_catalog;

CREATE TABLE f3 (
    repid numeric(12,0),
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    amend_addr character varying(1),
    rptcode character varying(3),
    rptpgi character varying(5),
    els character varying(2),
    eld numeric,
    el_date date,
    el_state character varying(2),
    act_pri character varying(1),
    act_gen character varying(1),
    act_spe character varying(1),
    act_run character varying(1),
    from_date date,
    through_date date,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    cash_hand numeric,
    canid character varying(9),
    can_lname character varying(90),
    can_fname character varying(20),
    can_mname character varying(20),
    can_prefix character varying(10),
    can_suffix character varying(10),
    f3z1 character varying(3),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE f3p (
    repid numeric(12,0),
    comid character varying(9),
    c_name character varying(200),
    c_str1 character varying(34),
    c_str2 character varying(34),
    c_city character varying(30),
    c_state character varying(2),
    c_zip character varying(9),
    amend_addr character varying(1),
    rptcode character varying(3),
    rptpgi character varying(5),
    el_date date,
    el_state character varying(2),
    act_pri character varying(1),
    act_gen character varying(1),
    from_date date,
    through_date date,
    cash numeric,
    tot_rec numeric,
    sub numeric,
    tot_dis numeric,
    cash_close numeric,
    debts_to numeric,
    debts_by numeric,
    expe numeric,
    net_con numeric,
    net_op numeric,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    sign_date date,
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE f3x (
    repid numeric(12,0),
    comid character varying(9),
    com_name character varying(200),
    str1 character varying(34),
    str2 character varying(34),
    city character varying(30),
    state character varying(2),
    zip character varying(9),
    amend_addr character varying(1),
    qual character varying(1),
    rptcode character varying(3),
    rptpgi character varying(5),
    el_date date,
    el_state character varying(2),
    from_date date,
    through_date date,
    lname character varying(90),
    fname character varying(20),
    mname character varying(20),
    prefix character varying(10),
    suffix character varying(10),
    date_signed date,
    sum_year character varying(4),
    imageno numeric(19,0),
    create_dt timestamp without time zone
);


CREATE TABLE reps (
    repid numeric(12,0),
    form character varying(4),
    comid character varying(9),
    com_name character varying(200),
    filed_date date,
    "timestamp" date,
    from_date date,
    through_date date,
    md5 character varying(32),
    superceded numeric,
    previd numeric,
    rptcode character varying(4),
    ef character varying(1),
    version character varying(4),
    filed character varying(1),
    rptnum numeric,
    starting numeric,
    ending numeric,
    used character varying(1),
    create_dt timestamp without time zone,
    exclude_ind character varying(1),
    notes character varying(100)
);


CREATE TABLE summary (
    repid numeric(12,0),
    lineno numeric(12,0),
    cola numeric,
    colb numeric,
    create_dt timestamp without time zone
);


SET search_path = staging, pg_catalog;

CREATE TABLE ref_pty (
    pty_cd character varying(3),
    pty_desc character varying(50),
    pg_date timestamp without time zone DEFAULT now()
);


CREATE TABLE ref_rpt_tp (
    rpt_tp_cd character varying(3),
    rpt_tp_desc character varying(30),
    pg_date timestamp without time zone DEFAULT now()
);

SET search_path = disclosure, pg_catalog;

ALTER TABLE ONLY f_item_receipt_or_exp
    ADD CONSTRAINT f_item_receipt_or_exp_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_1
    ADD CONSTRAINT nml_form_1_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_1z
    ADD CONSTRAINT nml_form_1z_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_24
    ADD CONSTRAINT nml_form_24_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_2
    ADD CONSTRAINT nml_form_2_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_2z
    ADD CONSTRAINT nml_form_2z_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_57
    ADD CONSTRAINT nml_form_57_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_5
    ADD CONSTRAINT nml_form_5_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_7
    ADD CONSTRAINT nml_form_7_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_9
    ADD CONSTRAINT nml_form_9_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_sched_a
    ADD CONSTRAINT nml_sched_a_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_sched_b
    ADD CONSTRAINT nml_sched_b_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_sched_e
    ADD CONSTRAINT nml_sched_e_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_sched_f
    ADD CONSTRAINT nml_sched_f_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY unverified_cand_cmte
    ADD CONSTRAINT unverified_cand_cmte_pkey PRIMARY KEY (cand_cmte_id);

SET search_path = public, pg_catalog;

ALTER TABLE ONLY ao
    ADD CONSTRAINT ao_pkey PRIMARY KEY (ao_id);

ALTER TABLE ONLY cal_user_category
    ADD CONSTRAINT cal_user_category_pkey PRIMARY KEY (sec_user_id, cal_category_id);

ALTER TABLE ONLY cand_cmte_linkage
    ADD CONSTRAINT cand_cmte_linkage_pkey PRIMARY KEY (linkage_id);

ALTER TABLE ONLY cand_inactive
    ADD CONSTRAINT cand_inactive_pkey PRIMARY KEY (cand_id, election_yr);

ALTER TABLE ONLY cand_valid_fec_yr
    ADD CONSTRAINT cand_valid_fec_yr_pkey PRIMARY KEY (cand_valid_yr_id);

ALTER TABLE ONLY candidate_summary
    ADD CONSTRAINT candidate_summary_pkey PRIMARY KEY (cand_id, fec_election_yr);

ALTER TABLE ONLY cmte_cmte_linkage
    ADD CONSTRAINT cmte_cmte_linkage_pkey PRIMARY KEY (linkage_id);

ALTER TABLE ONLY committee_summary_exclude
    ADD CONSTRAINT committee_summary_exclude_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (custno);

ALTER TABLE ONLY dim_calendar_inf
    ADD CONSTRAINT dim_calendar_inf_pkey PRIMARY KEY (calendar_pk);

ALTER TABLE ONLY dim_cand_inf
    ADD CONSTRAINT dim_cand_inf_pkey PRIMARY KEY (cand_pk);

ALTER TABLE ONLY dim_cmte_ie_inf
    ADD CONSTRAINT dim_cmte_ie_inf_pkey PRIMARY KEY (cmte_pk);

ALTER TABLE ONLY dim_cmte_prsnl_inf
    ADD CONSTRAINT dim_cmte_prsnl_inf_pkey PRIMARY KEY (cmte_prsnl_id, cmte_pk);

ALTER TABLE ONLY dim_election_attrib_inf
    ADD CONSTRAINT dim_election_attrib_inf_pkey PRIMARY KEY (election_attrib_pk);

ALTER TABLE ONLY dim_race_inf
    ADD CONSTRAINT dim_race_inf_pkey PRIMARY KEY (race_pk);

ALTER TABLE ONLY dimyears
    ADD CONSTRAINT dimyears_pkey PRIMARY KEY (year_sk);

ALTER TABLE ONLY doc_order
    ADD CONSTRAINT doc_order_pkey PRIMARY KEY (doc_order_id);

ALTER TABLE ONLY entity
    ADD CONSTRAINT entity_pkey PRIMARY KEY (entity_id);

ALTER TABLE ONLY entity_type
    ADD CONSTRAINT entity_type_pkey PRIMARY KEY (entity_type_id);

ALTER TABLE ONLY f_campaign
    ADD CONSTRAINT f_campaign_pkey PRIMARY KEY (cand_pk, cmte_pk);

ALTER TABLE ONLY f_election_vote
    ADD CONSTRAINT f_election_vote_pkey PRIMARY KEY (race_pk, cand_pk, election_attrib_pk);

ALTER TABLE ONLY facthousesenate_f3
    ADD CONSTRAINT facthousesenate_f3_pkey PRIMARY KEY (facthousesenate_f3_sk);

ALTER TABLE ONLY factindpexpcontb_f5
    ADD CONSTRAINT factindpexpcontb_f5_pkey PRIMARY KEY (factindpexpcontb_f5_sk);

ALTER TABLE ONLY factpacsandparties_f3x
    ADD CONSTRAINT factpacsandparties_f3x_pkey PRIMARY KEY (factpacsandparties_f3x_sk);

ALTER TABLE ONLY factpresidential_f3p
    ADD CONSTRAINT factpresidential_f3p_pkey PRIMARY KEY (factpresidential_f3p_sk);

ALTER TABLE ONLY fec_vsum_f105
    ADD CONSTRAINT fec_vsum_f105_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f1
    ADD CONSTRAINT fec_vsum_f1_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f2
    ADD CONSTRAINT fec_vsum_f2_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f3
    ADD CONSTRAINT fec_vsum_f3_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f3p
    ADD CONSTRAINT fec_vsum_f3p_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f3ps
    ADD CONSTRAINT fec_vsum_f3ps_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f3s
    ADD CONSTRAINT fec_vsum_f3s_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f3x
    ADD CONSTRAINT fec_vsum_f3x_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f3z
    ADD CONSTRAINT fec_vsum_f3z_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f56
    ADD CONSTRAINT fec_vsum_f56_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f57
    ADD CONSTRAINT fec_vsum_f57_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f5
    ADD CONSTRAINT fec_vsum_f5_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f76
    ADD CONSTRAINT fec_vsum_f76_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f7
    ADD CONSTRAINT fec_vsum_f7_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f91
    ADD CONSTRAINT fec_vsum_f91_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f94
    ADD CONSTRAINT fec_vsum_f94_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_f9
    ADD CONSTRAINT fec_vsum_f9_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_a
    ADD CONSTRAINT fec_vsum_sched_a_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_b
    ADD CONSTRAINT fec_vsum_sched_b_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_c1
    ADD CONSTRAINT fec_vsum_sched_c1_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_c
    ADD CONSTRAINT fec_vsum_sched_c_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_d
    ADD CONSTRAINT fec_vsum_sched_d_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_e
    ADD CONSTRAINT fec_vsum_sched_e_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_h1
    ADD CONSTRAINT fec_vsum_sh1_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_h2
    ADD CONSTRAINT fec_vsum_sh2_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_h3
    ADD CONSTRAINT fec_vsum_sh3_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_h4
    ADD CONSTRAINT fec_vsum_sh4_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_h5
    ADD CONSTRAINT fec_vsum_sh5_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_h6
    ADD CONSTRAINT fec_vsum_sh6_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_i
    ADD CONSTRAINT fec_vsum_shi_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY fec_vsum_sched_l
    ADD CONSTRAINT fec_vsum_sl_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY form_57
    ADD CONSTRAINT form_57_pkey PRIMARY KEY (form_57_sk);

ALTER TABLE ONLY form_5
    ADD CONSTRAINT form_5_pkey PRIMARY KEY (form_5_sk);

ALTER TABLE ONLY form_76
    ADD CONSTRAINT form_76_pkey PRIMARY KEY (form_76_sk);

ALTER TABLE ONLY form_7
    ADD CONSTRAINT form_7_pkey PRIMARY KEY (form_7_sk);

ALTER TABLE ONLY form_91
    ADD CONSTRAINT form_91_pkey PRIMARY KEY (form_91_sk);

ALTER TABLE ONLY form_94
    ADD CONSTRAINT form_94_pkey PRIMARY KEY (form_94_sk);

ALTER TABLE ONLY form_9
    ADD CONSTRAINT form_9_pkey PRIMARY KEY (form_9_sk);

ALTER TABLE ONLY jd_nml_form_76_test
    ADD CONSTRAINT jd_nml_form_76_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_13
    ADD CONSTRAINT nml_form_13_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_4
    ADD CONSTRAINT nml_form_4_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_76
    ADD CONSTRAINT nml_form_76_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY nml_form_9
    ADD CONSTRAINT nml_form_9_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY operations_log
    ADD CONSTRAINT operations_log_pkey PRIMARY KEY (sub_id);

ALTER TABLE ONLY players
    ADD CONSTRAINT players_pkey PRIMARY KEY (player_id);

ALTER TABLE ONLY pres_nml_ca_cm_link_16
    ADD CONSTRAINT pres_nml_ca_cm_link_16_pkey PRIMARY KEY (pr_link_id);

ALTER TABLE ONLY pres_nml_ca_cm_link_arc
    ADD CONSTRAINT pres_nml_ca_cm_link_arc_pkey PRIMARY KEY (pr_link_id);

ALTER TABLE ONLY pres_nml_cand_cmte_link
    ADD CONSTRAINT pres_nml_cand_cmte_link_pkey PRIMARY KEY (pr_link_id);

ALTER TABLE ONLY pres_nml_f3p_totals_16
    ADD CONSTRAINT pres_nml_f3p_totals_16_pkey PRIMARY KEY (cand_id, election_yr);

ALTER TABLE ONLY pres_nml_f3p_totals_arc
    ADD CONSTRAINT pres_nml_f3p_totals_arc_pkey PRIMARY KEY (cand_id, election_yr);

ALTER TABLE ONLY pres_nml_form_3p_16
    ADD CONSTRAINT pres_nml_form_3p_16_pkey PRIMARY KEY (record_id);

ALTER TABLE ONLY pres_nml_form_3p_arc
    ADD CONSTRAINT pres_nml_form_3p_arc_pkey PRIMARY KEY (record_id);

ALTER TABLE ONLY pres_nml_form_3p
    ADD CONSTRAINT pres_nml_form_3p_pkey PRIMARY KEY (record_id);

ALTER TABLE ONLY pres_nml_form_3p_totals
    ADD CONSTRAINT pres_nml_form_3p_totals_pkey PRIMARY KEY (cand_id, election_yr);

ALTER TABLE ONLY pres_nml_sched_a_16
    ADD CONSTRAINT pres_nml_sched_a_16_pkey PRIMARY KEY (record_id);

ALTER TABLE ONLY pres_nml_sched_a_arc
    ADD CONSTRAINT pres_nml_sched_a_arc_pkey PRIMARY KEY (record_id);

ALTER TABLE ONLY pres_nml_sched_a
    ADD CONSTRAINT pres_nml_sched_a_pkey PRIMARY KEY (record_id);

ALTER TABLE ONLY pres_nml_sched_b_16
    ADD CONSTRAINT pres_nml_sched_b_16_pkey PRIMARY KEY (record_id);

ALTER TABLE ONLY pres_nml_sched_b_arc
    ADD CONSTRAINT pres_nml_sched_b_arc_pkey PRIMARY KEY (record_id);

ALTER TABLE ONLY pres_nml_sched_b
    ADD CONSTRAINT pres_nml_sched_b_pkey PRIMARY KEY (record_id);

ALTER TABLE ONLY real_efile_f3p
    ADD CONSTRAINT real_efile_f3p_pkey PRIMARY KEY (repid);

ALTER TABLE ONLY real_efile_f3x
    ADD CONSTRAINT real_efile_f3x_pkey PRIMARY KEY (repid);

ALTER TABLE ONLY real_efile_summary
    ADD CONSTRAINT real_efile_summary_pkey PRIMARY KEY (repid, lineno);

ALTER TABLE ONLY ref_filing_desc
    ADD CONSTRAINT ref_filing_desc_pkey PRIMARY KEY (filing_code);

ALTER TABLE ONLY role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);

ALTER TABLE ONLY sec_user
    ADD CONSTRAINT sec_user_pkey PRIMARY KEY (sec_user_id);

ALTER TABLE ONLY summary_format_display
    ADD CONSTRAINT summary_format_display_pkey PRIMARY KEY (display_code_pk);

ALTER TABLE ONLY trc_election_status
    ADD CONSTRAINT trc_election_status_pkey PRIMARY KEY (trc_election_status_id);

ALTER TABLE ONLY trc_election_type
    ADD CONSTRAINT trc_election_type_pkey PRIMARY KEY (trc_election_type_id);

ALTER TABLE ONLY v_sum_and_det_sum_report
    ADD CONSTRAINT v_sum_and_det_sum_report_pkey PRIMARY KEY (orig_sub_id, form_tp_cd);

ALTER TABLE ONLY vw_filing_history
    ADD CONSTRAINT vw_filing_history_pkey PRIMARY KEY (sub_id);

SET search_path = disclosure, pg_catalog;

CREATE INDEX nml_sched_b_link_id_idx ON nml_sched_b USING btree (link_id);

SET search_path = fecapp, pg_catalog;

CREATE INDEX trc_election_dates_election_date_idx ON trc_election_dates USING btree (election_date);

CREATE INDEX trc_election_dates_election_date_idx1 ON trc_election_dates USING btree (election_date);

CREATE INDEX trc_report_due_date_due_date_idx ON trc_report_due_date USING btree (due_date);

CREATE INDEX trc_report_due_date_due_date_idx1 ON trc_report_due_date USING btree (due_date);

SET search_path = public, pg_catalog;

CREATE INDEX com_create_date_idx1 ON real_efile_f3 USING btree (create_dt);

CREATE INDEX com_create_date_idx2 ON real_efile_f3x USING btree (create_dt);

CREATE INDEX com_create_date_idx3 ON real_efile_f3p USING btree (create_dt);

CREATE INDEX com_id_idx1 ON real_efile_f3p USING btree (comid);

CREATE INDEX com_id_idx2 ON real_efile_f3x USING btree (comid);

CREATE INDEX com_id_idx3 ON real_efile_f3 USING btree (comid);

CREATE INDEX contributor_employer_text_idx ON real_efile_sa7 USING gin (contributor_employer_text);

CREATE INDEX contributor_name_text_idx ON real_efile_sa7 USING gin (contributor_name_text);

CREATE INDEX contributor_occupation_text_idx ON real_efile_sa7 USING gin (contributor_occupation_text);

CREATE INDEX entity_disbursements_chart_cycle_idx ON entity_disbursements_chart USING btree (cycle);

CREATE UNIQUE INDEX entity_disbursements_chart_idx_idx ON entity_disbursements_chart USING btree (idx);

CREATE INDEX entity_receipts_chart_cycle_idx ON entity_receipts_chart USING btree (cycle);

CREATE UNIQUE INDEX entity_receipts_chart_idx_idx ON entity_receipts_chart USING btree (idx);

CREATE INDEX fec_vsum_sched_b_link_id_idx ON fec_vsum_sched_b USING btree (link_id);

CREATE INDEX fec_vsum_sched_b_link_id_idx1 ON fec_vsum_sched_b USING btree (link_id);

CREATE INDEX fec_vsum_sched_b_link_id_idx10 ON fec_vsum_sched_b USING btree (link_id);

CREATE INDEX fec_vsum_sched_b_link_id_idx2 ON fec_vsum_sched_b USING btree (link_id);

CREATE INDEX fec_vsum_sched_b_link_id_idx3 ON fec_vsum_sched_b USING btree (link_id);

CREATE INDEX fec_vsum_sched_b_link_id_idx4 ON fec_vsum_sched_b USING btree (link_id);

CREATE INDEX fec_vsum_sched_b_link_id_idx5 ON fec_vsum_sched_b USING btree (link_id);

CREATE INDEX fec_vsum_sched_b_link_id_idx6 ON fec_vsum_sched_b USING btree (link_id);

CREATE INDEX fec_vsum_sched_b_link_id_idx7 ON fec_vsum_sched_b USING btree (link_id);

CREATE INDEX fec_vsum_sched_b_link_id_idx8 ON fec_vsum_sched_b USING btree (link_id);

CREATE INDEX fec_vsum_sched_b_link_id_idx9 ON fec_vsum_sched_b USING btree (link_id);

CREATE INDEX ix_efile_guide_f3_index ON efile_guide_f3 USING btree (index);

CREATE INDEX ix_efile_guide_f3p_index ON efile_guide_f3p USING btree (index);

CREATE INDEX ix_efile_guide_f3x_index ON efile_guide_f3x USING btree (index);

CREATE INDEX ix_testing2_index ON testing2 USING btree (index);

CREATE INDEX ix_testing3_index ON testing3 USING btree (index);

CREATE INDEX ix_testing4_index ON testing4 USING btree (index);

CREATE INDEX rep_id_idx1 ON real_efile_f3p USING btree (repid);

CREATE INDEX rep_id_idx2 ON real_efile_f3x USING btree (repid);

CREATE INDEX rep_id_idx3 ON real_efile_f3 USING btree (repid);

CREATE INDEX rep_id_idx4 ON real_efile_summary USING btree (repid);

CREATE INDEX test_purpose_disbursement_purpose_idx ON test_purpose USING btree (disbursement_purpose);

CREATE INDEX tsv_idx ON fec_vsum_sched_c USING gin (loan_name);

SET search_path = disclosure, pg_catalog;

CREATE TRIGGER fec_sched_e_notice_trigger BEFORE INSERT OR DELETE OR UPDATE ON nml_sched_e FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_e_update_queues_from_notice();

CREATE TRIGGER nml_form_24_trigger BEFORE INSERT OR DELETE OR UPDATE ON nml_form_57 FOR EACH ROW EXECUTE PROCEDURE public.ofec_f57_update_notice_queues();

CREATE TRIGGER nml_form_24_trigger BEFORE INSERT OR DELETE OR UPDATE ON nml_form_24 FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_e_update_notice_queues();

CREATE TRIGGER nml_form_24_trigger BEFORE INSERT OR DELETE OR UPDATE ON nml_sched_e FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_e_update_notice_queues();

CREATE TRIGGER nml_sched_e_notice_trigger BEFORE INSERT OR DELETE OR UPDATE ON nml_sched_e FOR EACH ROW EXECUTE PROCEDURE public.ofec_sched_e_nml_update_queues_from_notice();

CREATE TRIGGER ofec_f57_trigger BEFORE INSERT OR DELETE OR UPDATE ON nml_form_57 FOR EACH ROW EXECUTE PROCEDURE public.ofec_f57_update_notice_queues();

SET search_path = public, pg_catalog;
-- Creates all of the child tables for an itemized schedule partition.
CREATE OR REPLACE FUNCTION create_itemized_schedule_partition(schedule TEXT, start_year NUMERIC, end_year NUMERIC) RETURNS VOID AS $$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_sched_master() RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Performs the final steps needed to setup all of the child tables for
-- schedule A.
CREATE OR REPLACE FUNCTION finalize_itemized_schedule_a_tables(start_year NUMERIC, end_year NUMERIC, p_use_tmp BOOLEAN, p_create_primary_key BOOLEAN) RETURNS VOID AS $$
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

        -- Create indexes.
        -- Note:  The multi-column GIN indexes require the btree_gin extension
        --        https://www.postgresql.org/docs/current/static/btree-gin.html
        --        This is installed but not enabled in RDS by default, it must
        --        be turned on with this: CREATE EXTENSION btree_gin;

        -- Indexes used for search
           -- for sorting by receipt date
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

          -- for sorting by transaction amount
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

        -- Other indexes
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_rpt_yr%s ON %I (rpt_yr)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_pg_date%s ON %I (pg_date)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_entity_tp%s ON %I (entity_tp)', child_table_root, index_name_suffix, child_table_name);

        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_amount%s ON %I (contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_cmte_id_amount%s ON %I (cmte_id, contb_receipt_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_sub_id_cmte_id_date%s ON %I (cmte_id, contb_receipt_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE UNIQUE INDEX IF NOT EXISTS idx_%s_sub_id%s ON %I (sub_id)', child_table_root, index_name_suffix, child_table_name);

        -- Create the primary key if needed
        IF p_create_primary_key THEN
            EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY USING INDEX idx_%s_sub_id%s', child_table_name, child_table_root, index_name_suffix);
        END IF;

        -- Set statistics and analyze the table.
        EXECUTE format('ALTER TABLE %I ALTER COLUMN contbr_st SET STATISTICS 1000', child_table_name);
        EXECUTE format('ANALYZE %I', child_table_name);
    END LOOP;
END
$$ LANGUAGE plpgsql;

-- Performs the final steps needed to setup all of the child tables for
-- schedule B.
CREATE OR REPLACE FUNCTION finalize_itemized_schedule_b_tables(start_year NUMERIC, end_year NUMERIC, p_use_tmp BOOLEAN, p_create_primary_key BOOLEAN) RETURNS VOID AS $$
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

        -- Create indexes.
        -- Note:  The multi-column GIN indexes require the btree_gin extension
        --        https://www.postgresql.org/docs/current/static/btree-gin.html
        --        This is installed but not enabled in RDS by default, it must
        --        be turned on with this: CREATE EXTENSION btree_gin;

        -- Indexes for searching
          -- for sorting by date
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

          -- for sorting by amount
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

        -- Other indexes
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_cmte_id_disb_amt_sub_id%s ON %I (cmte_id, disb_amt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_cmte_id_disb_dt_sub_id%s ON %I (cmte_id, disb_dt, sub_id)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_pg_date%s ON %I (pg_date)', child_table_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE UNIQUE INDEX IF NOT EXISTS idx_%s_sub_id%s ON %I (sub_id)', child_table_root, index_name_suffix, child_table_name);

        -- Create the primary key if needed
        IF p_create_primary_key THEN
            EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY USING INDEX idx_%s_sub_id%s', child_table_name, child_table_root, index_name_suffix);
        END IF;

        -- Set statistics and analyze the table.
        EXECUTE format('ALTER TABLE %I ALTER COLUMN recipient_st SET STATISTICS 1000', child_table_name);
        EXECUTE format('ANALYZE %I', child_table_name);
    END LOOP;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rename_table_cascade(table_name TEXT) RETURNS VOID AS $$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rename_indexes(p_table_name TEXT) RETURNS VOID AS $$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_partition_cycles(start_year NUMERIC, amount NUMERIC) RETURNS VOID AS $$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_partition_suffix(year NUMERIC)
RETURNS TEXT AS $$
BEGIN
    IF year % 2 = 0 THEN
        RETURN (year - 1)::TEXT || '_' || year::TEXT;
    ELSE
        RETURN year::TEXT || '_' || (year + 1)::TEXT;
    END IF;
END
$$ LANGUAGE PLPGSQL IMMUTABLE;
