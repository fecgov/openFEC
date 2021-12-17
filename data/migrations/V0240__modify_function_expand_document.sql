-- FUNCTION: public.expand_document(text)

-- DROP FUNCTION public.expand_document(text);

CREATE OR REPLACE FUNCTION public.expand_document(acronym text)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
    begin
        return case acronym
            when '2' then '24-Hour Contribution Notice'
            when '4' then '48-Hour Contribution Notice'
            when 'A' then 'Debt Settlement Statement'
            when 'B' then 'Acknowledgment of Receipt of Debt Settlement Statement'
            when 'C' then 'RFAI: Debt Settlement First Notice'
            when 'D' then 'Commission Debt Settlement Review'
            when 'E' then 'Commission Response to Debt Settlement Request'
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
            when 'T' then 'Miscellaneous Report to FEC'
            when 'V' then 'Repeat Violation Notice (441A OR 441B)'
            when 'P' then 'Notice of Paper Filing'
            when 'R' then 'F3L Filing Frequency Change Notice'
            when 'Q' then 'Acknowledgment of F3L Filing Frequency Change'
            when 'U' then 'Unregistered Committee Notice'
            else null
        end;
    end
$BODY$;

ALTER FUNCTION public.expand_document(text)
    OWNER TO fec;
