create or replace function expand_candidate_incumbent(acronym text)
returns text as $$
    begin
        return case acronym
            when 'I' then 'Incumbent'
            when 'C' then 'Challenger'
            when 'O' then 'Open seat'
            else 'Unknown'
        end;
    end
$$ language plpgsql;

create or replace function expand_candidate_status(acronym text)
returns text as $$
    begin
        return case acronym
            when 'C' then 'Candidate'
            when 'F' then 'Future candidate'
            when 'N' then 'Not yet a candidate'
            when 'P' then 'Prior candidate'
            else 'Unknown'
        end;
    end
$$ language plpgsql;

create or replace function expand_organization_type(acronym text)
returns text as $$
    begin
        return case acronym
            when 'C' then 'Corporation'
            when 'L' then 'Labor Organization'
            when 'M' then 'Membership Organization'
            when 'T' then 'Trade Association'
            when 'V' then 'Cooperative'
            when 'W' then 'Corporation w/o capital stock'
            else null
        end;
    end
$$ language plpgsql;

create or replace function expand_committee_designation(acronym text)
returns text as $$
    begin
        return case acronym
            when 'A' then 'Authorized by a candidate'
            when 'J' then 'Joint fundraising committee'
            when 'P' then 'Principal campaign committee'
            when 'U' then 'Unauthorized'
            when 'B' then 'Lobbyist/Registrant PAC'
            when 'D' then 'Leadership PAC'
            else 'Unknown'
        end;
    end
$$ language plpgsql;

create or replace function expand_committee_type(acronym text)
returns text as $$
    begin
        return case acronym
            when 'P' then 'Presidential'
            when 'H' then 'House'
            when 'S' then 'Senate'
            when 'C' then 'Communication Cost'
            when 'D' then 'Delegate Committee'
            when 'E' then 'Electioneering Communication'
            when 'I' then 'Independent Expenditor (Person or Group)'
            when 'N' then 'PAC - Nonqualified'
            when 'O' then 'Super PAC (Independent Expenditure-Only)'
            when 'Q' then 'PAC - Qualified'
            when 'U' then 'Single Candidate Independent Expenditure'
            when 'V' then 'PAC with Non-Contribution Account - Nonqualified'
            when 'W' then 'PAC with Non-Contribution Account - Qualified'
            when 'X' then 'Party - Nonqualified'
            when 'Y' then 'Party - Qualified'
            when 'Z' then 'National Party Nonfederal Account'
            else 'Unknown'
        end;
    end
$$ language plpgsql;
