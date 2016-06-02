create or replace function get_cycle(year numeric)
returns integer as $$
begin
    return year + year % 2;
end
$$ language plpgsql immutable;

-- Figures out the appropriate year to use for the transaction of a Schedule A
-- or Schedule B record.  This function is used to fill in the value of the
-- "transaction_two_year_period" column for the openFEC Schedule A and B tables
-- and for checking how records should be split for the partitioning of those
-- tables.  We are splitting by two-year cycles and want to make sure we only
-- create tables for the cycles, not for every year present in the data.

-- Params:
--   transaction_date:  the value of the column representing the actual
--                      transaction date for a given record.
--   report_year:       the value of the column to use if the transaction_date
--                      value is NULL.

-- Returns:
--   The calculated year to use as the transaction date of a record.
create or replace function get_transaction_year(transaction_date date, report_year numeric)
returns integer as $$
begin
    return coalesce(extract(year from transaction_date), report_year) + (coalesce(cast(extract(year from transaction_date) as numeric(4, 0)), report_year) % 2);
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
