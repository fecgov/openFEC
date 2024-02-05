/*
This migration file is for #4821
Modify function: report_pdf_url_or_null to include more historic records
*/

--
-- Name: report_pdf_url_or_null(text, numeric, text, text,  text); 
-- Type: FUNCTION; Schema: public; Owner: fec
--

CREATE OR REPLACE FUNCTION report_pdf_url_or_null(image_number text, report_year numeric, committee_type text, cand_id text, form_type text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return case
        when image_number is not null and (
             report_year >= 2000 or
             (committee_type not in ('S','H') and report_year >= 1993) or
             (committee_type = 'H' and report_year >= 1996) or
             (form_type = 'F2' and substr(cand_id,1,1) = 'H' and report_year >= 1996) or
             (form_type = 'F2' and substr(cand_id,1,1) = 'P' and report_year >= 1993) 
        ) then report_pdf_url(image_number)
        else null
        end;
end
$$;


ALTER FUNCTION public.report_pdf_url_or_null(text, numeric, text, text, text) OWNER TO fec;
