create or replace function get_cycle(year numeric) returns int as $$
begin
    return year + year % 2;
end
$$ language plpgsql immutable;
