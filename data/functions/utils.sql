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

CREATE OR REPLACE FUNCTION get_partition_suffix(year NUMERIC)
RETURNS TEXT AS $$
BEGIN
    IF year % 2 = 0 THEN
        RETURN (year - 1)::TEXT || '_' || year::TEXT;
    ELSE
        RETURN year::TEXT || '_' || (year + 1)::TEXT;
    END IF;
END
$$ LANGUAGE PLPGSQL IMMUTABLE;

CREATE OR REPLACE FUNCTION rename_indexes(p_table_name TEXT) RETURNS VOID AS $$
DECLARE
    indexes_cursor CURSOR FOR
        SELECT indexname AS name
        FROM pg_indexes
        WHERE tablename = p_table_name;
BEGIN

    FOR index_name IN indexes_cursor LOOP
        EXECUTE format('ALTER INDEX %1$I RENAME TO %2$I', index_name.name, regexp_replace(index_name.name, '_tmp', ''));
    END LOOP;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_index_suffix(p_table_name TEXT, suffix TEXT) RETURNS VOID AS $$
DECLARE
    indexes_cursor CURSOR FOR
        SELECT indexname AS name
        FROM pg_indexes
        WHERE tablename = p_table_name;
BEGIN

    FOR index_name IN indexes_cursor LOOP
        EXECUTE format('ALTER INDEX %1$I RENAME TO %2$I', index_name.name,  index_name.name || suffix);
    END LOOP;
END
$$ LANGUAGE plpgsql;
