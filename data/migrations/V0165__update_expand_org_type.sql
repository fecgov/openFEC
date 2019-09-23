/*
This migration file is to solve issue #3967

Add organization types to
'H': 'Convention'
'I': 'Inaugural'

*/

CREATE OR REPLACE FUNCTION public.expand_organization_type(acronym text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    begin
        return case acronym
            when 'C' then 'Corporation'
            when 'H' then 'Convention'
            when 'I' then 'Inaugural'
            when 'L' then 'Labor Organization'
            when 'M' then 'Membership Organization'
            when 'T' then 'Trade Association'
            when 'V' then 'Cooperative'
            when 'W' then 'Corporation w/o capital stock'

            else null
        end;
    end
$$;
