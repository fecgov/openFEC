/*
This migration file is for #4458

Use https instead of http for docquery URLs in these functions:

image_pdf_url(text)
report_fec_url(text, integer)
report_html_url(text, text, text)
report_pdf_url(text)

*/


--
-- Name: image_pdf_url(text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE OR REPLACE FUNCTION image_pdf_url(image_number text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    return 'https://docquery.fec.gov/cgi-bin/fecimg/?' || image_number;
end
$$;


ALTER FUNCTION public.image_pdf_url(image_number text) OWNER TO fec;

--
-- Name: report_fec_url(text, integer); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE OR REPLACE FUNCTION report_fec_url(image_number text, file_number integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
begin
    return case
        when file_number < 1 then null
        when image_number is not null and not is_electronic(image_number) then format(
            'https://docquery.fec.gov/paper/posted/%1$s.fec',
            file_number
        )
        when image_number is not null and is_electronic(image_number) then format(
            'https://docquery.fec.gov/dcdev/posted/%1$s.fec',
            file_number
        )
    end;
end
$_$;


ALTER FUNCTION public.report_fec_url(image_number text, file_number integer) OWNER TO fec;

--
-- Name: report_html_url(text, text, text); Type: FUNCTION; Schema: public; Owner: fec
--

CREATE OR REPLACE FUNCTION report_html_url(means_filed text, cmte_id text, filing_id text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
BEGIN
    return CASE
       when means_filed = 'paper' and filing_id::int > 0 then format (
           'https://docquery.fec.gov/cgi-bin/paper_forms/%1$s/%2$s/',
            cmte_id,
            filing_id
       )
       when means_filed = 'e-file' then format (
           'https://docquery.fec.gov/cgi-bin/forms/%1$s/%2$s/',
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

CREATE OR REPLACE FUNCTION report_pdf_url(image_number text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
begin
    return case
        when image_number is not null then format(
            'https://docquery.fec.gov/pdf/%1$s/%2$s/%2$s.pdf',
            substr(image_number, length(image_number) - 2, length(image_number)),
            image_number
        )
        else null
    end;
end
$_$;


ALTER FUNCTION public.report_pdf_url(image_number text) OWNER TO fec;
