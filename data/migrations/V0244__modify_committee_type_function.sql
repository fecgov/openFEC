-- FUNCTION: public.expand_committee_type(text)
/*
This is for issue #5041.
This migration file changes the expand_committee_type function to change committee type I to 'Independent expenditure filer (not a committee)'
Previous file: V0004
*/
-- DROP FUNCTION public.expand_committee_type(text);

CREATE OR REPLACE FUNCTION public.expand_committee_type(acronym text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $$
    begin
        return case acronym
            when 'P' then 'Presidential'
            when 'H' then 'House'
            when 'S' then 'Senate'
            when 'C' then 'Communication Cost'
            when 'D' then 'Delegate Committee'
            when 'E' then 'Electioneering Communication'
            when 'I' then 'Independent expenditure filer (not a committee)'
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

ALTER FUNCTION public.expand_committee_type(text)
    OWNER TO fec;

