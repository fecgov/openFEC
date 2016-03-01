create or replace function get_cycle(year numeric) returns int as $$
begin
    return year + year %% 2;
end
$$ language plpgsql immutable;

create or replace function date_or_null(value text, format text)
returns date as $$
begin
    return to_date(value, format);
exception
    when others then return null::date;
end
$$ language plpgsql immutable;
