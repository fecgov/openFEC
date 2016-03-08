create or replace function get_cycle(year numeric)
returns integer as $$
begin
    return year + year %% 2;
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
