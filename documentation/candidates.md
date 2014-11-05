
# FEC API Documentation
## Candidate

## Supported parameters for candidate

| Parameter | Description |
|-----|-----|
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
| fields =    | Comma separated list of fields to display or `*` for all |


---

## Supported fields for candidate

### cand_id

Unique id given to a candidate running for an office. Note that a candidate that runs for different offices such as Senate and President, that individual will have multiple `cand_id`s. Candidates with multiple elections in the same chamber do not change `cand_id`s.

`cand_id`s beginning with an 'H' are for House candidates, ids beginning with a 'S' are Senate candidates and ids beginning with 'P' are presidential candidates.

### name

Name has the following children:

#### full_name

Full name of the candidate for the most recent election.

#### name_1

Part of the name that appears after the comma in full name. (This may be null)

#### name_2

Part of the name that appears before the comma in full name. (This may be null)

#### other_names

Variations of the full name of the candidate in FEC records.

### elections

A hash of information specific to each election with the election cycle year as its key.

`elections` has the following children:

#### cand_status / candidate_status

The candidate's statutory standing in an election.

`candidate` Statutory candidate.
`future_candidate` Statutory candidate for future election.
`not_yet_candidate` Not yet a statutory candidate.
`prior_candidate`  Statutory candidate in prior cycle.

#### cand_inactive

Whether or not a candidate is active in an election.

`Y` candidate id inactive
`null` candidate active

#### district

The district of the office the candidate is running for. In cases the code is, `00`, it means there is no district for the office, such as President and Senate, or the member is "at large" for House members.

#### incumbent_challenge

Indicates whether a candidate is an `incumbent`, already in office; a `challenger` to an incumbent; or if it is an `open_seat` and no incumbent is running in the race.

#### office_sought

The office the candidate is seeking, either `President`, `Senate` or `House`.

#### party_affiliation

The Candidate's political party. See full list of political party and party codes [here](party_codes)

#### primary_cmte

The primary committee for the candidate. See full list of political party and party codes [here](party_codes)

`primary_cmte` has the following children:

##### cmte_id

Unique id of the committee.

##### designation

Designation of the committee. See full list of designations and designation codes [here](designations). The committee's designation can affect what rules the committee must follow.

##### designation_code

Designation code of the committee. See full list of designations and designation codes [here](designations).

##### type

The type of the committee. See full list of types and type codes [here](committee_type).The committee's type can affect what rules the committee must follow.

##### type_code

The type of the committee code. See full list of types and type codes [here](committee_type).

#### affiliated_cmtes

A committee affiliated with the candidate. For example, an unauthorized single-candidate PAC.

Each of the affiliated committee has the following children:

##### cmte_id

Unique id of the committee.

##### designation

Designation of the committee. See full list of designations and designation codes [here](designations). The committee's designation can affect what rules the committee must follow.

##### designation_code

Designation code of the committee. See full list of designations and designation codes [here](designations).

##### type

The type of the committee. See full list of types and type codes [here](committee_type).The committee's type can affect what rules the committee must follow.

##### type_code

The type of the committee code. See full list of types and type codes [here](committee_type).

### state

The two-letter postal abbreviation for the state

---

## Sample output






---
