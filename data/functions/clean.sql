-- Handle typos and notes in party description:
-- * "Commandments Party (Removed)" becomes "Commandments Party"
-- * "Green Party Added)" becomes "Green Party"
create or replace function clean_party(party text)
returns text as $$
begin
    return regexp_replace(party, '\s*(Added|Removed|\(.*?)\)$', '');
end
$$ language plpgsql;


-- These fields include additional descriptions in curly braces that we don't want to show in the dimreporttype table that appear in curly braces. Like: { one of 4 codes }
create or replace function clean_report(report text)
returns text as $$
begin
	return regexp_replace(report, ' {.*}', '');
end
$$ language plpgsql;


-- Compare two values. If equal, return `NULL`, else return the first value.
create or replace function clean_repeated(first anyelement, second anyelement)
returns anyelement as $$
begin
    return case
        when first = second then null
        else first
    end;
end
$$ language plpgsql;
