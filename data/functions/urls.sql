create or replace function image_pdf_url(image_number text) returns text as $$
begin
    return 'http://docquery.fec.gov/cgi-bin/fecimg/?' || image_number;
end
$$ language plpgsql immutable;

create or replace function report_pdf_url(image_number text) returns text as $$
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
$$ language plpgsql immutable;

create or replace function report_pdf_url_or_null(image_number text, report_year numeric, committee_type text, form_type text) returns text as $$
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
$$ language plpgsql immutable;

create or replace function report_fec_url(image_number text, file_number integer) returns text as $$
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
$$ language plpgsql immutable;

create or replace function means_filed(image_number text) returns text as $$
begin
    return case
        when is_electronic(image_number) then 'e-file'
        else 'paper'
    end;
end
$$ language plpgsql immutable;

--If the image number string is of length 18, and the 9th character is a 9, then it is electronic
--if the image number string is of length 11, and the 3rd character is a 9, then also electronic
--if imaage number is of length 11 and the 3rd and 4th characters are 02 and 03 then it is paper
--all other combinations are paper filers. (this encoding is outlined at this GitHub issue:
--https://github.com/18F/openFEC/issues/1882
create or replace function is_electronic(image_number text) returns boolean as $$
begin
    return case
        when char_length(image_number) = 18 and substring(image_number from 9 for 1) = '9' then true
        when char_length(image_number) = 11 and substring(image_number from 3 for 1) = '9' then true
        --these last two cases aren't really needed, but good to add them to make this encoding
        --explicit to the reader
        when char_length(image_number) = 11 and substring(image_number from 3 for 2) = '02' then false
        when char_length(image_number) = 11 and substring(image_number from 3 for 2) = '03' then false
        else false
    end;
end
$$ language plpgsql immutable;

create or replace function is_amended(most_recent_file_number integer, file_number integer) returns boolean as $$
begin
    return not is_most_recent(most_recent_file_number, file_number);
end
$$ language plpgsql immutable;

create or replace function is_amended(most_recent_file_number integer, file_number integer, form_type text) returns boolean as $$
begin
    return case
        when form_type = 'F99' then false
        when form_type = 'FRQ' then false
        else not is_most_recent(most_recent_file_number, file_number)
    end;
end
$$ language plpgsql immutable;

create or replace function is_most_recent(most_recent_file_number integer, file_number integer) returns boolean as $$
begin
    return most_recent_file_number = file_number;
end
$$ language plpgsql immutable;

create or replace function is_most_recent(most_recent_file_number integer, file_number integer, form_type text) returns boolean as $$
begin
    return case
        when form_type = 'F99' then true
        when form_type = 'FRQ' then true
        else most_recent_file_number = file_number
    end;
end
$$ language plpgsql immutable;
