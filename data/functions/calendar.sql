-- Descriptions and summaries are usually the same, so we are trying to only show the
-- descriptions when it is not already included, That works for most things except court
-- cases, advisory opinions and conferences.
create or replace function describe_cal_event(event_name text, summary text, description text)
returns text as $$
    begin
        return case
            when event_name in ('Litigation', 'AOs and Rules', 'Conferences') then
                summary || ' ' || description
            else
                description
        end;
    end
$$ language plpgsql;

-- Retrieves the last day of the month for a given timestamp.
create or replace function last_day_of_month(timestamp)
returns timestamp as $$
    begin
        return date_trunc('month', $1) + (interval '1 month - 1 day');
    end
$$ language plpgsql;