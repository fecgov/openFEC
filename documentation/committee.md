# FEC API Documentation
## Committee

Endpoint:
`/committee`

## Supported parameters for committee
| Parameter |description |
|-----|-----|
| q=          | full-text search |
| /<cmte_id>  | Single candidate's record |
| cmte_id=    | Synonym for /<cmte_id> |
| name=       | Committee's name |
| state=      | Two-letter state abbreviation |
| type=   |one-letter code of committee type  |
| designation=  |one-letter code of committee designation  |
| organization_type= |one-letter code of organization type |
| candidate_id=  | Associated candidate's id number |
| party = | Party of the committee if applicable |


Information for committee is divided by `properties` and `archive` information that is current for the committee is listed in properties. Expired information is listed in archive and can be requested by addding `fields=*`.
## Fields


#### committee_id

Unique id of the committee.

#### expire_date

Expire dates apply to the information that the date is directly grouped with.

#### form_type

The type of filing the information came from

#### load_date

The date the information was loaded into the system



### Status

This is a grouping of information about the committee's description, designation and filing status.


#### designation_full

Designation of the committee. See full list of designations and designation codes [here](designations). The committee's designation can affect what rules the committee must follow.

#### designation

Designation code of the committee. See full list of designations and designation codes [here](designations).

#### organization_type_full

The written-out organizational structure of the committee. Such as: Corporation, Labor Organization, Membership Organization, Trade Association, Cooperative, Corporation Without Capital Stock.

#### organization_type

Code for organization type

C = Corporation,
L = Labor Organization,
M = Membership Organization,
T = Trade Association,
V = Cooperative,
W = Corporation Without Capital Stock,

#### type_full

The type of the committee. See full list of types and type codes [here](committee_type).The committee's type can affect what rules the committee must follow.

#### type

The type of the committee code. See full list of types and type codes [here](committee_type).




### Description

#### email

Email of the committee, if provided.

#### expire_date

Date the information expires.

#### fax

Fax number of the committee, if provided.

#### filing_frequency

How often a committee is scheduled to file.
M = monthly
Q = quarterly

#### form_type

The type of filing the information came from

#### website

The url to the committee's webpage, if provided.

#### leadership_pac

A flag to identify leadership PACs

#### lobbyist_registrant_pac

A flag for PACs that have registered as being “established or controlled” by a lobbyist or registrant.

#### original_registration_date

Original date of committee registration.

#### party_full

The written-out political party of the committee, if applicable. See full list of political party and party codes [here](party_codes).

#### party

The three-letter code for the political party of the committee, if applicable. See full list of political party and party codes [here](party_codes).

#### qualifying_date

Date a committee became qualified by meeting the requirements and filling our their paperwork.




### Candidates
Candidates associated with a committee. Look at the designation for the kind of relationship.

#### election_year

Year of the election. Elections are in two-year election cycles.

#### candidate_id

Unique id of the candidate

#### designation_full

Written out designation of the committee. See full list of designations and designation codes [here](designations). The committee's designation can affect what rules the committee must follow.

#### designation

Designation code of the committee. See full list of designations and designation codes [here](designations).

#### expire_date

Date the information expires

#### link_date

Date the committee was linked with a candidate.

#### type_full

The type of the committee. See full list of types and type codes [here](committee_type).The committee's type can affect what rules the committee must follow.

#### type

The type of the committee code. See full list of types and type codes [here](committee_type).




### Address
Mailing address of the committee.

#### city

City of committee address.

#### expire_date

Expiration date of the address

#### state

Sate of the committee address

#### street_1

First line of the street of the committee address.

#### street_2

Second line of the street of the committee address, if provided.

#### zip

Zip code of the committee address.




### Treasurer
Information about the treasurer, which may include: name address and phone


### Custodian
Information about the custodian, which may include: name address and phone


---

## Sample output

Sample call
```
/committee/C00000851?fields=*
```

Sample response
```
{
    "api_version": "0.2",
    "pagination": {
        "count": 1,
        "page": 1,
        "pages": 1,
        "per_page": 1
    },
    "results": [
        {
            "archive": [
                {
                    "address": [
                        {
                            "city": "VANCOUVER",
                            "expire_date": "2014-09-18 00:00:00",
                            "state": "WA",
                            "state_full": "Washington",
                            "street_1": "P.O. BOX 2216",
                            "zip": "98661"
                        }
                    ],
                    "description": [
                        {
                            "expire_date": "2014-09-18 00:00:00",
                            "filing_frequency": "Q",
                            "form_type": "F1",
                            "load_date": "2014-09-18 13:28:50"
                        }
                    ],
                    "treasurer": [
                        {
                            "expire_date": "2014-09-18 00:00:00",
                            "name_full": "MR. JAMES W. CALLEY, TREAS."
                        }
                    ]
                }
            ],
            "committee_id": "C00000851",
            "expire_date": null,
            "form_type": "F1",
            "load_date": "2014-09-18 13:28:42",
            "properties": {
                "candidates": [
                    {
                        "candidate_id": "H6WA04034",
                        "designation": "P",
                        "designation_full": "Principal campaign committee",
                        "election_year": 1976.0,
                        "expire_date": null,
                        "link_date": "2007-10-12 13:38:33",
                        "type": "H",
                        "type_full": "House"
                    }
                ],
                "status": {
                    "designation": "P",
                    "designation_full": "Principal campaign committee",
                    "expire_date": null,
                    "load_date": "2014-09-18 13:28:46",
                    "receipt_date": "1976-03-15 00:00:00",
                    "type": "H",
                    "type_full": "House"
                }
            }
        }
    ]
}
```
