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

create or replace function expand_state(acronym text)
returns text as $$
    begin
        return case acronym
            when 'AK' then 'Alaska'
            when 'AL' then 'Alabama'
            when 'AS' then 'American Samoa'
            when 'AR' then 'Arkansas'
            when 'AZ' then 'Arizona'
            when 'CA' then 'California'
            when 'CO' then 'Colorado'
            when 'CT' then 'Connecticut'
            when 'DC' then 'District Of Columbia'
            when 'DE' then 'Delaware'
            when 'FL' then 'Florida'
            when 'GA' then 'Georgia'
            when 'GU' then 'Guam'
            when 'HI' then 'Hawaii'
            when 'IA' then 'Iowa'
            when 'ID' then 'Idaho'
            when 'IL' then 'Illinois'
            when 'IN' then 'Indiana'
            when 'KS' then 'Kansas'
            when 'KY' then 'Kentucky'
            when 'LA' then 'Louisiana'
            when 'MA' then 'Massachusetts'
            when 'MD' then 'Maryland'
            when 'ME' then 'Maine'
            when 'MI' then 'Michigan'
            when 'MN' then 'Minnesota'
            when 'MO' then 'Missouri'
            when 'MS' then 'Mississippi'
            when 'MT' then 'Montana'
            when 'NC' then 'North Carolina'
            when 'ND' then 'North Dakota'
            when 'NE' then 'Nebraska'
            when 'NH' then 'New Hampshire'
            when 'NJ' then 'New Jersey'
            when 'NM' then 'New Mexico'
            when 'NV' then 'Nevada'
            when 'NY' then 'New York'
            when 'MP' then 'Northern Mariana Islands'
            when 'OH' then 'Ohio'
            when 'OK' then 'Oklahoma'
            when 'OR' then 'Oregon'
            when 'PA' then 'Pennsylvania'
            when 'PR' then 'Puerto Rico'
            when 'RI' then 'Rhode Island'
            when 'SC' then 'South Carolina'
            when 'SD' then 'South Dakota'
            when 'TN' then 'Tennessee'
            when 'TX' then 'Texas'
            when 'UT' then 'Utah'
            when 'VI' then 'Virgin Islands'
            when 'VA' then 'Virginia'
            when 'VT' then 'Vermont'
            when 'WA' then 'Washington'
            when 'WI' then 'Wisconsin'
            when 'WV' then 'West Virginia'
            when 'WY' then 'Wyoming'
            else null
        end;
    end
$$ language plpgsql;
