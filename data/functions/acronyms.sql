create or replace function expand_candidate_incumbent(acronym text)
returns text as $$
    begin
        return case acronym
            when 'I' then 'Incumbent'
            when 'C' then 'Challenger'
            when 'O' then 'Open seat'
            else null
        end;
    end
$$ language plpgsql;

 create or replace function expand_election_type(acronym text)
 returns text as $$
     begin
         return case acronym
             when 'P' then 'Primary Election'
             when 'PR' then 'Primary Runoff Election'
             when 'SP' then 'Special Primary Election'
             when 'SPR' then 'Special Primary Runoff Election'
             when 'G' then 'General Election'
             when 'GR' then 'General Runoff Election'
             when 'SG' then 'Special General Election'
             when 'SGR' then 'Special General Runoff Election'
             when 'O' then 'Other'
             when 'C' then 'Caucus or Convention'
             when 'CAU' then 'Caucus'
             when 'CON' then 'Convention'
             when 'SC' then 'Special Convention'
             when 'R' then 'Runoff Election'
             when 'SR' then 'Special Runoff Election'
             when 'S' then 'Special Election'
             when 'E' then 'Recount Election'
             else null
         end;
     end
 $$ language plpgsql;

create or replace function expand_office(acronym text)
returns text as $$
    begin
        return case acronym
            when 'P' then 'President'
            when 'S' then 'Senate'
            when 'H' then 'House'
        end;
    end
$$ language plpgsql;

create or replace function expand_office_description(acronym text)
returns text as $$
    begin
        return case acronym
            when 'P' then 'Presidential'
            when 'S' then 'Senate'
            when 'H' then 'House'
            else null
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
            else null
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
            else null
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
            else null
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

create or replace function expand_document(acronym text)
returns text as $$
    begin
        return case acronym
            when '2' then '24 Hour Contribution Notice'
            when '4' then '48 Hour Contribution Notice'
            when 'A' then 'Debt Settlement Statement'
            when 'B' then 'Acknowledgment of Receipt of Debt Settlement Statement'
            when 'C' then 'RFAI: Debt Settlement First Notice'
            when 'D' then 'Commission Debt Settlement Review'
            when 'E' then 'Commission Response TO Debt Settlement Request'
            when 'F' then 'Administrative Termination'
            when 'G' then 'Debt Settlement Plan Amendment'
            when 'H' then 'Disavowal Notice'
            when 'I' then 'Disavowal Response'
            when 'J' then 'Conduit Report'
            when 'K' then 'Termination Approval'
            when 'L' then 'Repeat Non-Filer Notice'
            when 'M' then 'Filing Frequency Change Notice'
            when 'N' then 'Paper Amendment to Electronic Report'
            when 'O' then 'Acknowledgment of Filing Frequency Change'
            when 'S' then 'RFAI: Debt Settlement Second'
            when 'T' then 'Miscellaneous Report TO FEC'
            when 'V' then 'Repeat Violation Notice (441A OR 441B)'
            when 'P' then 'Notice of Paper Filing'
            when 'R' then 'F3L Filing Frequency Change Notice'
            when 'Q' then 'Acknowledgment of F3L Filing Frequency Change'
            when 'U' then 'Unregistered Committee Notice'
            else null
        end;
    end
$$ language plpgsql;

create or replace function expand_line_number(form_type text, line_number text)
returns text as $$
    begin
        return case form_type
            when 'F3X' then expand_line_number_f3x(line_number)
            when 'F3P' then expand_line_number_f3p(line_number)
            when 'F3' then expand_line_number_f3(line_number)
            else null
        end;
    end
$$ language plpgsql;

