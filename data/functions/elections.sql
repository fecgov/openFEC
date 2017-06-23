-- Incumbents are not put in for future elections I am giving the data a little
-- padding in figuring out when to look up the most recent incumbent in that seat.

create or replace function check_incumbent_char(office char, election_yr numeric, cand_election_yr numeric, value char)
returns text as $$
    begin
        return case
            when 'office' = 'H' and election_yr - cand_election_yr <= 3
                then value
            when 'office' = 'S' and election_yr - cand_election_yr <= 7
                then value
            when 'office' = 'P' and election_yr - cand_election_yr <= 5
                then value
            else null
        end;
    end
$$ language plpgsql;

create or replace function check_incumbent_numeric(office char, election_yr numeric, cand_election_yr numeric, value numeric)
returns text as $$
    begin
        return case
            when 'office' = 'H' and election_yr - cand_election_yr <= 3
                then value
            when 'office' = 'S' and election_yr - cand_election_yr <= 7
                then value
            when 'office' = 'P' and election_yr - cand_election_yr <= 5
                then value
            else null
        end;
    end
$$ language plpgsql;
