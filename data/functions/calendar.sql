-- Retrieves the last day of the month for a given timestamp.
create or replace function last_day_of_month(timestamp)
returns timestamp as $$
    begin
        return date_trunc('month', $1) + (interval '1 month - 1 day');
    end
$$ language plpgsql;