create or replace function expand_line_number_f3X(line_number text)
returns text as $$
    begin
        return case line_number
            --Receipts
            when '11A1' then 'Contributions From Individuals/Persons Other Than Political Committees'
            when '11AI' then 'Contributions From Individuals/Persons Other Than Political Committees'
            when '11B' then 'Contributions From Political Party Committees'
            when '11C' then 'Contributions From Other Political Committees'
            when '11D' then 'Contributions From the Candidate'
            when '12' then 'Transfers from Authorized Committees'
            when '13' then 'Loans Received'
            when '14' then 'Loan Repayments Received'
            when '15' then 'Offsets To Operating Expenditures '
            when '16' then 'Refunds of Contributions Made to Federal Candidates and Other Political Committees'
            when '17' then 'Other Federal Receipts (Dividends, Interest, etc.).'
            when 'SL1A' then 'Non-Federal Receipts from Persons Levin (L-1A)'
            when 'SL2' then 'Non-Federal Other Receipt Levin (L-2)'
            --Disbursements
            when '21' then 'Operating Expenditures'
            when '21B' then 'Other Federal Operating Expenditures'
            when '22' then 'Transfers to Affiliated/Other Party Committees'
            when '23' then 'Contributions to Federal Candidates/Committees and Other Political Committees'
            when '24' then 'Independent Expenditures'
            when '25' then 'Coordinated Party Expenditures'
            when '26' then 'Loan Repayments Made'
            when '27' then 'Loans Made'
            when '28A' then 'Refunds of Contributions Made to Individuals/Persons Other Than Political Committees'
            when '28B' then 'Refunds of Contributions to Political Party Committees'
            when '28C' then 'Refunds of Contributions to Other Political Committees'
            when '28D' then 'Total Contributions Refunds'
            when '29' then 'Other Disbursements'
            when '30' then 'Federal Election Activity'
            when '30A' then 'Allocated Federal Election Activity'
            when '30B' then 'Federal Election Activity Paid Entirely With Federal Funds'
            when 'SL4A' then 'Levin Funds'
            when 'SL4B' then 'Levin Funds'
            when 'SL4C' then 'Levin Funds'
            when 'SL4D' then 'Levin Funds'
            when 'SL5' then 'Levin Funds'
            else null
        end;
    end
$$ language plpgsql;

create or replace function expand_line_number_f3p(line_number text)
returns text as $$
    begin
        return case line_number
            --Receipts
            when '16' then 'Federal Funds'
            when '17A' then 'Contributions From Individuals/Persons Other Than Political Committees'
            when '17B' then 'Contributions From Political Party Committees'
            when '17C' then 'Contributions From Other Political Committees'
            when '17D' then 'Contributions From the Candidate'
            when '18' then 'Transfers From Other Authorized Committees'
            when '19A' then 'Loans Received From or Guaranteed by Candidate'
            when '19B' then 'Other Loans'
            when '20A' then 'Offsets To Expenditures - Operating'
            when '20B' then 'Offsets To Expenditures - Fundraising'
            when '20C' then 'Offsets To Expenditures - Legal and Accounting'
            when '21' then 'Other Receipts'
            --Disbursements
            when '23' then 'Operating Expenditures'
            when '24' then 'Transfers to Other Authorized Committees'
            when '25' then 'Fundraising Disbursements'
            when '26' then 'Exempt Legal and Accounting Disbursements'
            when '27A' then 'Loan Repayments Made or Guaranteed by Candidate'
            when '27B' then 'Other Loan Repayments'
            when '28A' then 'Refunds of Contributions to Individuals/Persons Other Than Political Committees'
            when '28B' then 'Refunds of Contributions to Political Party Committees'
            when '28C' then 'Refunds of Contributions to Other Political Committees'
            when '29' then 'Other Disbursements'
            else null
        end;
    end
$$ language plpgsql;

create or replace function expand_line_number_f3(line_number text)
returns text as $$
    begin
        return case line_number
            --Receipts
            when '11A1' then 'Contributions From Individuals/Persons Other Than Political Committees'
            when '11AI' then 'Contributions From Individuals/Persons Other Than Political Committees'
            when '11B' then 'Contributions From Political Party Committees'
            when '11C' then 'Contributions From Other Political Committees'
            when '11D' then 'Contributions From the Candidate'
            when '12' then 'Transfers from authorized committees'
            when '13' then 'Loans Received'
            when '13A' then 'Loans Received from the Candidate'
            when '13B' then 'All Other Loans Received'
            when '14' then 'Offsets to Operating Expenditures'
            when '15' then 'Total Amount of Other Receipts'
            --Disbursements
            when '17' then 'Operating Expenditures'
            when '18' then 'Transfers to Other Authorized Committees'
            when '19' then 'Loan Repayments'
            when '19A' then 'Loan Repayments Made or Guaranteed by Candidate'
            when '19B' then 'Other Loan Repayments'
            when '20A' then 'Refunds of Contributions to Individuals/Persons Other Than Political Committees'
            when '20B' then 'Refunds of Contributions to Political Party Committees'
            when '20C' then 'Refunds of Contributions to Other Political Committees'
            when '21' then 'Other Disbursements'
            else null
        end;
    end
$$ language plpgsql;

