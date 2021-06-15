/*
This migration file is for #4053
Modify function: report_fec_url not to generate invalid fec_url
when file number is null 
*/

--
-- Name: report_fec_url(text, numeric); 
-- Type: FUNCTION; Schema: public; Owner: fec
--

CREATE OR REPLACE FUNCTION report_fec_url(image_number text, file_number integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
AS $$
begin
    return case
        when (file_number < 1 or file_number is null) then null
        when image_number is not null and not is_electronic(image_number) then format(
            'https://docquery.fec.gov/paper/posted/%1$s.fec',
            file_number
        )
        when image_number is not null and is_electronic(image_number) then format(
            'https://docquery.fec.gov/dcdev/posted/%1$s.fec',
            file_number
        )
        else null
    end;
end
$$;



ALTER FUNCTION public.report_fec_url(image_number text, file_number integer) OWNER TO fec;