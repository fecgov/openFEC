create or replace function get_cycle(year numeric)
returns integer as $$
begin
    return year + year % 2;
end
$$ language plpgsql immutable;

create or replace function election_duration(office text)
returns integer as $$
begin
    return case office
        when 'S' then 6
        when 'P' then 4
        else 2
    end;
end
$$ language plpgsql;

create or replace function date_or_null(value text, format text)
returns date as $$
begin
    return to_date(value, format);
exception
    when others then return null::date;
end
$$ language plpgsql immutable;
