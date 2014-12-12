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


The endpoint automatically displays the most recent information for the committee. Additional expired information may be listed in `archive` and can be requested by adding `fields=*` to the request.
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

#### election_years

A list of election years that a

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

### Sample call
```
/committee?fields=*&q=obama&designation=P&type=P
```

### Sample response
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
            "address": {
                "city": "CHICAGO",
                "expire_date": null,
                "state": "IL",
                "state_full": "Illinois",
                "street_1": "PO BOX 8102",
                "zip": "60680"
            },
            "candidates": [
                {
                    "candidate_id": "P80003338",
                    "designation": "P",
                    "designation_full": "Principal campaign committee",
                    "election_years": [
                        2008,
                        2012
                    ],
                    "expire_date": null,
                    "link_date": "2009-01-01 21:49:00",
                    "type": "P",
                    "type_full": "Presidential"
                }
            ],
            "committee_id": "C00431445",
            "custodian": {
                "city": "CHICAGO",
                "expire_date": null,
                "name_1": "TARYN",
                "name_2": "VOGEL",
                "name_full": "VOGEL, TARYN",
                "name_title": "CUSTODIAN OF RECORDS",
                "phone": "3129851700",
                "state": "IL",
                "street_1": "PO BOX 8102",
                "zip": "60680"
            },
            "description": {
                "email": "OFAFEC@OBAMABIDEN.COM",
                "expire_date": null,
                "filing_frequency": "Q",
                "form_type": "F1",
                "load_date": "2013-08-27 00:00:00",
                "name": "OBAMA FOR AMERICA",
                "website": "HTTP://WWW.OBAMABIDEN.COM"
            },
            "expire_date": null,
            "form_type": "F1",
            "load_date": "2013-08-27 00:00:00",
            "name": "OBAMA FOR AMERICA",
            "status": {
                "designation": "P",
                "designation_full": "Principal campaign committee",
                "expire_date": null,
                "load_date": "2014-11-24 16:52:15",
                "receipt_date": "2007-01-16 00:00:00",
                "type": "P",
                "type_full": "Presidential"
            },
            "treasurer": {
                "city": "CHICAGO",
                "expire_date": null,
                "name_1": "MARTIN",
                "name_2": "NESBITT",
                "name_full": "NESBITT, MARTIN H",
                "name_middle": "H",
                "name_title": "TREASURER",
                "phone": "3129851700",
                "state": "IL",
                "street_1": "PO BOX 8102",
                "zip": "60680"
            }
        }
    ]
}
```
