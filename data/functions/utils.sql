create or replace function get_cycle(year numeric)
returns integer as $$
begin
    return year + year % 2;
end
$$ language plpgsql immutable;

create or replace function get_transaction_year(transaction_date timestamp, report_year numeric)
returns smallint as $$
declare
    dah_date date = date(transaction_date);
begin
    return get_transaction_year(dah_date, report_year);
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
returns smallint as $$
declare
    transaction_year numeric = coalesce(extract(year from transaction_date), report_year);
begin
    return get_cycle(transaction_year);
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

-- Returns a projected weekly total of all itemized records that have been
-- added and are scheduled to be added or removed the day of as well.

-- Params:
--   schedule:      the itemized schedule table to calculate the totals for.

-- Returns:
--   The calculated projected weekly total of records processed fort the given
--   itemized schedule table.
create or replace function get_projected_weekly_itemized_total(schedule text)
returns integer as $$
declare
    weekly_total integer;
begin
    execute 'select
        (select count(*) from ofec_sched_' || schedule || '_master where pg_date > current_date - interval ''7 days'') +
        (select count(*) from ofec_sched_' || schedule || '_queue_new) -
        (select count(*) from ofec_sched_' || schedule || '_queue_old)'
    into weekly_total;

    return weekly_total;
end
$$ language plpgsql;
