-- Handle typos and notes in party description:
-- * "Commandments Party (Removed)" becomes "Commandments Party"
-- * "Green Party Added)" becomes "Green Party"
create or replace function clean_party(party text)
returns text as $$
    begin
        return regexp_replace(party, '\s*(Added|Removed|\(.*?)\)$', '');
    end
$$ language plpgsql;
