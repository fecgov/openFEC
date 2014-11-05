
# FEC API Documentation
## Candidate

## Supported parameters for candidate

| q=          | Full-text search |
| /<cand_id>  | Single candidate's record |
| cand_id=    | Synonym for /<cand_id> |
| office=     | Governmental office sought |
| state=      | Two-letter state abbreviation |
| district=   | Two-digit number(00 - if no district or at large) |
| name=       | Candidate's name |
| page=       | Page number |
| party=      | 3-letter party abbreviation |
| per_page=   | Number of records per page |
| year=       | Any year in which candidate ran |
| fields =    | Comma separated list of fields to display |


## Supported fields for candidate

### cand_id

Unique id given to a candidate running for an office. Note that a candidate that runs for different offices such as Senate and President, will have multiple candidate_ids.

### cand_status
### candidate_inactive
### district
### election
### full_name
### incumbent_challenge
### name
### office_saught
office_sought
### other_names
### party_affiliation
### primary_cmte
### affiliated_cmtes
### state

## Sample output



