
# FEC API Documentation
## Candidate

Provides descriptive information about campaign finance report filers.

## Supported parameters for candidate

| Parameter | Description |
|-----|-----|
| q=          | Full-text search |
| /<candidate_id>  | Single candidate's record |
| candidate_id=    | Synonym for /<candidate_id> |
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

### candidate_id

Unique id given to a candidate running for an office. Note that a candidate that runs for different offices such as Senate and President, that individual will have multiple `candidate_id`s. Candidates with multiple elections in the same chamber do not change `candidate_id`s.

`candidate_id`s beginning with an 'H' are for House candidates, ids beginning with a 'S' are Senate candidates and ids beginning with 'P' are presidential candidates.

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

#### candidate_status

The candidate's statutory standing in an election.

`candidate` Statutory candidate.
`future_candidate` Statutory candidate for future election.
`not_yet_candidate` Not yet a statutory candidate.
`prior_candidate`  Statutory candidate in prior cycle.

#### candidate_inactive

Whether or not a candidate is active in an election.

`Y` candidate id inactive
`null` candidate active

#### district

The district of the office the candidate is running for. In cases the code is, `00`, it means there is no district for the office, such as President and Senate, or the member is "at large" for House members.

#### election_year

Year of the election. Elections are in two-year election cycles.

#### incumbent_challenge

Indicates whether a candidate is an `incumbent`, already in office; a `challenger` to an incumbent; or if it is an `open_seat` and no incumbent is running in the race.

#### office_sought

The office the candidate is seeking, either `President`, `Senate` or `House`.

#### party_affiliation

The candidate's political party. See full list of political party and party codes [here](party_codes).

#### party_full

The written-out political party of the candidate. See full list of political party and party codes [here](party_codes).

#### party

The three-letter code for the political party of the candidate. See full list of political party and party codes [here](party_codes).

#### primary_committee

The primary committee for the candidate. See full list of political party and party codes [here](party_codes)

`primary_committee` has the following children:

##### committee_id

Unique id of the committee.

##### designation_full

Designation of the committee. See full list of designations and designation codes [here](designations). The committee's designation can affect what rules the committee must follow.

##### designation

Designation code of the committee. See full list of designations and designation codes [here](designations).

##### type_full

The type of the committee. See full list of types and type codes [here](committee_type).The committee's type can affect what rules the committee must follow.

##### type

The type of the committee code. See full list of types and type codes [here](committee_type).

#### affiliated_committees

A committee affiliated with the candidate. For example, an unauthorized single-candidate PAC.

Each of the affiliated committee has the following children:

##### committee_id

Unique id of the committee.

##### designation_full

Designation of the committee. See full list of designations and designation codes [here](designations). The committee's designation can affect what rules the committee must follow.

##### designation

Designation code of the committee. See full list of designations and designation codes [here](designations).

##### type_full

The type of the committee. See full list of types and type codes [here](committee_type).The committee's type can affect what rules the committee must follow.

##### type

The type of the committee code. See full list of types and type codes [here](committee_type).

### state

The two-letter postal abbreviation for the state the candidate is running for office.


### mailing address
Mailing address of the candidate's mailing.

#### city

City of candidate's mailing address.

#### expire_date

Expiration date of the address

#### state

Sate of the candidate's mailing address

#### street_1

First line of the street of the candidate's mailing address.

#### street_2

Second line of the street of the candidate's mailing address, if provided.

#### zip

Zipcode of the candidate's mailing address.

---

## Sample output

### Sample call
```
/candidate?office=H&state=CA&name=JENSEN&fields=*
```

### Sample response
```
{
    "api_version": "0.2",
    "pagination": {
        "count": 2,
        "page": 1,
        "pages": 1,
        "per_page": 2
    },
    "results": [
        {
            "candidate_id": "H0CA02146",
            "elections": [
                {
                    "district": "02",
                    "election_year": "2010",
                    "office_sought": "House",
                    "party_affiliation": "Invalid Party Code",
                    "state": "CA"
                }
            ],
            "mailing_addresses": [
                {
                    "city": "DURHAM ",
                    "expire_date": "2012-10-23",
                    "state": "CA",
                    "street_1": "PO BOX 156 ",
                    "street_2": null,
                    "zip": "95938"
                },
                {
                    "city": "DURHAM ",
                    "state": "CA",
                    "street_1": "PO BOX 156",
                    "street_2": null,
                    "zip": "95938"
                }
            ],
            "name": {
                "full_name": "JENSEN, MARK A.",
                "name_1": "MARK A.",
                "name_2": "JENSEN"
            }
        },
        {
            "candidate_id": "H2CA08172",
            "elections": [
                {
                    "candidate_inactive": null,
                    "candidate_status": "candidate",
                    "district": "08",
                    "election_year": "2012",
                    "incumbent_challenge": "challenger",
                    "office_sought": "House",
                    "party_affiliation": "Republican Party",
                    "primary_committee": {
                        "committee_id": "C00512806",
                        "designation": "Principal campaign committee",
                        "designation_code": "P",
                        "type": "House",
                        "type_code": "H"
                    },
                    "state": "CA"
                }
            ],
            "mailing_addresses": [
                {
                    "city": "HESPERIA",
                    "expire_date": "2010-10-23",
                    "state": "CA",
                    "street_1": "8075 E AVE",
                    "street_2": null,
                    "zip": "92345"
                },
                {
                    "city": "HESPERIA",
                    "expire_date": "2011-10-23",
                    "state": "CA",
                    "street_1": "8075 E AVE",
                    "street_2": null,
                    "zip": "92345"
                },
                {
                    "city": "HESPERIA",
                    "expire_date": "2012-10-23",
                    "state": "CA",
                    "street_1": "P.O. BOX 400346",
                    "street_2": null,
                    "zip": "92340"
                },
                {
                    "city": "HESPERIA",
                    "state": "CA",
                    "street_1": "P.O. BOX 400346",
                    "street_2": null,
                    "zip": "92340"
                }
            ],
            "name": {
                "full_name": "JENSEN, WILLIAM O'NEIL JR",
                "name_1": "WILLIAM O'NEIL JR",
                "name_2": "JENSEN"
            }
        }
    ]
}

```

---
